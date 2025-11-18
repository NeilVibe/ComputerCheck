#!/bin/bash
# run.sh - Unified Command Runner for Claude AI CLI
# Runs any tool from any category with consistent interface
# Handles WSL/Windows path translation automatically

set -euo pipefail

# Project configuration
PROJECT_ROOT="/home/neil1988/CheckComputer"
CATEGORIES_DIR="$PROJECT_ROOT/categories"
POWERSHELL_CMD="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to show usage
show_usage() {
    cat << EOF
${GREEN}run.sh - Unified Tool Runner${NC}

${YELLOW}USAGE:${NC}
  ./run.sh <category> <tool> [tool-arguments...]

${YELLOW}CATEGORIES:${NC}
  monitoring   - Event logs, USB devices, dangerous events
  performance  - Memory, CPU, vmmem checks
  security     - Process scanning, registry audits, file monitoring
  utilities    - Drive checks, service management

${YELLOW}EXAMPLES:${NC}
  # Run security tool
  ./run.sh security deep-process-check

  # Run with arguments (if tool supports them)
  ./run.sh performance memory-usage-check

  # List available tools
  ./tools.sh --list

  # Get help for a specific tool
  ./tools.sh --help deep-process-check

${YELLOW}EXIT CODES:${NC}
  0 - Success
  1 - General error
  2 - Warning (completed with issues)
  3 - Missing dependencies
  4 - Permission denied
  5 - Invalid arguments

EOF
}

# Function to find tool path
find_tool() {
    local category="$1"
    local tool="$2"

    local tool_path="$CATEGORIES_DIR/$category/${tool}.ps1"

    if [[ ! -f "$tool_path" ]]; then
        return 1
    fi

    echo "$tool_path"
}

# Function to run PowerShell script
run_powershell() {
    local script_path="$1"
    shift
    local args=("$@")

    # Convert WSL path to Windows path
    local windows_path=$(echo "$script_path" | sed 's|^/mnt/c/|C:\\|' | sed 's|/|\\|g')

    # Build command
    local ps_args="-NoProfile -ExecutionPolicy Bypass -File \"$windows_path\""

    # Add tool arguments if provided
    for arg in "${args[@]}"; do
        ps_args="$ps_args \"$arg\""
    done

    # Execute
    eval "$POWERSHELL_CMD $ps_args"
    return $?
}

# Main logic
main() {
    if [[ $# -lt 2 ]]; then
        echo -e "${RED}Error: Missing arguments${NC}"
        echo ""
        show_usage
        exit 5
    fi

    local category="$1"
    local tool="$2"
    shift 2
    local tool_args=("$@")

    # Validate category
    if [[ ! -d "$CATEGORIES_DIR/$category" ]]; then
        echo -e "${RED}Error: Unknown category '$category'${NC}"
        echo -e "${YELLOW}Valid categories: monitoring, performance, security, utilities${NC}"
        exit 5
    fi

    # Find tool
    local tool_path=$(find_tool "$category" "$tool") || {
        echo -e "${RED}Error: Tool '$tool' not found in category '$category'${NC}"
        echo -e "${YELLOW}Tip: Use './tools.sh --list' to see all available tools${NC}"
        exit 1
    }

    # Show what we're running
    echo -e "${BLUE}Running:${NC} $category/$tool"
    echo -e "${BLUE}Path:${NC} $tool_path"
    if [[ ${#tool_args[@]} -gt 0 ]]; then
        echo -e "${BLUE}Args:${NC} ${tool_args[*]}"
    fi
    echo ""

    # Run the tool
    if [[ "$tool_path" == *.ps1 ]]; then
        run_powershell "$tool_path" "${tool_args[@]}"
        exit_code=$?
    elif [[ "$tool_path" == *.sh ]]; then
        # For future bash scripts
        bash "$tool_path" "${tool_args[@]}"
        exit_code=$?
    else
        echo -e "${RED}Error: Unknown script type${NC}"
        exit 1
    fi

    # Return tool's exit code
    exit $exit_code
}

# Handle --help flag
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    show_usage
    exit 0
fi

main "$@"
