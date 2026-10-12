// Fraud protection, seller limits and the team's moderation tools (admins
// and support accounts), plus what follows from an order changing: emails,
// invoices and seller counts.
import { createHash } from 'node:crypto';
import { Timestamp } from 'firebase-admin/firestore';
import { UserError, isStaff, refundOrderInTx } from './core.js';
import { queueMail } from './mails.js';
import { creditOrderInvoices, issueOrderInvoices } from './invoices.js';

async function requireStaff(db, uid) {
  if (!(await isStaff(db, uid))) throw new UserError('permission-denied', 'Team accounts only.');
}

function log(db, entry, now) {
  return db.collection('moderationLog').add({ ...entry, at: Timestamp.fromMillis(now) });
}

// ---------------------------------------------------------------------------
// Ticket files sold twice
// ---------------------------------------------------------------------------

/**
 * Checks a newly uploaded ticket file: the same file (by its SHA-256) may
 * only be on sale once. A copy is blocked (never delivered) and reported to
 * the team; otherwise the file is marked checked and can be delivered.
 * Returns "ok", "duplicate" or "missing".
 */
export async function checkTicketFile(db, bucket, listingId, fileId, now = Date.now()) {
  const fileRef = db.doc(`listings/${listingId}/files/${fileId}`);
  const file = await fileRef.get();
  if (!file.exists) return 'missing';
  const [bytes] = await bucket.file(file.get('storagePath')).download();
  const hash = createHash('sha256').update(bytes).digest('hex');
  const listing = (await db.doc(`listings/${listingId}`).get()).data() ?? {};
  const hashRef = db.doc(`ticketHashes/${hash}`);
  return db.runTransaction(async (tx) => {
    const seen = await tx.get(hashRef);
    const other = seen.exists ? seen.data() : null;
    if (other && !(other.listingId === listingId && other.fileId === fileId)) {
      tx.update(fileRef, {
        checked: true,
        blocked: true,
        duplicateOf: { listingId: other.listingId, fileId: other.fileId, sellerId: other.sellerId },
      });
      tx.set(db.collection('reports').doc(`dup_${listingId}_${fileId}`), {
        type: 'duplicateTicket',
        listingId,
        fileId,
        sellerId: listing.sellerId ?? '',
        otherListingId: other.listingId,
        otherFileId: other.fileId,
        otherSellerId: other.sellerId,
        eventName: listing.event?.name ?? '',
        status: 'open',
        createdAt: Timestamp.fromMillis(now),
      });
      return 'duplicate';
    }
    tx.set(hashRef, { listingId, fileId, sellerId: listing.sellerId ?? '', at: Timestamp.fromMillis(now) });
    tx.update(fileRef, { checked: true, sha256: hash });
    return 'ok';
  });
}

/** A file the seller removed before delivery may be uploaded again. */
export async function forgetTicketFile(db, listingId, fileId, sha256) {
  if (!sha256) return;
  const ref = db.doc(`ticketHashes/${sha256}`);
  await db.runTransaction(async (tx) => {
    const h = await tx.get(ref);
    if (h.exists && h.get('listingId') === listingId && h.get('fileId') === fileId) tx.delete(ref);
  });
}

// ---------------------------------------------------------------------------
// Seller counts for the limits of new sellers
// ---------------------------------------------------------------------------

export async function countActiveListings(db, sellerId, now = Date.now()) {
  if (!sellerId) return;
  const n = (
    await db.collection('listings').where('sellerId', '==', sellerId).where('status', '==', 'active').count().get()
  ).data().count;
  await db.doc(`sellerStats/${sellerId}`).set(
    { activeListings: n, updatedAt: Timestamp.fromMillis(now) },
    { merge: true },
  );
}

export async function countCompletedSales(db, sellerId, now = Date.now()) {
  if (!sellerId) return;
  const n = (
    await db.collection('orders').where('sellerId', '==', sellerId).where('status', '==', 'completed').count().get()
  ).data().count;
  await db.doc(`sellerStats/${sellerId}`).set(
    { completedSales: n, updatedAt: Timestamp.fromMillis(now) },
    { merge: true },
  );
}

// ---------------------------------------------------------------------------
// An order changed: emails, invoices, counts
// ---------------------------------------------------------------------------

