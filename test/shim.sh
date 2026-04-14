#!/usr/bin/env bash
# Isola dados/estado do Vim durante os testes para não tocar a config de produção.
# ~/.vimrc ainda é carregado; apenas XDG_DATA/STATE ficam em diretórios temporários.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export XDG_CONFIG_HOME="$REPO_ROOT/test/xdg/config"
export XDG_DATA_HOME="$REPO_ROOT/test/xdg/data"
export XDG_STATE_HOME="$REPO_ROOT/test/xdg/state"

mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"
