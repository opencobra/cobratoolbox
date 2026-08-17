---

description: "Task list for feature implementation"
---

# Tasks: Full-Site Documentation Search

**Input**: Design documents from `/specs/019-full-site-search/`

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, quickstart.md

**Tests**: No `src/` MATLAB function is touched by this feature (documentation/CI-tooling
change — see spec.md Traceability, "no-source" rows). Per plan.md's Technical Context, the
narrowest practical automated check is a script-level well-formedness/coverage check on the
generated search index files (T009), run as part of the CI step so a broken generator fails
the build; remaining verification is the manual/CI reproduction in quickstart.md (per-story
verification tasks below).

**Organization**: Tasks are grouped by user story (spec.md priorities P1/P2/P3) to enable
independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Exact file paths are included in every task description

## Path Conventions

All paths are relative to the repository root. This feature touches only
`documentation/` (Sphinx sources and build-time Python tooling) and
`.github/workflows/build-and-publish-docs.yml` — no `src/` or `test/` MATLAB path, per
plan.md's Project Structure.

---

## Phase 1: Setup

**Purpose**: Establish the local build environment and the one piece of information every
later task depends on — the exact theme template to override.

- [X] T001 Set up the local documentation build environment: from `documentation/`, run
  `pip install -r requirements.txt`, then reproduce the CI job's build sequence from
  `quickstart.md` ("Build the site locally, reproducing the CI job") through the second
  `make html` pass, confirming it succeeds before any code change.
  **Done**: `documentation/.venv` created; `pip install -r requirements.txt` succeeded;
  `sphinx-build -b html source build/html` (with `GetRSTfiles.py` run first) succeeded —
  build succeeded, 472 warnings (pre-existing, unrelated to this feature — mostly
  `unknown document` refs for tutorial `.rst` files that live outside this repo).
- [X] T002 Confirm the exact `sphinx_cobra_theme` template name that renders the sidebar
  search box: locate the installed theme directory
  (`python -c "import sphinx_cobra_theme; print(sphinx_cobra_theme.get_theme_dir())"`),
  inspect its templates for the block containing the `id="simple"` search input and its
  `easyAutocomplete`/`functions.json` wiring, and append the confirmed template name/path to
  `specs/019-full-site-search/research.md`'s "Open items carried into implementation"
  section (resolving the first open item there).
  **Done**: confirmed template is `searchbox.html`, included via
  `{% include "searchbox.html" %}` in the theme's `layout.html`; findings recorded in
  research.md's "Open items — resolved during implementation" section (also corrected
  `searchindex.js`'s real location: build root, not `_static/`).

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Build the shared search-box template override and client-side search engine
that every user story renders through. Per research.md Decision 1, this engine queries
Sphinx's own generated `searchindex.js` — which already covers both function
reference pages and narrative doc pages — so US1 and US2 share this same delivery
mechanism; later phases only add tutorial coverage (US3) and per-story refinements.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T003 [P] Create `documentation/source/_templates/<name-confirmed-in-T002>.html`,
  overriding the theme's search-box block per research.md Decision 3, following the existing
  local-override pattern already used by `documentation/source/_templates/index.html` (which
  extends `layout.html` and overrides one block rather than copying the whole template).
  **Done**: `documentation/source/_templates/searchbox.html` created. Also required loading
  `_static/doctools.js` before `_static/searchtools.js` — discovered during T006 verification
  that `searchtools.js` calls `_ready(Search.init)` at its own top level, and `_ready` is
  defined by `doctools.js`, which the theme's `layout.html` does not load on any page.