/**
 * Reacts to an order going from [before] to [after] (either may be null).
 * Each email has a fixed id per order and step, so a retried trigger sends
 * it once.
 */
export async function orderChanged(db, orderId, before, after, { appUrl, now = Date.now() }) {
  if (!after) return;
  const from = before?.status;
  const to = after.status;
  const o = { ...after, id: orderId };
  const buyer = (kind) =>
    queueMail(db, { uid: after.buyerId, kind, data: o, path: `/order/${orderId}`, appUrl, now, id: `${orderId}-${kind}` });
  const seller = (kind, extra = {}) =>
    queueMail(db, {
      uid: after.sellerId, kind, data: { ...o, ...extra }, path: `/order/${orderId}`, appUrl, now, id: `${orderId}-${kind}`,
    });
  if (from === to) {
    // Moved to another date while still open.
    const was = before?.event?.date?.toMillis?.();
    const is = after.event?.date?.toMillis?.();
    if (was && is && was !== is && ['paid', 'ticketsSent', 'disputed'].includes(to)) {
      await queueMail(db, {
        uid: after.buyerId, kind: 'eventPostponed', data: o, path: `/order/${orderId}`, appUrl, now,
        id: `${orderId}-postponed-${is}`,
      });
    }
    return;
  }
  if (to === 'paid' && from === 'pendingPayment') {
    await buyer('orderPaid');
    await seller('ticketSold', { ticketsReady: await uploadedFor(db, after, orderId) });
    await issueOrderInvoices(db, orderId, now);
  } else if (to === 'ticketsSent') {
    await buyer('ticketsReady');
  } else if (to === 'refunded') {
    await buyer('orderRefunded');
    await seller('saleCancelled');
    await creditOrderInvoices(db, orderId, now);
  } else if (to === 'disputed') {
    await seller('disputeOpened');
  } else if (to === 'completed') {
    const payout = await db.doc(`payouts/${orderId}`).get();
    await queueMail(db, {
      uid: after.sellerId, kind: 'payoutReleased', data: { ...o, earnings: payout.get('amountMinor') ?? 0 },
      path: '/account/payouts', appUrl, now, id: `${orderId}-payoutReleased`,
    });
    await countCompletedSales(db, after.sellerId, now);
  }
}

/**
 * Whether the seller already uploaded enough e-tickets for [order]: files
 * not handed to another order (nor blocked copies) cover its quantity.
 */
async function uploadedFor(db, order, orderId) {
  if ((order.ticketType ?? 'eTicket') !== 'eTicket' || !order.listingId) return false;
  const files = await db.collection(`listings/${order.listingId}/files`).get();
  const tickets = files.docs
    .filter((f) => [null, undefined, orderId].includes(f.get('orderId')) && f.get('blocked') !== true)
    .reduce((n, f) => n + (f.get('tickets') ?? 1), 0);
  return tickets >= order.quantity;
}

/** Reminds sellers once when e-tickets are still missing two days before the event. */
export async function remindUploads(db, { appUrl, now = Date.now() }) {
  const soon = (await db.collection('orders').where('status', '==', 'paid').get()).docs.filter((d) => {
    const at = d.get('event.date')?.toMillis?.() ?? 0;
    return (
      (d.get('ticketType') ?? 'eTicket') === 'eTicket' &&
      (d.get('ticketsDelivered') ?? 0) < d.get('quantity') &&
      !d.get('uploadReminderAt') &&
      at - now < 48 * 3600 * 1000 &&
      at > now
    );
  });
  for (const d of soon) {
    await queueMail(db, {
      uid: d.get('sellerId'), kind: 'uploadReminder', data: { ...d.data(), id: d.id },
      path: `/order/${d.id}`, appUrl, now, id: `${d.id}-uploadReminder`,
    });
    await d.ref.update({ uploadReminderAt: Timestamp.fromMillis(now) });
  }
  return soon.length;
}

/** The team answered a support request: tell the user by email. */
export async function supportAnswered(db, ticketId, message, { appUrl, now = Date.now() }) {
  if (message.authorRole !== 'staff') return null;
  const t = await db.doc(`supportTickets/${ticketId}`).get();
  if (!t.exists) return null;
  return queueMail(db, {
    uid: t.get('uid'), kind: 'supportAnswer', data: t.data(), path: `/support/ticket/${ticketId}`, appUrl, now,
  });
}

