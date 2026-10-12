// The server side of Stubswap: everything that has to happen even when no
// buyer or seller has the app open. Written against plain Firestore and
// Storage handles, so the emulator tests can call it directly.
import { randomUUID } from 'node:crypto';
import { FieldValue, Timestamp } from 'firebase-admin/firestore';

/** A buyer has this long to pay; the tickets are held meanwhile. */
export const RESERVATION_MINUTES = 15;

/** Tickets must be delivered this long before the event, or the buyer is refunded. */
export const DELIVERY_DEADLINE_HOURS = 24;

/** Orders complete (and payouts are released) this long after the event. */
export const COMPLETE_AFTER_DAYS = 3;

/** Buyers can report a problem until this long after the event. */
export const DISPUTE_WINDOW_DAYS = 7;

const MINUTE = 60 * 1000;
const HOUR = 60 * MINUTE;
const DAY = 24 * HOUR;

/** A thrown error the app shows to the user (callable functions). */
export class UserError extends Error {
  constructor(code, message) {
    super(message);
    this.code = code;
  }
}

const step = (status, at) => ({ status, at: Timestamp.fromMillis(at) });
const millis = (t) => (t instanceof Timestamp ? t.toMillis() : t ? new Date(t).getTime() : 0);

export async function isStaff(db, uid) {
  if (!uid) return false;
  const role = await db.doc(`roles/${uid}`).get();
  return role.exists && ['admin', 'support'].includes(role.get('role'));
}

async function requireStaff(db, uid) {
  if (!(await isStaff(db, uid))) throw new UserError('permission-denied', 'Team accounts only.');
}

/** Writes in chunks below Firestore's 500 operations per batch. */
async function commitAll(db, ops) {
  for (let i = 0; i < ops.length; i += 400) {
    const batch = db.batch();
    for (const op of ops.slice(i, i + 400)) op(batch);
    await batch.commit();
  }
}

// ---------------------------------------------------------------------------
// Ticket delivery
// ---------------------------------------------------------------------------

/**
 * Hands the seller's uploaded ticket files of [listingId] to paid orders that
 * are still waiting for tickets, oldest order first. Each file is copied to
 * deliveries/{orderId}/ where only the buyer and the seller can read it; once
 * an order has all its tickets it moves to "tickets sent".
 */
export async function deliverTickets(db, bucket, listingId, now = Date.now()) {
  const listingRef = db.doc(`listings/${listingId}`);
  const orders = (await db.collection('orders').where('listingId', '==', listingId).get()).docs
    .filter((d) => d.get('status') === 'paid' && (d.get('ticketsDelivered') ?? 0) < d.get('quantity'))
    .sort((a, b) => millis(a.get('createdAt')) - millis(b.get('createdAt')));
  let delivered = 0;
  for (const orderDoc of orders) {
    // Claim files in a transaction, so two runs never hand out the same file.
    const claimed = await db.runTransaction(async (tx) => {
      const order = await tx.get(orderDoc.ref);
      if (order.get('status') !== 'paid') return [];
      let need = order.get('quantity') - (order.get('ticketsDelivered') ?? 0);
      const files = (await tx.get(listingRef.collection('files').where('orderId', '==', null))).docs
        .sort((a, b) => millis(a.get('uploadedAt')) - millis(b.get('uploadedAt')));
      const picked = [];
      for (const f of files) {
        const tickets = f.get('tickets') ?? 1;
        if (tickets > need) continue;
        picked.push(f);
        need -= tickets;
        if (need === 0) break;
      }
      for (const f of picked) {
        tx.update(f.ref, { orderId: order.id, assignedAt: Timestamp.fromMillis(now) });
      }
      return picked.map((f) => ({ id: f.id, ...f.data() }));
    });
    if (claimed.length === 0) continue;

    const order = orderDoc.data();
    let tickets = 0;
    for (const f of claimed) {
      const dest = `deliveries/${orderDoc.id}/${f.id}`;
      const source = bucket.file(f.storagePath);
      await source.copy(bucket.file(dest));
      await bucket.file(dest).setMetadata({
        contentType: f.contentType,
        contentDisposition: `attachment; filename="${f.name.replace(/"/g, '')}"`,
        metadata: {
          buyerId: order.buyerId,
          sellerId: order.sellerId,
          // A download link of its own: the copy would keep the seller's.
          firebaseStorageDownloadTokens: randomUUID(),
        },
      });
      await orderDoc.ref.collection('files').doc(f.id).set({
        name: f.name,
        contentType: f.contentType,
        size: f.size,
        tickets: f.tickets ?? 1,
        storagePath: dest,
        deliveredAt: Timestamp.fromMillis(now),
      });
      tickets += f.tickets ?? 1;
    }
    await db.runTransaction(async (tx) => {
      const fresh = await tx.get(orderDoc.ref);
      const total = (fresh.get('ticketsDelivered') ?? 0) + tickets;
      const complete = total >= fresh.get('quantity') && fresh.get('status') === 'paid';
      tx.update(orderDoc.ref, {
        ticketsDelivered: total,
        ...(complete
          ? {
              status: 'ticketsSent',
              deliveredAt: Timestamp.fromMillis(now),
              history: FieldValue.arrayUnion(step('ticketsSent', now)),
            }
          : {}),
        updatedAt: Timestamp.fromMillis(now),
      });
    });
    delivered += tickets;
  }
  return delivered;
}

