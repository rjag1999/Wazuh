# 0. Host preparation

_Nov 9–12, 2026, Phase 1 / Week 1_

The biggest problem in this lab wasn't Wazuh. It was the **Windows host**.
Check these points **before** you install anything.

## Lab environment

| Item | Value |
|---|---|
| Host | Lenovo IdeaPad (82LN), AMD Ryzen 5000-series laptop CPU, 14 GB RAM, Windows 11 Home |
| Hypervisor | VMware Workstation |
| Wazuh server VM | Ubuntu Server 24.04 LTS, 4 vCPU, 8 GB RAM, 100 GB disk, `100.100.100.130` |
| Windows endpoint VM ("RA") | Windows 10, 2 vCPU, 2.4 GB RAM, `100.100.100.131` |

## The real root cause: the Windows hypervisor under VMware

Symptoms inside the Ubuntu VM:
- `top` showed **~90% `sy`** (kernel) CPU and only ~6% user
- Load average **~39** on 4 vCPUs
- `systemctl daemon-reload` timed out and `watch` froze
- Wazuh services took **10–20× longer** than normal to start (1+ hour)

`systeminfo` on the host showed:
```
Virtualization-based security: Status: Running
Hyper-V Requirements: A hypervisor has been detected
```

When the Windows hypervisor is active (Memory Integrity, Virtual Machine
Platform or Windows Hypervisor Platform), VMware can't use the CPU's
virtualization directly and runs **on top of Hyper-V**, which makes every VM
operation expensive. Host RAM was also tight: only 3.4 GB of 14 GB was free.

### Fix applied on the host

1. Windows Security → Device security → Core isolation → **Memory integrity: Off**
2. Windows Features: uncheck **Virtual Machine Platform** and **Windows Hypervisor Platform**
3. Admin PowerShell:
   ```powershell
   bcdedit /set hypervisorlaunchtype off
   ```
4. Reboot.

**Verified:** `systeminfo` now shows `Virtualization-based security: Not enabled`
and lists the Hyper-V requirements, with no hypervisor detected. Free host RAM
went from **3.4 GB to 9.7 GB**, and Wazuh starts in **~7 minutes**.

> **Trade-off:** Memory Integrity is a host security feature, and WSL2 won't
> run while the hypervisor is off.
> **To undo:** `bcdedit /set hypervisorlaunchtype auto`, re-enable the features, reboot.

## Recommendations before installing

- [ ] **Check the host first.** Run `systeminfo` and confirm that
      "A hypervisor has been detected" does **not** appear before you use VMware or VirtualBox.
- [ ] **Budget RAM.** On a 14 GB host: Wazuh VM **6–8 GB**, Windows VM **2–3 GB**,
      and leave **at least 4 GB** for the host.
- [ ] **Exclude the VM folder** (`Documents\Virtual Machines`) from antivirus
      (McAfee) scanning.
- [ ] **Take a snapshot before every risky step:**
      `clean-ubuntu` → `wazuh-working` → `lab-baseline`.
