from __future__ import annotations

from pathlib import Path

import pytest

from conftest import assert_ok, run_cmd


@pytest.mark.required
@pytest.mark.nvim_runtime
@pytest.mark.parametrize(
    "relative_path",
    [
        "init.lua",
        "lua/config/lazy.lua",
        "lua/config/options.lua",
        "lua/config/keymaps.lua",
        "lua/config/autocmds.lua",
        "lua/plugins/noice.lua",
        "lua/plugins/cpp.lua",
        "lua/plugins/java.lua",
        "after/ftplugin/cpp.lua",
    ],
)
def test_lua_files_loadable_headless(repo_root: Path, relative_path: str) -> None:
    file_path = repo_root / relative_path
    chunk = f'assert(loadfile("{file_path.as_posix()}")); print("LUA_OK")'
    result = run_cmd(["nvim", "-u", "NONE", "-i", "NONE", "--headless", f"+lua {chunk}", "+qa"])
    assert_ok(result, context=relative_path)
    output = (result.stdout or "") + (result.stderr or "")
    assert "LUA_OK" in output


@pytest.mark.optional
@pytest.mark.nvim_runtime
def test_headless_can_evaluate_treesitter_exepath(repo_root: Path, nvim_env: dict[str, str]) -> None:
    options_path = (repo_root / "lua" / "config" / "options.lua").as_posix()
    chunk = f'dofile("{options_path}"); print(vim.fn.exepath("tree-sitter"))'
    result = run_cmd(
        ["nvim", "-u", "NONE", "-i", "NONE", "--headless", f"+lua {chunk}", "+qa"],
        env=nvim_env,
    )
    assert_ok(result, context="tree-sitter exepath")
    output = ((result.stdout or "") + (result.stderr or "")).strip()
    assert output, "tree-sitter executable path is empty"
