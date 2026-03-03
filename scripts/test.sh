#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v uv >/dev/null 2>&1; then
  echo "uv is not installed. Install: https://docs.astral.sh/uv/getting-started/installation/" >&2
  exit 1
fi

if ! command -v nvim >/dev/null 2>&1; then
  echo "nvim not found in PATH" >&2
  exit 1
fi

XDG_TEST_ROOT="${ROOT_DIR}/.tests/xdg"
mkdir -p "${XDG_TEST_ROOT}/cache" "${XDG_TEST_ROOT}/state"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${XDG_TEST_ROOT}/cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-${XDG_TEST_ROOT}/state}"

uv sync --dev

pytest_exit=0
lua_exit=0

uv run pytest || pytest_exit=$?

nvim --headless \
  -c "lua vim.opt.rtp:prepend(vim.fn.stdpath('data')..'/lazy/plenary.nvim'); require('plenary.test_harness').test_directory('tests/lua/spec', { minimal_init = 'tests/lua/minimal_init.lua' })" \
  -c "qa" || lua_exit=$?

if [[ "$pytest_exit" -ne 0 || "$lua_exit" -ne 0 ]]; then
  echo "test failures: pytest=${pytest_exit}, lua=${lua_exit}" >&2
  exit 1
fi
