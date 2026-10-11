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
    await setDoc(doc(ctx.firestore(), 'users/seller/private/payoutMethod'), { accountHolder: 'Seller', iban: IBAN });
    await setDoc(doc(ctx.firestore(), 'events/E1'), eventDoc());
    await setDoc(doc(ctx.firestore(), 'roles/boss'), { role: 'admin' });
    await setDoc(doc(ctx.firestore(), 'roles/helper'), { role: 'support' });
  });
});

// An event a month from now.
const EVENT = {
  name: 'Jazz Fest', venue: 'Dom mladih', city: 'Sarajevo',
  date: Timestamp.fromMillis(Date.now() + 30 * 24 * 3600 * 1000), category: 'concerts',
};
// The admin-created event behind EVENT.
const eventDoc = (over = {}) => ({
  ...EVENT, status: 'active', hasImage: false, imageVersion: 1,
  createdAt: serverTimestamp(), updatedAt: serverTimestamp(), ...over,
});
const listing = (over = {}) => ({
  sellerId: 'seller', eventId: 'E1', event: EVENT, buyerFeePercent: 10, sellerFeePercent: 10, ticketType: 'eTicket',
  quantity: 4, quantitySold: 0, priceMinor: 3500, currency: 'BAM', status: 'active',
  section: '', row: '', seats: '', note: '',
  createdAt: serverTimestamp(), updatedAt: serverTimestamp(), ...over,
});
const order = (over = {}) => ({
  number: 'SSW-TEST01', listingId: 'L1', buyerId: 'buyer', sellerId: 'seller',
  event: EVENT, quantity: 2, unitPriceMinor: 3500, currency: 'BAM', ticketType: 'eTicket',
  section: '', row: '', seats: '',
  status: 'pendingPayment', history: [{ status: 'pendingPayment' }], testMode: true,
  createdAt: Timestamp.now(), ...over,
});
// Signed in with a confirmed email address unless [verified] is false.
const db = (uid, { verified = true } = {}) => (uid
  ? env.authenticatedContext(uid, { email: `${uid}@test.ba`, email_verified: verified })
  : env.unauthenticatedContext()).firestore();
const IBAN = 'BA391290079401028494';

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
  await assertSucceeds(setDoc(doc(db('newbie'), 'users/newbie/private/payoutMethod'), { accountHolder: 'Newbie', iban: IBAN }));
  await assertSucceeds(setDoc(doc(db('newbie'), 'listings/L9'), listing({ sellerId: 'newbie' })));
});

