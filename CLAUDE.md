# CLAUDE.md - CheckComputer Navigation Hub

**Version:** 2512161430 | **Status:** TIER 1 Complete | **Health:** WARNING (handles)

> **KEEP THIS FILE COMPACT.** Only essential info here. Details go in linked docs.

---

## Quick Navigation

| Need | Go To |
|------|-------|
| **Current task?** | [ROADMAP.md](ROADMAP.md) |
| **Last session context?** | [docs/wip/SESSION_CONTEXT.md](docs/wip/SESSION_CONTEXT.md) |
| **Known issues?** | [docs/wip/ISSUES_TO_FIX.md](docs/wip/ISSUES_TO_FIX.md) |
| **Expansion priorities?** | [docs/PRIORITY-EXPANSION-LIST.md](docs/PRIORITY-EXPANSION-LIST.md) |
| **All WIP docs?** | [docs/wip/README.md](docs/wip/README.md) |

---

## Glossary

| Term | Meaning |
|------|---------|
| **RM** | ROADMAP.md - global priorities |
| **WIP** | docs/wip/*.md - active task files |
| **TIER 1** | Infrastructure (tools.sh, run.sh, check.sh) - COMPLETE |
| **TIER 2** | Automation (daily/weekly checks, cron) - PLANNED |
| **TIER 3** | Advanced (reports, remediation) - FUTURE |
| **Handles** | Explorer.exe handle count (>3500 = warning, >5000 = critical) |

---

## Architecture

**Dual Platform: WSL Ubuntu + Windows PowerShell**

```
CheckComputer/
├── Shell Scripts (Linux)     PowerShell Scripts (Windows)
│   ├── check.sh         ──→  ├── MegaManager.ps1
│   ├── run.sh                ├── SecurityManager.ps1
│   └── tools.sh              └── categories/*.ps1
│
└── Cross-Platform Bridge
    └── run.sh calls PowerShell via /mnt/c/Windows/.../powershell.exe
```

| Linux Tools | Windows Tools |
|-------------|---------------|
| Disk analysis (ncdu) | Registry audit |
| Network (ss, nethogs) | Services, events |
| SSH security | Explorer handles |
| System stats (htop) | Process monitoring |

---

## Critical Rules

### 1. No Bloat Policy
```
NEVER install packages "just in case"
ONLY install when specific need identified
DELETE unused tools
```

### 2. JSON Output for AI
All tools should output JSON when possible for AI parsing.
```bash
./check.sh --quick --json | jq '.status'
```

### 3. Read-Only First
Check and report before taking any action.
```
CHECK → REPORT → (user approves) → FIX
```

### 4. French System Warning
Windows Event logs may be in French. Account for this in parsing.

### 5. Admin Required
Many PowerShell operations need elevation. Use `gsudo` or run as admin.

---

## Quick Commands

```bash
# Health check (< 5 sec)
./check.sh --quick --json

# List all tools
./tools.sh --list

# Run specific tool
./run.sh security comprehensive
./run.sh performance memory
./run.sh monitoring dangerous-events

# Check Explorer handles
powershell.exe "Get-Process explorer | Select Handles"

# Kill SearchHost (fix handle leak)
powershell.exe "Stop-Process -Name 'SearchHost' -Force"
```

---

## Tool Categories

```
categories/
├── security/      8 scripts (registry, malware, processes)
├── monitoring/    5 scripts (events, USB, dangerous IDs)
├── performance/   2 scripts (memory, vmmem)
└── utilities/     3 scripts (WSL, admin, services)
```

**Discovery:** `./tools.sh --list`

---

## Key Thresholds

| Metric | OK | Warning | Critical |
|--------|-----|---------|----------|
| Explorer handles | <3,500 | 3,500-5,000 | >5,000 |
| Memory % | <75% | 75-90% | >90% |
| Disk % | <80% | 80-90% | >90% |

---

## New Session Checklist

1. **Read session context:** [docs/wip/SESSION_CONTEXT.md](docs/wip/SESSION_CONTEXT.md)
2. **Quick health check:** `./check.sh --quick --json`
3. **Check issues:** [docs/wip/ISSUES_TO_FIX.md](docs/wip/ISSUES_TO_FIX.md)
4. **Check roadmap:** [ROADMAP.md](ROADMAP.md)
5. **Ask user** what to work on

---

## Key Paths

| Item | Path |
|------|------|
| **Project** | `/home/neil1988/CheckComputer` |
| **Windows** | `\\wsl$\Ubuntu\home\neil1988\CheckComputer` |
| **GitHub** | `git@github.com:NeilVibe/ComputerCheck.git` |

---

## Documentation Map

```
docs/
├── wip/                      # Work in progress
│   ├── SESSION_CONTEXT.md    # ← Claude memory handoff
│   ├── ISSUES_TO_FIX.md      # ← Bug tracker
│   └── README.md             # ← WIP index
├── PRIORITY-EXPANSION-LIST.md # ← TIER 2 build order
├── MAINTENANCE-SCHEDULE.md    # Daily/weekly routines
├── SEARCHHOST-EXPLORER-HANDLE-LEAK.md  # Handle fix
└── ... (31 reference docs)
```

---

## Stats

- **Tools:** 17 PowerShell + 10 Shell scripts
- **Packages:** jq, htop, ncdu, psutil, nethogs, iftop, nmap
- **Disk Freed:** 208 GB (cleanup Nov-Dec 2025)
- **Docs:** 31 in docs/, 3 in wip/

---

*Last updated: 2025-12-16 | Hub file - details live in linked docs*
