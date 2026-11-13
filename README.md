# Wazuh Home Lab

A hands-on SIEM / XDR lab built with **Wazuh 4.14.10** in VMware Workstation:
one Ubuntu server running the full Wazuh stack and one Windows 10 endpoint
reporting to it as an agent.

## Lab topology

```
                     Internet
                        |
                  VMware NAT (DHCP)
               _________|_________
              |                   |
   +----------+---------+  +------+-------------+
   | Ubuntu Server 24.04|  | Windows 10 client  |
   | hostname: alejo99  |  | agent: win-131     |
   | Wazuh all-in-one   |  | Wazuh agent        |
   |  - indexer         |  |                    |
   |  - manager         |  |                    |
   |  - dashboard :443  |  |                    |
   +----------+---------+  +------+-------------+
              | 100.100.100.130   | 100.100.100.131
              |___________________|
               VMware host-only network
                 100.100.100.0/24
```

| VM | Role | NIC 1 | NIC 2 (host-only) |
|----|------|-------|-------------------|
| Ubuntu Server | Wazuh indexer + manager + dashboard | NAT (internet) | 100.100.100.130/24 |
| Windows 10 | Endpoint with Wazuh agent `win-131` | NAT (internet) | 100.100.100.131/24 |

Agent ↔ manager traffic (ports 1514/1515 TCP) and dashboard access
(https://100.100.100.130) use the host-only network.

## Documentation

| # | Topic | Status |
|---|-------|--------|
| 1 | [Network setup](docs/01-network.md) | ✅ Done |
| 2 | [Wazuh server install (all-in-one)](docs/02-wazuh-server-install.md) | ✅ Done |
| 3 | [Windows agent enrollment](docs/03-windows-agent.md) | ✅ Done |
| 4 | [Dashboard TLS certificate fix](docs/04-dashboard-certificate.md) | ✅ Done |
| 5 | [File Integrity Monitoring on the Windows Desktop](docs/05-file-integrity-monitoring.md) | ⏳ Next |

## Repository layout

```
config/config.yml               Node config used by the install assistant
scripts/fix-dashboard-cert.sh   Reissues the dashboard cert for the lab IP
docs/                           Step-by-step write-ups
```

> Secrets (`wazuh-install-files.tar`, passwords, private keys) are **not**
> stored here; see `.gitignore`.
