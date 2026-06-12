# Vim Setup (Vim 9.1+)

Setup profissional para desenvolvimento poliglota: **Elixir/Phoenix, Ruby/Rails, JS/React/Node, Python, Go, Rust**.

Baseado no [amix/vimrc](https://github.com/amix/vimrc), refatorado com CoC.nvim como LSP client, fzf como busca unificada, e 316 testes automatizados.

## Estrutura

```
configs.vim              ← arquivo principal — edite aqui
vimrcs/
  options.vim            ← opcoes do Vim (set commands)
  filetypes.vim          ← deteccao de filetype e indent por linguagem
  plugins.vim            ← Pathogen + config de plugins terceiros
  editor.vim             ← undo persistente, GUI, helpers
plugins/                 ← 49 plugins (Pathogen)
test/                    ← suite de testes (vader, jest, shell)
docs/                    ← documentacao
  keybindings.md         ← cheatsheet completo de atalhos
  test_plan.md           ← plano e arquitetura de testes
```

## Instalacao

> ⚠️ O repo **precisa** ficar em `~/.vim_runtime` — os paths sao hardcoded
> (sources, undodir). Use exatamente o caminho do clone abaixo.

**Automatica (recomendada):**

```bash
git clone https://github.com/albertosca/vim-runtime.git ~/.vim_runtime
bash ~/.vim_runtime/install.sh
```

> **Pré-requisitos:** Vim 9.1+, **Node.js** (sem ele o CoC/LSP não carrega),
> git e ripgrep. Setup detalhado por OS, primeiro-run e troubleshooting em
> **[docs/setup.md](docs/setup.md)**.

O `install.sh` e idempotente e faz backup do que ja existir. Ele inicializa
os submodules um a um (resiliente), cria `~/.vimrc` apontando para
`vimrc_example`, e linka `coc-settings.json` em `~/.vim/coc-settings.json`.

**Alternativa com `--recursive`** (submodules estao saudaveis, tambem funciona):

```bash
git clone --recursive https://github.com/albertosca/vim-runtime.git ~/.vim_runtime
bash ~/.vim_runtime/install.sh
```

**Manual:**

```bash
git clone https://github.com/albertosca/vim-runtime.git ~/.vim_runtime
git -C ~/.vim_runtime submodule update --init
ln -sf ~/.vim_runtime/vimrc_example ~/.vimrc
mkdir -p ~/.vim
ln -sf ~/.vim_runtime/coc-settings.json ~/.vim/coc-settings.json
```

O `~/.vimrc` (via `vimrc_example`) carrega nesta ordem — a ultima definicao vence:

```vim
source ~/.vim_runtime/autoload/pathogen.vim
call pathogen#infect('~/.vim_runtime/plugins/{}')
source ~/.vim_runtime/vimrcs/options.vim
source ~/.vim_runtime/vimrcs/filetypes.vim
source ~/.vim_runtime/vimrcs/plugins.vim
source ~/.vim_runtime/vimrcs/editor.vim
source ~/.vim_runtime/configs.vim
```

## Plugins (49)

| Categoria | Plugins |
|---|---|
| **LSP / Completion** | coc.nvim (25 extensoes), vim-snippets |
| **IA** | copilot-chat.vim, vim-claude-code |
| **Busca** | fzf, fzf.vim |
| **Navegacao** | NERDTree, vim-rooter, vim-projectionist, vim-rails, vim-tmux-navigator |
| **Git** | vim-fugitive, vim-gitgutter, gv.vim |
| **Edicao** | vim-surround, auto-pairs, vim-visual-multi, vim-commentary, vim-endwise, vim-repeat, tabular, vim-expand-region, vim-indent-object, vim-unimpaired, vim-abolish, vim-closetag, vim-matchup, vim-sleuth |
| **Testes** | vim-test, vimux |
| **Linguagens** | vim-elixir, vim-mix-format, vim-go, rust.vim, vim-jsx-improve, vim-js-pretty-template, vim-mdx-js, vim-markdown |
| **Database** | vim-dadbod, vim-dadbod-ui, vim-dadbod-completion |
| **UI** | lightline.vim, gruvbox, vim-devicons, vim-nerdtree-syntax-highlight, undotree, goyo.vim, vim-obsession, set_tabline |

**Atualizar plugins:** veja o guia em **[docs/updating-plugins.md](docs/updating-plugins.md)**.

## Atalhos

`mapleader` = `,` (virgula). Cheatsheet completo em **[docs/keybindings.md](docs/keybindings.md)**.

Destaques:

| Atalho | Acao |
|---|---|
| `Ctrl+f` | Buscar arquivos (fzf) |
| `Ctrl+b` | Buscar buffers (fzf) |
| `K` | Documentacao (CoC hover) |
| `gd` | Goto definition |
| `,tn` | Rodar teste sob o cursor |
| `:A` | Alternar codigo/teste |
| `,gv` | Git log navegavel |
| `,db` | Database UI |

## Extensoes CoC

25 extensoes instaladas automaticamente na primeira abertura do Vim:

| Extensao | Cobertura |
|---|---|
| coc-elixir | Elixir LSP (ElixirLS) |
| coc-tsserver | TypeScript, JavaScript, React |
| coc-pyright | Python LSP |
| coc-go | Go LSP (gopls) |
| coc-css, coc-tailwindcss | CSS, Tailwind |
| coc-eslint, coc-prettier, coc-stylelint, coc-stylelintplus | Linting e formatacao |
| coc-emmet | Expansao HTML/JSX |
| coc-snippets | Snippets (vim-snippets) |
| coc-sql | SQL completion |
| coc-html, coc-json, coc-yaml, coc-xml, coc-sh | Markup e config |
| coc-git, coc-yank | Git inline, historico de yanks |
| coc-docker, coc-browser, coc-markdownlint | Docker, browser APIs, markdown |
| coc-markdown-preview-enhanced, coc-webview | Preview de markdown |

> Ruby e Rust nao vem com LSP por padrao — veja **[docs/setup.md](docs/setup.md)**.

## Testes

316 testes automatizados em 5 suites:

```bash
bash test/run.sh          # compacto — uma linha por suite
bash test/run.sh -v       # expandido — cada caso com check/X
bash test/run.sh -vv      # raw — debug completo
bash test/run.sh unit     # rodar uma suite especifica
```

```
  Vim Config Test Suite
  ─────────────────────────────────────────────────────
  ✓  shell            48 passed  1 warn  0 failed
  ✓  unit             90 passed  0 failed
  ✓  integration      131 passed  0 failed
  ✓  e2e              19 passed  0 failed
  ✓  jest             28 passed  0 failed
  ─────────────────────────────────────────────────────
  ✓ 316 passed   all green
```

Detalhes da arquitetura de testes em **[docs/test_plan.md](docs/test_plan.md)**.

## Dicas de Workflow

1. **Navegacao por projeto:** `,gf` (so arquivos git) e mais rapido que `Ctrl+f` em projetos grandes
2. **Busca + substituicao global:** `,rg palavra` → seleciona com `Tab` → `:cfdo %s/old/new/g | update`
3. **Sessao por projeto:** Cada projeto tem seu `Session.vim`. Entre no diretorio e `vim` restaura tudo
4. **Blame em linha:** `,gm` mostra autor, hash e mensagem do commit da linha atual em popup
5. **Diagnosticos rapidos:** `]g` pula pro proximo erro, `,a` sugere correcao automatica
6. **Auto-save:** Todos os buffers sao salvos ao sair do foco do Vim (troca de app/tmux pane)
7. **Raiz do projeto automatica:** vim-rooter detecta `.git`, `mix.exs`, `Gemfile`, `package.json` e faz `cd` automatico

## Ecossistema

Este config faz parte de um setup maior:

| Repo | O que e |
|---|---|
| **[albertosca/vim](https://github.com/albertosca/vim)** | Este repo — config Vim com Pathogen + CoC |
| **[albertosca/tmux](https://github.com/albertosca/tmux)** | Config tmux complementar |
| **[albertosca/vim-tutorial](https://github.com/albertosca/vim-tutorial)** | Tutorial interativo Vim + tmux para devs |

## Licenca

MIT
