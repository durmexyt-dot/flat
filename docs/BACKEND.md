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
firebase emulators:exec --only firestore,storage "node --test functions/test/"
```
