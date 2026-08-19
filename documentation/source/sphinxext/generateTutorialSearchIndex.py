"""Emit a supplemental full-site-search index entry for each tutorial page,
and install the current site-wide search box on every staged tutorial page.

Tutorials are carried over as pre-built HTML from the previous gh-pages deploy
rather than rebuilt from .rst sources on every publish (see
.github/workflows/build-and-publish-docs.yml, the "Bring existing tutorials
into staging" step), so they are absent from Sphinx's own generated
searchindex.js, AND they never receive template changes Sphinx makes to
other pages -- including the search box itself. This script does two things
in one pass over the staged tutorial HTML:

1. Indexing: writes a small JSON index in the shape
   documentation/source/_static/js/siteSearch.js expects for kind="tutorial"
   entries (see specs/019-full-site-search/data-model.md):

       [{"title": ..., "url": ..., "body_text": ..., "kind": "tutorial"}, ...]

2. Widget installation: replaces every page's `<div role="search">...</div>`
   (still the old, function-name-only easyAutocomplete widget on every
   tutorial page today) with the current site-wide search box, at the
   correct relative-path depth for that page.

Usage:
    python generateTutorialSearchIndex.py --tutorials-dir <path> --out <path>

Exits non-zero (with a clear message on stderr) if the tutorials directory is
missing/unreadable, if any staged page could be read but not patched, or if
the written index fails its own well-formedness check -- so the CI step that
runs this fails the whole publish job rather than shipping a site with a
silently broken, missing, or stale search bar (FR-009).
"""

import argparse
import json
import os
import re
import sys
from html.parser import HTMLParser

# Files that are not a tutorial's own primary content: thin iframe wrappers
# that just embed the real page, template/test scaffolding, and site-wide
# navigation listing pages -- indexing them would only add noise/duplicates.
# (These are still eligible for the search-box patch below -- that decision
# is separate from whether a page's own content is worth indexing.)
EXCLUDE_PREFIXES = ("iframe_", "holder_template", "test")
EXCLUDE_NAMES = {"index.html"}

# Cap on indexed body text per page. Measured against the real tutorial tree:
# median page is ~90 chars and the 90th percentile is ~38,000, but one
# MATLAB-Live-Script export (tutorial_mgPipe.html) contains 17.5 MILLION
# characters of visible text (large printed command-window output embedded
# in the export) -- indexing it in full would make every page on the site
# fetch a search index bloated by that one outlier. 50,000 was chosen from
# that measured distribution: it leaves the vast majority of real tutorials
# (median ~90 chars) fully indexed -- only 21 of 336 pages are still
# truncated, versus 114 of 336 at the previous 4,000-char cap -- while still
# bounding the pathological cases to a few hundred KB total, not tens of MB.
MAX_BODY_CHARS = 50000
TITLE_SUFFIX = " — The COBRA Toolbox"  # " — The COBRA Toolbox"

# The search-box markup this feature installs on every Sphinx-rendered page
# (see documentation/source/_templates/searchbox.html) -- kept in sync with
# that template. Tutorial pages are carried over as pre-built HTML rather
# than rendered by Sphinx each run, so nothing else ever gives them this
# widget; patch_search_box() below re-renders this block directly into every
# staged tutorial page, computing the right ../ prefix for that page's depth
# the same way Sphinx's own `pathto(..., 1)` would.
_SEARCH_BOX_RE = re.compile(r'<div role="search">.*?</div>', re.DOTALL)
_SEARCH_BOX_TEMPLATE = """<div role="search">
  <form id="rtd-search-form" class="wy-form" action="{prefix}search.html" method="get">
    <input type="text" name="q" placeholder="Search docs" id="simple" autocomplete="off"/>
    <input type="hidden" name="check_keywords" value="yes" />
    <input type="hidden" name="area" value="default" />
  </form>
  <link rel="stylesheet" href="{prefix}_static/css/siteSearch.css" type="text/css" />
  <script src="{prefix}_static/doctools.js"></script>
  <script src="{prefix}_static/searchtools.js"></script>
  <script src="{prefix}_static/language_data.js"></script>
  <script src="{prefix}_static/js/siteSearch.js"></script>
  <script>
    document.addEventListener("DOMContentLoaded", function () {{
      SiteSearch.init({{
        inputId: "simple",
        siteRoot: "{site_root}",
        searchIndexUrl: "{prefix}searchindex.js",
        tutorialsIndexUrl: "{prefix}_static/json/tutorialsSearchIndex.json"
      }});
    }});
  </script>
</div>"""


