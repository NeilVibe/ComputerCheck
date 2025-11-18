# Complete Script Organization & Reference

**Purpose:** Master index of ALL scripts in CheckComputer toolkit
**Total Scripts:** 40+ tools organized by function
**Last Updated:** 2025-11-16

---

## Project Structure

```
CheckComputer/
├── 📁 Master Controllers
│   ├── MegaManager.ps1                    ← Main Windows security suite
│   └── SecurityManager.ps1                ← Simple security interface
│
├── 📁 Windows Performance & Diagnostics
│   ├── capture-freeze-state.ps1           ← System state snapshot tool
│   ├── check-ui-health.ps1                ← UI responsiveness checker
│   ├── diagnose-slowness.ps1              ← Performance diagnostic
│   └── check-dpc-latency.ps1              ← Kernel driver latency check
│
├── 📁 Windows Bloatware & Optimization
│   ├── disable-windows11-bloatware.ps1    ← Remove Windows 11 bloat
│   ├── disable-bloatware.ps1              ← General bloatware removal
│   ├── disable-nvidia-overlay.ps1         ← NVIDIA overlay disable
│   └── auto-fix-ui-freeze.ps1             ← Automatic UI freeze fix
│
├── 📁 Drive Management
│   ├── check-any-drive.ps1                ← Universal drive checker
│   ├── check-d-drive.ps1                  ← D drive specific check
│   ├── check-d-drive-handles.ps1          ← Drive handle detection
│   ├── check-d-drive-hidden-ties.ps1      ← Hidden Windows locks
│   └── release-d-drive.ps1                ← Release drive locks
│
├── 📁 Windows Customization
│   ├── restore-windows10-context-menu.ps1 ← Fix Windows 11 right-click
│   ├── toggle-kernel-driver.ps1           ← Manage kernel drivers
│   ├── toggle-vanguard.ps1                ← Toggle Riot Vanguard
│   └── install-ffmpeg.ps1                 ← FFmpeg installer
│
├── 📁 Linux/WSL Security & Monitoring
│   ├── check-ssh-security.sh              ← SSH security audit
│   ├── analyze-wsl-contents.sh            ← WSL disk analyzer
│   └── space-sniffer.sh                   ← Linux disk space tool
│
├── 📁 Archive (Not Used)
│   └── install-monitoring-tools.sh        ← ARCHIVED: Bulk installer (goes against anti-bloat philosophy)
│
├── 📁 Categories (Organized Tools)
│   ├── security/                          ← Security-focused scripts
│   │   ├── comprehensive-security-check.ps1
│   │   ├── registry-comprehensive-audit.ps1
│   │   ├── registry-startup-check.ps1
│   │   ├── deep-process-check.ps1
│   │   ├── system-file-monitor.ps1
│   │   ├── safe-event-monitor.ps1
│   │   └── check_security.ps1
│   ├── monitoring/                        ← Event/system monitoring
│   │   ├── dangerous-event-ids.ps1
│   │   ├── usb-device-monitor.ps1
│   │   ├── check-4104-events.ps1
│   │   ├── check-4104-simple.ps1
│   │   └── check-event-levels.ps1
│   ├── performance/                       ← Performance analysis
│   │   ├── memory-usage-check.ps1
│   │   └── check-vmmem.ps1
│   └── utilities/                         ← Utility scripts
│       ├── SecurityManager.ps1
│       ├── check-wsl-service.ps1
│       └── test-admin.ps1
│
└── 📁 Documentation
    ├── MASTER-GUIDE-UI-FREEZE-FIX.md      ← Complete UI freeze guide
    ├── SSH-FULLY-SECURED-2025-11-16.md    ← SSH security documentation
    ├── FAIL2BAN-EXPLAINED.md              ← fail2ban guide
    ├── LINUX-MONITORING-TOOLS.md          ← Linux tools reference
    ├── SECURITY-EXPANSION-PLAN.md         ← Future roadmap
    ├── ROADMAP.md                         ← Project roadmap
    └── CLAUDE.md                          ← Quick reference
```

---

## Scripts by Function

### 🔒 SECURITY MONITORING

