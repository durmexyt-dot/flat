# Backend: Cloud Functions, Storage, rules

Stubswap runs on Firebase (Blaze plan). The app writes most data itself,
guarded by `firestore.rules`; what must happen even when nobody has the app
open runs as Cloud Functions (`functions/`, 2nd gen, region `europe-west1`).

| Function | Trigger | What it does |
|---|---|---|
| `onOrderPaid` | order becomes `paid` | hands uploaded ticket files to the order |
| `onTicketUploaded` | new `listings/{id}/files/{file}` | hands the file to a waiting paid order |
| `maintenance` | every 5 minutes | unpaid orders expire after 15 min (tickets released); e-tickets not delivered 24 h before the event are refunded; orders complete 3 days after the event (payout scheduled); listings of past events expire |
| `openDispute` | callable (buyer) | report a problem: order on hold, support request opened |
| `resolveDispute` | callable (team) | refund the buyer or continue the order |
| `cancelEvent` | callable (team) | event cancelled: all buyers refunded, listings withdrawn |
| `postponeEvent` | callable (team) | new date for the event and all its listings and orders |
| `onOrderChanged` | any order change | emails (purchase, sale, tickets ready, refund, problem, payout, postponed event), fee invoices when paid, credit notes when refunded, completed sales per seller |
| `onTicketDeleted` | file removed before delivery | the same file may be uploaded again |
| `onListingChanged` | listing status changes | counts the seller's active listings (limits for new sellers) |
| `onSupportMessage` | team answers a support request | email to the user |
| `setUserBan` | callable (team) | block/unblock a user; blocking takes their listings off sale |
| `removeListing` | callable (team) | take a listing off sale; email to the seller |
| `refundOrder` | callable (team) | refund a paid order |
| `setSellerTrusted` | callable (team) | lift (or restore) the limits of a new seller |

`onTicketUploaded` first checks the file's SHA-256: the same file listed a
second time is blocked (never delivered) and reported to the team
(`reports`). `maintenance` also reminds sellers by email when e-tickets are
still missing 48 hours before the event.

### Emails (Trigger Email extension)

The functions put emails into the Firestore collection `mail` in the format
of the Firebase extension **Trigger Email from Firestore**. Until it is
installed, emails just wait there. Once per project:

1. An SMTP account for sending, e.g. Brevo, Mailgun, SendGrid or the domain's
   mail provider (sender like `no-reply@stubswap.ba`; set up SPF/DKIM for the
   domain so mails don't land in spam).
2. Firebase console → Extensions → *Trigger Email from Firestore* → Install:
   - Firestore database: `(default)` on staging, `stubswap-prod` on prod
   - Email documents collection: `mail`
   - SMTP connection URI, e.g. `smtps://USER@smtp-relay.brevo.com:465`
     and the SMTP password (stored as a secret)
   - Default FROM address: `Stubswap <no-reply@stubswap.ba>`
3. Links in emails open the app at `APP_URL` from `functions/.env.<project>`.

Users switch emails off under Settings → Notifications (all emails or per
kind); the app saves their language (bs/de/en) for the emails.

### Invoices

When an order is paid, the platform issues two invoices for its fees
(`invoices/<order>-buyer`, `invoices/<order>-seller`, VAT included at the
rate in `config/company`), numbered per year without gaps
(`PREFIX-2026-00001`, counter in `counters/`). A refund issues credit notes.
Admins enter the company details (name, address, JIB, PDV number, VAT rate,
prefix) under Administration → Company details, and export a month as CSV
under Administration → Platform invoices. Have an accountant confirm the
invoice content for BiH (PDV) before going live.

Ticket files live in Firebase Storage: sellers upload to
`tickets/{sellerUid}/{listingId}/{fileId}`; the function copies a file to
`deliveries/{orderId}/{fileId}` with buyer and seller in its metadata
(`storage.rules`). Which Firestore database a project uses is set in
`functions/.env.<project-id>` (`DATABASE_ID`).

## One-time setup per project (staging `stubswap-eda59`, prod `stubswap-prod`)

1. Blaze plan, with a budget alert (Google Cloud → Billing → Budgets).
2. **Storage**: Firebase console → Storage → Get started (location
   `eur3`/Europe, production mode).
3. Install the Firebase CLI once on your computer:
   `npm install -g firebase-tools`, then `firebase login`.

## Deploying

From the repository folder (after `git pull`):

```sh
cd functions && npm install && cd ..
firebase deploy --only functions,storage -P staging
# later, for prod (after testing on staging):
firebase deploy --only functions,storage -P prod
```

Firestore rules: publish `firestore.rules` in the console (Firestore →
Rules) for each project, as before. (With the CLI:
`firebase deploy --only firestore:rules -P staging`; for prod the named
database `stubswap-prod` needs the rules pasted in the console.)

The first deploy asks to enable some Google Cloud APIs (Cloud Functions,
Cloud Build, Artifact Registry, Cloud Scheduler, Eventarc) — answer yes.

## Tests

```sh
# rules (Firestore emulator, needs Java)
cd firestore_test && npm install && npm test
# functions (Firestore + Storage emulators)
cd functions && npm install && cd ..
firebase emulators:exec --only firestore,storage "node --test functions/test/*.test.js"
```
