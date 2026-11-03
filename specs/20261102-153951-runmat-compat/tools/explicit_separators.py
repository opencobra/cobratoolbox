"""Make element and row separators explicit inside MATLAB cell and matrix literals.

Usage: python3 explicit_separators.py [--dry-run] FILE...

Inside `{...}`, whitespace that MATLAB reads as an element separator becomes `, `.
Inside `{...}` and `[...]`, a newline that MATLAB reads as a row separator gets a `;`
before it (after the last token on the line, before any trailing comment).

MATLAB reads both forms identically; the caller confirms each rewritten file by comparing
MATLAB's parse tree (kinds and strings) before and after, and discards any file whose tree
changes. This script therefore aims to be correct for ordinary code and safe to reject when
unsure: it leaves a file untouched (status SKIP) when it meets something it does not model.

Printed per file: OK <path> <commas> <semicolons>, SAME <path>, or SKIP <path> <reason>.
"""
import re
import sys

IDENT = re.compile(r"[A-Za-z_]\w*")
NUMBER = re.compile(r"(\d+\.?\d*|\.\d+)([eEdD][+-]?\d+)?[ij]?")
OPERATORS = [".*", "./", ".\\", ".^", ".'", "==", "~=", "<=", ">=", "&&", "||",
             "+", "-", "*", "/", "\\", "^", "<", ">", "&", "|", "~", "!", "=", ":", ".", "@", "?"]
# Tokens after which a quote is a transpose, not a string start (outside the whitespace rule).
VALUE_END = {"ident", "number", "string", ")", "]", "}", "transpose"}


class Skip(Exception):
    pass


def lex(text):
    """Single-pass MATLAB lexer: returns (kind, value, start, end) tokens; newlines are tokens.

    A quote starts a char literal unless it follows a value (identifier, number, closing
    bracket, string or transpose) with no space between, or follows a value after a space
    outside brackets; inside [] or {}, a quote after whitespace starts a char literal.
    """
    out = []
    stack = []
    i, n = 0, len(text)
    block = 0
    line_start = True

    def last_sig():
        for t in reversed(out):
            if t[0] != "space":
                return t
        return None

    while i < n:
        c = text[i]
        if line_start:
            line_start = False
            m = re.match(r"[ \t]*%\{[ \t]*(?=\r?\n)", text[i:])
            if m:
                block += 1
                out.append(("comment", m.group(0), i, i + m.end()))
                i += m.end()
                continue
            if block:
                j = text.find("\n", i)
                j = n if j == -1 else j
                if re.match(r"[ \t]*%\}[ \t]*\r?$", text[i:j]):
                    block -= 1
                out.append(("comment", text[i:j], i, j))
                i = j
                continue
        if c == "\n":
            out.append(("newline", c, i, i + 1))
            i += 1
            line_start = True
            continue
        if c in " \t\r":
            j = i
            while j < n and text[j] in " \t\r":
                j += 1
            out.append(("space", text[i:j], i, j))
            i = j
            continue
        if c == "%":
            j = text.find("\n", i)
            j = n if j == -1 else j
            out.append(("comment", text[i:j], i, j))
            i = j
            continue
        if text.startswith("...", i):
            j = text.find("\n", i)
            j = n if j == -1 else j + 1
            out.append(("continuation", text[i:j], i, j))
            i = j
            line_start = True
            continue
        if c in "'\"":
            sig = last_sig()
            prev_space = bool(out) and out[-1][0] == "space"
            in_brackets = bool(stack) and stack[-1] in "[{"
            value_before = sig is not None and sig[0] in VALUE_END
            if c == "'" and value_before and not (prev_space and in_brackets):
                out.append(("transpose", "'", i, i + 1))
                i += 1
                continue
            j = i + 1
            while j < n and text[j] != "\n":
                if text[j] == c:
                    if j + 1 < n and text[j + 1] == c:
                        j += 2
                        continue
                    break
                j += 1
            if j >= n or text[j] != c:
                raise Skip("unterminated string")
            out.append(("string", text[i:j + 1], i, j + 1))
            i = j + 1
            continue
        m = IDENT.match(text, i)
        if m:
            out.append(("ident", m.group(0), i, m.end()))
            i = m.end()
            continue
        m = NUMBER.match(text, i)
        if m:
            out.append(("number", m.group(0), i, m.end()))
            i = m.end()
            continue
        if c in "([{":
            stack.append(c)
            out.append((c, c, i, i + 1))
            i += 1
            continue
        if c in ")]}":
            if not stack:
                raise Skip("unbalanced brackets")
            stack.pop()
            out.append((c, c, i, i + 1))
            i += 1
            continue
        if c in ",;":
            out.append((c, c, i, i + 1))
            i += 1
            continue
        if text.startswith(".'", i):
            out.append(("transpose", ".'", i, i + 2))
            i += 2
            continue
        for op in OPERATORS:
            if text.startswith(op, i):
                out.append(("op", op, i, i + len(op)))
                i += len(op)
                break
        else:
            raise Skip(f"unknown character {c!r}")
    if stack:
        raise Skip("unbalanced brackets at end of file")
    return out


