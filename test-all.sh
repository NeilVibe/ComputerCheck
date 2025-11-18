#!/bin/bash
# test-all.sh - Comprehensive Test of Claude CLI Infrastructure
# Tests all TIER 1 infrastructure tools and validates JSON output

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}   CLAUDE CLI INFRASTRUCTURE - COMPREHENSIVE TEST${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""

test_count=0
pass_count=0
fail_count=0

# Function to run a test
run_test() {
    local name="$1"
    local command="$2"
    local description="$3"

    ((test_count++))
    echo -e "${YELLOW}[$test_count] Testing: $name${NC}"
    echo -e "${BLUE}Description: $description${NC}"
    echo -e "${BLUE}Command: $command${NC}"

    if eval "$command" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((pass_count++))
    else
        echo -e "${RED}✗ FAIL${NC}"
        ((fail_count++))
    fi
    echo ""
}

# Test tools.sh
echo -e "${BLUE}════ Testing tools.sh (Tool Discovery) ════${NC}"
echo ""

run_test "tools.sh --count" \
    "./tools.sh --count" \
    "Count total tools"

run_test "tools.sh --list" \
    "./tools.sh --list | head -20" \
    "List all tools (human-readable)"

run_test "tools.sh --list --json" \
    "./tools.sh --list --json | jq '.total_tools'" \
    "List all tools (JSON output)"

run_test "tools.sh --categories" \
    "./tools.sh --categories" \
    "List all categories"

run_test "tools.sh --help <tool>" \
    "./tools.sh --help deep-process-check" \
    "Get help for specific tool"

# Test run.sh
echo -e "${BLUE}════ Testing run.sh (Unified Runner) ════${NC}"
echo ""

run_test "run.sh --help" \
    "./run.sh --help" \
    "Show run.sh help"

run_test "run.sh performance tool" \
    "./run.sh performance memory-usage-check | head -20" \
    "Run a performance tool"

# Test check.sh
echo -e "${BLUE}════ Testing check.sh (Health Check) ════${NC}"
echo ""

run_test "check.sh --quick --json" \
    "./check.sh --quick --json | jq '.status'" \
    "Quick health check (JSON)"

run_test "check.sh parse with jq (.system)" \
    "./check.sh --quick --json 2>/dev/null | jq '.system'" \
    "Parse system stats"

run_test "check.sh parse with jq (.network)" \
    "./check.sh --quick --json 2>/dev/null | jq '.network.summary'" \
    "Parse network stats"

run_test "check.sh parse with jq (.top_memory_processes)" \
    "./check.sh --quick --json 2>/dev/null | jq '.top_memory_processes[0]'" \
    "Parse top processes"

run_test "check.sh --quick --text" \
    "./check.sh --quick --text | head -15" \
    "Quick health check (text)"

# Test analyze.sh
echo -e "${BLUE}════ Testing analyze.sh (Disk Analyzer) ════${NC}"
echo ""

run_test "analyze.sh --help" \
    "./analyze.sh --help | head -20" \
    "Show analyze.sh help"

run_test "analyze.sh --quick --json" \
    "./analyze.sh . --quick --json | jq '.summary'" \
    "Quick disk analysis (JSON)"

run_test "analyze.sh parse with jq" \
    "./analyze.sh . --quick --json 2>/dev/null | jq '.summary.used_gb'" \
    "Parse disk usage stats"

# Test Famous Linux Tools Integration
echo -e "${BLUE}════ Testing Famous Linux Tools ════${NC}"
echo ""

run_test "psutil (Python)" \
    "python3 -c 'import psutil; print(psutil.virtual_memory().percent)'" \
    "psutil - System stats library"

run_test "jq (JSON parser)" \
    "echo '{\"test\":123}' | jq '.test'" \
    "jq - THE JSON parser"

run_test "ncdu (disk analyzer)" \
    "ncdu --version" \
    "ncdu - THE disk space analyzer"

run_test "ss (network tool)" \
    "ss -tuln | head -5" \
    "ss - THE modern network tool"

run_test "htop (process viewer)" \
    "which htop" \
    "htop - THE process viewer"

# Test JSON Output Validity
echo -e "${BLUE}════ Testing JSON Output Validity ════${NC}"
echo ""

run_test "tools.sh JSON validity" \
    "./tools.sh --list --json | jq empty" \
    "Validate tools.sh JSON output"

run_test "check.sh JSON validity" \
    "./check.sh --quick --json 2>/dev/null | jq empty" \
    "Validate check.sh JSON output"

run_test "analyze.sh JSON validity" \
    "./analyze.sh . --quick --json 2>/dev/null | jq empty" \
    "Validate analyze.sh JSON output"

# Summary
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}   TEST SUMMARY${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}Total Tests:${NC} $test_count"
echo -e "${GREEN}Passed:${NC} $pass_count"
if [[ $fail_count -gt 0 ]]; then
    echo -e "${RED}Failed:${NC} $fail_count"
else
    echo -e "${GREEN}Failed:${NC} 0"
fi
echo ""

if [[ $fail_count -eq 0 ]]; then
    echo -e "${GREEN}✓ ALL TESTS PASSED! Infrastructure is ready!${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠ Some tests failed. Review output above.${NC}"
    exit 1
fi
