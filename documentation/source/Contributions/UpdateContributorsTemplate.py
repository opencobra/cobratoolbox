#!/usr/bin/env python3
"""
Copy the left sidebar menu from a built Sphinx page (index.html) into
contributorsTemp.html, replacing only the
<div class="wy-menu wy-menu-vertical" ...> ... </div> contents.

It then retargets the "current" highlight to a specific href
(default: contributors.html) so the sidebar shows the Contributors page
as selected.

Usage:
  python UpdateContributorsTemplate.py \
    --source ./documentation/build/html/index.html \
    --input  ./documentation/source/Contributions/contributorsTemp.html \
    --output ./documentation/source/Contributions/contributorsTemp.html \
    --current-href contributors.html
"""

from __future__ import annotations
import argparse
from pathlib import Path
from bs4 import BeautifulSoup

def parse_args():
    ap = argparse.ArgumentParser(description="Replace sidebar in contributorsTemp.html using index.html and retarget 'current'.")
    ap.add_argument("--source", required=True, help="Path to built HTML with the correct sidebar (usually build/html/index.html)")
    ap.add_argument("--input", required=True, help="Path to contributorsTemp.html to modify")
    ap.add_argument("--output", required=True, help="Path to write the updated HTML (can be same as --input)")
    ap.add_argument("--current-href", default="contributors.html",
                    help="Sidebar href that should be highlighted as current (default: contributors.html)")
    ap.add_argument("--parser", default="html5lib", choices=["html5lib", "lxml", "html.parser"],
                    help="BeautifulSoup parser to use (default: html5lib)")
    return ap.parse_args()

def get_menu_div(soup: BeautifulSoup):
    return soup.select_one("div.wy-menu.wy-menu-vertical")

def replace_inner_html(target_div, new_inner_html: str, parser: str):
    target_div.clear()
    fragment = BeautifulSoup(new_inner_html, parser)
    parents = fragment.body.contents if fragment.body else fragment.contents
    for child in list(parents):
        target_div.append(child)

def normalise_href(href: str) -> str:
    if not href:
        return ""
    # Treat "#" as index.html on the home page menu
    if href.strip() == "#":
        return "index.html"
    return href.strip()

def retarget_current(menu_div, current_href: str = "contributors.html"):
    """
    Remove 'current' from all items/uls and set it on the li whose <a>
    matches current_href. Also set its parent <ul> to class 'current'.
    Uses :scope so it works with soupsieve.
    """
    wanted = normalise_href(current_href)

    # 1) Clear all 'current' classes under the menu
    for ul in menu_div.select(":scope ul"):
        if "current" in ul.get("class", []):
            ul["class"] = [c for c in ul.get("class", []) if c != "current"]
    for li in menu_div.select(":scope li"):
        if "current" in li.get("class", []):
            li["class"] = [c for c in li.get("class", []) if c != "current"]

    # 2) Find the li for the target href
    target_li = None
    for a in menu_div.select(":scope a.reference.internal"):
        if normalise_href(a.get("href", "")) == wanted:
            target_li = a.find_parent("li")
            break

    if not target_li:
        # Nothing to retarget; leave menu as-is
        return

    # 3) Mark it as current
    li_classes = target_li.get("class", [])
    if "current" not in li_classes:
        target_li["class"] = li_classes + ["current"]

    # 4) Ensure the immediate parent <ul> is marked current
    parent_ul = target_li.find_parent("ul")
    if parent_ul:
        ul_classes = parent_ul.get("class", [])
        if "current" not in ul_classes:
            parent_ul["class"] = ul_classes + ["current"]

def main():
    args = parse_args()
    src_path = Path(args.source)
    in_path  = Path(args.input)
    out_path = Path(args.output)

    if not src_path.is_file():
        raise SystemExit(f"Source HTML not found: {src_path}")
    if not in_path.is_file():
        raise SystemExit(f"Input HTML not found: {in_path}")

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

    # Copy the sidebar HTML from index.html
    new_inner = src_menu.decode_contents()
    replace_inner_html(tgt_menu, new_inner, args.parser)

    # Retarget the "current" highlight to Contributors (or provided href)
    retarget_current(tgt_menu, current_href=args.current_href)

    out_path.write_text(str(in_soup), encoding="utf-8")
    print(f"✓ Sidebar updated and 'current' set to {args.current_href}: {out_path}")

if __name__ == "__main__":
    main()
