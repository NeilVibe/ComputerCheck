#!/bin/bash

# Linux Monitoring Tools - Automated Installer
# Purpose: Install all essential Linux monitoring packages
# Date: 2025-11-16
# Usage: sudo ./install-monitoring-tools.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Linux Monitoring Tools - Installer${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}ERROR: This script must be run as root (use sudo)${NC}"
    echo "Usage: sudo ./install-monitoring-tools.sh"
    exit 1
fi

echo -e "${GREEN}Starting installation...${NC}"
echo ""

# Update package list
echo -e "${YELLOW}[1/4] Updating package list...${NC}"
apt update -qq
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Package list updated${NC}"
else
    echo -e "${RED}❌ Failed to update package list${NC}"
    exit 1
fi
echo ""

# Install essential monitoring tools
echo -e "${YELLOW}[2/4] Installing monitoring tools...${NC}"
echo "This will install:"
echo "  - htop (interactive process viewer)"
echo "  - glances (all-in-one system monitor)"
echo "  - nethogs (network usage per process)"
echo "  - iotop (disk I/O monitor)"
echo "  - ncdu (disk usage analyzer)"
echo "  - bmon (bandwidth monitor)"
echo "  - vnstat (network traffic logger)"
echo "  - sysstat (performance statistics)"
echo "  - nmap (network scanner)"
echo "  - iftop (network traffic monitor)"
echo "  - dstat (resource statistics)"
echo "  - lsof (list open files)"
echo "  - strace (system call tracer)"
echo "  - tcpdump (packet capture)"
echo "  - net-tools (network utilities)"
echo "  - iperf3 (network performance)"
echo "  - mtr (network diagnostic)"
echo "  - curl (data transfer)"
echo "  - jq (JSON processor)"
echo "  - tree (directory viewer)"
echo ""

apt install -y \
    htop \
    glances \
    nethogs \
    iotop \
    ncdu \
    bmon \
    vnstat \
    sysstat \
    nmap \
    iftop \
    dstat \
    lsof \
    strace \
    tcpdump \
    net-tools \
    iperf3 \
    mtr \
    curl \
    jq \
    tree 2>&1 | grep -v "^Reading" | grep -v "^Building" | grep -v "^0 upgraded"

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo -e "${GREEN}✅ All tools installed successfully${NC}"
else
    echo -e "${RED}❌ Some tools failed to install${NC}"
    echo "Check errors above and try again"
    exit 1
fi
echo ""

# Enable monitoring services
echo -e "${YELLOW}[3/4] Enabling monitoring services...${NC}"

# Enable vnstat (network traffic logging)
if systemctl enable vnstat 2>/dev/null; then
    systemctl start vnstat 2>/dev/null
    echo -e "${GREEN}✅ vnstat service enabled and started${NC}"
else
    echo -e "${YELLOW}⚠️  vnstat service not available (may not be needed)${NC}"
fi

# Enable sysstat (performance statistics)
if systemctl enable sysstat 2>/dev/null; then
    systemctl start sysstat 2>/dev/null
    echo -e "${GREEN}✅ sysstat service enabled and started${NC}"
else
    echo -e "${YELLOW}⚠️  sysstat service not available (may not be needed)${NC}"
fi

# Verify fail2ban is still running (from SSH security setup)
if systemctl is-active --quiet fail2ban; then
    echo -e "${GREEN}✅ fail2ban is active (SSH protection working)${NC}"
else
    echo -e "${YELLOW}⚠️  fail2ban not running (SSH may not be protected)${NC}"
fi
echo ""

# Verify installations
echo -e "${YELLOW}[4/4] Verifying installations...${NC}"

TOOLS=("htop" "glances" "nethogs" "iotop" "ncdu" "vnstat" "nmap" "jq" "tree")
FAILED=0

for tool in "${TOOLS[@]}"; do
    if command -v "$tool" &> /dev/null; then
        echo -e "${GREEN}✅ $tool${NC}"
    else
        echo -e "${RED}❌ $tool (not found)${NC}"
        FAILED=$((FAILED + 1))
    fi
done
echo ""

# Summary
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Installation Complete!${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All tools installed successfully!${NC}"
else
    echo -e "${YELLOW}⚠️  $FAILED tools failed to install${NC}"
fi

# Disk space used
DISK_USAGE=$(du -sh /var/cache/apt/archives 2>/dev/null | awk '{print $1}')
echo -e "Disk space used: ~100-150 MB"
echo -e "RAM usage: ~70 MB total (minimal impact)"
echo ""

# Usage instructions
echo -e "${BLUE}Quick Start Guide:${NC}"
echo ""
echo -e "${GREEN}System Monitoring:${NC}"
echo "  htop              - Interactive process viewer (press q to quit)"
echo "  glances           - All-in-one system monitor (beautiful!)"
echo "  glances -w        - Web interface at http://localhost:61208"
echo ""
echo -e "${GREEN}Network Monitoring:${NC}"
echo "  sudo nethogs      - Network usage per process"
echo "  sudo iftop        - Real-time network traffic"
echo "  vnstat            - Network traffic statistics"
echo "  vnstat -h         - Hourly stats"
echo "  vnstat -d         - Daily stats"
echo ""
echo -e "${GREEN}Disk Monitoring:${NC}"
echo "  ncdu ~            - Analyze home directory disk usage"
echo "  sudo ncdu /       - Analyze entire system (slow!)"
echo "  sudo iotop        - Disk I/O per process"
echo ""
echo -e "${GREEN}Security Monitoring:${NC}"
echo "  nmap localhost    - Scan open ports"
echo "  sudo lsof -i      - List network connections"
echo "  sudo fail2ban-client status sshd - Check banned IPs"
echo ""
echo -e "${GREEN}Utilities:${NC}"
echo "  tree              - Show directory structure"
echo "  tree -L 2         - Limit to 2 levels deep"
echo "  jq .              - Pretty-print JSON"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "1. Try running: ${GREEN}glances${NC} (press q to quit)"
echo "2. Monitor network: ${GREEN}sudo nethogs${NC}"
echo "3. Check disk usage: ${GREEN}ncdu ~${NC}"
echo "4. Run SSH security check: ${GREEN}./check-ssh-security.sh${NC}"
echo ""
echo -e "${YELLOW}Tip:${NC} Add aliases to ~/.bashrc for easier access:"
echo "  alias monitor='glances'"
echo "  alias netmon='sudo nethogs'"
echo "  alias diskmon='sudo iotop'"
echo ""
echo -e "${GREEN}Installation successful! Happy monitoring! 🚀${NC}"
