# SSH Connection to WSL - Complete Troubleshooting Guide

**Created:** 2025-01-26
**System:** Windows 11 + WSL2 Ubuntu
**Issue:** SSH connection from external network to WSL

---

## The Problem (January 26, 2025)

### User Report:
"I just checked my router, still have the thing configured for 172.30.1.54 fixed. But for some reason after I moved to Windows 11 now I cannot connect to my SSH. It was all solved yesterday."

### What Happened:
**Windows 11 upgrade wiped out the port forwarding configuration.**

The router was still correctly forwarding port 22 to Windows IP (172.30.1.54), but Windows was no longer forwarding traffic to WSL where the SSH server actually runs.

---

## Understanding the Network Architecture

### The SSH Connection Chain:

```
Internet/LAN
    ↓
Router (Port Forward Rule)
    ↓ forwards :22 to
Windows IP: 172.30.1.54:22
    ↓ needs port proxy to
WSL IP: 172.28.150.120:22 (where sshd actually runs)
```

### Key Concepts:

1. **WSL runs in a virtualized network**
   - WSL has its own IP address (different from Windows)
   - WSL IP is assigned by Hyper-V virtual switch
   - WSL IP can change on every reboot!

2. **Windows needs to forward traffic to WSL**
   - Uses `netsh interface portproxy` command
   - Acts as a network bridge between Windows and WSL
   - Configuration is stored in Windows registry
   - **Windows upgrades can wipe this configuration**

3. **Router configuration**
   - Router forwards external traffic to Windows IP
   - This part usually survives Windows upgrades
   - User's router: 172.30.1.54 (fixed/static assignment)

---

## The Diagnostic Journey

### Step 1: Check Current WSL IP
```bash
ip addr show eth0 | grep "inet " | awk '{print $2}' | cut -d/ -f1
```
**Result:** `172.28.150.120`

### Step 2: Check SSH Service in WSL
```bash
sudo systemctl status ssh
sudo ss -tulpn | grep :22
```
**Result:**
- SSH service: Active (running) since 09:24:29
- Port 22: Listening on 0.0.0.0:22
- ✅ SSH server is healthy

### Step 3: Check WSL-Related Windows Services
```powershell
Get-Service -Name 'LxssManager','WSLService' | Select-Object Name, Status, StartType
```
**Result:**
- LxssManager: Stopped (Manual) - This is normal
- WSLService: Running (Automatic) - ✅ Good

### Step 4: Test Local SSH Connection
```bash
ssh neil1988@172.28.150.120 "echo 'SSH connection successful'"
```
**Result:** `SSH connection successful`
- ✅ SSH works locally within WSL network

### Step 5: Check Port Forwarding Configuration
```powershell
netsh interface portproxy show all
```
**Result:** *Empty output* - ❌ **THIS IS THE PROBLEM!**

### Step 6: Check Windows Firewall
```powershell
Get-NetFirewallRule | Where-Object DisplayName -like '*SSH*'
```
**Result:** Multiple SSH rules enabled (SSH-In-WSL, WSL SSH, SSH2222, SSH2223, SSH)
- ✅ Firewall is not blocking

### Step 7: Check Windows Network IPs
```powershell
Get-NetIPAddress -AddressFamily IPv4 | Where-Object InterfaceAlias -notlike '*Loopback*'
```
**Result:**
- Windows IP: 172.30.1.54 (Ethernet 3) - ✅ Matches router config
- WSL Virtual Switch: 172.28.144.1

---

## The Solution

### Root Cause:
**Port forwarding from Windows to WSL was missing** after Windows 11 upgrade.

### The Fix:
```powershell
# Run as Administrator
netsh interface portproxy add v4tov4 listenport=22 listenaddress=0.0.0.0 connectport=22 connectaddress=172.28.150.120
```

**Command Breakdown:**
- `listenport=22` - Listen on port 22 (SSH)
- `listenaddress=0.0.0.0` - Listen on all Windows network interfaces
- `connectport=22` - Forward to port 22 in WSL
- `connectaddress=172.28.150.120` - Current WSL IP address

