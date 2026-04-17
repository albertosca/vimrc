# Plano de Testes — Vim Config (Alberto SCA)

## Sumário executivo de tecnologias

### O que É testável automaticamente

| Tecnologia | O que cobre |
| :--- | :--- |
| **vader.vim** | Funções VimScript, conteúdo de buffer após operações, autocommands, variáveis globais, mapeamentos de modo normal via simulação de teclas |
| **Vim nativo headless** (`vim -es -u vimrc`) | Verificação de variáveis, opções, startup sem erros, plugins carregados |
| **Shell (bash + assert)** | Existência de plugins, binários disponíveis, contagem de arquivos, integridade JSON |
| **Jest / Node.js** | Validade do `coc-settings.json` (schema, tipos, valores), lista de extensões CoC |

### O que NÃO é testável automaticamente

- Renderização visual (cores, fontes, cursor, transparência, aparência de borda)
- Janelas flutuantes **visualmente** — mas a **existência** de popups é automável via `popup_list()` (ver UT-055, UT-056, IT-088)
- Resultados reais de LSP (requer servidores de linguagem rodando)
- Integração real com tmux (requer sessão ativa)
- Conexões reais com banco de dados
- Timing e comportamento assíncrono **com `sleep` fixo** — use polling com timeout em vez disso (ex: `while !condition && t-- | sleep 50m | endwhile`)
- Comportamento de modo terminal (`:terminal`)
- Conflitos de mapeamentos que só se manifestam em sequências de teclas compostas no uso interativo real — conflitos simples (1 tecla / prefixo) são verificáveis via `maparg()` (ver IT-084, IT-089, IT-090)

---

## Como executar (referência para o implementador)

### Isolamento XDG (obrigatório antes de qualquer suite)

Os testes **não devem tocar o estado de produção** (undo history, sessões CoC, dados do coc-yank, etc.). Use o shim abaixo para isolar dados e estado em diretórios temporários de teste:

```bash
# test/shim.sh — executar SEMPRE antes de rodar o Vim headless
export XDG_CONFIG_HOME="$(pwd)/test/xdg/config"
export XDG_DATA_HOME="$(pwd)/test/xdg/data"
export XDG_STATE_HOME="$(pwd)/test/xdg/state"
mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"
# ~/.vimrc ainda é carregado; apenas dados/estado ficam isolados
```

O teardown (IT-087) deve limpar `test/xdg/` após a suite.

### Comandos de execução

```bash
# Testes VimScript (vader.vim) — com isolamento
source test/shim.sh && vim -N -u ~/.vimrc -c "Vader! test/unit/*.vader" -c "qa!"

# Testes de configuração (headless)
source test/shim.sh && vim -es -N -u ~/.vimrc -c "source test/check_config.vim" -c "qa!" 2>&1

# Testes de shell
bash test/shell/check_env.sh

# Testes JSON (Node.js)
cd test/node && npm test
```

### CI — GitHub Actions (esqueleto)

```yaml
# .github/workflows/test.yml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: rhysd/action-setup-vim@v1
        with:
          version: v9.1.0000
      - name: Instalar vader.vim
        run: git clone https://github.com/junegunn/vader.vim test/vendor/vader.vim
      - name: Rodar testes unitários e de integração
        run: |
          source test/shim.sh
          vim -N -u ~/.vimrc -c "Vader! test/unit/*.vader test/integration/*.vader" -c "qa!" 2>&1
      - name: Rodar testes de shell
        run: bash test/shell/check_env.sh
      - name: Rodar testes JSON
        run: cd test/node && npm ci && npm test
```

> **Branch protection:** configure a rule exigindo que todos os jobs acima passem antes de merge. Isso cria a "grade de proteção" para modificações por IAs ou colaboradores.

---

## Plano de Implementação

A implementação segue sete fases sequenciais. **Cada fase começa com um "Hello World"** — um único teste mínimo que prova que o mecanismo funciona — antes de implementar os casos reais daquele tipo. Nunca pule o Hello World: se o runner não funciona, nenhum teste adianta.

---

### Fase 0 — Scaffolding (infraestrutura base)

**Objetivo:** criar a estrutura de diretórios e os scripts de suporte. Nenhum teste ainda.

**Tarefas:**

1. Criar a árvore de diretórios:
   ```
   test/
   ├── vendor/          ← dependências de teste (vader.vim)
   ├── unit/            ← testes vader (UT)
   ├── integration/     ← testes vader + headless (IT)
   ├── e2e/             ← testes vader com feedkeys (E2E)
   ├── shell/           ← scripts bash
   ├── node/            ← testes Jest
   ├── manual/          ← checklist dos testes manuais
   └── xdg/             ← criado pelo shim, ignorado pelo git
   ```

2. Criar `test/shim.sh` (conteúdo na seção "Como executar" acima).

3. Adicionar `test/xdg/` ao `.gitignore`.

4. Clonar vader.vim:
   ```bash
   git clone https://github.com/junegunn/vader.vim test/vendor/vader.vim
   ```

5. Criar `test/run.sh` — entry point unificado:
   ```bash
   #!/usr/bin/env bash
   set -e
   source "$(dirname "$0")/shim.sh"
   echo "=== Shell tests ==="
   bash test/shell/check_env.sh
   echo "=== Unit + Integration (vader) ==="
   vim -N -u ~/.vimrc \
     --cmd "set rtp+=test/vendor/vader.vim" \
     -c "Vader! test/unit/*.vader test/integration/*.vader" \
     -c "qa!" 2>&1
   echo "=== E2E (vader) ==="
   vim -N -u ~/.vimrc \
     --cmd "set rtp+=test/vendor/vader.vim" \
     -c "Vader! test/e2e/*.vader" \
     -c "qa!" 2>&1
   echo "=== JSON (Jest) ==="
   cd test/node && npm test
   echo "=== DONE ==="
   ```

**Definição de pronto:** `bash test/run.sh` executa até o fim sem erros (com zero testes — o glob `*.vader` simplesmente não bate nada).

---

### Fase 1 — Hello World: vader.vim → Testes Unitários

**Objetivo:** provar que o runner vader.vim funciona com a config real, depois implementar todos os casos UT.

#### 1a. Hello World

Criar `test/unit/hello.vader`:

```vader
Execute (hello world - mapleader é vírgula):
  AssertEqual ',', mapleader
```

Rodar:
```bash
source test/shim.sh && vim -N -u ~/.vimrc \
  --cmd "set rtp+=test/vendor/vader.vim" \
  -c "Vader! test/unit/hello.vader" -c "qa!" 2>&1
```

**Esperado:** `Success/Total: 1/1`. Se falhar, investigar antes de continuar.

#### 1b. Bloco 1 — Variáveis e opções simples (sem buffer, sem mocks)

Implementar em `test/unit/variables.vader`:
- **UT-028 a UT-040** (mapleader, shiftwidth, tabstop, expandtab, scrolloff, foldmethod, foldlevel, updatetime, signcolumn, clipboard, mix_format_on_save, endwise_no_mappings, AutoPairsShortcutToggle)
- **UT-041 a UT-047** (surround vars: d, e, E, n, g, =, %)
- **UT-048 a UT-052** (projectionist heuristics, CoC extensions)
- **UT-057 a UT-060** (rooter patterns, Vimux, fzf layout, FZF_DEFAULT_COMMAND)

> Estes são os mais simples: apenas `AssertEqual val, g:variable`. Implementar todos de uma vez.

#### 1c. Bloco 2 — Funções com buffer (requer setup de buffer)

Implementar em `test/unit/smart_pairs.vader`:
- **UT-001 a UT-010** (`s:SmartPair`)
- **UT-011 a UT-016** (`s:SmartQuote`)
- **UT-053 a UT-054** (`s:ApplySmartOpenPairs`)

Padrão de setup no vader:
```vader
Before:
  new                 " buffer temporário
  call setline(1, 'foo')
  call cursor(1, 1)

After:
  bwipeout!           " teardown obrigatório
```

#### 1d. Bloco 3 — Funções com estado mais complexo

Implementar em `test/unit/functions.vader`:
- **UT-017 a UT-020** (`CheckBackspace`)
- **UT-021 a UT-022** (`ShowDocumentation` — requer mock de `CocAction`)
- **UT-023 a UT-027** (`s:GitMessenger` — retornos antecipados, hash de zeros)

> Mocking em VimScript: redefina a função no `Before` e restaure no `After`, ou use variáveis globais de stub que a função consulta.

#### 1e. Bloco 4 — Popups

Implementar em `test/unit/popups.vader`:
- **UT-055** (`popup_list()` vazio antes da chamada)
- **UT-056** (`s:GitMessenger` cria 1 popup)

```vader
After:
  call popup_clear()  " teardown obrigatório
```

**Definição de pronto da Fase 1:** `Vader! test/unit/*.vader` passa 100% (≥ 60 casos).

---

### Fase 2 — Hello World: Shell → Dependências e Plugins

**Objetivo:** provar que bash asserts funcionam, depois cobrir existência de plugins e binários.

#### 2a. Hello World

Criar `test/shell/check_env.sh`:

```bash
#!/usr/bin/env bash
set -e
pass() { echo "  PASS: $1"; }
fail() { echo "  FAIL: $1"; exit 1; }

command -v git > /dev/null && pass "git disponível" || fail "git não encontrado"
echo "Hello World OK"
```

Rodar: `bash test/shell/check_env.sh`

**Esperado:** `PASS: git disponível` e `Hello World OK`.

#### 2b. Implementar testes de shell

Expandir `test/shell/check_env.sh` com:
- **IT-001 a IT-014** (existência e integridade de plugins)
- **IT-015 a IT-020** (binários: node ≥14, rg, git ≥2, ElixirLS, ruby, python3)
- **IT-086** (tabela completa de plugin → binário)
- **IT-087** (criação e teardown de `test/xdg/`)

**Definição de pronto da Fase 2:** `bash test/shell/check_env.sh` passa com todos os binários presentes e 64 plugins verificados.

---

### Fase 3 — Hello World: Vim headless → Testes de Integração

**Objetivo:** provar que Vim headless com shim XDG funciona para asserções de estado, depois cobrir todos os IT via vader ou script VimScript.

#### 3a. Hello World

Criar `test/integration/hello.vader`:

```vader
Execute (startup sem erros - hello world headless):
  " Se chegamos aqui, o vimrc carregou sem E-errors
  Assert 1 == 1
```

