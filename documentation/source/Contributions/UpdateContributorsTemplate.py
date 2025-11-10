#!/usr/bin/env python3
"""
Copy the left sidebar menu from a built Sphinx page (index.html) into
contributorsTemp.html, then mark 'contributors.html' as the current page.

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
    ap.add_argument("--parser", default="html5lib", choices=["html5lib", "lxml", "html.parser"],
                    help="BeautifulSoup parser to use (default: html5lib)")
    ap.add_argument("--current-href", default="contributors.html",
                    help="Href of the page that should be marked as current in the sidebar")
    return ap.parse_args()

def get_menu_div(soup: BeautifulSoup):
    return soup.select_one("div.wy-menu.wy-menu-vertical")

def replace_inner_html(target_div, new_inner_html: str, parser: str):
    target_div.clear()
    fragment = BeautifulSoup(new_inner_html, parser)
    parents = fragment.body.contents if fragment.body else fragment.contents
    for child in list(parents):
        target_div.append(child)

def retarget_current(menu_div, current_href: str):
    """
    Make the item whose <a href="..."> equals current_href the 'current' entry,
    and move it into a leading <ul class="current"> like Sphinx does.
    Also fix any <a href="#"> (from index being current) back to their real file.
    """
    if menu_div is None:
        return

    # Collect all top-level li items
    items = menu_div.select("> ul > li.toctree-l1")
    if not items:
        # Some builds have two ULs already; flatten by collecting all level-1 LIs
        items = menu_div.select("li.toctree-l1")

    if not items:
        return

    # Helper to ensure a list of classes on Tag
    def cls_list(tag):
        c = tag.get("class", [])
        return list(c) if isinstance(c, list) else [c]

    # Build new ULs like Sphinx: one 'current' UL, one normal UL
    new_ul_current = menu_div.new_tag("ul")
    new_ul_current["class"] = ["current"]
    new_ul_rest = menu_div.new_tag("ul")

    target_li = None

    for li in items:
        a = li.find("a", href=True)
        if not a:
            continue

        # If this is leftover from index current, fix '#' back to 'index.html'
        if a.get("href") == "#":
            # Heuristic: if anchor text is 'Home', restore index.html
            if (a.string or "").strip().lower() == "home":
                a["href"] = "index.html"

        # Strip any previous 'current' classes
        li_classes = [c for c in cls_list(li) if c != "current"]
        a_classes = [c for c in cls_list(a) if c != "current"]
        li["class"] = li_classes or ["toctree-l1"]
        a["class"] = a_classes or ["reference", "internal"]

        # Route to the appropriate UL
        if a.get("href") == current_href:
            target_li = li
        else:
            new_ul_rest.append(li)

    # If we found the target, make it current and set href to '#'
    if target_li:
        a = target_li.find("a", href=True)
        if a:
            # Mark current
            li_classes = cls_list(target_li)
            if "current" not in li_classes:
                li_classes.append("current")
            target_li["class"] = li_classes

            a_classes = cls_list(a)
            if "current" not in a_classes:
                a_classes.insert(0, "current")
            a["class"] = a_classes

            # Current page usually has '#'
            a["href"] = "#"

        new_ul_current.append(target_li)

        # Replace the menu content with the two ULs. Keep order: current first, then the rest.
        menu_div.clear()
        menu_div.append(new_ul_current)
        # Only append the rest UL if it has items
        if new_ul_rest.find("li"):
            menu_div.append(new_ul_rest)
    else:
        # No target found; leave as is
        pass

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

    # Copy the sidebar HTML
    new_inner = src_menu.decode_contents()
    replace_inner_html(tgt_menu, new_inner, args.parser)

    # Retarget the 'current' highlight to contributors
    retarget_current(tgt_menu, current_href=args.current_href)

    # Write out without prettify to avoid reformatting or truncation
    out_path.write_text(str(in_soup), encoding="utf-8")
    print(f"✓ Sidebar updated and current set to '{args.current_href}' in: {out_path}")

if __name__ == "__main__":
    main()