// ---------------------------------------------------------------------------
// Refunds
// ---------------------------------------------------------------------------

/**
 * Refunds a paid order in [tx]: the order is refunded, the seller's payout
 * dropped, and with [returnTickets] the tickets go back on sale.
 */
function refundInTx(tx, db, orderSnap, listingSnap, { by, now, returnTickets }) {
  const order = orderSnap.data();
  tx.update(orderSnap.ref, {
    status: 'refunded',
    cancelledBy: by,
    history: FieldValue.arrayUnion(step('refunded', now)),
    updatedAt: Timestamp.fromMillis(now),
  });
  tx.delete(db.doc(`payouts/${orderSnap.id}`));
  if (returnTickets && listingSnap?.exists) {
    const l = listingSnap.data();
    tx.update(listingSnap.ref, {
      quantitySold: Math.max(0, (l.quantitySold ?? 0) - order.quantity),
      ...(l.status === 'soldOut' ? { status: 'active' } : {}),
      updatedAt: Timestamp.fromMillis(now),
    });
  }
}

// ---------------------------------------------------------------------------
// Deadlines (scheduled)
// ---------------------------------------------------------------------------

/** Unpaid orders past the reservation give their tickets back. */
export async function expireReservations(db, now = Date.now()) {
  const pending = (await db.collection('orders').where('status', '==', 'pendingPayment').get()).docs
    .filter((d) => millis(d.get('createdAt')) + RESERVATION_MINUTES * MINUTE < now);
  for (const d of pending) {
    await db.runTransaction(async (tx) => {
      const order = await tx.get(d.ref);
      if (order.get('status') !== 'pendingPayment') return;
      const listingRef = db.doc(`listings/${order.get('listingId')}`);
      const listing = await tx.get(listingRef);
      tx.update(d.ref, {
        status: 'cancelled',
        failureReason: 'expired',
        cancelledBy: 'expired',
        history: FieldValue.arrayUnion(step('cancelled', now)),
        updatedAt: Timestamp.fromMillis(now),
      });
      if (listing.exists && order.get('reserved') === true) {
        tx.update(listingRef, {
          quantityReserved: Math.max(0, (listing.get('quantityReserved') ?? 0) - order.get('quantity')),
          updatedAt: Timestamp.fromMillis(now),
        });
      }
    });
  }
  return pending.length;
}

/** Paid orders without (all) tickets close to the event are refunded. */
export async function refundUndelivered(db, now = Date.now()) {
  const late = (await db.collection('orders').where('status', '==', 'paid').get()).docs.filter(
    (d) =>
      millis(d.get('event.date')) - DELIVERY_DEADLINE_HOURS * HOUR < now &&
      (d.get('ticketsDelivered') ?? 0) < d.get('quantity') &&
      // Mobile and paper tickets are handed over outside the app.
      (d.get('ticketType') ?? 'eTicket') === 'eTicket',
  );
  for (const d of late) {
    await db.runTransaction(async (tx) => {
      const order = await tx.get(d.ref);
      if (order.get('status') !== 'paid') return;
      const listing = await tx.get(db.doc(`listings/${order.get('listingId')}`));
      refundInTx(tx, db, order, listing, { by: 'deadline', now, returnTickets: false });
    });
  }
  return late.length;
}

/** After the event (and a few quiet days) orders complete and payouts are released. */
export async function completeOrders(db, now = Date.now()) {
  const done = (await db.collection('orders').where('status', '==', 'ticketsSent').get()).docs.filter(
    (d) => millis(d.get('event.date')) + COMPLETE_AFTER_DAYS * DAY < now,
  );
  for (const d of done) {
    const payoutRef = db.doc(`payouts/${d.id}`);
    await db.runTransaction(async (tx) => {
      const order = await tx.get(d.ref);
      if (order.get('status') !== 'ticketsSent') return;
      const payout = await tx.get(payoutRef);
      tx.update(d.ref, {
        status: 'completed',
        history: FieldValue.arrayUnion(step('completed', now)),
        updatedAt: Timestamp.fromMillis(now),
      });
      if (payout.exists && payout.get('status') === 'pending') {
        tx.update(payoutRef, {
          status: 'scheduled',
          history: FieldValue.arrayUnion(step('scheduled', now)),
        });
      }
    });
  }
  return done.length;
}

