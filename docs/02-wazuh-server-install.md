# 2. Wazuh server: all-in-one install

**Result:** Wazuh **4.14.10** (indexer + manager + dashboard) on Ubuntu Server
24.04, dashboard at **https://100.100.100.130**. Startup after boot takes
**~7 minutes** (it took 1+ hour before the [host fix](00-host-preparation.md)).

> Do [host preparation](00-host-preparation.md) first. Most install failures
> in this lab came from the Windows hypervisor slowing the VM down.

## Install steps that worked

```bash
# 1. Fix the Ubuntu mirror (the Peru mirror was refusing connections)
sudo sed -i 's|http://pe.archive.ubuntu.com|http://archive.ubuntu.com|g' /etc/apt/sources.list.d/ubuntu.sources
sudo apt update && sudo apt upgrade -y

# 2. Give slow services more time to start (systemd drop-in overrides)
sudo mkdir -p /etc/systemd/system/wazuh-manager.service.d /etc/systemd/system/wazuh-indexer.service.d
printf "[Service]\nTimeoutStartSec=600\n"      | sudo tee /etc/systemd/system/wazuh-manager.service.d/override.conf
printf "[Service]\nTimeoutStartSec=infinity\n" | sudo tee /etc/systemd/system/wazuh-indexer.service.d/override.conf
sudo systemctl daemon-reload

# 3. Install inside tmux so an SSH drop can't kill it
tmux new -s wazuh
curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh && sudo bash ./wazuh-install.sh -a

# 4. Stop accidental Wazuh upgrades
sudo sed -i "s/^deb /#deb /" /etc/apt/sources.list.d/wazuh.list && sudo apt update
```

`-a` = all-in-one. The assistant uses [`config/config.yml`](../config/config.yml),
where every node is `127.0.0.1` because all three components share one host.

Then open **`https://<server-ip>`**. You must type `https://`. Log in as `admin`.

The installer creates `wazuh-install-files.tar`, which holds the cluster key,
certificates and **all passwords**. Keep it private and never upload it.
To see the passwords again:
```bash
sudo tar -O -xvf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt
```

## Recommendations during installation

- Run every long command inside **`tmux`**. Reattach with `tmux attach -t wazuh`.
- Add the **systemd timeout overrides before** running the installer. Otherwise
  a slow start makes the installer roll everything back.
- If the installer fails, **read the logs before running it again**:
  ```bash
  sudo journalctl -u <service> --no-pager | tail -n 30
  sudo grep -iE "error|fail" /var/log/wazuh-install.log | tail -n 30
  ```
- If a failed attempt left packages behind ("already installed"), clean up first:
  `sudo bash ./wazuh-install.sh -u` (see [troubleshooting #4](troubleshooting.md)).
- Take the snapshot **`wazuh-working`** as soon as the dashboard loads.

## Verify

```bash
systemctl is-active wazuh-indexer wazuh-manager wazuh-dashboard
sudo ss -tlnp | grep -E "443|9200|1514|1515"
```

See also: [Problems I hit and how I fixed them](troubleshooting.md) ·
[Daily operations](daily-operations.md)