def patch_search_box(html, rel_url):
    """Replace a tutorial page's (old, function-name-only) search box with
    the current site-wide widget, at the correct relative-path depth for
    where this page lives.

    Returns (new_html, changed). changed is False when no `<div
    role="search">...</div>` block was found (e.g. the lone thin
    `iFrame_*.html` wrapper pages have no site chrome at all) -- that is a
    normal no-op, not an error.
    """
    depth = rel_url.count("/")
    prefix = "../" * depth
    site_root = prefix if depth else "./"
    replacement = _SEARCH_BOX_TEMPLATE.format(prefix=prefix, site_root=site_root)
    new_html, count = _SEARCH_BOX_RE.subn(replacement, html, count=1)
    return new_html, count > 0


class _TextExtractor(HTMLParser):
    """Minimal HTML -> (title, body text) extractor.

    Uses the standard-library parser rather than adding a new dependency
    (html5lib is already used elsewhere in this pipeline for a different,
    stricter purpose -- see UpdateSideBar.py -- but plain text extraction
    from already-valid, MATLAB-Live-Script-exported HTML does not need it).

    Tutorial pages are wrapped in the same site sidebar/navigation as every
    other page (via UpdateSideBar.py), inside
    ``<div role="main" ...><div itemprop="articleBody">``. body_text is
    scoped to that container so the index does not fill up with the same
    repeated nav/sidebar/footer boilerplate on every single tutorial entry.
    """

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.in_title = False
        self.in_skip = False
        self.title_parts = []
        self.h1_parts = []
        self.in_h1 = False
        self.all_parts = []  # fallback: every text node outside <title>/<script>/<style>
        self.article_parts = []  # scoped: only text inside the articleBody container
        self._article_depth = None  # None = outside; int = nesting depth once inside
        self._depth = 0

    def handle_starttag(self, tag, attrs):
        self._depth += 1
        if tag == "title":
            self.in_title = True
        elif tag == "h1":
            self.in_h1 = True
        elif tag in ("script", "style"):
            self.in_skip = True
        elif tag == "div" and self._article_depth is None:
            if dict(attrs).get("itemprop") == "articleBody":
                self._article_depth = self._depth

    def handle_endtag(self, tag):
        if tag == "title":
            self.in_title = False
        elif tag == "h1":
            self.in_h1 = False
        elif tag in ("script", "style"):
            self.in_skip = False
        if (
            self._article_depth is not None
            and tag == "div"
            and self._depth <= self._article_depth
        ):
            self._article_depth = None
        self._depth = max(0, self._depth - 1)

    def handle_data(self, data):
        if self.in_skip:
            return
        if self.in_title:
            self.title_parts.append(data)
            return
        if self.in_h1:
            self.h1_parts.append(data)
        self.all_parts.append(data)
        if self._article_depth is not None:
            self.article_parts.append(data)

    def title(self):
        raw = "".join(self.title_parts).strip()
        if raw.endswith(TITLE_SUFFIX):
            raw = raw[: -len(TITLE_SUFFIX)].strip()
        if raw:
            return raw
        h1 = "".join(self.h1_parts).strip()
        return h1 or None

    def body_text(self):
        # Prefer the text scoped to <div itemprop="articleBody"> (present on
        # every sidebar-templated page, tutorials included, via
        # UpdateSideBar.py) so the index holds each tutorial's own content
        # rather than the nav/sidebar/footer boilerplate repeated on every
        # page. Fall back to the whole page only if that container is
        # somehow absent, so a page is never indexed with an empty body.
        parts = self.article_parts if self.article_parts else self.all_parts
        text = " ".join(part.strip() for part in parts if part.strip())
        text = re.sub(r"\s+", " ", text).strip()
        return text[:MAX_BODY_CHARS]


def _should_index(filename):
    lower = filename.lower()
    if not lower.endswith(".html"):
        return False
    if filename in EXCLUDE_NAMES:
        return False
    return not lower.startswith(EXCLUDE_PREFIXES)


