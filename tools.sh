#!/bin/bash
# tools.sh - Tool Discovery System for Claude AI CLI
# Automatically discovers and catalogs all available diagnostic tools
# Provides help, listing, and JSON output for AI parsing

set -euo pipefail

# Project root directory
PROJECT_ROOT="/mnt/c/Users/MYCOM/Desktop/CheckComputer"
CATEGORIES_DIR="$PROJECT_ROOT/categories"

# Colors for output (when not JSON)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to discover all tools in categories
discover_tools() {
    local category="$1"
    local category_path="$CATEGORIES_DIR/$category"

    if [[ ! -d "$category_path" ]]; then
        return
    fi

    # Find all .ps1 files
    find "$category_path" -maxdepth 1 -name "*.ps1" -type f | while read -r tool_path; do
        local tool_name=$(basename "$tool_path" .ps1)
        echo "$category|$tool_name|$tool_path"
    done
}

# Function to get tool description from file header
get_tool_description() {
    local tool_path="$1"

    # Extract first comment line that looks like a description
    grep -m 1 "^#.*" "$tool_path" 2>/dev/null | sed 's/^#\s*//' || echo "No description available"
}

# Function to list all tools
list_tools() {
    local format="${1:-text}"

    if [[ "$format" == "json" ]]; then
        echo "{"
        echo '  "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",'
        echo '  "categories": {'
    fi

    local first_category=true
    for category in monitoring performance security utilities; do
        if [[ "$format" == "json" ]]; then
            if [[ "$first_category" == "false" ]]; then
                echo ","
            fi
            echo "    \"$category\": ["
            first_category=false
        else
            echo -e "${CYAN}═══════════════════════════════════════${NC}"
            echo -e "${GREEN}CATEGORY: ${YELLOW}$category${NC}"
            echo -e "${CYAN}═══════════════════════════════════════${NC}"
        fi

        local first_tool=true
        discover_tools "$category" | while IFS='|' read -r cat tool_name tool_path; do
            local description=$(get_tool_description "$tool_path")

            if [[ "$format" == "json" ]]; then
                if [[ "$first_tool" == "false" ]]; then
                    echo ","
                fi
                echo "      {"
                echo "        \"name\": \"$tool_name\","
                echo "        \"description\": \"$description\","
                echo "        \"path\": \"$tool_path\""
                echo -n "      }"
                first_tool=false
            else
                echo -e "  ${BLUE}$tool_name${NC}"
                echo -e "    ${description}"
                echo ""
            fi
        done

        if [[ "$format" == "json" ]]; then
            echo ""
            echo -n "    ]"
        fi
    done

    if [[ "$format" == "json" ]]; then
        echo ""
        echo "  },"
        echo '  "total_tools": '$(find "$CATEGORIES_DIR" -name "*.ps1" -type f | wc -l)
        echo "}"
    else
        echo -e "${CYAN}═══════════════════════════════════════${NC}"
        echo -e "${GREEN}Total tools: ${YELLOW}$(find "$CATEGORIES_DIR" -name "*.ps1" -type f | wc -l)${NC}"
    fi
}

# Function to show help for a specific tool
show_tool_help() {
    local tool_name="$1"
    local format="${2:-text}"

    # Search for tool in all categories
    local tool_path=""
    for category in monitoring performance security utilities; do
        local found_path="$CATEGORIES_DIR/$category/${tool_name}.ps1"
        if [[ -f "$found_path" ]]; then
            tool_path="$found_path"
            break
        fi
    done

    if [[ -z "$tool_path" ]]; then
        if [[ "$format" == "json" ]]; then
            echo '{"error": "Tool not found", "tool": "'$tool_name'"}'
        else
            echo -e "${RED}Error: Tool '$tool_name' not found${NC}"
        fi
        return 1
    fi

    if [[ "$format" == "json" ]]; then
        echo "{"
        echo '  "tool": "'$tool_name'",'
        echo '  "path": "'$tool_path'",'
        echo '  "description": "'$(get_tool_description "$tool_path")'",'
        echo '  "help": ['

        # Extract comment block from top of file
        local first=true
        grep "^#" "$tool_path" | head -20 | while read -r line; do
            if [[ "$first" == "false" ]]; then
                echo ","
            fi
            echo -n "    \"$(echo "$line" | sed 's/^#\s*//' | sed 's/"/\\"/g')\""
            first=false
        done

        echo ""
        echo "  ]"
        echo "}"
    else
        echo -e "${CYAN}═══════════════════════════════════════${NC}"
        echo -e "${GREEN}Tool: ${YELLOW}$tool_name${NC}"
        echo -e "${CYAN}═══════════════════════════════════════${NC}"
        echo -e "${BLUE}Path:${NC} $tool_path"
        echo -e "${BLUE}Description:${NC} $(get_tool_description "$tool_path")"
        echo ""
        echo -e "${BLUE}Help:${NC}"
        grep "^#" "$tool_path" | head -20 | sed 's/^#\s*/  /'
        echo ""
        echo -e "${BLUE}Usage:${NC}"
        echo "  ./run.sh $(basename $(dirname "$tool_path")) $tool_name [options]"
    fi
}

# Function to show usage
show_usage() {
    cat << EOF
${GREEN}tools.sh - Tool Discovery System${NC}

${YELLOW}USAGE:${NC}
  ./tools.sh --list [--json]          List all available tools
  ./tools.sh --help <tool-name>       Show help for a specific tool
  ./tools.sh --categories             List all categories
  ./tools.sh --count                  Count total tools
  ./tools.sh --json                   Output everything as JSON

${YELLOW}EXAMPLES:${NC}
  ./tools.sh --list                   # List all tools (human-readable)
  ./tools.sh --list --json            # List all tools (JSON for AI)
  ./tools.sh --help malware-scan      # Show help for malware-scan tool
  ./tools.sh --count                  # Show total tool count

${YELLOW}FOR CLAUDE AI:${NC}
  Use --json flag for all commands to get parseable output
  Example: ./tools.sh --list --json | jq '.categories.security'

EOF
}

# Main logic
main() {
    local command="${1:-}"
    local arg2="${2:-}"
    local arg3="${3:-}"

    # Determine output format
    local format="text"
    if [[ "$arg2" == "--json" ]] || [[ "$arg3" == "--json" ]] || [[ "$command" == "--json" ]]; then
        format="json"
    fi

    case "$command" in
        --list)
            list_tools "$format"
            ;;
        --help)
            if [[ -z "$arg2" ]]; then
                echo -e "${RED}Error: Please specify a tool name${NC}"
                echo "Usage: ./tools.sh --help <tool-name>"
                exit 1
            fi
            show_tool_help "$arg2" "$format"
            ;;
        --categories)
            if [[ "$format" == "json" ]]; then
                echo '{"categories": ["monitoring", "performance", "security", "utilities"]}'
            else
                echo -e "${GREEN}Available Categories:${NC}"
                echo "  - monitoring"
                echo "  - performance"
                echo "  - security"
                echo "  - utilities"
            fi
            ;;
        --count)
            local count=$(find "$CATEGORIES_DIR" -name "*.ps1" -type f | wc -l)
            if [[ "$format" == "json" ]]; then
                echo '{"total_tools": '$count'}'
            else
                echo -e "${GREEN}Total tools: ${YELLOW}$count${NC}"
            fi
            ;;
        --json)
            # Full catalog in JSON
            list_tools "json"
            ;;
        "")
            show_usage
            ;;
        *)
            echo -e "${RED}Error: Unknown command '$command'${NC}"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
