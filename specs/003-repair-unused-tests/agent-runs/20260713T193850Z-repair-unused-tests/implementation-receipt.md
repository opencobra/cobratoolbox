# Implementation Receipt — repair-unused-tests (003)

**UTC**: 2026-07-13T19:38:50Z · **Branch**: 003-repair-unused-tests ·
**Gate 2**: "Approve all tasks" · **Invocation**: `/speckit-implement`

## Prompt

Spec Kit implementation of feature 003-repair-unused-tests (approved scope T001–T017):
identify and repair non-contributing tests (code-bug failures, over-strict requirement
skips, environment-dependent errors, a stray test) to enlarge coverage without weakening
assertions. Done = pass-count increase with every identified test accounted for.

## Final response

Repaired the tests that were repairable without weakening any assertion, and — following
the no-weakening rule strictly — reverted the ones that could only pass by loosening
solver-specific assertions. Verified locally: testGenerateFieldDescriptionFile now PASSES
(uses the function's returned string instead of re-reading a deleted reference, and
self-cleans the regenerated doc); testdynamicRFBA goes from ERROR to a clean SKIP (fixed
the struct-indexed-as-cell bug and gated on `requireOneSolverOf` the cplex variants);
testChangeIBMCplexParams got a scalar-safe assertion (`&&`/`isequal`) hardening; the
stray test_myfunction.m (target `myfunction` does not exist) was removed. The three lrs
tests (testExtremePathways/Pools/LrsInterface) PASS once `lrs` is on PATH — proven by
wiring the bundled `binary/glnxa64/bin/lrs/` binary for one session; persistent enable is
`sudo apt-get install -y lrslib` (surfaced to the user, not run silently). testIsCompatible
and testMOMA were confirmed already passing locally (their junit statuses were environment
artifacts), and testSampleCbModelRHMC is a clean skip locally. testFVA and
testComputeMetFormulae were investigated and reverted — their failing assertions are
genuinely solver-specific (a solver-dependent FVA reference; a cplex-only TimeLimit=0
behaviour) and cannot be fixed without changing an expected value. testMoomin/testMgPipe
broadenings were reverted as unvalidatable here (mosek MILP not working; Parallel Toolbox
absent). Net: +1 immediate new pass and +3 once lrs is installed, two errors eliminated
(testdynamicRFBA, test_myfunction), no previously-passing test broken, and every identified
non-contributing test accounted for (see audit/results.md and audit/out-of-scope.md).

## Diff summary

Test-only (3 files edited, +19/−6; 1 removed):
- `test/verifiedTests/base/testIO/testUtilities/testGenerateFieldDescriptionFile.m` — capture
  the returned string; remove the fopen/fscanf round-trip; delete the regenerated default doc.
- `test/verifiedTests/analysis/testrFBA/testdynamicRFBA.m` — gate via a separate
  `prepareTest('requireOneSolverOf', {'tomlab_cplex','ibm_cplex'})`; stop clobbering the loop cell.
- `test/verifiedTests/base/testSolvers/testChangeIBMCplexParams.m` — `assert(isempty(sol.full) && isequal(sol.origStat, 11))`.
- **removed** `test/test_myfunction.m`.
Reverted (no change committed): testFVA, testComputeMetFormulae, testMoomin, testMgPipe.

## Tests

All via `runScriptFile` on the local solver set (fast mode):
- testGenerateFieldDescriptionFile — PASS (0.1s; no leftover file).
- testdynamicRFBA — clean SKIP (was ERROR).
- testChangeIBMCplexParams, testMgPipe, testSampleCbModelRHMC — clean SKIP.
- testIsCompatible — PASS; testMOMA — PASS.
- testExtremePathways / testExtremePools / testLrsInterface — PASS with bundled lrs on PATH.
- `check_matlab_code` on the 3 edited files — only pre-existing/by-design warnings after
  removing an unnecessary `%#ok<NASGU>`.

## Unresolved issues

- Whole-suite source-line coverage delta (SC-005) is confirmed in CI, not run locally.
- lrs pass depends on the user running `apt install lrslib` (or PATH-wiring the bundled binary).
- Follow-ups (separate feature — src changes): `isCompatible.m` `fid==-1` guard + list-table
  parser; de-dup the shadowing `papers/…/TwoSidedBarrier.m`. See audit/out-of-scope.md.
- Genuinely dependency-bound tests (cplex/NLP/toolbox-licensed) remain clean skips.
