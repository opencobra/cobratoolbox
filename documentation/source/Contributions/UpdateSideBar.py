#!/usr/bin/env python3
"""
Copy the left sidebar menu from a built Sphinx page (index.html) into a target
HTML (e.g. contributorsTemp.html or tutorials/index.html), then:

- ensure the first "Home" block points to the desired home href
- mark a specific menu item as the 'current' page (with class order preserved)
- optionally rebase all relative sidebar hrefs with a prefix (e.g. '../')

Usage examples:

# Contributors page (at site root alongside index.html)
python UpdateContributorsTemplate.py \
  --source ./build/html/index.html \
  --input  ./source/Contributions/contributorsTemp.html \
  --output ./source/Contributions/contributorsTemp.html \
  --current-href contributors.html \
  --home-href index.html \
  --parser html5lib

# Tutorials index (lives in a subfolder, needs '../' prefix)
python UpdateContributorsTemplate.py \
  --source ./build/html/index.html \
  --input  ./source/tutorials/index.html \
  --output ./source/tutorials/index.html \
  --current-href tutorials/index.html \
  --home-href ../index.html \
  --href-prefix ../ \
  --parser html5lib
"""

from __future__ import annotations
import argparse
from pathlib import Path
from bs4 import BeautifulSoup

def parse_args():
    ap = argparse.ArgumentParser(description="Replace sidebar and set 'current' to a target href")
    ap.add_argument("--source", required=True, help="Path to built HTML with the correct sidebar (build/html/index.html)")
    ap.add_argument("--input", required=True, help="Path to target HTML to modify")
    ap.add_argument("--output", required=True, help="Path to write the updated HTML (can be same as --input)")
    ap.add_argument("--current-href", default="contributors.html", help="Href that should be marked as current")
    ap.add_argument("--home-href", default="index.html", help="Href to use for the Home link in the first UL")
    ap.add_argument("--href-prefix", default="", help="Prefix to add to *relative* sidebar hrefs (e.g. '../')")
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

def is_relative_href(href: str) -> bool:
    if not href:
        return False
    href = href.strip()
    if href.startswith("#"):
        return False
    if "://" in href:
        return False
    if href.startswith("/"):
        return False
    if href.startswith("../") or href.startswith("./"):
        return False
    return True

def rebase_sidebar_hrefs(menu_div, prefix: str):
    """
    Add `prefix` to all *relative* sidebar links so that links still point to the site root
    when the sidebar is embedded in a subfolder page (e.g. tutorials/index.html).
    """
    prefix = (prefix or "").strip()
    if not prefix:
        return
    for a in menu_div.find_all("a"):
        href = a.get("href")
        if is_relative_href(href):
            a["href"] = prefix + href

def ensure_home_block(menu_div, home_href: str):
    """
    Ensure the first UL (Home block) has class='current' and its link points to home_href.
    """
    first_ul = menu_div.find("ul", recursive=False)
    if not first_ul:
        return
    # Make sure the first UL has class 'current'
    ul_classes = list(first_ul.get("class", []))
    if "current" not in ul_classes:
        ul_classes.append("current")
        first_ul["class"] = ul_classes

    # Fix the Home link to point to home_href (index.html or ../index.html)
    first_li = first_ul.find("li", recursive=False)
    if first_li:
        a = first_li.find("a", recursive=True)
        if a:
            a["href"] = home_href

def href_matches(a_tag, target_href: str) -> bool:
    href = (a_tag.get("href") or "").strip()
    if not href:
        return False
    # Exact match or trailing match (e.g. 'tutorials/index.html' vs '/.../tutorials/index.html')
    return href == target_href or href.endswith("/" + target_href)

def set_exact_classes(tag, classes_in_order):
    """
    Overwrite a tag's class attribute with exactly the provided list, preserving order.
    """
    tag["class"] = list(classes_in_order)

def retarget_current(menu_div, current_href: str):
    """
    Ensure:
      - the UL that contains current_href has class 'current'
      - the LI for current_href has class exactly 'toctree-l1 current' (in that order)
      - the A for current_href has class exactly 'current reference internal' (in that order)
      - remove 'current' from other LIs/As
    """
    # Consider only direct UL children of the menu
    uls = menu_div.find_all("ul", recursive=False)

    target_li = None
    target_ul = None

    # First pass: locate target and clear stale 'current' from all li/a
    for ul in uls:
        for li in ul.find_all("li", recursive=False):
            # Strip any 'current' on non-targets
            li_classes = [c for c in li.get("class", []) if c != "current"]
            # Normalise 'toctree-l1' position if present
            if "toctree-l1" in li_classes:
                li_classes = ["toctree-l1"] + [c for c in li_classes if c != "toctree-l1"]
            if li_classes:
                li["class"] = li_classes
            elif "class" in li.attrs:
                del li["class"]

            a = li.find("a", recursive=True)
            if a:
                a_classes = [c for c in a.get("class", []) if c != "current"]
                if a_classes:
                    a["class"] = a_classes
                elif "class" in a.attrs:
                    del a["class"]

                # Check match for current target
                if href_matches(a, current_href):
                    target_li = li
                    target_ul = ul

    # If we found the target, set exact classes (with required order)
    if target_li and target_ul:
        # Ensure UL has 'current' (but do not wipe other classes)
        ul_classes = list(target_ul.get("class", []))
        if "current" not in ul_classes:
            ul_classes.append("current")
            target_ul["class"] = ul_classes

        # Set LI classes in exact order: 'toctree-l1 current'
        set_exact_classes(target_li, ["toctree-l1", "current"])

        # Set A classes in exact order: 'current reference internal'
        a = target_li.find("a", recursive=True)
        if a:
            set_exact_classes(a, ["current", "reference", "internal"])

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

    # Copy the menu contents from source to target
    new_inner = src_menu.decode_contents()
    replace_inner_html(tgt_menu, new_inner, args.parser)

    # Optionally rebase sidebar hrefs (e.g. prefix '../' for subfolder pages)
    rebase_sidebar_hrefs(tgt_menu, prefix=args.href_prefix)

    # Fix first UL (Home block) and its link
    ensure_home_block(tgt_menu, home_href=args.home_href)

    # Retarget 'current' to the requested page
    retarget_current(tgt_menu, current_href=args.current_href)

    # Write out without prettify to avoid reformatting
    out_path.write_text(str(in_soup), encoding="utf-8")
    print(f"✓ Sidebar updated, links rebased ('{args.href_prefix}'), and 'current' set to {args.current_href}: {out_path}")

if __name__ == "__main__":
    main()
