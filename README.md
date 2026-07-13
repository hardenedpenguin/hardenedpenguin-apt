# hardenedpenguin-apt

[![Publish APT repository](https://github.com/hardenedpenguin/hardenedpenguin-apt/actions/workflows/publish.yml/badge.svg)](https://github.com/hardenedpenguin/hardenedpenguin-apt/actions/workflows/publish.yml)
[![APT repository](https://img.shields.io/badge/apt-hardenedpenguin.github.io-blue?logo=github)](https://hardenedpenguin.github.io/hardenedpenguin-apt/)
[![Architectures](https://img.shields.io/badge/architectures-amd64%20%7C%20arm64-informational)](https://hardenedpenguin.github.io/hardenedpenguin-apt/dists/)
[![Debian](https://img.shields.io/badge/Debian-bookworm%20%7C%20trixie%20%7C%20stable-red?logo=debian)](https://hardenedpenguin.github.io/hardenedpenguin-apt/dists/)
[![Signed packages](https://img.shields.io/badge/packages-GPG%20signed-green)](https://hardenedpenguin.github.io/hardenedpenguin-apt/dists/stable/Release.gpg)

Signed APT repository for [hardenedpenguin](https://github.com/hardenedpenguin) Debian packages.

**https://hardenedpenguin.github.io/hardenedpenguin-apt/** · suites **`bookworm`** / **`trixie`** / **`stable`** · `amd64` / `arm64`

## Install

```bash
cd /tmp
curl -fsSLO https://hardenedpenguin.github.io/hardenedpenguin-apt/pool/main/h/hardenedpenguin-archive-keyring/hardenedpenguin-archive-keyring_1.2_all.deb
sudo apt install ./hardenedpenguin-archive-keyring_1.2_all.deb
sudo apt update
```

The keyring package (v1.2+) installs the signing key and **`/etc/apt/sources.list.d/hardenedpenguin.list`**, automatically enabling:

- Your OS suite (**`bookworm`** on Debian 12, **`trixie`** on Debian 13) — for suite-specific builds such as `skywarnplus-ng_*_deb12_*` / `*_deb13_*`
- The shared **`stable`** suite — for packages without a Debian revision suffix (supermon-ng, cap-alert, etc.)
- **`arch=amd64,arm64`** only — avoids armhf errors on multiarch ASL3/RPi nodes (32-bit is not supported)

After that, install packages with **`apt install`**, **`apt upgrade`**, and **`apt remove`**.

## Packages

| Package | Description |
|---------|-------------|
| `hardenedpenguin-archive-keyring` | Repository signing key and apt sources (install once via curl above) |
| `skywarnplus-ng` | [SkywarnPlus-NG](https://github.com/hardenedpenguin/SkywarnPlus-NG) weather alerts, dashboard, and Piper voice |
| `supermon-ng` | [Supermon-ng](https://github.com/hardenedpenguin/supermon-ng) AllStar node monitoring dashboard |
| `saytime-weather-rb` | [saytime_weather_rb](https://github.com/hardenedpenguin/saytime_weather_rb) time and weather announcements |
| `sayip-node-utils` | [sayip-reboot-halt-saypublicip](https://github.com/hardenedpenguin/sayip-reboot-halt-saypublicip) SayIP, reboot, and halt via DTMF |
| `internet-monitor` | [internet_monitor_rb](https://github.com/hardenedpenguin/internet_monitor_rb) Internet connectivity monitor with audio alerts |
| `cap-alert` | [cap-alert](https://github.com/hardenedpenguin/cap-alert) NWS weather alerts for AllStar/Asterisk nodes |
| `anytone` | [AnyTone_CPS](https://github.com/hardenedpenguin/AnyTone_CPS) Linux CPS for Anytone D878UV / D878UV II / D578UV |

Example:

```bash
sudo apt install skywarnplus-ng supermon-ng saytime-weather-rb internet-monitor cap-alert
sudo NODE_NUMBER=12345 apt install sayip-node-utils
```

**`sayip-node-utils`** may prompt for your node number on an interactive install. Use **`NODE_NUMBER`** for scripts or non-interactive installs.

## Suite-specific packages

Some packages ship **Debian suite builds** (ASL3-style revision tags):

| Package revision | Suite | Use on |
|------------------|-------|--------|
| `*_deb12_*` | `bookworm` | Debian 12 Bookworm |
| `*_deb13_*` | `trixie` | Debian 13 Trixie |

Example: [SkywarnPlus-NG](https://github.com/hardenedpenguin/SkywarnPlus-NG) publishes `skywarnplus-ng_1.6.0-1.deb12_arm64.deb` and `skywarnplus-ng_1.6.0-1.deb13_arm64.deb`. Bookworm nodes receive the `.deb12` build via the **`bookworm`** apt suite after the keyring is installed.

## Publishing (maintainers)

Release workflows in package repos trigger **`repository_dispatch`** here. The publish workflow:

1. Imports existing pool packages from GitHub Pages
2. Syncs `.deb` assets from GitHub Releases
3. Splits packages into **`stable`**, **`bookworm`**, and **`trixie`**
4. Builds a signed reprepro repository and deploys to GitHub Pages

Manual run: **Actions → Publish APT repository → Run workflow**.
