# 1. Network setup (VMware)

Each VM has **two network adapters**:

1. **NAT**: gives the VM internet access (package downloads, updates).
2. **Host-only**: a private network between the VMs and the host, with static IPs.

| VM | Host-only IP | Mask |
|----|--------------|------|
| Ubuntu Server (`alejo99`) | 100.100.100.130 | /24 (255.255.255.0) |
| Windows 10 | 100.100.100.131 | /24 (255.255.255.0) |

No gateway is set on the host-only adapter. The default route stays on the NAT adapter.

## Verify

Ubuntu:
```bash
ip -br addr          # host-only NIC shows 100.100.100.130/24
ping -c 3 100.100.100.131
```

Windows (PowerShell):
```powershell
ipconfig             # host-only adapter shows 100.100.100.131
Test-NetConnection 100.100.100.130 -Port 443
```

> Windows Firewall blocks ICMP by default, so ping from Ubuntu to Windows
> may fail while everything else works.
