# Terminal Commands Guide - Best Practices

**Purpose:** Understand how to run Linux/WSL terminal commands properly
**Covers:** sudo, exit codes, error vs. normal output, admin rights
**Audience:** Anyone using WSL/Linux terminal commands

---

## Exit Codes: Understanding What's Actually An Error

### What Are Exit Codes?

Every command returns a number when it finishes:
- **0** = Success, everything worked
- **Non-zero** = Something different (NOT always an error!)

### Common Exit Codes Explained

| Exit Code | Meaning | Is This Bad? |
|-----------|---------|--------------|
| **0** | Success | ✅ Good! |
| **1** | General error | ❌ Actual error |
| **2** | Misuse of command | ❌ Wrong syntax |
| **3** | Service stopped/inactive | ✅ Often normal! |
| **127** | Command not found | ❌ Typo or not installed |
| **130** | Ctrl+C pressed | ✅ You cancelled it |

### Real Example: systemctl status

**Command:**
```bash
sudo systemctl status fail2ban
```

**Output that LOOKS like an error:**
```
Exit code 3
○ fail2ban.service - Fail2Ban Service
     Active: inactive (dead)
```

**Is this an error?** NO! ✅
**What it means:** Service is stopped (which is what we wanted!)

**How to tell:**
- Look at "Active: inactive (dead)" ← This is the actual status
- Exit code 3 = "not running" (not "failed")
- If it said "Active: failed" ← THAT would be an error!

---

## When To Use `sudo` (Admin Rights)

### The Rule: Use `sudo` When You Need Admin/Root Permissions

**Commands That NEED sudo:**
```bash
# System services
sudo systemctl start/stop/restart service-name
sudo systemctl enable/disable service-name

# Installing packages
sudo apt update
sudo apt install package-name

# Editing system files
sudo nano /etc/ssh/sshd_config
sudo chmod 644 /etc/some-file

# Viewing protected logs
sudo cat /var/log/auth.log
sudo tail /var/log/fail2ban.log

# Network configuration
sudo netsh interface portproxy add v4tov4...
sudo iptables -L
```

**Commands That DON'T need sudo:**
```bash
# Viewing your own files
cat ~/myfile.txt
ls /home/username

# Running user programs
python script.py
node app.js

# Git operations (in your own repo)
git status
git commit -m "message"

# Checking public info
curl https://example.com
ping google.com
```

### What Happens If You Forget `sudo`?

**Without sudo (will fail):**
```bash
$ systemctl restart ssh
Failed to restart ssh.service: Access denied
```

**With sudo (works):**
```bash
$ sudo systemctl restart ssh
[sudo] password for username: ****
Service restarted successfully
```

### What Happens If You Use `sudo` When Not Needed?

