# Windows 11 Context Menu Fix - Manual REGEDIT Steps

**The EXACT Registry Editor (regedit) method to restore Windows 10 right-click menu**

---

## 🎯 Two Methods Available

### Method 1: HKCU (Current User Only) - Recommended
Changes only affect YOUR user account. Other users keep Windows 11 menu.

### Method 2: HKLM (All Users - System-wide) - Advanced
Changes affect ALL users on the computer. Requires admin rights and taking ownership.

**Most people should use Method 1 (HKCU)**

---

## Method 1: HKCU Registry Edit (Per-User)

### Step 1: Open Registry Editor

1. Press `Win + R` to open Run dialog
2. Type: `regedit`
3. Press `Enter`
4. Click `Yes` on UAC prompt (if shown)

**⚠️ IMPORTANT:** Do NOT run regedit as Administrator if you're logged in as a regular user. Run it normally - the change needs to be in HKEY_CURRENT_USER, not an elevated admin context.

---

### Step 2: Navigate to CLSID

In Registry Editor, navigate to:

```
HKEY_CURRENT_USER\Software\Classes\CLSID
```

**How to navigate:**
- In the left pane, expand `HKEY_CURRENT_USER`
- Expand `Software`
- Expand `Classes`
- Click on `CLSID`

**Quick navigation:** Click in the address bar at the top and paste:
```
Computer\HKEY_CURRENT_USER\Software\Classes\CLSID
```

---

### Step 3: Create New Key (First Key)

1. Right-click on `CLSID` folder (in left pane)
2. Select `New` → `Key`
3. Name it EXACTLY (copy-paste this):
   ```
   {86ca1aa0-34aa-4e8b-a509-50c905bae2a2}
   ```
4. Press `Enter`

**⚠️ CRITICAL:** The CLSID must be EXACT with all brackets, dashes, and letters. Copy-paste it to avoid typos!

**Current path should now be:**
```
HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}
```

---

### Step 4: Create New Key (Second Key - InprocServer32)

1. Right-click on the NEW key you just created:
   `{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}`
2. Select `New` → `Key`
3. Name it EXACTLY:
   ```
   InprocServer32
   ```
4. Press `Enter`

**Current path should now be:**
```
HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32
```

---

### Step 5: Modify the (Default) Value - THE CRITICAL STEP! 🔑

**This is the most important step - many people skip this and it doesn't work!**

