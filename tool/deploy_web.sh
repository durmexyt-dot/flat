#!/usr/bin/env bash
# Builds and publishes the web app to the gh-pages branch:
#
#   prod     → https://<owner>.github.io/<repo>/
#   staging  → https://<owner>.github.io/<repo>/staging/
#
#   tool/deploy_web.sh staging|prod [--ref <tag-or-commit>] [--to root|staging]
#
# --ref deploys an older version again (rollback), e.g. --ref v1.0.3.
# --to overrides where it goes (e.g. staging at the root while there is no
# prod project yet).
set -euo pipefail
cd "$(dirname "$0")/.."

env=${1:?usage: tool/deploy_web.sh staging|prod [--ref <ref>] [--to root|staging]}
shift
ref=""
target=$([[ "$env" == prod ]] && echo root || echo staging)
while [[ $# -gt 0 ]]; do
  case "$1" in
    --ref) ref=$2; shift 2 ;;
    --to) target=$2; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

repo_name=$(basename "$(git rev-parse --show-toplevel)")
src=$(pwd)
cleanup=()
trap 'for d in "${cleanup[@]}"; do git worktree remove --force "$d"; done' EXIT

# An older version is built from its own checkout.
if [[ -n "$ref" ]]; then
  src=$(mktemp -d)
  git worktree add --detach "$src" "$ref" >/dev/null
  cleanup+=("$src")
fi

if [[ "$target" == root ]]; then
  base_href="/$repo_name/"
else
  base_href="/$repo_name/staging/"
fi

(
  cd "$src"
  if [[ -z "$ref" ]]; then flutter test; else flutter pub get >/dev/null; fi
  bash tool/build_web.sh "$env" "$base_href"
)
version=$(sed -n 's/^version: *//p' "$src/pubspec.yaml")
commit=$(git -C "$src" rev-parse --short HEAD)

pages=$(mktemp -d)
cleanup+=("$pages")
if git ls-remote --exit-code --heads origin gh-pages >/dev/null; then
  git fetch -q origin gh-pages
  git worktree add --detach "$pages" origin/gh-pages >/dev/null
else
  git worktree add --detach "$pages" >/dev/null
  git -C "$pages" checkout -q --orphan gh-pages-new
  git -C "$pages" rm -rfq .
fi

# Replace only this environment's part of the site.
if [[ "$target" == root ]]; then
  find "$pages" -mindepth 1 -maxdepth 1 ! -name .git ! -name staging -exec rm -rf {} +
  cp -r "$src/build/web/." "$pages/"
else
  rm -rf "$pages/staging"
  mkdir -p "$pages/staging"
  cp -r "$src/build/web/." "$pages/staging/"
fi
touch "$pages/.nojekyll"

git -C "$pages" add -A
if git -C "$pages" diff --cached --quiet; then
  echo "No changes to deploy."
  exit 0
fi
git -C "$pages" commit -qm "Deploy $env $version ($commit) to $target"
git -C "$pages" push -q origin HEAD:gh-pages
echo "Deployed $env $version ($commit) to $target."
