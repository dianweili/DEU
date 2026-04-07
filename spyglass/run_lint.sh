#!/usr/bin/env bash
# =============================================================================
# run_lint.sh — Run SpyGlass lint/lint_rtl on DEU design
#
# Usage:
#   ./run_lint.sh            # run lint, output to ./deu_lint/
#   ./run_lint.sh clean      # remove all generated output
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPYGLASS_HOME=/data/synopsys/spyglass_vV-2023.12-SP1/spyglass/V-2023.12-SP1/SPYGLASS_HOME
export SPYGLASS_HOME
export PATH="${SPYGLASS_HOME}/bin:${PATH}"

PRJ="${SCRIPT_DIR}/deu_lint.prj"
GOAL="lint/lint_rtl"
REPORT_DIR="${SCRIPT_DIR}/reports"

# ---- clean ----
if [[ "${1}" == "clean" ]]; then
    echo "[clean] Removing generated output..."
    rm -rf "${SCRIPT_DIR}/deu_lint" \
           "${SCRIPT_DIR}/reports"   \
           "${SCRIPT_DIR}"/*.log
    echo "[clean] Done."
    exit 0
fi

# ---- run ----
cd "${SCRIPT_DIR}"
echo "========================================================"
echo "  SpyGlass lint/lint_rtl — DEU"
echo "  Project : ${PRJ}"
echo "  Goal    : ${GOAL}"
echo "========================================================"

spyglass -project "${PRJ}" \
         -batch   \
         -goals   "${GOAL}" \
         2>&1 | tee spyglass_lint.log

# ---- copy key report to a fixed location ----
mkdir -p "${REPORT_DIR}"
MORESIMPLE="${SCRIPT_DIR}/deu_lint/deu_design/lint/lint_rtl/spyglass_reports/moresimple.rpt"
if [[ -f "${MORESIMPLE}" ]]; then
    cp "${MORESIMPLE}" "${REPORT_DIR}/lint_moresimple.rpt"
    echo ""
    echo "[report] Saved → ${REPORT_DIR}/lint_moresimple.rpt"
fi

# ---- print summary ----
echo ""
grep -A6 "Goal Violation Summary" spyglass_lint.log || true
echo ""
echo "[done] Session DB: ${SCRIPT_DIR}/deu_lint/deu_design/.SG_SaveRestoreDB/"
echo "[done] Reports   : ${REPORT_DIR}/"
