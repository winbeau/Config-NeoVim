from __future__ import annotations

from pathlib import Path

import pytest


@pytest.mark.required
@pytest.mark.lua_contract
def test_noice_contract(repo_root: Path) -> None:
    text = (repo_root / "lua" / "plugins" / "noice.lua").read_text(encoding="utf-8")
    assert "opts.cmdline.enabled = true" in text
    assert "opts.presets.command_palette = true" in text
    assert "opts.presets.bottom_search = true" in text
    assert "opts.views.mini.size.max_height = 1" in text


@pytest.mark.required
@pytest.mark.lua_contract
def test_cpp_plugin_contract(repo_root: Path) -> None:
    text = (repo_root / "lua" / "plugins" / "cpp.lua").read_text(encoding="utf-8")
    assert 'opts.PATH = "append"' in text
    assert '"clangd"' in text
    assert '"clang-format"' in text


@pytest.mark.required
@pytest.mark.lua_contract
def test_options_treesitter_selector_contract(repo_root: Path) -> None:
    text = (repo_root / "lua" / "config" / "options.lua").read_text(encoding="utf-8")
    assert "vim.g.autoformat = false" in text
    assert "vim.opt.tabstop = 4" in text
    assert "vim.opt.shiftwidth = 4" in text
    assert "vim.opt.softtabstop = 4" in text
    assert "vim.opt.expandtab = true" in text
    assert "Prefer a working tree-sitter CLI" in text
    assert "local min = { 0, 25, 0 }" in text
    assert 'vim.fn.expand("$HOME/.nvm/versions/node/*/bin/tree-sitter")' in text


@pytest.mark.required
@pytest.mark.lua_contract
def test_java_plugin_contract(repo_root: Path) -> None:
    text = (repo_root / "lua" / "plugins" / "java.lua").read_text(encoding="utf-8")
    assert 'vim.list_extend(opts.ensure_installed, { "jdtls" })' in text
    assert "enabled = function()" in text
    assert "find_java21_bin" in text
    assert "--java-executable" in text
    assert "jdtls requires Java 21" in text
    assert 'map("<leader>ca", vim.lsp.buf.code_action' in text
    assert 'map("<leader>co", function()' in text
