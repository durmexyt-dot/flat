// Sends the emails queued in the "mail" collection over SMTP, in our own
// function (Firebase Extensions are being retired). The SMTP account is a
// secret (SMTP_URI); "none" leaves emails queued until one is set.
import { Timestamp } from 'firebase-admin/firestore';

/** At most this many tries per email (each trigger retry is one). */
export const MAX_ATTEMPTS = 3;

/**
 * Sends one queued email with [transport] (a nodemailer transport) and
 * records the outcome on the document: delivery.state SUCCESS, ERROR or
 * SKIPPED. Sending twice is avoided by claiming the document first.
 */
export async function sendQueuedMail(db, id, { transport, from, now = Date.now() }) {
  const ref = db.doc(`mail/${id}`);
  const claimed = await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) return null;
    const delivery = snap.get('delivery') ?? {};
    if (['SUCCESS', 'PROCESSING'].includes(delivery.state)) return null;
    if ((delivery.attempts ?? 0) >= MAX_ATTEMPTS) return null;
    tx.update(ref, {
      delivery: {
        state: 'PROCESSING',
        attempts: (delivery.attempts ?? 0) + 1,
        startTime: Timestamp.fromMillis(now),
      },
    });
    return snap.data();
  });
  if (!claimed) return 'skipped';
  if (!transport) {
    await ref.update({ 'delivery.state': 'SKIPPED', 'delivery.error': 'No SMTP account set.' });
    return 'skipped';
  }
  try {
    const info = await transport.sendMail({
      from,
      to: claimed.to,
      subject: claimed.message.subject,
      text: claimed.message.text,
      html: claimed.message.html,
    });
    await ref.update({
      'delivery.state': 'SUCCESS',
      'delivery.messageId': info?.messageId ?? '',
      'delivery.endTime': Timestamp.fromMillis(Date.now()),
    });
    return 'sent';
  } catch (e) {
    await ref.update({
      'delivery.state': 'ERROR',
      'delivery.error': String(e?.message ?? e).slice(0, 500),
      'delivery.endTime': Timestamp.fromMillis(Date.now()),
    });
    throw e;
  }
}

/** Emails left in ERROR (or never sent) are tried again by the schedule. */
export async function retryFailedMail(db, send) {
  const failed = await db.collection('mail').where('delivery.state', '==', 'ERROR').limit(50).get();
  let n = 0;
  for (const d of failed.docs) {
    if ((d.get('delivery.attempts') ?? 0) >= MAX_ATTEMPTS) continue;
    try {
      await send(d.id);
      n++;
    } catch {
      // Recorded on the document; the next run tries again.
    }
  }
  return n;
}
