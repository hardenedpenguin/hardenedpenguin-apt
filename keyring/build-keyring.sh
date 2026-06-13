#!/usr/bin/env bash
# Build hardenedpenguin-archive-keyring .deb (configures apt sources + trusted key).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STAGING="${1:-$REPO_ROOT/keyring/staging}"
SIGN_WITH="${2:-${REPREPRO_SIGN_WITH:-${GPG_KEY_ID:-}}}"
DIST_DIR="${DIST_DIR:-$REPO_ROOT/dist}"
KEYRING_VERSION="${KEYRING_VERSION:-1.0}"
REPO_URL="${REPO_URL:-https://hardenedpenguin.github.io/hardenedpenguin-apt/}"
CODENAME="${CODENAME:-stable}"
COMPONENT="${COMPONENT:-main}"
KEYRING_NAME="hardenedpenguin-archive-keyring"

if [[ -z "$SIGN_WITH" ]]; then
  echo "GPG fingerprint required (arg 2 or REPREPRO_SIGN_WITH / GPG_KEY_ID)" >&2
  exit 1
fi

rm -rf "$STAGING"
mkdir -p "$STAGING/DEBIAN" \
         "$STAGING/usr/share/keyrings" \
         "$STAGING/etc/apt/sources.list.d"

gpg --export-options export-minimal --export "$SIGN_WITH" \
  >"$STAGING/usr/share/keyrings/${KEYRING_NAME}.gpg"

cat >"$STAGING/etc/apt/sources.list.d/hardenedpenguin.list" <<EOF
deb [signed-by=/usr/share/keyrings/${KEYRING_NAME}.gpg] ${REPO_URL} ${CODENAME} ${COMPONENT}
EOF

cat >"$STAGING/DEBIAN/control" <<EOF
Package: ${KEYRING_NAME}
Version: ${KEYRING_VERSION}
Architecture: all
Maintainer: Jory A. Pratt, W5GLE <geekypenguin@gmail.com>
Section: misc
Priority: optional
Homepage: https://github.com/hardenedpenguin/hardenedpenguin-apt
Description: GPG archive key and apt sources list for Hardened Penguin packages
 Installs the repository signing key and adds the Hardened Penguin APT
 source so you can install packages with apt after one manual dpkg -i step.
EOF

mkdir -p "$DIST_DIR"
out="$DIST_DIR/${KEYRING_NAME}_${KEYRING_VERSION}_all.deb"
dpkg-deb --root-owner-group --build "$STAGING" "$out"
echo "Built $out"
