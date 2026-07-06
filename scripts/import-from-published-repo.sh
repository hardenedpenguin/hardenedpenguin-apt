#!/usr/bin/env bash
# Seed packages/incoming/ from the currently published GitHub Pages APT repo.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INCOMING="${INCOMING_DIR:-$REPO_ROOT/packages/incoming}"
BASE_URL="${REPO_BASE_URL:-https://hardenedpenguin.github.io/hardenedpenguin-apt/}"
CODENAMES="${IMPORT_CODENAMES:-stable bookworm trixie}"
ARCHES="${IMPORT_ARCHES:-amd64 arm64}"

mkdir -p "$INCOMING"

import_codename() {
  local codename="$1"
  local arch="$2"
  local packages_url="${BASE_URL}dists/${codename}/main/binary-${arch}/Packages"
  local tmp
  tmp="$(mktemp)"
  if curl -fsSL "$packages_url" -o "$tmp"; then
    :
  elif curl -fsSL "${packages_url}.gz" | gunzip -c >"$tmp"; then
    :
  else
    echo "No Packages index at $packages_url (skipping)" >&2
    rm -f "$tmp"
    return 0
  fi
  local count=0
  while IFS= read -r rel; do
    [[ -z "$rel" ]] && continue
    local url="${BASE_URL}${rel#./}"
    local dest="$INCOMING/$(basename "$rel")"
    if [[ -f "$dest" ]]; then
      continue
    fi
    echo "Import $codename/$arch: $(basename "$rel")"
    curl -fsSL "$url" -o "$dest"
    count=$((count + 1))
  done < <(grep -E '^Filename:' "$tmp" | awk '{print $2}')
  rm -f "$tmp"
  echo "Imported $count new file(s) from ${codename}/${arch}"
}

for codename in $CODENAMES; do
  for arch in $ARCHES; do
    import_codename "$codename" "$arch" || true
  done
done

shopt -s nullglob
incoming=( "$INCOMING"/*.deb )
echo "Incoming pool now has ${#incoming[@]} .deb file(s)"
