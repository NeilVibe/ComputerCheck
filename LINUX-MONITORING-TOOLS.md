# Linux Monitoring Tools - Complete Guide

**Purpose:** Transform your Linux/WSL into a monitoring powerhouse!
**Status:** Installation guide + usage examples
**All tools:** Free, open source, lightweight

---

## Quick Install - The Essentials

```bash
# Install all recommended monitoring tools (one command!)
sudo apt update && sudo apt install -y \
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
  tree

# Takes ~5 minutes, ~100 MB disk space
```

---

## The Tools Explained

### 1. System Monitoring

#### htop - Interactive Process Viewer
**What it does:** Beautiful, real-time system monitor
**Better than:** `top` (boring, text-only)

```bash
# Just run it
htop

# Shows:
# - All processes with CPU/RAM usage
# - Color-coded bars
# - Easy sorting (F6)
# - Kill processes (F9)
# - Tree view (F5)
```

**Use case:** Daily system health check, find resource hogs

---

#### glances - All-in-One System Monitor
**What it does:** htop + network + disk + sensors in ONE view
**The ULTIMATE system monitor!**

```bash
# Run glances
glances

# Shows EVERYTHING:
# - CPU, RAM, SWAP
# - Network I/O
# - Disk I/O
# - Processes
# - Sensors (temp, fan)
# - Alerts (red when high)

# Web mode (access from browser!)
glances -w
# Then open: http://localhost:61208
```

**Use case:** Complete system overview, performance monitoring

---

#### sysstat (sar, iostat, mpstat)
**What it does:** Historical performance data

```bash
# CPU stats
mpstat

# Disk I/O stats
iostat -x

# All stats with history
sar -A

# Enable data collection (automatic)
sudo systemctl enable sysstat
sudo systemctl start sysstat
```

**Use case:** Track performance over time, identify trends

---

### 2. Network Monitoring

#### nethogs - Network Usage Per Process
**What it does:** Shows which process uses most bandwidth

```bash
# Run nethogs
sudo nethogs

# Shows:
# - Chrome using 5 MB/s
# - SSH using 100 KB/s
# - Each process's upload/download
```

**Use case:** Find bandwidth hogs, network troubleshooting

---

#### iftop - Real-Time Network Traffic
**What it does:** Shows connections and bandwidth in real-time

```bash
# Monitor main interface
sudo iftop

# Specific interface
sudo iftop -i eth0

# Shows:
# - All active connections
# - Bandwidth per connection
# - Upload/download rates
# - Running totals
```

**Use case:** Network traffic analysis, bandwidth monitoring

---

#### bmon - Bandwidth Monitor
**What it does:** Beautiful network interface statistics

```bash
# Run bmon
bmon

# Shows:
# - All network interfaces
# - Real-time graphs
# - Traffic history
# - Easy navigation
```

**Use case:** Visual network monitoring, interface comparison

---

#### vnstat - Network Traffic Logger
**What it does:** Tracks bandwidth usage over time

```bash
# Show traffic summary
vnstat

# Hourly stats
vnstat -h

# Daily stats
vnstat -d

# Monthly stats
vnstat -m

# Enable monitoring
sudo systemctl enable vnstat
sudo systemctl start vnstat
```

**Use case:** Long-term bandwidth tracking, monthly usage reports

---

#### mtr - Advanced Traceroute
**What it does:** Combines ping + traceroute

```bash
# Trace route to Google
mtr google.com

# Shows:
# - All hops to destination
# - Packet loss per hop
# - Latency per hop
# - Real-time updates
```

**Use case:** Network path analysis, latency troubleshooting

---

#### tcpdump - Packet Capture
**What it does:** Capture and analyze network packets

```bash
# Capture all traffic
sudo tcpdump

# Capture SSH traffic
sudo tcpdump port 22

# Capture to file
sudo tcpdump -w capture.pcap

# Read capture file
sudo tcpdump -r capture.pcap
```

