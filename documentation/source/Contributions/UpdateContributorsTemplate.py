#!/usr/bin/env python3
"""
Copy the left sidebar menu from a built Sphinx page (index.html) into
contributorsTemp.html, replacing only the
<div class="wy-menu wy-menu-vertical" ...> ... </div> contents.

Usage:
  python UpdateContributorsTemplate.py \
    --source ./documentation/build/html/index.html \
    --input  ./documentation/source/Contributions/contributorsTemp.html \
    --output ./documentation/source/Contributions/contributorsTemp.html
"""

from __future__ import annotations
import argparse
from pathlib import Path
from bs4 import BeautifulSoup

def parse_args():
    ap = argparse.ArgumentParser(description="Replace sidebar in contributorsTemp.html using index.html")
    ap.add_argument("--source", required=True, help="Path to built HTML with the correct sidebar (usually build/html/index.html)")
    ap.add_argument("--input", required=True, help="Path to contributorsTemp.html to modify")
    ap.add_argument("--output", required=True, help="Path to write the updated HTML (can be same as --input)")
    # Parser choice note:
    # html5lib preserves Sphinx' whitespace and entities very faithfully.
    ap.add_argument("--parser", default="html5lib", choices=["html5lib", "lxml", "html.parser"],
                    help="BeautifulSoup parser to use (default: html5lib)")
    return ap.parse_args()

def get_menu_div(soup: BeautifulSoup):
    return soup.select_one("div.wy-menu.wy-menu-vertical")

def replace_inner_html(target_div, new_inner_html: str, parser: str):
    # Clear current children
    target_div.clear()
    # Parse the fragment and append its top-level nodes into the target div
    fragment = BeautifulSoup(new_inner_html, parser)
    # Use .contents rather than .body to avoid accidental extra wrapper nodes
    parents = fragment.body.contents if fragment.body else fragment.contents
    for child in list(parents):
        target_div.append(child)

def main():
    args = parse_args()
    src_path = Path(args.source)
    in_path  = Path(args.input)
    out_path = Path(args.output)

    if not src_path.is_file():
        raise SystemExit(f"Source HTML not found: {src_path}")
    if not in_path.is_file():
        raise SystemExit(f"Input HTML not found: {in_path}")

    # Load both documents
    src_html = src_path.read_text(encoding="utf-8", errors="ignore")
    in_html  = in_path.read_text(encoding="utf-8", errors="ignore")

    src_soup = BeautifulSoup(src_html, args.parser)
    in_soup  = BeautifulSoup(in_html,  args.parser)

    src_menu = get_menu_div(src_soup)
    if not src_menu:
        raise SystemExit("Could not find sidebar in source HTML: div.wy-menu.wy-menu-vertical")

    tgt_menu = get_menu_div(in_soup)
    if not tgt_menu:
        raise SystemExit("Could not find sidebar in input HTML: div.wy-menu.wy-menu-vertical")

    # Copy the exact inner HTML from source menu
    new_inner = src_menu.decode_contents()
    replace_inner_html(tgt_menu, new_inner, args.parser)

    # Write out without prettify to avoid reformatting or truncation
    out_path.write_text(str(in_soup), encoding="utf-8")
    print(f"✓ Sidebar updated in: {out_path}")

if __name__ == "__main__":
    main()
