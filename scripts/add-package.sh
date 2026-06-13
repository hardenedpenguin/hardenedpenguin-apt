#!/usr/bin/env bash
# Copy a .deb into packages/ and rebuild the local repository.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_DIR="${PACKAGES_DIR:-$REPO_ROOT/packages}"

usage() {
  cat <<'EOF'
Usage: scripts/add-package.sh <package.deb> [more.deb ...]

Copies Debian packages into ./packages/ and runs ./scripts/build-repo.sh.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || $# -lt 1 ]]; then
  usage
  exit "${1:+0}" 1
fi

mkdir -p "$PACKAGES_DIR"

for deb in "$@"; do
  if [[ ! -f "$deb" ]]; then
    echo "Not a file: $deb" >&2
    exit 1
  fi
  if [[ "$deb" != *.deb ]]; then
    echo "Not a .deb file: $deb" >&2
    exit 1
  fi
  cp -v "$deb" "$PACKAGES_DIR/"
done

exec "$REPO_ROOT/scripts/build-repo.sh"