**Use case:** Deep packet inspection, attack analysis

---

### 3. Disk Monitoring

#### ncdu - NCurses Disk Usage
**What it does:** Find what's eating disk space (interactive!)

```bash
# Scan home directory
ncdu ~

# Scan entire system (slow!)
sudo ncdu /

# Navigate:
# - Up/Down arrows to browse
# - Enter to go into folder
# - d to delete files
# - q to quit
```

**Use case:** Find large files/folders, clean up disk

---

#### iotop - Disk I/O Monitor
**What it does:** Shows disk read/write per process

```bash
# Run iotop
sudo iotop

# Shows:
# - Which processes are writing to disk
# - Read/write speeds
# - Total I/O
```

**Use case:** Find processes hammering disk, performance issues

---

### 4. Security Monitoring

#### nmap - Network Scanner
**What it does:** Scan networks and ports

```bash
# Scan your local machine
nmap localhost

# Scan local network
nmap 192.168.1.0/24

# Check open ports
nmap -p 1-65535 localhost

# OS detection
sudo nmap -O localhost
```

**Use case:** Security audits, port scanning, network discovery

---

#### lsof - List Open Files
**What it does:** Show all open files and network connections

```bash
# All open files
sudo lsof

# Files opened by user
lsof -u neil1988

# Network connections
sudo lsof -i

# Specific port
sudo lsof -i :22

# What's using a file?
sudo lsof /var/log/auth.log
```

**Use case:** See what files/ports are in use, troubleshooting

---

#### strace - System Call Tracer
**What it does:** See what a process is actually doing

```bash
# Trace a command
strace ls

# Trace running process
sudo strace -p 1234

# Save to file
strace -o trace.txt ls
```

**Use case:** Debug programs, see file/network access

---

### 5. Utility Tools

#### jq - JSON Processor
**What it does:** Parse and format JSON

```bash
# Pretty-print JSON
cat data.json | jq '.'

# Extract field
cat data.json | jq '.field'

# Filter results
cat data.json | jq '.[] | select(.name == "test")'
```

**Use case:** Process API responses, parse config files

---

#### tree - Directory Tree Viewer
**What it does:** Show directory structure visually

```bash
# Show directory tree
tree

# Limit depth
tree -L 2

# Show hidden files
tree -a

# Save to file
tree > structure.txt
```

**Use case:** Visualize project structure, documentation

---

#### dstat - Versatile Resource Statistics
**What it does:** Combines vmstat, iostat, netstat, ifstat

```bash
# Basic stats
dstat

# CPU and network
dstat -c -n

# All stats
dstat -a

# Every 5 seconds
dstat 5
```

**Use case:** Quick system overview, performance monitoring

---

## Advanced Monitoring (Optional)

### Prometheus + Grafana
**What it does:** Professional monitoring dashboard
**Best for:** Long-term monitoring, graphs, alerts

```bash
# Install Prometheus
sudo apt install prometheus -y

# Install Grafana
sudo apt install grafana -y

# Access Grafana
# Open: http://localhost:3000
```

**Use case:** Enterprise-grade monitoring, beautiful dashboards

---

### Netdata - Real-Time Monitoring
**What it does:** Auto-detecting, real-time monitoring
**Beautiful web interface!**

```bash
# Install Netdata
bash <(curl -Ss https://my-netdata.io/kickstart.sh)

# Access web interface
# Open: http://localhost:19999
```

**Use case:** Real-time web-based monitoring, zero config

---

## Monitoring Scripts to Create

### 1. system-health-check.sh
```bash
#!/bin/bash
# Check: CPU, RAM, Disk, Network, Processes
glances --time 5 --export-stdout | jq '.'
```

### 2. network-monitor.sh
```bash
#!/bin/bash
# Monitor network in real-time
nethogs & iftop
```

