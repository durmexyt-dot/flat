#!/usr/bin/env bash
# Makes a release: checks, version bump, changelog, tag, push, deploy.
#
#   tool/release.sh patch|minor|major|X.Y.Z [staging|prod|all]
#
#   patch  1.1.0 → 1.1.1   bug fixes
#   minor  1.1.0 → 1.2.0   new features
#   major  1.1.0 → 2.0.0   incompatible changes (e.g. data model)
#
# The build number (after "+") always grows by one; app stores require it,
# and the web app uses it to tell that a newer version is online.
# Deploys to staging by default; "all" also deploys prod once it exists.
#
# The release notes come from the "## [Unreleased]" section of
# CHANGELOG.md, or from the commit subjects since the last release.
set -euo pipefail
cd "$(dirname "$0")/.."

bump=${1:?usage: tool/release.sh patch|minor|major|X.Y.Z [staging|prod|all]}
envs=${2:-staging}

# ---- Preconditions -------------------------------------------------------
[[ $(git rev-parse --abbrev-ref HEAD) == main ]] || { echo "Release from main." >&2; exit 1; }
[[ -z $(git status --porcelain) ]] || { echo "Uncommitted changes: commit or stash first." >&2; exit 1; }
git fetch -q origin main
[[ $(git rev-parse HEAD) == $(git rev-parse origin/main) ]] || {
  echo "main differs from origin/main: pull or push first." >&2; exit 1; }

# ---- New version -----------------------------------------------------------
current=$(sed -n 's/^version: *//p' pubspec.yaml)
version=${current%%+*}
build=${current##*+}
IFS=. read -r major minor patch <<<"$version"
case "$bump" in
  patch) new="$major.$minor.$((patch + 1))" ;;
  minor) new="$major.$((minor + 1)).0" ;;
  major) new="$((major + 1)).0.0" ;;
  [0-9]*.[0-9]*.[0-9]*) new=$bump ;;
  *) echo "Unknown bump: $bump" >&2; exit 1 ;;
esac
new_build=$((build + 1))
tag="v$new"
git rev-parse -q --verify "refs/tags/$tag" >/dev/null && { echo "$tag exists." >&2; exit 1; }
echo "Release $version+$build → $new+$new_build"

# ---- Checks ----------------------------------------------------------------
flutter analyze
flutter test

# ---- Changelog ---------------------------------------------------------------
last=$(git describe --tags --abbrev=0 --match 'v*' 2>/dev/null || true)
python3 - "$new" "$last" <<'PY'
import datetime, re, subprocess, sys
new, last = sys.argv[1], sys.argv[2]
path = 'CHANGELOG.md'
text = open(path, encoding='utf-8').read()
m = re.search(r'## \[Unreleased\]\n(.*?)(?=\n## \[|\Z)', text, re.S)
notes = m.group(1).strip() if m else ''
if not notes:
    rng = f'{last}..HEAD' if last else 'HEAD'
    subjects = subprocess.run(['git', 'log', '--no-merges', '--format=%s', rng],
                              capture_output=True, text=True, check=True).stdout.split('\n')
    notes = '\n'.join(f'- {s}' for s in subjects
                      if s and not s.startswith(('Release v', 'WIP')))
today = datetime.date.today().isoformat()
section = f'## [Unreleased]\n\n## [{new}] – {today}\n\n{notes}\n'
if m:
    text = text[:m.start()] + section + text[m.end():]
else:
    text = text.replace('\n## [', '\n' + section + '\n## [', 1) if '\n## [' in text else text + '\n' + section
open(path, 'w', encoding='utf-8').write(text)
PY

# ---- Version, commit, tag, push ----------------------------------------------
sed -i.bak "s/^version: .*/version: $new+$new_build/" pubspec.yaml && rm pubspec.yaml.bak
git add pubspec.yaml CHANGELOG.md
git commit -qm "Release $tag"
git tag -a "$tag" -m "Stubswap $new"
git push -q origin main
if ! git push -q origin "refs/tags/$tag" 2>/dev/null; then
  # Some environments only allow branch pushes: keep the release findable.
  git push -q origin "$tag^{commit}:refs/heads/release/$tag"
  echo "Tag push refused; pushed branch release/$tag instead (push the tag later with: git push origin $tag)."
fi

# ---- Deploy --------------------------------------------------------------------
prod_ready=$(grep -q 'FirebaseOptions? web = null' lib/firebase_options_prod.dart && echo no || echo yes)
case "$envs" in
  staging) bash tool/deploy_web.sh staging ;;
  prod) bash tool/deploy_web.sh prod ;;
  all)
    bash tool/deploy_web.sh staging
    if [[ $prod_ready == yes ]]; then bash tool/deploy_web.sh prod
    else echo "Prod not configured yet: skipped."; fi ;;
  *) echo "Unknown environment: $envs" >&2; exit 1 ;;
esac
echo "Released $tag."
