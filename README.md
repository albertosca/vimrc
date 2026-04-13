# 🚀 Alberto SCA - Vim Setup (Vim 9.1+)

Setup profissional focado em performance e produtividade poliglota (**Elixir, Ruby, JS/React**).

---

## 🏗️ Estrutura de Arquivos
- **`~/.vimrc`**: Carregador principal (RuntimePath e Sources).
- **`~/.vim_runtime/my_plugins/`**: Único diretório de plugins (Gerenciado por Pathogen).
- **`~/.vim_runtime/my_configs.vim`**: **Onde você deve editar suas configs.**

---

## ⌨️ GUIA COMPLETO DE ATALHOS (Mappings)
O seu `mapleader` é a vírgula (`,`).

### 1. Navegação de Arquivos e Buffers
| Atalho | Ação | Plugin |
| :--- | :--- | :--- |
| `Ctrl + f` | Abrir busca de arquivos (Fuzzy) | `CtrlP` |
| `,j` | Abrir busca de arquivos (Alternativo) | `CtrlP` |
| `Ctrl + b` | Buscar em buffers abertos | `CtrlP` |
| `,nn` | Abrir/Fechar árvore de arquivos | `NERDTree` |
| `,nf` | Localizar arquivo atual na árvore | `NERDTree` |
| `,o` | Abrir explorador de buffers | `BufExplorer` |
| `,f` | Abrir arquivos recentes (MRU) | `MRU` |
| `,cs` / `,cl` | Copiar nome / caminho do arquivo atual | Custom |

### 2. Janelas (Windows) e Abas (Tabs)
| Atalho | Ação | Categoria |
| :--- | :--- | :--- |
| `Ctrl + h/j/k/l` | Mudar entre janelas (Esquerda/Baixo/Cima/Direita) | Nativo Mod. |
| `Ctrl + t` | Abrir nova aba | Nativo Mod. |
| `Ctrl+Shift + h/l` | Mover a aba atual para esquerda ou direita | Custom |
| `gr` | Ir para a aba anterior | Nativo Mod. |
| `,tn` | Criar nova aba | amix/base |
| `,tc` | Fechar aba atual | amix/base |
| `,te` | Abrir aba no mesmo diretório do arquivo atual | amix/base |

### 3. Edição e Produtividade
| Atalho | Ação | Plugin |
| :--- | :--- | :--- |
| `Alt + j/k` | **Mover linha atual** para baixo ou para cima | Nativo Mod. |
| `,w` | Salvar arquivo rápido (`:w!`) | amix/base |
| `*` / `#` | Buscar palavra selecionada (Visual Mode) | amix/base |
| `F3` | Ligar/Desligar realce de busca (`hlsearch`) | Custom |
| `,ss` | Ligar/Desligar corretor ortográfico | amix/base |
| `,pp` | Ligar/Desligar modo `paste` | amix/base |
| `ysiw + char` | Envolver palavra em um caractere (ex: `ysiw"`) | `Surround` |
| `ysiw d` | Envolver palavra em bloco **`do ... end`** | `Surround` |
| `Ctrl + n/p` | Navegar no histórico de **Yanks** (Copias) | `YankStack` |

### 4. Inteligência e LSP (CoC.nvim)
| Atalho | Ação |
| :--- | :--- |
| `Ctrl + ]` / `Cmd + ]` | **Pular para Definição** (Goto Definition) |
| `Ctrl + t` / `Cmd + [` | **Voltar** de onde pulou |
| `K` | Mostrar **Documentação** (Hover) em Popup |
| `gd` / `gy` / `gi` | Goto Definition / Type / Implementation |
| `,rn` | **Renomear** símbolo em todo o projeto |
| `,f` | **Formatar** código (seleção ou arquivo) |
| `,a` | Abrir **Code Actions** (Sugestões de correção) |
| `[g` / `]g` | Ir para o erro/aviso anterior ou seguinte |
| `Space + a` | Lista de diagnósticos (erros) do projeto |

### 5. Stacks Específicas (Elixir, Ruby, JS)
| Atalho | Ação | Stack |
| :--- | :--- | :--- |
| `:A` | Alternar entre Código <=> Teste | Elixir / Ruby |
| `,lc` | Rodar **Credo** (Linter rígido) no Tmux | Elixir |
| `,ie` | Abrir **IEx** (REPL) no Tmux | Elixir |
| `,mf` | **Mix Format** (Formatar manualmente) | Elixir |
| `,tn` / `,tf` | Rodar **Teste** (Próximo / Arquivo) | Todas |
| `,tl` | Rodar **Último Teste** executado | Todas |
| `Tab` | Expansão de Snippets e HTML | Emmet / JS |

### 6. Terminal & Banco de Dados
| Atalho | Ação | Plugin |
| :--- | :--- | :--- |
| `,vp` | Abrir Prompt para rodar comando no Tmux | `Vimux` |
| `,vl` | Repetir último comando enviado ao Tmux | `Vimux` |
| `,vq` | Fechar painel do Tmux | `Vimux` |
| `,vx` | Enviar `Ctrl+C` para o painel do Tmux | `Vimux` |
| `:DB [url]` | Executar SQL e ver resultado em split | `Dadbod` |

---

## 🚀 Dicas de Workflow
1. **Busca Global:** Use `,g` (Ack) para buscar um texto em todos os arquivos. Os resultados aparecem em uma lista rápida.
2. **Modo Zen:** Use `,z` (Goyo) para focar apenas no código, removendo todas as distrações visuais.
3. **Múltiplos Cursores:** Use `Ctrl + s` para selecionar ranges e editar várias linhas ao mesmo tempo (via CoC).