| Script | Platform | Purpose | Usage |
|--------|----------|---------|-------|
| **MegaManager.ps1** | Windows | Master security controller | `.\MegaManager.ps1 security comprehensive` |
| **SecurityManager.ps1** | Windows | Simple security interface | `.\SecurityManager.ps1 scan-malware KOS` |
| **check-ssh-security.sh** | Linux | SSH security audit | `sudo ./check-ssh-security.sh` |
| **comprehensive-security-check.ps1** | Windows | Full Windows security scan | Via MegaManager |
| **registry-comprehensive-audit.ps1** | Windows | Registry health audit | Via MegaManager |
| **registry-startup-check.ps1** | Windows | Startup item scanner | Via MegaManager |
| **deep-process-check.ps1** | Windows | Process analysis | Via MegaManager |
| **system-file-monitor.ps1** | Windows | System file tampering | Via MegaManager |

---

### 📊 PERFORMANCE MONITORING

| Script | Platform | Purpose | Usage |
|--------|----------|---------|-------|
| **capture-freeze-state.ps1** | Windows | System snapshot tool | `.\capture-freeze-state.ps1` |
| **check-ui-health.ps1** | Windows | Explorer.exe health | `.\check-ui-health.ps1` |
| **diagnose-slowness.ps1** | Windows | Performance diagnostic | `.\diagnose-slowness.ps1` |
| **check-dpc-latency.ps1** | Windows | Kernel driver latency | `.\check-dpc-latency.ps1` |
| **memory-usage-check.ps1** | Windows | Memory analysis | Via MegaManager |
| **check-vmmem.ps1** | Windows | WSL memory usage | Via MegaManager |

---

### 🚨 EVENT MONITORING

| Script | Platform | Purpose | Usage |
|--------|----------|---------|-------|
| **dangerous-event-ids.ps1** | Windows | Critical Windows events | Via MegaManager |
| **usb-device-monitor.ps1** | Windows | USB device tracking | Via MegaManager |
| **safe-event-monitor.ps1** | Windows | Event log health check | Via MegaManager |
| **check-4104-events.ps1** | Windows | PowerShell event 4104 | Via MegaManager |
| **check-event-levels.ps1** | Windows | Event severity check | Via MegaManager |

---

### 🧹 BLOATWARE REMOVAL

| Script | Platform | Purpose | Usage |
|--------|----------|---------|-------|
| **disable-windows11-bloatware.ps1** | Windows 11 | Remove W11 bloat | `.\disable-windows11-bloatware.ps1` |
| **disable-bloatware.ps1** | Windows | General bloatware | `.\disable-bloatware.ps1` |
| **disable-nvidia-overlay.ps1** | Windows | NVIDIA overlay | `.\disable-nvidia-overlay.ps1` |
| **auto-fix-ui-freeze.ps1** | Windows | Auto UI freeze fix | `.\auto-fix-ui-freeze.ps1` |

---

### 💾 DISK/DRIVE MANAGEMENT

| Script | Platform | Purpose | Usage |
|--------|----------|---------|-------|
| **check-any-drive.ps1** | Windows | Universal drive check | `.\check-any-drive.ps1 D` |
| **check-d-drive.ps1** | Windows | D drive diagnostics | `.\check-d-drive.ps1` |
| **check-d-drive-handles.ps1** | Windows | Handle detection | `.\check-d-drive-handles.ps1` |
| **check-d-drive-hidden-ties.ps1** | Windows | Hidden Windows locks | `.\check-d-drive-hidden-ties.ps1` |
| **release-d-drive.ps1** | Windows | Release drive locks | `.\release-d-drive.ps1` |
| **analyze-wsl-contents.sh** | Linux | WSL disk analyzer | `./analyze-wsl-contents.sh` |
| **space-sniffer.sh** | Linux | Disk space tool | `./space-sniffer.sh` |

---

### ⚙️ SYSTEM CUSTOMIZATION

