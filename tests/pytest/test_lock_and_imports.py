from __future__ import annotations

import json
from pathlib import Path

import pytest


@pytest.mark.required
@pytest.mark.lua_contract
def test_lazyvim_import_order(repo_root: Path) -> None:
    lazy_file = repo_root / "lua" / "config" / "lazy.lua"
    text = lazy_file.read_text(encoding="utf-8")

    core = '{ "LazyVim/LazyVim", import = "lazyvim.plugins" }'
    java_extra = '{ import = "lazyvim.plugins.extras.lang.java" }'
    user_plugins = '{ import = "plugins" }'

    i_core = text.find(core)
    i_extra = text.find(java_extra)
    i_user = text.find(user_plugins)

    assert i_core >= 0, f"missing core import: {core}"
    assert i_extra >= 0, f"missing java extra import: {java_extra}"
    assert i_user >= 0, f"missing user plugin import: {user_plugins}"
    assert i_core < i_extra < i_user, (
        "invalid import order: expected core -> extras -> user plugins\n"
        f"indices: core={i_core}, extra={i_extra}, user={i_user}"
    )


@pytest.mark.required
@pytest.mark.lua_contract
def test_lazy_lock_has_required_plugins(repo_root: Path) -> None:
    lock_file = repo_root / "lazy-lock.json"
    data = json.loads(lock_file.read_text(encoding="utf-8"))

    required = [
        "LazyVim",
        "nvim-treesitter",
        "nvim-lspconfig",
        "noice.nvim",
        "nvim-jdtls",
    ]
    missing = [name for name in required if name not in data]
    assert not missing, f"lazy-lock missing plugin keys: {', '.join(missing)}"
