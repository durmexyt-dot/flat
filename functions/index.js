// Cloud Functions of Stubswap (2nd gen). The same code runs for staging and
// prod; .env.<project-id> says which Firestore database each project uses.
import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';
import { setGlobalOptions } from 'firebase-functions/v2';
import { onDocumentCreated, onDocumentWritten } from 'firebase-functions/v2/firestore';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { defineString } from 'firebase-functions/params';
import * as core from './lib/core.js';

// Close to the Firestore location (eur3).
setGlobalOptions({ region: 'europe-west1', maxInstances: 10 });

const DATABASE_ID = defineString('DATABASE_ID', { default: '(default)' });

initializeApp();
const db = () =>
  DATABASE_ID.value() === '(default)' ? getFirestore() : getFirestore(DATABASE_ID.value());
const bucket = () => getStorage().bucket();

/** Runs a callable's work and turns our errors into the client's error codes. */
function callable(work) {
  return onCall(async (request) => {
    if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in first.');
    try {
      return (await work(request.auth.uid, request.data ?? {})) ?? {};
    } catch (e) {
      if (e instanceof core.UserError) throw new HttpsError(e.code, e.message);
      throw e;
    }
  });
}

// A paid order gets the seller's uploaded tickets right away.
export const onOrderPaid = onDocumentWritten(
  { document: 'orders/{orderId}', database: DATABASE_ID },
  async (event) => {
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();
    if (!after || after.status !== 'paid' || before?.status === 'paid') return;
    await core.deliverTickets(db(), bucket(), after.listingId);
  },
);

// A newly uploaded ticket goes to a buyer who is waiting for one.
export const onTicketUploaded = onDocumentCreated(
  { document: 'listings/{listingId}/files/{fileId}', database: DATABASE_ID },
  async (event) => {
    await core.deliverTickets(db(), bucket(), event.params.listingId);
  },
);

// Reservations, delivery deadlines, completion, expired listings.
export const maintenance = onSchedule(
  { schedule: 'every 5 minutes', timeZone: 'Europe/Sarajevo' },
  async () => {
    console.log('maintenance', await core.maintenance(db()));
  },
);

export const openDispute = callable((uid, data) => core.openDispute(db(), uid, data));
export const resolveDispute = callable((uid, data) => core.resolveDispute(db(), uid, data));
export const cancelEvent = callable((uid, data) => core.cancelEvent(db(), uid, data));
export const postponeEvent = callable((uid, data) => core.postponeEvent(db(), uid, data));
