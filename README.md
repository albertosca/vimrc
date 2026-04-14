# Alberto SCA - Vim Setup (Vim 9.1+)

Setup profissional para desenvolvimento poliglota: **Elixir/Phoenix · Ruby/Rails · JS/React/Node · CSS · Python · MySQL · PostgreSQL**

---

## Estrutura de Arquivos

| Arquivo | Função |
| :--- | :--- |
| `~/.vimrc` | Carregador principal |
| `~/.vim_runtime/my_configs.vim` | **Suas customizações — edite aqui** |
| `~/.vim/coc-settings.json` | Configuração do LSP (CoC.nvim) |
| `~/.vim_runtime/my_plugins/` | Todos os plugins (gerenciado por Pathogen) |
| `~/.vim_runtime/vimrcs/` | Configs base (basic, filetypes, plugins, extended) |

**Para atualizar todos os plugins:**
```bash
cd ~/.vim_runtime/my_plugins && bash update_my_plugins.sh
```

---

## GUIA COMPLETO DE ATALHOS

`mapleader` = vírgula (`,`)

---

### 1. Arquivos, Buffers e Busca (fzf)

| Atalho | Ação | Plugin |
| :--- | :--- | :--- |
| `Ctrl+f` | Buscar arquivos do projeto (popup) | `fzf` |
| `Ctrl+b` | Buscar buffers abertos | `fzf` |
| `,gf` | Buscar apenas arquivos rastreados pelo git | `fzf` |
| `,rg` | Busca por conteúdo com ripgrep | `fzf` |
| `,bl` | Buscar linhas no buffer atual | `fzf` |
| `,ht` | Histórico de arquivos abertos | `fzf` |
| `,nn` | Abrir/Fechar árvore de arquivos | `NERDTree` |
| `,nf` | Localizar arquivo atual na árvore | `NERDTree` |
| `,o` | Explorador de buffers | `BufExplorer` |
| `,fr` | Arquivos recentes (MRU) | `MRU` |
| `,cs` | Copiar **nome** do arquivo para clipboard | Custom |
| `,cl` | Copiar **caminho completo** para clipboard | Custom |

> **Dentro do fzf:** `Tab` seleciona múltiplos, `Ctrl+/` alterna preview, `Enter` abre, `Ctrl+t` abre em nova aba, `Ctrl+x` split horizontal, `Ctrl+v` split vertical.

---

### 2. Janelas (Windows) e Abas (Tabs)

| Atalho | Ação |
| :--- | :--- |
| `Ctrl+h/j/k/l` | Navegar entre splits |
| `Ctrl+Shift+h/l` | Mover aba para esquerda ou direita |
| `gr` | Aba anterior |
| `:tabnew` | Nova aba |
| `,tc` | Fechar aba |
| `,te` | Abrir aba no diretório do arquivo atual |

---

### 3. Edição e Produtividade

| Atalho | Ação | Plugin |
| :--- | :--- | :--- |
| `Alt+j/k` | Mover linha para baixo/cima | Nativo |
| `,w` | Salvar (`:w!`) | Nativo |
| `*` / `#` | Buscar palavra selecionada em visual mode | Nativo |
| `F3` | Ligar/desligar realce de busca | Nativo |
| `,ss` | Ligar/desligar corretor ortográfico | Nativo |
| `,pp` | Ligar/desligar modo paste | Nativo |
| `Ctrl+n` | Múltiplos cursores (seleciona próxima ocorrência) | `vim-multiple-cursors` |
| `Ctrl+n/p` | Navegar histórico de yanks | `vim-yankstack` |
| `,u` | Abrir árvore visual de undo | `undotree` |
| `Ctrl+p` | Ligar/desligar auto-pairs | `auto-pairs` |

> **Smart auto-pairs:** `(`, `[`, `{`, `"`, `'`, `` ` `` não fecham automaticamente quando há texto colado à **direita** do cursor. Fechamento e backspace inteligente continuam funcionando normalmente.

---

### 4. vim-surround — Envolver texto

**Modo normal** (`ysiw` = word, `yss` = linha inteira, `ys2j` = 2 linhas):

| Atalho | Resultado |
| :--- | :--- |
| `ysiw"` | `"palavra"` |
| `ysiw(` | `(palavra)` |
| `ysiw d` | `do` ↵ `palavra` ↵ `end` |
| `cs"'` | Troca `"` por `'` em volta do cursor |
| `ds"` | Remove as `"` em volta do cursor |

**Modo visual** (`v`/`V` seleciona → `S` + char envolve):

