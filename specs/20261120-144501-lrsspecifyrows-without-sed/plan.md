# Implementation Plan: lrsSpecifyRows without sed

**Branch**: `20261113-142115-test-backfill-tiers` (open pull request; maintainer, 2026-11-20) |
**Date**: 2026-11-20 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/20261120-144501-lrsspecifyrows-without-sed/spec.md`

## Summary

`lrsSpecifyRows` replaces `*****` with the row count by reading the file into MATLAB, `regexprep`,
and writing it back, instead of running GNU `sed -i`. It closes its file identifier and raises its
documented error for a file it cannot open, which fixes the two defects recorded in its test. The
test becomes Tier 1 with no requirement, and testLrsRun's minimal `PATH` drops sed. See
[research.md](research.md).

## Technical Context

**Language/Version**: MATLAB R2024b or newer (tested on R2025a)

**Primary Dependencies**: none (base MATLAB: fopen/fread/fwrite/regexprep)

**Storage**: the lrs text file, rewritten in place

**Testing**: testLrsSpecifyRows and testLrsRun with coverage; lrs-related tests as callers

**Target Platform**: any MATLAB platform (before: Unix with GNU sed)

**Project Type**: library function

**Performance Goals**: lrs files are small to medium; one read and one write, as sed did

**Constraints**: byte-for-byte the same output as the sed version (FR-002); interface kept (II)

**Scale/Scope**: lrsSpecifyRows.m, testLrsSpecifyRows.m, one line of testLrsRun.m, records

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: Exact row counting is unchanged. Only the text-substitution mechanism
  changes. Interface in [contracts/lrsSpecifyRows.md](contracts/lrsSpecifyRows.md).
- **Testing and reproducibility**: testLrsSpecifyRows (Tier 1, no requirement, including an
  empty-`PATH` run) and testLrsRun with coverage; callers (quickstart).
- **User experience and diagnostics**: The missing-file error now carries its intended message.
  The 'sed failed' error disappears together with sed.
- **Performance and numerical integrity**: No numerical change; no diagnostic removed except the
  sed failure, which cannot occur any more.
- **External-solver configuration audit**: N/A; no external program at all.
- **Dependency minimisation**: Removes GNU sed. Option 1 of Principle XI (base MATLAB). After this
  change lrsSpecifyRows has no dependency, and lrsRun needs only lrs, plus `which` and a shell, which
  every Unix provides.
- **Spec-driven scope control**: Edit `src/analysis/topology/extremeRays/lrs/lrsInterface/
  lrsSpecifyRows.m`, `test/verifiedTests/analysis/testLrsInterface/testLrsSpecifyRows.m`, and the
  program list in `testLrsRun.m`. Records: ledger rows, registry (regenerated), the back-fill
  review.md, `pr-note.md`.
- **MATLAB coding standards**: No evalc, no warning suppression, no nargin, header help updated
  with a dated note (VII-E).
- **Parameter-setting fidelity**: N/A.
- **Artifact placement**: Feature records under this feature folder only.

**Gate result**: PASS.

## Project Structure

```text
specs/20261120-144501-lrsspecifyrows-without-sed/   spec, plan, research, data-model, contracts/, quickstart, tasks, receipt
src/analysis/topology/extremeRays/lrs/lrsInterface/lrsSpecifyRows.m
test/verifiedTests/analysis/testLrsInterface/testLrsSpecifyRows.m
test/verifiedTests/analysis/testLrsInterface/testLrsRun.m              (minimal PATH: lrs, which)
```

**Structure Decision**: existing files only.

## Design

1. `lrsSpecifyRows`:
   - Keep the relative-name rule.
   - `fid = fopen(name, 'r+')`; on failure, raise 'Could not open lrs output file.'
   - `text = fread(fid, Inf, '*char')'`, then `fclose(fid)`.
   - Count by the current loop rule over `strsplit(text, newline, 'CollapseDelimiters', false)`,
     raising 'Could not read lrs output file.' if no `end` is reached.
   - `text = regexprep(text, '\*\*\*\*\*', int2str(nRows))`.
   - `fid = fopen(name, 'w')`, `fwrite(fid, text)`, `fclose(fid)`.
   - `status = 0; result = '';`
   - Header: outputs, and a NOTE dated with this feature.
2. `testLrsSpecifyRows`:
   - Header: Tier 1, no requirement; defects removed; exemptions none.
   - `prepareTest()`; no sed or GNU check.
   - Assert no open identifiers left after each call, instead of closing leftovers.
   - New sections:
     - a missing file, giving the documented error;
     - several placeholders and a six-star run, checked against the GNU sed results;
     - a run with `PATH` empty;
     - a file without `end`.
   - The failing-sed section is replaced, since there is no sed to fail.
3. `testLrsRun`: `runWithOnlyPrograms({'lrs', 'which'}, ...)` and its comments.

## Complexity Tracking

None.
