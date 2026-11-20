# Implementation Plan: Help text matches the code

**Branch**: `20261120-151023-doc-matches-code` | **Date**: 2026-11-20 | **Spec**: [spec.md](spec.md)

## Summary

There are two parts. First, correct comment text so that it describes the code: the cosmetic entries
that are text/code mismatches, and the help of five quarantined functions, guarded by
`tools/comment_only_check.py`. Second, write full tests for the five functions this clears and for
the one caller it unblocks, measured with the back-fill feature's coverage tools.

## Technical Context

**Language/Version**: MATLAB R2024b+ (tested on R2025a); Python 3 for the guard and ledger tools

**Primary Dependencies**: the back-fill feature's tools (`specs/20261113-142115-test-backfill-tiers/tools/`: `run_coverage.sh`, `update_ledger.py`), `.github/scripts/known_defects.py`

**Storage**: N/A

**Testing**: the changed source files' tests (runScriptFile), with coverage for new tests

**Target Platform**: as the toolbox

**Project Type**: library documentation and tests

**Performance Goals**: N/A

**Constraints**: no non-comment change in `src/`, and line counts kept (FR-001); Principle III tests

**Scale/Scope**: about 144 cosmetic entries reviewed, 5 help-text quarantines, 6 new full tests

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: No code changes, so results are unchanged. A text fix records the
  code's behaviour only where that behaviour is evidently deliberate. Slips stay as defects
  (spec, US1-3).
- **Testing and reproducibility**: Every test of a changed file is re-run. The new tests are run with
  coverage and checked with `--verify-coverage`.
- **User experience and diagnostics**: Help text becomes accurate. Messages stay as they are (out of
  scope).
- **Performance and numerical integrity**: Unchanged.
- **External-solver configuration audit**: N/A, no solver code changes. The new tests use the
  solvers prepareTest provides.
- **Dependency minimisation**: None added. New tests use base MATLAB and free solvers where they need
  any (Principle XI).
- **Spec-driven scope control**:
  - Edit: comment lines of `src/` files with a classified entry, the test headers of those entries,
    the five quarantine tests (to full tests), a new test for deltaG0concFluxConstraintBounds, and
    the back-fill ledger, registry and review.
  - Read-only: code lines, `external/`, `binary/`.
- **MATLAB coding standards**: Test conventions of the back-fill contract
  (`specs/20261113-142115-test-backfill-tiers/contracts/test-file.md`); no evalc and no warning
  suppression.
- **Parameter-setting fidelity**: N/A.
- **Artifact placement**: Records in this feature folder; tests in `test/verifiedTests/`.

**Gate result**: PASS.

## Design

1. **Cosmetic pass.** Five helper agents run in parallel, one per slice
   (`inventory/cosmetic-slice-N.txt`). They receive only the code, the tests and the brief
   (`inventory/cosmetic-brief.md`), and they do not run MATLAB. Each entry is classified:
   - A: text/comment mismatch, text fixed;
   - B: message, printing or behaviour, kept;
   - C: the code is the evident slip, kept and reported.

   Each class-A entry is removed from its test header. Records go to `inventory/results/`. The lead
   checks every A against the code (second reader) and runs the guard.
2. **Quarantines.** The lead corrects the help of the five functions and rewrites their quarantine
   tests as full tests. The wave versions in git history are the starting point, where they exist.
   The lead writes the test for deltaG0concFluxConstraintBounds. The ledger moves the rows to
   TESTED, and blocked rows drop the cleared blockers from their reasons.
3. **Verification.**
   - Run the guard.
   - Run the tests of every changed source file (runScriptFile).
   - Measure the six new tests with coverage and run `--verify-coverage`.
   - Regenerate the registry and run `--check`.
4. **Records.** Back-fill review.md item 2, a receipt, and a privacy scan. Commit, then push the new
   branch.

## Complexity Tracking

None.