test('profile flows of the app are allowed', async () => {
  const fs = db('amra');
  // ensureProfile
  await assertSucceeds(writeBatch(fs)
    .set(doc(fs, 'users/amra'), { displayName: 'Amra', email: 'amra@test.ba', visibility: 'public', notifications: { email: true }, createdAt: serverTimestamp() })
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
  await assertSucceeds(setDoc(doc(fs, 'users/amra/private/payoutMethod'), { accountHolder: 'Amra B', iban: IBAN, updatedAt: serverTimestamp() }));
  await assertFails(getDoc(doc(db('other'), 'users/amra/private/payoutMethod')));
  // Public profile readable while public.
  await assertSucceeds(getDoc(doc(db('other'), 'publicProfiles/amra')));
});

test('sellers create listings only for themselves and unsold', async () => {
  // (EVENT is the admin-created event E1.)
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
  await assertSucceeds(updateDoc(doc(db('buyer'), 'orders/O1'), { status: 'cancelled', failureReason: 'cardDeclined', history: arrayUnion({ status: 'cancelled' }) }));
  await assertFails(updateDoc(doc(db('buyer'), 'orders/O1'), { status: 'pendingPayment' }));
});

test('only the seller marks tickets sent, after payment', async () => {
  await openOrder();
  await assertFails(updateDoc(doc(db('seller'), 'orders/O1'), { status: 'ticketsSent' }));
  await assertSucceeds(payBatch(db('buyer')).commit());
  await assertFails(updateDoc(doc(db('buyer'), 'orders/O1'), { status: 'ticketsSent' }));
  await assertSucceeds(updateDoc(doc(db('seller'), 'orders/O1'), { status: 'ticketsSent', history: arrayUnion({ status: 'ticketsSent' }) }));
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


// ---- Attacks: everything outside what the app writes is refused ----------

test('listings: no extra fields, sane numbers, future events, verified sellers', async () => {
  const fs = db('seller');
  await assertSucceeds(setDoc(doc(fs, 'listings/ok'), listing()));
  await assertFails(setDoc(doc(fs, 'listings/a1'), listing({ verified: true })));
  await assertFails(setDoc(doc(fs, 'listings/a2'), listing({ quantity: 1000 })));
  await assertFails(setDoc(doc(fs, 'listings/a3'), listing({ priceMinor: 1000001 })));
  await assertFails(setDoc(doc(fs, 'listings/a4'), listing({ priceMinor: 12.5 })));
  await assertFails(setDoc(doc(fs, 'listings/a5'), listing({ currency: 'BTC' })));
  await assertFails(setDoc(doc(fs, 'listings/a6'), listing({ event: { ...EVENT, date: Timestamp.fromMillis(Date.now() - 86400000) } })));
  await assertFails(setDoc(doc(fs, 'listings/a7'), listing({ event: { ...EVENT, name: 'x'.repeat(101) } })));
  await assertFails(setDoc(doc(fs, 'listings/a8'), listing({ event: { ...EVENT, hack: 1 } })));
  await assertFails(setDoc(doc(fs, 'listings/a9'), listing({ note: 'x'.repeat(301) })));
  await assertFails(setDoc(doc(fs, 'listings/a10'), listing({ createdAt: Timestamp.fromMillis(0) })));
  // Unconfirmed email: no selling.
  await assertFails(setDoc(doc(db('seller', { verified: false }), 'listings/a11'), listing()));
  // Price changes stay in range; other fields can't be touched.
  await assertFails(updateDoc(doc(fs, 'listings/ok'), { priceMinor: 99999999 }));
  await assertFails(updateDoc(doc(fs, 'listings/ok'), { quantity: 40 }));
  await assertFails(updateDoc(doc(fs, 'listings/ok'), { sellerId: 'other' }));
  // Strangers can't touch it at all.
  await assertFails(updateDoc(doc(db('other'), 'listings/ok'), { priceMinor: 1 }));
  await assertFails(deleteDoc(doc(fs, 'listings/ok')));
});

test('orders: ticket details come from the listing', async () => {
  await assertFails(setDoc(doc(db('buyer'), 'orders/F1'), order({ event: { ...EVENT, name: 'Fake' } })));
  await assertFails(setDoc(doc(db('buyer'), 'orders/F2'), order({ seats: 'VIP 1' })));
  await assertFails(setDoc(doc(db('buyer'), 'orders/F3'), order({ number: '<script>' })));
  await assertFails(setDoc(doc(db('buyer'), 'orders/F4'), order({ paymentId: 'pi_fake' })));
  await assertFails(setDoc(doc(db('buyer'), 'orders/F5'), order({ history: [{ status: 'paid' }, { status: 'completed' }] })));
  await assertFails(setDoc(doc(db(null), 'orders/F6'), order()));
  // Orders can't be deleted, not even by their own buyer.
  await openOrder();
  await assertFails(deleteDoc(doc(db('buyer'), 'orders/O1')));
  // Nobody else reads them.
  await assertFails(getDoc(doc(db('other'), 'orders/O1')));
});

test('profiles: no extra fields, own email, small photo, reserved username', async () => {
  const fs = db('eve');
  await assertFails(setDoc(doc(fs, 'users/eve'), { displayName: 'Eve', role: 'admin' }));
  await assertFails(setDoc(doc(fs, 'users/eve'), { displayName: 'Eve', email: 'ceo@stubswap.ba' }));
  await assertFails(setDoc(doc(fs, 'users/eve'), { photo: 'x'.repeat(200001) }));
  await assertFails(setDoc(doc(fs, 'users/eve'), { visibility: 'everyone' }));
  await assertSucceeds(setDoc(doc(fs, 'users/eve'), { displayName: 'Eve', email: 'eve@test.ba' }));
  // Claiming a username without reserving it, or someone else's.
  await assertFails(setDoc(doc(fs, 'publicProfiles/eve'), { username: 'stubswap' }));
  await assertFails(setDoc(doc(fs, 'users/eve'), { username: 'stubswap' }, { merge: true }));
  // Hoarding names without using them.
  await assertFails(setDoc(doc(fs, 'usernames/admin'), { uid: 'eve' }));
  await assertFails(setDoc(doc(fs, 'publicProfiles/eve'), { displayName: 'Eve', verified: true }));
  // Writing someone else's profile.
  await assertFails(setDoc(doc(fs, 'users/amra'), { displayName: 'Hacked' }));
  await assertFails(setDoc(doc(fs, 'publicProfiles/amra'), { displayName: 'Hacked' }));
});

test('payout method: only a well-formed IBAN, only the owner', async () => {
  const fs = db('eve');
  await assertFails(setDoc(doc(fs, 'users/eve/private/payoutMethod'), { accountHolder: 'Eve', iban: 'NOT AN IBAN' }));
  await assertFails(setDoc(doc(fs, 'users/eve/private/payoutMethod'), { accountHolder: 'Eve', iban: IBAN, admin: true }));
  await assertFails(setDoc(doc(fs, 'users/eve/private/secrets'), { accountHolder: 'Eve', iban: IBAN }));
  await assertFails(setDoc(doc(fs, 'users/seller/private/payoutMethod'), { accountHolder: 'Eve', iban: IBAN }));
  await assertSucceeds(setDoc(doc(fs, 'users/eve/private/payoutMethod'), { accountHolder: 'Eve', iban: IBAN }));
});

test('old support requests: readable by their author only, no new ones', async () => {
  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), 'supportRequests/s1'), { uid: 'eve', message: 'Help' });
  });
  await assertSucceeds(getDoc(doc(db('eve'), 'supportRequests/s1')));
  await assertFails(getDoc(doc(db('amra'), 'supportRequests/s1')));
  await assertFails(setDoc(doc(db('eve'), 'supportRequests/s2'), { uid: 'eve', message: 'Help' }));
});