/** Listings of events that took place are no longer on sale. */
export async function expireListings(db, now = Date.now()) {
  const old = (await db.collection('listings').where('status', '==', 'active').get()).docs.filter(
    (d) => millis(d.get('event.date')) < now,
  );
  await commitAll(
    db,
    old.map((d) => (b) => b.update(d.ref, { status: 'expired', updatedAt: Timestamp.fromMillis(now) })),
  );
  return old.length;
}

export async function maintenance(db, now = Date.now()) {
  return {
    expired: await expireReservations(db, now),
    refunded: await refundUndelivered(db, now),
    completed: await completeOrders(db, now),
    listingsExpired: await expireListings(db, now),
  };
}

// ---------------------------------------------------------------------------
// Problems with an order (buyer protection)
// ---------------------------------------------------------------------------

const DISPUTE_REASONS = ['notReceived', 'invalid', 'wrongTickets', 'eventChanged', 'other'];

/**
 * The buyer reports a problem: the order is put on hold (no completion, no
 * payout) and a support request is opened for the team.
 */
export async function openDispute(db, uid, { orderId, reason, text }, now = Date.now()) {
  if (!DISPUTE_REASONS.includes(reason)) throw new UserError('invalid-argument', 'Unknown reason.');
  const message = String(text ?? '').trim();
  if (message.length < 10 || message.length > 2000) {
    throw new UserError('invalid-argument', 'Describe the problem (10–2000 characters).');
  }
  const ref = db.doc(`orders/${orderId}`);
  const ticketRef = db.collection('supportTickets').doc();
  await db.runTransaction(async (tx) => {
    const order = await tx.get(ref);
    if (!order.exists || order.get('buyerId') !== uid) {
      throw new UserError('permission-denied', 'Not your order.');
    }
    const status = order.get('status');
    if (!['paid', 'ticketsSent', 'completed'].includes(status)) {
      throw new UserError('failed-precondition', 'This order cannot be reported.');
    }
    if (millis(order.get('event.date')) + DISPUTE_WINDOW_DAYS * DAY < now) {
      throw new UserError('failed-precondition', 'Too late to report this order.');
    }
    const user = await tx.get(db.doc(`users/${uid}`));
    const name = user.get('displayName') ?? '';
    tx.update(ref, {
      status: 'disputed',
      dispute: {
        reason,
        text: message,
        previousStatus: status,
        supportTicketId: ticketRef.id,
        openedAt: Timestamp.fromMillis(now),
      },
      history: FieldValue.arrayUnion(step('disputed', now)),
      updatedAt: Timestamp.fromMillis(now),
    });
    const number = `SUP-${randomCode(6)}`;
    const subject = `${order.get('number')}: ${message}`.replace(/\s+/g, ' ');
    tx.set(ticketRef, {
      number,
      uid,
      email: user.get('email') ?? '',
      name,
      topic: 'order',
      reference: order.get('number'),
      subject: subject.length <= 80 ? subject : `${subject.slice(0, 79)}…`,
      status: 'open',
      unreadForUser: false,
      unreadForStaff: true,
      appVersion: 'dispute',
      // The team opens the order from the request to decide.
      orderId: order.id,
      createdAt: Timestamp.fromMillis(now),
      lastMessageAt: Timestamp.fromMillis(now),
    });
    tx.set(ticketRef.collection('messages').doc(), {
      authorId: uid,
      authorRole: 'user',
      authorName: name,
      text: message,
      images: [],
      createdAt: Timestamp.fromMillis(now),
    });
  });
  return { supportTicketId: ticketRef.id };
}

/** The team decides: refund the buyer, or reject and continue the order. */
export async function resolveDispute(db, uid, { orderId, decision, note }, now = Date.now()) {
  await requireStaff(db, uid);
  if (!['refund', 'reject'].includes(decision)) throw new UserError('invalid-argument', 'Unknown decision.');
  const ref = db.doc(`orders/${orderId}`);
  await db.runTransaction(async (tx) => {
    const order = await tx.get(ref);
    if (!order.exists || order.get('status') !== 'disputed') {
      throw new UserError('failed-precondition', 'No open problem on this order.');
    }
    const listing = await tx.get(db.doc(`listings/${order.get('listingId')}`));
    const resolution = {
      'dispute.decision': decision,
      'dispute.note': String(note ?? '').slice(0, 1000),
      'dispute.resolvedBy': uid,
      'dispute.resolvedAt': Timestamp.fromMillis(now),
    };
    if (decision === 'refund') {
      refundInTx(tx, db, order, listing, { by: 'support', now, returnTickets: false });
      tx.update(ref, resolution);
    } else {
      const previous = order.get('dispute.previousStatus') ?? 'ticketsSent';
      tx.update(ref, {
        ...resolution,
        status: previous,
        history: FieldValue.arrayUnion(step(previous, now)),
        updatedAt: Timestamp.fromMillis(now),
      });
    }
  });
}

