#!/usr/bin/env bash
# Suite de testes de shell — IT-001 a IT-020, IT-086, IT-087
# Uso: bash test/shell/check_env.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PLUGINS="$REPO_ROOT/plugins"
PASS=0; FAIL=0; WARN=0

pass() { echo "  PASS  $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL  $1"; FAIL=$((FAIL + 1)); }
warn() { echo "  WARN  $1"; WARN=$((WARN + 1)); }

plugin_file() {
  # plugin_file "vim-rails" "plugin/rails.vim"
  local dir="$PLUGINS/$1" file="$PLUGINS/$1/$2"
  if   [ ! -d "$dir"  ]; then fail "[$1] diretório ausente: $dir"
  elif [ ! -f "$file" ]; then fail "[$1] arquivo principal ausente: $2"
  else pass "[$1] $2"
  fi
}

require_bin() {
  # require_bin "git" ">=2" (versão é só informativa por enquanto)
  local bin="$1" label="${2:-}"
  if command -v "$bin" > /dev/null 2>&1; then
    local ver
    ver=$("$bin" --version 2>&1 | head -1 || true)
    pass "binário '$bin' disponível ($ver)"
  else
    fail "binário '$bin' não encontrado no PATH${label:+ — necessário para $label}"
  fi
}

optional_bin() {
  local bin="$1" label="${2:-}"
  if command -v "$bin" > /dev/null 2>&1; then
    pass "binário opcional '$bin' disponível"
  else
    warn "binário opcional '$bin' não encontrado${label:+ — $label}"
  fi
}

# ── IT-087: Isolamento XDG ─────────────────────────────────────────────────────
echo "── IT-087: Isolamento XDG ──────────────────────────────────────────────"
if [ -n "${XDG_DATA_HOME:-}" ] && [ -d "${XDG_DATA_HOME:-}" ]; then
  pass "XDG_DATA_HOME isolado em $XDG_DATA_HOME"
else
  warn "XDG_DATA_HOME não está isolado (rodar via test/run.sh para isolamento completo)"
fi

# ── IT-001: Nenhum diretório de plugin está vazio ──────────────────────────────
echo ""
echo "── IT-001: Integridade geral dos plugins ───────────────────────────────"
empty_count=0
for dir in "$PLUGINS"/*/; do
  name=$(basename "$dir")
  # Ignora arquivos soltos que aparecem no diretório
  [ -d "$dir" ] || continue
  count=$(find "$dir" -maxdepth 1 -type f -o -type d | grep -c . || true)
  if [ "$count" -le 1 ]; then
    fail "plugin vazio: $name"
    empty_count=$((empty_count + 1))
  fi
done
[ "$empty_count" -eq 0 ] && pass "nenhum diretório de plugin está vazio"
plugin_count=$(find "$PLUGINS" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
pass "$plugin_count diretórios de plugins encontrados"

# ── IT-002 a IT-014: Plugins críticos ─────────────────────────────────────────
echo ""
echo "── IT-002 a IT-014: Plugins críticos ───────────────────────────────────"
plugin_file "vim-rails"              "plugin/rails.vim"
plugin_file "vim-projectionist"      "plugin/projectionist.vim"
plugin_file "fzf"                    "plugin/fzf.vim"
plugin_file "fzf.vim"                "plugin/fzf.vim"
plugin_file "vim-dadbod"             "plugin/dadbod.vim"
plugin_file "vim-dadbod-ui"          "plugin/db_ui.vim"
plugin_file "vim-dadbod-completion"  "plugin/vim_dadbod_completion.vim"
plugin_file "undotree"               "plugin/undotree.vim"
plugin_file "vim-obsession"          "plugin/obsession.vim"
plugin_file "gv.vim"                 "plugin/gv.vim"
plugin_file "vim-unimpaired"         "plugin/unimpaired.vim"
plugin_file "vim-rooter"             "plugin/rooter.vim"
plugin_file "vim-test"               "plugin/test.vim"
plugin_file "vimux"                  "plugin/vimux.vim"
plugin_file "vim-surround"           "plugin/surround.vim"
plugin_file "vim-fugitive"           "plugin/fugitive.vim"
plugin_file "vim-gitgutter"          "plugin/gitgutter.vim"
plugin_file "auto-pairs"             "plugin/auto-pairs.vim"
plugin_file "nerdtree"               "plugin/NERD_tree.vim"
plugin_file "vim-tmux-navigator"     "plugin/tmux_navigator.vim"

# vim-snippets: verifica que tem snippets, não só o diretório
snippets_count=$(find "$PLUGINS/vim-snippets/snippets" -name "*.snippets" 2>/dev/null | wc -l | tr -d ' ')
if [ "${snippets_count:-0}" -gt 10 ]; then
  pass "[vim-snippets] $snippets_count arquivos .snippets"
else
  fail "[vim-snippets] snippets/: esperava >10 arquivos, encontrou ${snippets_count:-0}"
fi

# coc.nvim: build compilado
if [ -f "$PLUGINS/coc.nvim/build/index.js" ] && [ -s "$PLUGINS/coc.nvim/build/index.js" ]; then
  pass "[coc.nvim] build/index.js presente e não vazio"
else
  fail "[coc.nvim] build/index.js ausente ou vazio — rode: cd plugins/coc.nvim && npm ci"
fi

# ── IT-015 a IT-020: Binários externos obrigatórios ───────────────────────────
echo ""
echo "── IT-015 a IT-020: Binários externos ──────────────────────────────────"
require_bin "node"    "coc.nvim"
require_bin "rg"      "fzf + Ack backend"
require_bin "git"     "vim-fugitive / gv.vim / GitMessenger"
require_bin "ruby"    "coc-solargraph"
require_bin "python3" "coc-pyright"

# ElixirLS (IT-018)
ELIXIRLS="$HOME/.elixir-ls/release/language_server.sh"
if [ -f "$ELIXIRLS" ] && [ -x "$ELIXIRLS" ]; then
  pass "ElixirLS em $ELIXIRLS (executável)"
else
  fail "ElixirLS não encontrado ou não executável em $ELIXIRLS"
fi

# ── IT-086: Tabela plugin → binário ───────────────────────────────────────────
echo ""
echo "── IT-086: Mapeamento plugin → binário ─────────────────────────────────"
require_bin "fzf"  "plugin fzf"
# rg e git já verificados acima; node também
# DB clients são opcionais
optional_bin "psql" "vim-dadbod com PostgreSQL"
optional_bin "mysql" "vim-dadbod com MySQL"

# ── Resultado ─────────────────────────────────────────────────────────────────
echo ""
echo "────────────────────────────────────────────────────────────────────────"
echo "  PASS: $PASS  |  WARN: $WARN  |  FAIL: $FAIL"
echo "────────────────────────────────────────────────────────────────────────"

[ "$FAIL" -eq 0 ]
