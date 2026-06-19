# hardenedpenguin-apt

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
