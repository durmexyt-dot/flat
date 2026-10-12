// Cloud Functions of Stubswap (2nd gen). The same code runs for staging and
// prod; .env.<project-id> says which Firestore database each project uses.
import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';
import { setGlobalOptions } from 'firebase-functions/v2';
import { onDocumentCreated, onDocumentDeleted, onDocumentWritten } from 'firebase-functions/v2/firestore';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { defineSecret, defineString } from 'firebase-functions/params';
import nodemailer from 'nodemailer';
import * as core from './lib/core.js';
import * as moderation from './lib/moderation.js';
import * as mailer from './lib/mailer.js';

// Close to the Firestore location (eur3).
setGlobalOptions({ region: 'europe-west1', maxInstances: 10 });

const DATABASE_ID = defineString('DATABASE_ID', { default: '(default)' });
// Where links in emails go (the web app of this environment).
const APP_URL = defineString('APP_URL', { default: 'https://durmexyt-dot.github.io/flat/' });
const appUrl = () => APP_URL.value();
// The SMTP account for emails, e.g. smtps://user:password@smtp-relay.brevo.com:465
// (firebase functions:secrets:set SMTP_URI); "none" keeps emails queued.
const SMTP_URI = defineSecret('SMTP_URI');
const MAIL_FROM = defineString('MAIL_FROM', { default: 'Stubswap <no-reply@stubswap.ba>' });

let transport;
function mailTransport() {
  const uri = SMTP_URI.value();
  if (!uri || uri === 'none') return null;
  transport ??= nodemailer.createTransport(uri);
  return transport;
}
const sendMail = (id) =>
  mailer.sendQueuedMail(db(), id, { transport: mailTransport(), from: MAIL_FROM.value() });

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

// Emails, invoices and seller counts when an order changes.
export const onOrderChanged = onDocumentWritten(
  { document: 'orders/{orderId}', database: DATABASE_ID },
  async (event) => {
    await moderation.orderChanged(
      db(),
      event.params.orderId,
      event.data?.before?.data() ?? null,
      event.data?.after?.data() ?? null,
      { appUrl: appUrl() },
    );
  },
);

// A newly uploaded ticket is checked for copies, then goes to a buyer who is
// waiting for one.
export const onTicketUploaded = onDocumentCreated(
  { document: 'listings/{listingId}/files/{fileId}', database: DATABASE_ID },
  async (event) => {
    const { listingId, fileId } = event.params;
    await moderation.checkTicketFile(db(), bucket(), listingId, fileId);
    await core.deliverTickets(db(), bucket(), listingId);
  },
);

// A file removed before delivery can be uploaded again.
export const onTicketDeleted = onDocumentDeleted(
  { document: 'listings/{listingId}/files/{fileId}', database: DATABASE_ID },
  async (event) => {
    const { listingId, fileId } = event.params;
    await moderation.forgetTicketFile(db(), listingId, fileId, event.data?.get('sha256'));
  },
);

// Active listings per seller, for the limits of new sellers.
export const onListingChanged = onDocumentWritten(
  { document: 'listings/{listingId}', database: DATABASE_ID },
  async (event) => {
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();
    if (before?.status === after?.status) return;
    await moderation.countActiveListings(db(), (after ?? before).sellerId);
  },
);

// The team answered a support request.
export const onSupportMessage = onDocumentCreated(
  { document: 'supportTickets/{ticketId}/messages/{messageId}', database: DATABASE_ID },
  async (event) => {
    await moderation.supportAnswered(db(), event.params.ticketId, event.data?.data() ?? {}, {
      appUrl: appUrl(),
    });
  },
);

// Reservations, delivery deadlines, completion, expired listings.
export const maintenance = onSchedule(
  { schedule: 'every 5 minutes', timeZone: 'Europe/Sarajevo' },
  async () => {
    console.log('maintenance', await core.maintenance(db()));
    console.log('reminders', await moderation.remindUploads(db(), { appUrl: appUrl() }));
  },
);

export const openDispute = callable((uid, data) => core.openDispute(db(), uid, data));
export const resolveDispute = callable((uid, data) => core.resolveDispute(db(), uid, data));
export const cancelEvent = callable((uid, data) => core.cancelEvent(db(), uid, data));
export const postponeEvent = callable((uid, data) => core.postponeEvent(db(), uid, data));

// The team's moderation tools (admins and support accounts).
export const setUserBan = callable((uid, data) => moderation.setUserBan(db(), uid, data));
export const removeListing = callable((uid, data) =>
  moderation.removeListing(db(), uid, data, { appUrl: appUrl() }),
);
export const refundOrder = callable((uid, data) => moderation.refundOrder(db(), uid, data));
export const setSellerTrusted = callable((uid, data) => moderation.setSellerTrusted(db(), uid, data));

// Sends each queued email over SMTP (our own replacement for the Trigger
// Email extension); failures are retried by the hourly schedule below.
export const onMailQueued = onDocumentCreated(
  { document: 'mail/{mailId}', database: DATABASE_ID, secrets: [SMTP_URI] },
  async (event) => {
    await sendMail(event.params.mailId).catch((e) => console.error('mail', event.params.mailId, e));
  },
);

export const retryMail = onSchedule(
  { schedule: 'every 60 minutes', timeZone: 'Europe/Sarajevo', secrets: [SMTP_URI] },
  async () => {
    console.log('mail retried', await mailer.retryFailedMail(db(), sendMail));
  },
);
