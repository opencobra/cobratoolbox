# Implementation Review

## Summary

Four independent changes clear the five CI failures:

- **US1 (P1)**: pin `binary` at `10697a987`. `lrsRun` then fails loudly on any non-zero
  lrs/redund status, and its shell-script branch is fixed. Clears testExtremePathways,
  testExtremePools and testLrsInterface.
- **US2 (P2)**: testGenerateFullRowRankFR's console filter removes the expected warnings
  in their `matlab -batch` form (brackets, wrapping, backtrace). This was the confirmed
  CI cause, reproduced locally under `-batch`.
- **US3 (P3)**: testReconMap skips (`COBRA:RequirementsNotMet`) when MINERVA refuses the
  test account. Its dead branch with personal credentials is deleted.
- **US4 (P4)**: getRankLUSOL prints nothing at printLevel 0 except one
  `getRankLUSOL:lusolFallback` warning per session on fallback. Outputs are unchanged.

## Embedded Core Commands Completed

- constitution (checked) / specify / clarify (4 Q) / checklist (2 files, all pass) /
  plan / tasks / analyze (1 HIGH, 3 MEDIUM, 3 LOW; remediated, spec re-derived after the
  US2 root cause was confirmed).

## Cross-Artifact Analysis Summary

- No CRITICAL findings.
- **A1 (HIGH)** led to the discovery that the MCP session's diary records nothing.
  Running under `-batch` reproduced the CI failure and showed its true cause.
  Remediated in spec FR-004 and tasks T009/T014.
- **C1, U1, I1, I2**: remediated.
- **D1**: testRank.m is misnamed under III-Naming; pre-existing, recorded as a
  follow-up.
- **G1**: the CI half of SC-001 can't be verified here, because the fork's CI jobs are
  skipped.

## Proposed Implementation Scope

- **Tasks proposed**: T001–T022 (7 phases).
- **First independently testable slice**: Phases 1–3 (T001–T007, US1).
- **Files likely to change**:
  - `binary` (pointer)
  - `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsRun.m`
  - `src/analysis/subspaces/rank/getRankLUSOL.m`
  - `test/verifiedTests/analysis/testTopology/testLrsInterface.m`
  - `test/verifiedTests/analysis/testTopology/testGenerateFullRowRankFR.m`
  - `test/verifiedTests/analysis/testRank/testRank.m`
  - `test/verifiedTests/visualization/testReconMap/testReconMap.m`
  - the feature directory
  - `CLAUDE.md` (plan pointer, already changed)
- **Files that should NOT change**: `generateFullRowRankFR.m`, `postMINERVArequest.m`,
  `buildFluxDistLayout.m`, `lrsWriteHalfspace.m`, `external/`, any shipped binary,
  `testExtremePathways.m`, `testExtremePools.m`.

## Tests and Validation Expected (narrowest first)

1. testLrsInterface, then testExtremePathways and testExtremePools (MCP session).
2. testGenerateFullRowRankFR (`matlab -batch`), plus the filter sensitivity check (T011).
3. testReconMap (`matlab -batch`), then the same run through `runScriptFile` to show the
   skip.
4. testRank (`-batch`) and `getRankLUSOLBaseline('compare')`.
5. The binary-bump regression set before and after (testSolveCobraLP/QP, testQuadLP,
   testDuals, testMapSolverStatus), and every test in the topology and rank folders.

## Blocking Issues

None.

## Acceptable Risks

- The binary bump also changes the quadPrecision, minos and DQQ executables. T001/T019
  report any outcome change.
- `param.redund = 0` now errors clearly, because the new binary ships no `redund`.
  Before, it read an empty file silently.
- Once-per-session warning: after the first fallback in a session, further fallbacks
  are silent at printLevel 0 (user decision, clarify Q1).
- The exposed MINERVA password stays in git history; the user should rotate it.

## Human Approval

- Approved: no
- Approved option:
- Approved tasks/scope:
- Required implementation invocation per constitution: `/speckit-implement`, or the agent-assign pipeline
- Date (UTC):
