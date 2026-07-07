#!/usr/bin/env bash
# Build hardenedpenguin-archive-keyring for inclusion in the published repo.
set -euo pipefail

OUT_DIR="${1:-packages/incoming}"
SIGN_WITH="${GPG_KEY_ID:?GPG_KEY_ID is required}"
KEYRING_VERSION="${KEYRING_VERSION:-1.2}"
REPO_URL="${REPO_URL:-https://hardenedpenguin.github.io/hardenedpenguin-apt/}"
KEYRING_NAME="hardenedpenguin-archive-keyring"

staging="$(mktemp -d)"
trap 'rm -rf "$staging"' EXIT

mkdir -p "$staging/DEBIAN" \
         "$staging/usr/share/keyrings" \
         "$staging/etc/apt/sources.list.d"

gpg --export-options export-minimal --export "$SIGN_WITH" \
  >"$staging/usr/share/keyrings/${KEYRING_NAME}.gpg"

# Placeholder; postinst writes the suite-aware source list on install/upgrade.
: >"$staging/etc/apt/sources.list.d/hardenedpenguin.list"

cat >"$staging/DEBIAN/postinst" <<'POSTINST'
#!/bin/sh
set -e
REPO_URL="https://hardenedpenguin.github.io/hardenedpenguin-apt/"
KEYRING="/usr/share/keyrings/hardenedpenguin-archive-keyring.gpg"
LIST="/etc/apt/sources.list.d/hardenedpenguin.list"

suite=stable
if [ -f /etc/os-release ]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  case "${VERSION_CODENAME:-}" in
    bookworm) suite=bookworm ;;
    trixie|forky) suite=trixie ;;
  esac
fi

{
  echo "deb [arch=amd64,arm64 signed-by=${KEYRING}] ${REPO_URL} ${suite} main"
  echo "deb [arch=amd64,arm64 signed-by=${KEYRING}] ${REPO_URL} stable main"
} >"${LIST}"

exit 0
POSTINST
chmod 755 "$staging/DEBIAN/postinst"

cat >"$staging/DEBIAN/control" <<EOF
Package: ${KEYRING_NAME}
Version: ${KEYRING_VERSION}
Architecture: all
Maintainer: Jory A. Pratt, W5GLE <geekypenguin@gmail.com>
Section: misc
Priority: optional
Homepage: https://github.com/hardenedpenguin/hardenedpenguin-apt
Description: GPG archive key and apt source for Hardened Penguin packages
 Installs the repository signing key and adds hardenedpenguin apt sources
 matched to your Debian release (bookworm/trixie) plus the shared stable suite.
 Only amd64 and arm64 are enabled (32-bit armhf is not supported).
EOF

mkdir -p "$OUT_DIR"
out="$OUT_DIR/${KEYRING_NAME}_${KEYRING_VERSION}_all.deb"
dpkg-deb --root-owner-group --build "$staging" "$out"
echo "Built $out"
