# Implementation Plan: Fix four CI test failures (lrs, console-capture filter, ReconMap) and quiet getRankLUSOL

**Branch**: `20261026-220121-fix-ci-test-failures` | **Date**: 2026-10-26 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/20261026-220121-fix-ci-test-failures/spec.md`

## Summary

Four independent changes, one per user story (spec revised after analyze; research R0, R8):

1. **lrs (US1)**: pin the `binary` submodule at `10697a987`, whose Linux `lrs` starts
   without `libgmp.so.3`. Make `lrsRun` raise `lrsRun:commandFailed` on any non-zero exit
   status of lrs/redund, with the command, status and output. Fix the inverted
   shell-script status test and assign the output name in that branch (research R3).
2. **Console-capture filter (US2)**: testGenerateFullRowRankFR's `captureConsoleText`
   removes each named warning in full, whatever its -batch or desktop form (whitespace
   collapsed; brackets; backtrace block). This is the confirmed CI cause (research R8).
3. **testReconMap (US3)**: when the first upload is refused (`Access denied` /
   `Access is denied` in the console reply, captured with `diary`), restore the folder
   and raise `COBRA:RequirementsNotMet` (skip). Delete the unreachable credential branch
   (research R4).
4. **getRankLUSOL (US4)**: gate every explanatory `fprintf` on `printLevel > 0`. Replace
   `warning(ME.message)` with a once-per-session `getRankLUSOL:lusolFallback` warning that
   carries the message and the first stack frame, or "(no stack)". The "interface not on
   the path" branch uses the same warning (research R6).

## Technical Context

**Language/Version**: MATLAB (R2024b+ baseline; local R2026a Update 3)
**Primary Dependencies**: COBRA Toolbox; lrs (lrslib, shipped in `binary/glnxa64/bin/lrs`); LUSOL (`external/base/solvers/lusol`, `binary/glnxa64/lib/libclusol.so`)
**Storage**: files (lrs `.ine`/`.ext` in the test folder); `binary` git submodule
**Testing**: COBRA script tests run by `test/testAll.m` / `runScriptFile.m`. Locally, console-capture tests run with `matlab -batch` from the shell (research R0); the others run in the MCP session
**Target Platform**: Linux (CI: self-hosted runner, `matlab-cov` Docker image); lrs checks are Unix-only
**Project Type**: library (MATLAB toolbox)
**Performance Goals**: none beyond today's; a once-per-session warning bounds log volume
**Constraints**: no change to returned values (FR-006); warnings visible (VII-B); no new files in `src/`
**Scale/Scope**: 2 source files, 5 test files, 1 submodule pointer

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: no numerical statement changes. `getRankLUSOL` outputs
  are bit-for-bit identical (SC-004, checked by a baseline script on fixed matrices).
  `lrsRun` changes only how it reacts to failure. PASS.
- **Testing and reproducibility**: the narrowest tests are testLrsInterface (with the
  FR-002/FR-003 checks), testExtremePathways, testExtremePools,
  testGenerateFullRowRankFR (`-batch`), testReconMap (`-batch`) and testRank (fallback
  checks, `-batch`). Binary-bump regression set: research R5. Baseline script
  `getRankLUSOLBaseline.m` in the feature directory. PASS.
- **User experience and diagnostics**: intentional diagnostic change at printLevel 0
  (FR-008, Principle II), documented in the `getRankLUSOL` header NOTE. New error
  identifier `lrsRun:commandFailed` and warning identifier
  `getRankLUSOL:lusolFallback` (contracts/). PASS.
- **Performance and numerical integrity**: no solver behaviour or tolerance changes; no
  diagnostic step removed, only gated by `printLevel` (existing, documented). PASS.
- **External-solver configuration audit**: lrs and LUSOL options unchanged (research
  R7). N/A.
- **Spec-driven scope control**: edit only
  `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsRun.m`,
  `src/analysis/subspaces/rank/getRankLUSOL.m`, the test files listed in Project
  Structure, and the `binary` pointer. Read-only: `postMINERVArequest.m`,
  `buildFluxDistLayout.m`, `lrsWriteHalfspace.m`, `external/`, all binaries. PASS.
- **MATLAB coding standards**: no `evalc` (console capture by `diary`, as
  testGenerateFullRowRankFR already does); warnings visible; the new warning carries
  `ME.message` + `ME.stack(1).file/line` (VII-C); `exist(...,'var')` for options; help
  headers updated (VII-E). Skills consulted: `matlab-review-code` after edits. PASS.
- **Parameter-setting fidelity**: N/A (no ported/literate output).
- **Artifact placement**: tests stay in their folders. Temporary stand-ins (`lrs`,
  `lusol_obj.m`, `<model>.sh`) go to `tempname`/the test folder and are deleted by
  `onCleanup`. The baseline script lives in the feature directory, and its `.mat`
  output is gitignored there. PASS.

Post-design re-check: PASS (no violations; Complexity Tracking empty).

## Project Structure

### Documentation (this feature)

```text
specs/20261026-220121-fix-ci-test-failures/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── lrsRun.md
│   └── getRankLUSOL.md
├── getRankLUSOLBaseline.m      # created in tasks (SC-004)
└── tasks.md
```

### Source Code (repository root)

```text
binary                                                      # submodule pointer -> 10697a987
src/analysis/topology/extremeRays/lrs/lrsInterface/lrsRun.m # FR-002, FR-003, FR-010
src/analysis/subspaces/rank/getRankLUSOL.m                  # FR-006..FR-010
test/verifiedTests/analysis/testTopology/testLrsInterface.m           # FR-002/003 checks
test/verifiedTests/analysis/testTopology/testExtremePathways.m        # unchanged (runs)
test/verifiedTests/analysis/testTopology/testExtremePools.m           # unchanged (runs)
test/verifiedTests/analysis/testRank/testRank.m                       # FR-006..FR-008 checks
test/verifiedTests/analysis/testTopology/testGenerateFullRowRankFR.m  # FR-004 filter
test/verifiedTests/visualization/testReconMap/testReconMap.m          # FR-005, 005a, 005b
```

**Structure Decision**: existing toolbox layout; no new source files (research R1).

## Complexity Tracking

None.
