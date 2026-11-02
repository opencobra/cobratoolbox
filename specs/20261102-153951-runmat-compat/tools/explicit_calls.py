"""Write bare no-argument calls of the listed functions as explicit `name()` calls.

Usage: python3 explicit_calls.py --names A,B FILE...      (rewrites each FILE in place)

RunMat resolves a bare identifier at compile time and rejects it when it cannot see a function of
that name; `name()` is an explicit call. MATLAB reads `name` and `name()` identically when `name` is
a function or class (not a script and not a variable), which the caller establishes per name
(MATLAB `exist` is 2, 3, 5 or 6 and the file is not a script).

A file is left unchanged (SKIP) when it could make `name` a variable:
- `name` is assigned (left of a top-level `=`, including `for name = ...`, `[a, name] = ...`,
  `name(i) = ...`, `name.f = ...`), declared `global` or `persistent`, imported, or is an input or
  output of a function declaration in the file;
- the file calls `load` without an output, or `eval`, `evalin`, `evalc` or `assignin`.
An occurrence is rewritten only when it is a bare use: not followed by `(`, `{`, `.` or `=`, not
after `.`, `@` or `?`, not in command syntax (`name arg`), and not on a `function` line.

Printed per file: OK <path> <count>, SAME <path>, or SKIP <path> <reason>.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from explicit_separators import Skip, lex  # noqa: E402

STATEMENT_BREAK = {"newline", ",", ";", "continuation"}
DYNAMIC = {"eval", "evalin", "evalc", "assignin"}


def statements(tokens):
    """Splits significant tokens into top-level statements: lists of token indices."""
    out, cur, depth = [], [], 0
    for k, tok in enumerate(tokens):
        kind = tok[0]
        if kind in ("space", "comment"):
            continue
        if kind in STATEMENT_BREAK and depth == 0 and kind != "continuation":
            if cur:
                out.append(cur)
            cur = []
            continue
        if kind == "continuation":
            continue
        if len(kind) == 1 and kind in "([{":
            depth += 1
        elif len(kind) == 1 and kind in ")]}":
            depth -= 1
        cur.append(k)
    if cur:
        out.append(cur)
    return out


def top_level_assign(tokens, stmt):
    """Position in stmt of the top-level assignment `=`, or None."""
    depth = 0
    for p, k in enumerate(stmt):
        kind, value = tokens[k][0], tokens[k][1]
        if len(kind) == 1 and kind in "([{":
            depth += 1
        elif len(kind) == 1 and kind in ")]}":
            depth -= 1
        elif kind == "op" and value == "=" and depth == 0:
            return p
    return None


def file_blocker(tokens, stmts, name):
    """Reason the file could make `name` a variable, or None."""
    for stmt in stmts:
        first = tokens[stmt[0]][1]
        values = [tokens[k][1] for k in stmt]
        eq = top_level_assign(tokens, stmt)
        if first == "function":
            if name in values:
                fn_name_pos = (eq + 1) if eq is not None else 1
                if values.index(name) != fn_name_pos or values.count(name) > 1:
                    return "function argument"
            continue
        if first in ("global", "persistent", "import") and any(name in v for v in values[1:]):
            return first
        if eq is not None and name in values[:eq]:
            prev = [tokens[k] for k in stmt[:eq]]
            for p, tok in enumerate(prev):
                if tok[1] == name and not (p > 0 and prev[p - 1][1] in (".", "@")):
                    return "assigned"
        if first == "load" and eq is None:
            return "load without output"
        if any(v in DYNAMIC for v in values):
            return "eval or assignin"
    return None


def bare_occurrences(tokens, stmts, name):
    found = []
    for stmt in stmts:
        if tokens[stmt[0]][1] == "function":
            continue
        for p, k in enumerate(stmt):
            if tokens[k][0] != "ident" or tokens[k][1] != name:
                continue
            prev = tokens[stmt[p - 1]] if p > 0 else None
            if prev is not None and prev[1] in (".", "@", "?"):
                continue
            nxt = tokens[stmt[p + 1]] if p + 1 < len(stmt) else None
            if nxt is not None and nxt[1] in ("(", "{", ".", "="):
                continue
            spaced = k + 1 < len(tokens) and tokens[k + 1][0] == "space"
            if p == 0 and nxt is not None and spaced and nxt[0] in ("ident", "number", "string"):
                continue  # command syntax: `name arg`
            found.append(k)
    return found


def rewrite(text, names):
    tokens = lex(text)
    stmts = statements(tokens)
    inserts, blocked = [], []
    for name in names:
        reason = file_blocker(tokens, stmts, name)
        occurrences = bare_occurrences(tokens, stmts, name)
        if reason and occurrences:
            blocked.append(f"{name}: {reason}")
            continue
        inserts.extend(tokens[k][3] for k in occurrences)
    if blocked:
        raise Skip("; ".join(blocked))
    if not inserts:
        return None, 0
    out = text
    for pos in sorted(inserts, reverse=True):
        out = out[:pos] + "()" + out[pos:]
    return out, len(inserts)


if __name__ == "__main__":
    args = sys.argv[1:]
    if len(args) < 2 or args[0] != "--names":
        sys.exit(__doc__)
    names = [n for n in args[1].split(",") if n]
    for path in args[2:]:
        try:
            with open(path, encoding="utf-8", newline="") as f:
                text = f.read()
        except UnicodeDecodeError:
            print(f"SKIP\t{path}\tnot UTF-8")
            continue
        try:
            new, count = rewrite(text, names)
        except Skip as exc:
            print(f"SKIP\t{path}\t{exc}")
            continue
        if new is None:
            print(f"SAME\t{path}")
            continue
        with open(path, "w", encoding="utf-8", newline="") as f:
            f.write(new)
        print(f"OK\t{path}\t{count}")
