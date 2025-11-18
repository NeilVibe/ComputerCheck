#!/bin/bash

# SSH Security Checker
# Monitors SSH attacks, security settings, and fail2ban status
# Part of CheckComputer toolkit

echo "========================================"
echo "SSH SECURITY STATUS CHECK"
echo "========================================"
echo ""
date
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${YELLOW}Note: Some checks require sudo. Run with 'sudo' for full report.${NC}"
        echo ""
    fi
}

# Function to print section header
section() {
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}"
}

# 1. SSH SERVICE STATUS
section "1. SSH SERVICE STATUS"
if systemctl is-active --quiet ssh; then
    echo -e "${GREEN}✅ SSH service is RUNNING${NC}"
    systemctl status ssh --no-pager | head -5
else
    echo -e "${RED}❌ SSH service is NOT running!${NC}"
fi
echo ""

# 2. SSH CONFIGURATION SECURITY
section "2. SSH SECURITY CONFIGURATION"

echo "Checking critical security settings..."
echo ""

# Password Authentication
if sudo grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config 2>/dev/null; then
    echo -e "${GREEN}✅ Password Authentication: DISABLED (secure!)${NC}"
elif sudo grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config 2>/dev/null; then
    echo -e "${RED}❌ Password Authentication: ENABLED (vulnerable!)${NC}"
    echo -e "   ${YELLOW}Recommendation: Disable with 'PasswordAuthentication no'${NC}"
else
    echo -e "${YELLOW}⚠️  Password Authentication: Default (usually enabled)${NC}"
fi

# Root Login
if sudo grep -q "^PermitRootLogin no" /etc/ssh/sshd_config 2>/dev/null; then
    echo -e "${GREEN}✅ Root Login: DISABLED (secure!)${NC}"
elif sudo grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config 2>/dev/null; then
    echo -e "${RED}❌ Root Login: ENABLED (vulnerable!)${NC}"
    echo -e "   ${YELLOW}Recommendation: Disable with 'PermitRootLogin no'${NC}"
else
    echo -e "${YELLOW}⚠️  Root Login: Default setting${NC}"
fi

# Public Key Authentication
if sudo grep -q "^PubkeyAuthentication yes" /etc/ssh/sshd_config 2>/dev/null; then
    echo -e "${GREEN}✅ Public Key Authentication: ENABLED (good!)${NC}"
else
    echo -e "${YELLOW}⚠️  Public Key Authentication: Check config${NC}"
fi

echo ""

# 3. AUTHORIZED KEYS
section "3. AUTHORIZED SSH KEYS"
if [ -f ~/.ssh/authorized_keys ]; then
    key_count=$(wc -l < ~/.ssh/authorized_keys)
    echo -e "${GREEN}✅ Authorized keys file exists${NC}"
    echo "   Location: ~/.ssh/authorized_keys"
    echo "   Number of keys: $key_count"
    echo ""
    echo "Keys:"
    while IFS= read -r line; do
        # Extract key type and comment
        key_type=$(echo "$line" | awk '{print $1}')
        comment=$(echo "$line" | awk '{print $NF}')
        echo "   - $key_type: $comment"
    done < ~/.ssh/authorized_keys
else
    echo -e "${YELLOW}⚠️  No authorized_keys file found${NC}"
fi
echo ""

# 4. FAIL2BAN STATUS
section "4. FAIL2BAN STATUS"

if command -v fail2ban-client &> /dev/null; then
    echo -e "${GREEN}✅ fail2ban is installed${NC}"
    echo ""

    if systemctl is-active --quiet fail2ban; then
        echo -e "${GREEN}✅ fail2ban service is RUNNING${NC}"
        echo ""

        # SSHD jail status
        echo "SSHD Jail Status:"
        if sudo fail2ban-client status sshd 2>/dev/null; then
            echo ""
        else
            echo -e "${YELLOW}⚠️  SSHD jail not configured or not active${NC}"
        fi
    else
        echo -e "${RED}❌ fail2ban service is NOT running${NC}"
        echo -e "   ${YELLOW}Start with: sudo systemctl start fail2ban${NC}"
    fi
else
    echo -e "${RED}❌ fail2ban is NOT installed${NC}"
    echo -e "   ${YELLOW}Install with: sudo apt install fail2ban -y${NC}"
fi
echo ""

# 5. RECENT ATTACK ATTEMPTS
section "5. RECENT ATTACK ATTEMPTS"

echo "Failed SSH login attempts (last 24 hours):"
echo ""

