#!/bin/sh

# 🧪 SysDiag v1.2.0 - Linux Diagnostics Toolkit (with log analysis, CSV/MD export, and issue summary)

LOG_DIR="$HOME/.local/share/sysdiag"
mkdir -p "$LOG_DIR"
DATESTAMP=$(date +%F_%H-%M-%S)
LOG_FILE="$LOG_DIR/sysdiag_$DATESTAMP.log"
HTML_REPORT="$LOG_DIR/sysdiag_report.html"
JSON_REPORT="$LOG_DIR/sysdiag_summary.json"
CSV_REPORT="$LOG_DIR/sysdiag_summary.csv"
MD_REPORT="$LOG_DIR/sysdiag_summary.md"
SVG_REPORT="$LOG_DIR/sysdiag_status.svg"

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
BOLD="\033[1m"
RESET="\033[0m"

TEST_SUMMARY=""
TEST_LOGS=""

status_icon() {
  case "$1" in
    OK) echo "${GREEN}✅ OK${RESET}" ;;
    WARN) echo "${YELLOW}⚠️ Warning${RESET}" ;;
    FAIL) echo "${RED}❌ Fail${RESET}" ;;
    SKIP) echo "${YELLOW}⏭️ Skipped${RESET}" ;;
    *) echo "❓ Unknown" ;;
  esac
}

detect_issues_summary() {
  echo "<h2>⚠️ Detected Issues</h2><ul>" >> "$HTML_REPORT"
  echo "$TEST_LOGS" | grep -q "SGX disabled by BIOS" && echo "<li><b>BIOS:</b> SGX disabled by BIOS</li>" >> "$HTML_REPORT"
  echo "$TEST_LOGS" | grep -q "VMX.*disabled by BIOS" && echo "<li><b>BIOS:</b> VMX (Virtualization) disabled</li>" >> "$HTML_REPORT"
  echo "$TEST_LOGS" | grep -qi "gnome-keyring.*Failed to start" && echo "<li><b>GNOME:</b> keyring services failed to start</li>" >> "$HTML_REPORT"
  echo "$TEST_LOGS" | grep -qi "bluetooth.*failed" && echo "<li><b>Bluetooth:</b> driver or service initialization failed</li>" >> "$HTML_REPORT"
  echo "</ul>" >> "$HTML_REPORT"
}

run_test() {
  label="$1"
  cmd="$2"
  supported="$3"
  start=$(date +%s.%N)
  echo ""
  echo "${CYAN}▶ Running: $label${RESET}"
  echo "${CYAN}--------------------------------------------------${RESET}"
  if [ "$supported" = "false" ]; then
    echo "$(status_icon SKIP) Skipped (0.00s)"
    TEST_SUMMARY="${TEST_SUMMARY}${label},SKIP,0.00,Skipped\n"
    return
  fi
  result=$(eval "$cmd" 2>&1)
  status=$?
  end=$(date +%s.%N)
  duration=$(echo "$end - $start" | bc -l | xargs printf "%.2f")
  note="Success"
  if echo "$label" | grep -q "System Logs"; then
    ERRORS=$(echo "$result" | grep -iE "fail|error|denied|assertion" | wc -l)
    [ "$ERRORS" -gt 0 ] && note="$ERRORS critical messages" && status=1
  fi
  if echo "$label" | grep -q "Driver Errors"; then
    echo "$result" | grep -qi "Operation not permitted" && note="Permission denied" && status=1
  fi
  [ "$status" -eq 0 ] && TEST_SUMMARY="${TEST_SUMMARY}${label},OK,$duration,$note\n" || TEST_SUMMARY="${TEST_SUMMARY}${label},WARN,$duration,$note\n"
  [ "$status" -eq 0 ] && echo "$(status_icon OK) (${duration}s)" || echo "$(status_icon WARN) (${duration}s)"
  echo "${CYAN}--------------------------------------------------${RESET}"
  echo "--- $label ---\n$result\n" >> "$LOG_FILE"
  TEST_LOGS="${TEST_LOGS}--- $label ---\n$result\n\n"
  echo "$result"
}