**It works, but:**
- Files get created as root (ownership problems later)
- Security risk (running as admin when you don't need to)
- Bad practice

**Example of problem:**
```bash
# Bad: Creates file owned by root
sudo echo "test" > myfile.txt
# Now YOU can't edit myfile.txt without sudo!

# Good: Creates file owned by you
echo "test" > myfile.txt
# You can edit it anytime
```

---

## Understanding Command Output

### How To Tell Success vs. Error

#### 1. Look For Error Keywords

**These mean actual errors:**
- "Error:", "Failed:", "Cannot:", "Permission denied"
- "No such file or directory"
- "Command not found"

**These are normal/informational:**
- "inactive (dead)" when checking stopped service
- "Stopping..." when you asked it to stop
- "removed", "disabled" when you asked to disable

#### 2. Check The Action vs. The Result

**Example 1: Stopping a service**
```bash
$ sudo systemctl stop fail2ban
$ sudo systemctl status fail2ban
● fail2ban.service - Fail2Ban Service
     Active: inactive (dead)  ← GOOD! We stopped it!
```
**Result:** Success! (inactive = stopped, what we wanted)

**Example 2: Starting a service that failed**
```bash
$ sudo systemctl start broken-service
$ sudo systemctl status broken-service
● broken-service.service - Broken Service
     Active: failed (Result: exit-code)  ← BAD! It failed!
     Error: Cannot start service
```
**Result:** Actual error! (failed = didn't work)

#### 3. Return Codes

**Check last command's exit code:**
```bash
$ some-command
$ echo $?
0  ← Success!

$ some-other-command
$ echo $?
1  ← Error!
```

---

## Common Command Patterns

### Pattern 1: Check Status → Take Action

```bash
# Check if service is running
sudo systemctl status ssh

# If stopped, start it
sudo systemctl start ssh

# If running, restart it
sudo systemctl restart ssh
```

### Pattern 2: Install → Enable → Start

```bash
# Install package
sudo apt install package-name

# Enable on boot
sudo systemctl enable package-name

# Start now
sudo systemctl start package-name
```

### Pattern 3: Stop → Disable → Remove

```bash
# Stop service
sudo systemctl stop service-name

# Disable from boot
sudo systemctl disable service-name

# Optionally remove
sudo apt remove package-name
```

### Pattern 4: Edit Config → Test → Restart

```bash
# Backup first!
sudo cp /etc/service/config /etc/service/config.backup

# Edit config
sudo nano /etc/service/config

# Test configuration
sudo service-name -t

# If test OK, restart
sudo systemctl restart service-name
```

---

## File Permissions & Ownership

### Understanding `ls -la` Output

```bash
$ ls -la myfile.txt
-rw-r--r-- 1 username usergroup 1234 Nov 17 12:00 myfile.txt
│││││││││││   │        │         │    │
│││││││││││   │        │         │    └─ Date modified
│││││││││││   │        │         └────── File size
│││││││││││   │        └──────────────── Group owner
│││││││││││   └───────────────────────── User owner
│││││││││││
│││└┴┴┴┴┴┴──────────────────────────── Permissions
││└─────────────────────────────────── Number of links
│└──────────────────────────────────── File type (- = file, d = directory)
```

### Permission Numbers

```
r (read)    = 4
w (write)   = 2
x (execute) = 1

chmod 644 = rw-r--r--  (owner: read+write, others: read only)
chmod 755 = rwxr-xr-x  (owner: all, others: read+execute)
chmod 777 = rwxrwxrwx  (everyone: all) ← Dangerous! Avoid!
```

### When To Use `chmod`

**Need to run a script:**
```bash
# Make script executable
chmod +x script.sh

# Now you can run it
./script.sh
```

**Fix permission denied errors:**
```bash
# Error: Permission denied
$ ./myscript.sh
bash: ./myscript.sh: Permission denied

# Fix: Add execute permission
$ chmod +x myscript.sh
$ ./myscript.sh  # Works now!
```

### When To Use `chown`

**Fix ownership issues:**
```bash
# File owned by root, you can't edit it
$ ls -la myfile.txt
-rw-r--r-- 1 root root 100 Nov 17 12:00 myfile.txt

# Change owner to yourself
$ sudo chown username:username myfile.txt

# Now you can edit it
$ nano myfile.txt  # Works without sudo!
```

---

## Admin Rights: WSL to Windows PowerShell

### Running PowerShell Commands with Admin Rights

**From WSL, need Windows admin:**
```bash
# Method 1: Prompt UAC (User Account Control)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -Command "Start-Process powershell -Verb RunAs -ArgumentList '-Command \"Your-Command-Here\"'"

# Method 2: Using gsudo (if installed)
gsudo powershell -Command "Your-Command-Here"
```

**Example: Change system setting**
```bash
# This will prompt UAC to get admin rights
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -Command "Start-Process powershell -Verb RunAs -ArgumentList '-Command \"Set-Service -Name SomeService -StartupType Disabled\"'"
```

---

## Checking If You Have Admin/Root Rights

### Linux/WSL:

**Check if you're root:**
```bash
$ whoami
neil1988  ← Regular user

$ sudo whoami
root  ← Running as root with sudo
```

**Check if you CAN use sudo:**
```bash
$ sudo -v
[sudo] password for neil1988: ****
# If no error, you have sudo rights!
```

### Windows PowerShell:

**Check admin status:**
```powershell
# Run this in PowerShell
([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# True = Running as admin
# False = Running as regular user
```

---

## Common Errors & How To Fix

### Error 1: "Permission denied"

**Problem:**
```bash
$ ./script.sh
bash: ./script.sh: Permission denied
```

**Solution:**
```bash
# Add execute permission
chmod +x script.sh
```

### Error 2: "Command not found"

**Problem:**
```bash
$ mycommand
bash: mycommand: command not found
```

**Solutions:**
```bash
# 1. Check if it's installed
which mycommand

# 2. Install it
sudo apt install mycommand

# 3. Check spelling/typo
# 4. Add ./ if it's a local script
./mycommand
```

### Error 3: "Operation not permitted" (on Windows mounts)

**Problem:**
```bash
$ chmod +x /mnt/c/Users/MYCOM/script.sh
chmod: changing permissions of '/mnt/c/Users/MYCOM/script.sh': Operation not permitted
```

**Solution:**
```bash
# Use sudo for Windows mount points
sudo chmod +x /mnt/c/Users/MYCOM/script.sh
```

### Error 4: "Access denied" (systemctl)

**Problem:**
```bash
$ systemctl restart ssh
Failed to restart ssh.service: Access denied
```

**Solution:**
```bash
# Use sudo
sudo systemctl restart ssh
```

### Error 5: "E: Could not get lock" (apt)

**Problem:**
```bash
$ sudo apt install package
E: Could not get lock /var/lib/dpkg/lock-frontend
```

**Solution:**
```bash
# Another apt process is running, wait for it to finish
# Or if stuck, kill it:
sudo killall apt apt-get
sudo dpkg --configure -a
```

---

## Best Practices Summary

### DO:
✅ Use `sudo` when you need admin rights
✅ Check command output for actual errors
✅ Backup files before editing: `sudo cp file file.backup`
✅ Test commands on non-critical systems first
✅ Read error messages carefully
✅ Use `man command` to learn what command does
✅ Use absolute paths for scripts and files

### DON'T:
❌ Use `sudo` unless you need it
❌ Run `chmod 777` (too permissive, security risk!)
❌ Ignore "Permission denied" (fix the permission!)
❌ Run commands you don't understand
❌ Skip backups when editing system files
❌ Use `sudo rm -rf /` (NEVER! This deletes everything!)

---

## Quick Reference Card

### Check Service Status
```bash
sudo systemctl status service-name
# Active: active (running) = Working ✅
# Active: inactive (dead) = Stopped (might be OK)
# Active: failed = Error ❌
```

### Start/Stop/Restart Service
```bash
sudo systemctl start service-name    # Start
sudo systemctl stop service-name     # Stop
sudo systemctl restart service-name  # Restart
sudo systemctl enable service-name   # Auto-start on boot
sudo systemctl disable service-name  # Don't auto-start
```

### Check Last Command Success
```bash
some-command
echo $?
# 0 = Success
# Non-zero = Check what the number means
```

### View Logs
```bash
# System logs
sudo tail -f /var/log/syslog

# Service-specific logs
sudo journalctl -u service-name -f

# SSH logs
sudo tail -f /var/log/auth.log
```

### File Permissions
```bash
ls -la file              # Check permissions
chmod +x file            # Make executable
chmod 644 file           # rw-r--r--
chmod 755 file           # rwxr-xr-x
sudo chown user:user file  # Change owner
```

---

## When In Doubt

1. **Read the error message** - It usually tells you what's wrong
2. **Check if you need sudo** - Try with sudo if permission denied
3. **Google the exact error** - Someone has seen it before
4. **Ask before running dangerous commands** - Especially `rm`, `dd`, editing system files
5. **Test on backup/copy first** - Don't practice on production

---

**Remember:** Most "errors" are actually just informational messages. Real errors usually say "Error", "Failed", or "Cannot" explicitly!

**Last Updated:** 2025-11-17
**Related Guides:** POWERSHELL-ADMIN-GUIDE.md, WSL-WINDOWS-INTEGRATION.md
