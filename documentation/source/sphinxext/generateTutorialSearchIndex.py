"""Emit a supplemental full-site-search index entry for each tutorial page.

Tutorials are carried over as pre-built HTML from the previous gh-pages deploy
rather than rebuilt from .rst sources on every publish (see
.github/workflows/build-and-publish-docs.yml, the "Bring existing tutorials
into staging" step), so they are absent from Sphinx's own generated
searchindex.js. This script walks the staged tutorial HTML and writes a small
JSON index in the shape documentation/source/_static/js/siteSearch.js expects
for kind="tutorial" entries (see specs/019-full-site-search/data-model.md):

    [{"title": ..., "url": ..., "body_text": ..., "kind": "tutorial"}, ...]

Usage:
    python generateTutorialSearchIndex.py --tutorials-dir <path> --out <path>

Exits non-zero (with a clear message on stderr) if the tutorials directory is
missing/unreadable, or if the written index fails its own well-formedness
check -- so the CI step that runs this fails the whole publish job rather than
shipping a site with a silently broken or missing search bar (FR-009).
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
EXCLUDE_PREFIXES = ("iframe_", "holder_template", "test")
EXCLUDE_NAMES = {"index.html"}

MAX_BODY_CHARS = 4000
TITLE_SUFFIX = " — The COBRA Toolbox"  # " — The COBRA Toolbox"


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
    if not os.path.isdir(tutorials_dir):
        raise SystemExit(
            "generateTutorialSearchIndex: tutorials directory not found or "
            "unreadable: %s" % tutorials_dir
        )

    entries = []
    for root, _dirs, files in os.walk(tutorials_dir):
        for filename in sorted(files):
            if not _should_index(filename):
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
                continue

            parser = _TextExtractor()
            parser.feed(html)
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
    return entries


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

    entries = build_index(args.tutorials_dir)
    write_index(entries, args.out)
    verify_index(args.out)
    print(
        "generateTutorialSearchIndex: wrote %d tutorial entries to %s"
        % (len(entries), args.out)
    )


if __name__ == "__main__":
    main()
