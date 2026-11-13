# 3. Windows agent enrollment

Windows 10 VM (100.100.100.131) enrolled as agent **`win-131`**.

## Install (PowerShell as Administrator)

```powershell
Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.14.10-1.msi `
  -OutFile $env:TEMP\wazuh-agent.msi
msiexec.exe /i $env:TEMP\wazuh-agent.msi /q `
  WAZUH_MANAGER="100.100.100.130" WAZUH_AGENT_NAME="win-131"
NET START WazuhSvc
```

You can also generate this command from the dashboard:
**Agents management → Summary → Deploy new agent**.

## Verify

- Dashboard → **Agents**: `win-131` shows status **Active**.
- On the manager: `sudo /var/ossec/bin/agent_control -l`
- On Windows: `Get-Service WazuhSvc`

Agent config file: `C:\Program Files (x86)\ossec-agent\ossec.conf`
