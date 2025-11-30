# 🚨 URGENT: SSH BRUTE FORCE ATTACK DETECTED!

**Date:** 2025-11-16 22:50
**Severity:** HIGH
**Status:** ACTIVE ATTACK IN PROGRESS

---

## CRITICAL FINDINGS:

### You Are Under Active SSH Attack!

**Attack Statistics:**
- **32,783 total connection attempts** from IP 172.28.144.1 (Windows host/router)
- **3,683 attempts as "root"** user
- **Hundreds of different usernames** tried (admin, oracle, ubuntu, postgres, steam, dns, etc.)
- **All using password authentication** (brute force)
- **Attack is ONGOING** - Recent attempts in last 10 minutes

### Recent Attack Attempts (Last 10 Minutes):
```
22:46:38 - Failed password for root
22:47:04 - Failed password for invalid user steam
22:47:07 - Failed password for invalid user dns
22:47:40 - Failed password for invalid user saas
22:48:51 - Failed password for root
22:49:05 - Failed password for invalid user sanjay
22:49:42 - Failed password for invalid user epauser
22:49:47 - Failed password for invalid user slurm
22:49:48 - Failed password for invalid user erpnext
```

### Attack Pattern:
- Automated script trying common usernames
- Using dictionary attack (root, admin, user, test, etc.)
- Trying to guess passwords
- Coming through your Windows/router network

---

## Why Your iPad Is Asking for Password:

### The iPad Issue (Secondary):

Your iPad asking for password is **NOT the main problem** - the attack is!

**iPad Issue:**
1. Your iPad SSH client is probably set to wrong username (trying "root" instead of "neil1988")
2. Or the SSH key isn't properly configured in iPad app
3. When key fails, it falls back to password auth (which is currently enabled)

**Your Correct SSH Settings:**
- **Username:** `neil1988` (NOT root, NOT sanjay, NOT any other username)
- **Auth Method:** SSH Key (ED25519)
- **Password Auth:** Should be DISABLED (but currently enabled!)

---

## Current Vulnerable Configuration:

### What's Wrong:

**From /etc/ssh/sshd_config:**
```
PasswordAuthentication yes  ← DANGER! Should be "no"
PubkeyAuthentication yes    ← Good!
```

**Problems:**
1. **Password authentication is ENABLED** - Attackers can try to guess passwords
2. **Root login probably allowed** - Attackers targeting root user
3. **SSH exposed to internet** - Port 22 is reachable externally
4. **No rate limiting** - 32,783 attempts allowed without blocking

---

## Successful Logins (Your Phone):

**Your phone SSH is working correctly!**

Recent successful logins using SSH KEY:
```
Nov 16 00:35 - neil1988 from 172.28.144.1 (publickey)
Nov 16 08:35 - neil1988 from 172.28.144.1 (publickey)
Nov 16 12:26 - neil1988 from 172.28.144.1 (publickey)
Nov 16 13:56 - neil1988 from 172.28.144.1 (publickey)
Nov 16 20:51 - neil1988 from 172.28.144.1 (publickey)
Nov 16 22:36 - neil1988 from 172.28.144.1 (publickey)
```

**Key fingerprint:** `ED25519 SHA256:0iDmYHpz8wlQHllS7XBpFz7GpjzJ+V/cjaYxOUNzDWo`

This is the CORRECT way - your phone uses:
- ✅ Correct username: `neil1988`
- ✅ SSH key authentication
- ✅ No password needed

---

## Top Targeted Usernames (Attack Profile):

```
3,683 attempts - root
  121 attempts - admin
   73 attempts - oracle
   66 attempts - testuser
   65 attempts - huawei
   62 attempts - kingbase
   60 attempts - slurm
   58 attempts - ubuntu
   57 attempts - test
   52 attempts - db2fenc1
   46 attempts - user
```

**This is a PROFESSIONAL brute force attack** using common Unix/Linux usernames!

---

## IMMEDIATE ACTION REQUIRED:

### Step 1: Disable Password Authentication NOW

```bash
# Edit SSH config
sudo nano /etc/ssh/sshd_config

# Change these lines:
PasswordAuthentication no        # Change from "yes" to "no"
PermitRootLogin no               # Add this line
ChallengeResponseAuthentication no  # Add this line

# Save and restart SSH
sudo systemctl restart ssh
```

### Step 2: Install fail2ban (Block Attackers)

```bash
# Install fail2ban
sudo apt update && sudo apt install fail2ban -y

# Start fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Check status
sudo fail2ban-client status sshd
```

### Step 3: Fix iPad SSH Client

**On your iPad SSH app (probably Termius):**

1. **Check Username:**
   - Username: `neil1988` (NOT "root"!)

