# T006 audit — fast-mode edit classification

Classification of the ranked-slowest tests into: **auto** (handled by the
`prepareTest` fast hook, no per-test edit), **edited** (manual fast guard added),
or **deferred** (edit would risk correctness/coverage; kept full-fidelity in both
modes). Correctness/coverage preservation took priority over raw speed.

| Test | Time (s) | Driver | Action | Notes |
|------|---------:|--------|--------|-------|
| testGpSampler | 12–147 | hardcoded `{gurobi,tomlab_cplex,glpk}` | **edited** | fast → single default LP solver; assertions solver-independent |
| testSimulatePairwiseInteractions | 63 | hardcoded 3-solver loop | **edited** | fast → single default LP solver; interaction interpretation solver-independent. modelList 5→3 NOT applied (fragile hardcoded cleanup deletes mismatched filenames) |
| testMultiProductionEnvelopeInorg | 17 | non-solver | **edited** | removed dead `pause(3)` (unconditional); fast skips two unasserted extra calls |
| testReadSBML | 18 | `prepareTest(...,'requireOneSolverOf',...)` | **auto** | already returns one solver locally in both modes; no edit needed |
| testTest4HumanFctExt | 99 | `prepareTest('requireOneSolverOf',...)` | **auto (solver) / deferred (rest)** | solver loop already single locally; the ~686 FBA solves on Recon1 ARE the coverage and cannot be trimmed without losing it |
| testJoinModelsPairwiseFromList | 32 | non-solver (model builds) | **deferred** | no solver loop; a modelList 5→3 reduction collides with the fragile hardcoded cleanup (delete() of mismatched filenames) — risk > benefit |
| testWriteSBML | 42 | non-solver (libSBML) | **deferred** | the second `writeSBML` serialises the read-back model (testModelSBML), not the original, so the SBO-term struct cannot be cleanly reused from the first write without changing what is tested |
| testModelBorgifier | 31 | non-solver (XML parse + O(n²) compare) | **deferred** | swapping iIT341 .xml→.mat could yield a different model and change the comparison score/fields; risk to the assertions |

## Shared mechanism (applies to all)

- `getCobraTestMode` — resolves fast (default) / full; CI forces full.
- `prepareTest` — fast mode returns one representative solver per class unless the
  test explicitly requests multiple via `requiredSolvers`/`useSolversIfAvailable`
  (cross-solver tests keep all solvers — FR-005). This transparently trims any test
  that loops over `prepareTest`'s returned lists, chiefly in the CI `extensive`
  path (which runs full mode anyway, so CI is unaffected).

## Deviations from tasks.md (recorded for the receipt)

- T008: solver-trim applied; the modelList 5→3 reduction was **not** applied
  (fragile cleanup). T011: pause + unasserted-skip applied to
  testMultiProductionEnvelopeInorg; testJoinModelsPairwiseFromList /
  testWriteSBML / testModelBorgifier **deferred** (rationale above).
- T009 (testReadSBML) and the solver part of T010 (testTest4HumanFctExt) are
  **auto**-handled — no edit required.
- Net: the shared mechanism + three targeted edits deliver the dominant local
  speedup (the solver-loop tests) while keeping every test full-fidelity in full
  mode and avoiding any edit that could change an assertion or drop coverage
  unpredictably.
