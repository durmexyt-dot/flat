// The platform's invoices for its service fee: one to the buyer (buyer fee)
// and one to the seller (seller fee) when an order is paid, and credit notes
// when it is refunded. Numbers run per year without gaps (PREFIX-2026-00001).
import { Timestamp } from 'firebase-admin/firestore';

const percentOf = (amount, percent) => Math.round((amount * percent) / 100);

/** Company details on the invoices until an admin enters them. */
export const DEFAULT_COMPANY = {
  name: 'Stubswap',
  address: '',
  taxId: '',
  vatNumber: '',
  vatPercent: 17,
  email: '',
  invoicePrefix: 'SSW',
};

/** Splits a gross amount into net and VAT ([vatPercent] included). */
export function splitVat(grossMinor, vatPercent) {
  const net = Math.round((grossMinor * 100) / (100 + vatPercent));
  return { netMinor: net, vatMinor: grossMinor - net, grossMinor };
}

/** The fees of an order: what the buyer and the seller pay the platform. */
export function orderFees(o) {
  const subtotal = o.unitPriceMinor * o.quantity;
  return {
    buyer: percentOf(subtotal, o.buyerFeePercent ?? 10),
    seller: percentOf(subtotal, o.sellerFeePercent ?? 10),
  };
}

async function nextNumber(tx, db, prefix, year) {
  const ref = db.doc(`counters/invoices-${year}`);
  const snap = await tx.get(ref);
  const n = (snap.exists ? snap.get('last') : 0) + 1;
  tx.set(ref, { last: n }, { merge: true });
  return `${prefix}-${year}-${String(n).padStart(5, '0')}`;
}

async function recipient(db, uid) {
  const u = await db.doc(`users/${uid}`).get();
  return { name: u.get('displayName') ?? '', email: u.get('email') ?? '' };
}

/**
 * Issues the fee invoices of a paid order (once; ids "<order>-buyer" and
 * "<order>-seller"). Fees of zero get no invoice.
 */
export async function issueOrderInvoices(db, orderId, now = Date.now()) {
  const order = (await db.doc(`orders/${orderId}`).get()).data();
  if (!order) return [];
  const companyDoc = await db.doc('config/company').get();
  const company = { ...DEFAULT_COMPANY, ...(companyDoc.exists ? companyDoc.data() : {}) };
  delete company.updatedBy;
  delete company.updatedAt;
  const fees = orderFees(order);
  const issued = [];
  for (const role of ['buyer', 'seller']) {
    const gross = fees[role];
    if (gross <= 0) continue;
    const uid = role === 'buyer' ? order.buyerId : order.sellerId;
    const to = await recipient(db, uid);
    const ref = db.doc(`invoices/${orderId}-${role}`);
    const done = await db.runTransaction(async (tx) => {
      if ((await tx.get(ref)).exists) return false;
      const year = new Date(now).getUTCFullYear();
      const number = await nextNumber(tx, db, company.invoicePrefix, year);
      const amounts = splitVat(gross, company.vatPercent);
      tx.set(ref, {
        number,
        type: 'invoice',
        orderId,
        orderNumber: order.number,
        recipientUid: uid,
        recipientRole: role,
        recipientName: to.name,
        recipientEmail: to.email,
        description: role === 'buyer' ? 'buyerFee' : 'sellerFee',
        feePercent: role === 'buyer' ? (order.buyerFeePercent ?? 10) : (order.sellerFeePercent ?? 10),
        baseMinor: order.unitPriceMinor * order.quantity,
        eventName: order.event?.name ?? '',
        ...amounts,
        vatPercent: company.vatPercent,
        currency: order.currency,
        company,
        issuedAt: Timestamp.fromMillis(now),
      });
      return true;
    });
    if (done) issued.push(ref.id);
  }
  return issued;
}

/** Credit notes for the invoices of a refunded order (once each). */
export async function creditOrderInvoices(db, orderId, now = Date.now()) {
  const issued = [];
  for (const role of ['buyer', 'seller']) {
    const original = db.doc(`invoices/${orderId}-${role}`);
    const ref = db.doc(`invoices/${orderId}-${role}-credit`);
    const done = await db.runTransaction(async (tx) => {
      const inv = await tx.get(original);
      if (!inv.exists || (await tx.get(ref)).exists) return false;
      const d = inv.data();
      const year = new Date(now).getUTCFullYear();
      const number = await nextNumber(tx, db, d.company.invoicePrefix, year);
      tx.set(ref, {
        ...d,
        number,
        type: 'creditNote',
        creditFor: d.number,
        netMinor: -d.netMinor,
        vatMinor: -d.vatMinor,
        grossMinor: -d.grossMinor,
        issuedAt: Timestamp.fromMillis(now),
      });
      return true;
    });
    if (done) issued.push(ref.id);
  }
  return issued;
}