generate_exports() {
  echo "<html><head><title>SysDiag Report</title><style>body{font-family:monospace;background:#111;color:#eee;padding:20px;} a{color:#4fc3f7;} summary{cursor:pointer;font-weight:bold;} pre{background:#222;padding:10px;border-left:4px solid #4fc3f7;}</style></head><body>" > "$HTML_REPORT"
  echo "<h1>🔍 SysDiag Report</h1><p><b>Date:</b> $(date)</p>" >> "$HTML_REPORT"
  detect_issues_summary
  ERRORS=$(echo "$TEST_SUMMARY" | grep -c ",FAIL,\|,WARN,")
  echo "<p style=\"color:#ff9800;\"><b>Warnings/Errors Detected:</b> $ERRORS</p><hr>" >> "$HTML_REPORT"

  echo "$TEST_LOGS" | awk -v RS="--- " 'NR>1 {
    split($0, lines, "\n")
    summary = lines[1]
    body=""
    for (i=2; i<=length(lines); i++) body = body lines[i] "\n"
    printf "<details><summary>--- %s</summary><pre>%s</pre></details>\n", summary, body
  }' >> "$HTML_REPORT"

  echo "<hr><p>Links: <a href='file://$JSON_REPORT'>JSON</a> 
  echo "</body></html>" >> "$HTML_REPORT"

  echo "[" > "$JSON_REPORT"
  echo "$TEST_SUMMARY" | while IFS=',' read -r name status time note; do
    echo "  { \"test\": \"$name\", \"status\": \"$status\", \"duration\": \"$time\", \"note\": \"$note\" }," >> "$JSON_REPORT"
  done
  sed -i '$ s/,$//' "$JSON_REPORT"
  echo "]" >> "$JSON_REPORT"

  echo "test,status,duration,note" > "$CSV_REPORT"
  echo "$TEST_SUMMARY" | while IFS=',' read -r name status time note; do
    echo "$name,$status,$time,$note" >> "$CSV_REPORT"
  done

  echo "# 🧪 SysDiag Report — $(date)" > "$MD_REPORT"
  echo "" >> "$MD_REPORT"
  echo "| Test | Status | Duration | Note |" >> "$MD_REPORT"
  echo "|------|--------|----------|------|" >> "$MD_REPORT"
  echo "$TEST_SUMMARY" | while IFS=',' read -r name status time note; do
    echo "| $name | $status | ${time}s | $note |" >> "$MD_REPORT"
  done

  echo "<svg xmlns='http://www.w3.org/2000/svg' width='500' height='200'>" > "$SVG_REPORT"
  y=20
  echo "$TEST_SUMMARY" | while IFS=',' read -r test status time note; do
    color="#4caf50"
    [ "$status" = "FAIL" ] && color="#f44336"
    [ "$status" = "SKIP" ] && color="#ffc107"
    [ "$status" = "WARN" ] && color="#ff9800"
    echo "<text x='10' y='$y' fill='$color'>$test: $status ($time)s</text>" >> "$SVG_REPORT"
    y=$((y + 20))
  done
  echo "</svg>" >> "$SVG_REPORT"
}

main() {
  echo "${BOLD}🧪 SysDiag v1.2.0 — Advanced Diagnostics Toolkit${RESET}"
  echo "📂 Output directory: $LOG_DIR"
  echo ""
  echo "${BOLD}Starting full system diagnostics...${RESET}"

  run_test "Hardware Overview" "lshw -short" true
  run_test "Kernel Info" "uname -a" true
  run_test "CPU Info" "lscpu" true
  run_test "RAM Info" "free -h" true
  run_test "Disk Info" "lsblk" true
  run_test "Temperatures" "sensors | grep -E 'Package id|Core|temp[0-9]|Tctl|edge|high|crit'" true
  run_test "GPU Info" "lshw -C display" true
  if command -v nvidia-smi >/dev/null; then
    run_test "GPU Temperature" "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader" true
  else
    run_test "GPU Temperature" "echo 'nvidia-smi not available'" false
  fi
  run_test "RAM Stress" "stress-ng --vm 1 --vm-bytes 75% --timeout 10s --metrics-brief" true
  run_test "CPU Stress" "stress --cpu 4 --timeout 10s" true
  run_test "GPU Benchmark" "glmark2 | grep Score" true
  run_test "Network Ping" "ping -c 4 8.8.8.8" true
  run_test "DNS Resolution" "dig +short google.com" true
  run_test "System Logs" "journalctl -b -p 3 | tail -n 20" true
  run_test "Driver Errors" "dmesg --level=err 2>&1 | grep -iE 'firmware|pci|driver|usb|amdgpu|nvidia|taint' | tail -n 15 || echo '[!] Permission denied: Try sudo sysctl -w kernel.dmesg_restrict=0'" true

  echo ""
  echo "${GREEN}All diagnostics finished.${RESET}"
  generate_exports

  echo ""
  echo "${BOLD}🧾 SYSDIAG TEST SUMMARY${RESET}"
  echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo "$TEST_SUMMARY" | while IFS=',' read -r a b c d; do
    echo "▶ $a $(status_icon $b) (${c}s) $d"
  done
  echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  ERRORS_TOTAL=$(echo "$TEST_SUMMARY" | grep -c ",FAIL,\|,WARN,")
  echo "${YELLOW}⚠️ Total warnings/errors: $ERRORS_TOTAL${RESET}"
  echo "📄 HTML: ${BLUE}file://$HTML_REPORT${RESET}"
  echo "📥 JSON: ${BLUE}$JSON_REPORT${RESET}"
  echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

main