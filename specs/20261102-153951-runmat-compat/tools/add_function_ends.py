"""Add a closing `end` to every function in MATLAB files whose functions are all unterminated.

Usage: python3 add_function_ends.py FILE...      (rewrites each FILE in place, prints one line per file)

A file is rewritten only when it has at least one function and no function in it is already
terminated. The caller verifies each rewrite with MATLAB's code analyzer and RunMat's checker; this
script makes no judgement about whether the original file was valid.

Detection rules:
- A function starts at a line whose first token is `function`, outside a block comment (%{ ... %}).
- In a file with unterminated functions no function can be nested, so every function line starts a
  top-level function, which ends where the next one starts or at end of file.
- `end` is inserted after the last code line of each function (trailing comment and blank lines that
  precede the next function, typically its help text, are left after the inserted `end`).
- Files that start with `classdef` are skipped (class definitions always use `end`).
Whether the functions are unterminated is decided by the caller (the file failed RunMat with
"expected 'end'" at the function line, and MATLAB's analyzer must accept the rewrite).
"""
import re
import sys

FUNC = re.compile(r"^\s*function\b")
BLOCK_OPEN = re.compile(r"^\s*%\{\s*$")
BLOCK_CLOSE = re.compile(r"^\s*%\}\s*$")
COMMENT_OR_BLANK = re.compile(r"^\s*(%.*)?$")


def code_mask(lines):
    """True for lines outside block comments."""
    mask, depth = [], 0
    for line in lines:
        if BLOCK_OPEN.match(line):
            depth += 1
            mask.append(False)
        elif BLOCK_CLOSE.match(line) and depth:
            depth -= 1
            mask.append(False)
        else:
            mask.append(depth == 0)
    return mask


def rewrite(text):
    lines = text.split("\n")
    mask = code_mask(lines)
    starts = [i for i, l in enumerate(lines) if mask[i] and FUNC.match(l)]
    first_code = next((l for i, l in enumerate(lines) if mask[i] and not COMMENT_OR_BLANK.match(l)), "")
    if not starts or first_code.lstrip().startswith("classdef"):
        return None
    bounds = starts[1:] + [len(lines)]
    inserts = []
    for b in bounds:
        j = b - 1
        while j > starts[0] and (not mask[j] or COMMENT_OR_BLANK.match(lines[j])):
            j -= 1
        inserts.append(j + 1)
    for pos in reversed(inserts):
        lines.insert(pos, "end")
    return "\n".join(lines)


if __name__ == "__main__":
    for path in sys.argv[1:]:
        with open(path, encoding="utf-8", newline="") as f:
            text = f.read()
        crlf = "\r\n" in text
        new = rewrite(text.replace("\r\n", "\n"))
        if new is None:
            print(f"SKIP\t{path}")
            continue
        if crlf:
            new = new.replace("\n", "\r\n")
        with open(path, "w", encoding="utf-8", newline="") as f:
            f.write(new)
        print(f"OK\t{path}")