Rodar:
```bash
source test/shim.sh && vim -N -u ~/.vimrc \
  --cmd "set rtp+=test/vendor/vader.vim" \
  -c "Vader! test/integration/hello.vader" -c "qa!" 2>&1
```

Verificar também que não há linhas `E\d\+:` na saída:
```bash
output=$(source test/shim.sh && vim -es -N -u ~/.vimrc -c "qa!" 2>&1)
echo "$output" | grep -E "^E[0-9]+" && echo "FAIL: erros na startup" && exit 1
echo "PASS: startup limpa"
```

**Esperado:** sem linhas `E[0-9]+`.

#### 3b. Bloco 1 — Startup e augroups

Implementar em `test/integration/startup.vader`:
- **IT-027 a IT-029** (startup sem erros, pathogen, my_configs)
- **IT-082** (startup com shim XDG)
- **IT-083** (augroup SmartOpenPairs registrado)

#### 3c. Bloco 2 — Mapeamentos

Implementar em `test/integration/mappings.vader`:
- **IT-030 a IT-055** (todos os nnoremap definidos)
- **IT-056 a IT-058** (ausência de conflitos históricos)
- **IT-089 a IT-090** (`<C-f>` e `<C-b>` não mapeados para CoC float)
- **IT-084** (verificação exaustiva de conflitos — o mais trabalhoso; iterar sobre lista de teclas com mapeamento e checar unicidade via `maparg(k, 'n', 0, 1).script`)

#### 3d. Bloco 3 — Filetypes e indentação

Implementar em `test/integration/filetypes.vader`:
- **IT-059 a IT-071** (detecção de filetype por extensão)
- **IT-079 a IT-081** (indentação por filetype)

Padrão:
```vader
Execute (heex → filetype heex):
  edit test.heex
  AssertEqual 'heex', &filetype

After:
  bwipeout!
```

#### 3e. Bloco 4 — Autocommands e popup

Implementar em `test/integration/autocommands.vader`:
- **IT-072 a IT-078** (BufWritePre, FocusLost, CursorHold, InsertEnter)
- **IT-088** (popup_list após GitMessenger)

**Definição de pronto da Fase 3:** `Vader! test/integration/*.vader` passa 100% (≥ 63 casos).

---

### Fase 4 — Hello World: Jest/Node.js → Testes JSON

**Objetivo:** provar que Node.js + Jest conseguem ler e validar o `coc-settings.json`.

#### 4a. Hello World

```bash
cd test/node
npm init -y
npm install --save-dev jest
```

Criar `test/node/coc-settings.test.js`:

```js
const fs = require('fs');
const path = require('path');

const settingsPath = path.join(process.env.HOME, '.vim', 'coc-settings.json');
const settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));

test('coc-settings.json é JSON válido e carregável', () => {
  expect(settings).toBeDefined();
  expect(typeof settings).toBe('object');
});
```

Rodar: `npm test`

**Esperado:** `1 passed`.

#### 4b. Implementar validações JSON

Expandir o arquivo de teste com:
- **IT-021** (JSON válido — já coberto pelo hello world)
- **IT-022** (`eslint.autoFixOnSave` é boolean true)
- **IT-023** (`elixir.pathToElixirLS` aponta para arquivo existente — usa `fs.existsSync` com `~` expandido)
- **IT-024** (`tailwindCSS.includeLanguages` cobre heex e eruby)
- **IT-025** (`emmet.includeLanguages` cobre jsx e tsx)
- **IT-026** (ausência de chaves depreciadas)
- **IT-085** (`elixirLS.dialyzerEnabled` é boolean)

**Definição de pronto da Fase 4:** `npm test` passa com ≥ 7 casos.

---

### Fase 5 — Hello World: feedkeys E2E → Testes End-to-End

**Objetivo:** provar que `feedkeys` com flag `'tx'` funciona para simular digitação real e verificar o estado do buffer, depois cobrir os E2E automáveis.

#### 5a. Hello World

Criar `test/e2e/hello.vader`:

```vader
Execute (hello world - feedkeys insere texto no buffer):
  new
  startinsert
  call feedkeys("hello world", 'tx')
  stopinsert

Expect:
  hello world

After:
  bwipeout!
```

Rodar: `Vader! test/e2e/hello.vader`

**Esperado:** buffer contém `hello world`. Se `feedkeys` não sincronizar (output vazio ou errado), ajustar para `'tx'` + `call feedkeys("\<Esc>", 'tx')` antes do `Expect`.

#### 5b. Bloco 1 — Smart Auto-Pairs (E2E automáveis)

Implementar em `test/e2e/auto_pairs.vader`:
- **E2E-001** — `(` antes de palavra não fecha
- **E2E-002** — `(` em linha vazia fecha
- **E2E-003** — `[` antes de palavra não fecha
- **E2E-004** — `{` antes de texto não fecha
- **E2E-005** — `"` antes de palavra não fecha
- **E2E-006** — `"` com `"` à direita pula por cima
- **E2E-007** — Backspace dentro de `()` apaga ambos
- **E2E-008** — Texto normal sem interferência

Padrão para cada caso:
```vader
Execute (E2E-001 - abre paren antes de palavra nao fecha):
  new
  call setline(1, 'foo')
  call cursor(1, 1)
  startinsert
  call feedkeys('(', 'tx')
  stopinsert

Expect:
  (foo

After:
  bwipeout!
```

> **Atenção:** E2E-007 e E2E-008 são marcados como "parcialmente automáticos" — depende de auto-pairs estar ativo no buffer. Verificar se `b:AutoPairs` foi inicializado pelo plugin antes de simular backspace.

#### 5c. Bloco 2 — vim-surround (E2E automáveis)

Implementar em `test/e2e/surround.vader`:
- **E2E-009 a E2E-016** (wrapping visual com `V S d`, `v S e`, `V S E`, `v S =`, `v S %`, `ysiw d`, `cs"'`, `ds"`)

> O vim-surround depende de modo visual. Use `feedkeys('V', 'tx')` para entrar em linewise visual, depois `feedkeys('Sd', 'tx')` para o surround.

#### 5d. Bloco 3 — vim-rooter (E2E automáveis via headless)

Implementar em `test/e2e/rooter.vader`:
- **E2E-046 a E2E-048** (mudança de CWD para raiz de projeto ao abrir arquivo)

```vader
Execute (E2E-046 - rooter detecta mix.exs como raiz):
  " Usar um projeto de fixture em test/fixtures/elixir_project/
  edit test/fixtures/elixir_project/lib/app.ex
  AssertEqual fnamemodify('test/fixtures/elixir_project', ':p:h'), getcwd()

After:
  bwipeout!
```

> Criar fixtures mínimas: `test/fixtures/elixir_project/mix.exs` (arquivo vazio), `lib/app.ex`.

**Definição de pronto da Fase 5:** `Vader! test/e2e/*.vader` passa ≥ 20 casos automáveis.

---

### Fase 6 — CI: GitHub Actions

**Objetivo:** rodar tudo automaticamente a cada commit.

**Tarefas:**

1. Criar `.github/workflows/test.yml` com o esqueleto da seção "Como executar".
2. Fazer push de uma branch de teste e verificar que o pipeline passa.
3. Adicionar badge no `README.md`.
4. Configurar branch protection rule no GitHub para exigir que o workflow passe antes de merge em `main`.

**Definição de pronto:** badge verde visível no README; tentativa de push com teste falhando é bloqueada.

---

### Fase 7 — Runbook de testes manuais

**Objetivo:** documentar os 36 casos manuais como checklist executável, para que sejam rastreáveis mesmo sem automação.

**Tarefas:**

1. Criar `test/manual/checklist.md` com os 36 casos organizados por grupo, cada um como `- [ ] E2E-NNN: descrição`.
2. Documentar pré-requisitos reais para cada grupo:
   - **LSP (E2E-052 a E2E-057):** ElixirLS instalado e indexado, arquivo `.ex` de projeto real aberto
   - **tmux/Vimux (E2E-022 a E2E-026, E2E-049 a E2E-051):** sessão tmux ativa com painel aberto
   - **Rails/Elixir :A (E2E-017 a E2E-021):** projeto com estrutura de diretórios completa
   - **DB (E2E-040 a E2E-042):** PostgreSQL ou MySQL rodando localmente com credenciais de teste
3. Executar manualmente e marcar os checkboxes após cada release ou alteração estrutural.

**Definição de pronto:** `test/manual/checklist.md` criado com todos os 36 casos; pelo menos 1 execução manual documentada com data.

---

### Resumo das fases

| Fase | O que valida | Testes implementados | Definição de pronto |
| :--- | :--- | :---: | :--- |
| 0 — Scaffolding | Estrutura + shim XDG | 0 | `bash test/run.sh` executa sem erros |
| 1 — vader.vim Unit | Hello world → todos os UT | ≥ 60 | `Vader! unit/*.vader` 100% verde |
| 2 — Shell | Hello world → plugins + deps | ≥ 25 | `check_env.sh` 100% verde |
| 3 — Vim headless Integration | Hello world → IT completos | ≥ 63 | `Vader! integration/*.vader` 100% verde |
| 4 — Jest/Node.js | Hello world → JSON validation | ≥ 7 | `npm test` 100% verde |
| 5 — vader.vim E2E | Hello world → feedkeys auto-pairs/surround | ≥ 20 | `Vader! e2e/*.vader` 100% verde |
| 6 — CI | GitHub Actions rodando | — | Badge verde + branch protection ativa |
| 7 — Manual runbook | Checklist dos 36 casos manuais | 36 docs | Checklist criado + 1 execução documentada |

---

## Convenções de escrita de testes

Todos os casos seguem o padrão **AAA (Arrange-Act-Assert)**:

- **Arrange (Pré-condições):** estado inicial do buffer, variáveis ou mocks necessários
- **Act (Ação):** a operação exata a executar (tecla, chamada de função, comando)
- **Assert (Esperado):** a única coisa que este teste valida — cada caso testa **uma coisa só** (laser focus)

Todo caso com efeito colateral (popup aberto, buffer extra criado, variável global alterada) deve ter **teardown** explícito nos comentários do teste ou em `AfterEach` do vader.vim.

### Flags de feedkeys nos testes E2E

Testes que simulam digitação via `feedkeys()` devem usar as flags corretas:

