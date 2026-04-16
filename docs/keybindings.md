# Cheatsheet de Atalhos

`mapleader` = vírgula (`,`)

---

## 1. Arquivos, Buffers e Busca (fzf)

| Atalho | Ação | Plugin |
| :--- | :--- | :--- |
| `Ctrl+f` | Buscar arquivos do projeto (popup) | fzf |
| `Ctrl+b` | Buscar buffers abertos | fzf |
| `,gf` | Buscar apenas arquivos rastreados pelo git | fzf |
| `,rg` | Busca por conteúdo com ripgrep | fzf |
| `,bl` | Buscar linhas no buffer atual | fzf |
| `,ht` | Historico de arquivos abertos | fzf |
| `,nn` | Abrir/Fechar arvore de arquivos | NERDTree |
| `,nf` | Localizar arquivo atual na arvore | NERDTree |
| `,cs` | Copiar **nome** do arquivo para clipboard | Custom |
| `,cl` | Copiar **caminho completo** para clipboard | Custom |

> **Dentro do fzf:** `Tab` seleciona multiplos, `Ctrl+/` alterna preview, `Enter` abre, `Ctrl+t` abre em nova aba, `Ctrl+x` split horizontal, `Ctrl+v` split vertical.

---

## 2. Janelas (Windows) e Abas (Tabs)

| Atalho | Acao |
| :--- | :--- |
| `Ctrl+h/j/k/l` | Navegar entre splits |
| `Ctrl+Shift+h/l` | Mover aba para esquerda ou direita |
| `gr` | Aba anterior |
| `,tn` | Nova aba (se vim-test nao interceptar — ver secao 8) |
| `,tc` | Fechar aba |
| `,te` | Abrir aba no diretorio do arquivo atual |
| `,tl` | Toggle entre esta aba e a ultima acessada |

---

## 3. Edicao e Produtividade

| Atalho | Acao | Plugin |
| :--- | :--- | :--- |
| `Alt+j/k` | Mover linha para baixo/cima | Nativo |
| `,w` | Salvar (`:w!`) | Nativo |
| `*` / `#` | Buscar palavra selecionada em visual mode | Nativo |
| `F3` | Ligar/desligar realce de busca | Nativo |
| `,ss` | Ligar/desligar corretor ortografico | Nativo |
| `,pp` | Ligar/desligar modo paste | Nativo |
| `Ctrl+n` | Multiplos cursores (seleciona proxima ocorrencia) | vim-visual-multi |
| `,u` | Abrir arvore visual de undo | undotree |
| `Ctrl+p` | Ligar/desligar auto-pairs | auto-pairs |

> **Smart auto-pairs:** `(`, `[`, `{`, `"`, `'`, `` ` `` nao fecham automaticamente quando ha texto colado a **direita** do cursor.

---

## 4. vim-surround — Envolver texto

**Modo normal** (`ysiw` = word, `yss` = linha inteira, `ys2j` = 2 linhas):

| Atalho | Resultado |
| :--- | :--- |
| `ysiw"` | `"palavra"` |
| `ysiw(` | `(palavra)` |
| `ysiw d` | `do` / `palavra` / `end` |
| `cs"'` | Troca `"` por `'` em volta do cursor |
| `ds"` | Remove as `"` em volta do cursor |

**Modo visual** (`v`/`V` seleciona, `S` + char envolve):

