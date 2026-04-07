#!/bin/bash
# Simple test runner — focuses on P0/P1 with compact output
set -e

REPO_ROOT="$(cd .. && pwd)"
SIM_DIR="$(cd . && pwd)"
LOG_DIR="${SIM_DIR}/logs"

mkdir -p "${LOG_DIR}"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "================================================================================"
echo "  DEU UVM Test Suite"
echo "================================================================================"

rm -f "${LOG_DIR}/summary.txt"
touch "${LOG_DIR}/summary.txt"

# Test list
tests=(
    "sanity:deu_sanity_test:${REPO_ROOT}/tb/cfg/sanity.cfg"
    "directed_dt01:deu_base_test:${REPO_ROOT}/tb/cfg/directed_dt01.cfg"
    "directed_full_valid:deu_base_test:${REPO_ROOT}/tb/cfg/directed_full_valid.cfg"
    "pipeline_timing:deu_base_test:${REPO_ROOT}/tb/cfg/pipeline_timing.cfg"
)

total=0
passed=0
failed=0

# Compile once
echo -e "${YELLOW}[COMPILE]${NC} VCS..."
if make -B run TESTNAME=deu_sanity_test CFG="${REPO_ROOT}/tb/cfg/sanity.cfg" > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓ Done${NC}"
else
    echo -e "  ${RED}✗ Failed${NC}"
    exit 1
fi

# Run tests
for test_spec in "${tests[@]}"; do
    IFS=':' read -r tname tclass tcfg <<< "$test_spec"
    log_file="${LOG_DIR}/${tname}.log"

    echo -e "${YELLOW}[RUN]${NC} ${tname}..."

    if (cd "${SIM_DIR}" && ./simv +UVM_TESTNAME="${tclass}" +UVM_VERBOSITY=UVM_MEDIUM \
        +ntb_random_seed=1 +cfg="${tcfg}") > "${log_file}" 2>&1; then

        if grep -q "TESTCASE PASSED" "${log_file}"; then
            echo -e "  ${GREEN}✓ PASS${NC}"
            echo "PASS" >> "${LOG_DIR}/summary.txt"
            ((passed++))
        else
            echo -e "  ${RED}✗ FAIL${NC} (check logs)"
            echo "FAIL" >> "${LOG_DIR}/summary.txt"
            ((failed++))
        fi
    else
        echo -e "  ${RED}✗ FAIL${NC} (runtime error)"
        echo "FAIL" >> "${LOG_DIR}/summary.txt"
        ((failed++))
    fi
    ((total++))
done

echo ""
echo "================================================================================"
echo "  Results: ${passed}/${total} passed"
echo "================================================================================"

# Generate summary
cat > "${LOG_DIR}/summary.rpt" << EOF
DEU UVM Test Suite Summary
$(date)

Total: ${total}
Passed: ${passed}
Failed: ${failed}

Individual Results:
EOF

idx=0
for test_spec in "${tests[@]}"; do
    IFS=':' read -r tname tclass tcfg <<< "$test_spec"
    log_file="${LOG_DIR}/${tname}.log"
    if [ -f "$log_file" ] && grep -q "TESTCASE PASSED" "$log_file"; then
        echo "[✓] ${tname}" >> "${LOG_DIR}/summary.rpt"
    else
        echo "[✗] ${tname}" >> "${LOG_DIR}/summary.rpt"
    fi
done

cat "${LOG_DIR}/summary.rpt"

if [ $failed -eq 0 ]; then
    echo -e "${GREEN}✓ ALL TESTS PASSED${NC}"
    exit 0
else
    echo -e "${RED}✗ TESTS FAILED${NC}"
    exit 1
fi