// ---- Roles, events, fees ----------------------------------------------------

test('roles: admins only from the console; admins name support accounts', async () => {
  // Nobody makes themselves admin or support.
  await assertFails(setDoc(doc(db('eve'), 'roles/eve'), { role: 'admin' }));
  await assertFails(setDoc(doc(db('eve'), 'roles/eve'), { role: 'support', grantedBy: 'eve', grantedAt: serverTimestamp() }));
  const grant = (over = {}) => ({ role: 'support', name: 'Eve', email: 'eve@test.ba', grantedBy: 'boss', grantedAt: serverTimestamp(), ...over });
  // Support accounts can't name others.
  await assertFails(setDoc(doc(db('helper'), 'roles/eve'), grant({ grantedBy: 'helper' })));
  // The admin can, but not admins and not with made-up fields.
  await assertFails(setDoc(doc(db('boss'), 'roles/eve'), grant({ role: 'admin' })));
  await assertFails(setDoc(doc(db('boss'), 'roles/eve'), grant({ superpower: true })));
  await assertFails(setDoc(doc(db('boss'), 'roles/boss'), grant()));
  await assertSucceeds(setDoc(doc(db('boss'), 'roles/eve'), grant()));
  // Own role is readable; the team list only for admins.
  await assertSucceeds(getDoc(doc(db('eve'), 'roles/eve')));
  await assertFails(getDocs(collection(db('eve'), 'roles')));
  await assertSucceeds(getDocs(collection(db('boss'), 'roles')));
  // Support can be removed; admins can't (not even by an admin).
  await assertFails(deleteDoc(doc(db('eve'), 'roles/eve')));
  await assertSucceeds(deleteDoc(doc(db('boss'), 'roles/eve')));
  await assertFails(deleteDoc(doc(db('boss'), 'roles/boss')));
  // Admins find single users; others don't read profiles.
  await assertSucceeds(setDoc(doc(db('amra'), 'users/amra'), { displayName: 'Amra', email: 'amra@test.ba' }));
  await assertSucceeds(getDocs(query(collection(db('boss'), 'users'), where('email', '==', 'amra@test.ba'))));
  await assertFails(getDocs(query(collection(db('helper'), 'users'), where('email', '==', 'amra@test.ba'))));
});

