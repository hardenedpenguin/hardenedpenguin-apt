#!/usr/bin/env bash
# Build hardenedpenguin-archive-keyring for inclusion in the published repo.
set -euo pipefail

OUT_DIR="${1:-packages}"
SIGN_WITH="${GPG_KEY_ID:?GPG_KEY_ID is required}"
KEYRING_VERSION="${KEYRING_VERSION:-1.0}"
REPO_URL="${REPO_URL:-https://hardenedpenguin.github.io/hardenedpenguin-apt/}"
CODENAME="${CODENAME:-stable}"
COMPONENT="${COMPONENT:-main}"
KEYRING_NAME="hardenedpenguin-archive-keyring"

staging="$(mktemp -d)"
trap 'rm -rf "$staging"' EXIT

mkdir -p "$staging/DEBIAN" \
         "$staging/usr/share/keyrings" \
         "$staging/etc/apt/sources.list.d"

gpg --export-options export-minimal --export "$SIGN_WITH" \
  >"$staging/usr/share/keyrings/${KEYRING_NAME}.gpg"

cat >"$staging/etc/apt/sources.list.d/hardenedpenguin.list" <<EOF
deb [signed-by=/usr/share/keyrings/${KEYRING_NAME}.gpg] ${REPO_URL} ${CODENAME} ${COMPONENT}
EOF

cat >"$staging/DEBIAN/control" <<EOF
Package: ${KEYRING_NAME}
Version: ${KEYRING_VERSION}
Architecture: all
Maintainer: Jory A. Pratt, W5GLE <geekypenguin@gmail.com>
Section: misc
Priority: optional
Homepage: https://github.com/hardenedpenguin/hardenedpenguin-apt
Description: GPG archive key and apt source for Hardened Penguin packages
 Installs the repository signing key and adds the hardenedpenguin apt source.
EOF

mkdir -p "$OUT_DIR"
out="$OUT_DIR/${KEYRING_NAME}_${KEYRING_VERSION}_all.deb"
dpkg-deb --root-owner-group --build "$staging" "$out"
echo "Built $out"
