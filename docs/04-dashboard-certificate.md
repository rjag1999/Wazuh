# 4. Dashboard TLS certificate fix

## Problem

The all-in-one install used `127.0.0.1` for every node, so the dashboard
certificate wasn't valid for **100.100.100.130**. Browsers on the Windows VM
showed a certificate error.

## Fix

[`scripts/fix-dashboard-cert.sh`](../scripts/fix-dashboard-cert.sh) issues a
new dashboard certificate signed by the existing Wazuh root CA, with these
Subject Alternative Names:

- `IP:100.100.100.130`, `IP:127.0.0.1`
- `DNS:wazuh-dashboard`, `DNS:<hostname>`

The certificate is valid for 825 days. The script:
1. Extracts the root CA from `wazuh-install-files.tar` into a temporary folder
   and deletes it afterwards.
2. Backs up the current certs to `/etc/wazuh-dashboard/certs.bak-<timestamp>`.
3. Signs the new cert, installs it, restarts `wazuh-dashboard` and verifies it.
4. Copies the public `root-ca.crt` to the user's home for the Windows client.

```bash
sudo bash scripts/fix-dashboard-cert.sh
```

## Trust the CA on Windows (PowerShell as Administrator)

```powershell
Import-Certificate -FilePath .\root-ca.crt -CertStoreLocation Cert:\LocalMachine\Root
```

## Result

The certificate verifies for 100.100.100.130. Some browsers still showed
"Not secure", which is acceptable for this lab.

Roll back:
```bash
sudo cp -a /etc/wazuh-dashboard/certs.bak-<timestamp>/. /etc/wazuh-dashboard/certs/
sudo systemctl restart wazuh-dashboard
```
