#!/bin/bash
# =============================================================================
# run_all_tests.sh — Run all test cases with FSDB dumping and log collection
#
# Usage:
#   ./run_all_tests.sh              # Run all tests
#   ./run_all_tests.sh sanity       # Run only sanity
#   ./run_all_tests.sh p0 p1 p2     # Run specific levels
#
# Output:
#   logs/
#     sanity.log
#     directed_dt01.log
#     ... (one per test)
#     summary.rpt
#   waves/
#     sanity.fsdb
#     directed_dt01.fsdb
#     ... (one per test)
# =============================================================================

set -e

REPO_ROOT="$(cd .. && pwd)"
SIM_DIR="$(cd . && pwd)"
LOG_DIR="${SIM_DIR}/logs"
WAVE_DIR="${SIM_DIR}/waves"

# Create output directories
mkdir -p "${LOG_DIR}"
mkdir -p "${WAVE_DIR}"

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test lists (name, cfg_file, testname)
declare -a TESTS_P0=(
    "sanity|${REPO_ROOT}/tb/cfg/sanity.cfg|deu_sanity_test"
)

declare -a TESTS_P1=(
    "directed_dt01|${REPO_ROOT}/tb/cfg/directed_dt01.cfg|deu_base_test"
    "directed_full_valid|${REPO_ROOT}/tb/cfg/directed_full_valid.cfg|deu_base_test"
    "pipeline_timing|${REPO_ROOT}/tb/cfg/pipeline_timing.cfg|deu_base_test"
)

declare -a TESTS_P2=(
    "random_full|${REPO_ROOT}/tb/cfg/random_full.cfg|deu_random_test"
    "random_vld_toggle|${REPO_ROOT}/tb/cfg/random_vld_toggle.cfg|deu_random_test"
)

# Parse arguments
RUN_P0=0
RUN_P1=0
RUN_P2=0

if [ $# -eq 0 ]; then
    RUN_P0=1
    RUN_P1=1
    RUN_P2=1
else
    for arg in "$@"; do
        case "$arg" in
            p0|sanity) RUN_P0=1 ;;
            p1) RUN_P1=1 ;;
            p2) RUN_P2=1 ;;
            *) echo "Unknown test level: $arg"; exit 1 ;;
        esac
    done
fi

# Function to run a single test
run_test() {
    local test_name=$1
    local cfg_file=$2
    local testname=$3
    local log_file="${LOG_DIR}/${test_name}.log"
    local wave_file="${WAVE_DIR}/${test_name}.fsdb"

    echo -e "${YELLOW}[RUN] ${test_name}${NC}"

    # Run test with FSDB output, pipe stdout/stderr to log
    # Directly call the simulator if already built, or compile+run if not
    local test_result=0
    if [ ! -f "${SIM_DIR}/simv" ]; then
        # First test run — compile + simulate
        if (cd "${SIM_DIR}" && make -B run TESTNAME="${testname}" CFG="${cfg_file}" FSDB=1) \
            > "${log_file}" 2>&1; then
            test_result=0
        else
            test_result=1
        fi
    else
        # Subsequent runs — just change cfg and run (recompile only if needed)
        if (cd "${SIM_DIR}" && "${SIM_DIR}/simv" +UVM_TESTNAME="${testname}" \
            +UVM_VERBOSITY=UVM_MEDIUM +ntb_random_seed=1 +cfg="${cfg_file}" \
            +fsdbfile="${SIM_DIR}/waves.fsdb") \
            > "${log_file}" 2>&1; then
            test_result=0
        else
            test_result=1
        fi
    fi

    # Check result and report
    if [ $test_result -eq 0 ]; then
        # Check if test passed by looking for PASSED in log
        if grep -q "TESTCASE PASSED" "${log_file}"; then
            echo -e "${GREEN}[PASS] ${test_name}${NC}"
            echo "PASS" >> "${LOG_DIR}/summary.txt"
        else
            echo -e "${RED}[FAIL] ${test_name} (check log)${NC}"
            echo "FAIL" >> "${LOG_DIR}/summary.txt"
        fi
    else
        echo -e "${RED}[FAIL] ${test_name} (compilation/runtime error)${NC}"
        echo "FAIL" >> "${LOG_DIR}/summary.txt"
    fi

    # Move wave file to waves directory
    if [ -f "${SIM_DIR}/waves.fsdb" ]; then
        mv "${SIM_DIR}/waves.fsdb" "${wave_file}"
        echo "  Wave: ${wave_file}"
    fi
}

