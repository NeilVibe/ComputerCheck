# Issues To Fix

**Updated:** 2025-12-16

---

## Summary

| Priority | Count |
|----------|-------|
| CRITICAL | 0 |
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 2 |

---

## Active Issues

### MEDIUM Priority

#### ISSUE-001: Explorer Handle Leak
**Status:** KNOWN - MONITORING
**Component:** Windows / SearchHost
**Description:** Explorer.exe handles accumulate over time due to SearchHost process leak.

**Current:** 4,003 handles (warning threshold: 3,500)

**Workaround:**
```powershell
Stop-Process -Name "SearchHost" -Force
```

**Permanent Fix Options:**
1. Disable Windows Search service (loses Start Menu search)
2. Weekly maintenance restart
3. Accept and monitor

**Reference:** [SEARCHHOST-EXPLORER-HANDLE-LEAK.md](../SEARCHHOST-EXPLORER-HANDLE-LEAK.md)

---

### LOW Priority

#### ISSUE-002: TIER 2 Scripts Not Built
**Status:** PLANNED
**Description:** daily-check.sh, weekly-check.sh, snapshot.sh not yet created.

**Reference:** [PRIORITY-EXPANSION-LIST.md](../PRIORITY-EXPANSION-LIST.md)

---

#### ISSUE-003: No Automated Monitoring
**Status:** PLANNED
**Description:** No cron jobs set up for automated health checks.

**Solution:** Set up crontab after building daily/weekly scripts.

---

## Resolved Issues

| ID | Description | Resolved |
|----|-------------|----------|
| - | SSH brute force attacks | 2025-11-16 (password auth disabled) |
| - | Windows UI freeze | 2025-11-16 (bloatware disabled) |
| - | Disk space (405GB WSL) | 2025-12-06 (208GB freed) |

---

## Issue Template

```markdown
#### ISSUE-XXX: Title
**Status:** NEW / IN PROGRESS / MONITORING / RESOLVED
**Priority:** CRITICAL / HIGH / MEDIUM / LOW
**Component:** Area affected
**Description:** What's wrong

**Steps to Reproduce:**
1. Step 1
2. Step 2

**Workaround:** (if any)

**Fix:** (when found)
```

---

*Last Updated: 2025-12-16*