failed_today=$(sudo grep "Failed password" /var/log/auth.log 2>/dev/null | grep "$(date +%b\ %d)" | wc -l)
if [ "$failed_today" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  $failed_today failed login attempts today${NC}"
else
    echo -e "${GREEN}✅ No failed attempts today${NC}"
fi

# Last hour
failed_hour=$(sudo grep "Failed password" /var/log/auth.log 2>/dev/null | grep "$(date +%b\ %d\ %H):" | wc -l)
if [ "$failed_hour" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  $failed_hour failed attempts in the last hour${NC}"
else
    echo -e "${GREEN}✅ No failed attempts in the last hour${NC}"
fi

echo ""
echo "Most targeted usernames (top 10):"
sudo grep "Failed password" /var/log/auth.log 2>/dev/null | awk '{print $(NF-5)}' | sort | uniq -c | sort -rn | head -10 | while read count user; do
    echo "   $count attempts - $user"
done

echo ""
echo "Recent attack IPs (top 5):"
sudo grep "Failed password" /var/log/auth.log 2>/dev/null | awk '{print $(NF-3)}' | sort | uniq -c | sort -rn | head -5 | while read count ip; do
    echo "   $count attempts from $ip"
done

echo ""

# 6. SUCCESSFUL LOGINS
section "6. SUCCESSFUL SSH LOGINS (Last 10)"

echo "Recent successful SSH logins:"
echo ""
sudo grep "Accepted publickey" /var/log/auth.log 2>/dev/null | tail -10 | while IFS= read -r line; do
    timestamp=$(echo "$line" | awk '{print $1, $2, $3}')
    user=$(echo "$line" | awk '{print $9}')
    ip=$(echo "$line" | awk '{print $11}')
    echo "   $timestamp - User: $user from $ip"
done

echo ""

# 7. CURRENTLY BANNED IPS (fail2ban)
section "7. CURRENTLY BANNED IPS"

if command -v fail2ban-client &> /dev/null && systemctl is-active --quiet fail2ban; then
    banned=$(sudo fail2ban-client status sshd 2>/dev/null | grep "Currently banned" | awk '{print $NF}')
    if [ "$banned" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  $banned IP(s) currently banned${NC}"
        echo ""
        echo "Banned IPs:"
        sudo fail2ban-client status sshd 2>/dev/null | grep "Banned IP list" | cut -d: -f2 | tr ' ' '\n' | grep -v "^$" | while read ip; do
            echo "   - $ip"
        done
    else
        echo -e "${GREEN}✅ No IPs currently banned${NC}"
    fi
else
    echo "fail2ban not active - cannot check banned IPs"
fi

echo ""

# 8. SSH PORT AND EXPOSURE
section "8. SSH PORT AND NETWORK EXPOSURE"

ssh_port=$(sudo grep "^Port" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}')
if [ -z "$ssh_port" ]; then
    ssh_port="22 (default)"
fi

echo "SSH listening on port: $ssh_port"
echo ""

echo "Active SSH connections:"
ss -tn state established '( dport = :22 or sport = :22 )' 2>/dev/null | grep -v "State" | while read line; do
    echo "   $line"
done || echo "   None currently active"

echo ""

# 9. SECURITY SCORE
section "9. SECURITY SCORE"

score=0
max_score=6

# Check password auth disabled
if sudo grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config 2>/dev/null; then
    ((score++))
fi

# Check root login disabled
if sudo grep -q "^PermitRootLogin no" /etc/ssh/sshd_config 2>/dev/null; then
    ((score++))
fi

# Check public key auth enabled
if sudo grep -q "^PubkeyAuthentication yes" /etc/ssh/sshd_config 2>/dev/null; then
    ((score++))
fi

# Check fail2ban installed
if command -v fail2ban-client &> /dev/null; then
    ((score++))
fi

# Check fail2ban running
if systemctl is-active --quiet fail2ban 2>/dev/null; then
    ((score++))
fi

# Check authorized_keys exists
if [ -f ~/.ssh/authorized_keys ]; then
    ((score++))
fi

echo "Security Score: $score/$max_score"
echo ""

if [ "$score" -eq "$max_score" ]; then
    echo -e "${GREEN}🔒 EXCELLENT! Your SSH is fully secured!${NC}"
elif [ "$score" -ge 4 ]; then
    echo -e "${YELLOW}⚠️  GOOD, but some improvements recommended${NC}"
else
    echo -e "${RED}❌ VULNERABLE! Immediate action required!${NC}"
fi

echo ""

# 10. RECOMMENDATIONS
section "10. SECURITY RECOMMENDATIONS"

recommendations=()

if ! sudo grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config 2>/dev/null; then
    recommendations+=("Disable password authentication: Set 'PasswordAuthentication no' in /etc/ssh/sshd_config")
fi

if ! sudo grep -q "^PermitRootLogin no" /etc/ssh/sshd_config 2>/dev/null; then
    recommendations+=("Disable root login: Set 'PermitRootLogin no' in /etc/ssh/sshd_config")
fi

if ! command -v fail2ban-client &> /dev/null; then
    recommendations+=("Install fail2ban: sudo apt install fail2ban -y")
fi

if command -v fail2ban-client &> /dev/null && ! systemctl is-active --quiet fail2ban; then
    recommendations+=("Start fail2ban: sudo systemctl start fail2ban && sudo systemctl enable fail2ban")
fi

if [ ${#recommendations[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ No critical recommendations - your SSH security is excellent!${NC}"
else
    echo -e "${YELLOW}Recommended actions:${NC}"
    for i in "${!recommendations[@]}"; do
        echo -e "   $((i+1)). ${recommendations[$i]}"
    done
fi

echo ""
echo "========================================"
echo "END OF SECURITY CHECK"
echo "========================================"
echo ""
echo "Run this script regularly to monitor SSH security!"
echo "Suggested: Weekly or after any SSH configuration changes"
echo ""
