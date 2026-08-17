# Quickstart: Validating Full-Site Documentation Search

This is a documentation/CI-tooling feature (no `src/` MATLAB function under test — see
`spec.md` Traceability, "no-source" convention). Validation is a local reproduction of the
publish pipeline plus a scripted/manual check of the search widget, per Constitution
Principle III's "documented reproducibility check" substitute for an automated MATLAB test.

## Prerequisites

- Python 3.10 (matches `.github/workflows/build-and-publish-docs.yml`'s `setup-python`)
- From `documentation/`: `pip install -r requirements.txt` (installs Sphinx, the theme, and
  build extensions used by the real CI job)
- A local clone of a recent `gh-pages` publish (or the `cobratoolbox-gh-pages` working
  directory already available in this environment) to source existing tutorial HTML the same
  way the real CI job does, via its "Checkout gh-pages into temp dir" step

## Build the site locally, reproducing the CI job

Run the same sequence `build-and-publish-docs.yml` runs, in order, from `documentation/`:

```bash
python source/Citations/updateCitationsBib.py     # from documentation/source/Citations
make html                                          # first pass
python source/sphinxext/GenerateCitationsRST.py    # from documentation/source/sphinxext
python source/sphinxext/copy_files.py              # from documentation/source
python source/modules/GetRSTfiles.py               # from documentation/source/modules
make html                                          # second pass (functions/citations RST now present)
```

Then run the new search-index step this feature adds (see `data-model.md` for the entries
it must emit):

```bash
# Emit the tutorial supplement index from a staged tutorials directory
# (in the real pipeline this is ghpages/stable/tutorials, right after
# "Bring existing tutorials into staging"; locally, point it at any
# existing built tutorials tree, e.g. a checkout of the gh-pages branch)
python source/sphinxext/generateTutorialSearchIndex.py \
  --tutorials-dir <path-to-staged-or-existing-tutorials-html> \
  --out build/html/_static/json/tutorialsSearchIndex.json
```

Confirm the outputs exist:

```bash
test -f build/html/searchindex.js                          # Sphinx's own full-text index
test -f build/html/_static/json/tutorialsSearchIndex.json  # new tutorial supplement
```

Note: in the real CI pipeline, `searchindex.js` must be re-staged to `ghpages/stable/`
*after* the second `make html` pass (the one with function reference pages) — the earlier
"Stage core site to ghpages/stable" step runs before that pass and would otherwise leave a
stale, function-less index live on the published site. See the "Stage the full-text search
index" step in `build-and-publish-docs.yml` and research.md Decision 1.

## Serve and validate in a browser

```bash
python -m http.server --directory build/html 8000
```

Then, with the site open at `http://localhost:8000/`:

1. **US1 (broad search)** — type a phrase known to appear only in a non-function page (for
   example a sentence fragment from `installation.rst` or the FAQ). Confirm the search box
   shows that page as a result before pressing Enter, and that selecting it navigates to the
   correct page/section. Repeat with a phrase unique to a tutorial page (FR-008) — confirm a
   `tutorial`-kind result appears once the tutorial supplement index is present.
2. **US2 (function parity)** — type a known function name (e.g. one used in an existing
   tutorial or test). Confirm its reference page appears among the top results, matching
   today's `functions.json`-only behavior at minimum.
3. **Edge cases** — type a single character (confirm no unhelpfully large/noisy dump); type a
   query with no matches anywhere (confirm a clear empty state, not a blank box); type a query
   that matches both a function name and unrelated narrative content (confirm both appear and
   are visually distinguishable by `kind`).
4. **No unpublished leakage (FR-007)** — confirm nothing in `documentation/source/` that is
   excluded from the built `build/html/` (drafts, `.rst` sources not wired into any toctree,
   etc.) appears as a result.

## Validate the CI-integration requirement (US3 / FR-006 / FR-009 / SC-006)

Without needing a real GitHub Actions run:

1. Confirm the new tutorial-index step is present as an explicit step in
   `.github/workflows/build-and-publish-docs.yml`, positioned after the existing "Bring
   existing tutorials into staging" step (so it indexes the tutorial HTML that is actually
   about to be published, not stale local state).
2. Confirm the step's script exits non-zero on failure (e.g. missing/unreadable tutorials
   directory) rather than swallowing the error — this is what makes FR-009/SC-006 true: a
   broken search-index generation step fails the whole job instead of silently shipping a
   site with a missing/broken search bar.
3. Locally simulate a "content removed" publish: delete or rename a page's `.rst` source (or
   remove a tutorial subfolder from the local staged tutorials dir), rebuild per the steps
   above, and confirm the corresponding entry no longer appears in `searchindex.js` /
   `tutorialsSearchIndex.json`, and searching for that content returns no result (SC-005).

## Out of scope for this quickstart

- A real deploy to `gh-pages` — covered by the existing, unmodified deploy step; this feature
  changes what gets built and indexed, not how the built tree is published.
- Cross-browser UI testing — the widget rewiring (Decision 3 in `research.md`) is standard
  client-side JS; browser-matrix testing is not a stated requirement in `spec.md`.