| Flag | Quando usar |
| :--- | :--- |
| `'m'` | Remapeia teclas — testa o mapeamento real do usuário (padrão) |
| `'n'` | Não remaeia — testa comportamento base sem mapeamentos |
| `'t'` | Simula digitação real — **obrigatório** em E2E de auto-pairs e surround (afeta undo history e abertura de folds) |
| `'x'` | Executa imediatamente de forma síncrona — útil em testes unitários |

Recomendação: **E2E de auto-pairs e surround usam `'tx'`**; testes de mapeamentos de comandos usam `'mx'`.

---

## TESTES UNITÁRIOS (UT)

> **Ferramenta padrão:** vader.vim  
> **Localização sugerida:** `~/.vim_runtime/test/unit/`

---

### Função `s:SmartPair(open, close)`

**UT-001**
- **Descrição:** Não fecha quando caractere à direita é letra minúscula
- **Pré-condições:** Buffer com `foo` e cursor após o `o`
- **Ação:** Chamar `s:SmartPair('(', ')')`
- **Esperado:** Retorna `(`

**UT-002**
- **Descrição:** Não fecha quando caractere à direita é letra maiúscula
- **Pré-condições:** Buffer com `Foo` e cursor após o `F`
- **Ação:** Chamar `s:SmartPair('(', ')')`
- **Esperado:** Retorna `(`

**UT-003**
- **Descrição:** Não fecha quando caractere à direita é dígito
- **Pré-condições:** Buffer com `42` e cursor antes do `4`
- **Ação:** Chamar `s:SmartPair('[', ']')`
- **Esperado:** Retorna `[`

**UT-004**
- **Descrição:** Não fecha quando caractere à direita é underscore (`_`)
- **Pré-condições:** Buffer com `_var` e cursor antes do `_`
- **Ação:** Chamar `s:SmartPair('{', '}')`
- **Esperado:** Retorna `{` (underscore é `\w`)

**UT-005**
- **Descrição:** Fecha normalmente quando cursor está no fim da linha
- **Pré-condições:** Buffer com `foo` e cursor após o último char (fim de linha)
- **Ação:** Chamar `s:SmartPair('(', ')')`
- **Esperado:** Retorna `()<Left>`

**UT-006**
- **Descrição:** Fecha normalmente quando caractere à direita é espaço
- **Pré-condições:** Buffer com `foo bar`, cursor entre `foo` e `bar` (no espaço ou antes)
- **Ação:** Chamar `s:SmartPair('(', ')')`
- **Esperado:** Retorna `()<Left>`

**UT-007**
- **Descrição:** Fecha normalmente quando caractere à direita é `)` (não é `\w`)
- **Pré-condições:** Buffer com `)` e cursor antes
- **Ação:** Chamar `s:SmartPair('(', ')')`
- **Esperado:** Retorna `()<Left>`

**UT-008**
- **Descrição:** Fecha normalmente em linha completamente vazia
- **Pré-condições:** Buffer com linha vazia e cursor na coluna 1
- **Ação:** Chamar `s:SmartPair('(', ')')`
- **Esperado:** Retorna `()<Left>`

**UT-009**
- **Descrição:** Funciona para par `[` / `]`
- **Pré-condições:** Buffer com `foo` e cursor antes
- **Ação:** Chamar `s:SmartPair('[', ']')`
- **Esperado:** Retorna `[`

**UT-010**
- **Descrição:** Funciona para par `{` / `}`
- **Pré-condições:** Buffer com `foo` e cursor antes
- **Ação:** Chamar `s:SmartPair('{', '}')`
- **Esperado:** Retorna `{`

---

### Função `s:SmartQuote(char)`

**UT-011**
- **Descrição:** Não fecha `"` quando caractere à direita é letra
- **Pré-condições:** Buffer com `foo`, cursor antes do `f`
- **Ação:** Chamar `s:SmartQuote('"')`
- **Esperado:** Retorna `"`

**UT-012**
- **Descrição:** Pula por cima de `"` existente à direita
- **Pré-condições:** Buffer com `"`, cursor antes do `"`
- **Ação:** Chamar `s:SmartQuote('"')`
- **Esperado:** Retorna `<Right>`

**UT-013**
- **Descrição:** Fecha `"` normalmente em linha vazia
- **Pré-condições:** Linha vazia, cursor na coluna 1
- **Ação:** Chamar `s:SmartQuote('"')`
- **Esperado:** Retorna `""<Left>`

**UT-014**
- **Descrição:** Não fecha `'` quando caractere à direita é letra
- **Pré-condições:** Buffer com `foo`, cursor antes do `f`
- **Ação:** Chamar `s:SmartQuote("'")`
- **Esperado:** Retorna `'`

**UT-015**
- **Descrição:** Pula por cima de `` ` `` existente à direita
- **Pré-condições:** Buffer com `` ` ``, cursor antes
- **Ação:** Chamar `` s:SmartQuote('`') ``
- **Esperado:** Retorna `<Right>`

**UT-016**
- **Descrição:** Fecha `` ` `` normalmente quando próximo char é espaço
- **Pré-condições:** Buffer com ` ` (espaço), cursor antes
- **Ação:** Chamar `` s:SmartQuote('`') ``
- **Esperado:** Retorna ` `` <Left>`

---

### Função `CheckBackspace()`

**UT-017**
- **Descrição:** Retorna `1` quando cursor está na coluna 1 (início de linha)
- **Pré-condições:** Cursor na coluna 1
- **Ação:** Chamar `CheckBackspace()`
- **Esperado:** Retorna `1` (verdadeiro)

**UT-018**
- **Descrição:** Retorna `1` quando caractere à esquerda é espaço
- **Pré-condições:** Linha com `  foo`, cursor após os espaços
- **Ação:** Chamar `CheckBackspace()`
- **Esperado:** Retorna `1`

**UT-019**
- **Descrição:** Retorna `0` quando caractere à esquerda é letra
- **Pré-condições:** Linha com `foo`, cursor após o `o`
- **Ação:** Chamar `CheckBackspace()`
- **Esperado:** Retorna `0` (falso)

**UT-020**
- **Descrição:** Retorna `0` quando caractere à esquerda é `(`
- **Pré-condições:** Linha com `foo(`, cursor após o `(`
- **Ação:** Chamar `CheckBackspace()`
- **Esperado:** Retorna `0`

---

### Função `ShowDocumentation()`

**UT-021**
- **Descrição:** Chama `CocActionAsync('doHover')` quando provider hover está disponível
- **Pré-condições:** Mock `CocAction('hasProvider', 'hover')` retornando `1`
- **Ação:** Chamar `ShowDocumentation()`
- **Esperado:** `CocActionAsync('doHover')` foi invocado

**UT-022**
- **Descrição:** Usa `feedkeys('K', 'in')` quando hover não disponível
- **Pré-condições:** Mock `CocAction('hasProvider', 'hover')` retornando `0`
- **Ação:** Chamar `ShowDocumentation()`
- **Esperado:** `feedkeys` chamado com `'K'`

---

### Função `s:GitMessenger()`

**UT-023**
- **Descrição:** Retorna cedo se buffer não tem arquivo (`expand('%')` vazio)
- **Pré-condições:** Buffer sem nome (`:new` sem salvar)
- **Ação:** Chamar `s:GitMessenger()`
- **Esperado:** Retorna sem executar `system()`

**UT-024**
- **Descrição:** Retorna cedo se arquivo não é legível
- **Pré-condições:** Buffer com nome de arquivo inexistente
- **Ação:** Chamar `s:GitMessenger()`
- **Esperado:** Retorna sem executar git blame

**UT-025**
- **Descrição:** Exibe mensagem de erro quando não é repositório git
- **Pré-condições:** Arquivo em diretório fora de qualquer repo git; mock `system()` com `v:shell_error = 1`
- **Ação:** Chamar `s:GitMessenger()`
- **Esperado:** Mensagem "Não é um repositório git" exibida

**UT-026**
- **Descrição:** Exibe "não commitada" para hash de zeros
- **Pré-condições:** Mock git blame retornando hash `000000...`
- **Ação:** Chamar `s:GitMessenger()`
- **Esperado:** Mensagem "Linha ainda não commitada"

**UT-027**
- **Descrição:** Extrai hash do blame output corretamente
- **Pré-condições:** Mock git blame com output contendo hash `a1b2c3d4...`
- **Ação:** `matchstr(blame_output, '^[0-9a-f]\+')`
- **Esperado:** Hash `a1b2c3d4` extraído corretamente

---

### Variáveis globais e opções

**UT-028**
- **Descrição:** `mapleader` é vírgula
- **Ação:** Verificar `mapleader`
- **Esperado:** `mapleader == ','`

**UT-029**
- **Descrição:** `shiftwidth` é 2
- **Ação:** Verificar `&shiftwidth`
- **Esperado:** `2`

**UT-030**
- **Descrição:** `tabstop` é 2
- **Ação:** Verificar `&tabstop`
- **Esperado:** `2`

**UT-031**
- **Descrição:** `expandtab` está ativo
- **Ação:** Verificar `&expandtab`
- **Esperado:** `1`

**UT-032**
- **Descrição:** `scrolloff` é 8
- **Ação:** Verificar `&scrolloff`
- **Esperado:** `8`

**UT-033**
- **Descrição:** `foldmethod` é `manual`
- **Ação:** Verificar `&foldmethod`
- **Esperado:** `'manual'`

**UT-034**
- **Descrição:** `foldlevel` é 99
- **Ação:** Verificar `&foldlevel`
- **Esperado:** `99`

**UT-035**
- **Descrição:** `updatetime` é 300
- **Ação:** Verificar `&updatetime`
- **Esperado:** `300`

**UT-036**
- **Descrição:** `signcolumn` é `yes`
- **Ação:** Verificar `&signcolumn`
- **Esperado:** `'yes'`

**UT-037**
- **Descrição:** `clipboard` inclui `unnamed`
- **Ação:** Verificar `&clipboard`
- **Esperado:** Contém `'unnamed'`

**UT-038**
- **Descrição:** `mix_format_on_save` é 1
- **Ação:** Verificar `g:mix_format_on_save`
- **Esperado:** `1`

**UT-039**
- **Descrição:** `endwise_no_mappings` é 1
- **Ação:** Verificar `g:endwise_no_mappings`
- **Esperado:** `1`

