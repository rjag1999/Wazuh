# 2. Wazuh server: all-in-one install

Installed on 2026-11-11 on Ubuntu Server (`alejo99`, 100.100.100.130) with the
official installation assistant. Version: **4.14.10**.

## Steps

```bash
curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh
sudo bash ./wazuh-install.sh -a        # -a = all-in-one (indexer + server + dashboard)
```

The assistant uses [`config/config.yml`](../config/config.yml). All three
components run on the same host, so every node uses `127.0.0.1`.

When it finishes it prints the **admin** password and creates
`wazuh-install-files.tar`, which contains the cluster key, certificates and
all passwords. Keep this file private and **never** upload it.

To see the passwords later:
```bash
sudo tar -O -xvf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt
```

## Verify

```bash
sudo systemctl status wazuh-indexer wazuh-manager wazuh-dashboard
```

Dashboard: **https://100.100.100.130**, user `admin`.
