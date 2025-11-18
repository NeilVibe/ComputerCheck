# WSL Network Share Access Issue - 2025-11-18

## Problem Description

**User Issue:** After Windows Update, cannot access Ubuntu folder from Windows Explorer anymore.

**What Used to Work:**
- Could click and access `\\wsl$\Ubuntu\home\neil1988\` directly in Windows Explorer
- This allowed easy file browsing between Windows and WSL

**What Broke:**
- Windows Update changed WSL network sharing behavior
- Both `\\wsl$\Ubuntu` and `\\wsl.localhost\Ubuntu` paths return "cannot access"

## Current System State

**WSL Status:**
- ✅ WSL is running (this terminal is active)
- ✅ WSLService is running on Windows side
- ✅ WSLService StartType: Automatic
- ❌ Network share `\\wsl$\` is NOT being exposed

**WSL IP Address:** `172.28.150.120`

**Diagnostic Commands Used:**
```bash
# Check WSL service status
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-Service -Name 'WSLService' | Select-Object Name, Status, StartType"

# Result: Running, Automatic

# Test network paths
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Test-Path '\\wsl$\Ubuntu'"
# Result: False (doesn't exist)

/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Test-Path '\\wsl.localhost\Ubuntu'"
# Result: False (doesn't exist)
```

## Root Cause

Windows Update likely changed:
1. How WSLService exposes the network share
2. The service is running but not creating the `\\wsl$` or `\\wsl.localhost` paths
3. Common after major Windows updates (especially Win10→Win11 transitions)

## Proposed Solutions

### Solution 1: Restart WSLService (Quick Fix)
**Risk Level:** Low (5% chance terminals close, 95% fine)

**Command:**
```bash
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Restart-Service -Name 'WSLService' -Force"
```

**What This Does:**
- Restarts the Windows service that manages WSL
- Should recreate the `\\wsl$` network share
- **Does NOT intentionally restart WSL VM or terminals**
- Small chance Windows decides to restart entire WSL VM (rare)

**Verification After:**
```bash
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Test-Path '\\wsl.localhost\Ubuntu'"
# Should return: True
```

### Solution 2: Create Desktop Shortcut (Zero Risk)
**Risk Level:** None (no service restart)

**Command:**
```bash
# Creates shortcut on desktop pointing to WSL home folder
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\create-wsl-shortcut.ps1"
```

**What This Does:**
- Creates clickable shortcut on Windows desktop
- Points to `\\wsl$\Ubuntu\home\neil1988`
- No system changes, just creates a file
- Will work once network share is fixed (manually or after reboot)

### Solution 3: Map Network Drive (Alternative)
**Risk Level:** Low (no restart needed)

**Command:**
```bash
# Maps U: drive to Ubuntu home folder
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "net use U: '\\wsl$\Ubuntu\home\neil1988' /persistent:yes"
```

**What This Does:**
- Creates permanent U: drive in File Explorer
- Points directly to Ubuntu home folder
- Persists across reboots
- Only works if network share is accessible

### Solution 4: Wait for Full Reboot (Safest)
**Risk Level:** None (user controls timing)

**When to Use:**
- When ready to close all terminals
- Full system reboot will likely fix WSL networking
- Can verify after reboot if issue persists

## Alternative Workarounds (No Fix Needed)

### Access via File Explorer GUI
Some Windows versions expose WSL via:
```
File Explorer → Network → DESKTOP-[NAME] → Ubuntu
```
OR
```
File Explorer → This PC → Linux → Ubuntu
```

### Access from Windows to WSL (works now)
```bash
# From Windows PowerShell or CMD:
wsl ls /home/neil1988
wsl cat /home/neil1988/file.txt
wsl nano /home/neil1988/file.txt
```

### Access from WSL to Windows (works now)
```bash
# From WSL terminal:
cd /mnt/c/Users/MYCOM
ls /mnt/c/Users/MYCOM/Desktop
```

## Recovery If Terminals Crash

If terminals close unexpectedly:

1. **Open new WSL terminal:**
   - Start Menu → Ubuntu → Ubuntu (Terminal will reopen)
   - OR Windows Terminal → New Tab → Ubuntu

2. **Navigate back to project:**
   ```bash
   cd /mnt/c/Users/MYCOM/Desktop/CheckComputer
   ```

3. **Verify WSL is running:**
   ```bash
   pwd  # Should show current directory
   ls   # Should show project files
   ```

4. **Check if fix worked:**
   ```bash
   /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Test-Path '\\wsl.localhost\Ubuntu'"
   ```

5. **If still broken after restart, try:**
   ```bash
   # Check WSL service status
   /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-Service WSLService | Select-Object Status, StartType"

   # If stopped, start it
   /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Start-Service WSLService"
   ```

## Historical Context

**Previous WSL Issues in This Project:**
- 2025-11-16: SSH port forwarding broke after Windows update (fixed by recreating netsh portproxy)
- WSL IP changes after reboot (currently: 172.28.150.120)
- Windows Update tends to reset WSL-related configurations

**Related Files:**
- `docs/SSH-WSL-TROUBLESHOOTING.md` - SSH connection troubleshooting
- `docs/WSL-WINDOWS-INTEGRATION.md` - General WSL integration patterns
- `CLAUDE.md` - Main project documentation

## Decision Made

User chose: **Solution 1 (Restart WSLService)**
- Accepted small risk of terminal restart
- Documented everything first for recovery
- Will proceed with restart command

## Commands to Execute

```bash
# 1. Restart WSL Service
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Restart-Service -Name 'WSLService' -Force"

# 2. Wait 5 seconds
sleep 5

# 3. Verify network share is back
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Test-Path '\\wsl.localhost\Ubuntu'"

# Expected result: True
# If True: Open Windows Explorer and try \\wsl.localhost\Ubuntu\home\neil1988
# If False: Try full system reboot or alternative solutions
```

## Status

- **Date/Time:** 2025-11-18 (timestamp when issue occurred)
- **System:** Windows 11, WSL Ubuntu
- **Current State:** WSL running, network share broken
- **Action:** About to restart WSLService
- **Backup Plan:** Reopen terminal from Start Menu if closed

---

**Last Updated:** 2025-11-18
**Created By:** Claude Code troubleshooting session
**User:** neil1988
**Project:** CheckComputer Security Toolkit
