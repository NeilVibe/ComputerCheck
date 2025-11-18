# Git Push Issue & Linux Migration Guide

**Created:** 2025-11-18
**Status:** Commits ready, cannot push from Windows location

---

## 🚨 Current Issue

### **Problem:**
Cannot push commits to GitHub from Windows location (`/mnt/c/Users/MYCOM/Desktop/CheckComputer`)

### **Root Cause:**
1. Git remote URL uses HTTPS with expired token
2. Cannot modify `.git/config` from WSL due to Windows file permissions
3. Git not installed in Windows PowerShell (only in WSL)

### **What's Committed (Ready to Push):**
```bash
5bd7214 Add disk analyzer and comprehensive test suite
9e8dc96 Add TIER 1 Claude CLI infrastructure: tools.sh, run.sh, check.sh
778d476 Add AI-first infrastructure plan with package requirements and build strategy
```

**These 3 commits are SAFE** - committed locally, just need to push!

---

## ✅ Solution: Move to Linux Location

### **NO Git Re-init Needed!**
- Just copy the entire folder (includes `.git/`)
- Update remote URL
- Push!

### **What Needs to Change:**

#### **1. Paths in Scripts (4 files):**

**Files to update:**
- `tools.sh`
- `run.sh`
- `check.sh`
- `analyze.sh`

**Change this line in each:**
```bash
# Before:
PROJECT_ROOT="/mnt/c/Users/MYCOM/Desktop/CheckComputer"

# After:
PROJECT_ROOT="/home/neil1988/CheckComputer"
```

**That's it!** Just 1 line per file.

#### **2. PowerShell Script Paths:**
PowerShell scripts in `categories/` will still work! They use relative paths.

Example: This will still work from Linux location:
```bash
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "\\wsl$\Ubuntu\home\neil1988\CheckComputer\categories\security\deep-process-check.ps1"
```

---

## 📋 Migration Steps

### **Step 1: Copy Project to Linux**
```bash
# From WSL
cp -r /mnt/c/Users/MYCOM/Desktop/CheckComputer ~/CheckComputer
cd ~/CheckComputer
```

### **Step 2: Update Paths in 4 Scripts**
```bash
# Edit these files:
nano tools.sh          # Line 16: PROJECT_ROOT="/home/neil1988/CheckComputer"
nano run.sh            # Line 10: PROJECT_ROOT="/home/neil1988/CheckComputer"
nano check.sh          # (No PROJECT_ROOT, uses POWERSHELL_CMD directly - OK!)
nano analyze.sh        # (No PROJECT_ROOT - OK!)
```

Actually, only **2 files** need updating! (tools.sh and run.sh)

### **Step 3: Fix Git Remote**
```bash
# Switch from HTTPS to SSH
git remote set-url origin git@github.com:NeilVibe/ComputerCheck.git

# Verify
git remote -v
# Should show: git@github.com:NeilVibe/ComputerCheck.git
```

### **Step 4: Push!**
```bash
git push origin main
```

### **Step 5: Test Everything**
```bash
./tools.sh --count
./check.sh --quick --json | jq '.status'
./run.sh performance memory-usage-check
```

---

## 🔧 Alternative: Quick Fix Without Moving

If you want to stay on Windows Desktop:

### **Manual Fix:**
1. Open file: `C:\Users\MYCOM\Desktop\CheckComputer\.git\config`
2. Find line (around line 7-10):
   ```
   url = https://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@github.com/NeilVibe/ComputerCheck.git
   ```
3. Replace with:
   ```
   url = git@github.com:NeilVibe/ComputerCheck.git
   ```
4. Save file
5. From WSL: `git push origin main`

**This works** but you may hit permission issues again later!

---

## 📊 What Changes After Migration

| Aspect | Before (Windows) | After (Linux) |
|--------|------------------|---------------|
| **Project Path** | `/mnt/c/Users/MYCOM/Desktop/CheckComputer` | `/home/neil1988/CheckComputer` |
| **Access from Windows** | `C:\Users\MYCOM\Desktop\CheckComputer` | `\\wsl$\Ubuntu\home\neil1988\CheckComputer` |
| **Git operations** | 🔄 Sometimes fails (permissions) | ✅ Always works |
| **PowerShell scripts** | ✅ Work | ✅ Still work (same commands!) |
| **Speed** | 🐌 Slower | 🚀 Faster |
| **Permissions** | ❌ WSL can't modify some files | ✅ Full control |

---

## ❓ FAQ

### **Q: Will I lose my commits?**
**A:** NO! Copying the folder includes `.git/` folder with all commits.

### **Q: Do I need to re-initialize git?**
**A:** NO! Just copy folder and update remote URL.

### **Q: Will PowerShell scripts stop working?**
**A:** NO! They use absolute paths to PowerShell executable and will work from anywhere.

### **Q: Can I still access from Windows?**
**A:** YES! Use `\\wsl$\Ubuntu\home\neil1988\CheckComputer` in Windows Explorer.

### **Q: What if I want to merge later?**
**A:** No merging needed! You're just moving the same repo to a different location.

### **Q: Will the infrastructure tools still work?**
**A:** YES! After updating 2 paths in tools.sh and run.sh, everything works perfectly.

---

## 🎯 What We Built Today (Ready to Push!)

### **TIER 1 Infrastructure:**
1. ✅ **tools.sh** - Tool discovery system (JSON output)
2. ✅ **run.sh** - Unified command runner
3. ✅ **check.sh** - Quick health check (psutil + ss + network)
4. ✅ **analyze.sh** - Disk analyzer (ncdu + psutil)
5. ✅ **test-all.sh** - Comprehensive test suite

### **Famous Tools Integrated:**
- ✅ **psutil** (10M+ downloads/month) - System stats
- ✅ **jq** - JSON parser
- ✅ **ncdu** - Disk analyzer
- ✅ **ss** - Network tool
- ✅ **du** - Disk usage

### **Features:**
- 100% JSON output for AI parsing
- Cross-platform (WSL + Windows)
- NO ACTIONS - read-only checks
- Proper exit codes
- Full documentation

---

## 📝 Current Status

**Committed Locally:** ✅ 3 commits ready
**Pushed to GitHub:** ❌ Cannot push (git remote issue)
**Solution:** Move to Linux OR manually edit .git/config
**All Tools Working:** ✅ Tested and operational
**Next Session:** Push commits after migration!

---

**Last Updated:** 2025-11-18
