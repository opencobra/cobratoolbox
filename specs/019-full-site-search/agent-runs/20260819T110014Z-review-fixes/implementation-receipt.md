# Implementation Receipt

## Prompt

Follow-up to the completed feature 019 (full-site documentation search),
triggered by two AI-reviewer comments (`chatgpt-codex-connector`) on the
implementation PR:

1. P2: "Install the full-site widget on static pages" — the search-box
   template override only affects Sphinx-rendered pages; `citations.html`,
   `contributorsTemp.html`, and carried-over tutorial pages still initialize
   the old `easyAutocomplete`/`functions.json` widget, since
   `UpdateSideBar.py` only replaces the nav-menu div, not the search box.
2. P2: "Index the complete tutorial text" — the 4,000-character cap on
   indexed tutorial body text truncates the vast majority of tutorial pages
   (91 of 96 in the reviewer's run), so later-occurring terms are never
   searchable.

The user asked for my assessment of both comments' validity, then said "yes
implement both" once I'd verified each against the actual codebase and
proposed concrete fixes.

## Final response

Both fixes are implemented and verified in-browser.

**Comment 1 (partially valid, as I'd assessed — confirmed and fixed for the
two real cases, not `citations.html`)**: extended
`documentation/source/sphinxext/generateTutorialSearchIndex.py` to patch
`<div role="search">...</div>` in *every* staged tutorial HTML page (not
just the ones it indexes) with the current site-wide widget, rendered at the
correct relative-path depth for that page — reusing the same template
`documentation/source/_templates/searchbox.html` renders. Verified: 219 of
336 real tutorial pages had an old widget and got patched; the rest (mostly
raw, un-templated MATLAB Live Script exports with no site chrome at all)
were correctly left alone; zero `easyAutocomplete`/`functions.json`
references remain afterward. Extended
`documentation/source/Contributions/UpdateSideBar.py` (already invoked for
`contributorsTemp.html` and the two tutorials index/holder pages) to also
rebuild the search box at its existing `--href-prefix`, alongside the
nav-menu sync it already did. No CI workflow changes were needed — both
fixes live inside scripts the pipeline already calls.

I verified `citations.html` specifically is *not* actually affected — I
traced the "Copy the citations html page" step, which refreshes it from the
just-completed build (searchbox override included) before staging, so I
left that page alone rather than "fixing" something that wasn't broken.

**Comment 2 (valid, confirmed by measurement)**: re-ran the generator
uncapped against the real tutorial corpus and found the true distribution —
median tutorial is ~90 chars, 90th percentile is ~37,600, but one page
(`tutorial_mgPipe.html`, a 24MB Live Script export) has 17.5 million
characters of text, so naively removing the cap would balloon the payload
every page fetches. Raised `MAX_BODY_CHARS` from 4,000 to 50,000 — this
data-driven choice cuts truncated pages from 114/336 to 21/336 while keeping
the indexed payload in the low single-digit MB range rather than tens of MB.

Both changes are verified end-to-end in-browser (Chrome DevTools Protocol):
searching from an actual patched tutorial page and from a
`contributorsTemp.html`-derived page both return correct, ranked results
(function, doc, and tutorial kinds), matching behavior already verified on
ordinary Sphinx-rendered pages.

These changes are uncommitted on the `019-full-site-search` branch, on top
of the existing feature commit — let me know if you'd like them committed
now or reviewed first.

## Diff summary

```
 documentation/source/Contributions/UpdateSideBar.py           |  67 +++++++++
 documentation/source/sphinxext/generateTutorialSearchIndex.py | 150 +++++++++++++++++++--
 2 files changed, 204 insertions(+), 13 deletions(-)
```

- `documentation/source/Contributions/UpdateSideBar.py`: added
  `_SEARCH_BOX_INNER_TEMPLATE`, `get_search_div()`, `rebuild_search_box()`;
  wired into `main()` after the existing menu sync.
- `documentation/source/sphinxext/generateTutorialSearchIndex.py`: raised
  `MAX_BODY_CHARS` 4,000 → 50,000 (with the measured-distribution rationale
  recorded in a comment); added `_SEARCH_BOX_TEMPLATE`/`patch_search_box()`;
  `build_index()` now walks every `.html` file (not just indexable ones) to
  patch each one's search box, separately from the indexing decision;
  `main()` reports patch counts and fails loudly (`SystemExit`) if any file
  could be read but not written back.

No `.github/workflows/build-and-publish-docs.yml` change — both fixes live
inside the two scripts the pipeline already invokes at existing steps. No
`src/`, `test/`, or other MATLAB file touched.

## Tests

No `src/` MATLAB function is touched (same "no-source" convention as the
rest of feature 019). Verification performed:

- `python3 -c "import ast; ast.parse(...)"` on both modified files — PASS.
- `generateTutorialSearchIndex.py` run against a scratch copy of the real
  tutorial corpus (`/home/farid/Projects/cobratoolbox-gh-pages/stable/tutorials`,
  336 files): 219 patched, 121 left unchanged (no search box present),
  0 errors, exit 0. Post-run grep for `easyAutocomplete`/`functions.json`
  across the patched tree — 0 matches (confirms no old-widget markup
  survived). `diff` against the original `practica_FBA.html` confirms only
  the search-box region changed, nothing else in the page.
- `UpdateSideBar.py` run against scratch copies of `contributorsTemp.html`
  (prefix `""`) and `tutorials/index.html` (prefix `"../"`), using
  `build/html/index.html` as `--source`, matching the real CI invocations
  exactly — both produced correctly depth-prefixed search-box markup, exit
  0 both times.
- In-browser verification (Chrome DevTools Protocol) from a patched tutorial
  page (`practica_FBA.html`) and from a `contributorsTemp.html`-derived
  page: function search (`optimizeCbModel`), broad search (`Frequently` →
  FAQ), and tutorial search (`Flux Balance Analysis variants` → the
  FBA_variants tutorial, ranked among function/doc results) all return
  correct, expected results from both page types — matching behavior
  already established for ordinary Sphinx pages in the original
  implementation run.
- Truncation-cap claim measured directly: uncapped run against the real
  corpus showed median 90 chars / p90 ~37,600 / one 17.5M-char outlier;
  recomputed truncation counts at several candidate caps (4,000: 114/336
  truncated; 20,000: 54/336; 50,000: 21/336; 100,000: 10/336) to choose
  50,000 as a measured, justified middle ground rather than a guess.

No tests failed.

## Unresolved issues

- `citations.html` was investigated and found not to need a fix (the
  existing pipeline already refreshes it before staging) — noted here in
  case that reasoning should be revisited if the citations-generation step
  ever changes.
- The one MATLAB Live Script export whose text is genuinely ~17.5 million
  characters (`tutorial_mgPipe.html`) is still truncated at 50,000 chars, by
  design — searching for a term that only appears very late in that specific
  page's content will not find it. This is an explicit, measured trade-off
  against payload size, not an oversight.
- These two fixes have not yet been run through the actual GitHub Actions
  pipeline (no runner available here) — verified via direct invocation of
  both scripts with the same arguments the workflow uses, and via a
  from-scratch in-browser check, but not a full live CI run.
