from __future__ import annotations

import os
from pathlib import Path

import pytest

from conftest import assert_ok, extract_first_semver, run_cmd, semver_ge


@pytest.mark.required
@pytest.mark.env_gate
def test_tree_sitter_cli_version_minimum() -> None:
    result = run_cmd(["tree-sitter", "--version"])
    assert_ok(
        result,
        context=(
            "tree-sitter missing. Install with: "
            "cargo install --locked tree-sitter-cli --force"
        ),
    )

    text = result.stdout.strip() or result.stderr.strip()
    version = extract_first_semver(text)
    assert version is not None, f"failed to parse tree-sitter version from: {text}"
    assert semver_ge(version, "0.25.0"), (
        f"tree-sitter-cli>=0.25.0 required by nvim-treesitter, got {version}.\n"
        "fix: cargo install --locked tree-sitter-cli --force"
    )


@pytest.mark.required
@pytest.mark.nvim_runtime
def test_options_prefers_non_mason_tree_sitter(repo_root: Path, nvim_env: dict[str, str]) -> None:
    mason_bin = (Path.home() / ".local" / "share" / "nvim" / "mason" / "bin").as_posix()
    env = dict(nvim_env)
    env["PATH"] = f"{mason_bin}:{env.get('PATH', '')}"

    options = (repo_root / "lua" / "config" / "options.lua").as_posix()
    chunk = f'dofile("{options}"); print(vim.fn.exepath("tree-sitter"))'
    result = run_cmd(
        ["nvim", "-u", "NONE", "-i", "NONE", "--headless", f"+lua {chunk}", "+qa"],
        env=env,
    )
    assert_ok(result, context="prefer non-mason tree-sitter")

    output = ((result.stdout or "") + (result.stderr or "")).strip()
    selected = output.splitlines()[-1] if output else ""
    assert selected, "tree-sitter executable was not selected"
    assert not selected.endswith("/mason/bin/tree-sitter"), (
        "options.lua selected mason/bin/tree-sitter; expected fallback to a working host CLI"
    )
