#!/bin/bash
# analyze.sh - Disk Space Analyzer using ncdu (THE famous disk tool!)
# Analyzes disk usage and outputs JSON for Claude AI
# Can analyze Windows drives via /mnt/ or Linux directories

set -euo pipefail

NCDU_CMD="ncdu"
PYTHON_CMD="python3"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Function to get disk usage summary using psutil
get_disk_summary() {
    local path="$1"

    $PYTHON_CMD << EOF
import psutil
import json
import os

try:
    usage = psutil.disk_usage("$path")
    print(json.dumps({
        "path": "$path",
        "total_gb": round(usage.total / (1024**3), 2),
        "used_gb": round(usage.used / (1024**3), 2),
        "free_gb": round(usage.free / (1024**3), 2),
        "percent_used": round(usage.percent, 1)
    }))
except Exception as e:
    print(json.dumps({"error": str(e)}))
EOF
}

# Function to analyze top directories using du (fast!)
get_top_directories() {
    local path="$1"
    local count="${2:-10}"

    $PYTHON_CMD << EOF
import subprocess
import json
import os

try:
    # Use du to get directory sizes (fast!)
    result = subprocess.run(
        ['du', '-sh', '$path/*'],
        shell=True,
        capture_output=True,
        text=True,
        timeout=10
    )

    dirs = []
    for line in result.stdout.strip().split('\n'):
        if line:
            parts = line.split('\t', 1)
            if len(parts) == 2:
                size, path = parts
                dirs.append({"size": size, "path": path})

    # Sort by size (simple heuristic: K < M < G < T)
    def size_sort_key(item):
        s = item['size']
        if 'T' in s: return (4, float(s.replace('T', '')))
        if 'G' in s: return (3, float(s.replace('G', '')))
        if 'M' in s: return (2, float(s.replace('M', '')))
        if 'K' in s: return (1, float(s.replace('K', '')))
        return (0, float(s.replace('B', '')))

    dirs_sorted = sorted(dirs, key=size_sort_key, reverse=True)[:$count]
    print(json.dumps(dirs_sorted))
except Exception as e:
    print(json.dumps({"error": str(e)}))
EOF
}

# Function to run ncdu interactively
run_ncdu_interactive() {
    local path="$1"

    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${GREEN}Running ncdu (interactive)${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${YELLOW}Controls:${NC}"
    echo "  ↑↓  - Navigate"
    echo "  →   - Enter directory"
    echo "  ←   - Go back"
    echo "  d   - Delete (WE WON'T USE THIS!)"
    echo "  q   - Quit"
    echo ""
    echo -e "${BLUE}Analyzing: ${YELLOW}$path${NC}"
    echo ""

    $NCDU_CMD "$path"
}

# Quick analysis (JSON output)
quick_analyze() {
    local path="$1"
    local format="${2:-json}"

    # Get summary
    local summary=$(get_disk_summary "$path")

    # Get top directories
    local top_dirs=$(get_top_directories "$path" 10)

    if [[ "$format" == "json" ]]; then
        cat << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "target": "$path",
  "summary": $summary,
  "top_directories": $top_dirs
}
EOF
    else
        echo -e "${CYAN}═══════════════════════════════════════${NC}"
        echo -e "${GREEN}Disk Analysis: ${YELLOW}$path${NC}"
        echo -e "${CYAN}═══════════════════════════════════════${NC}"
        echo ""
        echo "$summary" | $PYTHON_CMD -m json.tool
        echo ""
        echo -e "${BLUE}Top 10 Directories:${NC}"
        echo "$top_dirs" | $PYTHON_CMD -c "import sys, json; [print(f\"  {d['size']:>8} {d['path']}\") for d in json.load(sys.stdin)]"
    fi
}

# Show usage
show_usage() {
    cat << EOF
${GREEN}analyze.sh - Disk Space Analyzer${NC}

${YELLOW}USAGE:${NC}
  ./analyze.sh [path] [--quick|--interactive] [--json|--text]

${YELLOW}OPTIONS:${NC}
  --quick         Fast analysis with summary (default)
  --interactive   Run ncdu interactively (visual browser)
  --json          Output as JSON (default for --quick)
  --text          Output human-readable text
  --help          Show this help

${YELLOW}EXAMPLES:${NC}
  # Analyze current directory (quick)
  ./analyze.sh .

  # Analyze WSL home directory (find that 405GB!)
  ./analyze.sh /home/neil1988 --quick --json

  # Analyze Windows C drive
  ./analyze.sh /mnt/c --quick --json

  # Analyze E drive interactively (WSL vhdx location)
  ./analyze.sh /mnt/e/Ubuntu --interactive

  # Quick analysis of specific directory
  ./analyze.sh /var/log --quick --text

${YELLOW}FOR CLAUDE AI:${NC}
  # Get JSON analysis
  ./analyze.sh /home/neil1988 --quick --json

  # Parse with jq
  ./analyze.sh /home/neil1988 --quick --json | jq '.summary.used_gb'

${YELLOW}FAMOUS TOOLS USED:${NC}
  - ${GREEN}ncdu${NC} - THE disk space analyzer (interactive mode)
  - ${GREEN}psutil${NC} - Cross-platform disk stats (Python)
  - ${GREEN}du${NC} - Linux disk usage (fast directory scanning)

${YELLOW}NO ACTIONS TAKEN:${NC}
  - Read-only analysis
  - Will NEVER delete anything automatically
  - Even in interactive mode, you must confirm deletions

${YELLOW}COMMON TARGETS:${NC}
  /home/neil1988           - Your WSL home (likely has big files!)
  /mnt/e/Ubuntu            - Where your WSL vhdx lives
  /mnt/c/Users/MYCOM       - Your Windows user folder
  ~/.cache                 - Python/pip caches
  ~/anaconda3              - Conda environments

EOF
}

# Main
main() {
    local path="${1:-.}"
    local mode="quick"
    local format="json"

    # Parse arguments
    for arg in "$@"; do
        case "$arg" in
            --help|-h)
                show_usage
                exit 0
                ;;
            --quick)
                mode="quick"
                ;;
            --interactive)
                mode="interactive"
                ;;
            --json)
                format="json"
                ;;
            --text)
                format="text"
                ;;
            --*)
                echo -e "${RED}Error: Unknown option '$arg'${NC}"
                show_usage
                exit 1
                ;;
        esac
    done

    # Validate path
    if [[ ! -d "$path" ]]; then
        echo -e "${RED}Error: Path '$path' does not exist or is not a directory${NC}"
        exit 1
    fi

    # Run analysis
    if [[ "$mode" == "interactive" ]]; then
        run_ncdu_interactive "$path"
    else
        quick_analyze "$path" "$format"
    fi
}

main "$@"
