// Transactional emails. The functions put them into the "mail" collection in
// the format of the Firebase extension "Trigger Email from Firestore", which
// sends them over the SMTP account set up with the extension. Without the
// extension they just wait there.
import { Timestamp } from 'firebase-admin/firestore';

const BRAND = '#5B2EFF';

/** Amount in minor units as "45,00 KM". */
export function money(minor, currency = 'BAM') {
  const value = (minor / 100).toFixed(2).replace('.', ',');
  const symbol = { BAM: 'KM', EUR: '€', USD: '$' }[currency] ?? currency;
  return `${value} ${symbol}`;
}

function date(ts, lang) {
  const d = ts instanceof Timestamp ? ts.toDate() : new Date(ts);
  const locale = { bs: 'bs-BA', de: 'de-DE', en: 'en-GB' }[lang] ?? 'bs-BA';
  return d.toLocaleString(locale, {
    day: 'numeric', month: 'long', year: 'numeric', hour: '2-digit', minute: '2-digit',
    timeZone: 'Europe/Sarajevo',
  });
}

// One text per kind and language: subject, lines, button.
const TEXTS = {
  orderPaid: {
    bs: (o) => [`Kupovina potvrđena: ${o.event.name}`, [`Hvala na kupovini! Tvoja narudžba ${o.number} je plaćena.`, `${o.quantity} × ${o.event.name}, ${date(o.event.date, 'bs')}, ${o.event.venue} · ${o.event.city}.`, 'Karte dobijaš čim ih prodavac učita. Javićemo ti se e-mailom.'], 'Otvori narudžbu'],
    de: (o) => [`Kauf bestätigt: ${o.event.name}`, [`Danke für deinen Kauf! Deine Bestellung ${o.number} ist bezahlt.`, `${o.quantity} × ${o.event.name}, ${date(o.event.date, 'de')}, ${o.event.venue} · ${o.event.city}.`, 'Du bekommst die Tickets, sobald der Verkäufer sie hochlädt. Wir melden uns per E-Mail.'], 'Bestellung öffnen'],
    en: (o) => [`Purchase confirmed: ${o.event.name}`, [`Thanks for your purchase! Your order ${o.number} is paid.`, `${o.quantity} × ${o.event.name}, ${date(o.event.date, 'en')}, ${o.event.venue} · ${o.event.city}.`, 'You get the tickets as soon as the seller uploads them. We will email you.'], 'Open order'],
  },
  ticketSold: {
    bs: (o) => [`Prodano: ${o.event.name}`, [`Prodao si ${o.quantity} kart(e) za ${o.event.name} (narudžba ${o.number}).`, o.ticketType === 'eTicket' ? 'Učitaj karte što prije, najkasnije 24 sata prije događaja; inače kupac dobija povrat novca.' : 'Predaj karte kupcu i označi ih kao poslane.'], 'Otvori prodaju'],
    de: (o) => [`Verkauft: ${o.event.name}`, [`Du hast ${o.quantity} Ticket(s) für ${o.event.name} verkauft (Bestellung ${o.number}).`, o.ticketType === 'eTicket' ? 'Lade die Tickets bald hoch, spätestens 24 Stunden vor dem Event; sonst wird der Käufer erstattet.' : 'Übergib die Tickets dem Käufer und markiere sie als gesendet.'], 'Verkauf öffnen'],
    en: (o) => [`Sold: ${o.event.name}`, [`You sold ${o.quantity} ticket(s) for ${o.event.name} (order ${o.number}).`, o.ticketType === 'eTicket' ? 'Upload the tickets soon, at the latest 24 hours before the event; otherwise the buyer is refunded.' : 'Hand the tickets to the buyer and mark them as sent.'], 'Open sale'],
  },
  ticketsReady: {
    bs: (o) => [`Tvoje karte su spremne: ${o.event.name}`, [`Karte za narudžbu ${o.number} su stigle. Preuzmi ih u aplikaciji.`], 'Preuzmi karte'],
    de: (o) => [`Deine Tickets sind da: ${o.event.name}`, [`Die Tickets für Bestellung ${o.number} sind da. Lade sie in der App herunter.`], 'Tickets herunterladen'],
    en: (o) => [`Your tickets are ready: ${o.event.name}`, [`The tickets for order ${o.number} have arrived. Download them in the app.`], 'Download tickets'],
  },
  orderRefunded: {
    bs: (o) => [`Povrat novca: ${o.event.name}`, [`Narudžba ${o.number} je otkazana${o.cancelledBy === 'event' ? ' jer je događaj otkazan' : ''}. Novac ti vraćamo u punom iznosu.`], 'Otvori narudžbu'],
    de: (o) => [`Erstattung: ${o.event.name}`, [`Die Bestellung ${o.number} wurde storniert${o.cancelledBy === 'event' ? ', weil das Event abgesagt wurde' : ''}. Du bekommst den vollen Betrag zurück.`], 'Bestellung öffnen'],
    en: (o) => [`Refund: ${o.event.name}`, [`Order ${o.number} was cancelled${o.cancelledBy === 'event' ? ' because the event was cancelled' : ''}. You get the full amount back.`], 'Open order'],
  },
  saleCancelled: {
    bs: (o) => [`Prodaja otkazana: ${o.event.name}`, [`Prodaja ${o.number} je otkazana i kupcu je vraćen novac. Za ovu prodaju nema isplate.`], 'Otvori prodaju'],
    de: (o) => [`Verkauf storniert: ${o.event.name}`, [`Der Verkauf ${o.number} wurde storniert und der Käufer erstattet. Für diesen Verkauf gibt es keine Auszahlung.`], 'Verkauf öffnen'],
    en: (o) => [`Sale cancelled: ${o.event.name}`, [`Sale ${o.number} was cancelled and the buyer refunded. There is no payout for this sale.`], 'Open sale'],
  },
  disputeOpened: {
    bs: (o) => [`Kupac je prijavio problem: ${o.event.name}`, [`Kupac je prijavio problem s narudžbom ${o.number}. Isplata čeka dok podrška ne odluči. Odgovori podršci ako te kontaktira.`], 'Otvori prodaju'],
    de: (o) => [`Käufer meldet ein Problem: ${o.event.name}`, [`Der Käufer hat ein Problem mit Bestellung ${o.number} gemeldet. Die Auszahlung wartet, bis der Support entscheidet.`], 'Verkauf öffnen'],
    en: (o) => [`Buyer reported a problem: ${o.event.name}`, [`The buyer reported a problem with order ${o.number}. The payout waits until support decides.`], 'Open sale'],
  },
  payoutReleased: {
    bs: (o) => [`Isplata pokrenuta: ${o.number}`, [`Prodaja ${o.number} je završena. Isplata od ${money(o.earnings, o.currency)} je zakazana na tvoj račun.`], 'Isplate'],
    de: (o) => [`Auszahlung gestartet: ${o.number}`, [`Der Verkauf ${o.number} ist abgeschlossen. Die Auszahlung von ${money(o.earnings, o.currency)} ist geplant.`], 'Auszahlungen'],
    en: (o) => [`Payout started: ${o.number}`, [`Sale ${o.number} is complete. A payout of ${money(o.earnings, o.currency)} is scheduled.`], 'Payouts'],
  },
  eventPostponed: {
    bs: (o) => [`Događaj pomjeren: ${o.event.name}`, [`${o.event.name} je pomjeren na ${date(o.event.date, 'bs')}. Tvoje karte ostaju važeće.`], 'Otvori narudžbu'],
    de: (o) => [`Event verschoben: ${o.event.name}`, [`${o.event.name} wurde auf ${date(o.event.date, 'de')} verschoben. Deine Tickets bleiben gültig.`], 'Bestellung öffnen'],
    en: (o) => [`Event postponed: ${o.event.name}`, [`${o.event.name} was moved to ${date(o.event.date, 'en')}. Your tickets stay valid.`], 'Open order'],
  },
  uploadReminder: {
    bs: (o) => [`Podsjetnik: učitaj karte za ${o.event.name}`, [`Kupac još čeka karte za narudžbu ${o.number}. Učitaj ih najkasnije 24 sata prije događaja, inače se kupcu vraća novac.`], 'Učitaj karte'],
    de: (o) => [`Erinnerung: Tickets für ${o.event.name} hochladen`, [`Der Käufer wartet noch auf die Tickets für Bestellung ${o.number}. Lade sie spätestens 24 Stunden vor dem Event hoch, sonst wird erstattet.`], 'Tickets hochladen'],
    en: (o) => [`Reminder: upload the tickets for ${o.event.name}`, [`The buyer is still waiting for the tickets of order ${o.number}. Upload them at the latest 24 hours before the event, or the buyer is refunded.`], 'Upload tickets'],
  },
  supportAnswer: {
    bs: (t) => [`Odgovor podrške: ${t.subject}`, [`Tim Stubswap je odgovorio na tvoj upit ${t.number}.`], 'Pročitaj odgovor'],
    de: (t) => [`Antwort vom Support: ${t.subject}`, [`Das Stubswap-Team hat auf deine Anfrage ${t.number} geantwortet.`], 'Antwort lesen'],
    en: (t) => [`Support answer: ${t.subject}`, [`The Stubswap team answered your request ${t.number}.`], 'Read the answer'],
  },
  listingRemoved: {
    bs: (l) => [`Ponuda uklonjena: ${l.event.name}`, ['Tim Stubswap je uklonio tvoju ponudu jer krši pravila platforme.', l.reason ? `Razlog: ${l.reason}` : ''], 'Moje ponude'],
    de: (l) => [`Angebot entfernt: ${l.event.name}`, ['Das Stubswap-Team hat dein Angebot entfernt, weil es gegen die Regeln verstößt.', l.reason ? `Grund: ${l.reason}` : ''], 'Meine Angebote'],
    en: (l) => [`Listing removed: ${l.event.name}`, ['The Stubswap team removed your listing because it breaks the platform rules.', l.reason ? `Reason: ${l.reason}` : ''], 'My listings'],
  },
};

