# hardenedpenguin-apt

Signed APT repository for [hardenedpenguin](https://github.com/hardenedpenguin) Debian packages.

**https://hardenedpenguin.github.io/hardenedpenguin-apt/** · codename `stable` · `amd64` / `arm64`

## Install

```bash
BASE=https://hardenedpenguin.github.io/hardenedpenguin-apt
ARCH=$(dpkg --print-architecture)
PKG=$(curl -fsSL "$BASE/dists/stable/main/binary-${ARCH}/Packages" | awk '
  /^Package: hardenedpenguin-archive-keyring$/ { found=1 }
  found && /^Filename:/ { print $2; exit }
')
curl -fsSLO "$BASE/$PKG"
sudo apt install "./$(basename "$PKG")"
sudo apt update
sudo apt install skywarnplus-ng-all
sudo systemctl enable --now skywarnplus-ng
```

The **`hardenedpenguin-archive-keyring`** package installs the signing key and **`/etc/apt/sources.list.d/hardenedpenguin.list`**. After that, use **`apt install`**, **`apt upgrade`**, and **`apt remove`** normally.