**UT-040**
- **Descrição:** `AutoPairsShortcutToggle` é `<C-p>`
- **Ação:** Verificar `g:AutoPairsShortcutToggle`
- **Esperado:** `'<C-p>'`

---

### vim-surround: variáveis de pares customizados

**UT-041**
- **Descrição:** `g:surround_100` define `do/end` com newlines
- **Ação:** Verificar `g:surround_100`
- **Esperado:** `"do\n\r\nend"`

**UT-042**
- **Descrição:** `g:surround_101` define `fn -> end` inline
- **Ação:** Verificar `g:surround_101`
- **Esperado:** `"fn -> \r end"`

**UT-043**
- **Descrição:** `g:surround_69` define `fn -> end` multilinha
- **Ação:** Verificar `g:surround_69`
- **Esperado:** `"fn ->\n\r\nend"`

**UT-044**
- **Descrição:** `g:surround_110` define `defmodule/do/end`
- **Ação:** Verificar `g:surround_110`
- **Esperado:** `"defmodule \r do\nend"`

**UT-045**
- **Descrição:** `g:surround_103` define `begin/end` (Ruby)
- **Ação:** Verificar `g:surround_103`
- **Esperado:** `"begin\n\r\nend"`

**UT-046**
- **Descrição:** `g:surround_61` define `<%= %>`
- **Ação:** Verificar `g:surround_61`
- **Esperado:** `"<%= \r %>"`

**UT-047**
- **Descrição:** `g:surround_37` define `<% %>`
- **Ação:** Verificar `g:surround_37`
- **Esperado:** `"<% \r %>"`

---

### vim-projectionist: heurísticas

**UT-048**
- **Descrição:** Heurística para `mix.exs` — lib ↔ test
- **Ação:** Verificar `g:projectionist_heuristics['mix.exs']['lib/*.ex']`
- **Esperado:** `{'alternate': 'test/{}_test.exs', 'type': 'source'}`

**UT-049**
- **Descrição:** Heurística para `mix.exs` — controller ↔ controller test
- **Ação:** Verificar chave `lib/*_web/controllers/*_controller.ex` em `g:projectionist_heuristics['mix.exs']`
- **Esperado:** Chave existe com alternate correto

**UT-050**
- **Descrição:** Heurística para `Gemfile` — model ↔ spec
- **Ação:** Verificar `g:projectionist_heuristics['Gemfile']['app/models/*.rb']`
- **Esperado:** `{'alternate': 'spec/models/{}_spec.rb', 'type': 'model'}`

---

### CoC: lista de extensões

**UT-051**
- **Descrição:** `coc_global_extensions` contém todas as extensões obrigatórias
- **Ação:** Verificar que `g:coc_global_extensions` contém cada uma das 21 extensões esperadas
- **Esperado:** Lista contém: `coc-elixir`, `coc-solargraph`, `coc-tsserver`, `coc-pyright`, `coc-css`, `coc-tailwindcss`, `coc-eslint`, `coc-prettier`, `coc-emmet`, `coc-snippets`, `coc-sql`, `coc-html`, `coc-json`, `coc-yaml`, `coc-xml`, `coc-sh`, `coc-git`, `coc-yank`, `coc-docker`, `coc-browser`, `coc-markdownlint`

**UT-052**
- **Descrição:** `coc_global_extensions` não contém extensões descontinuadas
- **Ação:** Verificar ausência de `coc-rome`, `coc-java`, `coc-texlab`, `coc-powershell`
- **Esperado:** Nenhuma das extensões banidas está presente

---

### Função `s:ApplySmartOpenPairs()` — setup de buffer

**UT-053**
- **Descrição:** Após chamar `s:ApplySmartOpenPairs()`, exatamente 6 `inoremap <buffer>` customizados estão definidos
- **Ferramenta:** vader.vim
- **Pré-condições:** Buffer limpo
- **Ação:** Chamar `s:ApplySmartOpenPairs()` e verificar `maparg('(', 'i', 0, 1)`, `[`, `{`, `"`, `'`, `` ` ``
- **Esperado:** Todos os 6 têm `buffer: 1` no dict de maparg

**UT-054**
- **Descrição:** `s:SmartQuote("'")` não fecha quando próximo char é qualquer letra (`\w`)
- **Ferramenta:** vader.vim
- **Pré-condições:** Buffer com `it`, cursor antes do `i`
- **Ação:** Chamar `s:SmartQuote("'")`
- **Esperado:** Retorna `'` (sem fechar)

---

### Popup / janela flutuante — `s:GitMessenger()`

**UT-055**
- **Descrição:** `popup_list()` está vazio antes de qualquer chamada a `s:GitMessenger()`
- **Ferramenta:** vader.vim
- **Pré-condições:** Vim headless recém iniciado (teardown: garante que testes anteriores fecharam popups)
- **Ação:** Verificar `len(popup_list())`
- **Esperado:** `0`
- **Teardown:** Chamar `call popup_clear()` após o teste

**UT-056**
- **Descrição:** `s:GitMessenger()` cria exatamente 1 popup quando chamado em arquivo rastreado pelo git
- **Ferramenta:** vader.vim (requer arquivo commitado acessível)
- **Pré-condições:** Buffer apontando para arquivo no repositório `~/.vim_runtime` com histórico; `popup_list()` vazio
- **Ação:** Chamar `s:GitMessenger()`
- **Esperado:** `len(popup_list()) == 1`
- **Teardown:** `call popup_clear()`

---

### Variáveis de configuração críticas

**UT-057**
- **Descrição:** `g:rooter_patterns` contém `'mix.exs'` e `'Gemfile'`
- **Ação:** Verificar `index(g:rooter_patterns, 'mix.exs') >= 0` e `index(g:rooter_patterns, 'Gemfile') >= 0`
- **Esperado:** Ambos presentes

**UT-058**
- **Descrição:** `g:VimuxOrientation` ou `g:VimuxHeight` está definido (Vimux configurado)
- **Ação:** Verificar `exists('g:VimuxOrientation') || exists('g:VimuxHeight')`
- **Esperado:** Ao menos um dos dois existe

**UT-059**
- **Descrição:** `g:fzf_layout` tem chave `window` com `width` e `height`
- **Ação:** Verificar `g:fzf_layout['window']['width']` e `g:fzf_layout['window']['height']`
- **Esperado:** Ambos numéricos e > 0 (evita regressão para layout fullscreen)

**UT-060**
- **Descrição:** `$FZF_DEFAULT_COMMAND` contém `rg` quando ripgrep está disponível no PATH
- **Ação:** `if executable('rg')` → verificar `$FZF_DEFAULT_COMMAND =~ 'rg'`
- **Esperado:** Variável contém `rg` (branch condicional do my_configs.vim está correto)

---

## TESTES DE INTEGRAÇÃO (IT)

> **Ferramenta padrão:** Shell (bash) + Vim headless  
> **Localização sugerida:** `~/.vim_runtime/test/integration/`

---

### Plugins instalados

**IT-001**
- **Descrição:** Todos os 64 diretórios de plugins existem e não estão vazios
- **Ferramenta:** Shell
- **Ação:** Listar `my_plugins/` e verificar que cada diretório tem ao menos 1 arquivo
- **Esperado:** 64 diretórios, nenhum vazio

**IT-002**
- **Descrição:** Plugin `vim-rails` está instalado
- **Ferramenta:** Shell
- **Ação:** Verificar existência de `my_plugins/vim-rails/plugin/rails.vim`
- **Esperado:** Arquivo existe

**IT-003**
- **Descrição:** Plugin `vim-projectionist` está instalado
- **Ferramenta:** Shell
- **Ação:** Verificar existência de `my_plugins/vim-projectionist/plugin/projectionist.vim`
- **Esperado:** Arquivo existe

**IT-004**
- **Descrição:** Plugin `fzf` está instalado com binário
- **Ferramenta:** Shell
- **Ação:** Verificar `my_plugins/fzf/plugin/fzf.vim` e `which fzf`
- **Esperado:** Arquivo existe e binário está no PATH

**IT-005**
- **Descrição:** Plugin `fzf.vim` está instalado
- **Ferramenta:** Shell
- **Ação:** Verificar `my_plugins/fzf.vim/plugin/fzf.vim`
- **Esperado:** Arquivo existe

**IT-006**
- **Descrição:** Plugin `vim-dadbod` está instalado
- **Ferramenta:** Shell
- **Ação:** Verificar `my_plugins/vim-dadbod/plugin/db.vim`
- **Esperado:** Arquivo existe

**IT-007**
- **Descrição:** Plugin `vim-dadbod-ui` está instalado
- **Ferramenta:** Shell
- **Ação:** Verificar `my_plugins/vim-dadbod-ui/plugin/dbui.vim`
- **Esperado:** Arquivo existe

**IT-008**
- **Descrição:** Plugin `undotree` está instalado
- **Ferramenta:** Shell
- **Ação:** Verificar `my_plugins/undotree/plugin/undotree.vim`
- **Esperado:** Arquivo existe

**IT-009**
- **Descrição:** Plugin `vim-obsession` está instalado
- **Ferramenta:** Shell
- **Ação:** Verificar `my_plugins/vim-obsession/plugin/obsession.vim`
- **Esperado:** Arquivo existe

**IT-010**
- **Descrição:** Plugin `gv.vim` está instalado
- **Ferramenta:** Shell
- **Ação:** Verificar `my_plugins/gv.vim/plugin/gv.vim`
- **Esperado:** Arquivo existe

**IT-011**
- **Descrição:** Plugin `vim-unimpaired` está instalado
- **Ferramenta:** Shell
- **Ação:** Verificar `my_plugins/vim-unimpaired/plugin/unimpaired.vim`
- **Esperado:** Arquivo existe

**IT-012**
- **Descrição:** Plugin `vim-snippets` está instalado e não vazio
- **Ferramenta:** Shell
- **Ação:** Verificar `my_plugins/vim-snippets/snippets/` tem arquivos `.snippets`
- **Esperado:** Diretório com mais de 10 arquivos

**IT-013**
- **Descrição:** Plugin `vim-rooter` está instalado
- **Ferramenta:** Shell
- **Ação:** Verificar `my_plugins/vim-rooter/plugin/rooter.vim`
- **Esperado:** Arquivo existe

**IT-014**
- **Descrição:** Plugin `coc.nvim` tem build compilado
- **Ferramenta:** Shell
- **Ação:** Verificar existência de `my_plugins/coc.nvim/build/index.js`
- **Esperado:** Arquivo existe e não está vazio

