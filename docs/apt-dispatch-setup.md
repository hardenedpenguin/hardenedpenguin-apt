# APT repo publish on release

Package repos call `dispatch-apt-publish.yml` after uploading release `.deb` files so the apt repository updates within minutes instead of waiting for the daily cron.

## One-time setup

1. Create a [fine-grained personal access token](https://github.com/settings/personal-access-tokens/new) or classic PAT with access to **`hardenedpenguin/hardenedpenguin-apt`** and **Actions: Read and write** (classic: `repo` scope).

2. Add the token as secret **`APT_REPO_DISPATCH_TOKEN`** on each package repository (or once as an organization secret shared by all hardenedpenguin repos):

   - SkywarnPlus-NG
   - supermon-ng
   - saytime_weather_rb
   - sayip-reboot-halt-saypublicip
   - internet_monitor_rb
   - cap-alert

3. Tag and release as usual. The release workflow triggers `repository_dispatch` on this repo, which runs **Publish APT repository**.

If the secret is missing, release workflows still succeed; apt publish is skipped with a warning until the secret is configured.
