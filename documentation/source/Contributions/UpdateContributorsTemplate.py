#!/usr/bin/env python3
"""
Copy the left sidebar menu from a built Sphinx page (index.html) into
contributorsTemp.html, then retarget the 'current' menu item to contributors.html.
"""

from __future__ import annotations
import argparse
from pathlib import Path
from bs4 import BeautifulSoup

def parse_args():
    ap = argparse.ArgumentParser(description="Replace sidebar and set 'current' to a target href")
    ap.add_argument("--source", required=True, help="Path to built HTML with the correct sidebar (build/html/index.html)")
    ap.add_argument("--input", required=True, help="Path to contributorsTemp.html to modify")
    ap.add_argument("--output", required=True, help="Path to write the updated HTML (can be same as --input)")
    ap.add_argument("--current-href", dest="current_href", default="contributors.html",
                    help="Href that should be marked as current")
    ap.add_argument("--parser", default="html5lib", choices=["html5lib", "lxml", "html.parser"],
                    help="BeautifulSoup parser to use")
    return ap.parse_args()

def get_menu_div(soup: BeautifulSoup):
    return soup.select_one("div.wy-menu.wy-menu-vertical")

def replace_inner_html(target_div, new_inner_html: str, parser: str):
    target_div.clear()
    fragment = BeautifulSoup(new_inner_html, parser)
    parents = fragment.body.contents if fragment.body else fragment.contents
    for child in list(parents):
        target_div.append(child)

def _remove_class(tag, cls: str):
    classes = tag.get("class", [])
    if not classes:
        return
    classes = [c for c in classes if c != cls]
    if classes:
        tag["class"] = classes
    elif "class" in tag.attrs:
        del tag["class"]

def _add_class_ordered(tag, desired_order: list[str]):
    """
    Add classes ensuring the final order matches desired_order first,
    followed by any other existing classes in their original order.
    """
    existing = tag.get("class", [])
    # Start with desired_order, include only once
    ordered = []
    for d in desired_order:
        if d in existing:
            ordered.append(d)
        else:
            ordered.append(d)
    # Append the rest, skipping duplicates
    for c in existing:
        if c not in ordered:
            ordered.append(c)
    tag["class"] = ordered

def href_matches(a_tag, target_href: str) -> bool:
    href = (a_tag.get("href") or "").strip()
    if not href:
        return False
    return href == target_href or href.endswith("/" + target_href)

def retarget_current(menu_div, current_href: str):
    """
    Ensure:
      - only the UL containing current_href has class 'current'
      - only the LI for current_href has class 'current'
      - the A for current_href has class 'current' and ordered as 'current reference internal'
    """
    # Remove 'current' from all top-level ULs
    uls = [ul for ul in menu_div.find_all("ul", recursive=False)]
    for ul in uls:
        _remove_class(ul, "current")

    target_li = None
    target_ul = None

    # Scan first-level items only
    for ul in uls:
        for li in ul.find_all("li", class_="toctree-l1", recursive=False):
            a = li.find("a", recursive=True)
            # Clear stale 'current' on each pass
            _remove_class(li, "current")
            if a:
                _remove_class(a, "current")
            if a and href_matches(a, current_href):
                target_li = li
                target_ul = ul

    if target_ul and target_li:
        # Mark UL and LI
        _add_class_ordered(target_ul, ["current"])
        _add_class_ordered(target_li, ["current"])
        # Ensure anchor has 'current reference internal' in that exact order
        a = target_li.find("a", recursive=True)
        if a:
            # Guarantee it also has reference and internal if Sphinx added them before
            existing = a.get("class", [])
            must_have = ["reference", "internal"]
            for cls in must_have:
                if cls not in existing:
                    existing.append(cls)
            a["class"] = existing  # set before ordering
            _add_class_ordered(a, ["current", "reference", "internal"])

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

    # Copy the menu contents
    new_inner = src_menu.decode_contents()
    replace_inner_html(tgt_menu, new_inner, args.parser)

    # Retarget 'current' to contributors.html
    retarget_current(tgt_menu, current_href=args.current_href)

    out_path.write_text(str(in_soup), encoding="utf-8")
    print(f"✓ Sidebar updated and 'current' set to {args.current_href}: {out_path}")

if __name__ == "__main__":
    main()
