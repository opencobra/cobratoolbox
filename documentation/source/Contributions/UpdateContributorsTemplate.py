#!/usr/bin/env python3
"""
Copy the left sidebar menu from a built Sphinx page (index.html) into
contributorsTemp.html, then retarget the 'current' menu item to contributors.html,
ensuring exact class ordering:
- <li> :  ["toctree-l1", "current"]
- <a>  :  ["current", "reference", "internal"]
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
    ap.add_argument("--current-href", default="contributors.html", help="Href that should be marked as current")
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

def href_matches(a_tag, target_href: str) -> bool:
    href = (a_tag.get("href") or "").strip()
    if not href:
        return False
    return href == target_href or href.endswith("/" + target_href)

def set_exact_classes(tag, ordered_classes: list[str]):
    """Force exactly this class list (order preserved as provided)."""
    if ordered_classes:
        tag["class"] = ordered_classes
    elif "class" in tag.attrs:
        del tag["class"]

def retarget_current(menu_div, current_href: str):
    """
    Make the sidebar show 'current' for the given href, with exact class ordering:
      - only the UL containing current_href has class 'current'
      - only the LI for current_href has class 'current', ordered as ['toctree-l1', 'current']
      - the A for current_href has class 'current reference internal' (in that order)
    """

    # 1) Get top-level ULs under the menu and strip 'current' from them
    uls = [ul for ul in menu_div.find_all("ul", recursive=False)]
    for ul in uls:
        classes = [c for c in ul.get("class", []) if c != "current"]
        if classes:
            ul["class"] = classes
        elif "class" in ul.attrs:
            del ul["class"]

    # 2) Walk first-level items to locate the target LI/A, clearing stale 'current'
    target_li = None
    target_ul = None

    for ul in uls:
        for li in ul.find_all("li", class_="toctree-l1", recursive=False):
            a = li.find("a", recursive=True)
            # Clear stale 'current' on LI while keeping toctree-l1 first
            set_exact_classes(li, ["toctree-l1"])
            if a:
                # Normalise any anchor classes to 'reference internal' without 'current'
                ac = [c for c in a.get("class", []) if c not in ("current",)]
                # Ensure 'reference' and 'internal' exist (Sphinx RTD style)
                base = []
                if "reference" in ac:
                    base.append("reference")
                if "internal" in ac:
                    # ensure 'reference' first then 'internal'
                    pass
                # Build base as exactly ['reference', 'internal'] if present in any order
                want_ref = "reference" in ac
                want_int = "internal" in ac
                new_base = []
                if want_ref:
                    new_base.append("reference")
                if want_int:
                    new_base.append("internal")
                # If neither present (very unlikely), keep whatever remains
                set_exact_classes(a, new_base if new_base else ac)

            if a and href_matches(a, current_href):
                target_li = li
                target_ul = ul

    # 3) Apply 'current' to the correct UL, LI and A with exact ordering
    if target_ul and target_li:
        # UL: add 'current' (order does not matter on UL but keep it first if present originally)
        ul_classes = target_ul.get("class", [])
        if "current" not in ul_classes:
            target_ul["class"] = (ul_classes or []) + ["current"]

        # LI: exactly ['toctree-l1', 'current']
        set_exact_classes(target_li, ["toctree-l1", "current"])

        # A: exactly ['current', 'reference', 'internal'] (if the anchor exists)
        a = target_li.find("a", recursive=True)
        if a:
            # Determine whether original had 'reference'/'internal' to avoid inventing classes
            had_ref = "reference" in a.get("class", []) or "reference" in (a.get("class") or [])
            had_int = "internal" in a.get("class", []) or "internal" in (a.get("class") or [])
            # Default RTD anchors do have both; enforce desired order regardless
            ordered = ["current"]
            if had_ref or True:
                ordered.append("reference")
            if had_int or True:
                ordered.append("internal")
            set_exact_classes(a, ordered)

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

    # Retarget 'current' to the requested page with exact class ordering
    retarget_current(tgt_menu, current_href=args.current_href)

    out_path.write_text(str(in_soup), encoding="utf-8")
    print(f"✓ Sidebar updated and 'current' set to {args.current_href}: {out_path}")

if __name__ == "__main__":
    main()