---

### Dependências externas

**IT-015**
- **Descrição:** Node.js está disponível (necessário para CoC)
- **Ferramenta:** Shell
- **Ação:** `node --version`
- **Esperado:** Versão >= 14.14.0

**IT-016**
- **Descrição:** ripgrep está disponível (necessário para fzf e Ack)
- **Ferramenta:** Shell
- **Ação:** `which rg` (binário real, não wrapper)
- **Esperado:** Binário encontrado

**IT-017**
- **Descrição:** git está disponível
- **Ferramenta:** Shell
- **Ação:** `git --version`
- **Esperado:** Versão >= 2.0

**IT-018**
- **Descrição:** ElixirLS está instalado no caminho configurado
- **Ferramenta:** Shell
- **Ação:** Verificar `~/.elixir-ls/release/language_server.sh` existe e é executável
- **Esperado:** Arquivo existe com permissão de execução

**IT-019**
- **Descrição:** Ruby está disponível (necessário para `coc-solargraph`)
- **Ferramenta:** Shell
- **Ação:** `ruby --version`
- **Esperado:** Versão >= 2.6

**IT-020**
- **Descrição:** Python3 está disponível (necessário para `coc-pyright`)
- **Ferramenta:** Shell
- **Ação:** `python3 --version`
- **Esperado:** Versão >= 3.8

---

### coc-settings.json

**IT-021**
- **Descrição:** `~/.vim/coc-settings.json` é JSON válido
- **Ferramenta:** Node.js / Shell (`jq`)
- **Ação:** `jq empty ~/.vim/coc-settings.json`
- **Esperado:** Exit code 0, sem erros de parse

**IT-022**
- **Descrição:** `eslint.autoFixOnSave` é boolean `true`
- **Ferramenta:** Node.js / Jest
- **Ação:** Parsear JSON e verificar tipo e valor
- **Esperado:** `typeof === 'boolean'` e `=== true`

**IT-023**
- **Descrição:** `elixir.pathToElixirLS` aponta para caminho existente
- **Ferramenta:** Shell + Node.js
- **Ação:** Expandir `~` e verificar existência do arquivo
- **Esperado:** Arquivo existe

**IT-024**
- **Descrição:** `tailwindCSS.includeLanguages` cobre `heex` e `eruby`
- **Ferramenta:** Jest
- **Ação:** Verificar chaves `heex` e `eruby` no objeto
- **Esperado:** Ambas mapeadas para `"html"`

**IT-025**
- **Descrição:** `emmet.includeLanguages` cobre `javascriptreact` e `typescriptreact`
- **Ferramenta:** Jest
- **Ação:** Verificar chaves no objeto
- **Esperado:** Ambas mapeadas para `"html"`

**IT-026**
- **Descrição:** Nenhuma chave obsoleta ou depreciada presente no JSON
- **Ferramenta:** Jest
- **Ação:** Verificar ausência de `python.pythonPath` (depreciado em favor de `python.defaultInterpreterPath`)
- **Esperado:** Chave ausente *(ou anotado como warning se presente)*

---

### Vim startup — sem erros

**IT-027**
- **Descrição:** Vim inicia sem erros com o vimrc completo
- **Ferramenta:** Vim headless + Shell
- **Ação:** `vim -N -u ~/.vimrc --headless -c 'qa!' 2>&1`
- **Esperado:** Nenhuma linha de `Error` ou `E\d\+:` no output

**IT-028**
- **Descrição:** Pathogen carrega plugins sem erros
- **Ferramenta:** Vim headless
- **Ação:** Verificar que `pathogen#infect()` completa sem `E492` ou similares
- **Esperado:** Nenhum erro de carregamento

**IT-029**
- **Descrição:** `my_configs.vim` é sourced sem erros
- **Ferramenta:** Vim headless
- **Ação:** `vim -u ~/.vimrc --headless -c 'messages' -c 'qa!'`
- **Esperado:** Nenhum erro de VimScript

---

### Mapeamentos de teclas — definidos

**IT-030**
- **Descrição:** `<C-f>` está mapeado para `:Files<CR>` em modo normal
- **Ferramenta:** Vim headless (`maparg`)
- **Ação:** Verificar `maparg('<C-f>', 'n')`
- **Esperado:** Contém `:Files`

**IT-031**
- **Descrição:** `<C-b>` está mapeado para `:Buffers<CR>` em modo normal
- **Ação:** Verificar `maparg('<C-b>', 'n')`
- **Esperado:** Contém `:Buffers`

**IT-032**
- **Descrição:** `<C-t>` está mapeado para `<C-o>` (jump back) em modo normal
- **Ação:** Verificar `maparg('<C-t>', 'n')`
- **Esperado:** Contém `<C-o>`

**IT-033**
- **Descrição:** `<C-]>` está mapeado para `coc-definition`
- **Ação:** Verificar `maparg('<C-]>', 'n')`
- **Esperado:** Contém `coc-definition`

**IT-034**
- **Descrição:** `K` está mapeado para `ShowDocumentation()`
- **Ação:** Verificar `maparg('K', 'n')`
- **Esperado:** Contém `ShowDocumentation`

**IT-035**
- **Descrição:** `gd` está mapeado para `coc-definition`
- **Ação:** Verificar `maparg('gd', 'n')`
- **Esperado:** Contém `coc-definition`

**IT-036**
- **Descrição:** `gy` está mapeado para `coc-type-definition`
- **Ação:** Verificar `maparg('gy', 'n')`
- **Esperado:** Contém `coc-type-definition`

**IT-037**
- **Descrição:** `gi` está mapeado para `coc-implementation`
- **Ação:** Verificar `maparg('gi', 'n')`
- **Esperado:** Contém `coc-implementation`

**IT-038**
- **Descrição:** `,rn` está mapeado para `coc-rename`
- **Ação:** Verificar `maparg(',rn', 'n')`
- **Esperado:** Contém `coc-rename`

**IT-039**
- **Descrição:** `,a` está mapeado para `coc-codeaction-cursor`
- **Ação:** Verificar `maparg(',a', 'n')`
- **Esperado:** Contém `coc-codeaction-cursor`

**IT-040**
- **Descrição:** `[g` está mapeado para `coc-diagnostic-prev`
- **Ação:** Verificar `maparg('[g', 'n')`
- **Esperado:** Contém `coc-diagnostic-prev`

**IT-041**
- **Descrição:** `]g` está mapeado para `coc-diagnostic-next`
- **Ação:** Verificar `maparg(']g', 'n')`
- **Esperado:** Contém `coc-diagnostic-next`

**IT-042**
- **Descrição:** `,gr` está mapeado para `coc-references`
- **Ação:** Verificar `maparg(',gr', 'n')`
- **Esperado:** Contém `coc-references`

**IT-043**
- **Descrição:** `,tn` está mapeado para `:TestNearest`
- **Ação:** Verificar `maparg(',tn', 'n')`
- **Esperado:** Contém `TestNearest`

**IT-044**
- **Descrição:** `,tf` está mapeado para `:TestFile`
- **Ação:** Verificar `maparg(',tf', 'n')`
- **Esperado:** Contém `TestFile`

**IT-045**
- **Descrição:** `,ts` está mapeado para `:TestSuite`
- **Ação:** Verificar `maparg(',ts', 'n')`
- **Esperado:** Contém `TestSuite`

**IT-046**
- **Descrição:** `,tl` está mapeado para `:TestLast`
- **Ação:** Verificar `maparg(',tl', 'n')`
- **Esperado:** Contém `TestLast`

**IT-047**
- **Descrição:** `,db` está mapeado para `:DBUIToggle`
- **Ação:** Verificar `maparg(',db', 'n')`
- **Esperado:** Contém `DBUIToggle`

**IT-048**
- **Descrição:** `,u` está mapeado para `:UndotreeToggle`
- **Ação:** Verificar `maparg(',u', 'n')`
- **Esperado:** Contém `UndotreeToggle`

**IT-049**
- **Descrição:** `,os` está mapeado para `:Obsession`
- **Ação:** Verificar `maparg(',os', 'n')`
- **Esperado:** Contém `Obsession`

**IT-050**
- **Descrição:** `,gv` está mapeado para `:GV`
- **Ação:** Verificar `maparg(',gv', 'n')`
- **Esperado:** Contém `GV`

**IT-051**
- **Descrição:** `,gm` está mapeado para `GitMessenger`
- **Ação:** Verificar `maparg(',gm', 'n')`
- **Esperado:** Contém `GitMessenger`

**IT-052**
- **Descrição:** `,cs` está mapeado para copiar nome do arquivo
- **Ação:** Verificar `maparg(',cs', 'n')`
- **Esperado:** Contém `expand("%:t")`

**IT-053**
- **Descrição:** `,cl` está mapeado para copiar caminho completo
- **Ação:** Verificar `maparg(',cl', 'n')`
- **Esperado:** Contém `expand("%:p")`

**IT-054**
- **Descrição:** `gr` está mapeado para `:tabprev`
- **Ação:** Verificar `maparg('gr', 'n')`
- **Esperado:** Contém `tabprev`

**IT-055**
- **Descrição:** `,fr` está mapeado para `:MRU`
- **Ação:** Verificar `maparg(',fr', 'n')`
- **Esperado:** Contém `MRU`

---

### Ausência de conflitos críticos

**IT-056**
- **Descrição:** `,tn` NÃO está mapeado para `:tabnew` em modo normal (conflito histórico)
- **Ferramenta:** Vim headless
- **Ação:** Verificar que `maparg(',tn', 'n')` NÃO contém `tabnew`
- **Esperado:** Não contém `tabnew`

**IT-057**
- **Descrição:** `<C-t>` NÃO está mapeado para `:tabe` (conflito histórico)
- **Ação:** Verificar que `maparg('<C-t>', 'n')` NÃO contém `tabe`
- **Esperado:** Não contém `tabe`

**IT-058**
- **Descrição:** `,f` está mapeado para CoC format, NÃO para MRU
- **Ação:** Verificar `maparg(',f', 'n')` contém `coc-format` e não `MRU`
- **Esperado:** Contém `coc-format`

---

### Detecção de filetype

**IT-059**
- **Descrição:** Arquivo `.ex` detectado como `elixir`
- **Ferramenta:** Vim headless
- **Ação:** Abrir buffer `test.ex` e verificar `&filetype`
- **Esperado:** `'elixir'`