// ---------------------------------------------------------------------------
// Cancelled and postponed events
// ---------------------------------------------------------------------------

async function eventOrders(db, eventId) {
  const listings = (await db.collection('listings').where('eventId', '==', eventId).get()).docs;
  const orders = [];
  for (const l of listings) {
    orders.push(...(await db.collection('orders').where('listingId', '==', l.id).get()).docs);
  }
  return { listings, orders };
}

/** The event is off: every buyer is refunded and nothing is sold anymore. */
export async function cancelEvent(db, uid, { eventId, reason }, now = Date.now()) {
  await requireStaff(db, uid);
  const eventRef = db.doc(`events/${eventId}`);
  const event = await eventRef.get();
  if (!event.exists) throw new UserError('not-found', 'No such event.');
  if (event.get('status') === 'cancelled') return { refunded: 0 };
  const { listings, orders } = await eventOrders(db, eventId);
  const ops = [];
  let refunded = 0;
  const at = Timestamp.fromMillis(now);
  for (const o of orders) {
    const status = o.get('status');
    if (status === 'pendingPayment') {
      ops.push((b) =>
        b.update(o.ref, {
          status: 'cancelled',
          cancelledBy: 'event',
          history: FieldValue.arrayUnion(step('cancelled', now)),
          updatedAt: at,
        }),
      );
    } else if (['paid', 'ticketsSent', 'disputed'].includes(status)) {
      refunded++;
      ops.push((b) =>
        b.update(o.ref, {
          status: 'refunded',
          cancelledBy: 'event',
          history: FieldValue.arrayUnion(step('refunded', now)),
          updatedAt: at,
        }),
      );
      ops.push((b) => b.delete(db.doc(`payouts/${o.id}`)));
    }
  }
  for (const l of listings) {
    if (['active', 'reserved', 'soldOut'].includes(l.get('status'))) {
      ops.push((b) => b.update(l.ref, { status: 'withdrawn', quantityReserved: 0, updatedAt: at }));
    }
  }
  ops.push((b) =>
    b.update(eventRef, {
      status: 'cancelled',
      cancelReason: String(reason ?? '').slice(0, 300),
      updatedAt: at,
    }),
  );
  await commitAll(db, ops);
  return { refunded };
}

/** The event moves to [newDate]: tickets stay valid, all copies get the new date. */
export async function postponeEvent(db, uid, { eventId, newDate }, now = Date.now()) {
  await requireStaff(db, uid);
  const date = new Date(newDate);
  if (Number.isNaN(date.getTime()) || date.getTime() <= now) {
    throw new UserError('invalid-argument', 'The new date must be in the future.');
  }
  const eventRef = db.doc(`events/${eventId}`);
  const event = await eventRef.get();
  if (!event.exists || event.get('status') === 'cancelled') {
    throw new UserError('failed-precondition', 'This event cannot be moved.');
  }
  const at = Timestamp.fromMillis(now);
  const ts = Timestamp.fromDate(date);
  const { listings, orders } = await eventOrders(db, eventId);
  const open = orders.filter((o) =>
    ['pendingPayment', 'paid', 'ticketsSent', 'disputed'].includes(o.get('status')),
  );
  // Only paid orders have a payout; its expected date moves along.
  const payouts = (await Promise.all(open.map((o) => db.doc(`payouts/${o.id}`).get()))).filter(
    (p) => p.exists,
  );
  const ops = [
    (b) =>
      b.update(eventRef, {
        date: ts,
        // The first original date stays, also when moved twice.
        postponedFrom: event.get('postponedFrom') ?? event.get('date'),
        updatedAt: at,
      }),
    ...listings.map((l) => (b) => b.update(l.ref, { 'event.date': ts, updatedAt: at })),
    ...open.map((o) => (b) => b.update(o.ref, { 'event.date': ts, updatedAt: at })),
    ...payouts.map((p) => (b) =>
      b.update(p.ref, { expectedAt: Timestamp.fromMillis(date.getTime() + 5 * DAY) }),
    ),
  ];
  await commitAll(db, ops);
  return { listings: listings.length, orders: open.length };
}

function randomCode(length) {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let s = '';
  for (let i = 0; i < length; i++) s += chars[Math.floor(Math.random() * chars.length)];
  return s;
}
