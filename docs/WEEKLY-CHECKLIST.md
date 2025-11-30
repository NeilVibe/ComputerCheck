# Weekly Health Check - Quick Checklist

**Print this and check off items every Sunday!**

---

## 📋 WEEKLY CHECKLIST

**Date: _______________**

### 1. System Health (1 min)
```bash
cd ~/CheckComputer && ./check.sh --quick --json | jq '.status'
```
- [ ] Status: ________________ (Expected: "healthy")

### 2. Explorer Handles (10 sec)
```bash
powershell.exe -NoProfile -Command "Get-Process explorer | Select-Object -First 1 Handles"
```
- [ ] Handles: _____________ (Normal: 1,000-2,500 | ⚠️ Warning: 3,500+)

### 3. Bloatware Check (30 sec)
```bash
powershell.exe -NoProfile -Command "Get-Service -Name 'ArmouryCrateService','LightingService','ROG Live Service','AsusUpdateCheck' -ErrorAction SilentlyContinue | Select-Object Name, Status, StartType | Format-Table"
```
- [ ] All services: **Stopped** and **Disabled** ✅
- [ ] Any Running? _____________ (Action: Disable again!)

### 4. Memory & CPU (15 sec)
```bash
./check.sh --quick --json | jq '.system'
```
- [ ] Memory: _________% (Normal: <75%)
- [ ] CPU: _________% (Normal: <30%)

### 5. Disk Usage (15 sec)
```bash
df -h | grep -E "/|/mnt/c|/mnt/e"
```
- [ ] Linux (/): _________% (Normal: <80%)
- [ ] Windows (C:): _________% (Normal: <80%)
- [ ] E: drive: _________% (Normal: <70%)

### 6. SSH Security (15 sec)
```bash
sudo ./check-ssh-security.sh
```
- [ ] Password auth: **OFF** ✅
- [ ] Attack attempts last 24h: _____________ (All blocked ✅)

### 7. Critical Events (20 sec)
```bash
powershell.exe -NoProfile -Command "Get-WinEvent -FilterHashtable @{LogName='System'; Level=1; StartTime=(Get-Date).AddHours(-24)} -MaxEvents 5 -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count"
```
- [ ] Event count: _____________ (Expected: 0)
- [ ] If >0, check: `Get-WinEvent -FilterHashtable @{LogName='System'; Level=1; StartTime=(Get-Date).AddHours(-24)} -MaxEvents 5`

### 8. Network Connections (15 sec)
```bash
sudo ss -tulnp | grep LISTEN | wc -l
```
- [ ] Listening ports: _____________ (Normal: 20-30)
- [ ] Any unusual ports? _____________

---

## ✅ PASS/FAIL

- [ ] **ALL CHECKS PASSED** - System healthy! ✅
- [ ] **ISSUES FOUND** - See notes below ⚠️

**Issues:**
```
_________________________________________________
_________________________________________________
```

**Actions Taken:**
```
_________________________________________________
_________________________________________________
```

---

## 🚨 QUICK REFERENCE - When to Worry

| Metric | Normal | Warning | Critical |
|--------|--------|---------|----------|
| Explorer Handles | 1,000-2,500 | 2,500-3,500 | >3,500 |
| Memory | <75% | 75-90% | >90% |
| CPU (sustained) | <30% | 30-70% | >85% |
| Disk | <80% | 80-90% | >90% |

---

## 💡 Common Issues & Quick Fixes

**High Explorer Handles (>3,500):**
```bash
taskkill /f /im explorer.exe && start explorer.exe
```

**Bloatware Re-enabled:**
```bash
powershell.exe -NoProfile -Command "Stop-Service -Name 'ServiceName' -Force; Set-Service -Name 'ServiceName' -StartupType Disabled"
```

**High Memory:**
```bash
# Find memory hogs
./check.sh --quick --json | jq '.top_memory_processes'
```

**Critical Events:**
```bash
# See what happened
powershell.exe -NoProfile -Command "Get-WinEvent -FilterHashtable @{LogName='System'; Level=1; StartTime=(Get-Date).AddHours(-24)} -MaxEvents 10 | Format-List"
```

---

**Time Required:** ~5 minutes
**Frequency:** Every Sunday morning
**Full Guide:** See MAINTENANCE-SCHEDULE.md

---

*Keep it simple. Check weekly. Stay healthy!*
