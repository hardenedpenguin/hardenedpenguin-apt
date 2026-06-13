#!/usr/bin/env bash
# Download .deb release assets from a GitHub repository into ./packages/
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_DIR="${PACKAGES_DIR:-$REPO_ROOT/packages}"
ARCH_FILTER="${ARCH_FILTER:-}"   # e.g. amd64 or arm64; empty = all .deb assets

usage() {
  cat <<'EOF'
Usage: scripts/sync-github-release.sh <owner/repo> [tag]

Downloads .deb files from the latest (or specified) GitHub release into ./packages/.
Requires curl and jq.

Examples:
  ./scripts/sync-github-release.sh hardenedpenguin/SkywarnPlus-NG
  ./scripts/sync-github-release.sh hardenedpenguin/supermon-ng V4.2.1
  ARCH_FILTER=amd64 ./scripts/sync-github-release.sh hardenedpenguin/SkywarnPlus-NG v1.2.0
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || $# -lt 1 ]]; then
  usage
  exit "${1:+0}" 1
fi

gh_repo="$1"
tag="${2:-}"

for cmd in curl jq; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "$cmd is required" >&2
    exit 1
  fi
done

api_url="https://api.github.com/repos/${gh_repo}/releases/latest"
if [[ -n "$tag" ]]; then
  api_url="https://api.github.com/repos/${gh_repo}/releases/tags/${tag}"
fi

echo "Fetching release metadata from $api_url ..."
release_json="$(curl -fsSL "$api_url")"
release_tag="$(jq -r '.tag_name' <<<"$release_json")"
asset_count="$(jq '[.assets[] | select(.name | endswith(".deb"))] | length' <<<"$release_json")"

if [[ "$asset_count" -eq 0 ]]; then
  echo "No .deb assets on release ${release_tag}" >&2
  exit 1
fi

mkdir -p "$PACKAGES_DIR"

while IFS= read -r line; do
  name="${line%%$'\t'*}"
  url="${line#*$'\t'}"

  if [[ -n "$ARCH_FILTER" && "$name" != *"_${ARCH_FILTER}.deb" && "$name" != *_all.deb ]]; then
    continue
  fi

  dest="$PACKAGES_DIR/$name"
  echo "Downloading $name ..."
  curl -fsSL -o "$dest" "$url"
done < <(jq -r '.assets[] | select(.name | endswith(".deb")) | "\(.name)\t\(.browser_download_url)"' <<<"$release_json")

echo "Downloaded release ${release_tag} assets into $PACKAGES_DIR"
