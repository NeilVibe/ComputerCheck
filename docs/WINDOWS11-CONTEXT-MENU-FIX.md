# Windows 11 Right-Click Context Menu - Restore Windows 10 Classic Menu

**The Problem:** Windows 11's simplified context menu SUCKS. This guide shows you how to get the full Windows 10 menu back.

Last Updated: 2025-01-26

---

## Table of Contents

1. [The Problem Explained](#the-problem-explained)
2. [Quick Fix - Using Our Script](#quick-fix---using-our-script)
3. [Manual Registry Fix](#manual-registry-fix)
4. [Alternative Methods](#alternative-methods)
5. [Troubleshooting](#troubleshooting)
6. [How to Revert](#how-to-revert)

---

## The Problem Explained

### Windows 11 Changed the Right-Click Menu

Microsoft redesigned the context menu in Windows 11 to be "simpler" and "cleaner", but in reality it just HIDES all the useful options behind an extra click.

**Windows 10 Context Menu (What We Want):**
```
Right-click on a file:
┌─────────────────────────┐
│ Open                    │
│ Edit                    │
│ Print                   │
│ ───────────────────     │
│ Send to              ►  │
│ ───────────────────     │
│ Cut                     │
│ Copy                    │
│ Paste                   │
│ ───────────────────     │
│ Delete                  │
│ Rename                  │
│ ───────────────────     │
│ Properties              │
└─────────────────────────┘

ALL OPTIONS VISIBLE IMMEDIATELY!
```

**Windows 11 Context Menu (What You Have Now):**
```
Right-click on a file:
┌─────────────────────────┐
│ Open                    │
│ ───────────────────     │
│ Cut                     │
│ Copy                    │
│ Rename                  │
│ Share                   │
│ Delete                  │
│ ───────────────────     │
│ Show more options    ►  │ ← YOU HAVE TO CLICK THIS!
└─────────────────────────┘
        │
        └─→ THEN you get the full menu
```

**Why It's Annoying:**
- Extra click EVERY time you need common options
- Slower workflow
- Hidden options are hard to remember
- Third-party app context menu items are buried
- Power users hate it

---

## Quick Fix - Using Our Script

**Easiest method! We created a safe PowerShell script to automate this.**

### Step 1: Open PowerShell as Administrator

**Windows 11:**
1. Press `Win + X`
2. Select "Terminal (Admin)" or "PowerShell (Admin)"
3. Click "Yes" on UAC prompt

### Step 2: Check Current Status

```powershell
cd C:\Users\MYCOM\Desktop\CheckComputer
.\restore-windows10-context-menu.ps1 Status
```

This shows you which menu you're currently using.

### Step 3: Restore Windows 10 Menu

```powershell
.\restore-windows10-context-menu.ps1 Restore
```

**What it does:**
- Checks if you have admin rights
- Creates registry key: `HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32`
- Sets the default value to empty string
- Offers to restart File Explorer automatically

### Step 4: Test It!

Right-click any file - you should see the full Windows 10 menu immediately!

---

## Manual Registry Fix

**If you prefer to do it manually:**

### Method 1: Command Prompt (Fastest)

1. Open Command Prompt as Administrator
2. Run this command:

```cmd
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
```

3. Restart File Explorer:
```cmd
taskkill /f /im explorer.exe & start explorer.exe
```

### Method 2: PowerShell One-Liner

```powershell
New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Force -Value ""
Stop-Process -Name explorer -Force
```

### Method 3: Registry Editor (GUI)

1. Press `Win + R`, type `regedit`, press Enter
2. Navigate to: `HKEY_CURRENT_USER\Software\Classes\CLSID`
3. Right-click `CLSID` → New → Key
4. Name it: `{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}`
5. Right-click the new key → New → Key
6. Name it: `InprocServer32`
7. Double-click `(Default)` in the right pane
8. Leave "Value data" EMPTY (just click OK)
9. Restart File Explorer (Ctrl+Shift+Esc → File Explorer → Restart)

---

## Alternative Methods

### Method 1: Shift + Right-Click (Temporary)

**No registry modification needed!**

Hold `Shift` key while right-clicking → You get the full menu!

**Pros:**
- No system changes
- Works on all Windows 11 versions
- Completely safe

**Cons:**
- Must remember to hold Shift every time
- Extra step for every operation

### Method 2: ExplorerPatcher (Third-Party Tool)

**If the registry fix doesn't work (Windows 11 24H2+):**

ExplorerPatcher is an open-source tool that brings back Windows 10 features:

**Download:** https://github.com/valinet/ExplorerPatcher

**Features:**
- Restores classic context menu
- Restores Windows 10 taskbar
- Many other customization options

**Installation:**
1. Download `ep_setup.exe` from the GitHub releases page
2. Run the installer
3. File Explorer will restart automatically
4. Right-click the taskbar → Properties → Configure ExplorerPatcher
5. Under "File Explorer" → "Context menu" → Select "Windows 10"

**⚠️ Warnings:**
- Third-party software (use at your own risk)
- May conflict with antivirus software
- Requires updates when Windows updates
- More complex than registry fix

### Method 3: Windows Terminal (for files)

For some operations, you can use Windows Terminal:
```bash
# From Windows Terminal (doesn't help with GUI though)
explorer.exe .  # Opens File Explorer at current location
```

---

## Troubleshooting

### Issue 1: Registry Fix Doesn't Work

**Symptoms:** Applied fix but still seeing Windows 11 menu

**Solutions:**

1. **Make sure File Explorer restarted:**
   ```powershell
   taskkill /f /im explorer.exe
   Start-Sleep -Seconds 2
   start explorer.exe
   ```

2. **Check registry was actually created:**
   ```powershell
   Test-Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
   ```
   Should return `True`

3. **Reboot computer:**
   Some systems require a full reboot, not just Explorer restart

4. **Check Windows version:**
   ```powershell
   [System.Environment]::OSVersion.Version
   ```
   If Build ≥ 26100 (24H2), the registry fix may be deprecated

### Issue 2: File Explorer Won't Start After Fix

**Symptoms:** Black screen or no File Explorer after restart

**Solution:**
```powershell
# Open Task Manager (Ctrl+Shift+Esc)
# File → Run new task
# Type: explorer.exe
# Check "Create this task with administrative privileges"
# Click OK

# If that doesn't work, revert the fix:
# File → Run new task → Type: powershell
reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2" /f
taskkill /f /im explorer.exe & start explorer.exe
```

### Issue 3: "Access Denied" When Creating Registry Key

**Symptoms:** Script fails with permission error

**Solutions:**

1. **Verify running as Administrator:**
   ```powershell
   ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")
   ```
   Should return `True`

2. **Check UAC is not blocking:**
   - Press `Win + R`
   - Type: `UserAccountControlSettings`
   - Make sure UAC is not at the highest level

3. **Try from elevated Command Prompt instead:**
   ```cmd
   reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
   ```

### Issue 4: Works But Breaks After Windows Update

**Symptoms:** Menu restored but reverts after Windows updates

**Cause:** Windows updates may reset the registry key

**Solution:**

1. Re-run the script after major updates:
   ```powershell
   .\restore-windows10-context-menu.ps1 Restore
   ```

2. Or create a scheduled task to apply fix automatically:
   ```powershell
   # Run this as Administrator
   $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File C:\Users\MYCOM\Desktop\CheckComputer\restore-windows10-context-menu.ps1 Restore"
   $trigger = New-ScheduledTaskTrigger -AtLogOn
   Register-ScheduledTask -TaskName "RestoreWin10ContextMenu" -Action $action -Trigger $trigger -RunLevel Highest -Description "Restore Windows 10 context menu after updates"
   ```

---

## How to Revert

**If you want to go back to Windows 11 menu:**

### Using Our Script (Easiest)

```powershell
.\restore-windows10-context-menu.ps1 Revert
```

### Manual Method

**Command Prompt:**
```cmd
reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f
taskkill /f /im explorer.exe & start explorer.exe
```

**PowerShell:**
```powershell
Remove-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Recurse -Force
Stop-Process -Name explorer -Force
```

---

## Technical Details

### What This Registry Key Does

**Registry Path:**
```
HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32
```

**How It Works:**
- `{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}` is the CLSID for Windows 11's new context menu handler
- `InprocServer32` specifies the DLL that handles the context menu
- Setting the default value to **empty string** tells Windows "this DLL doesn't exist"
- Windows falls back to the legacy (Windows 10) context menu handler

**Why It's Safe:**
- Only modifies `HKEY_CURRENT_USER` (your user registry, not system-wide)
- Doesn't delete or modify system files
- Easily reversible
- Doesn't affect system stability

**Compatibility:**
- ✅ Windows 11 21H2
- ✅ Windows 11 22H2
- ✅ Windows 11 23H2
- ⚠️ Windows 11 24H2 (may be deprecated in future builds)

---

## From WSL (Bonus)

**Run from WSL terminal:**

```bash
# Check status
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\restore-windows10-context-menu.ps1" Status

# Restore Windows 10 menu (prompts for confirmation)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\restore-windows10-context-menu.ps1" Restore

# One-liner from WSL (needs elevation)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File C:\Users\MYCOM\Desktop\CheckComputer\restore-windows10-context-menu.ps1 Restore'"
```

---

## Quick Reference

### Restore Windows 10 Menu
```powershell
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
taskkill /f /im explorer.exe & start explorer.exe
```

### Revert to Windows 11 Menu
```powershell
reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f
taskkill /f /im explorer.exe & start explorer.exe
```

### Check Current Status
```powershell
if (Test-Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32") { "Windows 10 menu" } else { "Windows 11 menu" }
```

---

## Related Documentation

- [PowerShell Admin Guide](./POWERSHELL-ADMIN-GUIDE.md) - Learn about registry manipulation with admin rights
- [WSL-Windows Integration](./WSL-WINDOWS-INTEGRATION.md) - Run Windows commands from WSL
- [CLAUDE.md](../CLAUDE.md) - Quick reference for common operations

---

**Last Updated:** 2025-01-26
**Script Location:** `/restore-windows10-context-menu.ps1`
**Tested On:** Windows 11 21H2, 22H2, 23H2

**Note:** This modification only affects your user account (HKCU). Other users on the same computer will still have Windows 11 menu unless they apply the fix separately.
