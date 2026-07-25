# Implementation Receipt — testAll performance modes (002)

**UTC**: 2026-07-13T17:05:13Z · **Branch**: 002-testall-performance-modes ·
**Gate 2**: "Approve all tasks" · **Invocation**: `/speckit-implement`

## Prompt

Spec Kit implementation of feature 002-testall-performance-modes (approved scope
T001–T020): a fast-by-default, coverage-preserving test-suite execution mode with a
documented revert to full mode, plus an opt-in profiling report. Derived from the
user request "speckit the coverage preserving speedup as an optional flag to enable
a global speedup of testAll, as default, but with the option to revert to the more
complete but slower test", routed through Spec Kit at the user's choice.

## Final response

Implemented and verified the fast/full test-mode mechanism and the opt-in profiling
report; applied the three highest-value coverage-preserving per-test speedups and
deferred four riskier ones (documented). New `getCobraTestMode` resolver (default
fast; `COBRA_CI=1` forces full; global/env overrides; invalid → error) drives a
fast-mode hook in `prepareTest` (one representative solver unless the test requests
multiple) and per-test guards. `testAll` announces the mode and, when
`COBRA_PERF=1`, writes a ranked timing CSV + profiler HTML (best-effort, never
alters pass/fail). Full mode reproduces prior behaviour by construction; CI runs
full so the 001 coverage gate is unaffected. Verified: resolver unit test passes;
prepareTest returns 6 solvers in extensive+full, 1 in fast, 6 when solvers are
explicitly requested; `testGpSampler` fast 12s (vs ~147s), `testMultiProduction-
EnvelopeInorg` fast 2.9s / full 55.7s both pass, `testSimulatePairwiseInteractions`
fast passes; static analysis introduces no new warnings. Whole-suite MoCov coverage
delta and a full `testAll` profiling run were not executed live (60-min suite) and
are left for a full/CI run.

## Diff summary

Source/test/docs (139 insertions, 6 deletions across 7 tracked files + 2 new):

- **NEW** `src/base/install/getCobraTestMode.m` — mode resolver.
- **NEW** `test/verifiedTests/base/testInstall/testGetCobraTestMode.m` — unit test.
- `src/base/install/prepareTest.m` (+11) — fast mode → minimal solvers unless
  `requiredSolvers`/`useSolversIfAvailable` given.
- `test/testAll.m` (+51) — announce mode; opt-in profiling report block.
- `test/verifiedTests/analysis/testSampling/testGpSampler.m` (+9/-) — fast → 1 LP solver.
- `.../testMultiSpeciesModelling/testSimulatePairwiseInteractions.m` (+9/-) — fast → 1 LP solver.
- `test/verifiedTests/design/testMultiProductionEnvelopeInorg.m` (+11/-2) — removed
  dead `pause(3)`; fast skips two unasserted calls.
- `documentation/source/guides/testGuide.rst` (+51) — modes + profiling + compat note.
- `.gitignore` (+3) — ignore `test/performance/`.
- `CLAUDE.md` — SPECKIT pointer updated to feature 002 (plan phase).

Deferred (correctness-first, see `audit/fast-mode-edits.md`): modelList reduction in
the two microbiome tests; `testWriteSBML`, `testModelBorgifier`,
`testJoinModelsPairwiseFromList`, `testTest4HumanFctExt` per-test trims.

## Tests

- `testGetCobraTestMode` — PASS (all resolution branches incl. CI-forces-full, invalid-errors).
- `prepareTest` behaviour — extensive+full: `{gurobi,mosek,glpk,pdco,quadMinos,dqqMinos}`;
  extensive+fast: `{gurobi}`; fast + explicit multi-solver request: all six (FR-005).
- `testGpSampler` — fast PASS 12.1s (baseline ~147s full).
- `testMultiProductionEnvelopeInorg` — full PASS 55.7s, fast PASS 2.9s.
- `testSimulatePairwiseInteractions` — fast PASS.
- `mcp__matlab__check_matlab_code` — new/edited files: only pre-existing / by-design
  (global) warnings; the one non-top-level `global` note was fixed.

## Unresolved issues

- Whole-suite fast-vs-full **MoCov coverage** comparison (SC-002, ≤5 pp) and a full
  `testAll COBRA_PERF=1` run (T017/T018) not executed live — 60-min suite; run in CI
  or a dedicated session to close SC-001/SC-002 numerically.
- Deferred per-test trims (T008 modelList, T011 testWriteSBML/testModelBorgifier/
  testJoinModelsPairwiseFromList) — optional follow-up; each carries a documented
  correctness risk.
- Pre-existing broken tests `testFVA` (FAIL) and `testdynamicRFBA` (ERROR) remain
  broken in both modes (not masked, as required) — out of scope to fix here.

## Other information

Full mode is behaviourally identical to pre-feature except the removed `pause(3)`
(pure idle wait, no assertion/coverage impact). CI (`COBRA_CI=1`) forces full mode,
so feature 001's coverage/skip gate baseline is unaffected.
