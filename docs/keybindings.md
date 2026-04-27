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
| `,nb` | Abrir NERDTree a partir de um bookmark | NERDTree |
| `,cs` | Copiar **nome** do arquivo para clipboard | Custom |
| `,cl` | Copiar **caminho completo** para clipboard | Custom |

> **Dentro do fzf:** `Tab` seleciona multiplos, `Ctrl+/` alterna preview, `Enter` abre, `Ctrl+t` abre em nova aba, `Ctrl+x` split horizontal, `Ctrl+v` split vertical.

---

## 2. Janelas, Abas e Buffers

**Splits e abas:**

| Atalho | Acao |
| :--- | :--- |
| `Ctrl+h/j/k/l` | Navegar entre splits |
| `Ctrl+Shift+h/l` | Mover aba para esquerda ou direita |
| `gr` | Aba anterior |
| `,tn` | Nova aba (se vim-test nao interceptar — ver secao 8) |
| `,tc` | Fechar aba |
| `,to` | Fechar todas as outras abas (`:tabonly`) |
| `,te` | Abrir aba no diretorio do arquivo atual |
| `,tl` | Toggle entre esta aba e a ultima acessada |
| `,tm <num>` | Mover aba para posicao `<num>` (interativo) |
| `,t,` | Ir para proxima aba (`<leader>t<leader>` → `:tabnext`) |

**Buffers:**

| Atalho | Acao |
| :--- | :--- |
| `,l` | Proximo buffer |
| `,h` | Buffer anterior |
| `,bd` | Fechar buffer atual (e a aba se ficar vazia) |
| `,ba` | Fechar TODOS os buffers (`:bufdo bd`) |
| `[b` / `]b` | Buffer anterior/proximo (vim-unimpaired — ver secao 6) |

---

## 3. Edicao e Produtividade

**Edicao e busca:**

| Atalho | Acao | Plugin |
| :--- | :--- | :--- |
| `Alt+j/k` | Mover linha para baixo/cima (`Cmd+j/k` no GVim macOS) | Nativo |
| `,w` | Salvar (`:w!`) | Nativo |
| `*` / `#` | Buscar palavra selecionada em visual mode | Nativo |
| `F3` | Ligar/desligar realce de busca | Nativo |
| `,<Enter>` | Desligar realce da busca atual (`:noh`) | Nativo |
| `(visual) ,r` | Buscar-e-substituir o texto selecionado | Custom |
| `,pp` | Ligar/desligar modo paste | Nativo |
| `Ctrl+n` | Multiplos cursores (proxima ocorrencia — ver secao 15) | vim-visual-multi |
| `,u` | Abrir arvore visual de undo | undotree |
| `Ctrl+p` | Ligar/desligar auto-pairs | auto-pairs |
| `,cd` | `cd` para o diretorio do arquivo atual (e mostra `pwd`) | Nativo |
| `,m` | Remover caracteres `^M` (line endings Windows) | Nativo |

**Scratch buffers (rascunho global):**

| Atalho | Acao |
| :--- | :--- |
| `,q` | Abrir scratch livre em `~/buffer` |
| `,x` | Abrir scratch Markdown em `~/buffer.md` |

**Corretor ortografico:**

| Atalho | Acao |
| :--- | :--- |
| `,ss` | Ligar/desligar corretor |
| `,sn` | Proximo erro (`]s`) |
| `,sp` | Erro anterior (`[s`) |
| `,sa` | Adicionar palavra ao dicionario (`zg`) |
| `,s?` | Sugerir correcoes para a palavra sob o cursor (`z=`) |

**Linha de comando (`:` e `/`) — atalhos estilo Emacs/readline:**

| Atalho | Acao |
| :--- | :--- |
| `Ctrl+A` | Ir para o inicio da linha |
| `Ctrl+E` | Ir para o fim da linha |
| `Ctrl+K` | Apagar do cursor ate o fim da linha |
| `Ctrl+P` / `Ctrl+N` | Comando anterior / proximo no historico |

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

**Atalho custom:**

| Sequencia | Resultado | Uso tipico |
| :--- | :--- | :--- |
| `Si` (visual) | `(_selecao)` com cursor apos `)` | Captures Elixir (`&(_)`), lambdas com placeholder |

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

> **Scroll de hover/diagnostic float:** com um popup do CoC aberto (hover via `K`, signature, diagnostic), use `Ctrl+f` / `Ctrl+b` em **insert** ou **visual** mode para rolar o float. Em **normal** mode esses atalhos pertencem ao fzf (Files/Buffers — secao 1); fora de float aberto, `Ctrl+f` em insert vira `<Right>` e `Ctrl+b` vira `<Left>`.

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

---

## 14. IA e Assistentes

### Claude Code (vim-claude-code)

**Terminal:**

