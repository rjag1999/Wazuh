# Problems I hit and how I fixed them

| # | Symptom | Root cause | Fix |
|---|---|---|---|
| 1 | Re-running the installer: "Wazuh manager already installed" | A first attempt failed halfway and left packages behind | Clean up, then reinstall (see #4) |
| 2 | `ERROR: wazuh-manager could not be started`, then the installer rolled everything back | systemd start **timeout**: the manager was still starting when systemd gave up | `TimeoutStartSec=600` override for the manager |
| 3 | `apt` errors: "Failed to fetch pe.archive.ubuntu.com" | The local Ubuntu mirror was refusing connections | Switched to `archive.ubuntu.com` |
| 4 | Uninstall: "Wazuh indexer package could not be removed" | SSH disconnected during the rollback, leaving the package half-removed | `dpkg --configure -a`, `apt-get purge`, `dpkg --purge`, delete leftover folders, reboot |
| 5 | SSH session died mid-install (`client_loop: send disconnect`) | Long install plus an unstable SSH session | Run long jobs inside `tmux` |
| 6 | Browser: `ERR_CONNECTION_REFUSED` | Typed the IP without `https://`, so Chrome tried port 80 | Always use `https://<ip>` (the dashboard only listens on 443) |
| 7 | After reboot: indexer `failed (Result: timeout)`, nothing on port 443 | The indexer took 15–20+ min to start and hit the systemd timeout; the dashboard can't serve without it | `TimeoutStartSec=infinity` for the indexer |
| 8 | `daemon-reload` timed out, `watch` froze, load average **39** | **Root cause of everything:** `top` showed **90% `sy`** (kernel) CPU | Windows hypervisor (VBS / Hyper-V) under VMware, see [host preparation](00-host-preparation.md) |
| 9 | Browser certificate error for `100.100.100.130` | The all-in-one cert was issued for `127.0.0.1` only | Reissued the dashboard cert, see [doc 4](04-dashboard-certificate.md) |

## Cleaning up a half-removed install (#4)

```bash
sudo bash ./wazuh-install.sh -u            # try the official uninstall first
sudo dpkg --configure -a
sudo apt-get purge -y wazuh-indexer wazuh-manager wazuh-dashboard filebeat
sudo dpkg --purge wazuh-indexer            # if apt still can't remove it
sudo rm -rf /var/lib/wazuh-indexer /usr/share/wazuh-indexer /etc/wazuh-indexer \
            /var/ossec /etc/wazuh-dashboard /usr/share/wazuh-dashboard
sudo reboot
```

## Diagnosing a slow VM (#8)

```bash
top -bn1 | head -5     # %Cpu(s): if "sy" is much higher than "us", look at the host
uptime                 # load average far above the vCPU count means trouble
free -h
```
