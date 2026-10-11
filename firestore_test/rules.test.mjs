import { test, before, after, beforeEach } from 'node:test';
import fs from 'node:fs';
import { initializeTestEnvironment, assertSucceeds, assertFails } from '@firebase/rules-unit-testing';
import { doc, setDoc, getDoc, updateDoc, deleteDoc, writeBatch, runTransaction, collection, query, where, getDocs, Timestamp, arrayUnion, serverTimestamp } from 'firebase/firestore';

let env;
const RULES = fs.readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8');

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'stubswap-rules-test',
    firestore: { rules: RULES, host: '127.0.0.1', port: 8085 },
  });
});
after(async () => env.cleanup());
beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), 'listings/L1'), listing());
    await setDoc(doc(ctx.firestore(), 'users/seller/private/payoutMethod'), { accountHolder: 'S', iban: 'X' });
  });
});

const listing = (over = {}) => ({
  sellerId: 'seller', event: { name: 'Jazz', date: Timestamp.now() },
  quantity: 4, quantitySold: 0, priceMinor: 3500, currency: 'BAM', status: 'active', ...over,
});
const order = (over = {}) => ({
  number: 'SSW-TEST01', listingId: 'L1', buyerId: 'buyer', sellerId: 'seller',
  event: { name: 'Jazz' }, quantity: 2, unitPriceMinor: 3500, currency: 'BAM',
  status: 'pendingPayment', history: [], testMode: true, ...over,
});
const db = (uid) => (uid ? env.authenticatedContext(uid) : env.unauthenticatedContext()).firestore();

// The payment transaction the app runs.
function payBatch(fs, { quantitySold = 2, status = 'active', amount = 6300, orderId = 'O1' } = {}) {
  return writeBatch(fs)
    .update(doc(fs, `orders/${orderId}`), { status: 'paid', paymentId: 'pi_1', paymentMethod: 'Visa', history: arrayUnion({ status: 'paid' }) })
    .update(doc(fs, 'listings/L1'), { quantitySold, status, lastOrderId: orderId })
    .set(doc(fs, `payouts/${orderId}`), { sellerId: 'seller', orderNumbers: ['SSW-TEST01'], amountMinor: amount, currency: 'BAM', status: 'pending', testMode: true });
}

async function openOrder(id = 'O1', over = {}) {
  await assertSucceeds(setDoc(doc(db('buyer'), `orders/${id}`), order(over)));
}

test('anyone can read and query active listings', async () => {
  await assertSucceeds(getDoc(doc(db(null), 'listings/L1')));
  await assertSucceeds(getDocs(query(collection(db(null), 'listings'), where('status', '==', 'active'))));
});

test('sellers need a payout method before listing', async () => {
  await assertFails(setDoc(doc(db('newbie'), 'listings/L9'), listing({ sellerId: 'newbie' })));
  await assertSucceeds(setDoc(doc(db('newbie'), 'users/newbie/private/payoutMethod'), { accountHolder: 'N', iban: 'BA391290079401028494' }));
  await assertSucceeds(setDoc(doc(db('newbie'), 'listings/L9'), listing({ sellerId: 'newbie' })));
});

