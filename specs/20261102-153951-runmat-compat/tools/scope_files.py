"""List the in-scope MATLAB files of the RunMat-compatibility feature.

Usage: python3 scope_files.py            (run from the repository root; prints one path per line)

In scope: tracked `.m` files under `src/` and `test/`, plus `initCobraToolbox.m` (FR-007, FR-013).
Excluded: any path inside a `.gitmodules` submodule path, and any path with an `external` or
`deprecated` folder component.
"""
import subprocess
import sys


def git_lines(*args):
    out = subprocess.run(["git", *args], check=True, capture_output=True, text=True).stdout
    return [line for line in out.splitlines() if line]


def submodule_paths():
    try:
        lines = git_lines("config", "-f", ".gitmodules", "--get-regexp", r"submodule\..*\.path")
    except subprocess.CalledProcessError:
        return []
    return [line.split(None, 1)[1] for line in lines]


def main():
    subs = submodule_paths()
    files = git_lines("ls-files", "--", "src/*.m", "test/*.m", "initCobraToolbox.m")
    for path in files:
        parts = path.split("/")
        if "external" in parts[:-1] or "deprecated" in parts[:-1]:
            continue
        if any(path == s or path.startswith(s + "/") for s in subs):
            continue
        print(path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