test('events: only admins create and change them', async () => {
  await assertFails(setDoc(doc(db('seller'), 'events/X1'), eventDoc()));
  await assertFails(setDoc(doc(db('helper'), 'events/X1'), eventDoc()));
  await assertSucceeds(setDoc(doc(db('boss'), 'events/X1'), eventDoc()));
  await assertFails(setDoc(doc(db('boss'), 'events/X2'), eventDoc({ date: Timestamp.fromMillis(Date.now() - 1000) })));
  await assertFails(setDoc(doc(db('boss'), 'events/X3'), eventDoc({ name: 'x' })));
  await assertFails(setDoc(doc(db('boss'), 'events/X4'), eventDoc({ featured: true })));
  await assertSucceeds(updateDoc(doc(db('boss'), 'events/X1'), { status: 'hidden', updatedAt: serverTimestamp() }));
  await assertFails(updateDoc(doc(db('seller'), 'events/E1'), { name: 'Hacked', updatedAt: serverTimestamp() }));
  await assertFails(deleteDoc(doc(db('boss'), 'events/E1')));
  // Everyone sees visible events; hidden ones only admins.
  await assertSucceeds(getDoc(doc(db(null), 'events/E1')));
  await assertFails(getDoc(doc(db(null), 'events/X1')));
  await assertSucceeds(getDoc(doc(db('boss'), 'events/X1')));
  // Pictures: admins only, size-limited.
  await assertSucceeds(setDoc(doc(db('boss'), 'eventImages/E1'), { data: 'x'.repeat(5000), updatedAt: serverTimestamp() }));
  await assertFails(setDoc(doc(db('boss'), 'eventImages/E1'), { data: 'x'.repeat(400001), updatedAt: serverTimestamp() }));
  await assertFails(setDoc(doc(db('seller'), 'eventImages/E1'), { data: 'x'.repeat(5000), updatedAt: serverTimestamp() }));
  await assertSucceeds(getDoc(doc(db(null), 'eventImages/E1')));
});

test('listings: only for a visible event, with its exact data', async () => {
  const fs = db('seller');
  await assertFails(setDoc(doc(fs, 'listings/e1'), listing({ eventId: 'nope' })));
  await assertFails(setDoc(doc(fs, 'listings/e2'), listing({ event: { ...EVENT, venue: 'Elsewhere' } })));
  const { eventId, ...withoutEvent } = listing();
  await assertFails(setDoc(doc(fs, 'listings/e3'), withoutEvent));
  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), 'events/H1'), eventDoc({ status: 'hidden' }));
  });
  await assertFails(setDoc(doc(fs, 'listings/e4'), listing({ eventId: 'H1' })));
});

