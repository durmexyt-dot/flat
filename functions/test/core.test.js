// Runs against the Firestore and Storage emulators:
//   firebase emulators:exec --only firestore,storage "node --test functions/test/"
import { test, before, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { initializeApp } from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';
import * as core from '../lib/core.js';

const PROJECT = 'stubswap-functions-test';
let db;
let bucket;
const HOUR = 3600 * 1000;
const DAY = 24 * HOUR;
const NOW = Date.now();

before(() => {
  initializeApp({ projectId: PROJECT, storageBucket: `${PROJECT}.appspot.com` });
  db = getFirestore();
  bucket = getStorage().bucket();
});

beforeEach(async () => {
  await fetch(`http://${process.env.FIRESTORE_EMULATOR_HOST}/emulator/v1/projects/${PROJECT}/databases/(default)/documents`, { method: 'DELETE' });
  await db.doc('roles/boss').set({ role: 'admin' });
  await db.doc('roles/helper').set({ role: 'support' });
});

const ts = (ms) => Timestamp.fromMillis(ms);
const event = (inDays) => ({ name: 'Jazz', venue: 'Dom', city: 'Sarajevo', date: ts(NOW + inDays * DAY), category: 'concerts' });

async function listing(id, { quantity = 4, sold = 0, reserved = 0, inDays = 10, eventId = 'E1' } = {}) {
  await db.doc(`listings/${id}`).set({
    sellerId: 'seller', eventId, event: event(inDays), quantity, quantitySold: sold, quantityReserved: reserved,
    priceMinor: 3500, currency: 'BAM', status: 'active', ticketType: 'eTicket',
  });
}

async function order(id, { listingId = 'L1', status = 'paid', quantity = 2, inDays = 10, createdAt = NOW - HOUR, reserved = true, delivered = 0 } = {}) {
  await db.doc(`orders/${id}`).set({
    number: `SSW-${id.toUpperCase().padEnd(6, 'X').slice(0, 6)}`, listingId, buyerId: 'buyer', sellerId: 'seller',
    event: event(inDays), quantity, status, reserved, ticketsDelivered: delivered, ticketType: 'eTicket',
    unitPriceMinor: 3500, currency: 'BAM', createdAt: ts(createdAt), history: [],
  });
  if (['paid', 'ticketsSent', 'disputed'].includes(status)) {
    await db.doc(`payouts/${id}`).set({ sellerId: 'seller', amountMinor: 6300, status: 'pending', history: [] });
  }
}

async function upload(listingId, fileId, { tickets = 1, at = NOW } = {}) {
  const path = `tickets/seller/${listingId}/${fileId}`;
  await bucket.file(path).save(Buffer.from(`%PDF ticket ${fileId}`), {
    contentType: 'application/pdf',
    metadata: { metadata: { firebaseStorageDownloadTokens: `seller-${fileId}` } },
  });
  await db.doc(`listings/${listingId}/files/${fileId}`).set({
    name: `${fileId}.pdf`, contentType: 'application/pdf', size: 20, storagePath: path, tickets, orderId: null, uploadedAt: ts(at),
  });
}

const get = async (path) => (await db.doc(path).get()).data();

test('uploaded tickets go to the oldest paid order; it is then sent', async () => {
  await listing('L1', { sold: 3 });
  await order('o1', { quantity: 2, createdAt: NOW - 2 * HOUR });
  await order('o2', { quantity: 1, createdAt: NOW - HOUR });
  await upload('L1', 'f1', { at: NOW - 3 });
  await upload('L1', 'f2', { at: NOW - 2 });
  assert.equal(await core.deliverTickets(db, bucket, 'L1', NOW), 2);
  assert.equal((await get('orders/o1')).status, 'ticketsSent');
  assert.equal((await get('orders/o1')).ticketsDelivered, 2);
  assert.equal((await get('orders/o2')).status, 'paid');
  // The buyer's copy, readable by them through the metadata.
  const [meta] = await bucket.file('deliveries/o1/f1').getMetadata();
  assert.equal(meta.metadata.buyerId, 'buyer');
  assert.equal(meta.metadata.sellerId, 'seller');
  // Its own download link, not the seller's.
  assert.ok(meta.metadata.firebaseStorageDownloadTokens);
  assert.notEqual(meta.metadata.firebaseStorageDownloadTokens, 'seller-f1');
  assert.ok((await get('orders/o1/files/f2')).storagePath.startsWith('deliveries/o1/'));
  assert.equal((await get('listings/L1/files/f1')).orderId, 'o1');
  // A later upload goes to the next order.
  await upload('L1', 'f3');
  await core.deliverTickets(db, bucket, 'L1', NOW);
  assert.equal((await get('orders/o2')).status, 'ticketsSent');
  // Running again hands out nothing twice.
  assert.equal(await core.deliverTickets(db, bucket, 'L1', NOW), 0);
});

test('a file with more tickets than an order needs is kept for a bigger order', async () => {
  await listing('L1', { sold: 1 });
  await order('o1', { quantity: 1 });
  await upload('L1', 'pair', { tickets: 2 });
  await core.deliverTickets(db, bucket, 'L1', NOW);
  assert.equal((await get('orders/o1')).status, 'paid');
  assert.equal((await get('listings/L1/files/pair')).orderId, null);
});

test('reservations expire after 15 minutes and free the tickets', async () => {
  await listing('L1', { reserved: 3 });
  await order('old', { status: 'pendingPayment', quantity: 2, createdAt: NOW - 16 * 60 * 1000 });
  await order('fresh', { status: 'pendingPayment', quantity: 1, createdAt: NOW - 5 * 60 * 1000 });
  assert.equal(await core.expireReservations(db, NOW), 1);
  assert.equal((await get('orders/old')).status, 'cancelled');
  assert.equal((await get('orders/old')).cancelledBy, 'expired');
  assert.equal((await get('orders/fresh')).status, 'pendingPayment');
  assert.equal((await get('listings/L1')).quantityReserved, 1);
});

test('undelivered e-tickets are refunded 24 hours before the event', async () => {
  await listing('L1', { sold: 2, inDays: 0.5 });
  await order('late', { inDays: 0.5 });
  await order('early', { inDays: 3, listingId: 'L1' });
  assert.equal(await core.refundUndelivered(db, NOW), 1);
  assert.equal((await get('orders/late')).status, 'refunded');
  assert.equal((await get('orders/late')).cancelledBy, 'deadline');
  assert.equal(await get('payouts/late'), undefined);
  assert.equal((await get('orders/early')).status, 'paid');
});

test('orders complete three days after the event and release the payout', async () => {
  await order('done', { status: 'ticketsSent', inDays: -4 });
  await order('recent', { status: 'ticketsSent', inDays: -1 });
  await order('reported', { status: 'disputed', inDays: -4 });
  assert.equal(await core.completeOrders(db, NOW), 1);
  assert.equal((await get('orders/done')).status, 'completed');
  assert.equal((await get('payouts/done')).status, 'scheduled');
  assert.equal((await get('orders/recent')).status, 'ticketsSent');
  assert.equal((await get('orders/reported')).status, 'disputed');
});

test('listings of past events expire', async () => {
  await listing('past', { inDays: -1 });
  await listing('future', { inDays: 1 });
  assert.equal(await core.expireListings(db, NOW), 1);
  assert.equal((await get('listings/past')).status, 'expired');
  assert.equal((await get('listings/future')).status, 'active');
});

test('a reported problem holds the order and opens a support request; the team decides', async () => {
  await order('o1', { status: 'ticketsSent', inDays: -1 });
  await db.doc('users/buyer').set({ displayName: 'Kupac', email: 'buyer@test.ba' });
  await assert.rejects(core.openDispute(db, 'other', { orderId: 'o1', reason: 'invalid', text: 'Karta nije važila.' }, NOW), /Not your order/);
  await assert.rejects(core.openDispute(db, 'buyer', { orderId: 'o1', reason: 'x', text: 'Karta nije važila.' }, NOW), /Unknown reason/);
  const { supportTicketId } = await core.openDispute(db, 'buyer', { orderId: 'o1', reason: 'invalid', text: 'Karta nije važila na ulazu.' }, NOW);
  const o = await get('orders/o1');
  assert.equal(o.status, 'disputed');
  assert.equal(o.dispute.previousStatus, 'ticketsSent');
  assert.equal((await get(`supportTickets/${supportTicketId}`)).reference, o.number);
  assert.equal((await get(`supportTickets/${supportTicketId}`)).orderId, 'o1');
  // Not completed while open.
  assert.equal(await core.completeOrders(db, NOW + 10 * DAY), 0);
  // Only the team decides.
  await assert.rejects(core.resolveDispute(db, 'buyer', { orderId: 'o1', decision: 'refund' }, NOW), /Team accounts only/);
  await core.resolveDispute(db, 'helper', { orderId: 'o1', decision: 'refund', note: 'Provjereno.' }, NOW);
  assert.equal((await get('orders/o1')).status, 'refunded');
  assert.equal((await get('orders/o1')).cancelledBy, 'support');
  assert.equal(await get('payouts/o1'), undefined);
});

test('a rejected problem continues the order', async () => {
  await order('o1', { status: 'paid', inDays: 2 });
  await core.openDispute(db, 'buyer', { orderId: 'o1', reason: 'notReceived', text: 'Još nisam dobio karte.' }, NOW);
  await core.resolveDispute(db, 'boss', { orderId: 'o1', decision: 'reject' }, NOW);
  assert.equal((await get('orders/o1')).status, 'paid');
  assert.equal((await get('orders/o1')).dispute.decision, 'reject');
});

test('a cancelled event refunds every buyer and stops all sales', async () => {
  await db.doc('events/E1').set({ ...event(10), status: 'confirmed' });
  await listing('L1', { sold: 3, reserved: 1 });
  await listing('L2', { eventId: 'E2' });
  await order('paid', { quantity: 2 });
  await order('sent', { quantity: 1, status: 'ticketsSent' });
  await order('waiting', { quantity: 1, status: 'pendingPayment' });
  await assert.rejects(core.cancelEvent(db, 'seller', { eventId: 'E1' }, NOW), /Team accounts only/);
  assert.deepEqual(await core.cancelEvent(db, 'boss', { eventId: 'E1', reason: 'Kiša' }, NOW), { refunded: 2 });
  assert.equal((await get('events/E1')).status, 'cancelled');
  assert.equal((await get('orders/paid')).status, 'refunded');
  assert.equal((await get('orders/paid')).cancelledBy, 'event');
  assert.equal((await get('orders/waiting')).status, 'cancelled');
  assert.equal(await get('payouts/sent'), undefined);
  assert.equal((await get('listings/L1')).status, 'withdrawn');
  assert.equal((await get('listings/L2')).status, 'active');
});

test('a postponed event moves all copies of its date', async () => {
  await db.doc('events/E1').set({ ...event(10), status: 'confirmed' });
  await listing('L1', { sold: 2 });
  await order('paid', { quantity: 2 });
  await order('failed', { quantity: 1, status: 'cancelled' });
  const newDate = new Date(NOW + 40 * DAY).toISOString();
  await assert.rejects(core.postponeEvent(db, 'helper', { eventId: 'E1', newDate: new Date(NOW - DAY).toISOString() }, NOW), /future/);
  await core.postponeEvent(db, 'helper', { eventId: 'E1', newDate }, NOW);
  const e = await get('events/E1');
  assert.equal(e.date.toMillis(), Date.parse(newDate));
  assert.ok(e.postponedFrom);
  assert.equal((await get('listings/L1')).event.date.toMillis(), Date.parse(newDate));
  assert.equal((await get('orders/paid')).event.date.toMillis(), Date.parse(newDate));
  assert.equal((await get('orders/failed')).event.date.toMillis(), NOW + 10 * DAY);
  assert.equal((await get('payouts/paid')).expectedAt.toMillis(), Date.parse(newDate) + 5 * DAY);
});
