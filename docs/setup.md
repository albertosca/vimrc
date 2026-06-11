# Setup — Guia de Instalação

Guia completo para instalar e configurar o `~/.vim_runtime` em uma máquina nova.

---

## Pré-requisitos

| Dependência | Obrigatório? | macOS | Linux (apt) | Pra quê |
|---|---|---|---|---|
| Vim 9.1+ | sim | `brew install vim` | `apt install vim` | o editor |
| Node.js | sim | `brew install node` | `apt install nodejs npm` | CoC (LSP) não carrega sem ele |
| git | sim | `brew install git` | `apt install git` | submodules, fugitive, gv |
| ripgrep (`rg`) | sim | `brew install ripgrep` | `apt install ripgrep` | busca fzf/Ack |
| psql / mysql | opcional | `brew install postgresql` / `brew install mysql` | `apt install postgresql-client` / `apt install mysql-client` | vim-dadbod (DB UI) |

---

## Instalação

```bash
# Recomendado (sem erros vermelhos no clone)
git clone https://github.com/albertosca/vim-runtime.git ~/.vim_runtime
bash ~/.vim_runtime/install.sh

# Alternativa com --recursive (submodules estão saudáveis)
git clone --recursive https://github.com/albertosca/vim-runtime.git ~/.vim_runtime
bash ~/.vim_runtime/install.sh
```

O `install.sh` faz tudo de forma automatizada e **idempotente**:

- Inicializa os submodules um a um de forma resiliente (falhas individuais não abortam a instalação)
- Cria o symlink `~/.vimrc → vimrc_example`
- Linka `~/.vim/coc-settings.json` para o arquivo do repo
- Faz backup automático de qualquer arquivo existente que seria sobrescrito

---

## Primeiro run

Ao abrir `vim` pela primeira vez após a instalação, o CoC detecta a lista de extensões em `g:coc_global_extensions` e inicia o download e instalação automática de todas as 25 extensões. Esse processo leva **~1–2 minutos** na primeira vez e exige Node.js instalado e acesso à internet.

**Para acompanhar o progresso:**

- `:CocList extensions` — status de cada extensão (instalando, pronto, erro)
- `:messages` — log detalhado com mensagens do CoC

As extensões instaladas automaticamente são:

```
coc-browser, coc-css, coc-docker, coc-elixir, coc-emmet, coc-eslint,
coc-git, coc-go, coc-html, coc-json, coc-markdown-preview-enhanced,
coc-markdownlint, coc-prettier, coc-pyright, coc-sh, coc-snippets,
coc-sql, coc-stylelint, coc-stylelintplus, coc-tailwindcss, coc-tsserver,
coc-webview, coc-xml, coc-yaml, coc-yank
```

---

## Verificar que está funcionando

Após a instalação e o primeiro run, rode estes checks:

- **`:CocInfo`** — mostra a versão do CoC, o Node detectado e qualquer problema de configuração
- **`:checkhealth`** — diagnóstico geral do Vim e dos plugins carregados

Para confirmar que o LSP está ativo:

1. Abra um arquivo `.ex`, `.ts` ou `.py`
2. Posicione o cursor sobre um símbolo e pressione `K` — deve aparecer o hover doc
3. Pressione `gd` sobre um símbolo — deve navegar para a definição

Se `K` e `gd` respondem, o CoC está funcionando corretamente.

---

## LSP por linguagem

| Linguagem | Extensão CoC | Já auto-instala? | Servidor externo a instalar |
|---|---|---|---|
| Elixir | coc-elixir | sim | ElixirLS — baixar release em https://github.com/elixir-lsp/elixir-ls/releases e colocar em `~/.elixir-ls/release/language_server.sh` |
| JS/TS/React | coc-tsserver | sim | nenhum (tsserver vem na extensão) |
| Python | coc-pyright | sim | nenhum (pyright vem na extensão) |
| Go | coc-go | sim | `gopls` (a extensão instala automaticamente; precisa do toolchain Go) |
| Ruby/Rails | — | **não** | `:CocInstall coc-solargraph` + `gem install solargraph` |
| Rust | — | **não** | `:CocInstall coc-rust-analyzer` + `rustup component add rust-analyzer` |

> **Nota:** Ruby (`coc-solargraph`) e Rust (`coc-rust-analyzer`) **não estão** na lista de extensões auto-instaladas. Para usá-los, rode o `:CocInstall` acima após a instalação.

---

## Troubleshooting

**CoC não inicia / "Coc requires Node"**
Node ausente ou versão menor que 16. Rode `node --version` para verificar. Instale ou atualize via `brew install node` (macOS) ou `apt install nodejs` (Linux) e reabra o Vim.

**Extensão CoC não instala**
Sem internet na primeira abertura, ou processo do Node travado. Verifique o estado com `:CocList extensions`; reinicie o CoC com `:CocCommand workspace.restart`; confira o log em `:messages`.

**fzf sem binário / `:Files` não abre**
O binário do fzf não foi compilado. Rode:
```bash
~/.vim_runtime/plugins/fzf/install --bin
```

**Plugin ausente após clone**
Submodule não foi inicializado. Rode:
```bash
git -C ~/.vim_runtime submodule update --init plugins/NOME
```
Substitua `NOME` pelo nome do diretório do plugin faltante.

**Ícones quadrados ou faltando (vim-devicons)**
Falta uma Nerd Font no terminal. Instale uma (ex: "FiraCode Nerd Font" em https://www.nerdfonts.com) e selecione-a nas configurações do seu emulador de terminal. Depois reabra o Vim.

**Ruby/Rust sem autocomplete**
Esses LSPs não vêm por padrão — ver tabela "LSP por linguagem" acima para o procedimento de instalação manual.

---

## Ver também

- [`keybindings.md`](keybindings.md) — cheatsheet completo de atalhos
- [`updating-plugins.md`](updating-plugins.md) — como atualizar plugins com segurança