2. **Check Authentication:**
   - Method: SSH Key (NOT password)
   - Key: Use the ED25519 key you have

3. **Check Host:**
   - Host: Your router's external IP or domain
   - Port: 22 (for now, change later)

### Step 4: Change SSH Port (Optional but Recommended)

```bash
# Edit SSH config
sudo nano /etc/ssh/sshd_config

# Change:
Port 2222  # Or any port other than 22

# Restart SSH
sudo systemctl restart ssh

# Update router port forwarding:
# External Port: 2222 → Internal Port: 2222
```

---

## Why This Happened:

### SSH is Exposed to Internet

Your SSH server is accessible from the internet (probably via router port forwarding).

**Attack Path:**
```
Internet → Router (172.30.1.54) → Windows (172.28.144.1) → WSL SSH (172.28.150.120:22)
```

**Attackers found your IP and are trying to break in!**

---

## Security Checklist:

### ✅ Do This NOW (Emergency):

- [ ] Disable password authentication
- [ ] Disable root login
- [ ] Install fail2ban
- [ ] Check who else is logged in: `who`
- [ ] Check for unauthorized SSH keys in ~/.ssh/authorized_keys

### ✅ Do This Today:

- [ ] Change SSH port from 22 to something else (2222, 2200, etc.)
- [ ] Update router port forwarding to new port
- [ ] Configure fail2ban rules
- [ ] Fix iPad SSH client settings
- [ ] Enable UFW firewall with SSH allowed

### ✅ Do This Week:

- [ ] Set up SSH key rotation
- [ ] Implement IP whitelisting (only allow your known IPs)
- [ ] Set up SSH monitoring/alerts
- [ ] Review all authorized_keys entries
- [ ] Consider VPN instead of direct SSH exposure

---

## How to Fix iPad Connection:

### In Your iPad SSH App:

**1. Connection Settings:**
```
Host: [Your external IP or domain]
Port: 22 (change to 2222 after you change server port)
Username: neil1988  ← CRITICAL! Not "root"!
```

**2. Authentication:**
```
Method: SSH Key
Key: [Your ED25519 private key]
Password: [Leave empty or remove]
```

**3. Advanced Settings:**
```
Disable password authentication fallback
Use only key-based authentication
```

### Test from iPad:
```
ssh neil1988@[your-ip] -p 22 -i [your-key]
```

**If it still asks for password:**
- Check username is "neil1988"
- Check key is correctly imported
- Check key permissions (private key should be read-only)
- Try regenerating key pair

---

## Monitoring Commands:

### Check Current Attacks:
```bash
# Live attack monitoring
sudo tail -f /var/log/auth.log | grep "Failed password"

# Count attacks in last hour
sudo grep "Failed password" /var/log/auth.log | grep "$(date +%b\ %d\ %H)" | wc -l

# Top attacking IPs
sudo grep "Failed password" /var/log/auth.log | awk '{print $(NF-3)}' | sort | uniq -c | sort -rn | head -10
```

### Check fail2ban Status:
```bash
# See banned IPs
sudo fail2ban-client status sshd

# Unban IP if needed
sudo fail2ban-client set sshd unbanip [IP]
```

---

## What Attackers Are After:

1. **Compromise your server** - Install malware, ransomware, cryptominers
2. **Use as bot** - Launch attacks on others from your IP
3. **Steal data** - Access your files, code, credentials
4. **Pivot to network** - Use your server to attack Windows, other devices

**This is SERIOUS!** Secure your SSH immediately!

---

## Summary:

### The Attack:
- ✅ **Detected:** Active SSH brute force attack
- ✅ **Source:** Internet (via router → Windows → WSL)
- ✅ **Attempts:** 32,783+ failed password attempts
- ✅ **Status:** ONGOING (attacks happening right now)

### Your Defense:
- ❌ **Password auth:** ENABLED (vulnerable!)
- ✅ **Key auth:** ENABLED and working (phone connects fine)
- ❌ **fail2ban:** NOT installed (no attacker blocking)
- ❌ **Port:** Default 22 (easy target)
- ❌ **Root login:** Probably allowed (dangerous)

### The iPad:
- **Not the attacker** - Just using wrong username or not configured for key auth
- **Falling back to password** - Because password auth is enabled
- **Fix:** Set username to "neil1988" and ensure key is used

### Action Required:
1. **URGENT:** Disable password authentication NOW
2. **HIGH:** Install fail2ban to block attackers
3. **MEDIUM:** Change SSH port
4. **LOW:** Fix iPad SSH client settings

---

**DO THIS NOW!** Your server is under active attack!

**Next file:** Create `secure-ssh-emergency.sh` script to automate fixes