def build_index(tutorials_dir):
    """Walk every staged tutorial HTML file, patching each one's search box
    in place (patch_search_box) and, for pages worth indexing
    (_should_index), extracting a search entry from it.

    Patching runs over *every* .html file, independent of _should_index --
    a page can be excluded from the search index's content (e.g. the
    generic tutorials/index.html listing page) while still needing the
    current search widget installed, since visitors browse it directly.

    Returns (entries, patch_stats) where patch_stats is
    {"patched": int, "unchanged": int, "errors": [(path, message), ...]}.
    """
    if not os.path.isdir(tutorials_dir):
        raise SystemExit(
            "generateTutorialSearchIndex: tutorials directory not found or "
            "unreadable: %s" % tutorials_dir
        )

    entries = []
    patch_stats = {"patched": 0, "unchanged": 0, "errors": []}
    for root, _dirs, files in os.walk(tutorials_dir):
        for filename in sorted(files):
            if not filename.lower().endswith(".html"):
                continue
            full_path = os.path.join(root, filename)
            rel_path = os.path.relpath(full_path, os.path.dirname(tutorials_dir))
            rel_url = rel_path.replace(os.sep, "/")
            try:
                with open(full_path, encoding="utf-8", errors="replace") as fh:
                    html = fh.read()
            except OSError as exc:
                print(
                    "generateTutorialSearchIndex: skipping unreadable file "
                    "%s (%s)" % (full_path, exc),
                    file=sys.stderr,
                )
                patch_stats["errors"].append((full_path, str(exc)))
                continue

            patched_html, changed = patch_search_box(html, rel_url)
            if changed:
                try:
                    with open(full_path, "w", encoding="utf-8") as fh:
                        fh.write(patched_html)
                    patch_stats["patched"] += 1
                except OSError as exc:
                    print(
                        "generateTutorialSearchIndex: could not write patched "
                        "search box to %s (%s)" % (full_path, exc),
                        file=sys.stderr,
                    )
                    patch_stats["errors"].append((full_path, str(exc)))
            else:
                patch_stats["unchanged"] += 1

            if not _should_index(filename):
                continue

            parser = _TextExtractor()
            parser.feed(patched_html if changed else html)
            title = parser.title()
            if not title:
                continue
            entries.append(
                {
                    "title": title,
                    "url": rel_url,
                    "body_text": parser.body_text(),
                    "kind": "tutorial",
                }
            )
    return entries, patch_stats


def write_index(entries, out_path):
    out_dir = os.path.dirname(out_path)
    if out_dir:
        os.makedirs(out_dir, exist_ok=True)
    with open(out_path, "w", encoding="utf-8") as fh:
        json.dump(entries, fh)


def verify_index(out_path):
    """Well-formedness/coverage check: valid JSON, a list, non-empty.

    This is the narrowest automated check this documentation/CI-tooling
    feature can offer in place of a MATLAB test file (no src/ function is
    touched -- see specs/019-full-site-search/plan.md Technical Context). Run
    immediately after writing so a broken generator fails the CI step loudly
    (FR-009) instead of publishing a missing/broken search bar.
    """
    with open(out_path, encoding="utf-8") as fh:
        data = json.load(fh)
    if not isinstance(data, list):
        raise SystemExit(
            "generateTutorialSearchIndex: %s did not contain a JSON list" % out_path
        )
    if not data:
        raise SystemExit(
            "generateTutorialSearchIndex: %s contains zero tutorial entries "
            "-- refusing to publish an empty tutorial search index" % out_path
        )
    for entry in data:
        missing = [k for k in ("title", "url", "body_text", "kind") if k not in entry]
        if missing:
            raise SystemExit(
                "generateTutorialSearchIndex: entry missing field(s) %s: %r"
                % (missing, entry)
            )


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--tutorials-dir",
        required=True,
        help="Path to the staged tutorials directory (e.g. ghpages/stable/tutorials)",
    )
    parser.add_argument(
        "--out",
        required=True,
        help="Output path for the generated JSON index",
    )
    args = parser.parse_args()

    entries, patch_stats = build_index(args.tutorials_dir)
    write_index(entries, args.out)
    verify_index(args.out)
    print(
        "generateTutorialSearchIndex: wrote %d tutorial entries to %s"
        % (len(entries), args.out)
    )
    print(
        "generateTutorialSearchIndex: search box installed on %d page(s), "
        "already current on %d page(s)"
        % (patch_stats["patched"], patch_stats["unchanged"])
    )
    if patch_stats["errors"]:
        # A page we could read but failed to write back would silently keep
        # the old function-name-only widget -- fail loudly (FR-009) rather
        # than publish that inconsistently.
        for path, message in patch_stats["errors"]:
            print(
                "generateTutorialSearchIndex: FAILED to patch %s (%s)"
                % (path, message),
                file=sys.stderr,
            )
        raise SystemExit(
            "generateTutorialSearchIndex: %d file(s) could not be patched with "
            "the current search box; see errors above" % len(patch_stats["errors"])
        )


if __name__ == "__main__":
    main()
