# Vim Config — Guia para IA

Setup profissional de Vim 9.1+ para desenvolvimento poliglota (Elixir/Phoenix, Ruby/Rails, JS/React/Node, Python, Go, Rust).

## Estrutura do repositório

```
configs.vim              ← ARQUIVO PRINCIPAL — todas as customizações pessoais
vimrcs/
  options.vim            ← opções do Vim (set commands, search, indent, UI)
  filetypes.vim          ← detecção de filetype e indent por linguagem
  plugins.vim            ← carregamento do Pathogen + config de plugins terceiros
  editor.vim             ← undo persistente, GUI, helpers, VisualSelection
plugins/                 ← 45 plugins (gerenciados por Pathogen, NÃO vim-plug/lazy)
autoload/pathogen.vim    ← plugin manager
colors/                  ← colorschemes extras (gruvbox é o ativo, vive em plugins/)
test/                    ← suite de testes (vader, jest, shell) — ver docs/test_plan.md
docs/                    ← documentação (keybindings, test plan)
temp_dirs/undodir/       ← undo persistente (cleanup automático >90 dias)
```

## Ordem de carregamento

O `~/.vimrc` carrega nesta ordem — **a última definição vence**:

1. `vimrcs/options.vim` — defaults (shiftwidth=4, colorscheme nenhum, etc.)
2. `vimrcs/filetypes.vim` — filetype detection
3. `vimrcs/plugins.vim` — Pathogen + config de NERDTree, lightline, Goyo, vim-go, gitgutter, grepprg
4. `vimrcs/editor.vim` — undo, GUI, command-line helpers
5. `configs.vim` — **sobrescreve tudo acima** (shiftwidth=2, colorscheme gruvbox, CoC, fzf, mappings)

Plugin `plugin/*.vim` files são sourced pelo Vim **depois** do vimrc completo. Para evitar que plugins sobrescrevam mappings, use variáveis globais (ex: `g:ctrlp_map`) setadas ANTES do Pathogen carregar.

## Convenções obrigatórias

- **Sempre usar `nnoremap`** em vez de `map` para mappings de normal mode (evita visual mode leak e recursão)
- **Sempre envolver autocmds em `augroup`** com `autocmd!` (evita duplicação ao re-source)
- **Nunca usar `set option!`** (toggle) no escopo global — use valor explícito (`set nohlsearch`)
- **configs.vim é o arquivo para editar** — vimrcs/ são camadas base herdadas do amix/vimrc
- **Testes existem e devem passar** — rodar `bash test/run.sh` antes de concluir qualquer mudança

## Sistema de testes

```bash
bash test/run.sh          # compacto — uma linha por suite
bash test/run.sh -v       # expandido — cada caso com ✓/✗
bash test/run.sh -vv      # raw — debug
bash test/run.sh unit     # só uma suite (unit, integration, e2e, json, shell)
```

| Suite | Ferramenta | O que testa |
|---|---|---|
| shell | bash | Existência de plugins, binários, integridade |
| unit | vader.vim | Variáveis, opções, funções VimScript |
| integration | vader.vim | Mappings, autocmds, filetypes, startup |
| e2e | vader.vim | feedkeys (auto-pairs, surround, rooter) |
| jest | Node.js | coc-settings.json (schema, tipos, valores) |

## Plugins — gerenciamento

- **Manager**: Pathogen (NÃO vim-plug, NÃO lazy.nvim)
- **Diretório**: `plugins/` — cada subdiretório é um plugin
- **Submodules**: 27 plugins são git submodules (`.gitmodules`), os demais são embedded
- **Atualizar**: `cd plugins && bash update_plugins.sh`

## LSP

- CoC.nvim é o LSP client — `~/.vim/coc-settings.json` (fora deste repo)
- 21 extensões CoC listadas em `g:coc_global_extensions` no configs.vim
- Fixture para CI em `test/fixtures/coc-settings.json`

## O que NÃO fazer

- Não adicionar `map` (usar `nnoremap`)
- Não criar autocmds fora de augroups
- Não editar vimrcs/ para features novas (usar configs.vim)
- Não remover plugins sem atualizar testes (`test/integration/cleanup.vader`)
- Não commitar `test/node/node_modules/` ou `temp_dirs/undodir/*`
- Não usar `set option!` (toggle) no escopo global