| `S` + | Resultado | Stack |
| :--- | :--- | :--- |
| `"` `'` `` ` `` | `"selecao"` `'selecao'` `` `selecao` `` | Qualquer |
| `(` ou `b` | `(selecao)` | Qualquer |
| `[` ou `r` | `[selecao]` | Qualquer |
| `{` ou `B` | `{selecao}` | Qualquer |
| `t` | `<tag>selecao</tag>` — pergunta a tag | HTML |
| `f` | `nome(selecao)` — pergunta o nome | Qualquer |
| `d` | `do` / `selecao` / `end` | Elixir, Ruby |
| `e` | `fn -> selecao end` (inline) | Elixir |
| `E` | `fn ->` / `selecao` / `end` | Elixir |
| `n` | `defmodule selecao do` / `end` | Elixir |
| `g` | `begin` / `selecao` / `end` | Ruby |
| `=` | `<%= selecao %>` | Rails ERB |
| `%` | `<% selecao %>` | Rails ERB |

---

## 5. LSP e Completion (CoC.nvim)

| Atalho | Acao |
| :--- | :--- |
| `Tab` / `Shift+Tab` | Proximo/anterior item do completion |
| `Enter` | Confirmar completion |
| `Ctrl+Space` | Triggerar completion manualmente |
| `Ctrl+j` | Expandir/pular snippet |
| `K` | Documentacao (hover popup) |
| `Ctrl+]` / `Cmd+]` | Goto Definition |
| `Ctrl+t` / `Cmd+[` | Voltar da definicao |
| `gd` | Goto Definition (alternativo) |
| `gy` | Goto Type Definition |
| `gi` | Goto Implementation |
| `,gr` | Listar todas as referencias |
| `,rn` | Renomear simbolo em todo o projeto |
| `,f` | Formatar selecao ou arquivo |
| `,a` | Code Actions no cursor (normal) ou selecao (visual) |
| `[g` / `]g` | Diagnostico anterior / proximo |
| `Space+a` | Lista de todos os diagnosticos |
| `Space+o` | Outline do documento |
| `Space+s` | Buscar simbolos no workspace |
| `Space+e` | Gerenciar extensoes CoC |
| `Space+c` | Listar comandos CoC |
| `Space+j/k` | Proximo/anterior na lista CoC ativa |
| `Space+p` | Retomar ultima lista CoC |
| `:Format` | Formatar buffer inteiro |
| `:OR` | Organizar imports |

---

## 6. Navegacao de Diagnosticos e Quickfix (vim-unimpaired)

| Atalho | Acao |
| :--- | :--- |
| `[g` / `]g` | Diagnostico CoC anterior/proximo |
| `[q` / `]q` | Quickfix anterior/proximo |
| `[l` / `]l` | Location list anterior/proximo |
| `[b` / `]b` | Buffer anterior/proximo |
| `[n` / `]n` | Conflito de merge anterior/proximo |

---

## 7. Git

| Atalho | Acao | Plugin |
| :--- | :--- | :--- |
| `,gv` | Git log do projeto (navegavel) | gv.vim |
| `,gV` | Git log do arquivo atual | gv.vim |
| `,gm` | Popup com commit e autor da linha atual | Custom |
| `,d` | Ligar/desligar diff no gutter | vim-gitgutter |
| `:Git` | Interface completa do git | vim-fugitive |
| `:Git blame` | Blame do arquivo | vim-fugitive |

> **Dentro do `:GV`:** `Enter` abre o commit, `o` abre em split, `q` fecha.

---

## 8. Testes (vim-test + Vimux)

| Atalho | Acao |
| :--- | :--- |
| `,tn` | Rodar teste **sob o cursor** |
| `,tf` | Rodar todos os testes do **arquivo** |
| `,ts` | Rodar a **suite inteira** |
| `,tl` | Repetir **ultimo** teste |
| `,tv` | Ir para o ultimo arquivo de teste |

**Suporte automatico por linguagem:** Elixir (`mix test`), Ruby (`bundle exec rspec`), JS (Jest/Mocha), Python (pytest). Estrategia: Vimux (tmux).

---

## 9. Stacks Especificas

| Atalho | Acao | Stack |
| :--- | :--- | :--- |
| `:A` | Alternar codigo / teste | Elixir, Ruby/Rails |
| `,mf` | Mix Format (manual) | Elixir |
| `,md` | Mix Format Diff (preview) | Elixir |
| `,lc` | `mix credo --strict` no tmux | Elixir |
| `,ie` | Abrir IEx REPL no tmux | Elixir |
| `:Emodel` / `:Econtroller` | Navegar para model/controller | Rails |

**Auto-format ao salvar:** `.ex`, `.exs`, `.heex` (CoC + mix format)

---

## 10. Banco de Dados (vim-dadbod)

| Atalho / Comando | Acao |
| :--- | :--- |
| `,db` | Abrir/fechar DB UI explorer |
| `,dba` | Adicionar nova conexao |
| `,dbf` | Encontrar buffer de query atual no explorer |
| `,dbr` | Renomear buffer de query atual |
| `:DB [url] [query]` | Executar SQL em split |

**Formato das URLs:** `postgresql://user:pass@localhost:5432/mydb` ou `mysql://user:pass@localhost:3306/mydb`

---

## 11. Sessoes e Historico

| Atalho | Acao |
| :--- | :--- |
| `,os` | Inicia/para tracking da sessao (`Session.vim` no CWD) |
| `vim` (sem args) | Restaura sessao automaticamente se `Session.vim` existir |
| `,u` | Abre arvore visual de undo (historico persistente) |

---

## 12. Terminal e Tmux (Vimux)

| Atalho | Acao |
| :--- | :--- |
| `,vp` | Prompt para rodar comando no painel tmux |
| `,vl` | Repetir ultimo comando |
| `,vq` | Fechar painel tmux |
| `,vx` | Enviar `Ctrl+C` ao painel tmux |

---

## 13. Foco e Misc

| Atalho | Acao |
| :--- | :--- |
| `,z` | Modo zen (Goyo — remove distracoes visuais) |
| `,e` | Editar configs.vim |
| `,mdp` | Preview do Markdown |
| `,mdt` | Inserir tabela Markdown |
| `,mdl` | Listar comandos Markdown |
