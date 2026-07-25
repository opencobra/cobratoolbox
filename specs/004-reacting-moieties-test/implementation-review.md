# Implementation Review

## Summary

Add one additive test that repurposes the verified-working conserved-and-reacting
moieties tutorial into automated coverage of seven currently-untested moiety functions,
asserting the `L*N = 0` conservation invariant plus stable structural facts, with figures
generated invisibly. No `src/` change.

## Embedded Core Commands Completed

- constitution: checked · specify ✅ · clarify n/a · checklist ✅ (all pass) ·
  plan ✅ · tasks ✅ (T001–T006) · analyze: inline (below).

## Cross-Artifact Analysis Summary

Every FR maps to a task: FR-001/002/003 → T003/T004; FR-004 → T003 (onCleanup figure
restore); FR-005 → T001/T003 (prepareTest); FR-006 → additive only, no src edits;
FR-007 → T005 (both modes); FR-008 → T002 (self-contained rxnFiles). 0 blocking issues.
Low risks: the exact expected values and the true solver requirement are resolved by a
real run in T001/T004 before assertions are fixed.

## Proposed Implementation Scope

- **Tasks proposed**: T001–T006.
- **First independently testable slice (MVP)**: T001–T005 (the working test); T006 is
  polish (static check, receipt, commit staging).
- **Files likely to change (all NEW)**:
  - `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
  - `test/verifiedTests/analysis/testReactingMoieties/data/rxnFiles/…` (minimal fixture)
  - optional `…/refData_reactingMoieties.mat`
  - commit of the existing `test/tutorialDerived/` analysis staging (research)
- **Files that should NOT change**: any `src/` function under test, the tutorials
  submodule, other tests, expected-result fixtures of other tests.

## Tests and Validation Expected (narrowest first)

1. `testConservedReactingMoieties` via `runScriptFile`/`run_matlab_test_file` — passes,
   asserts `L*N=0`, exercises the 7 functions, opens no figure window, both modes.
2. `check_matlab_code` on the new test — no new warnings.

## Blocking Issues

None.

## Acceptable Risks

- Exact expected values / solver requirement determined during implementation (T001/T004)
  from a real run; if the workflow turns out to need an unavailable dependency, the test
  becomes a clean skip rather than a pass (still satisfies SC-001's "or a clean skip").

## Human Approval

- Approved: no
- Approved option:
- Approved tasks/scope:
- Required implementation invocation per constitution: explicit `/speckit-implement`
  (a Gate 2 pick alone does not authorize edits). **Awaiting it before any file is written.**
- Date (UTC):
