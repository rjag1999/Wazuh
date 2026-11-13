# 5. File Integrity Monitoring (FIM): Windows Desktop

**Status: next step**

Goal: alert in real time when files on `C:\Users\Clientew10\Desktop` are
created, modified or deleted, and show what changed.

## Plan

1. On Windows, open Notepad **as Administrator** and edit
   `C:\Program Files (x86)\ossec-agent\ossec.conf`.
2. Inside the `<syscheck>` block, add:
   ```xml
   <directories realtime="yes" report_changes="yes">C:\Users\Clientew10\Desktop</directories>
   ```
3. Restart the agent (PowerShell as Administrator):
   ```powershell
   Restart-Service WazuhSvc
   ```
4. Test: create, edit and delete a `.txt` file on the Desktop.
5. Check: Dashboard → **File Integrity Monitoring** → agent `win-131` → Events.

_Results and screenshots will be added here once completed._
