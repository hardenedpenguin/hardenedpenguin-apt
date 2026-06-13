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

**`sayip-node-utils`** may ask for your node number on install. For a non-interactive install:

```bash
sudo NODE_NUMBER=12345 apt install sayip-node-utils
```