### Verification:
```powershell
# Check it was added
netsh interface portproxy show all

# Output:
Adresse         Port        Adresse         Port
0.0.0.0         22          172.28.150.120  22
```

### Test Connection:
```powershell
Test-NetConnection -ComputerName 172.30.1.54 -Port 22
```
**Result:** TcpTestSucceeded = True ✅

---

## How to Run the Fix (For Future Reference)

### Method 1: From WSL with UAC Elevation
```bash
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -Command \"netsh interface portproxy add v4tov4 listenport=22 listenaddress=0.0.0.0 connectport=22 connectaddress=172.28.150.120\"' -Wait"
```

### Method 2: From PowerShell (Run as Administrator)
```powershell
netsh interface portproxy add v4tov4 listenport=22 listenaddress=0.0.0.0 connectport=22 connectaddress=172.28.150.120
```

---

## Common Issues & Solutions

### Issue 1: SSH Works Locally But Not From Network

**Symptoms:**
- `ssh neil1988@172.28.150.120` works inside WSL
- `ssh user@router-external-ip` fails from outside

**Diagnosis:**
```powershell
netsh interface portproxy show all
```

**Solution:**
If output is empty, port forwarding is missing. Apply the fix above.

---

### Issue 2: WSL IP Address Changed

**Symptoms:**
- SSH was working, now suddenly fails
- After Windows reboot, connection drops

**Diagnosis:**
```bash
# Check current WSL IP
ip addr show eth0 | grep "inet "

# Check what port forwarding thinks WSL IP is
powershell.exe -c "netsh interface portproxy show all"
```

**Solution:**
```powershell
# Delete old forwarding
netsh interface portproxy delete v4tov4 listenport=22 listenaddress=0.0.0.0

# Add new forwarding with updated WSL IP
netsh interface portproxy add v4tov4 listenport=22 listenaddress=0.0.0.0 connectport=22 connectaddress=[NEW_WSL_IP]
```

**Why WSL IP Changes:**
- WSL2 uses Hyper-V virtualization
- IP is assigned dynamically by Windows Hyper-V network switch
- Can change after Windows updates, reboots, or WSL restarts

---

### Issue 3: Windows Firewall Blocking

**Symptoms:**
- Port forwarding is configured correctly
- SSH works locally but not from network
- Windows Firewall is enabled

**Diagnosis:**
```powershell
Get-NetFirewallRule | Where-Object DisplayName -like '*SSH*' | Select-Object DisplayName, Enabled, Direction, Action
```

**Solution:**
```powershell
# Create inbound rule for SSH
New-NetFirewallRule -DisplayName "SSH-In-WSL" -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow
```

---

### Issue 4: Router Not Forwarding

**Symptoms:**
- Everything works from local network
- Fails from external network/internet

**Diagnosis:**
1. Check router port forwarding settings
2. Verify Windows IP hasn't changed
3. Test from outside the network

**Solution:**
- Log into router admin panel
- Verify port forward: External Port 22 → 172.30.1.54:22
- If Windows IP changed, update router config

---

## Windows 11 vs Windows 10 Differences

### What Changed in Windows 11:

1. **Port Proxy Configuration**
   - Windows 11 upgrade process can reset registry settings
   - Port forwarding rules may be wiped during upgrade
   - **Always check after major Windows updates**

2. **WSL2 Integration**
   - WSL2 networking might behave differently
   - IP assignment can be more dynamic
   - Virtual switch configuration may change

3. **Firewall Rules**
   - Some firewall rules may need reconfiguration
   - Windows Defender Firewall rules can be reset

### What Stayed the Same:

- SSH server configuration in WSL (untouched)
- Router configuration (external to Windows)
- SSH keys and authorized_keys
- WSL distributions and files

---

## Complete Diagnostic Checklist

When SSH stops working, check in this order:

### 1. WSL Layer
```bash
# Is SSH service running?
sudo systemctl status ssh

# Is port 22 listening?
sudo ss -tulpn | grep :22

# What's the current WSL IP?
ip addr show eth0 | grep "inet "

# Can you SSH locally?
ssh neil1988@localhost
```

