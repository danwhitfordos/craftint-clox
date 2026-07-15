#!/usr/bin/env python3
"""Run every .lox file in examples/ and fail on any interpreter error."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path


def run_examples(clox_path: Path, examples_dir: Path) -> int:
    if not clox_path.exists():
        print(f"error: clox binary not found: {clox_path}", file=sys.stderr)
        return 1

    if not examples_dir.is_dir():
        print(f"error: examples directory not found: {examples_dir}", file=sys.stderr)
        return 1

    example_files = sorted(examples_dir.glob("*.lox"))
    if not example_files:
        print(f"error: no .lox files found in {examples_dir}", file=sys.stderr)
        return 1

    failures = 0
    for example in example_files:
        proc = subprocess.run(
            [str(clox_path), str(example)],
            capture_output=True,
            text=True,
            check=False,
        )

        if proc.returncode != 0:
            failures += 1
            print(f"FAIL: {example.name} (exit code {proc.returncode})")
            if proc.stdout:
                print("--- stdout ---")
                print(proc.stdout, end="" if proc.stdout.endswith("\n") else "\n")
            if proc.stderr:
                print("--- stderr ---")
                print(proc.stderr, end="" if proc.stderr.endswith("\n") else "\n")
        else:
            print(f"PASS: {example.name}")

    total = len(example_files)
    print(f"\nexamples smoke test: {total - failures}/{total} passed")
    return 0 if failures == 0 else 1


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: test_examples.py <path-to-clox> <examples-dir>", file=sys.stderr)
        return 2

    clox_path = Path(sys.argv[1]).resolve()
    examples_dir = Path(sys.argv[2]).resolve()
    return run_examples(clox_path, examples_dir)


if __name__ == "__main__":
    sys.exit(main())
