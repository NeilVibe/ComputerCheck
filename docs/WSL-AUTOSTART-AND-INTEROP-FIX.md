# WSL Auto-Start & Interop Fix

**Created:** 2025-12-19 | **Status:** Complete | **Author:** Claude

---

## Overview

Two issues fixed:
1. **WSL not reliably starting on Windows boot** - Task was using `/bin/true` (exits immediately)
2. **WSL Interop breaking randomly** - Windows .exe files couldn't run from WSL

---

## Solution 1: Elegant WSL Startup Task

### The Problem
Old task action:
```
wsl.exe -d Ubuntu2 --exec /bin/true
```
This boots WSL, runs `true` (does nothing), exits. WSL might shut down before systemd fully initializes.

### The Fix
New task action:
```
C:\Users\MYCOM\wsl-startup.cmd
```

**Script contents** (`C:\Users\MYCOM\wsl-startup.cmd`):
```batch
@echo off
REM Elegant WSL startup - waits for systemd to fully initialize
REM SSH and other services auto-start via systemd
wsl.exe -d Ubuntu2 --exec /usr/bin/systemctl is-system-running --wait
```

**Why this works:**
- `systemctl is-system-running --wait` blocks until systemd reaches a stable state
- By the time it exits, SSH and all other systemd services are running
- Task returns success only after system is truly ready

### Task Configuration
| Setting | Value |
|---------|-------|
| Name | WSL-SSH-Startup |
| Trigger | At logon (MYCOM) |
| Delay | 10 seconds |
| Run Level | Highest |
| Action | `C:\Users\MYCOM\wsl-startup.cmd` |

### How to Modify
```powershell
# View current task
Get-ScheduledTask -TaskName "WSL-SSH-Startup" | Select-Object -ExpandProperty Actions

# Edit the script (no admin needed)
notepad C:\Users\MYCOM\wsl-startup.cmd

# Delete and recreate task (needs admin)
gsudo powershell -File C:\path\to\update-script.ps1
```

---

## Solution 2: Interop Auto-Fix Service

### The Problem
WSL interop (ability to run `.exe` files from Linux) sometimes breaks. The `WSLInterop` handler disappears from `/proc/sys/fs/binfmt_misc/`.

**Symptoms:**
```bash
$ cmd.exe /c echo test
/bin/bash: cmd.exe: cannot execute binary file: Exec format error
```

### The Fix
Systemd service that auto-registers the interop handler if missing.

**Service file** (`/etc/systemd/system/wsl-interop-fix.service`):
```ini
[Unit]
Description=Ensure WSL Interop is registered
After=systemd-binfmt.service
Before=multi-user.target

[Service]
Type=oneshot
ExecCondition=/bin/sh -c '[ ! -f /proc/sys/fs/binfmt_misc/WSLInterop ]'
ExecStart=/bin/sh -c 'echo ":WSLInterop:M::MZ::/init:PF" > /proc/sys/fs/binfmt_misc/register'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

**How it works:**
1. Runs at boot after `systemd-binfmt.service`
2. `ExecCondition` checks if WSLInterop is missing
3. If missing, registers the handler
4. If already exists, service skips (no-op)

### The Magic String Explained
```
:WSLInterop:M::MZ::/init:PF
```
| Part | Meaning |
|------|---------|
| `WSLInterop` | Handler name |
| `M` | Match by magic bytes |
| `MZ` | DOS/Windows executable magic bytes |
| `/init` | WSL's init handles execution |
| `PF` | Flags: Preserve argv[0], Fix binary |

### Manual Fix (if needed)
```bash
# Check if interop is working
cat /proc/sys/fs/binfmt_misc/WSLInterop

# Manual fix (if missing)
sudo sh -c 'echo ":WSLInterop:M::MZ::/init:PF" > /proc/sys/fs/binfmt_misc/register'

# Verify
cmd.exe /c echo "Interop working!"
```

---

## Files Created/Modified

| File | Location | Purpose |
|------|----------|---------|
| `wsl-startup.cmd` | `C:\Users\MYCOM\` | Startup script (waits for systemd) |
| `wsl-interop-fix.service` | `/etc/systemd/system/` | Auto-fix interop at boot |
| `WSL-SSH-Startup` | Task Scheduler | Triggers startup on logon |

---

## Verification Commands

```bash
# Check startup task
powershell.exe 'Get-ScheduledTask -TaskName "WSL-SSH-Startup" | Select-Object TaskName, State'

# Check interop service
systemctl status wsl-interop-fix.service
systemctl is-enabled wsl-interop-fix.service

# Check interop working
cat /proc/sys/fs/binfmt_misc/WSLInterop
cmd.exe /c echo "Works!"

# Check SSH running
systemctl status ssh
```

---

## Troubleshooting

### Task runs but SSH not accessible
1. Check systemd status: `systemctl is-system-running`
2. Check SSH: `systemctl status ssh`
3. Check if SSH is enabled: `systemctl is-enabled ssh`

### Interop still broken after boot
```bash
# Check service ran
journalctl -u wsl-interop-fix.service

# Manual fix
sudo systemctl start wsl-interop-fix.service
```

### Need to restart WSL remotely
**No `wsl --restart` exists.** Options:
1. From Windows: `wsl --shutdown` then `wsl -d Ubuntu2`
2. Restart LxssManager: `Restart-Service LxssManager`
3. Via scheduled task: Create a task that does shutdown+start

---

## Security Notes

- `wsl-startup.cmd` runs as user, not SYSTEM
- gsudo cache was disabled after task creation
- No credentials stored
- Temp scripts deleted after use

---

## Related Configs

**`/etc/wsl.conf`:**
```ini
[boot]
systemd=true

[interop]
enabled=true
appendWindowsPath=true
```

**SSH enabled in systemd:**
```bash
sudo systemctl enable ssh
```