| Script | Platform | Purpose | Usage |
|--------|----------|---------|-------|
| **restore-windows10-context-menu.ps1** | Windows 11 | Fix right-click menu | `.\restore-windows10-context-menu.ps1 Restore` |
| **toggle-kernel-driver.ps1** | Windows | Driver management | `.\toggle-kernel-driver.ps1` |
| **toggle-vanguard.ps1** | Windows | Riot Vanguard toggle | `.\toggle-vanguard.ps1` |
| **install-ffmpeg.ps1** | Windows | FFmpeg installer | `.\install-ffmpeg.ps1` |
| **check-wsl-service.ps1** | Windows | WSL service check | `.\check-wsl-service.ps1` |

**Note:** install-monitoring-tools.sh was ARCHIVED (not used) - goes against anti-bloat philosophy. See archive/README-ARCHIVE.md

---

## Quick Reference by Use Case

### "My computer is freezing!"
1. `.\capture-freeze-state.ps1` - Capture current state
2. `.\check-ui-health.ps1` - Check Explorer.exe handles
3. `.\diagnose-slowness.ps1` - Full diagnostic
4. `.\disable-windows11-bloatware.ps1` - Remove bloatware (permanent fix)

### "Is my computer infected?"
1. `.\MegaManager.ps1 security comprehensive` - Full security scan
2. `.\SecurityManager.ps1 scan-malware` - Quick malware check
3. `.\MegaManager.ps1 security registry-audit` - Registry analysis

### "Check my SSH security"
1. `sudo ./check-ssh-security.sh` - Complete SSH audit
2. `sudo fail2ban-client status sshd` - Check banned IPs
3. `sudo grep "Failed" /var/log/auth.log | tail -20` - Recent attacks

### "My disk is full"
1. `.\check-any-drive.ps1 C` - Windows drive check
2. `./analyze-wsl-contents.sh` - Linux/WSL analysis
3. `ncdu /` - Interactive disk usage (Linux)

### "Check system performance"
1. `.\capture-freeze-state.ps1` - Complete snapshot
2. `.\MegaManager.ps1 performance memory` - Memory analysis
3. `glances` - Real-time monitoring (Linux)

### "Something attacked my server!"
1. `sudo ./check-ssh-security.sh` - SSH security check
2. `sudo fail2ban-client status sshd` - Banned attackers
3. `sudo grep "Failed" /var/log/auth.log | wc -l` - Count attacks

---

## Master Controllers Explained

### MegaManager.ps1 - The Swiss Army Knife

**What it does:** Controls ALL Windows security/performance tools

**Main Commands:**
```powershell
# Full security scan
.\MegaManager.ps1 security comprehensive

# Registry health audit
.\MegaManager.ps1 security registry-audit

# Memory analysis
.\MegaManager.ps1 performance memory

# Dangerous event check
.\MegaManager.ps1 monitoring dangerous-events

# List all tools
.\MegaManager.ps1 list

# Test all tools
.\MegaManager.ps1 test
```

**Categories:**
- Security: Malware, registry, processes
- Performance: Memory, CPU, disk
- Monitoring: Events, USB, system
- Utilities: Drive checks, services

---

### SecurityManager.ps1 - Simple Interface

**What it does:** Easy-to-use security scanner

**Commands:**
```powershell
# Scan for specific malware
.\SecurityManager.ps1 malware KOS

# Deep scan
.\SecurityManager.ps1 scan-malware KOS -Deep

# Quick security check
.\SecurityManager.ps1 scan
```

---

## Tool Chains (Common Workflows)

### Complete Security Audit
```bash
# Windows
.\MegaManager.ps1 security comprehensive
.\MegaManager.ps1 security registry-audit
.\capture-freeze-state.ps1

# Linux
sudo ./check-ssh-security.sh

# Review
# - Windows security report
# - SSH attack log
# - System snapshot
```

### Performance Investigation
```bash
# Capture baseline
.\capture-freeze-state.ps1

# Check specific issues
.\check-ui-health.ps1
.\diagnose-slowness.ps1
.\MegaManager.ps1 performance memory

# Monitor real-time
glances  # Linux
```

### Attack Response
```bash
# Immediate
sudo fail2ban-client status sshd
sudo grep "Failed" /var/log/auth.log | tail -50

# Analysis
sudo ./check-ssh-security.sh > attack-report.txt

# Review
cat attack-report.txt
```

---

## Installation & Setup

### Windows Tools (Already Have!)
All PowerShell scripts ready to use from CheckComputer directory