### 2. Windows Layer
```powershell
# Is port forwarding configured?
netsh interface portproxy show all

# Is WSL service running?
Get-Service -Name 'WSLService','LxssManager'

# Is firewall blocking?
Get-NetFirewallRule | Where-Object DisplayName -like '*SSH*'

# What's the Windows IP?
Get-NetIPAddress -AddressFamily IPv4
```

### 3. Network Layer
```powershell
# Can Windows reach WSL SSH?
Test-NetConnection -ComputerName [WSL_IP] -Port 22

# Can Windows SSH reach itself?
Test-NetConnection -ComputerName 172.30.1.54 -Port 22
```

### 4. Router Layer
- Check router admin panel
- Verify port forward exists: External:22 → 172.30.1.54:22
- Test from external network

---

## Historical Context

### Previous SSH Configurations (From Bash History)

```bash
# Connection attempts to various WSL IPs
ssh neil1988@172.30.1.6      # Old WSL IP
ssh neil1988@172.28.150.120  # Current WSL IP

# SSH key setup
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys

# Service checks
sudo ss -tulpn | grep ssh
cat /etc/ssh/sshd_config

# Port proxy checks
powershell.exe -c "netsh interface portproxy show all"
```

### WSL IP History:
- **2025-01-25 (or earlier):** 172.30.1.6
- **2025-01-26:** 172.28.150.120

This shows WSL IP has changed, confirming it's dynamic!

---

## Best Practices

### 1. Document Your Configuration
Always know:
- Current WSL IP
- Windows IP (should be static via router)
- Port forwarding rules
- Router configuration

### 2. Check After Windows Updates
Major Windows updates can reset:
- Port forwarding configuration
- Firewall rules
- Service startup settings

### 3. Consider Static WSL IP (Advanced)
You can configure WSL to use a static IP via `.wslconfig`, but this has trade-offs and can cause other networking issues.

### 4. Monitor WSL IP Changes
Create a simple check:
```bash
# Add to ~/.bashrc
echo "Current WSL IP: $(ip addr show eth0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)"
```

### 5. Keep Router Config Simple
- Use fixed/static IP assignment for Windows (172.30.1.54)
- Single port forward rule (External:22 → 172.30.1.54:22)
- Let Windows handle the rest via port proxy

---

## Related Documentation

- **CLAUDE.md** - Quick reference for this project
- **startup-issue-report-2025-09-21.md** - WSLService timeout issues
- **docs/WSL-WINDOWS-INTEGRATION.md** - Complete WSL-Windows integration guide
- **docs/troubleshooting-protocols.md** - General troubleshooting patterns

---

## Summary for Future Claude Iterations

### The Essential Knowledge:

1. **SSH runs in WSL, not Windows**
   - WSL has its own IP (dynamic, can change)
   - Windows needs to forward traffic to WSL

2. **Port forwarding is required**
   - Command: `netsh interface portproxy add v4tov4 listenport=22 listenaddress=0.0.0.0 connectport=22 connectaddress=[WSL_IP]`
   - This configuration can be wiped by Windows updates
   - Always verify after major system changes

3. **The diagnostic order:**
   - Check SSH in WSL ✓
   - Check port forwarding ← **Usually the problem**
   - Check firewall ✓
   - Check router ✓

4. **The most common issue:**
   - Missing or outdated port forwarding configuration
   - Easy fix: Re-apply the netsh command

5. **Windows 11 specific:**
   - Major upgrades can reset port proxy settings
   - Always assume port forwarding needs reconfiguration after upgrade

### Quick Fix Command:
```powershell
# Get current WSL IP first
wsl ip addr show eth0 | grep "inet " | awk '{print $2}' | cut -d/ -f1

# Then apply port forwarding (as Administrator)
netsh interface portproxy add v4tov4 listenport=22 listenaddress=0.0.0.0 connectport=22 connectaddress=[WSL_IP]
```

**This document should answer all SSH troubleshooting questions for this system.**

---

**Status:** RESOLVED (2025-01-26)
**Next Known Issue:** WSL IP may change on reboot - check and update port forwarding if needed