test('profile flows of the app are allowed', async () => {
  const fs = db('amra');
  // ensureProfile
  await assertSucceeds(writeBatch(fs)
    .set(doc(fs, 'users/amra'), { displayName: 'Amra', email: 'a@b.ba', visibility: 'public', notifications: { email: true }, createdAt: serverTimestamp() })
    .set(doc(fs, 'publicProfiles/amra'), { displayName: 'Amra', visibility: 'public' })
    .commit());
  // updateDisplayName / setPhoto / setVisibility
  await assertSucceeds(writeBatch(fs)
    .set(doc(fs, 'users/amra'), { displayName: 'Amra B', photo: 'abc' }, { merge: true })
    .set(doc(fs, 'publicProfiles/amra'), { displayName: 'Amra B', photo: 'abc' }, { merge: true })
    .commit());
  // setUsername (transaction, like the app)
  const claim = (name) => runTransaction(fs, async (tx) => {
    const user = await tx.get(doc(fs, 'users/amra'));
    const taken = await tx.get(doc(fs, `usernames/${name}`));
    if (taken.exists() && taken.data().uid !== 'amra') throw new Error('taken');
    const previous = user.data()?.username;
    if (previous && previous !== name) tx.delete(doc(fs, `usernames/${previous}`));
    tx.set(doc(fs, `usernames/${name}`), { uid: 'amra' })
      .set(doc(fs, 'users/amra'), { username: name }, { merge: true })
      .set(doc(fs, 'publicProfiles/amra'), { username: name }, { merge: true });
  });
  await assertSucceeds(claim('amra.b'));
  await assertSucceeds(claim('amra_2'));
  await assertFails(claim('Not Valid'));
  // Someone else can't take it.
  await assertFails(setDoc(doc(db('other'), 'usernames/amra_2'), { uid: 'other' }));
  // Notifications and payout method.
  await assertSucceeds(setDoc(doc(fs, 'users/amra'), { notifications: { newsletter: true } }, { merge: true }));
  await assertSucceeds(setDoc(doc(fs, 'users/amra/private/payoutMethod'), { accountHolder: 'A', iban: 'X' }));
  await assertFails(getDoc(doc(db('other'), 'users/amra/private/payoutMethod')));
  // Public profile readable while public.
  await assertSucceeds(getDoc(doc(db('other'), 'publicProfiles/amra')));
});

test('sellers create listings only for themselves and unsold', async () => {
  await assertSucceeds(setDoc(doc(db('seller'), 'listings/L2'), listing()));
  await assertFails(setDoc(doc(db('seller'), 'listings/L3'), listing({ sellerId: 'other' })));
  await assertFails(setDoc(doc(db('seller'), 'listings/L4'), listing({ quantitySold: 1 })));
});

test('order creation must match the listing', async () => {
  await openOrder();
  await assertFails(setDoc(doc(db('buyer'), 'orders/O2'), order({ unitPriceMinor: 100 })));
  await assertFails(setDoc(doc(db('buyer'), 'orders/O3'), order({ quantity: 5 })));
  await assertFails(setDoc(doc(db('buyer'), 'orders/O4'), order({ testMode: false })));
  await assertFails(setDoc(doc(db('buyer'), 'orders/O5'), order({ status: 'paid' })));
  await assertFails(setDoc(doc(db('buyer'), 'orders/O6'), order({ buyerId: 'someone' })));
  await assertFails(setDoc(doc(db('seller'), 'orders/O7'), order({ buyerId: 'seller' })));
});

test('payment: order, listing and payout together succeed', async () => {
  await openOrder();
  await assertSucceeds(payBatch(db('buyer')).commit());
  await assertSucceeds(getDoc(doc(db('seller'), 'payouts/O1')));
  await assertFails(getDoc(doc(db('buyer'), 'payouts/O1')));
});

test('payment: last tickets must mark the listing sold out', async () => {
  await openOrder('O1', { quantity: 4 });
  await assertFails(payBatch(db('buyer'), { quantitySold: 4, status: 'active', amount: 12600 }).commit());
  await assertSucceeds(payBatch(db('buyer'), { quantitySold: 4, status: 'soldOut', amount: 12600 }).commit());
});

test('payment: wrong payout amount or ticket count is rejected', async () => {
  await openOrder();
  await assertFails(payBatch(db('buyer'), { amount: 7000 }).commit());
  await assertFails(payBatch(db('buyer'), { quantitySold: 1 }).commit());
});

test('order cannot be marked paid alone', async () => {
  await openOrder();
  await assertFails(updateDoc(doc(db('buyer'), 'orders/O1'), { status: 'paid' }));
});

test('tickets cannot be counted without a payment in the same batch', async () => {
  await openOrder();
  await assertSucceeds(payBatch(db('buyer')).commit());
  // Replaying the paid order to count tickets again.
  await assertFails(updateDoc(doc(db('buyer'), 'listings/L1'), { quantitySold: 4, status: 'soldOut', lastOrderId: 'O1' }));
});