**IT-060**
- **Descrição:** Arquivo `.exs` detectado como `elixir`
- **Ação:** Abrir `test.exs`, verificar `&filetype`
- **Esperado:** `'elixir'`

**IT-061**
- **Descrição:** Arquivo `.heex` detectado como `heex`
- **Ação:** Abrir `test.heex`, verificar `&filetype`
- **Esperado:** `'heex'`

**IT-062**
- **Descrição:** Arquivo `.leex` detectado como `eelixir`
- **Ação:** Abrir `test.leex`, verificar `&filetype`
- **Esperado:** `'eelixir'`

**IT-063**
- **Descrição:** Arquivo `.jsx` detectado como `javascriptreact`
- **Ação:** Abrir `test.jsx`, verificar `&filetype`
- **Esperado:** `'javascriptreact'`

**IT-064**
- **Descrição:** Arquivo `.tsx` detectado como `typescriptreact`
- **Ação:** Abrir `test.tsx`, verificar `&filetype`
- **Esperado:** `'typescriptreact'`

**IT-065**
- **Descrição:** Arquivo `.rb` detectado como `ruby`
- **Ação:** Abrir `test.rb`, verificar `&filetype`
- **Esperado:** `'ruby'`

**IT-066**
- **Descrição:** `Gemfile` detectado como `ruby`
- **Ação:** Abrir buffer nomeado `Gemfile`, verificar `&filetype`
- **Esperado:** `'ruby'`

**IT-067**
- **Descrição:** `Rakefile` detectado como `ruby`
- **Ação:** Abrir buffer nomeado `Rakefile`, verificar `&filetype`
- **Esperado:** `'ruby'`

**IT-068**
- **Descrição:** Arquivo `.erb` detectado como `eruby`
- **Ação:** Abrir `test.erb`, verificar `&filetype`
- **Esperado:** `'eruby'`

**IT-069**
- **Descrição:** Arquivo `.jinja` detectado como `htmljinja`
- **Ação:** Abrir `test.jinja`, verificar `&filetype`
- **Esperado:** `'htmljinja'`

**IT-070**
- **Descrição:** Arquivo `.twig` detectado como `html`
- **Ação:** Abrir `test.twig`, verificar `&filetype`
- **Esperado:** `'html'`

**IT-071**
- **Descrição:** Arquivo `.py` detectado como `python`
- **Ação:** Abrir `test.py`, verificar `&filetype`
- **Esperado:** `'python'`

---

### Autocommands registrados

**IT-072**
- **Descrição:** Autocommand de format Elixir está registrado para `BufWritePre`
- **Ferramenta:** Vim headless
- **Ação:** `:autocmd BufWritePre *.ex` e verificar output
- **Esperado:** Output contém `CocAction('format')`

**IT-073**
- **Descrição:** Autocommand de trailing whitespace está registrado para `.rb`
- **Ação:** `:autocmd BufWritePre *.rb`
- **Esperado:** Output contém `CleanExtraSpaces`

**IT-074**
- **Descrição:** Autocommand de trailing whitespace está registrado para `.ts`
- **Ação:** `:autocmd BufWritePre *.ts`
- **Esperado:** Output contém `CleanExtraSpaces`

**IT-075**
- **Descrição:** Autocommand de auto-save está registrado para `FocusLost`
- **Ação:** `:autocmd FocusLost *`
- **Esperado:** Output contém `wa`

**IT-076**
- **Descrição:** Autocommand de smart pairs está registrado para `InsertEnter`
- **Ação:** `:autocmd InsertEnter *` no grupo `SmartOpenPairs`
- **Esperado:** Output contém `ApplySmartOpenPairs`

**IT-077**
- **Descrição:** Autocommand de restore de sessão está registrado para `VimEnter`
- **Ação:** `:autocmd VimEnter *` no grupo `obsession_restore`
- **Esperado:** Output contém `Session.vim`

**IT-078**
- **Descrição:** Autocommand de highlight CoC está registrado para `CursorHold`
- **Ação:** `:autocmd CursorHold *`
- **Esperado:** Output contém `CocActionAsync('highlight')`

---

### Indentação por filetype

**IT-079**
- **Descrição:** Arquivo `.ex` tem `shiftwidth=2` e `expandtab`
- **Ferramenta:** Vim headless
- **Ação:** Abrir `test.ex`, verificar `&shiftwidth` e `&expandtab`
- **Esperado:** `2` e `1`

**IT-080**
- **Descrição:** Arquivo `.rb` tem `shiftwidth=2` e `expandtab`
- **Ação:** Abrir `test.rb`, verificar opções
- **Esperado:** `2` e `1`

**IT-081**
- **Descrição:** Arquivo `.heex` tem `shiftwidth=2` e `expandtab`
- **Ação:** Abrir `test.heex`, verificar opções
- **Esperado:** `2` e `1`

---

### Isolamento e integridade do ambiente de teste

**IT-082**
- **Descrição:** Startup produz zero linhas de erro (`E\d+:`) ao carregar `~/.vimrc` com shim XDG
- **Ferramenta:** Shell + Vim headless
- **Ação:** `source test/shim.sh && vim -es -N -u ~/.vimrc -c "qa!" 2>&1 | grep -c "^E[0-9]"`
- **Esperado:** Saída `0`

**IT-083**
- **Descrição:** Augroup `SmartOpenPairs` existe e registra autocmd para `InsertEnter`
- **Ferramenta:** Vim headless
- **Ação:** `vim -u ~/.vimrc --headless -c "autocmd SmartOpenPairs" -c "qa!" 2>&1`
- **Esperado:** Output contém `InsertEnter` e `ApplySmartOpenPairs`

**IT-084**
- **Descrição:** Nenhum mapeamento normal de 1 tecla conflita com outro (verificação exaustiva)
- **Ferramenta:** Vim headless (script VimScript)
- **Ação:** Para cada tecla com mapeamento, verificar via `maparg(k, 'n', 0, 1)` se `script` aponta para um único source. Emitir erro se 2+ definições conflitantes forem detectadas.
- **Esperado:** Zero conflitos reportados

**IT-085**
- **Descrição:** `coc-settings.json` — `elixirLS.dialyzerEnabled` é boolean, não string
- **Ferramenta:** Jest / Node.js
- **Ação:** Parsear JSON, acessar chave e verificar `typeof === 'boolean'`
- **Esperado:** `true` (boolean)

**IT-086**
- **Descrição:** Todos os plugins com dependências externas têm o binário correspondente no `$PATH`
- **Ferramenta:** Shell
- **Ação:** Para cada par (plugin → binário): `command -v <binário>`

| Plugin | Binário |
| :--- | :--- |
| fzf | `fzf` |
| ripgrep (fzf backend) | `rg` |
| vim-fugitive | `git` |
| gv.vim | `git` |
| Ack | `ack` ou `rg` |
| coc.nvim | `node` |
| vim-dadbod | `psql` ou `mysql` (opcional — warning, não falha) |

- **Esperado:** `fzf`, `rg`, `git`, `node` presentes; DB drivers reportam warning se ausentes

**IT-087**
- **Descrição:** Diretório `test/xdg/` é criado pelo shim e limpo pelo teardown
- **Ferramenta:** Shell
- **Ação:** Executar `source test/shim.sh`, verificar que `test/xdg/` existe; após teardown, verificar que foi removido
- **Esperado:** Existe durante os testes, removido ao final

**IT-088**
- **Descrição:** `popup_list()` retorna lista não-vazia após `:call s:GitMessenger()` em arquivo rastreado
- **Ferramenta:** Vim headless
- **Ação:** Abrir arquivo com histórico git, chamar `s:GitMessenger()`, verificar `len(popup_list())`
- **Esperado:** `>= 1`
- **Teardown:** `call popup_clear()`

**IT-089**
- **Descrição:** `maparg('<C-f>', 'n')` resolve para `:Files` — NÃO para CoC float scroll
- **Ferramenta:** Vim headless
- **Ação:** `maparg('<C-f>', 'n')`
- **Esperado:** Contém `Files` e **não** contém `coc#float`

**IT-090**
- **Descrição:** `maparg('<C-b>', 'n')` resolve para `:Buffers` — NÃO para CoC float scroll
- **Ferramenta:** Vim headless
- **Ação:** `maparg('<C-b>', 'n')`
- **Esperado:** Contém `Buffers` e **não** contém `coc#float`

---

## TESTES END-TO-END (E2E)

> **Ferramenta padrão:** Vader.vim (simulação de teclas) ou Manual  
> **Nota:** Cenários marcados como `Manual` requerem ambiente completo (LSP ativo, tmux, etc.)  
> **Localização sugerida:** `~/.vim_runtime/test/e2e/`  
> **Flags de feedkeys:** todos os testes de auto-pairs e surround usam `call feedkeys('...', 'tx')` — flag `t` para simular digitação real (afeta undo/folds), flag `x` para execução síncrona. Testes de comandos (`:Files`, `:TestNearest`) usam `'mx'`.

---

### Smart Auto-Pairs — comportamento interativo

**E2E-001**
- **Descrição:** Digitar `(` antes de palavra não fecha automaticamente
- **Ferramenta:** Vader.vim
- **Pré-condições:** Buffer com texto `foo`, cursor antes de `f` em insert mode
- **Ação:** Digitar `(`
- **Esperado:** Buffer contém `(foo`, cursor após `(`

**E2E-002**
- **Descrição:** Digitar `(` em linha vazia fecha automaticamente
- **Ferramenta:** Vader.vim
- **Pré-condições:** Linha vazia em insert mode
- **Ação:** Digitar `(`
- **Esperado:** Buffer contém `()`, cursor entre os parênteses

**E2E-003**
- **Descrição:** Digitar `[` antes de palavra não fecha
- **Ferramenta:** Vader.vim
- **Pré-condições:** Buffer com `items`, cursor antes do `i`
- **Ação:** Digitar `[`
- **Esperado:** Buffer contém `[items`

**E2E-004**
- **Descrição:** Digitar `{` antes de texto não fecha
- **Ferramenta:** Vader.vim
- **Pré-condições:** Buffer com `key: value`, cursor antes do `k`
- **Ação:** Digitar `{`
- **Esperado:** Buffer contém `{key: value`

**E2E-005**
- **Descrição:** Digitar `"` antes de palavra não fecha
- **Ferramenta:** Vader.vim
- **Pré-condições:** Buffer com `hello`, cursor antes do `h`
- **Ação:** Digitar `"`
- **Esperado:** Buffer contém `"hello`

