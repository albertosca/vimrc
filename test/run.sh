#!/usr/bin/env bash
# Entry point unificado da suite de testes.
# Uso: bash test/run.sh [fase] [flags]
#   bash test/run.sh              → roda tudo (output compacto)
#   bash test/run.sh unit         → só vader unit
#   bash test/run.sh -v           → cada caso de teste com ✓/✗
#   bash test/run.sh -vv          → output bruto completo (debug)
#   bash test/run.sh unit -v      → uma fase, expandido

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

source test/shim.sh

# ── Parse args ────────────────────────────────────────────────────────────────
FASE="all"
VERBOSE=0
for arg in "$@"; do
  case "$arg" in
    -vv|--raw)     VERBOSE=2 ;;
    -v|--verbose)  VERBOSE=1 ;;
    *)             FASE="$arg" ;;
  esac
done

# ── Colors (disable if not a terminal) ────────────────────────────────────────
if [[ -t 1 ]]; then
  GREEN='\033[0;32m'
  RED='\033[0;31m'
  YELLOW='\033[0;33m'
  DIM='\033[2m'
  BOLD='\033[1m'
  RESET='\033[0m'
else
  GREEN='' RED='' YELLOW='' DIM='' BOLD='' RESET=''
fi

# ── State ─────────────────────────────────────────────────────────────────────
VADER_RTP="test/vendor/vader.vim"
TOTAL_PASS=0
TOTAL_FAIL=0
TOTAL_WARN=0

# ── Portable millisecond timer ────────────────────────────────────────────────
now_ms() {
  python3 -c 'import time; print(int(time.time()*1000))' 2>/dev/null \
    || perl -MTime::HiRes=time -e 'printf "%d\n", time()*1000' 2>/dev/null \
    || echo $(( $(date +%s) * 1000 ))
}

# ── Helpers ───────────────────────────────────────────────────────────────────

# Compact: one-line suite summary
suite_line() {
  local name="$1" pass="$2" fail="$3" warn="${4:-0}" elapsed_ms="$5"

  local elapsed
  elapsed=$(awk "BEGIN { printf \"%.1f\", $elapsed_ms / 1000 }")

  local icon color
  if [[ "$fail" -gt 0 ]]; then
    icon="✗" ; color="$RED"
  else
    icon="✓" ; color="$GREEN"
  fi

  local warn_str=""
  if [[ "$warn" -gt 0 ]]; then
    warn_str="  ${YELLOW}${warn} warn${RESET}"
  fi

  printf "  %b%s%b  %-16s %b%s passed%b%b  %b%s failed%b  %b%s%b\n" \
    "$color" "$icon" "$RESET" \
    "$name" \
    "$GREEN" "$pass" "$RESET" \
    "$warn_str" \
    "$([ "$fail" -gt 0 ] && echo "$RED" || echo "$DIM")" "$fail" "$RESET" \
    "$DIM" "${elapsed}s" "$RESET"

  TOTAL_PASS=$((TOTAL_PASS + pass))
  TOTAL_FAIL=$((TOTAL_FAIL + fail))
  TOTAL_WARN=$((TOTAL_WARN + warn))
}

# Expanded (-v): shell test cases with ✓/✗/⚠
show_shell_expanded() {
  echo "$1" | grep -E '^\s*(PASS|FAIL|WARN)\s' | while IFS= read -r line; do
    local msg
    msg=$(echo "$line" | sed -E 's/^[[:space:]]*(PASS|FAIL|WARN)[[:space:]]*//')
    if echo "$line" | grep -q 'PASS'; then
      printf "    %b✓%b %s\n" "$GREEN" "$RESET" "$msg"
    elif echo "$line" | grep -q 'FAIL'; then
      printf "    %b✗ %s%b\n" "$RED" "$msg" "$RESET"
    else
      printf "    %b⚠ %s%b\n" "$YELLOW" "$msg" "$RESET"
    fi
  done
}

