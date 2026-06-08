#!/usr/bin/env bash
#
# install.sh — bootstrap deste setup de Vim para uma máquina do zero.
#
# O que faz (idempotente, sempre faz backup do que já existe):
#   1. Verifica que o repo está em ~/.vim_runtime (os paths são hardcoded).
#   2. Inicializa/atualiza os submodules (fzf, coc.nvim, vim-elixir, ...).
#   3. Cria ~/.vimrc apontando para vimrc_example.
#   4. Linka coc-settings.json em ~/.vim/coc-settings.json (config do LSP).
#
# Uso:
#   git clone --recursive https://github.com/albertosca/vim-runtime.git ~/.vim_runtime
#   bash ~/.vim_runtime/install.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXPECTED="$HOME/.vim_runtime"
STAMP="$(date +%Y%m%d%H%M%S)"

info() { printf '  \033[32m✓\033[0m %s\n' "$1"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$1"; }
err()  { printf '  \033[31m✗\033[0m %s\n' "$1" >&2; }

# Faz backup de um arquivo/symlink existente antes de sobrescrever.
backup_if_exists() {
  local target="$1"
  if [ -e "$target" ] || [ -L "$target" ]; then
    mv "$target" "$target.backup-$STAMP"
    warn "$target já existia — backup em $target.backup-$STAMP"
  fi
}

echo "Vim runtime — instalação"
echo "────────────────────────────────────────────"

# 1. Paths deste setup são hardcoded em ~/.vim_runtime (editor.vim, configs.vim,
#    vimrc_example). Se o repo estiver em outro lugar, o Vim sobe quebrado.
if [ "$REPO_ROOT" != "$EXPECTED" ]; then
  err "Este repo está em $REPO_ROOT, mas o setup exige $EXPECTED."
  err "Os sources e undodir são hardcoded em ~/.vim_runtime."
  err "Mova o repo: mv \"$REPO_ROOT\" \"$EXPECTED\" — e rode de novo."
  exit 1
fi
info "Repo em $EXPECTED"

# 2. Submodules — sem isso fzf, coc.nvim, vim-elixir etc. vêm vazios.
# Itera um a um: se um repo sumiu do GitHub, avisa e continua em vez de abortar tudo.
if command -v git > /dev/null 2>&1 && [ -f "$REPO_ROOT/.gitmodules" ]; then
  echo "Inicializando submodules (pode demorar na primeira vez)..."
  fail_count=0
  while IFS= read -r mod_path; do
    if ! git -C "$REPO_ROOT" submodule update --init "$mod_path" > /dev/null 2>&1; then
      mod_url=$(git -C "$REPO_ROOT" config --file .gitmodules "submodule.$mod_path.url" 2>/dev/null || echo "url desconhecida")
      warn "Submodule ignorado (repo inacessível?): $(basename "$mod_path")  ← $mod_url"
      fail_count=$((fail_count + 1))
    fi
  done < <(git -C "$REPO_ROOT" config --file .gitmodules --get-regexp 'submodule\..*\.path' | awk '{print $2}')
  if [ "$fail_count" -eq 0 ]; then
    info "Submodules atualizados"
  else
    warn "$fail_count submodule(s) ignorado(s) — o Vim funciona, mas esses plugins estão ausentes"
  fi
else
  warn "git ou .gitmodules ausente — pulei submodules"
fi

# 3. ~/.vimrc → vimrc_example
backup_if_exists "$HOME/.vimrc"
ln -sf "$EXPECTED/vimrc_example" "$HOME/.vimrc"
info "~/.vimrc → vim_runtime/vimrc_example"

# 4. coc-settings.json (config das extensões de LSP do CoC)
mkdir -p "$HOME/.vim"
backup_if_exists "$HOME/.vim/coc-settings.json"
ln -sf "$EXPECTED/coc-settings.json" "$HOME/.vim/coc-settings.json"
info "~/.vim/coc-settings.json → vim_runtime/coc-settings.json"

echo "────────────────────────────────────────────"
echo "Pronto. Próximos passos:"
echo "  • Abra o Vim. O CoC vai instalar as extensões de g:coc_global_extensions."
echo "  • LSPs externos opcionais: node, ripgrep (rg), ElixirLS, solargraph, pyright."
echo "  • Veja o README para a lista completa e atalhos."
