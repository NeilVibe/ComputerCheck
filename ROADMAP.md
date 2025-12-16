# Project Roadmap

**Updated:** 2025-12-16 | **Status:** TIER 1 Complete, TIER 2 Planned

---

## Mission

**AI-First Diagnostic Infrastructure** - Built FOR Claude AI CLI to diagnose and fix computer issues autonomously.

### Design Principles
1. **Parseable Output** - JSON, not pretty text
2. **Consistent Interface** - Same patterns across all tools
3. **Exit Codes** - Proper success/failure codes
4. **Self-Discovery** - `--help`, `--list` flags everywhere
5. **Fast Execution** - No scripts >30 seconds
6. **Dual Platform** - WSL + Windows seamless

---

## Current Status

### TIER 1: Infrastructure - COMPLETE

| Component | Status | Description |
|-----------|--------|-------------|
| tools.sh | Done | Tool discovery (17 tools) |
| run.sh | Done | Unified command runner |
| check.sh | Done | Health check (<5 sec, JSON) |
| Famous packages | Done | jq, htop, ncdu, psutil, nethogs, iftop, nmap |
| Documentation | Done | 31 docs, WIP structure |

### TIER 2: Automation - PLANNED

| Component | Status | Priority |
|-----------|--------|----------|
| daily-check.sh | TODO | P1 - High |
| weekly-check.sh | TODO | P1 - High |
| Cron automation | TODO | P1 - High |
| snapshot.sh | TODO | P2 - Medium |
| status.sh | TODO | P2 - Medium |
| Alerts | TODO | P2 - Medium |
| Historical tracking | TODO | P2 - Medium |

### TIER 3: Advanced - FUTURE

| Component | Status | Priority |
|-----------|--------|----------|
| monitor.sh (full) | TODO | P3 - Low |
| Monitor.ps1 (full) | TODO | P3 - Low |
| Report generator | TODO | P3 - Low |
| Auto-remediation | TODO | P3 - Low |

---

## Priority Build Order

See **[docs/PRIORITY-EXPANSION-LIST.md](docs/PRIORITY-EXPANSION-LIST.md)** for detailed build plan.

**Quick Summary:**
```
Week 1: daily-check.sh + cron
Week 2: weekly-check.sh + status.sh
Week 3: snapshot.sh baseline
Week 4: Alerts + historical
```

---

## Tool Inventory

### Shell Scripts (Linux)
| Script | Purpose |
|--------|---------|
| check.sh | Quick health check |
| run.sh | Unified tool runner |
| tools.sh | Tool discovery |
| check-ssh-security.sh | SSH audit |
| space-sniffer.sh | Disk analysis |
| analyze-wsl-contents.sh | WSL space |

### PowerShell Categories
```
categories/
├── security/      8 scripts
├── monitoring/    5 scripts
├── performance/   2 scripts
└── utilities/     3 scripts
```

### Famous Packages Installed
| Package | Version | Purpose |
|---------|---------|---------|
| jq | 1.6 | JSON parser |
| htop | 3.0.5 | Process viewer |
| ncdu | 1.15.1 | Disk browser |
| psutil | 7.1.3 | Python system stats |
| nethogs | 0.8.6 | Per-app bandwidth |
| iftop | 1.0~pre4 | Network traffic |
| nmap | 7.80 | Security scanner |

---

## Milestones Completed

| Date | Milestone |
|------|-----------|
| 2025-12-16 | WIP/SESSION structure, CLAUDE.md HUB rewrite |
| 2025-12-06 | 81GB disk cleanup, Tree Hub docs |
| 2025-11-30 | 127GB disk cleanup, docs reorganization |
| 2025-11-20 | Famous monitoring trio (nethogs, iftop, nmap) |
| 2025-11-18 | TIER 1 complete (tools.sh, run.sh, check.sh) |
| 2025-11-17 | fail2ban evaluation (abandoned - WSL limitation) |
| 2025-11-16 | SSH hardening, bloatware removal |

**Total Disk Freed:** 208 GB

---

## Session Logs

Session logs have moved to **[docs/wip/SESSION_CONTEXT.md](docs/wip/SESSION_CONTEXT.md)**.

This file now contains only roadmap and priorities.

---

## Links

| Doc | Purpose |
|-----|---------|
| [CLAUDE.md](CLAUDE.md) | Navigation hub |
| [docs/wip/SESSION_CONTEXT.md](docs/wip/SESSION_CONTEXT.md) | Session handoff |
| [docs/wip/ISSUES_TO_FIX.md](docs/wip/ISSUES_TO_FIX.md) | Issue tracker |
| [docs/PRIORITY-EXPANSION-LIST.md](docs/PRIORITY-EXPANSION-LIST.md) | TIER 2 build order |

---

*Last updated: 2025-12-16 - Cleaned up, session logs moved to WIP*
