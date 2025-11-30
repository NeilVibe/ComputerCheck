# CLAUDE.md - Project Hub

## Quick Reference

| Item | Value |
|------|-------|
| **Location** | `/home/neil1988/CheckComputer` |
| **Windows Access** | `\\wsl$\Ubuntu\home\neil1988\CheckComputer` |
| **Git Remote** | `git@github.com:NeilVibe/ComputerCheck.git` |

---

## Primary Tools

### Quick Health Check
```bash
./check.sh --quick --json | jq '.status'
```

### MegaManager (Windows diagnostics)
```bash
./run.sh security comprehensive      # Full security scan
./run.sh performance memory          # Memory analysis
./run.sh monitoring dangerous-events # Check suspicious events
```

### PowerShell from WSL
```bash
powershell.exe -NoProfile -Command "YOUR_COMMAND"
# Or for scripts:
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "\\wsl$\Ubuntu\home\neil1988\CheckComputer\SCRIPT.ps1"
```

---

## Documentation Index

### Core Docs (Root)
| File | Purpose |
|------|---------|
| README.md | Project introduction |
| ROADMAP.md | Development roadmap & session logs |
| INSTALL.md | Setup guide |
| USAGE_GUIDE.md | How to use tools |

### Reference Docs (`docs/`)

**System Health:**
- `MASTER-GUIDE-UI-FREEZE-FIX.md` - UI freeze fix (bloatware removal)
- `SEARCHHOST-EXPLORER-HANDLE-LEAK.md` - Handle leak pattern
- `MAINTENANCE-SCHEDULE.md` - Daily/weekly/monthly checks
- `WEEKLY-CHECKLIST.md` - Quick Sunday checklist

**Security:**
- `SSH-FULLY-SECURED-2025-11-16.md` - SSH hardening guide
- `FAIL2BAN-WSL-LIMITATION.md` - Why fail2ban doesn't work in WSL
- `SECURITY-EXPANSION-PLAN.md` - Future security features

**Disk & Cleanup:**
- `DISK-CLEANUP-FINDINGS.md` - WSL disk analysis
- `SAFE-CLEANUP-RANKED.md` - What's safe to delete

**WSL/Windows Integration:**
- `WSL-WINDOWS-INTEGRATION.md` - Cross-platform guide
- `WSL-WINDOWS-BRIDGE-STRATEGY.md` - For special Windows folders
- `POWERSHELL-ADMIN-GUIDE.md` - Admin operations
- `TERMINAL-COMMANDS-GUIDE.md` - Linux command best practices
- `SSH-WSL-TROUBLESHOOTING.md` - SSH connection issues

**Other:**
- `LINUX-MONITORING-TOOLS.md` - Available tools reference
- `KERNEL-DRIVERS-REFERENCE.md` - Driver troubleshooting
- `UI-LAG-FIX.md` - UI lag solutions

### Archive (`archive/`)
Old session reports, superseded docs, historical reference.

---

## Quick Commands

### Weekly Health Check (5 min)
```bash
# 1. System health
./check.sh --quick --json | jq '.status'

# 2. Explorer handles (should be 1,000-2,500)
powershell.exe -NoProfile -Command "Get-Process explorer | Select-Object Handles"

# 3. SSH security
sudo ./check-ssh-security.sh
```

### Common Diagnostics
```bash
# Check recent Windows errors
powershell.exe -NoProfile -Command "Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2,3; StartTime=(Get-Date).AddMinutes(-15)} | Select-Object TimeCreated, Message -First 5"

# Check service status
powershell.exe -NoProfile -Command "Get-Service -Name 'ServiceName' | Select-Object Status, StartType"

# Check disk space
df -h
```

### Fix Permissions
```bash
sudo chmod -R 755 ~/CheckComputer
sudo chmod +x ~/CheckComputer/*.sh
```

---

## Key Event IDs

| ID | Meaning |
|----|---------|
| 7011 | Service timeout (startup delay) |
| 7045 | New service installed |
| 4625 | Failed login (brute force) |
| 6008 | Unexpected shutdown |

---

## Project Structure

```
CheckComputer/
├── CLAUDE.md          # This file - HUB
├── README.md          # Project intro
├── ROADMAP.md         # Development roadmap
├── INSTALL.md         # Setup
├── USAGE_GUIDE.md     # Usage
├── docs/              # Reference documentation (31 files)
├── archive/           # Old/superseded docs
├── categories/        # PowerShell tool categories
│   ├── security/
│   ├── performance/
│   ├── monitoring/
│   └── utilities/
├── *.sh               # Bash infrastructure scripts
└── *.ps1              # PowerShell tools
```

---

## Important Notes

- **French system** - Windows logs may be in French
- **Run as Admin** - Many PowerShell operations need elevation
- **chmod after creating files** - Always make scripts executable
- **Password auth OFF** - SSH uses key-only (brute force impossible)

---

*Last Updated: 2025-11-30*
*Total Disk Cleanup: ~127GB freed (pip cache, old conda envs, Ghost backup)*
