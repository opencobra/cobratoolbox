#!/usr/bin/env python3
import argparse
import datetime as _dt
import pathlib
import re
import sys

def build_pattern(holder: str) -> re.Pattern:
    # Match "©", "&copy;", "&#169;", or "Copyright"
    # Then a start year, optional dash and end year, then the holder name
    sym = r'(?:©|&copy;|&#169;|Copyright)'
    years = r'\s*(?P<start>\d{4})(?:\s*[-–]\s*(?P<end>\d{4}))?'
    tail = r'\s*,?\s*' + re.escape(holder)
    return re.compile(rf'(?P<prefix>{sym}){years}{tail}', re.IGNORECASE)

def update_text(text: str, holder: str, default_start: int) -> tuple[str, bool]:
    year_now = _dt.date.today().year
    pat = build_pattern(holder)

    def repl(m: re.Match) -> str:
        prefix = m.group('prefix')
        start = int(m.group('start')) if m.group('start') else default_start
        # Keep original start if it looks sensible, else fall back
        if start < 1900 or start > year_now:
            start = default_start
        if start == year_now:
            year_part = f'{year_now}'
        else:
            year_part = f'{start}-{year_now}'
        # Preserve original symbol capitalisation
        if prefix.lower() == 'copyright':
            prefix_out = 'Copyright'
        else:
            prefix_out = prefix
        return f'{prefix_out} {year_part}, {holder}'

    new_text, n = pat.subn(repl, text)
    if n > 0:
        return new_text, True

    # Fallback: try to inject into a footer-like area if present
    footer_pat = re.compile(r'(<footer[^>]*>)(.*?)(</footer>)', re.IGNORECASE | re.DOTALL)
    m = footer_pat.search(text)
    if m:
        start = default_start
        year_part = f'{year_now}' if start == year_now else f'{start}-{year_now}'
        replacement = f"{m.group(1)}<p>© {year_part}, {holder}</p>{m.group(3)}"
        return footer_pat.sub(replacement, text, count=1), True

    # Final fallback: if no match at all, do nothing but signal no change
    return text, False

def main():
    ap = argparse.ArgumentParser(description="Update copyright year range in an HTML file, in place.")
    ap.add_argument("files", nargs="+", help="HTML file(s) to update")
    ap.add_argument("--holder", default="The COBRA Toolbox developers",
                    help="Copyright holder text to match and keep")
    ap.add_argument("--default-start", type=int, default=2017,
                    help="Default start year if none is found in the file")
    args = ap.parse_args()

    changed_any = False
    for f in args.files:
        path = pathlib.Path(f)
        if not path.exists():
            print(f"[skip] {path} not found", file=sys.stderr)
            continue
        text = path.read_text(encoding="utf-8")
        new_text, changed = update_text(text, args.holder, args.default_start)
        if changed:
            path.write_text(new_text, encoding="utf-8")
            print(f"[ok]  Updated {path}")
            changed_any = True
        else:
            print(f"[info] No matching copyright found in {path}", file=sys.stderr)

    return 0 if changed_any else 0  # do not fail the build if nothing changed

if __name__ == "__main__":
    sys.exit(main())
