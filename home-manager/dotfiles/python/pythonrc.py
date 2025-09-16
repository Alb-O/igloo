#!/usr/bin/env python3
"""XDG-compliant history bootstrap for vanilla Python pre-3.13."""
from __future__ import annotations
import atexit
import os
from pathlib import Path

import readline


def is_vanilla() -> bool:
    """Return True when running CPython without REPL replacements."""
    argv0 = os.path.basename(os.environ.get("PYTHONEXECUTABLE", ""))
    if argv0 in {"ipython", "bpython"}:
        return False
    return "__IPYTHON__" not in globals()


def history_path() -> Path:
    if hist := os.environ.get("PYTHON_HISTORY"):
        return Path(hist)

    state_home = os.environ.get("XDG_STATE_HOME")
    if state_home:
        return Path(state_home) / "python" / "history"

    return Path.home() / ".local" / "state" / "python_history"


def ensure_history(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if not path.exists():
        path.touch()


def main() -> None:
    target = history_path()
    ensure_history(target)
    readline.read_history_file(target)
    atexit.register(readline.write_history_file, target)


if is_vanilla():
    main()
