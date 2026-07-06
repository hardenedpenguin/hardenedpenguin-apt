#!/usr/bin/env bash
# Build signed APT repository with stable, bookworm, and trixie suites.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${1:-$(mktemp -d)}"
PACKAGES_ROOT="${PACKAGES_DIR:-$REPO_ROOT/packages}"
REPREPRO_BASE="${REPREPRO_BASE:-$REPO_ROOT/.reprepro-work}"
SIGN_WITH="${GPG_KEY_ID:?GPG_KEY_ID is required}"
ORIGIN="${ORIGIN:-Hardened Penguin}"
LABEL="${LABEL:-Hardened Penguin APT Repository}"

if [[ -z "${GPG_PRIVATE_KEY:-}" ]]; then
  echo "GPG_PRIVATE_KEY is required in the environment" >&2
  exit 1
fi

install -d -m 700 ~/.gnupg
echo "$GPG_PRIVATE_KEY" | gpg --batch --import >/dev/null

rm -rf "$REPREPRO_BASE"
mkdir -p "$REPREPRO_BASE/conf"

cat >"$REPREPRO_BASE/conf/distributions" <<EOF
Codename: stable
Suite: stable
Origin: ${ORIGIN}
Label: ${LABEL}
SignWith: ${SIGN_WITH}
Architectures: amd64 arm64
Components: main

Codename: bookworm
Suite: bookworm
Origin: ${ORIGIN}
Label: ${LABEL}
SignWith: ${SIGN_WITH}
Architectures: amd64 arm64
Components: main

Codename: trixie
Suite: trixie
Origin: ${ORIGIN}
Label: ${LABEL}
SignWith: ${SIGN_WITH}
Architectures: amd64 arm64
Components: main
EOF

reprepro=( reprepro -b "$REPREPRO_BASE" -C main )

for codename in stable bookworm trixie; do
  shopt -s nullglob
  debs=( "$PACKAGES_ROOT/$codename"/*.deb )
  if ((${#debs[@]} == 0)); then
    echo "No packages for suite ${codename} (skipping)"
    continue
  fi
  echo "Including ${#debs[@]} package(s) in ${codename} ..."
  "${reprepro[@]}" includedeb "$codename" "${debs[@]}"
done

if [[ ! -d "$REPREPRO_BASE/dists/stable" && ! -d "$REPREPRO_BASE/dists/bookworm" && ! -d "$REPREPRO_BASE/dists/trixie" ]]; then
  echo "No suite was published; at least one suite must contain packages" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"
cp -a "$REPREPRO_BASE/dists" "$REPREPRO_BASE/pool" "$OUT_DIR/"
echo "Built APT repo at $OUT_DIR"
