#!/usr/bin/env bash
# Build or update the local reprepro repository under ./repo/
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="${REPO_DIR:-$REPO_ROOT/repo}"
PACKAGES_DIR="${PACKAGES_DIR:-$REPO_ROOT/packages}"
CODENAME="${CODENAME:-stable}"
SIGN_WITH="${REPREPRO_SIGN_WITH:-${GPG_KEY_ID:-}}"

usage() {
  cat <<'EOF'
Usage: scripts/build-repo.sh

Builds ./repo/ from .deb files in ./packages/ using reprepro.
Requires REPREPRO_SIGN_WITH or GPG_KEY_ID (GPG fingerprint) and an imported secret key.

Environment:
  REPO_DIR       Output directory (default: ./repo)
  PACKAGES_DIR   Input .deb directory (default: ./packages)
  CODENAME       Distribution codename (default: stable)
  REPREPRO_SIGN_WITH  GPG fingerprint for SignWith
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if ! command -v reprepro >/dev/null 2>&1; then
  echo "reprepro is required. Install with: sudo apt install reprepro" >&2
  exit 1
fi

if [[ -z "$SIGN_WITH" ]]; then
  echo "Set REPREPRO_SIGN_WITH or GPG_KEY_ID to your signing key fingerprint." >&2
  exit 1
fi

mkdir -p "$REPO_DIR/conf"
sed "s/@SIGN_WITH@/$SIGN_WITH/" "$REPO_ROOT/conf/distributions.template" >"$REPO_DIR/conf/distributions"
cp "$REPO_ROOT/conf/options" "$REPO_DIR/conf/options"

shopt -s nullglob
debs=( "$PACKAGES_DIR"/*.deb )
if ((${#debs[@]} == 0)); then
  echo "No .deb files in $PACKAGES_DIR" >&2
  exit 1
fi

for deb in "${debs[@]}"; do
  echo "Adding $(basename "$deb") ..."
  reprepro -b "$REPO_DIR" includedeb "$CODENAME" "$deb"
done

"$REPO_ROOT/keyring/build-keyring.sh"
keyring_deb="$REPO_ROOT/dist/hardenedpenguin-archive-keyring_"*"_all.deb"
reprepro -b "$REPO_DIR" includedeb "$CODENAME" $keyring_deb

cp "$REPO_ROOT/public/index.html" "$REPO_DIR/index.html"
gpg --armor --export "$SIGN_WITH" >"$REPO_DIR/pubkey.asc"

echo
echo "Repository built at: $REPO_DIR"
echo "Serve locally:  cd $REPO_DIR && python3 -m http.server 8080"