| Atalho | Acao |
| :--- | :--- |
| `Ctrl+\` | Toggle terminal Claude Code (normal e terminal mode) |
| `,cC` | Continuar sessao anterior (`--continue`) |
| `,cV` | Abrir em modo verbose |
| `Ctrl+W z` | Maximizar/restaurar janela do terminal Claude |

**Edicao** — funcionam em normal mode (arquivo inteiro) e visual mode (selecao):

| Atalho | Acao |
| :--- | :--- |
| `,ce` | Explicar codigo / selecao |
| `,cf` | Corrigir codigo / selecao |
| `,cr` | Refatorar codigo / selecao |
| `,ct` | Gerar testes para o codigo / selecao |
| `,cd` | Gerar documentacao |
| `,cn` | Renomear simbolo |
| `,co` | Otimizar codigo / selecao |

**Projeto** — normal mode:

| Atalho | Acao |
| :--- | :--- |
| `,cG` | Gerar mensagem de commit |
| `,cR` | Code review do arquivo atual |
| `,cp` | Criar Pull Request |
| `,cP` | Gerar plano de implementacao |
| `,ca` | Analisar codigo / arquitetura |
| `,cD` | Debugging assistido |
| `,cA` | Aplicar diff sugerido pelo Claude |

**Chat e meta:**

| Atalho | Acao |
| :--- | :--- |
| `,cc` | Abrir chat livre com Claude |
| `,cx` | Enviar contexto do buffer ao Claude |
| `,cm` | Selecionar modelo Claude |

> **Comando principal:** `:Claude <subcomando>` — todos os atalhos acima sao wrappers desse comando. Use `:Claude <Tab>` para completar. Subcomandos uteis: `version`, `doctor`, `preview install/status`.

---

### Copilot Chat (copilot-chat.vim)

| Atalho / Comando | Acao |
| :--- | :--- |
| `,pc` | Abrir chat Copilot |
| `(visual) ,cq` | Perguntar ao Copilot sobre a selecao |
| `:CopilotChatToggle` | Toggle do painel de chat |
| `:CopilotChatModels` | Selecionar modelo |
| `:CopilotChatReset` | Limpar conversa atual |
| `:CopilotChatSave [nome]` | Salvar conversa |
| `:CopilotChatLoad [nome]` | Carregar conversa salva |
| `:CopilotChatList` | Listar conversas salvas |
| `:CopilotChatUsage` | Ver uso de tokens |

---

## 15. Visual Block

### Nativo (`Ctrl+V`)

| Atalho | Acao |
| :--- | :--- |
| `Ctrl+V` | Entrar em visual block mode |
| `I` | Inserir texto ANTES do bloco em todas as linhas (confirmar com `Esc`) |
| `A` | Adicionar texto DEPOIS do bloco em todas as linhas (confirmar com `Esc`) |
| `c` | Substituir o bloco em todas as linhas (confirmar com `Esc`) |
| `d` / `x` | Deletar o bloco |
| `r<char>` | Substituir todos os caracteres do bloco por `<char>` |
| `>` / `<` | Indentar / desindentar o bloco |
| `~` | Alternar maiusculas/minusculas |
| `u` / `U` | Converter para minusculas / MAIUSCULAS |
| `J` | Juntar as linhas do bloco |
| `o` | Mover cursor para o canto oposto |

---

### vim-visual-multi (`Ctrl+N`) — multi-cursor

O VM_leader deste plugin e `\` (barra invertida), independente do `<Leader>` do Vim.

**Entrada:**

| Atalho | Acao |
| :--- | :--- |
| `Ctrl+N` | Selecionar proxima ocorrencia da palavra (normal) ou da selecao (visual) |
| `\A` | Selecionar TODAS as ocorrencias de uma vez |
| `\\` | Adicionar cursor na posicao atual |
| `Ctrl+Down` / `Ctrl+Up` | Adicionar cursores verticalmente (coluna) |
| `Shift+Down` / `Shift+Up` | Expandir selecao verticalmente |
| `Shift+Right` / `Shift+Left` | Expandir selecao horizontalmente |
| `(visual) \A` | Selecionar todas as ocorrencias da selecao atual |
| `(visual) \c` | Criar cursores nos fins de linha da selecao |
| `(visual) \f` | Usar selecao como padrao de busca |

**Dentro da sessao VM:**

| Atalho | Acao |
| :--- | :--- |
| `Tab` | Alternar cursor mode ↔ extend mode |
| `n` / `N` | Proxima / anterior ocorrencia |
| `]` / `[` | Ir para proximo / anterior cursor |
| `q` | Pular esta ocorrencia e ir para a proxima |
| `Q` | Remover cursor/selecao atual |
| `Esc` | Sair do vim-visual-multi |

**Operacoes (dentro da sessao VM):**

| Atalho | Acao |
| :--- | :--- |
| `\a` | Alinhar cursores na mesma coluna |
| `\m` | Mesclar regioes sobrepostas |
| `\t` | Transpor selecoes entre cursores |
| `\d` | Duplicar cada regiao |
| `\s` | Dividir regioes por padrao regex |
| `\N` / `\n` | Numerar sequencialmente (prefixo / sufixo) |
| `S` | vim-surround em todas as selecoes |
| `M` | Toggle modo multi-linha |
| `\c` / `\C` | Case setting / menu de conversao |

> **Cursor mode** (padrao): comandos normais (`c`, `d`, `y`, `.`, etc.) operam em todos os cursores simultaneamente.
> **Extend mode** (`Tab`): comandos visuais (`>`, `<`, `S`, etc.) operam em todas as selecoes.
