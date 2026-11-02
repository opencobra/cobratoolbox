"""Add an empty `catch` to every `try` block that has none.

Usage: python3 add_empty_catch.py FILE...      (rewrites each FILE in place, prints one line per file)

RunMat rejects `try` without `catch`; MATLAB treats it the same as an empty `catch` (the error is
discarded). The `catch` is inserted before the `end` that closes the `try`: on its own line at the
`try` indentation when that `end` starts its line, otherwise as `catch, ` just before the `end`.

Blocks are matched with the lexer of explicit_separators.py: `end` outside brackets closes the
innermost open block; block keywords count only as the first token of a statement and not after a
`.`; class sections (methods, properties, events, enumeration) count only directly inside classdef,
and `arguments` only before a line end or an Input, Output or Repeating attribute. `function` opens a block only in files whose functions are terminated (decided by whether the
blocks balance). The caller verifies each rewrite with MATLAB: the parse tree may differ only by the
added CATCH nodes (parseTreeEquivalence 'catch' mode), and the code analyzer gains no message.

Printed per file: OK <path> <count>, SAME <path>, or SKIP <path> <reason>.
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from explicit_separators import Skip, lex  # noqa: E402

OPENERS = {"if", "for", "parfor", "while", "switch", "try", "spmd", "classdef",
           "methods", "properties", "events", "enumeration", "arguments"}
CLASS_SECTIONS = {"methods", "properties", "events", "enumeration", "arguments"}
STATEMENT_BREAK = {"newline", ",", ";", "continuation"}


def is_block_opener(tokens, k, value, stack):
    """Class sections open a block directly inside classdef; `arguments` opens one when followed
    by a line end or an (Input), (Output) or (Repeating) attribute; other keywords always do."""
    if value not in CLASS_SECTIONS:
        return True
    if value != "arguments":
        return bool(stack) and stack[-1][0] == "classdef"
    rest = [t for t in tokens[k + 1:k + 8] if t[0] != "space"]
    if not rest or rest[0][0] in ("newline", "comment", ",", ";"):
        return True
    return (rest[0][1] == "(" and len(rest) > 2 and rest[1][1] in ("Input", "Output", "Repeating")
            and rest[2][1] == ")")


def match_blocks(tokens, function_opens):
    """Returns (end index, try index) token pairs for each `try` with no `catch`, and the open blocks."""
    stack = []  # entries: [keyword, token index, has_catch]
    depth = 0
    statement_start = True
    missing = []
    prev_sig = None
    for k, (kind, value, _, _) in enumerate(tokens):
        if kind in ("space", "comment"):
            continue
        if kind in "([{" and len(kind) == 1:
            depth += 1
        elif kind in ")]}" and len(kind) == 1:
            depth -= 1
        elif kind == "ident" and depth == 0 and not (prev_sig and prev_sig[1] == "."):
            if value == "end":
                if not stack:
                    raise Skip("unmatched end")
                keyword, opened_at, has_catch = stack.pop()
                if keyword == "try" and not has_catch:
                    missing.append((k, opened_at))
            elif statement_start and value == "catch" and stack and stack[-1][0] == "try":
                stack[-1][2] = True
            elif statement_start and (value in OPENERS or (value == "function" and function_opens)):
                if is_block_opener(tokens, k, value, stack):
                    stack.append([value, k, False])
        statement_start = kind in STATEMENT_BREAK and depth == 0
        prev_sig = (kind, value)
    return missing, stack


def rewrite(text):
    tokens = lex(text)
    missing, stack = match_blocks(tokens, function_opens=True)
    if stack:
        if any(entry[0] != "function" for entry in stack):
            raise Skip("unbalanced blocks")
        missing, stack = match_blocks(tokens, function_opens=False)
        if stack:
            raise Skip("unbalanced blocks")
    if not missing:
        return None, 0
    newline = "\r\n" if "\r\n" in text else "\n"
    out = text
    for k, try_index in sorted(missing, reverse=True):
        pos = tokens[k][2]
        line_start = text.rfind("\n", 0, pos) + 1
        if text[line_start:pos].strip() == "":
            try_line = text.rfind("\n", 0, tokens[try_index][2]) + 1
            indent = re.match(r"[ \t]*", text[try_line:]).group(0)
            insert_at, insertion = line_start, indent + "catch" + newline
        else:
            insert_at, insertion = pos, "catch, "
        out = out[:insert_at] + insertion + out[insert_at:]
    return out, len(missing)


if __name__ == "__main__":
    for path in sys.argv[1:]:
        try:
            with open(path, encoding="utf-8", newline="") as f:
                text = f.read()
        except UnicodeDecodeError:
            print(f"SKIP\t{path}\tnot UTF-8")
            continue
        try:
            new, count = rewrite(text)
        except Skip as exc:
            print(f"SKIP\t{path}\t{exc}")
            continue
        if new is None:
            print(f"SAME\t{path}")
            continue
        with open(path, "w", encoding="utf-8", newline="") as f:
            f.write(new)
        print(f"OK\t{path}\t{count}")