const FOOTER = {
  bs: 'Ovaj e-mail šaljemo jer imaš račun na Stubswap. E-mailove možeš isključiti u Postavke → Obavještenja.',
  de: 'Du bekommst diese E-Mail, weil du ein Stubswap-Konto hast. E-Mails kannst du unter Einstellungen → Benachrichtigungen abschalten.',
  en: 'You get this email because you have a Stubswap account. Turn emails off in Settings → Notifications.',
};

/** Which notification setting a kind of email belongs to. */
const CATEGORY = {
  orderPaid: 'orderUpdates', ticketsReady: 'orderUpdates', orderRefunded: 'orderUpdates',
  eventPostponed: 'orderUpdates',
  ticketSold: 'saleUpdates', saleCancelled: 'saleUpdates', disputeOpened: 'saleUpdates',
  uploadReminder: 'saleUpdates', listingRemoved: 'saleUpdates',
  payoutReleased: 'payoutUpdates',
  supportAnswer: null,
};

const escape = (s) => String(s).replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' })[c]);

/** Subject, text and HTML of one email. */
export function render(kind, data, lang, link) {
  const l = ['bs', 'de', 'en'].includes(lang) ? lang : 'bs';
  const [subject, lines, button] = TEXTS[kind][l](data);
  const body = lines.filter(Boolean);
  const text = [...body, '', `${button}: ${link}`, '', FOOTER[l]].join('\n');
  const html = `<!doctype html><html><body style="margin:0;background:#f4f4f5;font-family:Arial,Helvetica,sans-serif;color:#18181b">
<table width="100%" cellpadding="0" cellspacing="0"><tr><td align="center" style="padding:24px 12px">
<table width="100%" cellpadding="0" cellspacing="0" style="max-width:560px;background:#ffffff;border-radius:12px;border:1px solid #e4e4e7">
<tr><td style="padding:24px 24px 8px;font-size:20px;font-weight:bold">Stub<span style="color:${BRAND}">swap</span></td></tr>
<tr><td style="padding:8px 24px;font-size:18px;font-weight:bold">${escape(subject)}</td></tr>
${body.map((p) => `<tr><td style="padding:6px 24px;font-size:15px;line-height:1.5">${escape(p)}</td></tr>`).join('\n')}
<tr><td style="padding:16px 24px 24px"><a href="${escape(link)}" style="display:inline-block;background:${BRAND};color:#ffffff;text-decoration:none;padding:12px 20px;border-radius:8px;font-weight:bold">${escape(button)}</a></td></tr>
</table>
<p style="max-width:560px;font-size:12px;color:#71717a;line-height:1.5">${escape(FOOTER[l])}</p>
</td></tr></table></body></html>`;
  return { subject, text, html };
}

/**
 * Queues an email of [kind] to user [uid] if their settings allow it.
 * [path] is the app page the button opens (e.g. "/order/abc").
 * Returns the mail document id, or null when nothing was sent.
 */
export async function queueMail(db, { uid, kind, data, path, appUrl, now = Date.now(), id }) {
  if (!uid) return null;
  const user = await db.doc(`users/${uid}`).get();
  const email = user.get('email');
  if (!user.exists || !email) return null;
  const prefs = user.get('notifications') ?? {};
  if (prefs.email === false) return null;
  const category = CATEGORY[kind];
  if (category && prefs[category] === false) return null;
  const link = `${appUrl.replace(/\/$/, '')}/#${path}`;
  const message = render(kind, data, user.get('language'), link);
  const ref = id ? db.collection('mail').doc(id) : db.collection('mail').doc();
  // A fixed id makes retries of the same trigger send only once.
  try {
    await ref.create({ to: email, message, kind, uid, createdAt: Timestamp.fromMillis(now) });
  } catch (e) {
    if (e.code === 6 || /already exists/i.test(String(e.message))) return null;
    throw e;
  }
  return ref.id;
}
