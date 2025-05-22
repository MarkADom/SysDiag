#!/bin/sh

# 🧪 SysDiag v1.2.1 - Linux Diagnostics Toolkit (with log analysis, HTML export, and issue summary)

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
  ISSUE_PATTERNS="
SGX disabled by BIOS:BIOS:SGX disabled in firmware
VMX.*disabled by BIOS:BIOS:Virtualization (VMX) disabled
gnome-keyring.*Failed:GNOME:Keyring service failure
bluetooth.*(fail|error):Bluetooth:Bluetooth initialization issue
firmware bug|taint|driver error:Kernel:Driver or firmware warning
Failed to start .*gnome.*:GNOME:GNOME service startup failure
amdgpu.*error:GPU:AMD GPU-related error
nvidia.*error:GPU:NVIDIA GPU-related error
"
  echo "$ISSUE_PATTERNS" | while IFS=: read -r regex category description; do
    if echo "$TEST_LOGS" | grep -qiE "$regex"; then
      echo "<li><b>$category:</b> $description</li>" >> "$HTML_REPORT"
    fi
  done
  echo "</ul>" >> "$HTML_REPORT"
}

run_test() {
  label="$1"
  cmd="$2"
  supported="$3"
  start=$(date +%s.%N)
  echo ""
  echo "${CYAN}▶ Running: $label${RESET}"
  echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  if [ "$supported" = "false" ]; then
    echo "$(status_icon SKIP) Skipped (0.00s)"
    TEST_SUMMARY="${TEST_SUMMARY}${label},SKIP,0.00,Skipped\n"
    return
  fi
  result=$(bash -o pipefail -c "$cmd" 2>&1)
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
  [ "$status" -eq 0 ] && echo "$(status_icon OK) (${duration}s)" || echo "$(status_icon WARN) (${duration}s)"
  echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  TEST_SUMMARY="${TEST_SUMMARY}${label},${status:+WARN},$duration,$note\n"
  echo "--- $label ---\n$result\n" >> "$LOG_FILE"
  TEST_LOGS="${TEST_LOGS}--- $label ---\n$result\n\n"
  echo "$result"
}

check_dependencies() {
  echo ""
  echo "${BOLD}🔍 Checking required dependencies...${RESET}"
  sleep 0.3
  MISSING=""
  echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  for CMD in sensors lshw stress glmark2 dmidecode; do
    printf "• %-12s " "$CMD"
    if command -v $CMD >/dev/null 2>&1; then
      echo "${GREEN}✔ Found${RESET}"
    else
      echo "${RED}✘ Missing${RESET}"
      MISSING="$MISSING $CMD"
    fi
  done
  echo "• lscpu       ${GREEN}✔ Built-in${RESET}"
  echo "• lsblk       ${GREEN}✔ Built-in${RESET}"
  echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  if [ -n "$MISSING" ]; then
    echo ""
    echo "${YELLOW}⚠️ Missing packages:$RESET$MISSING"
    read -p "Install now? [Y/n] " ans
    if [ "$ans" = "Y" ] || [ "$ans" = "y" ] || [ -z "$ans" ]; then
      echo "${BLUE}📦 Installing...${RESET}"
      sudo apt update && sudo apt install -y$MISSING
    else
      echo "${RED}⚠️ Some tests may fail due to missing tools.${RESET}"
    fi
  else
    echo ""
    echo "${GREEN}✅ All dependencies are present.${RESET}"
  fi
}

generate_exports() {
  echo "<html><head><title>SysDiag Report</title><style>body{font-family:monospace;background:#111;color:#eee;padding:20px;}a{color:#4fc3f7;}summary{cursor:pointer;font-weight:bold;}pre{background:#222;padding:10px;border-left:4px solid #4fc3f7;}</style></head><body>" > "$HTML_REPORT"
  echo "<h1>🔍 SysDiag Report</h1><p><b>Date:</b> $(date)</p>" >> "$HTML_REPORT"
  detect_issues_summary
  ERRORS=$(echo "$TEST_SUMMARY" | grep -c ",FAIL,\|,WARN,")
  echo "<p style=\"color:#ff9800;\"><b>Warnings/Errors Detected:</b> $ERRORS</p><hr>" >> "$HTML_REPORT"
  echo "$TEST_LOGS" | awk -v RS="--- " 'NR>1{split($0,lines,"\n");summary=lines[1];body="";for(i=2;i<=length(lines);i++)body=body lines[i] "\n";printf "<details><summary>--- %s</summary><pre>%s</pre></details>\n",summary,body}' >> "$HTML_REPORT"
  echo "<hr><p>Links: <a href='file://$JSON_REPORT'>JSON</a> • <a href='file://$HTML_REPORT'>HTML</a></p></body></html>" >> "$HTML_REPORT"
  echo "{\"date\":\"$(date)\",\"errors\":$ERRORS,\"summary\":[" > "$JSON_REPORT"
  echo "$TEST_SUMMARY" | while IFS=',' read -r name status time note; do echo "{\"test\":\"$name\",\"status\":\"$status\",\"duration\":\"$time\",\"note\":\"$note\"},"; done >> "$JSON_REPORT"
  sed -i '$ s/,$//' "$JSON_REPORT"
  echo "]}" >> "$JSON_REPORT"
}

main() {
  check_dependencies
  echo "${BOLD}🧪 SysDiag v1.2.1 — Advanced Diagnostics Toolkit${RESET}"
  echo "📂 Output directory: $LOG_DIR"
  echo ""
  echo "${BOLD}Starting full system diagnostics...${RESET}"
  run_test "Hardware Overview" "lshw -short" true
  run_test "Kernel Info" "uname -a" true
  run_test "CPU Info" "lscpu" true
  run_test "RAM Info" "free -h" true
  run_test "Disk Info" "lsblk" true
  run_test "Temperatures" "sensors" true
  run_test "GPU Info" "lshw -C display" true
  if command -v nvidia-smi >/dev/null; then run_test "GPU Temperature" "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader" true; else run_test "GPU Temperature" "echo 'nvidia-smi not available'" false; fi
  run_test "RAM Stress" "stress-ng --vm 1 --vm-bytes 75% --timeout 10s --metrics-brief" true
  run_test "CPU Stress" "stress --cpu 4 --timeout 10s" true
  run_test "GPU Benchmark" "glmark2 | grep Score" true
  run_test "Network Ping" "ping -c 4 8.8.8.8" true
  run_test "DNS Resolution" "dig +short google.com" true
  run_test "System Logs" "journalctl -b -p 3 | tail -n 20" true
  run_test "Driver Errors" "dmesg --level=err 2>&1 | grep -iE 'firmware|pci|driver|usb|amdgpu|nvidia|taint' | tail -n 15" true
  echo ""
  echo "${GREEN}All diagnostics finished.${RESET}"
  generate_exports
  echo ""
  echo "${BOLD}🧾 SYSDIAG TEST SUMMARY${RESET}"
  echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo "$TEST_SUMMARY" | while IFS=',' read -r a b c d; do echo "▶ $a $(status_icon $b) (${c}s) $d"; done
  echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo ""
  echo "${RED}⚠️ Detected Issues${RESET}"
  echo "(see HTML report for details)"
  ERRORS_TOTAL=$(echo "$TEST_SUMMARY" | grep -c ",FAIL,\|,WARN,")
  echo "${YELLOW}⚠️ Total warnings/errors: $ERRORS_TOTAL${RESET}"
  echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo "📄 HTML: ${BLUE}file://$HTML_REPORT${RESET}"
  echo "📥 JSON: ${BLUE}$JSON_REPORT${RESET}"
  echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

main
