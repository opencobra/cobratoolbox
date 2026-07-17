# Implementation Receipt — 013-relocate-vendored-code (slices P1, P2, P3a)

**Run:** 20260717T071421Z-relocate-vendored-code
**Feature:** specs/013-relocate-vendored-code · **Branch:** 013-relocate-vendored-code

## Prompt

Address weakness W9 (vendored third-party code and data blobs inside `src/`) via Spec Kit. Scoped at
Gate 2 to **P1 (SAMMI) + P2 (Perl+GAMS) + P3 sub-slice 3a (orphans/generated/tutorial)**, deferring the
static-data `data/` sub-slice (3b, gated on a constitution amendment). Implementation authorized by an
explicit `/speckit-implement`. Behavior-preserving: no public MATLAB signature changes; moves
byte-identical; wrappers re-anchored on `CBTDIR`.

## Final response

Implemented feature 013 slices P1, P2, and P3a on branch `013-relocate-vendored-code`, moving the
vendored non-MATLAB code and committed generated artifacts out of `src/` while keeping every wrapper's
public signature and behavior intact.

- **P1 (SAMMI):** SAMMI's GPLv3 JS/CSS/HTML template → `external/visualization/SAMMIM/`; `sammi.m` now
  resolves the template from `external/` via `CBTDIR` and rewrites the generated HTML's local asset
  refs to absolute external paths (default output location + signature unchanged). `demo.json` turned
  out to be a **live `testSammi` fixture** (not dead) → moved to the test dir with a 1-line `testSammi.m`
  update. Committed generated HTML removed + gitignored.
- **P2 (Perl + GAMS):** the 5 `c13solver/*.pl` and 7 `.gms` (incl. `licememo.gms`) → `external/`; all
  `which('*.gms')`/perl invocations re-anchored on `CBTDIR` across 9 wrappers (including
  `checkGAMSSolvers.m`, a required companion for the `licememo` move).
- **P3a:** orphan Python scratch → `deprecated/_io_python_tmp/`; regenerable `wang/cache/*.mat` deleted
  + gitignored.

~45k lines removed from `src/`; the `src/*.m` diff is only path-resolution edits. Verified with MATLAB
R2026a: `check_matlab_code` clean of new issues on every edited wrapper; live smokes confirm the SAMMI
template + `demo.json` fixture resolve and `sammi` writes output, and `perl` locates+executes the
relocated `generatorEMU.pl`.

**Deferred (not done):** T019 tutorial move (`tutorials/` is a git submodule — needs a submodule
commit); sub-slice 3b static data → `data/` (needs a `/speckit-constitution` amendment adding the
`data/` role); `taxa2proc_*.txt` (out of scope).

## Diff summary

Feature commits: `3280fc7d0` (P1), `e4e425373` (P2), `26c6bf664` (P3a). 40 files, +48 / −1219 lines
(vendored JS/JSON/PL/GMS moved as byte-identical renames; from `src/`'s view ~45,047 lines left).

- **Moved (byte-identical) out of `src/`:** SAMMI `helpfunctions.js`, `uploaddownload.js`,
  `simulationfunctions.js`, `sammi.css`, `index.html` → `external/visualization/SAMMIM/`; `demo.json` →
  `test/verifiedTests/visualization/testSammi/`; `c13solver/{generatorEMU,generatorCumomer,optimizerEMU,optimizerCumomer,validator}.pl`
  → `external/dataIntegration/fluxomics/c13solver/`; `optForceGAMS/{findMustL,findMustLL,findMustU,findMustUL,findMustUU,optForce}.gms`
  → `external/design/optForceGAMS/`; `gams/licememo.gms` → `external/base/solvers/gams/`;
  `base/io/python/tmp/*` → `deprecated/_io_python_tmp/`.
- **Deleted:** `wang/cache/autoFragment_*.mat` (4, ~3.1 MB); SAMMI `index_load.html`, `index_load2.html`,
  `sammi_test_output.html` (generated).
- **Edited (path-resolution only):** `sammi.m` (+13/−3), `generateIsotopomerSolver.m` (+8/−5),
  `optForceWithGAMS.m`, `findMust{L,LL,U,UL,UU}WithGAMS.m`, `getAvailableGAMSSolvers.m`,
  `checkGAMSSolvers.m` (+2/−1 each), `testSammi.m` (+1/−1), `.gitignore` (SAMMI + cache patterns),
  `analysis/WEAKNESSES.md` + `analysis/ARCHITECTURE.md` (W9 status).

## Tests

- Environment: MATLAB R2026a; `perl` present, `gams` absent, `statistics_toolbox` absent (baseline in
  `baseline.md`).
- `check_matlab_code` on all edited wrappers: only pre-existing info/warnings; no new issues.
- SAMMI smoke: template resolves from `external/`; `sammi(model,...)` writes output; asset paths
  rewritten to `external/`; `demo.json` fixture case (case 10) writes output. (Full `testSammi` cannot
  run here — `prepareTest` requires `statistics_toolbox`, absent; errors at L19 before any edited code,
  identical before/after — baseline, not a regression.)
- Perl smoke: `perl(<external>/generatorEMU.pl)` from an empty cwd dies at line 4 on missing
  `IsotopomerModel.txt`, referencing the external path → the relocated script is located and executed.
- GAMS: absent → optForce/GAMS wrappers behave as baseline; relocated `.gms` resolution verified by
  `exist()` on the CBTDIR-anchored paths.
- SC checks: SC-001/002 — no targeted vendored/generated artifacts remain under `src/` except the
  intentionally-deferred `tutorial_eFBA.mlx`. SC-005 — ~45k lines / ~5.9 MB left `src/`. SC-006 —
  `git diff src/*.m` is path-resolution edits only.

## Unresolved issues

1. **T019 tutorial move (`tutorial_eFBA.mlx` → `tutorials/`)** — `tutorials/` is a git submodule; the
   move needs a commit inside the submodule + a pointer bump. Left in `src/visualization/entropicFBA/`.
   Decision needed.
2. **Sub-slice 3b static data (`data/`)** — deferred at Gate 2; requires a `/speckit-constitution`
   amendment adding the `data/` role before the NIST/`.xlsx` moves.
3. **`taxa2proc_*.txt`** — out of scope (Clarifications).
4. **Working-tree noise (not this feature):** an externally-installed `agent-assign` Spec Kit extension
   modified `constitution.md`, `AGENTS.md`, `CLAUDE.md`, `.specify/extensions.yml`, and added
   `agent-assign` skills. These are uncommitted and were deliberately excluded from all 013 commits.
