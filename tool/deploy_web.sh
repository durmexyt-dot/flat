#!/usr/bin/env bash
# Builds the web app and publishes it to the gh-pages branch.
# GitHub Pages serves that branch at https://<owner>.github.io/<repo>/.
set -euo pipefail

cd "$(dirname "$0")/.."
repo_name=$(basename "$(git rev-parse --show-toplevel)")
commit=$(git rev-parse --short HEAD)

flutter test
flutter build web --release --base-href "/$repo_name/"

worktree=$(mktemp -d)
trap 'git worktree remove --force "$worktree"' EXIT

if git ls-remote --exit-code --heads origin gh-pages >/dev/null; then
  git fetch origin gh-pages
  git worktree add "$worktree" origin/gh-pages --detach
else
  git worktree add "$worktree" --detach
  git -C "$worktree" checkout --orphan gh-pages-new
fi

# Replace everything with the fresh build.
git -C "$worktree" rm -rfq --ignore-unmatch .
cp -r build/web/. "$worktree"/
touch "$worktree/.nojekyll"

git -C "$worktree" add -A
if git -C "$worktree" diff --cached --quiet; then
  echo "No changes to deploy."
  exit 0
fi
git -C "$worktree" commit -qm "Deploy web build from $commit"
git -C "$worktree" push origin HEAD:gh-pages
echo "Deployed $commit to gh-pages."
