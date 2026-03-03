from __future__ import annotations

import platform
import sys

import pytest

from conftest import extract_first_semver, has_bin, run_cmd, semver_ge


@pytest.mark.required
@pytest.mark.env_gate
def test_required_binaries_present() -> None:
    required = ["nvim", "git", "curl", "tar", "cc", "python3"]
    missing = [name for name in required if not has_bin(name)]
    assert not missing, f"missing required binaries: {', '.join(missing)}"


@pytest.mark.required
@pytest.mark.env_gate
def test_python_version_minimum() -> None:
    current = f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}"
    assert semver_ge(current, "3.11.0"), f"python>=3.11.0 required, got {current}"


@pytest.mark.required
@pytest.mark.env_gate
def test_pytest_version_minimum() -> None:
    current = pytest.__version__
    assert semver_ge(current, "8.0.0"), f"pytest>=8.0.0 required, got {current}"


@pytest.mark.required
@pytest.mark.env_gate
def test_nvim_version_minimum() -> None:
    result = run_cmd(["nvim", "--version"])
    assert result.returncode == 0, result.stderr
    first_line = result.stdout.splitlines()[0] if result.stdout else ""
    version = extract_first_semver(first_line)
    assert version is not None, f"failed to parse nvim version from: {first_line}"
    assert semver_ge(version, "0.11.0"), f"nvim>=0.11.0 required, got {version}"


@pytest.mark.optional
@pytest.mark.env_gate
def test_java_runtime_optional_gate(gate_mode: str) -> None:
    result = run_cmd(["java", "-version"])
    if result.returncode != 0:
        if gate_mode == "strict":
            pytest.fail("java runtime missing, install JDK 17+ for java extra")
        pytest.xfail("java runtime missing; install JDK 17+ for full java workflow")

    version_text = (result.stderr or result.stdout).replace('"', "")
    version = extract_first_semver(version_text)
    if not version:
        if gate_mode == "strict":
            pytest.fail(f"failed to parse java version: {version_text}")
        pytest.xfail(f"failed to parse java version: {version_text}")
    assert semver_ge(version, "17.0.0"), f"java>=17 required, got {version}"


@pytest.mark.optional
@pytest.mark.env_gate
def test_platform_is_reported() -> None:
    # Guardrail to keep diagnostics readable in CI/local logs.
    assert platform.system(), "platform.system() returned empty value"
