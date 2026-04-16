# Vim Setup (Vim 9.1+)

Setup profissional para desenvolvimento poliglota: **Elixir/Phoenix, Ruby/Rails, JS/React/Node, Python, Go, Rust**.

Baseado no [amix/vimrc](https://github.com/amix/vimrc), refatorado com CoC.nvim como LSP client, fzf como busca unificada, e 219 testes automatizados.

## Estrutura

```
configs.vim              ← arquivo principal — edite aqui
vimrcs/
  options.vim            ← opcoes do Vim (set commands)
  filetypes.vim          ← deteccao de filetype e indent por linguagem
  plugins.vim            ← Pathogen + config de plugins terceiros
  editor.vim             ← undo persistente, GUI, helpers
plugins/                 ← 45 plugins (Pathogen)
test/                    ← suite de testes (vader, jest, shell)
docs/                    ← documentacao
  keybindings.md         ← cheatsheet completo de atalhos
  test_plan.md           ← plano e arquitetura de testes
```

## Instalacao

```bash
git clone --recursive https://github.com/albertosca/vim-runtime.git ~/.vim_runtime
ln -sf ~/.vim_runtime/vimrc_example ~/.vimrc   # ou edite o seu ~/.vimrc
```

O `~/.vimrc` deve carregar nesta ordem:

```vim
source ~/.vim_runtime/autoload/pathogen.vim
call pathogen#infect('~/.vim_runtime/plugins/{}')
source ~/.vim_runtime/vimrcs/options.vim
source ~/.vim_runtime/vimrcs/filetypes.vim
source ~/.vim_runtime/vimrcs/plugins.vim
source ~/.vim_runtime/vimrcs/editor.vim
source ~/.vim_runtime/configs.vim
```

## Plugins (45)

| Categoria | Plugins |
|---|---|
| **LSP / Completion** | coc.nvim (21 extensoes), vim-snippets |
| **Busca** | fzf, fzf.vim |
| **Navegacao** | NERDTree, vim-rooter, vim-projectionist, vim-rails |
| **Git** | vim-fugitive, vim-gitgutter, gv.vim |
| **Edicao** | vim-surround, auto-pairs, vim-visual-multi, vim-commentary, vim-endwise, vim-repeat, tabular, vim-expand-region, vim-indent-object, vim-unimpaired, vim-abolish, vim-closetag |
| **Testes** | vim-test, vimux |
| **Linguagens** | vim-elixir, vim-mix-format, vimix, vim-go, rust.vim, vim-jsx-improve, vim-js-pretty-template, vim-mdx-js, vim-markdown |
| **Database** | vim-dadbod, vim-dadbod-ui, vim-dadbod-completion |
| **UI** | lightline.vim, gruvbox, vim-devicons, vim-nerdtree-syntax-highlight, undotree, goyo.vim, vim-obsession, set_tabline |

**Atualizar plugins:**
```bash
cd ~/.vim_runtime/plugins && bash update_plugins.sh
```

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

| Extensao | Cobertura |
|---|---|
| coc-elixir | Elixir LSP (ElixirLS) |
| coc-solargraph | Ruby LSP |
| coc-tsserver | TypeScript, JavaScript, React |
| coc-pyright | Python LSP |
| coc-css, coc-tailwindcss | CSS, Tailwind |
| coc-eslint, coc-prettier | Linting e formatacao |
| coc-emmet | Expansao HTML/JSX |
| coc-snippets | Snippets (vim-snippets) |
| coc-sql | SQL completion |
| coc-html, coc-json, coc-yaml, coc-xml, coc-sh | Markup e config |
| coc-git, coc-yank | Git inline, historico de yanks |
| coc-docker, coc-browser, coc-markdownlint | Docker, browser APIs, markdown |

## Testes

219 testes automatizados em 5 suites:

```bash
bash test/run.sh          # compacto — uma linha por suite
bash test/run.sh -v       # expandido — cada caso com check/X
bash test/run.sh -vv      # raw — debug completo
bash test/run.sh unit     # rodar uma suite especifica
```

```
  Vim Config Test Suite
  ─────────────────────────────────────────────────
  ✓  shell            32 passed  1 warn  0 failed
  ✓  unit             64 passed  0 failed
  ✓  integration      87 passed  0 failed
  ✓  e2e              19 passed  0 failed
  ✓  jest             17 passed  0 failed
  ─────────────────────────────────────────────────
  ✓ 219 passed   all green
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

## Licenca

MIT
