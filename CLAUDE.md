# CLAUDE.md - Project Tree Hub

```
 _______ ______ ______ ______   __  __ __  __ ____
|__   __|  ____|  ____|  ____| |  \/  |  \/  |  _ \
   | |  | |__  | |__  | |__    | \  / | \  / | |_) |
   | |  |  __| |  __| |  __|   | |\/| | |\/| |  _ <
   | |  | |    | |____| |____  | |  | | |  | | |_) |
   |_|  |_|    |______|______| |_|  |_|_|  |_|____/

   CheckComputer - AI-First Diagnostic Infrastructure
```

---

## Quick Reference

| Item | Value |
|------|-------|
| **Location** | `/home/neil1988/CheckComputer` |
| **Windows** | `\\wsl$\Ubuntu\home\neil1988\CheckComputer` |
| **Remote** | `git@github.com:NeilVibe/ComputerCheck.git` |

---

## Project Tree

```
CheckComputer/
│
├── CLAUDE.md ◄────────────── YOU ARE HERE (Hub)
│
├─── Core Docs
│    ├── README.md             # Project intro
│    ├── ROADMAP.md            # Dev roadmap + session logs
│    ├── INSTALL.md            # Setup guide
│    └── USAGE_GUIDE.md        # How to use
│
├─── Tools (Executable)
│    ├── check.sh              # Quick health check
│    ├── run.sh                # Unified tool runner
│    ├── tools.sh              # Tool discovery
│    ├── MegaManager.ps1       # Windows master controller
│    └── SecurityManager.ps1   # Security tools
│
├─── categories/               # PowerShell modules
│    ├── security/             # Registry audit, malware scan
│    ├── performance/          # Memory, handles, startup
│    ├── monitoring/           # Events, processes, USB
│    └── utilities/            # Drive check, services
│
├─── docs/                     # Reference docs (31 files)
│    ├── System Health         # UI freeze, handle leaks
│    ├── Security              # SSH, fail2ban, hardening
│    ├── Disk & Cleanup        # Space analysis, safe cleanup
│    └── WSL Integration       # Cross-platform guides
│
└─── archive/                  # Old/superseded docs
```

---

## Tools Tree

```
Tool Infrastructure
│
├─── Health Checks
│    ├── ./check.sh --quick --json    # Fast health (<5 sec)
│    ├── ./check.sh --all             # Comprehensive
│    └── ./tools.sh --list            # Discover all tools
│
├─── Windows Diagnostics (via run.sh)
│    ├── security comprehensive       # Full security scan
│    ├── security registry-audit      # Registry malware check
│    ├── performance memory           # Memory analysis
│    ├── performance handle-check     # Explorer handles
│    ├── monitoring dangerous-events  # Critical Event IDs
│    └── monitoring process-watch     # Suspicious processes
│
└─── Linux Tools
     ├── htop                          # Process viewer
     ├── ncdu                          # Disk analyzer
     ├── nethogs                       # Per-app bandwidth
     ├── iftop                         # Network traffic
     └── nmap                          # Security scanner
```

---

## Documentation Tree

```
docs/
│
├─── System Health
│    ├── MASTER-GUIDE-UI-FREEZE-FIX.md      # Bloatware removal
│    ├── SEARCHHOST-EXPLORER-HANDLE-LEAK.md # Handle leak fix
│    ├── MAINTENANCE-SCHEDULE.md            # Daily/weekly checks
│    └── WEEKLY-CHECKLIST.md                # Sunday routine
│
├─── Security
│    ├── SSH-FULLY-SECURED-2025-11-16.md    # SSH hardening
│    ├── FAIL2BAN-WSL-LIMITATION.md         # WSL limitation
│    └── SECURITY-EXPANSION-PLAN.md         # Future plans
│
├─── Disk & Cleanup
│    ├── DISK-CLEANUP-FINDINGS.md           # WSL analysis
│    └── SAFE-CLEANUP-RANKED.md             # What's safe
│
└─── WSL/Windows
     ├── WSL-WINDOWS-INTEGRATION.md         # Cross-platform
     ├── POWERSHELL-ADMIN-GUIDE.md          # Admin ops
     └── TERMINAL-COMMANDS-GUIDE.md         # Best practices
```

---

## Quick Commands Tree

```
Common Operations
│
├─── Health Check (5 min)
│    ├── ./check.sh --quick --json | jq '.status'
│    ├── powershell.exe "Get-Process explorer | Select Handles"
│    └── sudo ./check-ssh-security.sh
│
├─── Windows Diagnostics
│    ├── ./run.sh security comprehensive
│    ├── ./run.sh performance memory
│    └── ./run.sh monitoring dangerous-events
│
├─── Disk Space
│    ├── df -h                              # Linux space
│    ├── ncdu ~                             # Interactive browser
│    └── conda clean --all -y               # Clear conda cache
│
└─── Git Operations
     ├── git status
     ├── git add . && git commit -m "msg"
     └── git push
```

---

## Roadmap Tree

```
Development Status
│
├─── TIER 1: Infrastructure ✅ COMPLETE
│    ├── tools.sh (discovery)      ✅
│    ├── run.sh (unified runner)   ✅
│    ├── check.sh (health)         ✅
│    └── Famous packages           ✅ jq, htop, ncdu, nmap
│
├─── TIER 2: Core Features ⏳ IN PROGRESS
│    ├── monitor.sh                🔲 Linux monitoring
│    ├── Monitor.ps1               🔲 Windows monitoring
│    ├── Automated checks          🔲 Cron jobs
│    └── Dashboard                 🔲 Visual status
│
└─── TIER 3: Advanced 🔲 PLANNED
     ├── Historical tracking       🔲
     ├── Automated remediation     🔲
     └── Report generation         🔲
```

---

## Key Event IDs

| ID | Meaning |
|----|---------|
| 7011 | Service timeout |
| 7045 | New service installed |
| 4625 | Failed login (brute force) |
| 6008 | Unexpected shutdown |

---

## Important Notes

- **French system** - Windows logs may be in French
- **Run as Admin** - Many PowerShell ops need elevation
- **chmod after creating** - Make scripts executable
- **Password auth OFF** - SSH key-only (brute force blocked)

---

## Disk Cleanup History

| Date | Freed | Total |
|------|-------|-------|
| 2025-11-30 | 127 GB | pip, conda, Ghost backup |
| 2025-12-06 | 81 GB | conda cache, HF models, logs |
| **TOTAL** | **208 GB** | |

---

*Last Updated: 2025-12-06*
*Tree Hub Style - Quick navigation for Claude AI*
