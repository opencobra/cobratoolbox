#!/usr/bin/env python3
"""
Update only the left sidebar menu of contributorsTemp.html from contents.rst.

Paths (relative to this script):
- contents:        ../contents.rst
- target html:     ./contributorsTemp.html

Behaviour:
- Parses the toctree in contents.rst
- Derives hrefs (adds ".html" when the entry has no extension)
- Tries to read the target page's <title> to use as the label
- Falls back to a sensible label mapping or Title Case of the slug
- Replaces only the inner HTML of <div class="wy-menu wy-menu-vertical"> … </div>
"""

from pathlib import Path
import re
from bs4 import BeautifulSoup

# --- Paths ---------------------------------------------------------------

SCRIPT_DIR = Path(__file__).resolve().parent
ROOT = SCRIPT_DIR.parent  # documentation/source
CONTENTS_RST = ROOT / "contents.rst"
TARGET_HTML = SCRIPT_DIR / "contributorsTemp.html"

# If your built/static HTMLs live elsewhere, add extra search roots here
# (relative to this script). These are used to try to read <title> tags.
HTML_SEARCH_ROOTS = [
    SCRIPT_DIR,             # ./Contributions
    ROOT,                   # ../
    ROOT.parent,            # documentation/
]

# --- Parsing contents.rst ------------------------------------------------

def parse_toctree_entries(rst_path: Path):
    """
    Extract the list of document entries from the toctree in contents.rst.
    Ignores option lines (those starting with ':') and blank lines.
    """
    text = rst_path.read_text(encoding="utf-8")
    # Find the first toctree block
    m = re.search(r"^\.\.\s+toctree::.*?(?:\n[ \t].*)+", text, re.MULTILINE | re.DOTALL)
    if not m:
        raise RuntimeError("Could not find a '.. toctree::' block in contents.rst")
    block = m.group(0)

    entries = []
    for line in block.splitlines()[1:]:
        # Keep only indented content lines
        if not line.strip():
            continue
        if line.lstrip() == line:
            # not indented
            continue
        stripped = line.strip()
        if stripped.startswith(":"):
            # option line like :maxdepth:
            continue
        # Support the 'Title <path>' syntax if ever used
        if "<" in stripped and stripped.endswith(">"):
            # e.g., "Nice Title <path/to/page>"
            title_part, path_part = stripped.split("<", 1)
            title_part = title_part.strip()
            path_part = path_part[:-1].strip()
            entries.append((path_part, title_part))
        else:
            entries.append((stripped, None))
    return entries

# --- Href + label helpers ------------------------------------------------

def to_href(doc: str) -> str:
    """
    Convert a toctree target to a relative href:
    - keep .html targets as is
    - if target ends with '/index' or 'index', append '.html'
    - otherwise append '.html'
    Examples:
      'installation'            -> 'installation.html'
      'modules/index'           -> 'modules/index.html'
      'index.html'              -> 'index.html'
    """
    if doc.endswith(".html"):
        return doc
    return f"{doc}.html"

# Preferred pretty labels when we cannot read a page title
FALLBACK_LABELS = {
    "index": "Home",
    "index.html": "Home",
    "installation": "Installation",
    "modules/index": "Functions",
    "tutorials/index": "Tutorials",
    "contributing": "How to contribute",
    "cite": "How to cite",
    "support": "Support",
    "faq": "FAQ",
    "contributors": "Contributors",
    "funding": "Funding",
    "plan": "Development Plan",
    "lifecycle": "Lifecycle",
    "contact": "Contact",
    "citations": "Citations",
}

def slug_label_fallback(slug: str) -> str:
    key = slug.rstrip(".html")
    if key in FALLBACK_LABELS:
        return FALLBACK_LABELS[key]
    # Last path component, dash/underscore to space, title case
    last = key.split("/")[-1]
    nice = re.sub(r"[-_]+", " ", last).strip().title()
    return nice or key

def try_read_title_from_html(href: str) -> str | None:
    """
    Try to read the <title> from the first matching HTML found under HTML_SEARCH_ROOTS.
    Returns None if not found or unreadable.
    """
    for root in HTML_SEARCH_ROOTS:
        candidate = (root / href).resolve()
        if candidate.exists() and candidate.is_file():
            try:
                html = candidate.read_text(encoding="utf-8", errors="ignore")
                soup = BeautifulSoup(html, "lxml")
                if soup.title and soup.title.string:
                    # Strip common site suffix, keep the left part
                    title_text = soup.title.string.strip()
                    # Optional: split on ' — ' or ' | ' to get the page label
                    parts = re.split(r"\s+[–—|-]\s+|\s+&mdash;\s+", title_text)
                    return parts[0].strip() if parts else title_text
            except Exception:
                pass
    return None

# --- HTML update ---------------------------------------------------------

def build_sidebar_ul(items: list[tuple[str, str]]) -> str:
    """
    Build an HTML <ul> with the Sphinx RTD classes from (href, label) pairs.
    Returns a string (inner HTML for the menu container).
    """
    li_parts = []
    for href, label in items:
        li_parts.append(
            f'<li class="toctree-l1"><a class="reference internal" href="{href}">{label}</a></li>'
        )
    ul_html = '<ul class="current">\n' + "\n".join(li_parts) + "\n</ul>\n"
    return ul_html

def replace_sidebar_only(html_path: Path, new_sidebar_inner_html: str):
    """
    Parse the target HTML and replace ONLY the inner HTML of
    <div class="wy-menu wy-menu-vertical" ...> ... </div>.
    """
    html = html_path.read_text(encoding="utf-8")
    soup = BeautifulSoup(html, "lxml")

    menu_div = soup.select_one("div.wy-menu.wy-menu-vertical")
    if not menu_div:
        raise RuntimeError("Could not find <div class='wy-menu wy-menu-vertical'> in target HTML")

    # Replace existing children with the new UL
    # We replace its entire inner content while keeping the div node and attributes
    menu_div.clear()
    # Insert as raw HTML to preserve classes and spacing
    new_fragment = BeautifulSoup(new_sidebar_inner_html, "lxml")
    for child in list(new_fragment.body or []):
        # Guard for parsers that wrap in <body>
        for sub in child.children if child.name == "body" else [child]:
            menu_div.append(sub if sub.name else sub)

    html_path.write_text(str(soup), encoding="utf-8")

# --- Main ----------------------------------------------------------------

def main():
    # 1) Parse contents.rst
    entries = parse_toctree_entries(CONTENTS_RST)  # list of (doc, optional_title)

    # 2) Build (href, label) pairs
    items: list[tuple[str, str]] = []
    for doc, explicit_title in entries:
        href = to_href(doc)
        if explicit_title:  # from 'Title <path>'
            label = explicit_title
        else:
            label = try_read_title_from_html(href) or slug_label_fallback(doc)
        items.append((href, label))

    # 3) Build the sidebar HTML
    sidebar_html = build_sidebar_ul(items)

    # 4) Replace only the sidebar in the target HTML
    replace_sidebar_only(TARGET_HTML, sidebar_html)

    print(f"Updated sidebar in: {TARGET_HTML}")

if __name__ == "__main__":
    main()