# Expanded (-v): vader test cases with ✓/✗, grouped by file
# Uses a "pending" pattern: store each test name, flush it as pass/fail
# when the next event arrives (next test, (X) failure, or file boundary).
show_vader_expanded() {
  echo "$1" | awk \
    -v green="$GREEN" -v red="$RED" -v dim="$DIM" -v reset="$RESET" '
  function flush_pass() {
    if (pending != "") {
      printf "    %s✓%s %s\n", green, reset, pending
      pending = ""
    }
  }
  function flush_fail() {
    if (pending != "") {
      printf "    %s✗ %s%s\n", red, pending, reset
      pending = ""
    }
  }

  /Starting Vader:.*suite/ { next }

  /Starting Vader:/ {
    flush_pass()
    sub(/.*\//, "")
    printf "\n    %s%s%s\n", dim, $0, reset
    next
  }

  /\[EXECUTE\].*\(X\)/ {
    flush_fail()
    next
  }

  /\[ EXPECT\]/ { next }

  /\[EXECUTE\]/ {
    flush_pass()
    sub(/.*\[EXECUTE\] /, "")
    pending = $0
    next
  }

  /^Success\/Total:/ {
    flush_pass()
  }

  END {
    flush_pass()
  }
  '
}

# Expanded (-v): jest test cases — use jest's own verbose format
show_jest_expanded() {
  (cd test/node && npx jest --verbose 2>&1) | while IFS= read -r line; do
    # Skip noisy lines (PASS badge, blank, timing, summary)
    case "$line" in
      *'PASS '*)   continue ;;
      *'Test Suites:'*) continue ;;
      *'Tests:'*)  continue ;;
      *'Snapshots:'*) continue ;;
      *'Time:'*)   continue ;;
      *'Ran all'*) continue ;;
      '')          continue ;;
    esac
    # Describe group headers
    if echo "$line" | grep -qE '^\s+[A-Z]' && ! echo "$line" | grep -qE '✓|✕|✗|×|✖'; then
      local trimmed
      trimmed=$(echo "$line" | sed 's/^[[:space:]]*//')
      printf "\n    %b%s%b\n" "$DIM" "$trimmed" "$RESET"
    # Pass
    elif echo "$line" | grep -q '✓'; then
      local trimmed
      trimmed=$(echo "$line" | sed 's/^[[:space:]]*//' | sed 's/^✓ //')
      printf "    %b✓%b %s\n" "$GREEN" "$RESET" "$trimmed"
    # Fail
    elif echo "$line" | grep -qE '✕|✗|✖|×'; then
      local trimmed
      trimmed=$(echo "$line" | sed 's/^[[:space:]]*//' | sed 's/^[✕✗✖×] //')
      printf "    %b✗ %s%b\n" "$RED" "$trimmed" "$RESET"
    fi
  done
}

# Compact: show only failure details
show_vader_failures() {
  echo "$1" | grep '(X)' | sed 's/.*\[EXECUTE\] //' | sed 's/^(X) //' | while IFS= read -r line; do
    printf "    %b↳ %s%b\n" "$RED" "$line" "$RESET"
  done
}

# ── Header ────────────────────────────────────────────────────────────────────
echo ""
printf "  %bVim Config Test Suite%b\n" "$BOLD" "$RESET"
printf "  %b─────────────────────────────────────────────────────%b\n" "$DIM" "$RESET"

# ── Shell tests ───────────────────────────────────────────────────────────────
if [[ "$FASE" == "all" || "$FASE" == "shell" ]]; then
  if ls test/shell/*.sh > /dev/null 2>&1; then
    _start=$(now_ms)
    _out=$(bash test/shell/check_env.sh 2>&1) || true
    _elapsed=$(( $(now_ms) - _start ))

    [[ "$VERBOSE" -eq 2 ]] && echo "$_out"

    s_pass=$(echo "$_out" | sed -n 's/.*PASS: \([0-9]*\).*/\1/p')
    s_fail=$(echo "$_out" | sed -n 's/.*FAIL: \([0-9]*\).*/\1/p')
    s_warn=$(echo "$_out" | sed -n 's/.*WARN: \([0-9]*\).*/\1/p')

    if [[ "$VERBOSE" -eq 1 ]]; then
      printf "\n  %bshell%b\n" "$BOLD" "$RESET"
      show_shell_expanded "$_out"
    fi

    suite_line "shell" "${s_pass:-0}" "${s_fail:-0}" "${s_warn:-0}" "$_elapsed"

    if [[ "${s_fail:-0}" -gt 0 && "$VERBOSE" -eq 0 ]]; then
      echo "$_out" | grep 'FAIL' | while IFS= read -r line; do
        printf "    %b↳ %s%b\n" "$RED" "$line" "$RESET"
      done
    fi
  fi
fi

