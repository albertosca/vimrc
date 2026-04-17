---
name: test
description: Roda a suite de testes deste Vim config via `bash test/run.sh`. Suporta as fases (shell, unit, integration, e2e, json) e os modos verbose (-v por caso, -vv raw).
---

# /test — runner da suite deste Vim config

Invocação: `/test [args]`. Os `[args]` vão direto pro `bash test/run.sh`.

## Comando base

```
bash test/run.sh [args]
```

Sempre rodar a partir da raiz do repo (`/Users/albertosca/.vim_runtime`).

## Argumentos suportados

- (vazio) → roda tudo (shell + unit + integration + e2e + json)
- `shell` → só binários/plugins/integridade
- `unit` → só variáveis e funções VimScript
- `integration` → mappings, autocmds, filetypes, startup
- `e2e` → feedkeys (auto-pairs, surround, rooter)
- `json` → jest (coc-settings.json schema)
- `-v` → cada caso de teste com ✓/✗
- `-vv` → output bruto (debug)

Combinações: `/test unit -v`, `/test e2e`, etc.

## Regras

- Se a suite passa de ~20s, rode em background (`run_in_background: true`) e avise.
- Reporte **só o essencial**: totals por suite (pass/fail/tempo) + `all green` ou primeira falha.
- Em falha, extraia o arquivo/linha do Vader (padrão `[EXECUTE] (X) <nome do teste>`) e mostre só isso, não o output todo.
- NUNCA modificar código como parte de `/test` — é puramente leitura/execução.
- Se o usuário pedir `/test` fora deste repo, informe que esta skill é específica do Vim config.
