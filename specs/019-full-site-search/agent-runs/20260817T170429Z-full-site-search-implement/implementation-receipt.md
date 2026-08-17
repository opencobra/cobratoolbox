# Implementation Receipt

## Prompt

`/speckit-implement` (no additional arguments), run against feature
`specs/019-full-site-search/` after `/speckit-specify` → `/speckit-plan` →
`/speckit-tasks` completed earlier in the same session. The underlying feature
request: "look at the CI and how a change in the documentation that lives
under master branch in rst files trigers the CI to generate the html format
using sphinx and push it to the gh-pages. Currently on the cobra toolbox
website the search bar only looks through the function names. I want to
change this feature into a general search bar that searchs through all the
documentations on the website."

## Final response

All 22 tasks in `tasks.md` are complete. The site's search bar — previously
an `easyAutocomplete` widget backed only by `_static/json/functions.json` (a
flat list of MATLAB function names, and one that turned out not to even be
wired into CI) — is now a full-site instant search that covers function
reference pages, every narrative page Sphinx builds from `.rst` (installation,
FAQ, guides, contributing, citations), and tutorials.

**How it works**: rather than building a second indexing pipeline, the widget
reuses Sphinx's own generated `searchindex.js` (already covers function +
narrative pages) via its real `Search`/`Scorer`/`splitQuery`/
`makeSearchSummary` machinery, loaded explicitly since the theme
(`sphinx_cobra_theme`, a separate GitHub repo, never edited) doesn't load it
itself. A new script, `generateTutorialSearchIndex.py`, supplements this with
tutorial pages, which are carried over as pre-built HTML rather than rebuilt
from source each publish. Both indexes refresh automatically on every publish
via two new steps in `build-and-publish-docs.yml`, and the new step fails the
build loudly (non-zero exit) rather than shipping a broken search bar.