### 3. disk-usage-alert.sh
```bash
#!/bin/bash
# Alert if disk >90%
USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $USAGE -gt 90 ]; then
  echo "WARNING: Disk usage at ${USAGE}%!"
fi
```

### 4. attack-monitor.sh (already planned!)
```bash
#!/bin/bash
# Monitor SSH attacks live
tail -f /var/log/auth.log | grep "Failed password"
```

---

## Installation Script

### install-monitoring-tools.sh

```bash
#!/bin/bash

echo "Installing Linux Monitoring Tools..."
echo ""

# Update package list
sudo apt update

# Install essentials
echo "Installing essential monitoring tools..."
sudo apt install -y \
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
  tree

# Enable services
echo "Enabling monitoring services..."
sudo systemctl enable vnstat 2>/dev/null
sudo systemctl start vnstat 2>/dev/null
sudo systemctl enable sysstat 2>/dev/null
sudo systemctl start sysstat 2>/dev/null

echo ""
echo "Installation complete!"
echo ""
echo "Available tools:"
echo "  htop          - Interactive process viewer"
echo "  glances       - All-in-one system monitor"
echo "  nethogs       - Network usage per process"
echo "  iftop         - Real-time network traffic"
echo "  ncdu          - Disk usage analyzer"
echo "  vnstat        - Network traffic logger"
echo "  nmap          - Network scanner"
echo ""
echo "Try: htop"
echo "Try: glances"
echo "Try: sudo nethogs"
echo ""
```

---

## Recommended Daily Checks

### Morning System Check:
```bash
# 1. System overview
glances --time 10

# 2. Disk usage
ncdu ~

# 3. Network traffic (yesterday)
vnstat -d

# 4. SSH attacks
sudo grep "Failed" /var/log/auth.log | grep "$(date +%b\ %d)" | wc -l
```

### Weekly Deep Dive:
```bash
# 1. Open ports
nmap localhost

# 2. Network connections
sudo lsof -i

# 3. Disk I/O
sudo iotop -b -n 3

# 4. Historical stats
sar -A
```

---

## Pro Tips

### Combine Tools:
```bash
# Watch specific process
watch -n 1 'ps aux | grep process_name'

# Monitor SSH attempts live
watch -n 1 'sudo tail -20 /var/log/auth.log | grep Failed'

# Network + Disk together
tmux split-window -h 'sudo nethogs' \; split-window -v 'sudo iotop'
```

### Create Aliases:
```bash
# Add to ~/.bashrc
alias monitor='glances'
alias netmon='sudo nethogs'
alias diskmon='sudo iotop'
alias attacks='sudo tail -f /var/log/auth.log | grep Failed'
```

---

## Resource Usage

| Tool | RAM | CPU | Disk |
|------|-----|-----|------|
| htop | ~5 MB | <1% | 0 MB |
| glances | ~30 MB | <2% | 0 MB |
| nethogs | ~10 MB | <1% | 0 MB |
| vnstat | ~2 MB | <0.1% | 1 MB |
| fail2ban | ~20 MB | <1% | 0 MB |

**Total:** ~70 MB RAM for ALL tools (negligible!)

---

## Summary

### Essential Tools (Install These):
- ✅ htop (process monitoring)
- ✅ glances (everything monitor)
- ✅ nethogs (network per-process)
- ✅ ncdu (disk usage)
- ✅ vnstat (traffic logging)
- ✅ fail2ban (already installed!)

### Advanced Tools (Optional):
- Netdata (web dashboard)
- Prometheus + Grafana (enterprise monitoring)
- tcpdump (packet analysis)
- nmap (security scanning)

### Scripts to Create:
1. system-health-check.sh
2. network-monitor.sh
3. disk-usage-alert.sh
4. attack-monitor.sh
5. unified-monitor.sh

**Everything free, lightweight, professional-grade!** 🚀

---

**Next:** Create install-monitoring-tools.sh and start building monitoring scripts!
