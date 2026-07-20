# Implementation Review

## Summary

Two full-mode-only tests that drive `XomicsToModel` end-to-end (one `fastCore`, one
`thermoKernel`) on the shipped model + omics data, covering both untested functions,
with genuine assertions (feasible extracted model + captured reference facts). Skipped in
fast/default mode so routine runs stay fast. No `src` change.

## Embedded Core Commands Completed
- constitution: checked · specify ✅ · clarify ✅ (full-mode-only; both extractors) ·
  checklist ✅ · plan ✅ · tasks ✅ · analyze: inline (below).

## Cross-Artifact Analysis Summary
FR-001/002 → T004/T005; FR-003 → prepareTest; FR-004 → T003; FR-005 → no src edits;
FR-006 → full-mode-only guard + T001/T002 viability; FR-007 → two tests; FR-008 → figures.
**One HIGH risk**: viability — neither extractor completed in feasibility (~10 min). T001/T002
must run each to completion (bounded ≤~30 min) before assertions are fixed; a config that does
not converge is deferred/documented, not committed as a hanging test.

## Proposed Implementation Scope
- **Tasks**: T001–T008.
- **First testable slice**: the fastCore test (T001, T003, T004, T006) — if fastCore converges.
- **Files likely to change (all NEW)**: `test/verifiedTests/dataIntegration/testXomicsToModel/`
  (two test .m + `data/` omics fixtures).
- **Files that should NOT change**: any `src/` (XomicsToModel, thermoKernel, preprocessingOmicsModel),
  the submodules, other tests.

## Tests and Validation Expected (narrowest first)
1. `testXomicsToModel_fastCore` in full mode → passed (feasible model, references match); skipped in fast mode.
2. `testXomicsToModel_thermoKernel` likewise (if thermoKernel converges within the cap).
3. `check_matlab_code` on both.

## Blocking Issues
None at spec level, but see the viability risk (a config may not converge → that test deferred).

## Acceptable Risks
- A config (esp. thermoKernel) may not complete within the bounded cap → that test is deferred
  and documented; the feature still delivers whatever converges.
- The tests are heavy; quarantined to full mode so routine runs are unaffected.

## Human Approval
- Approved: no
- Required implementation invocation per constitution: explicit `/speckit-implement`.
  **Awaiting it before any file is written.**
- Date (UTC):
