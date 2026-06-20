# hardenedpenguin-apt

[![Publish APT repository](https://github.com/hardenedpenguin/hardenedpenguin-apt/actions/workflows/publish.yml/badge.svg)](https://github.com/hardenedpenguin/hardenedpenguin-apt/actions/workflows/publish.yml)
[![APT repository](https://img.shields.io/badge/apt-hardenedpenguin.github.io-blue?logo=github)](https://hardenedpenguin.github.io/hardenedpenguin-apt/)
[![Architectures](https://img.shields.io/badge/architectures-amd64%20%7C%20arm64-informational)](https://hardenedpenguin.github.io/hardenedpenguin-apt/dists/stable/)
[![Debian](https://img.shields.io/badge/Debian-stable-red?logo=debian)](https://hardenedpenguin.github.io/hardenedpenguin-apt/dists/stable/)
[![Signed packages](https://img.shields.io/badge/packages-GPG%20signed-green)](https://hardenedpenguin.github.io/hardenedpenguin-apt/dists/stable/Release.gpg)

Signed APT repository for [hardenedpenguin](https://github.com/hardenedpenguin) Debian packages.

**https://hardenedpenguin.github.io/hardenedpenguin-apt/** · codename `stable` · `amd64` / `arm64`

## Install

```bash
curl -fsSLO https://hardenedpenguin.github.io/hardenedpenguin-apt/pool/main/h/hardenedpenguin-archive-keyring/hardenedpenguin-archive-keyring_1.0_all.deb
sudo apt install ./hardenedpenguin-archive-keyring_1.0_all.deb
sudo apt update
```

The keyring package adds the signing key and **`/etc/apt/sources.list.d/hardenedpenguin.list`**. After that, install packages with **`apt install`**, **`apt upgrade`**, and **`apt remove`**.

## Packages

| Package | Description |
|---------|-------------|
| `hardenedpenguin-archive-keyring` | Repository signing key and apt source (install once via curl above) |
| `skywarnplus-ng` | [SkywarnPlus-NG](https://github.com/hardenedpenguin/SkywarnPlus-NG) weather alerts, dashboard, and Piper voice |
| `supermon-ng` | [Supermon-ng](https://github.com/hardenedpenguin/supermon-ng) AllStar node monitoring dashboard |
| `saytime-weather-rb` | [saytime_weather_rb](https://github.com/hardenedpenguin/saytime_weather_rb) time and weather announcements |
| `sayip-node-utils` | [sayip-reboot-halt-saypublicip](https://github.com/hardenedpenguin/sayip-reboot-halt-saypublicip) SayIP, reboot, and halt via DTMF |
| `internet-monitor` | [internet_monitor_rb](https://github.com/hardenedpenguin/internet_monitor_rb) Internet connectivity monitor with audio alerts |

Example:

```bash
sudo apt install skywarnplus-ng supermon-ng saytime-weather-rb internet-monitor
sudo NODE_NUMBER=12345 apt install sayip-node-utils
```

**`sayip-node-utils`** may prompt for your node number on an interactive install. Use **`NODE_NUMBER`** for scripts or non-interactive installs.
