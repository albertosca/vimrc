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

# ── IT-088: Configurações críticas ───────────────────────────────────────────
echo ""
echo "── IT-088: Configurações críticas ──────────────────────────────────────"
PLUGINS_VIM="$REPO_ROOT/vimrcs/plugins.vim"
if grep -q 'NERDTreeWinPos.*=.*"left"' "$PLUGINS_VIM"; then
  pass "NERDTree abre à esquerda (NERDTreeWinPos = \"left\")"
else
  fail "NERDTreeWinPos não está como \"left\" em vimrcs/plugins.vim — risco de regressão"
fi

# ── IT-089: Bootstrap de instalação do zero ──────────────────────────────────
echo ""
echo "── IT-089: Instalação do zero (vimrc_example + install.sh) ──────────────"

VIMRC_EXAMPLE="$REPO_ROOT/vimrc_example"
if [ -f "$VIMRC_EXAMPLE" ]; then
  pass "vimrc_example existe (template do ~/.vimrc)"
  # Deve carregar pathogen + as 4 camadas base + configs.vim, nesta ordem.
  ok=1
  for src in autoload/pathogen.vim vimrcs/options.vim vimrcs/filetypes.vim \
             vimrcs/plugins.vim vimrcs/editor.vim configs.vim; do
    grep -q "$src" "$VIMRC_EXAMPLE" || { fail "vimrc_example não carrega $src"; ok=0; }
  done
  [ "$ok" -eq 1 ] && pass "vimrc_example carrega pathogen + 4 camadas + configs.vim"
else
  fail "vimrc_example ausente — README manda 'ln -sf ~/.vim_runtime/vimrc_example ~/.vimrc'"
fi

INSTALL_SH="$REPO_ROOT/install.sh"
if [ -f "$INSTALL_SH" ]; then
  pass "install.sh existe"
  [ -x "$INSTALL_SH" ] && pass "install.sh é executável" \
                       || fail "install.sh não é executável (chmod +x)"
  bash -n "$INSTALL_SH" && pass "install.sh tem sintaxe válida" \
                        || fail "install.sh tem erro de sintaxe"
  grep -q 'submodule update --init' "$INSTALL_SH" \
    && pass "install.sh inicializa submodules" \
    || fail "install.sh não inicializa submodules"
  grep -q 'coc-settings.json' "$INSTALL_SH" \
    && pass "install.sh linka coc-settings.json" \
    || fail "install.sh não linka coc-settings.json"
else
  fail "install.sh ausente — README documenta 'bash ~/.vim_runtime/install.sh'"
fi

# ── IT-090: install.sh comportamento real ─────────────────────────────────────
echo ""
echo "── IT-090: install.sh comportamento real ────────────────────────────────"

# Cria HOME temporário com install.sh + arquivos mínimos + .gitmodules fictício
_setup_fake_home() {
  local fh
  fh=$(mktemp -d)
  local r="$fh/.vim_runtime"
  mkdir -p "$r/bin_stub"
  cp "$INSTALL_SH" "$r/install.sh"
  printf '# vimrc_example stub\n' > "$r/vimrc_example"
  printf '{}' > "$r/coc-settings.json"
  printf '[submodule "plugins/mod-ok"]\n  path = plugins/mod-ok\n  url = https://x/mod-ok\n[submodule "plugins/mod-dead"]\n  path = plugins/mod-dead\n  url = https://x/mod-dead\n' > "$r/.gitmodules"
  echo "$fh"
}

# IT-090a: caminho errado → exit 1 com mensagem "exige"
_h=$(mktemp -d)
cp "$INSTALL_SH" "$_h/"
_out=$(HOME="$_h" bash "$_h/install.sh" 2>&1) && _rc=0 || _rc=$?
rm -rf "$_h"
[ "$_rc" -ne 0 ] && echo "$_out" | grep -q "exige" \
  && pass "IT-090a: path errado → exit 1 + mensagem 'exige'" \
  || fail "IT-090a: esperava exit 1 + 'exige', obteve exit=$_rc"

# IT-090b: happy path — todos os submodules ok
_h=$(_setup_fake_home)
cat > "$_h/.vim_runtime/bin_stub/git" << 'EOF'
#!/usr/bin/env bash
while [[ "$1" == "-C" ]]; do shift 2; done
if echo "$@" | grep -q "get-regexp"; then
  echo "submodule.plugins/mod-ok.path plugins/mod-ok"
  echo "submodule.plugins/mod-dead.path plugins/mod-dead"
