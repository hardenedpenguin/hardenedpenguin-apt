# hardenedpenguin-apt

Signed APT repository for [hardenedpenguin](https://github.com/hardenedpenguin) Debian packages.

**https://hardenedpenguin.github.io/hardenedpenguin-apt/** · codename `stable` · `amd64` / `arm64`

## Install

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
