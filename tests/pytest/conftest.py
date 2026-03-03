from __future__ import annotations

import os
import re
import shlex
import shutil
import subprocess
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[2]


class CommandError(AssertionError):
    pass


def shell_join(args: list[str]) -> str:
    return " ".join(shlex.quote(a) for a in args)


def run_cmd(
    args: list[str],
    *,
    cwd: Path | None = None,
    env: dict[str, str] | None = None,
    timeout: int = 120,
) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        args,
        cwd=str(cwd or REPO_ROOT),
        env=env,
        text=True,
        capture_output=True,
        timeout=timeout,
        check=False,
    )


def assert_ok(result: subprocess.CompletedProcess[str], context: str = "") -> None:
    if result.returncode == 0:
        return
    details = [
        f"command failed ({context})" if context else "command failed",
        f"exit_code={result.returncode}",
        f"stdout:\n{result.stdout}",
        f"stderr:\n{result.stderr}",
    ]
    raise CommandError("\n".join(details))


def extract_first_semver(text: str) -> str | None:
    match = re.search(r"(\d+\.\d+\.\d+)", text)
    return match.group(1) if match else None


def semver_tuple(version: str) -> tuple[int, int, int]:
    a, b, c = version.split(".")
    return int(a), int(b), int(c)


def semver_ge(actual: str, minimum: str) -> bool:
    return semver_tuple(actual) >= semver_tuple(minimum)


def has_bin(name: str) -> bool:
    return shutil.which(name) is not None


@pytest.fixture(scope="session")
def repo_root() -> Path:
    return REPO_ROOT


@pytest.fixture(scope="session")
def gate_mode() -> str:
    return os.environ.get("TEST_GATE_MODE", "tiered").strip().lower()


@pytest.fixture
def nvim_env(tmp_path: Path) -> dict[str, str]:
    cache = tmp_path / "xdg-cache"
    state = tmp_path / "xdg-state"
    data = tmp_path / "xdg-data"
    cache.mkdir(parents=True, exist_ok=True)
    state.mkdir(parents=True, exist_ok=True)
    data.mkdir(parents=True, exist_ok=True)

    env = os.environ.copy()
    env["XDG_CACHE_HOME"] = str(cache)
    env["XDG_STATE_HOME"] = str(state)
    # Keep data default for plugin lookup, unless caller overrides.
    env.setdefault("XDG_DATA_HOME", str(Path.home() / ".local" / "share"))
    return env


@pytest.fixture(scope="session")
def mason_tree_sitter_path() -> Path:
    return Path.home() / ".local" / "share" / "nvim" / "mason" / "bin" / "tree-sitter"
