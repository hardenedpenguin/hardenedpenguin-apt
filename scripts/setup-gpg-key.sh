#!/usr/bin/env bash
# Generate a GPG signing key for the APT repository (run once on a trusted machine).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEY_NAME="${KEY_NAME:-Hardened Penguin APT Repository}"
KEY_EMAIL="${KEY_EMAIL:-apt@hardenedpenguin.github.io}"
KEY_TYPE="${KEY_TYPE:-rsa4096}"
EXPORT_DIR="${EXPORT_DIR:-$REPO_ROOT/gpg-export}"

usage() {
  cat <<'EOF'
Usage: scripts/setup-gpg-key.sh [options]

Creates a dedicated GPG key for signing the APT repository metadata.
Store the private key in GitHub Actions secret GPG_PRIVATE_KEY and the
fingerprint in repository variable GPG_KEY_ID.

Options (environment variables):
  KEY_NAME     Real name on the key (default: Hardened Penguin APT Repository)
  KEY_EMAIL    Email on the key (default: apt@hardenedpenguin.github.io)
  KEY_TYPE     rsa4096 (default) or ed25519
  EXPORT_DIR   Directory for exported public key files

After creation, add to GitHub:
  Settings → Secrets and variables → Actions
    Secret:  GPG_PRIVATE_KEY  (gpg --armor --export-secret-keys <fingerprint>)
    Variable: GPG_KEY_ID       (40-char fingerprint, no spaces)

Never commit private key material to git.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if ! command -v gpg >/dev/null 2>&1; then
  echo "gpg is required. Install with: sudo apt install gnupg" >&2
  exit 1
fi

export GPG_TTY="$(tty 2>/dev/null || true)"

batch_cfg="$(mktemp)"
trap 'rm -f "$batch_cfg"' EXIT

case "$KEY_TYPE" in
  rsa4096)
    cat >"$batch_cfg" <<EOF
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: ${KEY_NAME}
Name-Email: ${KEY_EMAIL}
Expire-Date: 0
%no-protection
%commit
EOF
    ;;
  ed25519)
    cat >"$batch_cfg" <<EOF
Key-Type: EdDSA
Key-Curve: Ed25519
Name-Real: ${KEY_NAME}
Name-Email: ${KEY_EMAIL}
Expire-Date: 0
%no-protection
%commit
EOF
    ;;
  *)
    echo "Unsupported KEY_TYPE: $KEY_TYPE (use rsa4096 or ed25519)" >&2
    exit 1
    ;;
esac

echo "Generating GPG key for ${KEY_NAME} <${KEY_EMAIL}> ..."
gpg --batch --generate-key "$batch_cfg"

fingerprint="$(gpg --list-secret-keys --with-colons "$KEY_EMAIL" 2>/dev/null | awk -F: '/^fpr:/ { print $10; exit }')"
if [[ -z "$fingerprint" ]]; then
  echo "Failed to read key fingerprint" >&2
  exit 1
fi

mkdir -p "$EXPORT_DIR"
gpg --export-options export-minimal --export "$fingerprint" >"$EXPORT_DIR/hardenedpenguin-archive-keyring.gpg"
gpg --armor --export "$fingerprint" >"$EXPORT_DIR/pubkey.asc"

cat <<EOF

Key created successfully.

  Fingerprint: ${fingerprint}
  Public key:  ${EXPORT_DIR}/pubkey.asc
  Keyring:     ${EXPORT_DIR}/hardenedpenguin-archive-keyring.gpg

Export the private key for GitHub Actions (keep this secret):

  gpg --armor --export-secret-keys ${fingerprint}

Add to https://github.com/hardenedpenguin/hardenedpenguin-apt/settings/secrets/actions
  GPG_PRIVATE_KEY  → output of the command above
  GPG_KEY_ID       → ${fingerprint}  (repository variable)

Local reprepro builds:

  export REPREPRO_SIGN_WITH=${fingerprint}
  ./scripts/build-repo.sh
EOF
