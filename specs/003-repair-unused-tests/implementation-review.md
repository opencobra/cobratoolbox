# Implementation Review

## Summary

Repair non-contributing tests to enlarge coverage: fix tests broken by their own bugs,
broaden over-strict requirement declarations, install the one freely-obtainable dep
that helps here (`lrs`), convert genuinely un-runnable tests to clean skips, and remove
a stray test. No assertion weakened; no function-under-test changed. Done = pass-count
increase with every identified test accounted for.

## Embedded Core Commands Completed

- constitution: checked (v1.2.0) · specify ✅ · clarify ✅ (DoD=pass-count; widest scope)
- checklist ✅ (all pass) · plan ✅ · research ✅ (per-test triage via 2 subagents) ·
  tasks ✅ (T001–T017) · analyze ✅ (0 critical, 100% FR coverage)

## Cross-Artifact Analysis Summary

Every FR maps to ≥1 task; every identified non-contributing test has a recorded
outcome (pass / error→clean-skip / stays-skip / removed / out-of-scope follow-up).
No orphan tasks. One HIGH-value clarification already resolved (widest scope) is
bounded by environment reality (only lrs is installable here; commercial/licensed deps
stay clean skips).

## Proposed Implementation Scope

- **Tasks proposed**: T001–T017.
- **First independently testable slice (MVP)**: US1 = T001–T004 (testGenerateFieldDescriptionFile
  and testFVA → pass), the two highest-confidence, dependency-free code-bug fixes.
- **Files likely to change** (test-only): testGenerateFieldDescriptionFile.m, testFVA.m,
  testMoomin.m, testComputeMetFormulae.m, testMgPipe.m, testdynamicRFBA.m,
  testChangeIBMCplexParams.m; and removal of test/test_myfunction.m.
- **Files that should NOT change**: any `src/**` function under test (isCompatible.m,
  TwoSidedBarrier.m, sampleCbModel.m, etc. — function/layout fixes are out of scope),
  expected-result `.mat` fixtures, feature 001/002 code.

## Tests and Validation Expected (narrowest first)

1. Each edited test via `runScriptFile`/`run_matlab_test_file` before/after, both modes:
   testGenerateFieldDescriptionFile & testFVA → passed; testMoomin & testComputeMetFormulae
   → passed on available solvers; testdynamicRFBA → clean skip; testChangeIBMCplexParams
   → clean skip (locally).
2. lrs trio after `apt install lrslib` (user-run) → passed or clean skip.
3. testMOMA / testIsCompatible → verify already pass; testSampleCbModelRHMC → clean skip.
4. `check_matlab_code` on edited files; regression sample of passing neighbours.

## Blocking Issues

None (0 critical).

## Acceptable Risks

- testMoomin on mosek MILP was never author-validated — validate before committing;
  if mosek deviates, leave testMoomin as a clean skip rather than weaken it.
- The lrs "pass" depends on the user running the surfaced `apt install lrslib`.
- Pass-count is environment-relative; the authoritative coverage number is a CI concern.

## Human Approval

- Approved: no
- Approved option:
- Approved tasks/scope:
- Required implementation invocation per constitution: explicit `/speckit-implement`
  (a Gate 2 menu pick alone does not authorize edits). **Awaiting it before any edit.**
- Date (UTC):