test('fees: admins set them; new listings and their orders keep them', async () => {
  const fees = (over = {}) => ({ buyerPercent: 12, sellerPercent: 8, updatedBy: 'boss', updatedAt: serverTimestamp(), ...over });
  await assertFails(setDoc(doc(db('seller'), 'config/fees'), fees({ updatedBy: 'seller' })));
  await assertFails(setDoc(doc(db('boss'), 'config/fees'), fees({ buyerPercent: 31 })));
  await assertFails(setDoc(doc(db('boss'), 'config/fees'), fees({ sellerPercent: 7.5 })));
  await assertSucceeds(setDoc(doc(db('boss'), 'config/fees'), fees()));
  await assertSucceeds(getDoc(doc(db(null), 'config/fees')));
  // Listings must take the new fees, not the old or made-up ones.
  const fs = db('seller');
  await assertFails(setDoc(doc(fs, 'listings/f1'), listing()));
  await assertFails(setDoc(doc(fs, 'listings/f2'), listing({ buyerFeePercent: 0, sellerFeePercent: 0 })));
  await assertSucceeds(setDoc(doc(fs, 'listings/f3'), listing({ buyerFeePercent: 12, sellerFeePercent: 8 })));
  // The old listing L1 keeps 10 %: an order for it at 10 % works...
  await openOrder();
  // ...and an order can't pick other fees than its listing.
  await assertFails(setDoc(doc(db('buyer'), 'orders/O9'), order({ buyerFeePercent: 0, sellerFeePercent: 0 })));
  await assertSucceeds(setDoc(doc(db('buyer'), 'orders/O8'), order({ listingId: 'f3', buyerFeePercent: 12, sellerFeePercent: 8 })));
  // The seller's payout uses the order's seller fee: 2 × 35 − 8 % = 64.40.
  const b = db('buyer');
  await assertSucceeds(writeBatch(b)
    .update(doc(b, 'orders/O8'), { status: 'paid', paymentId: 'pi_1', paymentMethod: 'Visa', history: arrayUnion({ status: 'paid' }) })
    .update(doc(b, 'listings/f3'), { quantitySold: 2, status: 'active', lastOrderId: 'O8' })
    .set(doc(b, 'payouts/O8'), { sellerId: 'seller', orderNumbers: ['SSW-TEST01'], amountMinor: 6440, currency: 'BAM', status: 'pending', testMode: true })
    .commit());
});

// ---- Support tickets ----------------------------------------------------------

const ticket = (over = {}) => ({
  number: 'SUP-ABC234', uid: 'eve', email: 'eve@test.ba', name: 'Eve', topic: 'order',
  reference: 'SSW-TEST01', subject: 'Help', status: 'open', unreadForUser: false, unreadForStaff: true,
  appVersion: '1.3.0 (8 · abc1234)', createdAt: serverTimestamp(), lastMessageAt: serverTimestamp(), ...over,
});
const message = (over = {}) => ({
  authorId: 'eve', authorRole: 'user', authorName: 'Eve', text: 'Help please', images: [], createdAt: serverTimestamp(), ...over,
});
async function openTicket(id = 'T1') {
  const fs = db('eve');
  await assertSucceeds(writeBatch(fs)
    .set(doc(fs, `supportTickets/${id}`), ticket())
    .set(doc(fs, `supportTickets/${id}/messages/m1`), message())
    .commit());
}

test('support: users open requests for themselves, with small pictures', async () => {
  await openTicket();
  const fs = db('eve');
  const open = (id, t, m = message()) => writeBatch(fs)
    .set(doc(fs, `supportTickets/${id}`), t).set(doc(fs, `supportTickets/${id}/messages/m1`), m).commit();
  await assertFails(open('T2', ticket({ email: 'victim@test.ba' })));
  await assertFails(open('T3', ticket({ uid: 'amra' })));
  await assertFails(open('T4', ticket({ status: 'answered' })));
  await assertFails(open('T5', ticket({ unreadForStaff: false })));
  await assertFails(open('T6', ticket({ priority: 'urgent' })));
  await assertFails(open('T7', ticket(), message({ text: 'x'.repeat(2001) })));
  await assertFails(open('T8', ticket(), message({ images: ['x'.repeat(300001)] })));
  await assertFails(open('T9', ticket(), message({ images: ['a'.repeat(200), 'b'.repeat(200), 'c'.repeat(200), 'd'.repeat(200)] })));
  await assertFails(open('T10', ticket(), message({ authorRole: 'staff' })));
  await assertSucceeds(open('T11', ticket(), message({ images: ['a'.repeat(200), 'b'.repeat(200)] })));
  // Others can't read them; the team can.
  await assertFails(getDoc(doc(db('amra'), 'supportTickets/T1')));
  await assertFails(getDocs(collection(db('amra'), 'supportTickets/T1/messages')));
  await assertFails(getDocs(collection(db('amra'), 'supportTickets')));
  await assertSucceeds(getDocs(query(collection(fs, 'supportTickets'), where('uid', '==', 'eve'))));
  await assertSucceeds(getDocs(collection(db('helper'), 'supportTickets')));
  await assertSucceeds(getDocs(collection(db('boss'), 'supportTickets/T1/messages')));
});

