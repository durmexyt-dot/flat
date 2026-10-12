// Runs against the Firestore and Storage emulators, like core.test.js (own
// project id, so both files can run at the same time).
import { test, before, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { initializeApp } from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';
import * as core from '../lib/core.js';
import * as moderation from '../lib/moderation.js';
import { render, money } from '../lib/mails.js';
import { splitVat } from '../lib/invoices.js';
import * as mailer from '../lib/mailer.js';

const PROJECT = 'stubswap-moderation-test';
const APP = 'https://example.test/flat/';
let db;
let bucket;
const DAY = 24 * 3600 * 1000;
const NOW = Date.now();
const ts = (ms) => Timestamp.fromMillis(ms);

before(() => {
  const app = initializeApp({ projectId: PROJECT, storageBucket: `${PROJECT}.appspot.com` }, 'moderation');
  db = getFirestore(app);
  bucket = getStorage(app).bucket();
});

beforeEach(async () => {
  await fetch(`http://${process.env.FIRESTORE_EMULATOR_HOST}/emulator/v1/projects/${PROJECT}/databases/(default)/documents`, { method: 'DELETE' });
  await db.doc('roles/boss').set({ role: 'admin' });
  await db.doc('roles/helper').set({ role: 'support' });
  for (const uid of ['buyer', 'seller']) {
    await db.doc(`users/${uid}`).set({ displayName: uid === 'buyer' ? 'Kupac' : 'Prodavac', email: `${uid}@test.ba`, language: 'de' });
  }
});

const EVENT = { name: 'Jazz', venue: 'Dom', city: 'Sarajevo', date: ts(NOW + 10 * DAY), category: 'concerts' };

async function listing(id, over = {}) {
  await db.doc(`listings/${id}`).set({
    sellerId: 'seller', eventId: 'E1', event: EVENT, quantity: 4, quantitySold: 0, priceMinor: 3500,
    currency: 'BAM', status: 'active', ticketType: 'eTicket', ...over,
  });
}

const order = (over = {}) => ({
  number: 'SSW-AAAAAA', listingId: 'L1', buyerId: 'buyer', sellerId: 'seller', event: EVENT, quantity: 2,
  unitPriceMinor: 5000, currency: 'BAM', buyerFeePercent: 10, sellerFeePercent: 15, ticketType: 'eTicket',
  status: 'paid', createdAt: ts(NOW), history: [], ...over,
});

async function upload(listingId, fileId, content) {
  const path = `tickets/seller/${listingId}/${fileId}`;
  await bucket.file(path).save(Buffer.from(content), { contentType: 'application/pdf' });
  await db.doc(`listings/${listingId}/files/${fileId}`).set({
    name: `${fileId}.pdf`, contentType: 'application/pdf', size: content.length, storagePath: path,
    tickets: 1, orderId: null, checked: false, uploadedAt: ts(NOW),
  });
}

const get = async (path) => (await db.doc(path).get()).data();
const mails = async () => (await db.collection('mail').get()).docs.map((d) => d.data());

test('the same ticket file listed twice is blocked, reported and never delivered', async () => {
  await listing('L1');
  await listing('L2', { sellerId: 'other' });
  await upload('L1', 'f1', '%PDF ticket A');
  await upload('L2', 'g1', '%PDF ticket A');
  assert.equal(await moderation.checkTicketFile(db, bucket, 'L1', 'f1', NOW), 'ok');
  assert.equal(await moderation.checkTicketFile(db, bucket, 'L2', 'g1', NOW), 'duplicate');
  assert.equal((await get('listings/L1/files/f1')).checked, true);
  assert.equal((await get('listings/L2/files/g1')).blocked, true);
  const report = await get('reports/dup_L2_g1');
  assert.equal(report.type, 'duplicateTicket');
  assert.equal(report.otherListingId, 'L1');
  // A paid order on the copy gets nothing.
  await db.doc('orders/o2').set(order({ listingId: 'L2', quantity: 1, sellerId: 'other' }));
  assert.equal(await core.deliverTickets(db, bucket, 'L2', NOW), 0);
  // Checking the same file again is fine (retries).
  assert.equal(await moderation.checkTicketFile(db, bucket, 'L1', 'f1', NOW), 'ok');
});

test('unchecked uploads wait; removed files can be uploaded again', async () => {
  await listing('L1');
  await upload('L1', 'f1', '%PDF ticket B');
  await db.doc('orders/o1').set(order({ quantity: 1 }));
  assert.equal(await core.deliverTickets(db, bucket, 'L1', NOW), 0);
  await moderation.checkTicketFile(db, bucket, 'L1', 'f1', NOW);
  assert.equal(await core.deliverTickets(db, bucket, 'L1', NOW), 1);

  await upload('L1', 'f2', '%PDF ticket C');
  await moderation.checkTicketFile(db, bucket, 'L1', 'f2', NOW);
  const { sha256 } = await get('listings/L1/files/f2');
  await moderation.forgetTicketFile(db, 'L1', 'f2', sha256);
  await upload('L1', 'f3', '%PDF ticket C');
  assert.equal(await moderation.checkTicketFile(db, bucket, 'L1', 'f3', NOW), 'ok');
});

test('a paid order sends emails and issues numbered fee invoices; a refund credits them', async () => {
  await db.doc('config/company').set({ name: 'Stubswap d.o.o.', vatPercent: 17, invoicePrefix: 'STB' });
  const before = order({ status: 'pendingPayment' });
  const after = order();
  await db.doc('orders/o1').set(after);
  await moderation.orderChanged(db, 'o1', before, after, { appUrl: APP, now: NOW });
  // Retried trigger: nothing twice.
  await moderation.orderChanged(db, 'o1', before, after, { appUrl: APP, now: NOW });

  const sent = await mails();
  assert.deepEqual(sent.map((m) => m.kind).sort(), ['orderPaid', 'ticketSold']);
  const toBuyer = sent.find((m) => m.kind === 'orderPaid');
  assert.equal(toBuyer.to, 'buyer@test.ba');
  assert.match(toBuyer.message.subject, /Kauf bestätigt/);
  assert.match(toBuyer.message.html, /https:\/\/example\.test\/flat\/#\/order\/o1/);

  const year = new Date(NOW).getUTCFullYear();
  const buyerInv = await get('invoices/o1-buyer');
  const sellerInv = await get('invoices/o1-seller');
  assert.equal(buyerInv.number, `STB-${year}-00001`);
  assert.equal(sellerInv.number, `STB-${year}-00002`);
  // 10 % and 15 % of 100,00, VAT included.
  assert.equal(buyerInv.grossMinor, 1000);
  assert.equal(sellerInv.grossMinor, 1500);
  assert.equal(buyerInv.netMinor + buyerInv.vatMinor, 1000);
  assert.equal(buyerInv.company.name, 'Stubswap d.o.o.');
  assert.equal(buyerInv.recipientUid, 'buyer');

  const refunded = order({ status: 'refunded', cancelledBy: 'seller' });
  await moderation.orderChanged(db, 'o1', after, refunded, { appUrl: APP, now: NOW });
  const credit = await get('invoices/o1-buyer-credit');
  assert.equal(credit.type, 'creditNote');
  assert.equal(credit.grossMinor, -1000);
  assert.equal(credit.creditFor, buyerInv.number);
  assert.ok((await mails()).some((m) => m.kind === 'orderRefunded'));
});

test('emails follow the notification settings', async () => {
  await db.doc('users/buyer').set({ email: 'buyer@test.ba', notifications: { email: false } });
  await db.doc('users/seller').set({ email: 'seller@test.ba', notifications: { email: true, saleUpdates: false } });
  await moderation.orderChanged(db, 'o1', order({ status: 'pendingPayment' }), order(), { appUrl: APP, now: NOW });
  assert.equal((await mails()).length, 0);
});

test('postponed events, completed sales and upload reminders email the right person', async () => {
  const paid = order();
  const moved = order({ event: { ...EVENT, date: ts(NOW + 20 * DAY) } });
  await moderation.orderChanged(db, 'o1', paid, moved, { appUrl: APP, now: NOW });
  assert.equal((await mails())[0].kind, 'eventPostponed');

  await db.doc('payouts/o2').set({ amountMinor: 8500 });
  await db.doc('orders/o2').set(order({ status: 'completed' }));
  await moderation.orderChanged(db, 'o2', order({ status: 'ticketsSent' }), order({ status: 'completed' }), { appUrl: APP, now: NOW });
  const payout = (await mails()).find((m) => m.kind === 'payoutReleased');
  assert.equal(payout.to, 'seller@test.ba');
  assert.match(payout.message.text, /85,00 KM/);
  assert.equal((await get('sellerStats/seller')).completedSales, 1);

  await db.doc('orders/o3').set(order({ event: { ...EVENT, date: ts(NOW + DAY) } }));
  assert.equal(await moderation.remindUploads(db, { appUrl: APP, now: NOW }), 1);
  assert.equal(await moderation.remindUploads(db, { appUrl: APP, now: NOW }), 0);
});

test('active listings are counted per seller', async () => {
  await listing('L1');
  await listing('L2');
  await listing('L3', { status: 'withdrawn' });
  await moderation.countActiveListings(db, 'seller', NOW);
  assert.equal((await get('sellerStats/seller')).activeListings, 2);
});

test('the team blocks users (listings go off sale), removes listings and refunds orders', async () => {
  await listing('L1');
  await listing('L2');
  await assert.rejects(moderation.setUserBan(db, 'buyer', { uid: 'seller', banned: true }), { code: 'permission-denied' });
  await assert.rejects(moderation.setUserBan(db, 'helper', { uid: 'boss', banned: true }), { code: 'failed-precondition' });
  assert.deepEqual(await moderation.setUserBan(db, 'helper', { uid: 'seller', banned: true, reason: 'Fake' }, NOW), { listingsRemoved: 2 });
  assert.equal((await get('bans/seller')).reason, 'Fake');
  assert.equal((await get('listings/L1')).status, 'removed');
  await moderation.setUserBan(db, 'boss', { uid: 'seller', banned: false }, NOW);
  assert.equal(await get('bans/seller'), undefined);

  await listing('L3');
  await moderation.removeListing(db, 'helper', { listingId: 'L3', reason: 'Wucher' }, { appUrl: APP, now: NOW });
  assert.equal((await get('listings/L3')).status, 'removed');
  assert.equal((await mails())[0].kind, 'listingRemoved');

  await db.doc('orders/o1').set(order());
  await db.doc('payouts/o1').set({ sellerId: 'seller', amountMinor: 8500, status: 'pending' });
  await moderation.refundOrder(db, 'helper', { orderId: 'o1', reason: 'Fake QR' }, NOW);
  assert.equal((await get('orders/o1')).status, 'refunded');
  assert.equal(await get('payouts/o1'), undefined);
  await assert.rejects(moderation.refundOrder(db, 'helper', { orderId: 'o1' }, NOW), { code: 'failed-precondition' });

  await moderation.setSellerTrusted(db, 'helper', { uid: 'seller', trusted: true }, NOW);
  assert.equal((await get('sellerStats/seller')).trusted, true);
  const log = (await db.collection('moderationLog').get()).docs.map((d) => d.get('action')).sort();
  assert.deepEqual(log, ['ban', 'refund', 'removeListing', 'trust', 'unban']);
});

test('emails in three languages, amounts and VAT split', () => {
  const o = order();
  for (const lang of ['bs', 'de', 'en', 'xx']) {
    const m = render('orderPaid', o, lang, 'https://x/#/order/1');
    assert.ok(m.subject.includes('Jazz'));
    assert.ok(m.html.includes('https://x/#/order/1'));
  }
  assert.equal(money(4500), '45,00 KM');
  assert.deepEqual(splitVat(1170, 17), { netMinor: 1000, vatMinor: 170, grossMinor: 1170 });
});

test('queued emails are sent once over SMTP; failures are recorded and retried', async () => {
  await db.doc('mail/m1').set({ to: 'a@test.ba', message: { subject: 'Hi', text: 'Hallo', html: '<p>Hallo</p>' } });
  const sent = [];
  const transport = { sendMail: async (m) => { sent.push(m); return { messageId: 'x1' }; } };
  const from = 'Stubswap <no-reply@test.ba>';
  assert.equal(await mailer.sendQueuedMail(db, 'm1', { transport, from }), 'sent');
  assert.equal(await mailer.sendQueuedMail(db, 'm1', { transport, from }), 'skipped');
  assert.equal(sent.length, 1);
  assert.equal(sent[0].from, from);
  assert.equal(sent[0].to, 'a@test.ba');
  assert.equal((await get('mail/m1')).delivery.state, 'SUCCESS');

  // No SMTP account yet: stays unsent.
  await db.doc('mail/m2').set({ to: 'b@test.ba', message: { subject: 'S', text: 't', html: 'h' } });
  assert.equal(await mailer.sendQueuedMail(db, 'm2', { transport: null, from }), 'skipped');
  assert.equal((await get('mail/m2')).delivery.state, 'SKIPPED');

  // SMTP fails: recorded, then the schedule tries again.
  await db.doc('mail/m3').set({ to: 'c@test.ba', message: { subject: 'S', text: 't', html: 'h' } });
  const broken = { sendMail: async () => { throw new Error('535 auth failed'); } };
  await assert.rejects(mailer.sendQueuedMail(db, 'm3', { transport: broken, from }));
  assert.equal((await get('mail/m3')).delivery.state, 'ERROR');
  assert.match((await get('mail/m3')).delivery.error, /535/);
  assert.equal(await mailer.retryFailedMail(db, (id) => mailer.sendQueuedMail(db, id, { transport, from })), 1);
  assert.equal((await get('mail/m3')).delivery.state, 'SUCCESS');
  assert.equal((await get('mail/m3')).delivery.attempts, 2);
});

test('the sale email says nothing is left to do when the tickets are already uploaded', async () => {
  await listing('L1');
  await upload('L1', 'f1', '%PDF ready 1');
  await upload('L1', 'f2', '%PDF ready 2');
  await moderation.orderChanged(db, 'o1', order({ status: 'pendingPayment' }), order(), { appUrl: APP, now: NOW });
  const sold = (await mails()).find((m) => m.kind === 'ticketSold');
  assert.match(sold.message.text, /schon hochgeladen/);
  // Not enough files: the reminder to upload.
  await db.doc('listings/L2').set({ sellerId: 'seller', status: 'active' });
  await moderation.orderChanged(db, 'o2', order({ status: 'pendingPayment', listingId: 'L2' }), order({ listingId: 'L2' }), { appUrl: APP, now: NOW });
  const later = (await db.doc('mail/o2-ticketSold').get()).data();
  assert.match(later.message.text, /spätestens 24 Stunden/);
});
