#!/usr/bin/env bash
# Entry point unificado da suite de testes.
# Uso: bash test/run.sh [fase]
#   bash test/run.sh          → roda tudo
#   bash test/run.sh unit     → só vader unit
#   bash test/run.sh shell    → só shell
#   bash test/run.sh json     → só Jest
#   bash test/run.sh e2e      → só vader e2e

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

source test/shim.sh

VADER_RTP="test/vendor/vader.vim"
FASE="${1:-all}"
ERRORS=0

pass() { echo "  ✓ $1"; }
fail() { echo "  ✗ $1"; ERRORS=$((ERRORS + 1)); }
header() { echo ""; echo "=== $1 ==="; }

run_vader() {
  local label="$1"
  local glob="$2"
  # Expande o glob; se não houver arquivos, pula sem erro
  local files
  files=$(ls $glob 2>/dev/null || true)
  if [ -z "$files" ]; then
    echo "  (nenhum arquivo em $glob — pulando)"
    return
  fi
  vim -N -u ~/.vimrc \
    --cmd "set rtp+=$VADER_RTP" \
    -c "Vader! $glob" \
    -c "qa!" 2>&1 \
    | grep -E "(^[[:space:]]*(✓|✗|PASS|FAIL|Error|E[0-9]+)|Success|Failure)" || true
}

# ── Shell ──────────────────────────────────────────────────────────────────────
if [[ "$FASE" == "all" || "$FASE" == "shell" ]]; then
  header "Shell tests"
  if ls test/shell/*.sh > /dev/null 2>&1; then
    for f in test/shell/*.sh; do
      bash "$f" && pass "$f" || fail "$f"
    done
  else
    echo "  (nenhum script em test/shell/ — pulando)"
  fi
fi

# ── Unit (vader) ───────────────────────────────────────────────────────────────
if [[ "$FASE" == "all" || "$FASE" == "unit" ]]; then
  header "Unit tests (vader)"
  run_vader "unit" "test/unit/*.vader"
fi

# ── Integration (vader) ────────────────────────────────────────────────────────
if [[ "$FASE" == "all" || "$FASE" == "integration" ]]; then
  header "Integration tests (vader)"
  run_vader "integration" "test/integration/*.vader"
fi

# ── E2E (vader) ────────────────────────────────────────────────────────────────
if [[ "$FASE" == "all" || "$FASE" == "e2e" ]]; then
  header "E2E tests (vader)"
  run_vader "e2e" "test/e2e/*.vader"
fi

# ── JSON / Jest ────────────────────────────────────────────────────────────────
if [[ "$FASE" == "all" || "$FASE" == "json" ]]; then
  header "JSON tests (Jest)"
  if [ -f test/node/package.json ]; then
    (cd test/node && npm test --silent) && pass "Jest" || fail "Jest"
  else
    echo "  (test/node/package.json não encontrado — pulando)"
  fi
fi

# ── Teardown XDG ───────────────────────────────────────────────────────────────
rm -rf "$REPO_ROOT/test/xdg"

# ── Resultado final ────────────────────────────────────────────────────────────
echo ""
if [ "$ERRORS" -eq 0 ]; then
  echo "=== DONE — todos os testes passaram ==="
else
  echo "=== DONE — $ERRORS fase(s) falharam ==="
  exit 1
fi
