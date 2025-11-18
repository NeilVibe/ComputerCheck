#!/bin/bash
# SPACE SNIFFER - Find what's eating your disk space!
# Usage: ./space-sniffer.sh [path]
# Default: Analyzes E: drive and WSL Ubuntu

TARGET_PATH="${1:-/mnt/e}"

echo "============================================"
echo "🔍 SPACE SNIFFER - Disk Usage Analyzer"
echo "============================================"
echo ""

# Check if path exists
if [ ! -d "$TARGET_PATH" ]; then
    echo "❌ Error: Path $TARGET_PATH does not exist!"
    exit 1
fi

echo "📂 Target: $TARGET_PATH"
echo ""

# 1. Overall disk space
echo "=== DISK SPACE OVERVIEW ==="
df -h "$TARGET_PATH" | awk 'NR==1 {print "  "$0} NR==2 {printf "  %-20s %8s %8s %8s %6s %s\n", $1, $2, $3, $4, $5, $6}'
echo ""

# 2. Top-level directory sizes
echo "=== TOP-LEVEL DIRECTORIES (Sorted by Size) ==="
echo "  Calculating sizes... (this may take a moment)"
echo ""

du -sh "$TARGET_PATH"/* 2>/dev/null | sort -hr | head -20 | awk '{
    size=$1
    path=$2
    # Extract just the directory name
    cmd = "basename \"" path "\""
    cmd | getline name
    close(cmd)
    printf "  %8s  %s\n", size, name
}'
echo ""

# 3. If Ubuntu folder exists, analyze it
UBUNTU_PATH="$TARGET_PATH/Ubuntu"
if [ -d "$UBUNTU_PATH" ]; then
    echo "=== WSL UBUNTU ANALYSIS ==="

    # Total Ubuntu size
    UBUNTU_SIZE=$(du -sh "$UBUNTU_PATH" 2>/dev/null | awk '{print $1}')
    echo "  Total Ubuntu WSL Size: $UBUNTU_SIZE"
    echo ""

    # Top directories in Ubuntu
    echo "  Top 15 directories in Ubuntu:"
    du -h "$UBUNTU_PATH" 2>/dev/null | sort -hr | head -15 | awk '{
        size=$1
        path=$2
        # Make path relative and shorter
        sub(/^.*Ubuntu\//, "", path)
        if (path == "") path = "."
        printf "    %8s  %s\n", size, path
    }'
    echo ""

    # Find largest files in Ubuntu
    echo "  Top 10 largest files in Ubuntu:"
    find "$UBUNTU_PATH" -type f -exec du -h {} + 2>/dev/null | sort -hr | head -10 | awk '{
        size=$1
        path=$2
        # Make path relative
        sub(/^.*Ubuntu\//, "", path)
        printf "    %8s  %s\n", size, path
    }'
    echo ""
fi

# 4. Find biggest files on entire E: drive
echo "=== TOP 20 LARGEST FILES ON E: ==="
echo "  Searching for biggest files... (this takes time!)"
find "$TARGET_PATH" -type f -exec du -h {} + 2>/dev/null | sort -hr | head -20 | awk '{
    size=$1
    path=$2
    # Extract just the filename
    cmd = "basename \"" path "\""
    cmd | getline name
    close(cmd)
    # Extract directory
    cmd2 = "dirname \"" path "\""
    cmd2 | getline dir
    close(cmd2)
    # Shorten directory path
    sub(/^\/mnt\/e\//, "", dir)
    printf "  %8s  %-30s  %s\n", size, name, dir
}'
echo ""

# 5. Hidden space eaters
echo "=== COMMON SPACE WASTERS ==="

# Check Recycle Bin
if [ -d "$TARGET_PATH/\$RECYCLE.BIN" ]; then
    RECYCLE_SIZE=$(du -sh "$TARGET_PATH/\$RECYCLE.BIN" 2>/dev/null | awk '{print $1}')
    echo "  🗑️  Recycle Bin: $RECYCLE_SIZE"
fi

# Check for log files
LOG_SIZE=$(find "$TARGET_PATH" -name "*.log" -type f -exec du -ch {} + 2>/dev/null | grep total | awk '{print $1}')
if [ ! -z "$LOG_SIZE" ] && [ "$LOG_SIZE" != "0" ]; then
    echo "  📋 Log files (.log): $LOG_SIZE"
fi

# Check for temp files
TEMP_SIZE=$(find "$TARGET_PATH" -name "*.tmp" -o -name "*.temp" -type f -exec du -ch {} + 2>/dev/null | grep total | awk '{print $1}')
if [ ! -z "$TEMP_SIZE" ] && [ "$TEMP_SIZE" != "0" ]; then
    echo "  🔄 Temp files (.tmp/.temp): $TEMP_SIZE"
fi

# Check for cache directories
CACHE_DIRS=$(find "$TARGET_PATH" -type d -name "cache" -o -name "Cache" 2>/dev/null | wc -l)
if [ "$CACHE_DIRS" -gt 0 ]; then
    echo "  📦 Cache directories found: $CACHE_DIRS"
fi

echo ""

# 6. Summary and recommendations
echo "=== SUMMARY & RECOMMENDATIONS ==="
TOTAL_USED=$(df -h "$TARGET_PATH" | awk 'NR==2 {print $3}')
TOTAL_SIZE=$(df -h "$TARGET_PATH" | awk 'NR==2 {print $2}')
PERCENT_USED=$(df -h "$TARGET_PATH" | awk 'NR==2 {print $5}' | tr -d '%')

echo "  Drive E: is using $TOTAL_USED of $TOTAL_SIZE ($PERCENT_USED%)"
echo ""

if [ "$PERCENT_USED" -gt 90 ]; then
    echo "  ⚠️  WARNING: Drive is over 90% full!"
    echo "  Quick wins:"
    echo "    - Empty Recycle Bin"
    echo "    - Delete old downloads"
    echo "    - Clear application caches"
elif [ "$PERCENT_USED" -gt 75 ]; then
    echo "  ⚡ Drive is getting full (>75%)"
    echo "  Consider cleaning up large files"
else
    echo "  ✅ Drive has healthy free space"
fi

echo ""
echo "============================================"
echo "💡 TIP: To analyze a specific folder:"
echo "   ./space-sniffer.sh /mnt/e/Ubuntu"
echo "============================================"
