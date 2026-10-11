#!/usr/bin/env bash
# Builds the web app for one environment, with version, build number and
# commit baked in (single source: pubspec.yaml + git).
#
#   tool/build_web.sh staging|prod <base-href>
#
# Output: build/web. Both environments use the payment simulator until
# Stripe is added.
set -euo pipefail
cd "$(dirname "$0")/.."

env=${1:?usage: tool/build_web.sh staging|prod <base-href>}
base_href=${2:?usage: tool/build_web.sh staging|prod <base-href>}
case "$env" in staging|prod) ;; *) echo "Unknown environment: $env" >&2; exit 1 ;; esac

if [[ "$env" == prod ]] && grep -q 'FirebaseOptions? web = null' lib/firebase_options_prod.dart; then
  echo "Prod Firebase config missing: fill in lib/firebase_options_prod.dart." >&2
  exit 1
fi

full_version=$(sed -n 's/^version: *//p' pubspec.yaml)   # e.g. 1.1.0+7
version=${full_version%%+*}
build=${full_version##*+}
commit=$(git rev-parse --short HEAD)

flutter build web --release --base-href "$base_href" \
  --dart-define=APP_ENV="$env" \
  --dart-define=APP_VERSION="$version" \
  --dart-define=APP_BUILD="$build" \
  --dart-define=APP_COMMIT="$commit"

echo "Built $env $version ($build · $commit) for $base_href"