**E2E-006**
- **Descrição:** Digitar `"` quando já há `"` à direita pula por cima
- **Ferramenta:** Vader.vim
- **Pré-condições:** Buffer com `"hello"`, cursor entre `o` e `"`
- **Ação:** Digitar `"`
- **Esperado:** Cursor move para depois do `"`, buffer não muda

**E2E-007**
- **Descrição:** Backspace dentro de par `()` apaga ambos
- **Ferramenta:** Vader.vim
- **Pré-condições:** Buffer com `()`, cursor entre os parênteses
- **Ação:** Digitar `<BS>`
- **Esperado:** Buffer fica vazio (ambos apagados pelo auto-pairs)

**E2E-008**
- **Descrição:** Smart pairs não interferem com digitação normal de texto
- **Ferramenta:** Vader.vim
- **Pré-condições:** Linha vazia
- **Ação:** Digitar `def foo`
- **Esperado:** Buffer contém exatamente `def foo`

---

### vim-surround — wrapping visual

**E2E-009**
- **Descrição:** `V S d` envolve linha selecionada em `do/end`
- **Ferramenta:** Vader.vim
- **Pré-condições:** Buffer com `some_call()`, cursor na linha
- **Ação:** `V` (seleciona linha), `S d`
- **Esperado:** Buffer contém `do`, `some_call()`, `end` em 3 linhas

**E2E-010**
- **Descrição:** `v S e` envolve seleção em `fn -> end` inline
- **Ferramenta:** Vader.vim
- **Pré-condições:** Buffer com `expression`, cursor no início da palavra
- **Ação:** `v e` (seleciona palavra), `S e`
- **Esperado:** Buffer contém `fn -> expression end`

**E2E-011**
- **Descrição:** `V S E` envolve linhas em `fn -> end` multilinha
- **Ferramenta:** Vader.vim
- **Pré-condições:** Buffer com `body`
- **Ação:** `V S E`
- **Esperado:** `fn ->`, `body`, `end` em linhas separadas

**E2E-012**
- **Descrição:** `v S =` envolve seleção em tag ERB output
- **Ferramenta:** Vader.vim
- **Pré-condições:** Buffer com `user.name`
- **Ação:** `v e S =`
- **Esperado:** `<%= user.name %>`

**E2E-013**
- **Descrição:** `v S %` envolve seleção em tag ERB silenciosa
- **Ferramenta:** Vader.vim
- **Pré-condições:** Buffer com `render partial`
- **Ação:** `v $ S %`
- **Esperado:** `<% render partial %>`

**E2E-014**
- **Descrição:** `ysiw d` envolve palavra em `do/end`
- **Ferramenta:** Vader.vim
- **Pré-condições:** Buffer com `foo`, cursor sobre a palavra
- **Ação:** `ysiw d`
- **Esperado:** `do`, `foo`, `end`

**E2E-015**
- **Descrição:** `cs"'` troca aspas duplas por simples
- **Ferramenta:** Vader.vim
- **Pré-condições:** Buffer com `"hello"`, cursor dentro
- **Ação:** `cs"'`
- **Esperado:** Buffer contém `'hello'`

**E2E-016**
- **Descrição:** `ds"` remove aspas duplas
- **Ferramenta:** Vader.vim
- **Pré-condições:** Buffer com `"hello"`, cursor dentro
- **Ação:** `ds"`
- **Esperado:** Buffer contém `hello`

---

### Alternância de arquivos (`:A`)

**E2E-017**
- **Descrição:** `:A` em arquivo Elixir `lib/foo.ex` abre `test/foo_test.exs`
- **Ferramenta:** Manual (requer projeto com `mix.exs`)
- **Pré-condições:** Projeto Elixir com `lib/foo.ex` e `test/foo_test.exs`
- **Ação:** Abrir `lib/foo.ex`, executar `:A`
- **Esperado:** Buffer muda para `test/foo_test.exs`

**E2E-018**
- **Descrição:** `:A` em `test/foo_test.exs` abre `lib/foo.ex`
- **Ferramenta:** Manual
- **Pré-condições:** Projeto Elixir configurado
- **Ação:** Abrir `test/foo_test.exs`, executar `:A`
- **Esperado:** Buffer muda para `lib/foo.ex`

**E2E-019**
- **Descrição:** `:A` em controller Phoenix alterna para controller test
- **Ferramenta:** Manual
- **Pré-condições:** Projeto Phoenix com `lib/app_web/controllers/user_controller.ex`
- **Ação:** Abrir controller, executar `:A`
- **Esperado:** Abre `test/app_web/controllers/user_controller_test.exs`

**E2E-020**
- **Descrição:** `:A` em `app/models/user.rb` abre `spec/models/user_spec.rb`
- **Ferramenta:** Manual (requer projeto Rails + vim-projectionist)
- **Pré-condições:** Projeto Rails com Gemfile e arquivos correspondentes
- **Ação:** Abrir model, executar `:A`
- **Esperado:** Abre o spec correspondente

**E2E-021**
- **Descrição:** `:Emodel User` abre `app/models/user.rb` em projeto Rails
- **Ferramenta:** Manual (vim-rails)
- **Pré-condições:** Projeto Rails aberto com vim-rooter no diretório correto
- **Ação:** Executar `:Emodel User`
- **Esperado:** Buffer abre `app/models/user.rb`

---

### vim-test — execução de testes

**E2E-022**
- **Descrição:** `,tn` roda teste Elixir mais próximo via Vimux
- **Ferramenta:** Manual (requer tmux + projeto Elixir)
- **Pré-condições:** Vim dentro de sessão tmux, arquivo `_test.exs` aberto, cursor sobre um `test "..."` block
- **Ação:** Pressionar `,tn`
- **Esperado:** Painel tmux executa `mix test path/to/file.exs:linha`

**E2E-023**
- **Descrição:** `,tf` roda todos os testes do arquivo atual
- **Ferramenta:** Manual (requer tmux)
- **Pré-condições:** Vim em tmux, arquivo de teste aberto
- **Ação:** Pressionar `,tf`
- **Esperado:** Painel tmux executa `mix test path/to/file_test.exs`

**E2E-024**
- **Descrição:** `,ts` roda a suíte completa
- **Ferramenta:** Manual (requer tmux + projeto Elixir)
- **Ação:** Pressionar `,ts`
- **Esperado:** Painel tmux executa `mix test`

**E2E-025**
- **Descrição:** `,tl` repete o último teste sem renavegar
- **Ferramenta:** Manual
- **Pré-condições:** Ter rodado um teste anteriormente
- **Ação:** Mover para outro arquivo, pressionar `,tl`
- **Esperado:** Mesmo comando de teste anterior é re-executado

**E2E-026**
- **Descrição:** `,tn` em arquivo Ruby roda `bundle exec rspec` com linha correta
- **Ferramenta:** Manual (requer tmux + projeto Ruby)
- **Pré-condições:** Arquivo `_spec.rb` aberto, cursor sobre um `it "..."` block
- **Ação:** Pressionar `,tn`
- **Esperado:** Painel tmux executa `bundle exec rspec path/to/spec.rb:linha`

---

### fzf — busca

**E2E-027**
- **Descrição:** `Ctrl+f` abre popup fzf de arquivos
- **Ferramenta:** Manual
- **Ação:** Pressionar `Ctrl+f` em modo normal
- **Esperado:** Janela popup fzf abre com lista de arquivos do projeto

**E2E-028**
- **Descrição:** `Ctrl+b` abre popup fzf de buffers
- **Ferramenta:** Manual
- **Ação:** Pressionar `Ctrl+b`
- **Esperado:** Lista de buffers abertos no popup

**E2E-029**
- **Descrição:** `,gf` lista apenas arquivos rastreados pelo git
- **Ferramenta:** Manual (requer repo git)
- **Ação:** Pressionar `,gf` dentro de repositório git
- **Esperado:** Popup fzf com apenas arquivos do `git ls-files`

**E2E-030**
- **Descrição:** `,rg palavra` encontra ocorrências em todos os arquivos
- **Ferramenta:** Manual
- **Ação:** Digitar `,rg defmodule<Enter>`
- **Esperado:** Lista de arquivos/linhas contendo `defmodule`

---

### Elixir — workflow completo

**E2E-031**
- **Descrição:** Auto-format ao salvar `.ex` executa sem erros
- **Ferramenta:** Manual (requer Elixir instalado)
- **Pré-condições:** Projeto Mix aberto, arquivo `.ex` com código Elixir válido
- **Ação:** Fazer uma edição e salvar (`:w`)
- **Esperado:** Arquivo formatado via `mix format` sem erros

**E2E-032**
- **Descrição:** `,lc` executa `mix credo --strict` no painel tmux
- **Ferramenta:** Manual (requer tmux + Elixir)
- **Ação:** Pressionar `,lc`
- **Esperado:** Painel tmux executa `mix credo --strict`

**E2E-033**
- **Descrição:** `,ie` abre IEx com `iex -S mix`
- **Ferramenta:** Manual (requer tmux + projeto Mix)
- **Ação:** Pressionar `,ie`
- **Esperado:** Painel tmux abre REPL IEx com projeto carregado

**E2E-034**
- **Descrição:** `,mf` formata manualmente arquivo Elixir
- **Ferramenta:** Manual
- **Pré-condições:** Arquivo `.ex` com formatação incorreta
- **Ação:** Pressionar `,mf`
- **Esperado:** Arquivo re-formatado

**E2E-035**
- **Descrição:** `,md` mostra diff do mix format sem aplicar
- **Ferramenta:** Manual
- **Pré-condições:** Arquivo `.ex` com formatação incorreta
- **Ação:** Pressionar `,md`
- **Esperado:** Diff exibido sem modificar arquivo

---

### Git — workflow

**E2E-036**
- **Descrição:** `,gv` abre git log navegável do projeto
- **Ferramenta:** Manual (requer repo git)
- **Ação:** Pressionar `,gv`
- **Esperado:** Janela com log de commits abre, navegável com `j/k`

**E2E-037**
- **Descrição:** `,gV` abre git log apenas do arquivo atual
- **Ferramenta:** Manual (requer repo git + arquivo commitado)
- **Ação:** Abrir arquivo commitado, pressionar `,gV`
- **Esperado:** Log apenas com commits que tocaram o arquivo