test('support: the team answers, the user reads, replies and closes', async () => {
  await openTicket();
  const staff = db('helper');
  const answer = writeBatch(staff)
    .set(doc(staff, 'supportTickets/T1/messages/m2'), message({ authorId: 'helper', authorRole: 'staff', authorName: 'Support' }))
    .update(doc(staff, 'supportTickets/T1'), { status: 'answered', unreadForUser: true, unreadForStaff: false, lastMessageAt: serverTimestamp() });
  await assertSucceeds(answer.commit());
  // Strangers can't answer or pose as the team.
  const fake = db('amra');
  await assertFails(setDoc(doc(fake, 'supportTickets/T1/messages/m3'), message({ authorId: 'amra', authorRole: 'staff' })));
  await assertFails(updateDoc(doc(fake, 'supportTickets/T1'), { status: 'closed' }));
  const fs = db('eve');
  await assertFails(setDoc(doc(fs, 'supportTickets/T1/messages/m4'), message({ authorRole: 'staff' })));
  // The user can't fake a team answer state or edit other fields.
  await assertFails(updateDoc(doc(fs, 'supportTickets/T1'), { status: 'answered' }));
  await assertFails(updateDoc(doc(fs, 'supportTickets/T1'), { email: 'x@test.ba' }));
  await assertSucceeds(updateDoc(doc(fs, 'supportTickets/T1'), { unreadForUser: false }));
  // Reply: reopens it for the team.
  await assertSucceeds(writeBatch(fs)
    .set(doc(fs, 'supportTickets/T1/messages/m5'), message())
    .update(doc(fs, 'supportTickets/T1'), { status: 'open', unreadForUser: false, unreadForStaff: true, lastMessageAt: serverTimestamp() })
    .commit());
  // Messages can't be changed or deleted.
  await assertFails(updateDoc(doc(fs, 'supportTickets/T1/messages/m5'), { text: 'edited' }));
  await assertFails(deleteDoc(doc(fs, 'supportTickets/T1/messages/m5')));
  // Close when satisfied; closed stays closed.
  await assertSucceeds(updateDoc(doc(fs, 'supportTickets/T1'), { status: 'closed', closedBy: 'user', unreadForStaff: false, unreadForUser: false }));
  await assertFails(writeBatch(fs)
    .set(doc(fs, 'supportTickets/T1/messages/m6'), message())
    .update(doc(fs, 'supportTickets/T1'), { status: 'open', unreadForUser: false, unreadForStaff: true, lastMessageAt: serverTimestamp() })
    .commit());
  await assertFails(setDoc(doc(staff, 'supportTickets/T1/messages/m7'), message({ authorId: 'helper', authorRole: 'staff' })));
  await assertFails(deleteDoc(doc(fs, 'supportTickets/T1')));
});

test('unknown collections and anonymous writes are refused', async () => {
  await assertFails(setDoc(doc(db('eve'), 'admins/eve'), { admin: true }));
  await assertFails(setDoc(doc(db(null), 'listings/x'), listing()));
  await assertFails(getDocs(collection(db('eve'), 'orders')));
  await assertFails(getDocs(collection(db('eve'), 'payouts')));
  await assertFails(getDocs(collection(db('eve'), 'users')));
});
