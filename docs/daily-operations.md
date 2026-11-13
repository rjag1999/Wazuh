# Daily operations

## After boot

Wazuh needs about **7 minutes** to come up. Startup order matters:
**indexer (9200) → manager → dashboard (443)**.

```bash
watch -n 30 'sudo ss -tlnp | grep -E "443|9200"'
```

When both ports show up, open **https://100.100.100.130**.

## Quick health check

```bash
systemctl is-active wazuh-indexer wazuh-manager wazuh-dashboard
top -bn1 | head -5          # "sy" (kernel CPU) should stay low
```

## Shutting down

Shut the Ubuntu VM down cleanly, not by closing VMware:
```bash
sudo shutdown now
```

## Useful commands

| Purpose | Command |
|---|---|
| Service status | `systemctl is-active wazuh-indexer wazuh-manager wazuh-dashboard` |
| Ports listening | `sudo ss -tlnp \| grep -E "443\|9200\|1514\|1515"` |
| Indexer log | `sudo tail -n 30 /var/log/wazuh-indexer/wazuh-cluster.log` |
| Manager log | `sudo tail -n 30 /var/ossec/logs/ossec.log` |
| Dashboard log | `sudo journalctl -u wazuh-dashboard --no-pager \| tail -n 20` |
| Connected agents | `sudo /var/ossec/bin/agent_control -l` |
| CPU / RAM check | `top -bn1 \| head -5` · `free -h` |
| Uninstall Wazuh | `sudo bash ./wazuh-install.sh -u` |

## Snapshots

`clean-ubuntu` → `wazuh-working` → `lab-baseline`. Take one before every risky change.
