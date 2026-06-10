# Guia de Atualização de Plugins

Como atualizar os submodules e plugins embedded com segurança, verificar regressões e commitar o resultado.

## Quando rodar

- Periodicamente (ex: mensal) para pegar bugfixes e suporte a novas versões de linguagem.
- Antes de qualquer update: confirmar que a suite está verde no estado atual.

---

## Tipos de plugin neste repo

| Tipo | Localização | Como atualizar | Rastreado pelo git? |
|------|------------|----------------|---------------------|
| **Submodule** | `plugins/NOME/` com entrada em `.gitmodules` | `git -C plugins/NOME pull --ff-only` | Sim — SHA do parent muda |
| **Embedded** | `plugins/NOME/` sem entrada em `.gitmodules` | `git -C plugins/NOME pull --ff-only` | Não — só muda o conteúdo interno |

Ver lista completa em `.gitmodules` (submodules) e em `CLAUDE.md` (embedded).

---

## Passo a passo

### 1. Baseline antes de tocar em qualquer coisa

```bash
bash test/run.sh
```

Se tiver falha: **parar aqui** — investigar antes de avançar. Nunca atualizar sobre um baseline vermelho.

Anotar os totais (ex: `314 passed · 1 warn · 0 failed`).

### 2. Garantir que todos os submodules estão inicializados

```bash
git submodule status | grep "^-"
```

Se aparecer algum com `-` (não inicializado):

```bash
git submodule update --init
```

### 3. Checar o que há de novo

```bash
git submodule foreach '
  LOCAL=$(git rev-parse HEAD)
  REMOTE=$(git rev-parse origin/HEAD 2>/dev/null || echo "sem-upstream")
  if [ "$LOCAL" != "$REMOTE" ] && [ "$REMOTE" != "sem-upstream" ]; then
    COUNT=$(git log --oneline $LOCAL..$REMOTE 2>/dev/null | wc -l | tr -d " ")
    echo "UPDATES ($COUNT commits): $name"
  fi
'
```

Para ver o que mudou em um plugin específico:

```bash
git -C plugins/NOME log --oneline HEAD..origin/HEAD | head -20
```

Prestar atenção em títulos com `BREAKING`, `breaking change`, `remove`, `rename`, `deprecat` — esses exigem revisar se `configs.vim` usa alguma variável `g:NOME_*` ou comando que mudou.

### 4. Atualizar por grupos de risco

Atualizar de uma vez pode obscurecer qual plugin causou uma regressão. Melhor ir em grupos:

**Grupo A — baixo risco** (VimScript puro, single-purpose):
`undotree`, `vim-closetag`, `vim-endwise`, `vim-obsession`, `vim-rooter`, `vim-unimpaired`, `gv.vim`, `vimux`, `vim-mdx-js`

**Grupo B — médio risco** (feature-rich, podem ter mudanças de API):
`fzf.vim`, `vim-elixir`, `vim-mix-format`, `vim-test`, `vim-dadbod`, `vim-dadbod-completion`, `vim-dadbod-ui`, `vim-rails`, `vim-projectionist`, `vim-jsx-improve`, `vim-js-pretty-template`, `vim-snippets`

**Grupo C — alto risco** (binário externo, LSP, muitos moving parts):
`fzf` (tem binário Go — ver nota abaixo), `coc.nvim` (LSP), `vim-visual-multi`, `vim-matchup`, `vim-devicons`, `vim-nerdtree-syntax-highlight`

**Grupo D — plugins nossos / pinados** (só atualizar intencionalmente):
`vim-claude-code`, `copilot-chat.vim`, `vim-sleuth`, `vim-tmux-navigator`

Para cada grupo:

```bash
# Substituir pela lista do grupo
for plugin in PLUGIN1 PLUGIN2; do
  echo "=== $plugin ==="
  git -C "plugins/$plugin" pull --ff-only 2>&1 | tail -1
done
```

Rodar os testes após cada grupo:

```bash
bash test/run.sh
```

Se falhar: identificar qual plugin avançou o SHA e reverter só ele:

```bash
git -C plugins/NOME checkout <SHA_ANTERIOR>
bash test/run.sh   # confirma que era ele o culpado
```

### 5. Plugins embedded

```bash
for plugin in auto-pairs goyo.vim gruvbox lightline.vim nerdtree rust.vim \
              set_tabline tabular vim-abolish vim-commentary vim-expand-region \
              vim-fugitive vim-gitgutter vim-indent-object vim-markdown \
              vim-repeat vim-surround; do
  [ -d "plugins/$plugin/.git" ] && git -C "plugins/$plugin" pull --ff-only 2>&1 | tail -1
done
bash test/run.sh
```

O SHA desses não muda no parent repo — só o conteúdo interno dos diretórios.

### 6. Verificação final e commit

```bash
# Ver exatamente o que será commitado
git diff --cached --stat
git diff --cached --submodule | head -80

# Suite completa uma última vez
bash test/run.sh
```

Se os totais baterem com o baseline: commit.

```bash
git add plugins/PLUGIN1 plugins/PLUGIN2 ...   # só os submodules que avançaram SHA
# Atualizar README.md se a contagem de testes mudou:
grep -n "testes automatizados" README.md
git add README.md

git commit -m "chore(plugins): atualizar submodules para HEADs mais recentes

N submodules atualizados (lista). Suite de X testes passou sem regressões."
```

---

## Notas por plugin

### fzf (Grupo C)

Tem binário Go separado. Após `pull`, se a versão mudou:

```bash
~/.vim_runtime/plugins/fzf/install --bin
```

### coc.nvim (Grupo C)

Usa `branch = release` no `.gitmodules` (já configurado). O branch `release` contém os artefatos JS pré-compilados — **não roda `npm ci`** depois de puxar, ao contrário do branch `master`.

Se aparecer erro de compatibilidade de extensões no Vim após update: reverter para o SHA anterior e abrir issue.

### vim-claude-code / copilot-chat.vim (Grupo D)

Têm integrações com `configs.vim`. Só atualizar se há bugfix ou feature desejada — revisar o log antes:

```bash
git -C plugins/vim-claude-code log --oneline HEAD..origin/HEAD
git -C plugins/copilot-chat.vim log --oneline HEAD..origin/HEAD
```

---

## Se um submodule sumir do GitHub (repo deletado)

```bash
# Confirmar 404
curl -s -o /dev/null -w "%{http_code}" https://github.com/USER/REPO

# Se 404, remover completamente
git submodule deinit -f plugins/NOME
git rm -f plugins/NOME
rm -rf .git/modules/plugins/NOME
# Remover a entrada de plugins/NOME em .gitmodules
# Checar se configs.vim referencia variáveis g: desse plugin
bash test/run.sh   # verificar que nenhum teste quebrou
```

O `install.sh` já é resiliente a submodules inacessíveis — avisa e continua.

---

## Se `--ff-only` falhar

O upstream fez rebase/force-push. Avaliar o log e decidir se é intencional:

```bash
git -C plugins/NOME log --oneline --graph HEAD..origin/HEAD
# Se for cleanup intencional:
git -C plugins/NOME reset --hard origin/HEAD
```
