#!/bin/bash
# WSL CONTENT ANALYZER - READ ONLY - NO MODIFICATIONS
# Safely analyzes what's inside your WSL Ubuntu installation

echo "=========================================="
echo "📊 WSL UBUNTU CONTENT ANALYZER"
echo "🔒 READ ONLY - NO MODIFICATIONS"
echo "=========================================="
echo ""

# Analyze your home directory
echo "=== YOUR HOME DIRECTORY BREAKDOWN ==="
echo "Analyzing: $HOME"
echo ""

du -h "$HOME" 2>/dev/null | sort -hr | head -30 | awk '{
    size=$1
    path=$2
    # Make path relative to home
    sub(/^.*\/home\/[^\/]*\//, "~/", path)
    if (path == "$HOME") path = "~/"
    printf "  %10s  %s\n", size, path
}'
echo ""

# Find largest files in your home
echo "=== TOP 20 LARGEST FILES IN YOUR HOME ==="
find "$HOME" -type f -exec du -h {} + 2>/dev/null | sort -hr | head -20 | awk '{
    size=$1
    path=$2
    # Get filename
    cmd = "basename \"" path "\""
    cmd | getline name
    close(cmd)
    # Get relative path
    sub(/^.*\/home\/[^\/]*\//, "~/", path)
    printf "  %10s  %s\n", size, path
}'
echo ""

# Check /var (logs, cache, etc)
echo "=== /var DIRECTORY (logs, cache, etc) ==="
sudo du -h /var 2>/dev/null | sort -hr | head -15 | awk '{
    size=$1
    path=$2
    printf "  %10s  %s\n", size, path
}'
echo ""

# Check /tmp
echo "=== /tmp DIRECTORY ==="
TEMP_SIZE=$(sudo du -sh /tmp 2>/dev/null | awk '{print $1}')
echo "  Total /tmp size: $TEMP_SIZE"
echo ""

# Check /usr (installed software)
echo "=== /usr DIRECTORY (installed software) ==="
sudo du -h /usr 2>/dev/null | sort -hr | head -15 | awk '{
    size=$1
    path=$2
    printf "  %10s  %s\n", size, path
}'
echo ""

# Find big directories anywhere
echo "=== TOP 30 DIRECTORIES BY SIZE (ENTIRE WSL) ==="
echo "  (This shows you where your 405GB actually is)"
echo ""
sudo du -h / 2>/dev/null | grep -E '^[0-9]+G|^[0-9]{3,}M' | sort -hr | head -30 | awk '{
    size=$1
    path=$2
    printf "  %10s  %s\n", size, path
}'
echo ""

# File type breakdown
echo "=== FILE TYPE ANALYSIS (Your Home) ==="
echo "  Finding file types..."
echo ""

# Count and size by extension
find "$HOME" -type f 2>/dev/null | awk -F. '{print $NF}' | sort | uniq -c | sort -rn | head -20 | awk '{
    printf "  %8s files: .%s\n", $1, $2
}'
echo ""

# Large file types
echo "  Largest file types in your home:"
for ext in zip tar gz bz2 7z rar iso img vdi vhdx mp4 mkv avi mov jpg png pdf doc docx; do
    total=$(find "$HOME" -name "*.$ext" -type f -exec du -ch {} + 2>/dev/null | grep total | awk '{print $1}')
    if [ ! -z "$total" ] && [ "$total" != "0" ]; then
        printf "    %-6s files: %s\n" ".$ext" "$total"
    fi
done
echo ""

# Docker/container images if they exist
if [ -d "/var/lib/docker" ]; then
    echo "=== DOCKER DATA ==="
    DOCKER_SIZE=$(sudo du -sh /var/lib/docker 2>/dev/null | awk '{print $1}')
    echo "  Docker storage: $DOCKER_SIZE"
    echo ""
fi

# Snap packages
if [ -d "/var/lib/snapd" ]; then
    echo "=== SNAP PACKAGES ==="
    SNAP_SIZE=$(sudo du -sh /var/lib/snapd 2>/dev/null | awk '{print $1}')
    echo "  Snap storage: $SNAP_SIZE"
    echo ""
fi

# Summary
echo "=========================================="
echo "📋 SUMMARY"
echo "=========================================="
echo "This analysis shows WHERE your 405GB is:"
echo "  - Your home directory contents"
echo "  - System directories (/var, /usr, /tmp)"
echo "  - File types and their sizes"
echo ""
echo "🔒 NO FILES WERE MODIFIED"
echo "=========================================="
