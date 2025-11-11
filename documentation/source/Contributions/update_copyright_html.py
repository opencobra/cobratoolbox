#!/usr/bin/env python3
import argparse
import datetime
import pathlib
import re

CURRENT_YEAR = datetime.datetime.now().year
RANGE_SEP = r"[-–]"  # hyphen or en dash


def update(html: str, start_year: int | None, author: str | None) -> str:
    flags = re.IGNORECASE

    author_guard = ""
    if author:
        author_guard = rf"(?=[^\n\r]{{0,200}}{re.escape(author)})"

    # Update ranges: 2017-2020 -> 2017-2025
    pattern_range = re.compile(
        rf"((?:copyright|©)[^.\n\r]{{0,80}}?){author_guard}\b(\d{{4}})\s*{RANGE_SEP}\s*(\d{{4}})\b",
        flags
    )

    def repl_range(m):
        prefix, left, _right = m.group(1), int(m.group(2)), int(m.group(3))
        left = start_year if start_year else left
        return f"{prefix}{left}-{CURRENT_YEAR}"

    html = pattern_range.sub(repl_range, html)

    # Update single-year copyright: 2019 -> 2019-2025
    pattern_single = re.compile(
        rf"((?:copyright|©)[^.\n\r]{{0,80}}?){author_guard}\b(\d{{4}})\b(?!\s*{RANGE_SEP}\s*\d{{4}})",
        flags
    )

    def repl_single(m):
        prefix, year = m.group(1), int(m.group(2))
        left = start_year if start_year else year
        if left >= CURRENT_YEAR:
            return m.group(0)
        return f"{prefix}{left}-{CURRENT_YEAR}"

    html = pattern_single.sub(repl_single, html)

    return html


def main():
    parser = argparse.ArgumentParser(description="Update copyright year in an HTML file (no backups).")
    parser.add_argument("html_path", help="Input HTML file")
    parser.add_argument("--start-year", type=int, help="Force a specific start year", default=None)
    parser.add_argument("--author", type=str, help="Only update if this author text is on the same line", default=None)
    parser.add_argument("--encoding", default="utf-8")
    args = parser.parse_args()

    path = pathlib.Path(args.html_path)

    original = path.read_text(encoding=args.encoding)
    updated = update(original, args.start_year, args.author)
    path.write_text(updated, encoding=args.encoding)

    print(f"Updated copyright years in: {path}")


if __name__ == "__main__":
    main()