OPERAND_START = {"ident", "number", "string", "(", "[", "{", "@"}


def element_break(tokens, i):
    """True if the whitespace token at i, inside a bracket literal, separates two elements."""
    prev = tokens[i - 1]
    nxt = tokens[i + 1] if i + 1 < len(tokens) else None
    if nxt is None or prev[0] in ("(", "[", "{", ",", ";", "op") and prev[1] not in ("'",):
        return False
    if prev[0] not in ("ident", "number", "string", ")", "]", "}", "transpose"):
        return False
    if nxt[0] in ("]", "}", ",", ";", "newline", "comment", "continuation"):
        return False
    if nxt[0] == "op":
        if nxt[1] in ("+", "-"):
            after = tokens[i + 2] if i + 2 < len(tokens) else None
            return after is not None and after[0] != "space"      # unary: `a -b`
        if nxt[1] in ("@", "~", "!"):
            after = tokens[i + 2] if i + 2 < len(tokens) else None
            if nxt[1] == "~" and after is not None and after[0] == "op" and after[1] == "=":
                return False
            return True
        return False                                               # binary operator continues
    return nxt[0] in ("ident", "number", "string", "(", "[", "{")


def rewrite(text):
    tokens = lex(text)
    inserts = []          # (position, text)
    stack = []
    commas = semis = 0
    for i, (kind, val, s, e) in enumerate(tokens):
        if kind in "([{":
            stack.append(kind)
            continue
        if kind in ")]}":
            stack.pop()
            continue
        if not stack or stack[-1] not in "[{":
            continue
        if kind == "space" and stack[-1] == "{" and element_break(tokens, i):
            inserts.append((s, ","))
            commas += 1
        elif kind == "newline":
            j = i - 1
            while j >= 0 and tokens[j][0] in ("space", "comment"):
                j -= 1
            last = tokens[j]
            if last[0] in (";", ",", "[", "{", "newline", "continuation"):
                continue
            k = i + 1
            while k < len(tokens) and tokens[k][0] in ("space", "comment", "newline"):
                k += 1
            if k < len(tokens) and tokens[k][0] in ("]", "}"):
                continue
            inserts.append((last[3], ";"))
            semis += 1
    if not inserts:
        return None, 0, 0
    out = text
    for pos, ins in sorted(inserts, reverse=True):
        out = out[:pos] + ins + out[pos:]
    return out, commas, semis


if __name__ == "__main__":
    args = sys.argv[1:]
    dry = "--dry-run" in args
    for path in [a for a in args if a != "--dry-run"]:
        try:
            with open(path, encoding="utf-8", newline="") as f:
                text = f.read()
        except UnicodeDecodeError:
            print(f"SKIP\t{path}\tnot UTF-8")
            continue
        try:
            new, commas, semis = rewrite(text)
        except Skip as exc:
            print(f"SKIP\t{path}\t{exc}")
            continue
        if new is None:
            print(f"SAME\t{path}")
            continue
        if not dry:
            with open(path, "w", encoding="utf-8", newline="") as f:
                f.write(new)
        print(f"OK\t{path}\t{commas}\t{semis}")