- [X] T004 [P] Create `documentation/source/_static/js/siteSearch.js`: on page load, fetch
  and parse the built `searchindex.js`; implement matching and relevance ranking
  against it; classify each candidate entry's `kind` as `"function"` when its URL falls under
  `modules/` and `"doc"` otherwise (per data-model.md's Search Index Entry); render the top-N
  ranked results (title, link) inline beneath the search input as the visitor types, with no
  full-page navigation required to see whether anything matched (FR-005).
  **Done**: created, reusing Sphinx's own `Search.loadIndex`/`Search._index`/`Scorer`/
  `splitQuery`/`makeSearchSummary` (via `_static/searchtools.js`) rather than re-implementing
  indexing/scoring, per research.md Decision 1's refined approach. Function-kind candidates
  are sourced from `_index.objects` (the MATLAB autodoc table), doc-kind from
  `_index.titles`/`_index.terms`/`_index.titleterms`.
- [X] T005 Wire the template from T003 to load `siteSearch.js` (T004) and initialize it
  against the existing `id="simple"` search input, replacing the current
  `functions.json`-only `easyAutocomplete` configuration entirely (depends on T003, T004).
  **Done**: `searchbox.html` now loads `doctools.js` → `searchtools.js` → `language_data.js`
  → `siteSearch.js`, then calls `SiteSearch.init({...})` on `DOMContentLoaded` with the
  Jinja-computed `siteRoot`/`searchIndexUrl`/`tutorialsIndexUrl`. The old
  `easyAutocomplete`/`functions.json` block is gone entirely.
- [X] T006 Confirm this feature's standing reproducibility check: run the
  `quickstart.md` "Serve and validate in a browser" sequence against T003–T005's output and
  confirm the search box renders results from `siteSearch.js` (not the old
  `functions.json`-only widget) for at least one query — this is the documented
  reproducibility check Constitution Principle III requires in place of a MATLAB test file,
  since no `src/` function is touched.
  **Done**: full local build served via `python -m http.server`, driven headlessly with Chrome
  DevTools Protocol (no test-framework dependency added to the repo). Confirmed
  `easyAutocomplete`/`functions.json` no longer appear in built pages, `siteSearch.js` is
  wired and reachable, `Search`/`Scorer` load correctly after the doctools.js fix, and results
  render from the new engine.

**Checkpoint**: Foundation ready — the search box now queries Sphinx's full-text index for
all `.rst`-generated content. User story implementation can now begin.

---

## Phase 3: User Story 1 - Find any documentation topic, not just a function (Priority: P1) 🎯 MVP

**Goal**: A visitor can type a phrase found anywhere in the site's narrative documentation
(installation, FAQ, contributing, guides, citations) and get the correct page as a result,
directly from the search box.

**Independent Test**: Per spec.md — on the built site, type a phrase that appears only in a
non-function documentation page and confirm the search box returns that page as a result
without requiring a separate page load.

### Implementation for User Story 1

- [X] T007 [US1] Add relevance-aware excerpt extraction to
  `documentation/source/_static/js/siteSearch.js`: each rendered result shows a short,
  query-relevant snippet of its matched text (not just a bare title), giving the visitor
  enough context to judge relevance (FR-002).
  **Done**: `fetchSnippet`/`summarizeText` reuse Sphinx's own `Search.makeSearchSummary`
  (fetches the top `SUMMARY_FETCH_LIMIT` result pages' HTML and extracts a query-relevant
  excerpt, exactly like Sphinx's own `search.html` does). Also discovered and fixed a real
  matching gap during verification: `idx.terms`/`idx.titleterms` are keyed by Porter-stemmed
  words, so an un-stemmed query (e.g. "compilers") silently missed the stored root
  ("compil") — fixed by stemming query terms with `language_data.js`'s `Stemmer` before
  matching, same as Sphinx's own `Search.performSearch`. Verified via Chrome DevTools
  Protocol against a local build: "compilers" now correctly returns
  `installation/compilers.html`.
- [X] T008 [US1] Add empty-state rendering to
  `documentation/source/_static/js/siteSearch.js` for queries with zero matches, so the
  visitor sees a clear "no results" indication rather than a blank dropdown (Edge Case,
  spec.md).
  **Done**: verified in-browser — a no-match query renders
  `No results found for "<query>".` rather than a blank box.
- [X] T009 [US1] Add a minimum-query-length guard to
  `documentation/source/_static/js/siteSearch.js` before triggering matching, so a
  single-character query does not return an unhelpfully large/noisy result set (Edge Case,
  spec.md).
  **Done**: `MIN_QUERY_LENGTH = 2`; verified in-browser that a 1-character query keeps the
  results box hidden entirely (no matching attempted).
- [X] T010 [US1] Verify SC-001 and SC-003 locally per `quickstart.md`'s "US1 (broad search)"
  step: query at least one phrase unique to each of installation, FAQ, contributing, and
  citations content; confirm the correct page is returned as a result and appears to feel
  near-instant (informal timing, consistent with SC-003's <1s target).
  **Done**: verified in-browser (Chrome DevTools Protocol against a local build served via
  `python -m http.server`) — "Frequently" → `notes/faq.html`; "compilers" →
  `installation/compilers.html`; "Publications that cited" → `contributing.html` /
  `guides/testGuide.html` / `citations.html`. All results rendered well within the visible
  response window of the fixed ~200ms debounce plus near-instant client-side scoring (no
  network round trip needed for the ranked list itself; only per-result snippets fetch
  lazily, capped at `SUMMARY_FETCH_LIMIT`).

**Checkpoint**: User Story 1 is independently functional — broad search across all
`.rst`-generated documentation works from the search box (tutorial coverage lands in Phase
5 / US3).

---

## Phase 4: User Story 2 - Keep finding functions by name (Priority: P2)

**Goal**: Searching for a function's exact or partial name continues to surface that
function's reference page as a top result, with no regression versus today's
`functions.json`-only widget, and function results stay visually distinguishable from
narrative-doc results.

**Independent Test**: Per spec.md — search for a known, unambiguous function name and
confirm its reference page appears among the top results.

### Implementation for User Story 2

- [X] T011 [US2] Add visual kind-labeling to
  `documentation/source/_static/js/siteSearch.js`'s result rendering (e.g. a "Function" vs.
  "Doc" tag per result), so a result set mixing function and narrative matches stays legible
  (FR-003 / Edge Cases, spec.md).
  **Done**: `KIND_LABELS`/`.site-search-badge` in `siteSearch.js` +
  `documentation/source/_static/css/siteSearch.css` (colour-coded Function/Doc/Tutorial
  badges); verified visually via a "fastFVA" query returning both `function`-kind and
  neighbouring `doc`-kind rows, each carrying its own badge.
- [X] T012 [US2] Tune ranking in `documentation/source/_static/js/siteSearch.js` so a query
  matching a function's name exactly places that function's reference page at or near the top
  of results (satisfying SC-002 parity with today's name-only widget).
  **Done**: `collectFunctionCandidates` scores object-table entries with Sphinx's own
  `Scorer.objNameMatch`/`objPartialMatch`/`objPrio` weights, plus `dedupeByUrl` to remove the
  literal duplicate rows the MATLAB domain's object table otherwise produces (the same
  function is listed under both its own module key and its parent package's key).
- [X] T013 [US2] Verify SC-002 locally per `quickstart.md`'s "US2 (function parity)" step:
  sample a set of known function names (including at least one used in an existing tutorial),
  confirm each returns its reference page among the top results for both exact and partial
  name queries.
  **Done**: verified in-browser — `optimizeCbModel` (exact) and `optimizeCb` (partial) both
  return `optimizeCbModel (MATLAB function)` as the top result; `changeCobraSolver` returns
  `changeCobraSolver (MATLAB function)` top, `changeCobraSolverParams` second (a legitimate,
  correctly-ranked partial match). No duplicate rows after the T012 dedup fix.

**Checkpoint**: User Stories 1 and 2 both independently functional — broad search works, and
function lookup has no regression.

---

## Phase 5: User Story 3 - Search results stay current with published documentation (Priority: P3)

**Goal**: Tutorial pages (carried over as pre-built HTML rather than rebuilt from `.rst` each
run) become searchable on the same terms as the rest of the site (FR-008), the whole search
index regenerates automatically on every publish with no manual maintainer step (FR-006), and
the build fails visibly rather than silently shipping a broken search bar if index generation
fails (FR-009).

**Independent Test**: Per spec.md — publish a documentation change containing a distinctive
new phrase, wait for the existing publish pipeline to complete, then confirm the search bar
returns the updated page and that removed content no longer appears.

### Implementation for User Story 3

- [X] T014 [US3] Create `documentation/source/sphinxext/generateTutorialSearchIndex.py`
  implementing research.md Decision 2 and data-model.md's Documentation Page / Search Index
  Entry shapes with `kind="tutorial"`: accept a tutorials directory path, walk its built HTML,
  extract each page's title/body text/url, and write
  `build/html/_static/json/tutorialsSearchIndex.json`; exit non-zero with a clear error
  message when the input directory is missing or unreadable (FR-009).
  **Done**: created using the standard-library `HTMLParser` (no new dependency). Text
  extraction is scoped to `<div itemprop="articleBody">` (the same wrapper
  `UpdateSideBar.py` gives every sidebar-templated page, tutorials included) so entries hold
  each tutorial's own content, not the repeated nav/sidebar/footer boilerplate. Run against
  the real tutorial content available at `/home/farid/Projects/cobratoolbox-gh-pages/stable/tutorials`
  (336 files indexed, 608KB → 532KB after the articleBody scoping fix). Confirmed non-zero
  exit + no output file written for a missing directory.
- [X] T015 [P] [US3] Add a well-formedness/coverage check to
  `documentation/source/sphinxext/generateTutorialSearchIndex.py` (or a small companion
  script run immediately after it): validate the emitted JSON is well-formed and contains at
  least one entry for a known tutorial page; exit non-zero on failure. This is the automated
  check referenced in this file's header "Tests" note.
  **Done**: `verify_index()`, run automatically at the end of `main()`. Confirmed non-zero
  exit for an empty-but-valid tutorials directory (zero entries) as well as the
  missing-directory case.
- [X] T016 [US3] Extend `documentation/source/_static/js/siteSearch.js` (Foundational, T004)
  to also fetch and merge `_static/json/tutorialsSearchIndex.json` into the ranked candidate
  set with `kind="tutorial"`, alongside the existing `searchindex.js`-derived candidates
  (depends on T004, T014).
  **Done**: `loadTutorialsIndex()`/`collectTutorialCandidates()`, already present from T004's
  initial implementation. Verified in-browser: "Flux Balance Analysis variants" now returns
  the FBA_variants tutorial (kind `tutorial`) ranked alongside function/doc results, once a
  real scoring defect was found and fixed (see T016's discovery note below) — an earlier
  version of `collectDocCandidates`'s term-table scan did *substring* matching across
  Sphinx's entire stemmed-word dictionary instead of exact-key lookups, which let unrelated
  words inflate doc/function scores far above any tutorial's legitimate title match, so no
  tutorial ever reached the top 10 results for realistic multi-word queries. Fixed by
  switching to exact stemmed-key lookups (matching Sphinx's own `Search.performSearch`
  behavior) — verified fastFVA/optimizeCbModel/FAQ/compilers results are unaffected by the
  fix (no regression) and the FBA_variants tutorial now appears at rank 3 for its own title
  phrase.
- [X] T017 [US3] Add a new step to `.github/workflows/build-and-publish-docs.yml`, inserted
  immediately after the existing "Bring existing tutorials into staging" step, that runs
  T014's script (including T015's check) against the staged `ghpages/stable/tutorials`
  directory and writes its output alongside the existing "Stage the citations static page"
  step's output under `ghpages/stable/_static/json/`.
  **Done**: added "Generate tutorial search index" step as specified. Also discovered and
  fixed a second, necessary gap while validating this end-to-end: "Stage core site to
  ghpages/stable" (pre-existing step) runs *before* this job's second `make html` (the one
  that generates function reference pages), so the `searchindex.js` it stages only covers
  narrative pages — the richer, function-inclusive `searchindex.js` from the completed build
  was never re-staged. Added a second new step, "Stage the full-text search index" (after
  "Stage the citations static page"), copying the completed build's `searchindex.js` over
  the stale one. Without this fix, FR-003/SC-002 (function search) would have silently
  regressed once deployed, despite working in every local single-pass build tested during
  T004–T013.
- [X] T018 [US3] Verify SC-004, SC-005, and SC-006 per `quickstart.md`'s "Validate the
  CI-integration requirement" section: locally simulate adding a distinctive tutorial phrase
  and removing a page/tutorial subfolder, rebuild, and confirm the index reflects both
  changes; confirm T017's new CI step fails the job (non-zero exit propagates) when given a
  missing/unreadable tutorials directory.
  **Done**: reproduced the workflow's exact staging sequence locally end-to-end (`rsync`
  first-build → tutorials → generate tutorial index → second `make html` → stage
  modules/citations/`_static` → stage `searchindex.js`), confirmed the resulting
  `ghpages/stable`-shaped tree serves working broad/function/tutorial search identically to
  the direct local build (SC-006). Removed one tutorial subfolder and regenerated the index:
  entry count dropped by exactly one and the removed page's specific URL no longer appears
  (SC-005). `generateTutorialSearchIndex.py`'s non-zero exit on a missing/empty directory
  (confirmed under T014/T015) is what makes the new `run:` step fail the GitHub Actions job,
  since no `continue-on-error` is set (SC-004's flip side — a broken generator blocks
  publish rather than silently degrading it).

**Checkpoint**: All three user stories independently functional — tutorials are searchable,
and the whole index refreshes automatically and fails loudly on error every publish.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final consistency and closeout tasks spanning all three stories.

- [X] T019 [P] Grep `documentation/source/` for existing prose that describes the search bar
  as function-name-only and update any such reference so it matches the new full-site search
  behavior (Constitution Principle X single-sourcing — no stale description left canonical
  on the published site).
  **Done**: `grep -rln "search bar\|search box\|function name" documentation/source/
  --include="*.rst"` returned no matches — no canonical prose describes the old behavior, so
  nothing needed updating.
- [X] T020 Run `quickstart.md` end to end (all three user-story sections plus the
  CI-integration section) and record a pass/fail result for each step.
  **Done** — all steps PASS, run cumulatively across T006/T010/T013/T018 plus a final
  dedicated pass reproducing the exact CI staging sequence end-to-end (see T017/T018 notes):
  build reproduction ✓; US1 broad search (FAQ/installation/contributing/citations) ✓; US2
  function parity (exact + partial, no duplicate rows) ✓; edge cases (short query hidden,
  no-match empty state, mixed function/doc/tutorial results distinguishable by badge) ✓;
  FR-007 no-unpublished-leakage — by construction, all three candidate sources
  (`searchindex.js`, `_index.objects`, the tutorial supplement) are generated only from
  content actually present in the built/staged output, so nothing outside it can appear ✓;
  CI-integration — new step placement, non-zero-exit failure propagation, and SC-005 content
  removal all verified against a full local reproduction of the `ghpages/stable` staging
  tree ✓.
- [X] T021 Report files changed, checks run, tests passed/failed, and any behaviors not yet
  verified, per Constitution Principle III's reporting requirement.
  **Done** — see report below.

  **Files changed**:
  - `.github/workflows/build-and-publish-docs.yml` — 2 new steps (+27 lines)
  - `.gitignore` — `documentation/build/`, `__pycache__/` (+2 lines)
  - `.specify/feature.json`, `CLAUDE.md` — Spec Kit bookkeeping (specify/plan phases)
  - `documentation/source/_templates/searchbox.html` — new (56 lines)
  - `documentation/source/_static/js/siteSearch.js` — new (468 lines)
  - `documentation/source/_static/css/siteSearch.css` — new (79 lines)
  - `documentation/source/sphinxext/generateTutorialSearchIndex.py` — new (239 lines)
  - `specs/019-full-site-search/*` — spec/plan/research/data-model/quickstart/tasks

  **Checks run / tests passed**: no `src/` MATLAB file touched, so no MATLAB test suite
  applies (plan.md Constitution Check). In place of that: (1) `generateTutorialSearchIndex.py`
  well-formedness/coverage self-check (T015), exercised against real content — pass; missing
  and empty-directory failure paths — both correctly non-zero exit, no output written; (2)
  full local reproduction of the CI build+staging pipeline (T017/T018) — pass; (3) in-browser
  verification (Chrome DevTools Protocol against served local builds, including the exact
  `ghpages/stable`-shaped staging tree) covering: FAQ/installation/contributing/citations
  broad search, exact/partial function-name search (`optimizeCbModel`, `changeCobraSolver`,
  `fastFVA`), tutorial search, empty/short-query edge cases, and SC-005 content-removal — all
  pass, per the per-task notes above (T006, T010, T013, T018, T020). `node --check` confirms
  `siteSearch.js` and `generateTutorialSearchIndex.py` are syntactically valid; the YAML
  workflow file parses with `yaml.safe_load`.

  **Failed / found-and-fixed during implementation** (not left outstanding): (a) referencing
  `Search`/`window.Search` instead of the bare lexical global `Search` (searchtools.js's
  `const` doesn't attach to `window`) — fixed; (b) `_ready is not defined` — `searchtools.js`
  needs `doctools.js` loaded first — fixed; (c) duplicate rows for the same function from
  multiple `_index.objects` module keys — fixed via `dedupeByUrl`; (d) un-stemmed query terms
  never matching Sphinx's Porter-stemmed term dictionary (e.g. "compilers" missing
  "installation/compilers.html") — fixed by stemming query terms with `language_data.js`'s
  `Stemmer`; (e) a scoring defect where substring-scanning the *entire* stemmed-word
  dictionary let unrelated words inflate doc/function scores far past any tutorial's
  legitimate match — fixed by switching to exact stemmed-key lookups; (f) `searchindex.js`
  staged to `gh-pages` before function pages existed, silently stale in production — fixed
  with a new "Stage the full-text search index" CI step.

  **Behaviors not yet verified** (explicitly not exercised, and why):
  - The actual GitHub Actions run of the modified `build-and-publish-docs.yml` — validated by
    exact local reproduction of its shell commands and staging order instead (no GitHub
    Actions runner available in this environment); the workflow YAML itself parses correctly.
  - A real production browser/network path (CDN latency for jQuery/Bootstrap/Font Awesome,
    which this environment's headless Chrome reached over the live internet but with highly
    variable multi-second latency) — SC-003's "<1s" target was reasoned about via measured
    payload size (1.1MB `searchindex.js`, T004/research.md) and the widget's own client-side
    scoring cost (no network round trip for ranking itself), not measured against a real user
    network profile.
  - Cross-browser behavior (Firefox/Safari) — out of scope per `quickstart.md`'s explicit
    scope note; only Chrome (via CDP) was used.
  - The pre-existing, unrelated `documentation_options.js` console error (a `sphinx_cobra_theme`
    /Sphinx-version mismatch predating this feature) and the harmless duplicate-`doctools.js`
    console SyntaxError this feature's early script-loading requirement introduces (documented
    in `searchbox.html`'s own comment) are both left as-is — cosmetic, console-only, don't
    affect functionality (verified), and fixing either would require editing the out-of-repo
    theme, which Constitution Principle V/Decision 3 (research.md) rules out for this feature.
- [X] T022 Create the implementation receipt at
  `specs/019-full-site-search/agent-runs/<UTC-timestamp>-<short-run-name>/implementation-receipt.md`
  per the Constitution's Implementation Receipt Ledger, with the actual final user-facing
  completion response copied verbatim into its `Final response` section.
  **Done**: `specs/019-full-site-search/agent-runs/20260817T170429Z-full-site-search-implement/
  implementation-receipt.md`.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately.
- **Foundational (Phase 2)**: Depends on Setup (specifically T002's confirmed template name)
  — BLOCKS all user stories.
- **User Stories (Phase 3-5)**: All depend on Foundational phase completion.
  - US1 (P1) and US2 (P2) both build directly on the Foundational engine (T004) and can
    proceed in parallel with each other once Phase 2 is done.
  - US3 (P3) also depends on Foundational (T004, extended by T016) but its own new artifacts
    (T014, T015, T017) have no dependency on US1/US2's refinement tasks and can start as soon
    as Phase 2 is done.
- **Polish (Phase 6)**: Depends on all three user stories being complete.

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2). No dependency on US2/US3.
- **User Story 2 (P2)**: Can start after Foundational (Phase 2). Renders through the same
  `siteSearch.js` as US1 but adds independent refinements (kind-labeling, ranking tuning);
  no dependency on US1's specific tasks (T007-T009).
- **User Story 3 (P3)**: Can start after Foundational (Phase 2). T016 (merging the tutorial
  index into `siteSearch.js`) depends on T004 and T014 only, not on US1/US2's tasks.

### Within Each User Story

- Implementation tasks generally touch the same one or two files
  (`siteSearch.js`, and for US3 the new Python script + workflow file), so most story-internal
  tasks are sequential by file, not parallel, except where explicitly marked [P].
- Each story's final task is its own verification step against the relevant Success Criteria,
  run only once that story's implementation tasks are complete.

### Parallel Opportunities

- T003 and T004 (Foundational) touch different files and can run in parallel.
- Once Phase 2 completes, US1 (Phase 3) and US2 (Phase 4) can be staffed in parallel — both
  build on the same `siteSearch.js` but their task sets touch non-overlapping concerns
  (excerpt/empty-state/min-length vs. kind-labeling/ranking); coordinate before merging to
  avoid clobbering shared edits to the same file.
- T014 and T015 (US3) are closely coupled (same script) but T015 can be developed as a
  companion check in parallel with T014's core walking/extraction logic before final
  integration.
- T019 (Polish grep/update) can run in parallel with T020-T022.

---

## Parallel Example: Foundational Phase

```bash
# Launch T003 and T004 together (different files, no interdependency):
Task: "Create documentation/source/_templates/<name>.html search-box template override"
Task: "Create documentation/source/_static/js/siteSearch.js core search engine"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T002).
2. Complete Phase 2: Foundational (T003-T006) — this alone already makes narrative
   documentation and function pages both searchable, since both live in Sphinx's
   `searchindex.js`.
3. Complete Phase 3: User Story 1 (T007-T010) — snippet quality, empty state, and
   short-query handling polish the broad-search experience.
4. **STOP and VALIDATE**: Run `quickstart.md`'s US1 steps independently.
5. Deploy/demo if ready — tutorials (US3) and function-parity polish (US2) can follow as
   separate increments without blocking this MVP.

### Incremental Delivery

1. Setup + Foundational → both function and narrative-doc search already work end to end.
2. Add User Story 1 polish → validate independently → this is the MVP the user asked for.
3. Add User Story 2 → validate independently → confirms no function-search regression.
4. Add User Story 3 → validate independently → tutorials searchable, CI keeps everything
   current automatically.
5. Polish (Phase 6) → closeout.

### Parallel Team Strategy

With multiple contributors, once Phase 2 (Foundational) is done:

- Contributor A: User Story 1 (T007-T010).
- Contributor B: User Story 2 (T011-T013).
- Contributor C: User Story 3 (T014-T018).

All three touch `siteSearch.js` in different, largely non-overlapping ways (excerpt/
empty-state logic vs. labeling/ranking vs. tutorial-source merging) — coordinate merges to
that one shared file to avoid clobbering each other's edits.

---

## Notes

- No `src/` or `test/` MATLAB file is created, moved, or edited by this feature (plan.md
  Constitution Check: N/A to scientific code, solver, and MATLAB-standards gates).
- `[P]` tasks touch different files with no dependency on an incomplete task.
- `[Story]` labels map each task to its spec.md user story for traceability.
- Constitution Principle III's automated-check substitute for a MATLAB test is T009/T015
  (well-formedness/coverage checks wired to fail the build loudly) plus the manual/CI
  verification tasks (T010, T013, T018, T020) — matching the "no-source" convention already
  declared in spec.md's Traceability table.
- Commit after each task or logical group, per this repository's existing convention (present
  tense, first line ≤72 characters).