# Main execution
echo "================================================================================"
echo "  DEU UVM Test Suite — All Tests with FSDB Waveforms"
echo "================================================================================"
echo ""

# Initialize summary
rm -f "${LOG_DIR}/summary.txt"
touch "${LOG_DIR}/summary.txt"

total_tests=0
declare -a all_tests

# P0 Tests
if [ $RUN_P0 -eq 1 ]; then
    echo -e "${YELLOW}=== P0 (Smoke) ===${NC}"
    for test_spec in "${TESTS_P0[@]}"; do
        IFS='|' read -r name cfg testname <<< "$test_spec"
        run_test "$name" "$cfg" "$testname"
        all_tests+=("$name")
        ((total_tests++))
    done
    echo ""
fi

# P1 Tests
if [ $RUN_P1 -eq 1 ]; then
    echo -e "${YELLOW}=== P1 (Directed) ===${NC}"
    for test_spec in "${TESTS_P1[@]}"; do
        IFS='|' read -r name cfg testname <<< "$test_spec"
        run_test "$name" "$cfg" "$testname"
        all_tests+=("$name")
        ((total_tests++))
    done
    echo ""
fi

# P2 Tests
if [ $RUN_P2 -eq 1 ]; then
    echo -e "${YELLOW}=== P2 (Regression) ===${NC}"
    for test_spec in "${TESTS_P2[@]}"; do
        IFS='|' read -r name cfg testname <<< "$test_spec"
        run_test "$name" "$cfg" "$testname"
        all_tests+=("$name")
        ((total_tests++))
    done
    echo ""
fi

# ============================================================================
# Summary Report
# ============================================================================
echo "================================================================================"
echo "  Test Summary Report"
echo "================================================================================"

# Count results
passed=$(grep -c "^PASS$" "${LOG_DIR}/summary.txt" 2>/dev/null || echo 0)
failed=$((total_tests - passed))

# Generate summary report file
cat > "${LOG_DIR}/summary.rpt" << EOF
================================================================================
                    DEU UVM Test Suite Summary Report
================================================================================

Run Date: $(date)
Total Tests: ${total_tests}
Passed: ${passed}
Failed: ${failed}

================================================================================
Test Results:
================================================================================
EOF

# Detailed results
idx=0
for test_name in "${all_tests[@]}"; do
    log_file="${LOG_DIR}/${test_name}.log"
    wave_file="${WAVE_DIR}/${test_name}.fsdb"

    if grep -q "TESTCASE PASSED" "${log_file}" 2>/dev/null; then
        status="PASS"
        status_color="${GREEN}"
    else
        status="FAIL"
        status_color="${RED}"
    fi

    # Extract scoreboard summary from log
    pass_cnt=$(grep "PASSED=" "${log_file}" 2>/dev/null | grep -o "PASSED=[0-9]*" | head -1 | cut -d= -f2 || echo "N/A")
    fail_cnt=$(grep "FAILED=" "${log_file}" 2>/dev/null | grep -o "FAILED=[0-9]*" | head -1 | cut -d= -f2 || echo "N/A")

    echo -e "${status_color}${status}${NC}  ${test_name}"

    cat >> "${LOG_DIR}/summary.rpt" << EOF
[${status}] ${test_name}
  Log:        ${log_file}
  Wave:       ${wave_file}
  Checks:     PASSED=${pass_cnt}  FAILED=${fail_cnt}
EOF

    ((idx++))
done

# Final verdict
echo ""
cat >> "${LOG_DIR}/summary.rpt" << EOF

================================================================================
Overall Result:
================================================================================
EOF

if [ $failed -eq 0 ]; then
    echo -e "${GREEN}✓ ALL TESTS PASSED${NC}"
    cat >> "${LOG_DIR}/summary.rpt" << EOF
✓ ALL TESTS PASSED
EOF
else
    echo -e "${RED}✗ ${failed} TEST(S) FAILED${NC}"
    cat >> "${LOG_DIR}/summary.rpt" << EOF
✗ ${failed} TEST(S) FAILED
EOF
fi

echo ""
echo "Log directory: ${LOG_DIR}"
echo "Wave directory: ${WAVE_DIR}"
echo "Summary report: ${LOG_DIR}/summary.rpt"
echo ""
cat "${LOG_DIR}/summary.rpt"

exit $failed
