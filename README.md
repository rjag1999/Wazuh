# Wazuh Home Lab

A hands-on SIEM / XDR lab built with **Wazuh 4.14.10** in VMware Workstation:
one Ubuntu server running the full Wazuh stack and one Windows 10 endpoint
reporting to it as an agent.

## Lab topology

```
                         Internet
                            |
        VMware NAT - VMnet8 (100.100.100.0/24, gateway .2)
               _____________|_____________
              |                           |
   +----------+---------+      +----------+---------+
   | Ubuntu Server 24.04|      | Windows 10 ("RA")  |
   | hostname: alejo99  |      | agent: win-131     |
   | 4 vCPU / 8 GB RAM  |      | 2 vCPU / 2.4 GB    |
   | Wazuh all-in-one   |      | Wazuh agent        |
   |  - indexer  :9200  |      |                    |
   |  - manager  :1514/5|      |                    |
   |  - dashboard :443  |      |                    |
   +----------+---------+      +----------+---------+
     100.100.100.130 (ens33)      100.100.100.131
              |                           |
   Host-only - VMnet1 (200.200.200.0/24): second adapter, not used yet
```

| VM | Role | Adapter 1: NAT (VMnet8) | Adapter 2: Host-only (VMnet1) |
|----|------|------------------------|-------------------------------|
| Ubuntu Server 24.04 | Wazuh indexer + manager + dashboard | **100.100.100.130/24** | 200.200.200.0/24 (down) |
| Windows 10 "RA" | Endpoint with Wazuh agent `win-131` | **100.100.100.131/24** | 200.200.200.0/24 |

Host: Lenovo IdeaPad (AMD Ryzen 5000, 14 GB RAM, Windows 11 Home) with VMware Workstation.

## Documentation

| # | Topic | Status |
|---|-------|--------|
| 0 | [Host preparation (Hyper-V / VBS, RAM, snapshots)](docs/00-host-preparation.md) | ✅ Done |
| 1 | [Network setup](docs/01-network.md) | ✅ Done |
| 2 | [Wazuh server install + recommendations](docs/02-wazuh-server-install.md) | ✅ Done |
| 3 | [Windows agent enrollment](docs/03-windows-agent.md) | ✅ Done |
| 4 | [Dashboard TLS certificate fix](docs/04-dashboard-certificate.md) | ✅ Done |
| 5 | [File Integrity Monitoring on the Windows Desktop](docs/05-file-integrity-monitoring.md) | ⏳ Next |
| 6 | Sysmon on Windows + agent channel | 📋 Planned |
| ⚠️ | [**Problems I hit and how I fixed them**](docs/troubleshooting.md) | 📖 |
| 🛠️ | [Daily operations & useful commands](docs/daily-operations.md) | 📖 |

## Repository layout

```
config/config.yml               Node config used by the install assistant
scripts/fix-dashboard-cert.sh   Reissues the dashboard cert for the lab IP
docs/                           Step-by-step write-ups
```

> Secrets (`wazuh-install-files.tar`, passwords, private keys) are **not**
> stored here; see `.gitignore`.
