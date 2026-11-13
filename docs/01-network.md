# 1. Network setup (VMware)

Each VM has two network adapters:

| Adapter | VMware network | Subnet | Use |
|---|---|---|---|
| 1 | **NAT** (VMnet8) | `100.100.100.0/24`, gateway `100.100.100.2` | Internet **and** lab traffic (agent ↔ manager, dashboard) |
| 2 | **Host-only** (VMnet1) | `200.200.200.0/24` | Reserved, not used yet |

| VM | Interface | IP |
|----|-----------|----|
| Ubuntu Server (`alejo99`) | `ens33` (NAT) | 100.100.100.130/24 |
| Ubuntu Server (`alejo99`) | `ens37` (host-only) | down |
| Windows 10 "RA" | NAT adapter | 100.100.100.131/24 |

> The VMware NAT subnet was changed from its default to `100.100.100.0/24`
> in **Edit → Virtual Network Editor → VMnet8**.

## Verify

Ubuntu:
```bash
ip -br addr          # ens33 shows 100.100.100.130/24
ip route             # default via 100.100.100.2 dev ens33
ping -c 3 100.100.100.131
```

Windows (PowerShell):
```powershell
ipconfig
Test-NetConnection 100.100.100.130 -Port 443    # dashboard
Test-NetConnection 100.100.100.130 -Port 1514   # agent events
```

> Windows Firewall blocks ICMP by default, so ping from Ubuntu to Windows
> may fail while everything else works.

## Ports used

| Port | Service |
|---|---|
| 443/tcp | Wazuh dashboard (HTTPS only, no port 80) |
| 9200/tcp | Wazuh indexer |
| 1514/tcp | Agent → manager events |
| 1515/tcp | Agent enrollment |
