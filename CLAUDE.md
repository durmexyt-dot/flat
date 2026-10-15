# Working on Stubswap

- Answer the owner in German. App languages: Bosnian (default), German, English.
- Commit directly to `main` and push after each task.
- Deploy via the `gh-pages` branch with `tool/release.sh` / `tool/deploy_web.sh`
  (no GitHub Actions).
- **Releases go to STAGING only** (`tool/release.sh patch|minor`, default
  target). Deploy to PROD (`/flat/`) only when the owner explicitly asks, and
  then the exact version tested on staging: `tool/deploy_web.sh prod --ref vX.Y.Z`.
  Exception: **bug fixes** may go to staging and prod together
  (`tool/release.sh patch all`) once checked in the browser.
- Until go-live, "prod" (`/flat/`, `stubswap-prod`) is an integration
  environment without real users: no real payments, company details and
  sender domain come later. Staging stays the dev/test environment.
- Changed `firestore.rules` must be published by the owner in the Firebase
  console (staging `stubswap-eda59`, prod `stubswap-prod` / database
  `stubswap-prod`) before an app that needs them reaches that environment.
- No demo mode; test data lives in staging (`tool/seed_staging_showcase.py`).
  Test passwords are never committed.
- Prod keeps the payment simulator until Stripe is added.
- UI: Forui 0.27.5, mobile first, 70/20/10 colors, no gradients.
  Spacing, sizes, motion, weights, text styles and fixed colors come from
  `lib/src/ui/tokens.dart` (see `docs/DESIGN.md`); no new magic numbers.
- Both environments are `noindex` (meta tag in `web/index.html`). At go-live
  set `PROD_INDEXABLE=true` in `tool/build_web.sh` so prod can be indexed;
  remind the owner of this when go-live comes up.