1. Click on `InprocServer32` in the left pane (make sure it's selected)
2. In the RIGHT pane, you'll see an entry named `(Default)`
3. **Double-click** on `(Default)`
4. A dialog box "Edit String" will appear
5. **Make sure "Value data:" field is COMPLETELY EMPTY**
6. If there's anything in it, delete it
7. Click `OK`

**⚠️ CRITICAL:** You MUST double-click and open the edit dialog, then click OK - even if the field appears empty. This sets the value to an empty string (null), which is different from not touching it at all!

**What it should look like:**
```
Edit String
─────────────────────────────
Value name: (Default)
Value data: [EMPTY - NOTHING HERE]
─────────────────────────────
[OK] [Cancel]
```

---

### Step 6: Close Registry Editor

Just close the Registry Editor window. Changes are saved automatically.

---

### Step 7: Restart Windows Explorer

**Method 1 - Task Manager (Recommended):**
1. Press `Ctrl + Shift + Esc` to open Task Manager
2. Find `Windows Explorer` in the list
3. Right-click on it
4. Select `Restart`

**Method 2 - Command (Faster):**
1. Press `Win + X`
2. Select `Terminal (Admin)` or `PowerShell (Admin)`
3. Run:
   ```cmd
   taskkill /f /im explorer.exe & start explorer.exe
   ```

**Method 3 - Reboot:**
Just reboot your computer if you prefer.

---

### Step 8: Test It!

1. Right-click on any file or folder
2. You should now see the **FULL Windows 10 context menu** with all options immediately visible!
3. No more "Show more options" needed!

---

## Method 2: HKLM Registry Edit (System-Wide - All Users)

**⚠️ ADVANCED METHOD - Use only if Method 1 doesn't work or you want to change for ALL users**

This method requires:
- Administrator privileges
- Taking ownership of registry key
- More complex steps

### Step 1: Open Registry Editor as Administrator

1. Press `Win + R`
2. Type: `regedit`
3. Press `Ctrl + Shift + Enter` (runs as admin)
4. Click `Yes` on UAC prompt

### Step 2: Navigate to HKLM CLSID

Navigate to:
```
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32
```

**Quick path (copy-paste in address bar):**
```
Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32
```

### Step 3: Take Ownership of the Key

**This key already exists in HKLM, but you need permission to modify it:**

1. Right-click on `InprocServer32` (in left pane)
2. Select `Permissions...`
3. Click `Advanced` button
4. At the top, click `Change` next to Owner
5. Type your username or `Administrators`
6. Click `Check Names` then `OK`
7. Check the box: `Replace owner on subcontainers and objects`
8. Click `Apply` then `OK`

### Step 4: Grant Full Control

Still in Permissions window:
1. Select your user or `Administrators` group
2. Click `Edit`
3. Select your user again
4. Check `Full Control` in the Allow column
5. Click `OK` on all windows

### Step 5: Modify the (Default) Value

1. In the right pane, double-click `(Default)`
2. **Delete ALL content from "Value data:" field** (make it completely empty)
3. Click `OK`

**The value should now show (value not set)**

### Step 6: Restart Explorer

Restart Windows Explorer:
```cmd
taskkill /f /im explorer.exe & start explorer.exe
```

Or reboot your computer.

### HKLM Revert Instructions

To revert the HKLM method, you need to restore the original value:

1. Navigate back to `HKLM\SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32`
2. Double-click `(Default)`
3. Set Value data to: `%SystemRoot%\system32\windows.storage.dll`
4. Click OK
5. Restart Explorer

---

## ⌨️ Keyboard Shortcuts (No Registry Changes Needed)

### Shift + Right-Click
Hold `Shift` key while right-clicking → Get full Windows 10 menu temporarily

### Shift + F10
1. Click on a file/folder (single click to select it)
2. Press `Shift + F10` → Full menu appears!

**These work WITHOUT any registry modifications and work on ALL Windows 11 versions!**

---

## 🔄 How to REVERT Method 1 (HKCU - Go Back to Windows 11 Menu)

### Using REGEDIT:

1. Press `Win + R`, type `regedit`, press Enter
2. Navigate to:
   ```
   HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}
   ```
3. Right-click on `{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}`
4. Select `Delete`
5. Click `Yes` to confirm
6. Close Registry Editor
7. Restart Windows Explorer (Ctrl+Shift+Esc → Restart Explorer)

### Using Command (Faster):

```cmd
reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f
taskkill /f /im explorer.exe & start explorer.exe
```

---

## 📋 The Complete Registry Path (Copy-Paste Reference)

**Full path to create:**
```
HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32
```

**CLSID to create (copy-paste):**
```
{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}
```

**Key name to create under CLSID:**
```
InprocServer32
```

**Value to set:**
- Name: `(Default)`
- Type: `REG_SZ` (String Value)
- Data: `` (empty string - nothing)

---

## ❗ Common Mistakes & Fixes

### Mistake 1: Not Opening the (Default) Value
**Problem:** Created the keys but didn't double-click (Default) to set empty value
**Fix:** Must double-click (Default), see the Edit String dialog, and click OK even if empty

### Mistake 2: Running Regedit as Administrator
**Problem:** Changes made to elevated admin registry instead of current user
**Fix:** Run regedit normally (not as admin) when logged in as regular user

### Mistake 3: Typo in CLSID
**Problem:** CLSID has wrong characters, missing brackets, wrong dashes
**Fix:** Copy-paste exactly: `{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}`

### Mistake 4: Not Restarting Explorer
**Problem:** Made changes but Explorer still shows old menu
**Fix:** Must restart explorer.exe or reboot

### Mistake 5: Wrong Registry Hive
**Problem:** Created under HKLM instead of HKCU
**Fix:** Must be under `HKEY_CURRENT_USER`, not `HKEY_LOCAL_MACHINE`

---

## 🎯 Visual Registry Structure

After completing all steps, your registry should look like this:

```
HKEY_CURRENT_USER
└── Software
    └── Classes
        └── CLSID
            └── {86ca1aa0-34aa-4e8b-a509-50c905bae2a2}   ← YOU CREATE THIS
                └── InprocServer32                        ← YOU CREATE THIS
                    └── (Default) = ""                    ← YOU SET THIS TO EMPTY
```

---

## 🔍 Verify It Worked

**Check in Registry Editor:**
1. Navigate to: `HKEY_CURRENT_USER\Software\Classes\CLSID`
2. You should see `{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}` in the list
3. Expand it and you should see `InprocServer32` underneath
4. Click `InprocServer32` and verify `(Default)` shows `(value not set)` or blank in right pane

**Check the Menu:**
1. Right-click any file or folder
2. You should see the full menu with Cut, Copy, Delete, Rename, Properties, etc.
3. No "Show more options" button

---

## 📝 Command-Line Alternative (Faster)

If you prefer command-line instead of GUI:

**To Enable Windows 10 Menu:**
```cmd
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
taskkill /f /im explorer.exe & start explorer.exe
```

**To Revert to Windows 11 Menu:**
```cmd
reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f
taskkill /f /im explorer.exe & start explorer.exe
```

---

## 🛡️ Is This Safe?

**YES - Completely safe:**
- Only modifies HKEY_CURRENT_USER (your user settings)
- Does NOT touch system files
- Does NOT modify HKEY_LOCAL_MACHINE (system-wide settings)
- Easily reversible by deleting the key
- No impact on system stability
- Microsoft officially supports both menu styles

**What it does:**
- Tells Windows "the new context menu handler DLL doesn't exist"
- Windows automatically falls back to legacy (Windows 10) menu
- This is an official fallback mechanism built into Windows 11

---

## ⚙️ Compatibility

✅ **Works on:**
- Windows 11 Home
- Windows 11 Pro
- Windows 11 Enterprise
- Windows 11 Education
- All builds up to 23H2

⚠️ **May not work on:**
- Windows 11 24H2 and newer (Microsoft may deprecate this method)
- Use Shift+Right-Click or third-party tools as alternatives

---

## 🔗 Related Information

- **Automated script:** `restore-windows10-context-menu.ps1` (in project root)
- **Detailed guide:** `docs/WINDOWS11-CONTEXT-MENU-FIX.md`
- **Registry manipulation:** `docs/POWERSHELL-ADMIN-GUIDE.md`

---

**Last Updated:** 2025-01-26

**Summary:** Create registry key at `HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32` with empty (Default) value, then restart Explorer.
