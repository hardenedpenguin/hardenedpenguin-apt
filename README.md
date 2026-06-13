# hardenedpenguin-apt

Signed APT repository for [hardenedpenguin](https://github.com/hardenedpenguin) Debian packages.

**https://hardenedpenguin.github.io/hardenedpenguin-apt/** · codename `stable` · `amd64` / `arm64`

## Install

```bash
curl -fsSLO https://hardenedpenguin.github.io/hardenedpenguin-apt/pool/main/h/hardenedpenguin-archive-keyring/hardenedpenguin-archive-keyring_1.0_all.deb
sudo apt install ./hardenedpenguin-archive-keyring_1.0_all.deb
sudo apt update
```

The keyring package adds the signing key and **`/etc/apt/sources.list.d/hardenedpenguin.list`**. Install packages normally, for example:

```bash
sudo apt install skywarnplus-ng-all saytime-weather-rb internet-monitor
```

| APT package | Project |
|-------------|---------|
| `skywarnplus-ng-all` | [SkywarnPlus-NG](https://github.com/hardenedpenguin/SkywarnPlus-NG) |
| `saytime-weather-rb` | [saytime_weather_rb](https://github.com/hardenedpenguin/saytime_weather_rb) |
| `sayip-node-utils` | [sayip-reboot-halt-saypublicip](https://github.com/hardenedpenguin/sayip-reboot-halt-saypublicip) |
| `internet-monitor` | [internet_monitor_rb](https://github.com/hardenedpenguin/internet_monitor_rb) |

**`sayip-node-utils`** may ask for your node number on install. For a non-interactive install:

```bash
sudo NODE_NUMBER=12345 apt install sayip-node-utils
```
