# Daily & Weekly Maintenance Schedule

**Clear, step-by-step checklist to keep your system healthy and prevent issues from creeping back.**

---

## 🌅 **DAILY CHECKS (5 minutes)**

**Goal:** Quick health snapshot, catch critical issues early

### 1. **Quick Health Check** (30 seconds)

```bash
cd ~/CheckComputer
./check.sh --quick --json
```

**What to look for:**
- ✅ `"status": "healthy"` - You're good!
- ⚠️ `"status": "warning"` - Check warnings array
- 🚨 `"status": "critical"` - Check errors array immediately

**Thresholds:**
- **Explorer handles**: Normal: 1,000-2,500 | Warning: 2,500-3,500 | Critical: 3,500+
- **Memory**: Normal: <75% | Warning: 75-90% | Critical: >90%
- **Disk**: Normal: <80% | Warning: 80-90% | Critical: >90%

### 2. **Check Explorer Handles** (10 seconds)

```bash
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-Process explorer | Select-Object Name, Handles"
```

**Expected:** 1,000-2,500 handles

**Action if >3,500:**
- Restart Explorer: `taskkill /f /im explorer.exe && start explorer.exe`
- Check for bloatware re-enabling (see Weekly Check #3)

### 3. **Check for Critical Events** (15 seconds)

```bash
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-WinEvent -FilterHashtable @{LogName='System','Application'; Level=1; StartTime=(Get-Date).AddHours(-24)} -MaxEvents 5 -ErrorAction SilentlyContinue | Select-Object TimeCreated, Id, ProviderName, Message | Format-List"
```

**What to look for:**
- ❌ **No events** = Perfect!
- ⚠️ **Event ID 7011** = Service timeout (check which service)
- 🚨 **Event ID 6008** = Unexpected shutdown (check what caused it)
- 🚨 **Event ID 1116** = Malware detected (run full scan!)

### 4. **SSH Security Quick Check** (10 seconds)

```bash
sudo ./check-ssh-security.sh
```

**Expected:**
- ✅ Password authentication: OFF
- ✅ Root login: disabled
- ✅ SSH service: running

**If attacks detected:**
- Normal: 100-500 attempts/day (all blocked if password auth OFF)
- High: 1,000+ attempts/day (check if key-only auth is enforced)

---

## 📅 **WEEKLY CHECKS (15-20 minutes)**

**Goal:** Comprehensive health review, prevent bloatware creep

**Best time:** Sunday morning (fresh start for the week!)

### 1. **Full System Health** (1 minute)

```bash
cd ~/CheckComputer
./check.sh --quick --json | jq '.'
```

Review all sections:
- System metrics (handles, memory, CPU)
- Disk usage on all drives
- Network connections
- Top memory processes
- Recent critical events

**Save baseline:**
```bash
./check.sh --quick --json > ~/health-baseline-$(date +%Y-%m-%d).json
```

### 2. **Memory Analysis** (2 minutes)

```bash
./run.sh performance memory-usage-check
```

**What to check:**
- Top 10 memory consumers
- Any unusual processes (unknown names, suspicious paths)
- vmmem.exe usage (WSL memory - should be <8GB normally)

**Action if issues:**
- Identify bloatware processes
- Stop/disable unnecessary services

### 3. **Bloatware Status Check** (5 minutes)

**Critical: Check if bloatware re-enabled itself!**

```bash
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-Service -Name 'ArmouryCrateService','LightingService','ROG Live Service','AsusUpdateCheck','CrossEX Live Checker','Interezen_service','HPPrintScanDoctorService' -ErrorAction SilentlyContinue | Select-Object Name, Status, StartType | Format-Table"
```

**Expected:** All should be **Stopped** and **Disabled**

**If any are Running/Automatic:**
```bash
# Disable them again (one at a time)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Stop-Service -Name 'ServiceName' -Force; Set-Service -Name 'ServiceName' -StartupType Disabled"
```

**Also check Windows 11 bloatware:**
```bash
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-Process -Name 'WidgetService','PhoneExperienceHost','SearchHost' -ErrorAction SilentlyContinue | Select-Object Name, Handles"
```

**Expected:** None running (or very low handles if they exist)

### 4. **Startup Programs Audit** (3 minutes)

```bash
./run.sh security registry-startup-check
```

**What to look for:**
- Banking software conflicts (multiple security programs)
- Korean software remnants (CrossEX, wizvera, ipinside, NIASpeedMeter)
- Unknown/suspicious programs

**Clean registry if needed:**
```bash
# Example: Remove specific entry
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Remove-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run' -Name 'ProgramName' -ErrorAction SilentlyContinue"
```

### 5. **SSH Attack Review** (2 minutes)

```bash
# Check attack statistics (last 7 days)
sudo grep "Failed password" /var/log/auth.log | tail -100

# Count unique attacker IPs (last 24 hours)
sudo grep "Failed password" /var/log/auth.log | grep "$(date +%b\ %e)" | awk '{print $11}' | sort | uniq | wc -l
```

**Expected:**
- Zero successful logins (all blocked)
- 50-500 attack attempts/day is normal
- 1,000+ attempts = high activity (but still safe if password auth OFF)

**Verify security:**
```bash
sudo grep "PasswordAuthentication" /etc/ssh/sshd_config
```
**Must show:** `PasswordAuthentication no`

### 6. **Disk Space Review** (2 minutes)

```bash
# Overall disk usage
df -h | grep -E "Filesystem|/dev/sd|/mnt/c|/mnt/d|/mnt/e"

# WSL ext4.vhdx size on Windows
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-ChildItem 'E:\Ubuntu\UbuntuWSL\ext4.vhdx' | Select-Object FullName, @{N='SizeGB';E={[math]::Round(\$_.Length/1GB,2)}}"
```

**Thresholds:**
- WSL ext4.vhdx: Currently 405GB (43% of E: drive)
- Warning if >450GB (48%)
- Critical if >500GB (53%)

**If space issues:**
```bash
# Use ncdu to find large directories
ncdu /home/neil1988
```

### 7. **Network Connections Audit** (2 minutes)

```bash
# See all listening ports
sudo ss -tulnp

# Check for suspicious established connections
sudo ss -tunp | grep ESTAB
```

**What to look for:**
- Expected: SSH (22), HTTP (80/443), DNS (53)
- Unexpected: Unknown high ports, connections to unknown IPs
- Suspicious: Connections from unfamiliar processes

### 8. **Windows Update Impact Check** (1 minute)

**Check if Windows Update re-enabled bloatware:**

```bash
# Check last Windows Update
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 5 HotFixID, Description, InstalledOn"
```

**If update installed in last 7 days:**
- Re-check bloatware services (step 3)
- Re-check Explorer handles (step 2 from Daily)
- Re-verify registry startup items (step 4)

---

## 🗓️ **MONTHLY CHECKS (30-45 minutes)**

**Goal:** Deep-dive security audit, comprehensive system review

**Best time:** First Sunday of the month

### 1. **Comprehensive Registry Audit** (10 minutes)

```bash
./run.sh security registry-comprehensive-audit
```

**Review all sections:**
- Startup locations (HKLM, HKCU, Run, RunOnce)
- Shell modifications
- Winlogon changes
- Browser helper objects
- Scheduled tasks
- System policy changes

**Action items:**
- Document all unknown entries
- Remove confirmed bloatware/malware entries
- Baseline for next month's comparison

### 2. **Deep Security Scan** (5 minutes)

```bash
./run.sh security comprehensive-security-check
```

**Comprehensive check:**
- Process analysis (all running processes)
- Service analysis (all services)
- Network connections (all ports)
- Recent event log review (7 days)

### 3. **System File Integrity Check** (5 minutes)

```bash
./run.sh security system-file-monitor
```

**What it checks:**
- Critical Windows system files
- Unexpected modifications
- Suspicious file changes

### 4. **USB/Hardware Security Audit** (2 minutes)

```bash
./run.sh monitoring usb-device-monitor
```

**Review:**
- All USB devices connected in last 30 days
- Unknown/unauthorized devices
- Suspicious hardware changes

### 5. **Performance Baseline Update** (5 minutes)

```bash
# Capture comprehensive baseline
cd ~/CheckComputer
./check.sh --quick --json > ~/baselines/monthly-$(date +%Y-%m).json

# Compare to last month
diff ~/baselines/monthly-$(date -d "last month" +%Y-%m).json ~/baselines/monthly-$(date +%Y-%m).json
```

**Analyze trends:**
- Explorer handles (increasing = bloatware creeping back)
- Memory usage (increasing = memory leak or bloat)
- Disk usage (increasing = need cleanup)
- Network connections (new ports = investigate)

### 6. **Package/Tool Audit** (5 minutes)

**Review installed Linux packages:**
```bash
# Check if we installed any new packages
dpkg -l | grep -E "jq|htop|ncdu|nethogs|iftop|nmap"
```

**Expected (ONLY THESE!):**
- jq (1.6) - JSON parser
- htop (3.0.5) - Process viewer
- ncdu (1.15.1) - Disk analyzer
- nethogs (0.8.6) - Bandwidth monitor
- iftop (1.0~pre4) - Network traffic
- nmap (7.80) - Security scanner

**If anything else installed:**
- Review if you actually use it (last 30 days)
- Remove if unused: `sudo apt remove package-name`
- Fight bloat!

### 7. **SSH Log Deep Dive** (5 minutes)

```bash
# Full month attack statistics
sudo journalctl -u ssh --since "30 days ago" | grep "Failed password" | wc -l

# Top 10 attacker IPs this month
sudo journalctl -u ssh --since "30 days ago" | grep "Failed password" | awk '{print $11}' | sort | uniq -c | sort -rn | head -10

# Check for any successful logins (should be ZERO from unknown IPs!)
sudo grep "Accepted publickey" /var/log/auth.log | grep -v "172.28"
```

**Expected:**
- Thousands of failed attempts (all blocked)
- Zero successful logins from external IPs
- All your logins should be from 172.28.x.x (WSL internal IP)

### 8. **Documentation Update** (3 minutes)

**Update your notes:**
```bash
# Add notes to monthly log
echo "Monthly Check - $(date +%Y-%m-%d)" >> ~/monthly-checks.log
echo "Explorer handles: [current value]" >> ~/monthly-checks.log
echo "Memory usage: [current %]" >> ~/monthly-checks.log
echo "Disk usage: [current GB]" >> ~/monthly-checks.log
echo "New issues found: [list any]" >> ~/monthly-checks.log
echo "Actions taken: [list fixes]" >> ~/monthly-checks.log
echo "---" >> ~/monthly-checks.log
```

---

## 🚨 **CRITICAL THRESHOLDS - When to Act Immediately**

### Explorer.exe Handles
- **Normal:** 1,000-2,500
- **Elevated:** 2,500-3,500 (monitor closely)
- **Warning:** 3,500-4,500 (restart Explorer soon)
- **CRITICAL:** 4,500+ (UI freeze imminent - restart NOW!)

### Memory Usage
- **Normal:** <75%
- **High:** 75-85% (check what's using memory)
- **Warning:** 85-90% (close unnecessary programs)
- **CRITICAL:** >90% (system instability likely)

### Disk Usage
- **Normal:** <80%
- **High:** 80-85% (plan cleanup)
- **Warning:** 85-90% (cleanup required)
- **CRITICAL:** >90% (system may fail)

### CPU Usage (Sustained)
- **Normal:** 0-30% (idle/light use)
- **Active:** 30-70% (normal workload)
- **High:** 70-85% (check what's running)
- **CRITICAL:** 85-100% for >5 minutes (find culprit)

### SSH Attack Rate
- **Low:** <100 attempts/hour
- **Normal:** 100-500 attempts/hour
- **High:** 500-1,000 attempts/hour
- **Attack:** 1,000+ attempts/hour (verify key-only auth enabled!)

**Note:** Any attack rate is safe if password authentication is disabled (it is!)

---

## 📋 **QUICK COMMAND REFERENCE**

### Most Common Commands

```bash
# Daily health check
cd ~/CheckComputer && ./check.sh --quick --json

# Check Explorer handles
powershell.exe -NoProfile -Command "Get-Process explorer | Select-Object Handles"

# Check bloatware services
powershell.exe -NoProfile -Command "Get-Service -Name 'ArmouryCrateService','LightingService','WidgetService' | Select-Object Name, Status, StartType"

# SSH security status
sudo ./check-ssh-security.sh

# Disk usage
df -h | grep -E "/|/mnt/c|/mnt/e"

# Network connections
sudo ss -tulnp | grep LISTEN

# Recent critical events
powershell.exe -NoProfile -Command "Get-WinEvent -FilterHashtable @{LogName='System'; Level=1; StartTime=(Get-Date).AddHours(-24)} -MaxEvents 10"
```

---

## 🎯 **WEEKLY CHECKLIST (Print/Save)**

**Date: _______________**

- [ ] Health check passed (status: healthy)
- [ ] Explorer handles: _______ (normal: 1,000-2,500)
- [ ] Memory usage: _______% (normal: <75%)
- [ ] CPU usage: _______% (normal: <30%)
- [ ] Disk usage: _______% (normal: <80%)
- [ ] Bloatware services: All disabled
- [ ] Windows 11 bloat: Not running or low handles
- [ ] Startup registry: Clean (no suspicious entries)
- [ ] SSH security: Password auth OFF, attacks blocked
- [ ] Attack rate: _______ attempts/hour
- [ ] Network connections: All expected
- [ ] Windows Update installed: Yes / No
  - If Yes: Re-checked bloatware (all disabled)
- [ ] Baseline saved: `~/health-baseline-$(date).json`

**Issues found:**
```
_________________________________________________
_________________________________________________
_________________________________________________
```

**Actions taken:**
```
_________________________________________________
_________________________________________________
_________________________________________________
```

---

## 🛡️ **PREVENTION TIPS**

1. **Never install unknown software** - Even "free utilities" can be bloatware
2. **Review Windows Updates** - They sometimes re-enable services
3. **Check after system restarts** - Bloatware might auto-start
4. **One tool per problem** - Don't accumulate "just in case" tools
5. **Weekly discipline** - 15 minutes every Sunday prevents hours of troubleshooting
6. **Keep baselines** - Compare month-to-month to spot trends
7. **Trust the thresholds** - Numbers don't lie, act when limits exceeded

---

**Last Updated:** 2025-11-20
**Version:** 1.0

*Remember: Consistent small checks prevent big problems!*