elif echo "$@" | grep -q "config.*url"; then
  echo "https://x/stub"
fi
exit 0
EOF
chmod +x "$_h/.vim_runtime/bin_stub/git"
_out=$(HOME="$_h" PATH="$_h/.vim_runtime/bin_stub:$PATH" bash "$_h/.vim_runtime/install.sh" 2>&1) && _rc=0 || _rc=$?
rm -rf "$_h"
[ "$_rc" -eq 0 ] && echo "$_out" | grep -q "Submodules atualizados" \
  && pass "IT-090b: happy path → 'Submodules atualizados', exit 0" \
  || fail "IT-090b: esperava exit 0 + 'Submodules atualizados', exit=$_rc"

# IT-090c: um submodule falha → avisa (ignorado) e não aborta
_h=$(_setup_fake_home)
cat > "$_h/.vim_runtime/bin_stub/git" << 'EOF'
#!/usr/bin/env bash
while [[ "$1" == "-C" ]]; do shift 2; done
if echo "$@" | grep -q "get-regexp"; then
  echo "submodule.plugins/mod-ok.path plugins/mod-ok"
  echo "submodule.plugins/mod-dead.path plugins/mod-dead"
elif echo "$@" | grep -q "submodule update.*mod-dead"; then
  exit 1
elif echo "$@" | grep -q "config.*url"; then
  echo "https://x/stub"
fi
exit 0
EOF
chmod +x "$_h/.vim_runtime/bin_stub/git"
_out=$(HOME="$_h" PATH="$_h/.vim_runtime/bin_stub:$PATH" bash "$_h/.vim_runtime/install.sh" 2>&1) && _rc=0 || _rc=$?
rm -rf "$_h"
echo "$_out" | grep -q "ignorado" \
  && pass "IT-090c: submodule morto → aviso 'ignorado' emitido" \
  || fail "IT-090c: esperava 'ignorado' no output"
[ "$_rc" -eq 0 ] \
  && pass "IT-090c: script não abortou após falha de submodule" \
  || fail "IT-090c: script abortou (exit $_rc) — deveria continuar"

# IT-090d: git indisponível → warning sobre git ausente
_h=$(_setup_fake_home)
_out=$(HOME="$_h" PATH="/usr/bin:/bin" bash "$_h/.vim_runtime/install.sh" 2>&1) && _rc=0 || _rc=$?
rm -rf "$_h"
echo "$_out" | grep -qE "ausente|pulei" \
  && pass "IT-090d: git ausente → warning emitido" \
  || fail "IT-090d: esperava 'ausente' ou 'pulei' no output"

# ── IT-091: install.sh faz pre-flight de dependências ─────────────────────────
echo ""
echo "── IT-091: install.sh pre-flight de dependências ───────────────────────"

# Pre-flight deve AVISAR (não abortar) quando node falta. Rodamos com um PATH
# que tem git (pra passar do path-check) mas sem node, em fake home no caminho certo.
_h=$(_setup_fake_home)
cat > "$_h/.vim_runtime/bin_stub/git" << 'EOF'
#!/usr/bin/env bash
while [[ "$1" == "-C" ]]; do shift 2; done
if echo "$@" | grep -q "get-regexp"; then echo "submodule.plugins/mod-ok.path plugins/mod-ok"; fi
exit 0
EOF
chmod +x "$_h/.vim_runtime/bin_stub/git"
# HOME aponta para fake home; install.sh roda de $HOME/.vim_runtime (path certo).
_out=$(HOME="$_h" PATH="$_h/.vim_runtime/bin_stub:/usr/bin:/bin" bash "$_h/.vim_runtime/install.sh" 2>&1) && _rc=0 || _rc=$?
rm -rf "$_h"
echo "$_out" | grep -qiE "node.*aus|node.*não|node.*nao|node.*instale" \
  && pass "IT-091a: node ausente → pre-flight avisa" \
  || fail "IT-091a: esperava aviso sobre node ausente no output"
[ "$_rc" -eq 0 ] \
  && pass "IT-091b: pre-flight não aborta quando falta dependência" \
  || fail "IT-091b: install.sh abortou (exit $_rc) — pre-flight deve só avisar"

# ── Resultado ─────────────────────────────────────────────────────────────────
echo ""
echo "────────────────────────────────────────────────────────────────────────"
echo "  PASS: $PASS  |  WARN: $WARN  |  FAIL: $FAIL"
echo "────────────────────────────────────────────────────────────────────────"

[ "$FAIL" -eq 0 ]