**New/changed files**: `documentation/source/_templates/searchbox.html` (new,
local override of the theme's search box), `documentation/source/_static/js/
siteSearch.js` (new, 468-line search engine), `documentation/source/_static/
css/siteSearch.css` (new), `documentation/source/sphinxext/
generateTutorialSearchIndex.py` (new), `.github/workflows/
build-and-publish-docs.yml` (+2 steps), `.gitignore` (+2 patterns for local
build artifacts).

**Verified in-browser** (Chrome DevTools Protocol against served local
builds, including a full local reproduction of the exact `ghpages/stable`
staging tree the real CI produces): broad search across FAQ/installation/
contributing/citations; exact and partial function-name search with no
regression (`optimizeCbModel`, `changeCobraSolver`, `fastFVA`); tutorial
search; empty-query and short-query edge cases; content-removal (a removed
tutorial's entry correctly disappears after regeneration); and the new CI
step's failure path (missing/empty tutorials directory → non-zero exit).

**Six real defects were found and fixed during implementation** (not just
theorized in planning) — most significantly: a scoring bug where substring-
scanning Sphinx's entire stemmed-word dictionary let unrelated words inflate
unrelated pages' scores past any genuinely matching tutorial, which I caught
because a title-matching tutorial query was returning zero tutorial results;
and a CI staging gap where `searchindex.js` was staged *before* the build
pass that generates function reference pages, meaning production search
would have silently regressed on function lookups even though every local
test passed. Full details, per-task, are in `tasks.md`.

**Not verified**: an actual GitHub Actions run (no runner available here;
substituted with an exact local reproduction of the workflow's shell
commands and staging order), real-network SC-003 timing, and cross-browser
behavior (out of scope per `quickstart.md`).

**Cleanup**: build artifacts from local verification (a `documentation/.venv/`
virtualenv, `documentation/build/`, and auto-generated `.rst` files under
`documentation/source/modules/`) were removed or gitignored; the working tree
now contains only the intended feature changes.

Next step, if you'd like: `/speckit-git-commit` to commit these changes (shown
above as an optional post-implement hook), or review the diff yourself first.

## Diff summary

```
 .github/workflows/build-and-publish-docs.yml | 27 +++++++++++++++++++++++++++
 .gitignore                                   |  2 ++
 .specify/feature.json                        |  4 +++-
 CLAUDE.md                                    |  2 +-
 4 files changed, 33 insertions(+), 2 deletions(-)
```

New files (untracked, not yet committed):
- `documentation/source/_templates/searchbox.html` (56 lines)
- `documentation/source/_static/js/siteSearch.js` (468 lines)
- `documentation/source/_static/css/siteSearch.css` (79 lines)
- `documentation/source/sphinxext/generateTutorialSearchIndex.py` (239 lines)
- `specs/019-full-site-search/` (spec.md, plan.md, research.md, data-model.md,
  quickstart.md, tasks.md, checklists/requirements.md, this receipt)

No `src/`, `test/`, or other MATLAB file was created, moved, or edited.

## Tests

No `src/` MATLAB function is touched by this feature (documentation/
CI-tooling change; spec.md's Traceability table uses the "no-source"
convention throughout). In place of a MATLAB test file:

- `generateTutorialSearchIndex.py`'s own `verify_index()` well-formedness/
  coverage check (valid JSON, non-empty, required fields present per entry),
  run automatically at the end of every invocation and wired as the CI step's
  built-in failure gate. Exercised against real tutorial content (336 entries
  from `/home/farid/Projects/cobratoolbox-gh-pages/stable/tutorials`) —
  PASS. Exercised against a missing directory and an empty-but-valid
  directory — both correctly exit non-zero with no output file written.
- Full local reproduction of the CI build-and-stage pipeline (first build →
  stage → tutorials → generate tutorial index → second build with function
  RST → stage modules/citations/`_static` → stage `searchindex.js`),
  confirmed the resulting `ghpages/stable`-shaped tree serves fully working
  search — PASS.
- In-browser verification via Chrome DevTools Protocol (no new test-framework
  dependency added to the repository): broad search (FAQ, installation,
  contributing, citations), function-name search (exact + partial, several
  functions), tutorial search, empty-state, short-query guard, kind badges,
  and content-removal (SC-005) — all PASS, details per task in `tasks.md`.
- `node --check` on both new JS/Python-adjacent script's syntax equivalents
  (`siteSearch.js`) and `python3 -m ast.parse`-equivalent checks on
  `generateTutorialSearchIndex.py` — PASS. `yaml.safe_load` on the modified
  workflow file — PASS.

No tests failed. See `tasks.md`'s T021 entry for the full list of defects
found and fixed during this verification (not left as known failures).

## Unresolved issues

- The actual GitHub Actions execution of the modified
  `build-and-publish-docs.yml` has not been observed (no runner available in
  this environment) — substituted with an exact local shell reproduction of
  every step in order, including the newly added ones.
- SC-003's "<1s" perceived-latency target is reasoned about from measured
  payload size (1.1 MB `searchindex.js` at full scale) and the fact that
  ranking itself is client-side with no network round trip, not measured
  against a real end-user network profile.
- Two pre-existing/newly-necessary console-only issues are deliberately left
  as-is, documented in `searchbox.html`'s own comment: (1) a `sphinx_cobra_theme`
  /Sphinx-version mismatch (`documentation_options.js` throwing on every
  page) that predates this feature; (2) a harmless duplicate `doctools.js`
  declaration `SyntaxError`, an unavoidable side effect of this feature
  needing `_ready` available earlier in `<body>` than the theme's own script
  loading provides. Both are confirmed not to affect functionality; fixing
  either would require editing the out-of-repo `sphinx_cobra_theme` package,
  which Constitution Principle V and this feature's research.md Decision 3
  rule out.
- Cross-browser behavior (Firefox, Safari) was not tested — out of scope per
  `quickstart.md`'s explicit scope note.
