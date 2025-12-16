# Priority Expansion List - Infrastructure Roadmap

## Quick Reference: What to Build Next

```
Priority Tiers:
  [P1] HIGH   - Do this week, big impact
  [P2] MEDIUM - Do this month, nice to have
  [P3] LOW    - Future, when bored
```

---

## [P1] HIGH PRIORITY - This Week

### 1. Daily Health Check Script (`daily-check.sh`)
**Why**: Catch problems before they become critical
**Effort**: 1 hour
**Value**: Prevents freezes, catches issues early

```bash
# What it checks:
- Explorer handles (freeze prevention)
- Disk space warnings (>85% used)
- Memory usage
- Critical Windows events (last 24h)
- SSH attack summary
```

**Output**: JSON summary + optional email/log

---

### 2. Weekly Maintenance Script (`weekly-check.sh`)
**Why**: Deeper checks that don't need to run daily
**Effort**: 2 hours
**Value**: Comprehensive health overview

```bash
# What it checks:
- Full registry audit (malware persistence)
- Service status (bloatware creep detection)
- Startup programs audit
- Conda/pip cache size
- Handle trends (compare to last week)
- Security event summary (7 days)
```

---

### 3. Cron Job Automation
**Why**: Checks run automatically, no manual work
**Effort**: 30 minutes
**Value**: Set and forget monitoring

```bash
# Suggested crontab:
0 9 * * * /home/neil1988/CheckComputer/daily-check.sh >> ~/logs/daily.log 2>&1
0 10 * * 0 /home/neil1988/CheckComputer/weekly-check.sh >> ~/logs/weekly.log 2>&1
```

---

### 4. Fix Explorer Handle Warning (NOW at 4,003!)
**Why**: You're in warning zone right now
**Effort**: 5 minutes
**Options**:
- Kill SearchHost (temporary fix)
- Disable Windows Search service (permanent)
- Accept weekly restarts

---

## [P2] MEDIUM PRIORITY - This Month

### 5. Baseline Snapshot System (`snapshot.sh`)
**Why**: Detect changes, catch new malware/services
**Effort**: 3 hours
**Value**: Security anomaly detection

```bash
./snapshot.sh save baseline.json      # Save current state
./snapshot.sh compare baseline.json   # What changed?

# Tracks:
- Running services
- Startup programs
- Registry run keys
- Scheduled tasks
- Installed software
```

---

### 6. Historical Metrics Storage
**Why**: Track trends over time
**Effort**: 2 hours
**Value**: See if handles/memory trending up

```
data/
├── metrics/
│   ├── 2025-12-16.json
│   ├── 2025-12-17.json
│   └── ...
└── reports/
    └── weekly-2025-12-16.json
```

---

### 7. Simple Dashboard (`status.sh`)
**Why**: Quick visual health overview
**Effort**: 1 hour
**Value**: Instant system status

```bash
./status.sh

╔══════════════════════════════════════╗
║         SYSTEM STATUS                ║
╠══════════════════════════════════════╣
║ Health:     [████████░░] 80% OK      ║
║ Handles:    4,003 ⚠️  (warn >3500)    ║
║ Memory:     27% ✅                    ║
║ Disk C:     48% ✅                    ║
║ Last Check: 2 hours ago              ║
╚══════════════════════════════════════╝
```

---

### 8. Alert System (Simple Version)
**Why**: Get notified when things go wrong
**Effort**: 2 hours
**Value**: Don't miss critical issues

```bash
# Options (pick one):
- Desktop notification (notify-send)
- Log file alert
- Email via sendmail (if configured)
- Discord/Telegram webhook (fancy)
```

---

## [P3] LOW PRIORITY - Future

### 9. monitor.sh (Full Linux Monitoring)
**Why**: Unified Linux-side monitoring
**Effort**: 4 hours
**Value**: Complete monitoring solution

```bash
./monitor.sh security ssh
./monitor.sh network bandwidth
./monitor.sh system disk
./monitor.sh windows explorer  # calls PowerShell
```

---

### 10. Monitor.ps1 (Full Windows Monitoring)
**Why**: Unified Windows-side monitoring
**Effort**: 4 hours
**Value**: Complete monitoring solution

---

### 11. Report Generator
**Why**: Professional health reports
**Effort**: 3 hours
**Value**: Documentation, audit trail

```bash
./report.sh weekly --format html > report.html
./report.sh monthly --format pdf > report.pdf
```

---

### 12. Auto-Remediation (Careful!)
**Why**: Auto-fix known issues
**Effort**: 5 hours
**Value**: Hands-off maintenance

```bash
./fix.sh --issue handle-leak    # Kill SearchHost
./fix.sh --issue bloatware      # Re-disable services
./fix.sh --issue disk-cache     # Clear caches
```

---

## Recommended Build Order

```
Week 1:
├── [P1] Fix Explorer handles (5 min)
├── [P1] daily-check.sh (1 hour)
└── [P1] Set up cron job (30 min)

Week 2:
├── [P1] weekly-check.sh (2 hours)
└── [P2] status.sh dashboard (1 hour)

Week 3:
├── [P2] snapshot.sh baseline (3 hours)
└── [P2] Historical storage (2 hours)

Week 4+:
├── [P2] Alert system (2 hours)
└── [P3] Full monitor.sh (4 hours)
```

---

## Daily Routine (After Building)

```
Morning (auto via cron):
├── daily-check.sh runs at 9 AM
├── Logs to ~/logs/daily.log
└── Alerts if issues found

Manual (when needed):
├── ./check.sh --quick --json     # Quick status
├── ./status.sh                   # Visual dashboard
└── ./run.sh security comprehensive  # Deep scan
```

---

## Weekly Routine (Sunday)

```
Automated:
├── weekly-check.sh runs at 10 AM Sunday
└── Logs to ~/logs/weekly.log

Manual Review:
├── Check logs for warnings
├── Review handle trends
├── Clear caches if needed (conda clean)
└── Git commit any changes
```

---

## Nice Tools to Add (Optional)

| Tool | Purpose | Install |
|------|---------|---------|
| **btop** | Prettier htop | `sudo apt install btop` |
| **duf** | Better df | `sudo apt install duf` |
| **gdu** | Fast ncdu | `sudo apt install gdu` |
| **bandwhich** | Per-process bandwidth | cargo install |
| **dust** | Better du | cargo install |

**Note**: Only add if you'll actually use them! No bloat.

---

## Quick Wins (Do Today)

1. **Kill SearchHost** - Drop handles from 4,003 to ~1,500
   ```powershell
   Stop-Process -Name "SearchHost" -Force
   ```

2. **Check bloatware status** - Make sure services stayed disabled
   ```bash
   ./run.sh security comprehensive
   ```

3. **Set up log directory**
   ```bash
   mkdir -p ~/logs
   ```

---

*Created: 2025-12-16*
*Purpose: Guide infrastructure expansion with clear priorities*
