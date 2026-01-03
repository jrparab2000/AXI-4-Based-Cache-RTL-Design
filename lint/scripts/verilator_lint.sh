#!/usr/bin/env bash
set -e

TOP_LEVEL=${1}
FILELIST=${2}
REPORT_DIR=${3}
LOG_FILE="${REPORT_DIR}/verilator_lint.log"
SUMMARY_FILE="${REPORT_DIR}/summary.txt"

VERILATOR_OPTS=(
    --lint-only
    --sv
    -Wall
    --timing
    --error-limit 0
)

mkdir -p "${REPORT_DIR}"

echo "====================================" | tee "${SUMMARY_FILE}"
echo " Verilator Lint Run" | tee -a "${SUMMARY_FILE}"
echo " Date: $(date)" | tee -a "${SUMMARY_FILE}"
echo "====================================" | tee -a "${SUMMARY_FILE}"
echo "" | tee -a "${SUMMARY_FILE}"

echo "[INFO] Running Verilator lint..."
echo "[INFO] Logs    : ${LOG_FILE}"
echo "[INFO] Summary : ${SUMMARY_FILE}"
echo ""

verilator "${VERILATOR_OPTS[@]}" \
  -f "${FILELIST}" \
  --top-module "${TOP_LEVEL}" \
  2>&1 | tee "${LOG_FILE}"

  echo "" >> "${SUMMARY_FILE}"
echo "------------ LINT SUMMARY ------------" >> "${SUMMARY_FILE}"

grep -E "%Warning|%Error" "${LOG_FILE}" | sort | uniq >> "${SUMMARY_FILE}" || true

WARN_COUNT=$(grep -c "%Warning" "${LOG_FILE}" || true)
ERR_COUNT=$(grep -c "%Error" "${LOG_FILE}" || true)

echo "" >> "${SUMMARY_FILE}"
echo "Warnings : ${WARN_COUNT}" >> "${SUMMARY_FILE}"
echo "Errors   : ${ERR_COUNT}" >> "${SUMMARY_FILE}"

echo "--------------------------------------" >> "${SUMMARY_FILE}"

if [[ ${ERR_COUNT} -ne 0 ]]; then
  echo "[FAIL] Verilator lint found errors ❌"
  exit 1
else
  echo "[PASS] Verilator lint completed successfully ✅"
fi