test('a failed payment cancels the order', async () => {
  await openOrder();
  await assertSucceeds(updateDoc(doc(db('buyer'), 'orders/O1'), { status: 'cancelled', failureReason: 'cardDeclined', history: [] }));
  await assertFails(updateDoc(doc(db('buyer'), 'orders/O1'), { status: 'pendingPayment' }));
});

test('only the seller marks tickets sent, after payment', async () => {
  await openOrder();
  await assertFails(updateDoc(doc(db('seller'), 'orders/O1'), { status: 'ticketsSent' }));
  await assertSucceeds(payBatch(db('buyer')).commit());
  await assertFails(updateDoc(doc(db('buyer'), 'orders/O1'), { status: 'ticketsSent' }));
  await assertSucceeds(updateDoc(doc(db('seller'), 'orders/O1'), { status: 'ticketsSent', history: [] }));
});

test('profiles are private', async () => {
  await assertSucceeds(setDoc(doc(db('buyer'), 'users/buyer'), { displayName: 'B' }));
  await assertFails(getDoc(doc(db('seller'), 'users/buyer')));
});

// The cancel transaction the app runs.
function cancelBatch(fs, { quantitySold = 0, status = 'active', orderId = 'O1', dropPayout = true } = {}) {
  const b = writeBatch(fs)
    .update(doc(fs, `orders/${orderId}`), { status: 'refunded', cancelledBy: 'seller', history: arrayUnion({ status: 'refunded' }) })
    .update(doc(fs, 'listings/L1'), { quantitySold, status, lastOrderId: orderId });
  return dropPayout ? b.delete(doc(fs, `payouts/${orderId}`)) : b;
}

async function paidOrder({ quantitySold = 2, status = 'active' } = {}) {
  await openOrder();
  await assertSucceeds(payBatch(db('buyer'), { quantitySold, status }).commit());
}

test('the seller cancels a paid sale: refund, tickets back, payout gone', async () => {
  await paidOrder();
  await assertSucceeds(cancelBatch(db('seller')).commit());
  await env.withSecurityRulesDisabled(async (ctx) => {
    const l = (await getDoc(doc(ctx.firestore(), 'listings/L1'))).data();
    if (l.quantitySold !== 0) throw new Error('tickets not returned');
    if ((await getDoc(doc(ctx.firestore(), 'payouts/O1'))).exists()) throw new Error('payout kept');
  });
});

test('cancelling a sold-out sale reopens the listing', async () => {
  await openOrder('O1', { quantity: 4 });
  await assertSucceeds(payBatch(db('buyer'), { quantitySold: 4, status: 'soldOut', amount: 12600 }).commit());
  await assertFails(cancelBatch(db('seller'), { quantitySold: 0, status: 'soldOut' }).commit());
  await assertSucceeds(cancelBatch(db('seller'), { quantitySold: 0, status: 'active' }).commit());
});

test('the seller can cancel after sending the tickets too', async () => {
  await paidOrder();
  await assertSucceeds(updateDoc(doc(db('seller'), 'orders/O1'), { status: 'ticketsSent', history: arrayUnion({ status: 'ticketsSent' }) }));
  await assertSucceeds(cancelBatch(db('seller')).commit());
});

test('buyers cannot cancel a paid order', async () => {
  await paidOrder();
  await assertFails(cancelBatch(db('buyer')).commit());
  await assertFails(updateDoc(doc(db('buyer'), 'orders/O1'), { status: 'cancelled' }));
});

test('a cancel must return the tickets and drop the payout', async () => {
  await paidOrder();
  // Payout kept.
  await assertFails(cancelBatch(db('seller'), { dropPayout: false }).commit());
  // Tickets not (or wrongly) returned.
  await assertFails(cancelBatch(db('seller'), { quantitySold: 2 }).commit());
  await assertFails(cancelBatch(db('seller'), { quantitySold: 1 }).commit());
  // Order alone.
  await assertFails(updateDoc(doc(db('seller'), 'orders/O1'), { status: 'refunded', cancelledBy: 'seller' }));
  // Payout alone.
  await assertFails(deleteDoc(doc(db('seller'), 'payouts/O1')));
});
