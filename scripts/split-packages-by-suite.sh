#!/usr/bin/env bash
# Sort .deb files into suite-specific directories for reprepro publishing.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INCOMING="${INCOMING_DIR:-$REPO_ROOT/packages/incoming}"
OUT_ROOT="${PACKAGES_DIR:-$REPO_ROOT/packages}"

route_deb() {
  local name="$1"
  case "$name" in
    *.deb12_*.deb) echo bookworm ;;
    *.deb13_*.deb) echo trixie ;;
    skywarnplus-ng_*.deb)
      # Legacy release assets (pre .deb12/.deb13) require Python 3.13 → Trixie only.
      echo trixie
      ;;
    *) echo stable ;;
  esac
}

mkdir -p "$INCOMING" "$OUT_ROOT/stable" "$OUT_ROOT/bookworm" "$OUT_ROOT/trixie"
rm -f "$OUT_ROOT/stable"/*.deb "$OUT_ROOT/bookworm"/*.deb "$OUT_ROOT/trixie"/*.deb 2>/dev/null || true

shopt -s nullglob
incoming=( "$INCOMING"/*.deb )
if ((${#incoming[@]} == 0)); then
  echo "No .deb files in $INCOMING" >&2
  exit 1
fi

declare -A counts=( [stable]=0 [bookworm]=0 [trixie]=0 )
for deb in "${incoming[@]}"; do
  name="$(basename "$deb")"
  suite="$(route_deb "$name")"
  cp -f "$deb" "$OUT_ROOT/$suite/$name"
  counts["$suite"]=$(( counts["$suite"] + 1 ))
  echo "$name -> $suite"
done

echo "Split ${#incoming[@]} package(s): stable=${counts[stable]} bookworm=${counts[bookworm]} trixie=${counts[trixie]}"
