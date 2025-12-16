# Work In Progress (WIP) Hub

**Purpose:** Track active tasks and Claude memory handoff
**Updated:** 2025-12-16

---

## Start Here

| Need | Go To |
|------|-------|
| **Last session state?** | [SESSION_CONTEXT.md](SESSION_CONTEXT.md) |
| **Known issues?** | [ISSUES_TO_FIX.md](ISSUES_TO_FIX.md) |
| **High-level roadmap?** | [../../ROADMAP.md](../../ROADMAP.md) |
| **Expansion priorities?** | [../PRIORITY-EXPANSION-LIST.md](../PRIORITY-EXPANSION-LIST.md) |

---

## Current Status

```
TIER 1: COMPLETE (2025-11-18)
├── tools.sh     ✅ Tool discovery
├── run.sh       ✅ Unified runner
├── check.sh     ✅ Health check
└── Packages     ✅ jq, htop, ncdu, psutil, nethogs, iftop, nmap

TIER 2: PLANNED
├── daily-check.sh    🔲 Auto morning checks
├── weekly-check.sh   🔲 Deep Sunday scan
├── snapshot.sh       🔲 Baseline comparison
└── status.sh         🔲 Visual dashboard
```

---

## Priority Queue

### NOW: Infrastructure Expansion

| Priority | Task | Status |
|----------|------|--------|
| P1 | daily-check.sh | 🔲 TODO |
| P1 | weekly-check.sh | 🔲 TODO |
| P1 | Cron automation | 🔲 TODO |
| P2 | snapshot.sh | 🔲 TODO |
| P2 | status.sh dashboard | 🔲 TODO |

### Active Issues

| Priority | Issue | Description |
|----------|-------|-------------|
| WARNING | Explorer handles | 4,003 (>3,500 threshold) |

---

## Document Index

### Active
| Doc | Purpose |
|-----|---------|
| [SESSION_CONTEXT.md](SESSION_CONTEXT.md) | Claude handoff state |
| [ISSUES_TO_FIX.md](ISSUES_TO_FIX.md) | Issue tracker |

### Reference
| Doc | Purpose |
|-----|---------|
| [../PRIORITY-EXPANSION-LIST.md](../PRIORITY-EXPANSION-LIST.md) | TIER 2 build order |
| [../SEARCHHOST-EXPLORER-HANDLE-LEAK.md](../SEARCHHOST-EXPLORER-HANDLE-LEAK.md) | Handle leak fix |
| [../MAINTENANCE-SCHEDULE.md](../MAINTENANCE-SCHEDULE.md) | Daily/weekly routines |

---

## Quick Commands

```bash
# Check system health
./check.sh --quick --json

# List available tools
./tools.sh --list

# Run specific tool
./run.sh security comprehensive
```

---

*Last Updated: 2025-12-16*