| `S` + | Resultado | Stack |
| :--- | :--- | :--- |
| `"` `'` `` ` `` | `"seleção"` `'seleção'` `` `seleção` `` | Qualquer |
| `(` ou `b` | `(seleção)` | Qualquer |
| `[` ou `r` | `[seleção]` | Qualquer |
| `{` ou `B` | `{seleção}` | Qualquer |
| `t` | `<tag>seleção</tag>` — pergunta a tag | HTML |
| `f` | `nome(seleção)` — pergunta o nome | Qualquer |
| `d` | `do` ↵ `seleção` ↵ `end` | Elixir, Ruby |
| `e` | `fn -> seleção end` (inline) | Elixir |
| `E` | `fn ->` ↵ `seleção` ↵ `end` | Elixir |
| `n` | `defmodule seleção do` ↵ `end` | Elixir |
| `g` | `begin` ↵ `seleção` ↵ `end` | Ruby |
| `=` | `<%= seleção %>` | Rails ERB |
| `%` | `<% seleção %>` | Rails ERB |

---

### 5. LSP e Completion (CoC.nvim)

| Atalho | Ação |
| :--- | :--- |
| `Tab` / `Shift+Tab` | Próximo/anterior item do completion |
| `Enter` | Confirmar completion |
| `Ctrl+Space` | Triggerar completion manualmente |
| `Ctrl+j` | Expandir/pular snippet |
| `K` | Documentação (hover popup) |
| `Ctrl+]` / `Cmd+]` | Goto Definition |
| `Ctrl+t` / `Cmd+[` | Voltar da definição |
| `gd` | Goto Definition (alternativo) |
| `gy` | Goto Type Definition |
| `gi` | Goto Implementation |
| `,gr` | Listar todas as referências |
| `,rn` | Renomear símbolo em todo o projeto |
| `,f` | Formatar seleção ou arquivo |
| `,a` | Code Actions no cursor (normal) ou seleção (visual) |
| `[g` / `]g` | Diagnóstico anterior / próximo |
| `Space+a` | Lista de todos os diagnósticos |
| `Space+o` | Outline do documento |
| `Space+s` | Buscar símbolos no workspace |
| `Space+e` | Gerenciar extensões CoC |
| `Space+c` | Listar comandos CoC |
| `Space+j/k` | Próximo/anterior na lista CoC ativa |
| `Space+p` | Retomar última lista CoC |
| `:Format` | Formatar buffer inteiro |
| `:OR` | Organizar imports |

---

### 6. Navegação de Diagnósticos e Quickfix (vim-unimpaired)

| Atalho | Ação |
| :--- | :--- |
| `[g` / `]g` | Diagnóstico CoC anterior/próximo |
| `[q` / `]q` | Quickfix anterior/próximo |
| `[l` / `]l` | Location list anterior/próximo |
| `[b` / `]b` | Buffer anterior/próximo |
| `[n` / `]n` | Conflito de merge anterior/próximo |

---

### 7. Git

| Atalho | Ação | Plugin |
| :--- | :--- | :--- |
| `,gv` | Git log do projeto (navegável) | `gv.vim` |
| `,gV` | Git log do arquivo atual | `gv.vim` |
| `,gm` | Popup com commit e autor da linha atual | Custom |
| `,d` | Ligar/desligar diff no gutter | `vim-gitgutter` |
| `:Git` | Interface completa do git | `vim-fugitive` |
| `:Git blame` | Blame do arquivo | `vim-fugitive` |

> **Dentro do `:GV`:** `Enter` abre o commit, `o` abre em split, `q` fecha.

---

### 8. Testes (vim-test + Vimux)

| Atalho | Ação | Estratégia |
| :--- | :--- | :--- |
| `,tn` | Rodar teste **sob o cursor** | Vimux (tmux) |
| `,tf` | Rodar todos os testes do **arquivo** | Vimux (tmux) |
| `,ts` | Rodar a **suíte inteira** | Vimux (tmux) |
| `,tl` | Repetir **último** teste | Vimux (tmux) |
| `,tv` | Ir para o último arquivo de teste | — |

**Suporte automático por linguagem:**
- Elixir → `mix test`
- Ruby → `bundle exec rspec`
- JS/Node → Jest, Mocha, Jasmine (detecção automática)
- Python → pytest, unittest

---

### 9. Stacks Específicas

| Atalho | Ação | Stack |
| :--- | :--- | :--- |
| `:A` | Alternar código ↔ teste | Elixir, Ruby/Rails |
| `,mf` | Mix Format (manual) | Elixir |
| `,md` | Mix Format Diff (preview das mudanças) | Elixir |
| `,lc` | `mix credo --strict` no tmux | Elixir |
| `,ie` | Abrir IEx REPL no tmux | Elixir |
| `:Emodel` / `:Econtroller` | Navegar para model/controller | Rails |
| `:Emigration` | Abrir migration | Rails |
| `:Eview` | Abrir view | Rails |

**Auto-format ao salvar:** `.ex`, `.exs`, `.heex` (CoC + mix format)

---

### 10. Banco de Dados (vim-dadbod)

| Atalho / Comando | Ação |
| :--- | :--- |
| `,db` | Abrir/fechar DB UI explorer |
| `,dba` | Adicionar nova conexão |
| `,dbf` | Encontrar buffer de query atual no explorer |
| `,dbr` | Renomear buffer de query atual |
| `:DB [url] [query]` | Executar SQL em split |

**Formato das URLs:**
```
postgresql://user:pass@localhost:5432/mydb
mysql://user:pass@localhost:3306/mydb
```

---

### 11. Sessões e Histórico

| Atalho / Comando | Ação |
| :--- | :--- |
| `,os` | Inicia/para tracking da sessão (`Session.vim` no CWD) |
| `vim` (sem args) | Restaura sessão automaticamente se `Session.vim` existir |
| `,u` | Abre árvore visual de undo (histórico persistente) |

**Fluxo de sessão:**
```bash
cd ~/meu-projeto && vim   # restaura automaticamente se Session.vim existir
,os                       # começa a gravar sessão
,os                       # para de gravar
```

---

### 12. Terminal e Tmux (Vimux)

| Atalho | Ação |
| :--- | :--- |
| `,vp` | Prompt para rodar comando no painel tmux |
| `,vl` | Repetir último comando |
| `,vq` | Fechar painel tmux |
| `,vx` | Enviar `Ctrl+C` ao painel tmux |

---

### 13. Foco e Misc

| Atalho | Ação |
| :--- | :--- |
| `,z` | Modo zen (Goyo — remove distrações visuais) |
| `,g` | Busca global com Ack (resultados em quickfix) |
| `gv` | Busca visual selecionada com Ack |
| `,mdp` | Preview do Markdown |
| `,mdt` | Inserir tabela Markdown |
| `,mdl` | Listar comandos Markdown |

---

## Extensões CoC instaladas

| Extensão | Cobertura |
| :--- | :--- |
| `coc-elixir` | Elixir LSP (ElixirLS) |
| `coc-solargraph` | Ruby LSP |
| `coc-tsserver` | TypeScript, JavaScript, React |
| `coc-pyright` | Python LSP |
| `coc-css` | CSS, SCSS, Less |
| `coc-tailwindcss` | Tailwind (incluindo `.heex`) |
| `coc-eslint` | Linting JS/TS |
| `coc-prettier` | Formatação |
| `coc-emmet` | Expansão HTML/JSX |
| `coc-snippets` | Snippets (usa `vim-snippets`) |
| `coc-sql` | SQL completion |
| `coc-html` | HTML |
| `coc-json` | JSON |
| `coc-yaml` | YAML |
| `coc-xml` | XML |
| `coc-sh` | Shell scripts |
| `coc-git` | Git status inline |
| `coc-yank` | Histórico de yanks |
| `coc-docker` | Dockerfile |
| `coc-browser` | Browser APIs completion |
| `coc-markdownlint` | Linting de Markdown |

---

## Dicas de Workflow

1. **Navegação por projeto:** `,gf` (só arquivos do git) é mais rápido que `Ctrl+f` em projetos grandes.
2. **Busca + substituição global:** `,rg palavra` → `Tab` pra selecionar múltiplos arquivos → `:cfdo %s/old/new/g | update`.
3. **Sessão por projeto:** Cada projeto tem seu `Session.vim`. Entre no diretório e `vim` restaura tudo.
4. **Blame em linha:** `,gm` mostra autor, hash e mensagem do commit da linha atual em popup.
5. **Diagnósticos rápidos:** `]g` pula pro próximo erro, `,a` sugere correção automática.
6. **Trailing whitespace:** Removido automaticamente ao salvar em `.ex`, `.exs`, `.heex`, `.rb`, `.ts`, `.tsx`, `.css`, `.scss`, `.js`, `.py`, `.sh`.
7. **Auto-save:** Todos os buffers são salvos ao sair do foco do Vim (troca de app ou tmux pane).
8. **Raiz do projeto automática:** `vim-rooter` detecta a raiz (`.git`, `mix.exs`, `Gemfile`, `package.json`…) e faz `cd` automático ao abrir qualquer arquivo — fzf, Ack e `:A` sempre partem do lugar certo.
9. **Surround visual rápido:** `V` seleciona linhas → `S d` envolve em `do/end`. Em modo char (`v`), `S e` envolve inline com `fn -> end`.