### Linux Monitoring Tools (Need to Install!)
```bash
# Run installer (creates this later)
./install-monitoring-tools.sh

# Or manual install
sudo apt install htop glances nethogs ncdu vnstat fail2ban -y
```

---

## Maintenance Schedule

### Daily (Optional):
```bash
# Quick check
glances --time 10  # Linux
```

### Weekly (Recommended):
```bash
# Windows
.\capture-freeze-state.ps1
Get-Process explorer | Select Name, Handles

# Linux
sudo ./check-ssh-security.sh
```

### Monthly:
```bash
# Full audit
.\MegaManager.ps1 security comprehensive
.\MegaManager.ps1 security registry-audit
sudo ./check-ssh-security.sh
```

### After Windows Updates:
```bash
# Check bloatware respawn
Get-Process | Where {$_.Name -like '*Widget*'}

# Re-run if needed
.\disable-windows11-bloatware.ps1
```

---

## Script Status Legend

| Status | Meaning |
|--------|---------|
| ✅ Active | Regular use, well-tested |
| 🔨 Tool | Utility, use as needed |
| 🎯 Diagnostic | Troubleshooting specific issues |
| 📊 Monitor | Continuous monitoring |
| 🧹 Maintenance | Cleanup/optimization |
| 🔧 Fix | Problem resolution |

---

## Future Scripts (Planned)

### Phase 2 - Linux Monitoring:
- `linux-security-monitor.sh` - Complete Linux security status
- `attack-analytics.sh` - SSH attack analysis with geo-IP
- `log-analyzer.sh` - System log parser
- `install-monitoring-tools.sh` - Auto-install Linux tools

### Phase 3 - Unified Dashboard:
- `unified-security-check.sh` - Windows + Linux + Network
- `security-dashboard.sh` - Complete infrastructure view
- `daily-health-report.sh` - Automated daily summary

### Phase 4 - Advanced:
- `geo-ip-mapper.sh` - Map attack sources
- `network-traffic-monitor.sh` - Bandwidth analysis
- `threat-intelligence.sh` - External threat feeds

---

## File Organization Best Practices

### Root Directory (Quick Access):
- Master controllers (MegaManager, SecurityManager)
- Most-used diagnostic tools
- UI freeze tools
- Drive management
- Linux security tools

### Categories Directory (Organized Tools):
- security/ - Security-focused scripts
- monitoring/ - Event monitoring
- performance/ - Performance tools
- utilities/ - Helper scripts

### Documentation Directory:
- Usage guides
- Troubleshooting docs
- Security reports
- Project documentation

---

## Quick Command Reference

### Most Used Commands:

```powershell
# Windows Security
.\MegaManager.ps1 security comprehensive
.\capture-freeze-state.ps1
.\disable-windows11-bloatware.ps1

# Linux Security
sudo ./check-ssh-security.sh
sudo fail2ban-client status sshd

# Performance
.\check-ui-health.ps1
glances

# Drive Management
.\check-any-drive.ps1 D
ncdu /
```

---

## Total Script Count

**Windows Scripts:** 35+
- PowerShell (.ps1): 32
- Bash for WSL (.sh): 3

**Linux Scripts:** 3 (check-ssh-security.sh, analyze-wsl-contents.sh, space-sniffer.sh)

**Archived Scripts:** 1 (install-monitoring-tools.sh - bulk installer, not used)

**Documentation:** 16+ markdown files

**Total Active Tools:** 38+ scripts
**Available Linux Packages (NOT installed):** 20+ tools documented as reference in LINUX-MONITORING-TOOLS.md

**Philosophy:** Keep it lean - only install tools when specific need identified, one at a time!

---

**Status:** Well-organized, documented, ready to expand!
**Next:** Add Linux monitoring tools, unified dashboard
**Vision:** Complete cross-platform infrastructure monitoring toolkit

---

Last Updated: 2025-11-17
Scripts Active: 38+ (lean and focused!)
Latest Change: ✅ Archived bulk installer (anti-bloat philosophy)
Approach: One tool at a time, only when needed, user approval required
Next: Build monitoring scripts using BUILT-IN tools (no new installs needed!)