// ---------------------------------------------------------------------------
// The team's tools (callable)
// ---------------------------------------------------------------------------

/** Blocks or unblocks a user; blocking takes their listings off sale. */
export async function setUserBan(db, staffUid, { uid, banned, reason }, now = Date.now()) {
  await requireStaff(db, staffUid);
  if (!uid || typeof uid !== 'string') throw new UserError('invalid-argument', 'No user.');
  if (uid === staffUid || (await isStaff(db, uid))) {
    throw new UserError('failed-precondition', 'Team accounts cannot be blocked.');
  }
  const why = String(reason ?? '').trim().slice(0, 300);
  const ref = db.doc(`bans/${uid}`);
  if (banned) {
    await ref.set({ reason: why, by: staffUid, at: Timestamp.fromMillis(now) });
    const active = await db.collection('listings').where('sellerId', '==', uid).where('status', '==', 'active').get();
    const batch = db.batch();
    for (const l of active.docs) {
      batch.update(l.ref, {
        status: 'removed', removedReason: 'banned', removedBy: staffUid, updatedAt: Timestamp.fromMillis(now),
      });
    }
    await batch.commit();
    await log(db, { action: 'ban', targetUid: uid, staffUid, reason: why, listings: active.size }, now);
    return { listingsRemoved: active.size };
  }
  await ref.delete();
  await log(db, { action: 'unban', targetUid: uid, staffUid, reason: why }, now);
  return { listingsRemoved: 0 };
}

/** Takes a listing off sale for breaking the rules; the seller gets an email. */
export async function removeListing(db, staffUid, { listingId, reason }, { appUrl, now = Date.now() } = {}) {
  await requireStaff(db, staffUid);
  const ref = db.doc(`listings/${listingId}`);
  const why = String(reason ?? '').trim().slice(0, 300);
  const listing = await db.runTransaction(async (tx) => {
    const l = await tx.get(ref);
    if (!l.exists) throw new UserError('not-found', 'No such listing.');
    if (!['active', 'soldOut'].includes(l.get('status'))) {
      throw new UserError('failed-precondition', 'The listing is not on sale.');
    }
    tx.update(ref, {
      status: 'removed', removedReason: why, removedBy: staffUid, updatedAt: Timestamp.fromMillis(now),
    });
    return l.data();
  });
  await log(db, { action: 'removeListing', targetUid: listing.sellerId, listingId, staffUid, reason: why }, now);
  if (appUrl) {
    await queueMail(db, {
      uid: listing.sellerId, kind: 'listingRemoved', data: { ...listing, reason: why },
      path: '/account/listings', appUrl, now, id: `${listingId}-removed`,
    });
  }
}

/** The team refunds a paid order (e.g. fake tickets found later). */
export async function refundOrder(db, staffUid, { orderId, reason }, now = Date.now()) {
  await requireStaff(db, staffUid);
  const ref = db.doc(`orders/${orderId}`);
  const why = String(reason ?? '').trim().slice(0, 300);
  const order = await db.runTransaction(async (tx) => {
    const o = await tx.get(ref);
    if (!o.exists) throw new UserError('not-found', 'No such order.');
    if (!['paid', 'ticketsSent', 'disputed'].includes(o.get('status'))) {
      throw new UserError('failed-precondition', 'This order cannot be refunded.');
    }
    const listing = await tx.get(db.doc(`listings/${o.get('listingId')}`));
    refundOrderInTx(tx, db, o, listing, { by: 'support', now, returnTickets: false });
    tx.update(ref, { refundReason: why });
    return o.data();
  });
  await log(db, { action: 'refund', targetUid: order.sellerId, orderId, staffUid, reason: why }, now);
}

/** Trusted sellers have no listing limits. */
export async function setSellerTrusted(db, staffUid, { uid, trusted }, now = Date.now()) {
  await requireStaff(db, staffUid);
  if (!uid) throw new UserError('invalid-argument', 'No user.');
  await db.doc(`sellerStats/${uid}`).set(
    { trusted: trusted === true, updatedAt: Timestamp.fromMillis(now) },
    { merge: true },
  );
  await log(db, { action: trusted ? 'trust' : 'untrust', targetUid: uid, staffUid }, now);
}