# ── Vader suite runner ────────────────────────────────────────────────────────
run_vader_suite() {
  local name="$1" glob="$2"

  local files
  files=$(ls $glob 2>/dev/null || true)
  [[ -z "$files" ]] && return

  local _start _out _elapsed
  _start=$(now_ms)
  _out=$(vim -N -u ~/.vimrc \
    --cmd "set rtp+=$VADER_RTP" \
    -c "Vader! $glob" \
    -c "qa!" 2>&1) || true
  _elapsed=$(( $(now_ms) - _start ))

  [[ "$VERBOSE" -eq 2 ]] && echo "$_out"

  # Parse the last "Success/Total: X/Y" line
  local summary passed total failed
  summary=$(echo "$_out" | grep 'Success/Total:' | tail -1)
  passed=$(echo "$summary" | sed 's|.*Success/Total: \([0-9]*\)/\([0-9]*\).*|\1|')
  total=$(echo "$summary" | sed 's|.*Success/Total: \([0-9]*\)/\([0-9]*\).*|\2|')
  failed=$((total - passed))

  if [[ "$VERBOSE" -eq 1 ]]; then
    printf "\n  %b%s%b\n" "$BOLD" "$name" "$RESET"
    show_vader_expanded "$_out"
    echo ""
  fi

  suite_line "$name" "$passed" "$failed" "0" "$_elapsed"

  if [[ "$failed" -gt 0 && "$VERBOSE" -eq 0 ]]; then
    show_vader_failures "$_out"
  fi
}

if [[ "$FASE" == "all" || "$FASE" == "unit" ]]; then
  run_vader_suite "unit" "test/unit/*.vader"
fi

if [[ "$FASE" == "all" || "$FASE" == "integration" ]]; then
  run_vader_suite "integration" "test/integration/*.vader"
fi

if [[ "$FASE" == "all" || "$FASE" == "e2e" ]]; then
  run_vader_suite "e2e" "test/e2e/*.vader"
fi

# ── Jest ──────────────────────────────────────────────────────────────────────
if [[ "$FASE" == "all" || "$FASE" == "json" ]]; then
  if [[ -f test/node/package.json ]]; then
    _start=$(now_ms)
    _out=$(cd test/node && npx jest --json --no-coverage 2>/dev/null) || true
    _elapsed=$(( $(now_ms) - _start ))

    [[ "$VERBOSE" -eq 2 ]] && (cd test/node && npx jest 2>&1) || true

    j_pass=$(echo "$_out" | sed -n 's/.*"numPassedTests":\([0-9]*\).*/\1/p' | head -1)
    j_fail=$(echo "$_out" | sed -n 's/.*"numFailedTests":\([0-9]*\).*/\1/p' | head -1)

    if [[ -z "$j_pass" ]]; then
      _out2=$(cd test/node && npx jest 2>&1) || true
      j_pass=$(echo "$_out2" | sed -n 's/.*Tests:.*\([0-9]\+\) passed.*/\1/p' | head -1)
      j_fail=$(echo "$_out2" | sed -n 's/.*Tests:.*\([0-9]\+\) failed.*/\1/p' | head -1)
    fi

    if [[ "$VERBOSE" -eq 1 ]]; then
      printf "\n  %bjest%b\n" "$BOLD" "$RESET"
      show_jest_expanded
      echo ""
    fi

    suite_line "jest" "${j_pass:-0}" "${j_fail:-0}" "0" "$_elapsed"

    if [[ "${j_fail:-0}" -gt 0 && "$VERBOSE" -eq 0 ]]; then
      echo "$_out" | grep -E 'FAIL|●' | head -5 | while IFS= read -r line; do
        printf "    %b↳ %s%b\n" "$RED" "$line" "$RESET"
      done
    fi
  fi
fi

# ── Teardown ──────────────────────────────────────────────────────────────────
rm -rf "$REPO_ROOT/test/xdg"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
printf "  %b─────────────────────────────────────────────────────%b\n" "$DIM" "$RESET"

warn_label=""
if [[ "$TOTAL_WARN" -gt 0 ]]; then
  warn_label="  ${YELLOW}${TOTAL_WARN} warn${RESET}"
fi

if [[ "$TOTAL_FAIL" -eq 0 ]]; then
  printf "  %b✓ %s passed%b%b   all green%b\n" \
    "${BOLD}${GREEN}" "$TOTAL_PASS" "$RESET" \
    "$GREEN" "$RESET"
  [[ -n "$warn_label" ]] && printf "  %b\n" "$warn_label"
else
  printf "  %b✗ %s passed   %s failed%b\n" \
    "${BOLD}${RED}" "$TOTAL_PASS" "$TOTAL_FAIL" "$RESET"
  [[ -n "$warn_label" ]] && printf "  %b\n" "$warn_label"
fi

echo ""

[[ "$TOTAL_FAIL" -eq 0 ]]
