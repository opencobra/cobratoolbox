# Implementation Plan: lrsRun without the separate redund program

**Branch**: `20261113-142115-test-backfill-tiers` (open pull request; maintainer, 2026-11-20) |
**Date**: 2026-11-20 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/20261120-140123-lrsrun-without-redund/spec.md`

## Summary

With `param.redund = 0` and facet enumeration, `lrsRun` removes redundant inequalities by running
`lrs` a second time, on a temporary copy of lrs's facet output that ends with the option line
`redund 0 0`. The separate program `redund` is no longer called. The copy is removed by an
`onCleanup` object. The switched-off `sed` route and the unused `redundCmd` are removed. `testLrsRun`
then declares only `lrs` and checks the new route, including a run with no `redund` on the `PATH`.
See [research.md](research.md) for the evidence that lrs and redund give the same result.

## Technical Context

**Language/Version**: MATLAB R2024b or newer (tested on R2025a)

**Primary Dependencies**: lrs from lrslib 7 or later (already required by lrsRun); POSIX shell for
`system`

**Storage**: lrs input/output text files in the caller's working folder; one temporary file in the
system temporary folder

**Testing**: `test/verifiedTests/analysis/testLrsInterface/testLrsRun.m` via `runScriptFile`, with
coverage of `lrsRun.m` (the back-fill feature's `run_coverage.sh`); callers' tests
`testExtremePools`, `testExtremePathways`

**Target Platform**: Unix (Linux, macOS), as lrsRun today; non-Unix unchanged (prints "not yet
supported")

**Project Type**: library (COBRA Toolbox function)

**Performance Goals**: one extra lrs run replaces one redund run; same work

**Constraints**: interface, file names and error identifier unchanged (Principle II); no file
modified or left behind beyond what lrsRun wrote before

**Scale/Scope**: 2 files (`lrsRun.m`, `testLrsRun.m`) plus feature records

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: Exact polyhedral computation stays in lrs (exact/hybrid arithmetic).
  The result is the same irredundant H-representation as `redund` (research R1). Interface unchanged
  ([contracts/lrsRun.md](contracts/lrsRun.md)).
- **Testing and reproducibility**: `testLrsRun` with coverage, and once with `redund` hidden from the
  `PATH`; `testExtremePools` and `testExtremePathways` as caller checks (quickstart).
- **User experience and diagnostics**: The printed command line now shows the lrs call with the
  option. `lrsRun:commandFailed` names the failing command and its status, as today.
- **Performance and numerical integrity**: No change in arithmetic or amount of work; no
  verification step removed.
- **External-solver configuration audit**: N/A for optimisation solvers. lrs runs with its defaults
  plus `redund 0 0` (research R5).
- **Dependency minimisation**: Removes the program `redund`. Option 2 of Principle XI: lrs, already
  required, does the job. Remaining dependency: lrs itself, which is free and open source, bundled by
  COBRA for Linux, macOS and Windows, and the subject of this interface, so no earlier option
  applies. testLrsRun's requirement `lrs` is stated in its header.
- **Spec-driven scope control**: Edit `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsRun.m`
  and `test/verifiedTests/analysis/testLrsInterface/testLrsRun.m`. Read-only: `binary/`,
  `external/`, `lrsSpecifyRows`, the readers. Recorded in the back-fill feature's review.md and the
  pull request description: the pull request no longer leaves `src/` untouched.
- **MATLAB coding standards**: No evalc, warnings visible, no nargin added (existing `exist` /
  `isfield` defaults kept), `onCleanup` for the temporary file, header help updated (VII-E).
- **Parameter-setting fidelity**: N/A (no ported or literate output).
- **Artifact placement**: No new tracked files outside `specs/20261120-140123-lrsrun-without-redund/`.
  The temporary file lives in the system temporary folder and is deleted.

**Gate result**: PASS; no violations.

## Project Structure

### Documentation (this feature)

```text
specs/20261120-140123-lrsrun-without-redund/
├── spec.md
├── plan.md              # this file
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/lrsRun.md
├── checklists/requirements.md
└── tasks.md             # /speckit-tasks
```

### Source Code (repository root)

```text
src/analysis/topology/extremeRays/lrs/lrsInterface/
└── lrsRun.m                 # redundancy step: lrs with the redund option on a temporary copy
test/verifiedTests/analysis/testLrsInterface/
└── testLrsRun.m             # requirement lrs only; checks of the new route; run without redund
```

**Structure Decision**: existing files only; no new source or test file.

## Design

1. In `lrsRun`, branch `param.facetEnumeration && param.redund == 0`:
   - After `lrsSpecifyRows(fileNameIn)` (kept), read `fileNameIn`.
   - Write the text, a newline if it does not end with one, and `redund 0 0` followed by a newline to
     `optionFile = [tempname '.ine']`; register `onCleanup` to delete it.
   - `systemCallText = ['lrs ' optionFile ' > ' pwd filesep fileNameOut]`.
   - `localCallText = ['lrs ' fileNameIn ' (with option redund 0 0) > ' fileNameOut]`, which is
     printed. Then `system` runs, followed by `checkCommandStatus`.
   - Remove `uselrsRedundOption`, the `sed` route, and the unused `redundCmd` block (lines 89-93).
2. Header: `.redund` describes "remove redundant inequalities (lrs's redund option)", and the NOTE
   names lrs and the shell script only, with a dated line on this change (VII-E).
3. `testLrsRun`:
   - `prepareTest('requiredSoftwares', {'lrs'})`.
   - In the redund section, check the result, that `q7_noR.ine` is unchanged (still holds the trivial
     row), and that no file other than the expected ones is created in the work folder or left in
     `tempdir`.
   - Add a run with `PATH` set to a folder holding only a link to lrs and `which`, so redund cannot
     be found.
   - Add a failing lrs in the redundancy step: a stand-in `lrs` script that succeeds for the first
     call and fails when its input contains `redund 0 0`, which raises `lrsRun:commandFailed`.
   - Update the coverage exemptions (lines 133-135 disappear) and the header (requirements, Authors
     line).

## Complexity Tracking

None.