**E2E-038**
- **Descrição:** `,gm` mostra popup com informações do commit da linha atual
- **Ferramenta:** Manual (requer repo git + linha commitada)
- **Pré-condições:** Cursor sobre linha com histórico git
- **Ação:** Pressionar `,gm`
- **Esperado:** Popup com hash, autor, data e mensagem do commit

**E2E-039**
- **Descrição:** `,d` liga/desliga diff no gutter
- **Ferramenta:** Manual (requer repo git com modificações)
- **Ação:** Pressionar `,d` duas vezes
- **Esperado:** Gutter mostra sinais de diff ao ligar, remove ao desligar

---

### Banco de dados — workflow

**E2E-040**
- **Descrição:** `,db` abre o DB UI explorer
- **Ferramenta:** Manual
- **Ação:** Pressionar `,db`
- **Esperado:** Painel lateral com explorador de conexões abre

**E2E-041**
- **Descrição:** `:DB postgresql://... SELECT 1` executa query e mostra resultado
- **Ferramenta:** Manual (requer PostgreSQL rodando)
- **Pré-condições:** PostgreSQL acessível com credenciais válidas
- **Ação:** `:DB postgresql://user:pass@localhost/db SELECT 1`
- **Esperado:** Resultado `1` exibido em split

**E2E-042**
- **Descrição:** `:DB mysql://... SELECT 1` executa query MySQL
- **Ferramenta:** Manual (requer MySQL rodando)
- **Pré-condições:** MySQL acessível
- **Ação:** `:DB mysql://user:pass@localhost/db SELECT 1`
- **Esperado:** Resultado exibido

---

### Sessões — workflow

**E2E-043**
- **Descrição:** `,os` inicia tracking criando `Session.vim` no diretório atual
- **Ferramenta:** Manual
- **Pré-condições:** Vim aberto em diretório sem `Session.vim`
- **Ação:** Pressionar `,os`
- **Esperado:** `Session.vim` criado no CWD

**E2E-044**
- **Descrição:** Fechar e reabrir Vim sem argumentos restaura sessão automaticamente
- **Ferramenta:** Manual
- **Pré-condições:** `Session.vim` existente no CWD com múltiplos buffers/splits
- **Ação:** Fechar Vim, reabrir com `vim` (sem argumentos)
- **Esperado:** Buffers, splits e cursor position restaurados

**E2E-045**
- **Descrição:** `,os` segunda vez para tracking (toggle)
- **Ferramenta:** Manual
- **Pré-condições:** Sessão já sendo rastreada
- **Ação:** Pressionar `,os` novamente
- **Esperado:** Tracking para, `Session.vim` não mais atualizado

---

### vim-rooter — mudança automática de diretório

**E2E-046**
- **Descrição:** Abrir arquivo dentro de projeto Elixir muda CWD para raiz do projeto
- **Ferramenta:** Vader.vim / Manual
- **Pré-condições:** Projeto com `mix.exs` em diretório pai; abrir arquivo em subdiretório
- **Ação:** `:edit /path/to/project/lib/deep/file.ex`
- **Esperado:** `getcwd()` retorna diretório com `mix.exs`

**E2E-047**
- **Descrição:** Abrir arquivo em projeto Rails muda CWD para raiz do projeto
- **Pré-condições:** Projeto com `Gemfile`
- **Ação:** `:edit /path/to/rails_app/app/models/user.rb`
- **Esperado:** `getcwd()` retorna diretório com `Gemfile`

**E2E-048**
- **Descrição:** Abrir arquivo em projeto Node.js muda CWD para raiz
- **Pré-condições:** Projeto com `package.json`
- **Ação:** `:edit /path/to/node_project/src/deep/file.js`
- **Esperado:** `getcwd()` retorna diretório com `package.json`

---

### Vimux — integração tmux

**E2E-049**
- **Descrição:** `,vp` abre prompt para digitar comando no tmux
- **Ferramenta:** Manual (requer tmux)
- **Ação:** Pressionar `,vp`, digitar `echo hello`, confirmar
- **Esperado:** Painel tmux executa `echo hello`

**E2E-050**
- **Descrição:** `,vl` repete último comando no tmux
- **Ferramenta:** Manual (requer tmux + comando anterior)
- **Ação:** Pressionar `,vl`
- **Esperado:** Painel tmux re-executa o último comando

**E2E-051**
- **Descrição:** `,vx` envia `Ctrl+C` para o painel tmux
- **Ferramenta:** Manual (requer tmux com processo rodando)
- **Ação:** Iniciar processo longo no tmux, pressionar `,vx`
- **Esperado:** Processo interrompido no painel

---

### CoC — LSP (requer servidores ativos)

**E2E-052**
- **Descrição:** `K` sobre função Elixir mostra documentação em popup
- **Ferramenta:** Manual (requer ElixirLS rodando)
- **Pré-condições:** Arquivo `.ex` aberto, cursor sobre função com documentação
- **Ação:** Pressionar `K`
- **Esperado:** Popup com documentação da função aparece

**E2E-053**
- **Descrição:** `gd` sobre função Elixir navega para definição
- **Ferramenta:** Manual (requer ElixirLS)
- **Ação:** Cursor sobre chamada de função, pressionar `gd`
- **Esperado:** Buffer muda para arquivo com definição da função

**E2E-054**
- **Descrição:** `[g` navega para diagnóstico anterior no arquivo
- **Ferramenta:** Manual (requer LSP com diagnósticos)
- **Pré-condições:** Arquivo com erros de compilação/linting
- **Ação:** Pressionar `[g`
- **Esperado:** Cursor salta para o erro anterior

**E2E-055**
- **Descrição:** `,a` sobre erro mostra code actions disponíveis
- **Ferramenta:** Manual (requer LSP)
- **Pré-condições:** Cursor sobre diagnóstico com code actions
- **Ação:** Pressionar `,a`
- **Esperado:** Menu de ações aparece (ex: "Add missing import", "Fix typo")

**E2E-056**
- **Descrição:** Tab completa sugestão de autocomplete do ElixirLS
- **Ferramenta:** Manual (requer ElixirLS)
- **Pré-condições:** Digitando nome de módulo Elixir incompleto
- **Ação:** Digitar `Enum.m`, aguardar sugestões, pressionar `Tab`
- **Esperado:** Sugestão aceita (ex: `Enum.map`)

**E2E-057**
- **Descrição:** `,rn` renomeia símbolo em todos os arquivos do projeto
- **Ferramenta:** Manual (requer LSP)
- **Pré-condições:** Cursor sobre nome de função usada em múltiplos arquivos
- **Ação:** Pressionar `,rn`, digitar novo nome, confirmar
- **Esperado:** Todos os usos renomeados no projeto

---

### Undo tree — workflow

**E2E-058**
- **Descrição:** `,u` abre painel de histórico visual de undo
- **Ferramenta:** Manual
- **Ação:** Fazer algumas edições, pressionar `,u`
- **Esperado:** Painel lateral com árvore de undo abre e recebe foco

**E2E-059**
- **Descrição:** Histórico de undo persiste após fechar e reabrir arquivo
- **Ferramenta:** Manual
- **Pré-condições:** `undodir` configurado em `~/.vim_runtime/temp_dirs/undodir`
- **Ação:** Editar arquivo, salvar, fechar Vim, reabrir arquivo, verificar undo
- **Esperado:** `u` desfaz edições da sessão anterior

---

## Sumário de viabilidade

| Categoria | Total de casos | Automatizável (vader/shell/Jest) | Parcialmente automático | Manual apenas |
| :--- | :---: | :---: | :---: | :---: |
| Unit — Funções VimScript | 29 | 27 | 2 | 0 |
| Unit — Popup/GitMessenger | 2 | 2 | 0 | 0 |
| Unit — Variáveis/opções | 24 | 24 | 0 | 0 |
| Unit — Config críticas (fzf, rooter, vimux) | 4 | 4 | 0 | 0 |
| Integration — Plugins/arquivos | 14 | 14 | 0 | 0 |
| Integration — Dependências | 6 | 6 | 0 | 0 |
| Integration — coc-settings.json | 7 | 7 | 0 | 0 |
| Integration — Startup | 3 | 3 | 0 | 0 |
| Integration — Mapeamentos | 29 | 29 | 0 | 0 |
| Integration — Filetypes | 13 | 13 | 0 | 0 |
| Integration — Autocommands | 7 | 7 | 0 | 0 |
| Integration — Indentação | 3 | 3 | 0 | 0 |
| Integration — Ambiente/isolamento | 5 | 5 | 0 | 0 |
| Integration — Conflitos de mapeamentos | 4 | 4 | 0 | 0 |
| E2E — Smart auto-pairs | 8 | 6 | 2 | 0 |
| E2E — vim-surround | 8 | 6 | 2 | 0 |
| E2E — Alternância de arquivos | 5 | 0 | 1 | 4 |
| E2E — vim-test | 5 | 0 | 0 | 5 |
| E2E — fzf | 4 | 0 | 0 | 4 |
| E2E — Elixir workflow | 5 | 0 | 0 | 5 |
| E2E — Git | 4 | 0 | 1 | 3 |
| E2E — Banco de dados | 3 | 0 | 0 | 3 |
| E2E — Sessões | 3 | 0 | 1 | 2 |
| E2E — vim-rooter | 3 | 2 | 1 | 0 |
| E2E — Vimux | 3 | 0 | 0 | 3 |
| E2E — CoC LSP | 6 | 0 | 0 | 6 |
| E2E — Undo tree | 2 | 0 | 1 | 1 |
| **TOTAL** | **209** | **162 (78%)** | **11 (5%)** | **36 (17%)** |

### O que mudou em relação à versão anterior

| Dimensão | Antes | Depois |
| :--- | :--- | :--- |
| Total de casos | 191 | 209 (+18) |
| Automáveis | 144 (75%) | 162 (78%) |
| "Não testáveis" reclassificados | — | 3 itens → automáveis |
| Infraestrutura de isolamento | Ausente | XDG shim documentado |
| CI/CD | Ausente | GitHub Actions esqueleto documentado |
| feedkeys flags | Genérico | `'tx'` para auto-pairs/surround especificado |
| Popup/float coverage | Manual | `popup_list()` — automável (UT-055, UT-056, IT-088) |
| Convenção de testes | Implícita | AAA + laser focus + teardown explicitados |
