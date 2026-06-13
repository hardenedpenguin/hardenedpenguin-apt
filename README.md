# Hardened Penguin APT Repository

Central [Debian APT](https://wiki.debian.org/Apt) repository for `.deb` packages built by [hardenedpenguin](https://github.com/hardenedpenguin). Hosts are served over **GitHub Pages** at:

**https://hardenedpenguin.github.io/hardenedpenguin-apt/**

Users install a single archive-keyring package once, then install any published package with normal `apt` commands.

## Install on a node (users)

### One-time: enable the repository

Download and install the archive keyring package (registers the GPG key and adds the apt source):

```bash
BASE=https://hardenedpenguin.github.io/hardenedpenguin-apt
PKG=$(curl -fsSL "$BASE/dists/stable/main/binary-all/Packages" | awk '
  /^Package: hardenedpenguin-archive-keyring$/ { found=1 }
  found && /^Filename:/ { print $2; exit }
')
curl -fsSLO "$BASE/$PKG"
sudo apt install "./$(basename "$PKG")"
sudo apt update
```

### Install packages

```bash
sudo apt install skywarnplus-ng-all
sudo apt install supermon-ng
```

Replace package names with whatever is currently published. List available packages:

```bash
apt-cache search hardenedpenguin
apt list 2>/dev/null | grep -E 'skywarn|supermon'
```

### Upgrade

```bash
sudo apt update
sudo apt upgrade
```

## Maintainer setup (one-time)

### 1. Create a signing key

On a trusted machine:

```bash
chmod +x scripts/*.sh keyring/build-keyring.sh
./scripts/setup-gpg-key.sh
```

Follow the printed instructions to add secrets to this GitHub repository:

| Name | Type | Value |
|------|------|-------|
| `GPG_PRIVATE_KEY` | Secret | `gpg --armor --export-secret-keys <fingerprint>` |
| `GPG_KEY_ID` | Variable | 40-character fingerprint (no spaces) |

### 2. Enable GitHub Pages

In **Settings → Pages → Build and deployment**, set **Source** to **GitHub Actions**.

### 3. Publish packages

**Option A — commit `.deb` files locally** (small repos / testing):

```bash
cp /path/to/*.deb packages/
git add packages/
git commit -m "Add packages"
git push
```

**Option B — manual workflow with release sync** (recommended):

1. Open **Actions → Publish APT repository → Run workflow**
2. Enable **Sync SkywarnPlus-NG** and/or **Sync supermon-ng**
3. Optionally set a release tag (empty = latest)

**Option C — trigger from another repo** (`repository_dispatch`):

```bash
curl -sS -X POST \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/hardenedpenguin/hardenedpenguin-apt/dispatches \
  -d '{"event_type":"publish-debs","client_payload":{"sync_skywarnplus":true,"sync_supermon":true}}'
```

Or pass explicit `.deb` URLs:

```json
{
  "event_type": "publish-debs",
  "client_payload": {
    "deb_urls": [
      "https://github.com/hardenedpenguin/SkywarnPlus-NG/releases/download/v1.2.0/skywarnplus-ng-all_1.2.0_amd64.deb"
    ]
  }
}
```

## Local development

Build the repository on your machine (requires `reprepro`, `gnupg`, imported signing key):

```bash
export REPREPRO_SIGN_WITH=<your-fingerprint>
./scripts/sync-github-release.sh hardenedpenguin/SkywarnPlus-NG v1.2.0
./scripts/build-repo.sh
cd repo && python3 -m http.server 8080
```

Add a single package:

```bash
export REPREPRO_SIGN_WITH=<your-fingerprint>
./scripts/add-package.sh /path/to/package.deb
```

Test on a client pointed at your local server:

```bash
# after adjusting sources to http://127.0.0.1:8080/ stable main
sudo apt update
sudo apt install skywarnplus-ng-all
```

## Repository layout

```
conf/                  reprepro configuration templates
keyring/               archive-keyring .deb builder
packages/              incoming .deb files for CI (binaries gitignored)
public/index.html      landing page copied into published repo
scripts/               maintainer helpers
.github/workflows/     GitHub Pages publish pipeline
```

Published output (on GitHub Pages) follows the usual Debian layout: `dists/`, `pool/`, `pubkey.asc`, and the `hardenedpenguin-archive-keyring` package in `pool/main/`.

## Supported architectures

Packages are indexed for **amd64** and **arm64**. Packages marked `Architecture: all` (for example `supermon-ng`) are served on both automatically — do not list `all` in the reprepro config.

The apt **codename** is `stable` — it is not tied to a specific Debian release name; packages target ASL3 / Debian bookworm and trixie nodes.

## Security

- Repository metadata is **GPG-signed**. The public key ships in `hardenedpenguin-archive-keyring` and as `pubkey.asc` on the site.
- **Never commit** private keys or `packages/*.deb` unless you intend to (they are gitignored by default).
- Rotate keys by generating a new key, updating GitHub secrets, rebuilding the repo, and publishing a new keyring package version.

## License

Scripts and configuration in this repository: MIT. Individual packages retain their upstream licenses.
