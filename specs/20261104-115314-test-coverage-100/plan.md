# Implementation Plan: Bring every test to 100% line coverage of its function (or documented exemptions)

**Branch**: `20261104-115314-test-coverage-100` | **Date**: 2026-11-04 | **Spec**: [spec.md](spec.md)

## Summary

Measure the line coverage of the function under test for each of the 527 mapped tests by
running each whole test script once under MATLAB's code-coverage plugin
(`tools/measureCoverage.m`), build `coverage-inventory.md` with a status per test
(`tools/build_inventory.py`), then close every GAP in batches by source domain: add independent
test sections that reach missed lines, or document exemptions with the constitution's reasons.
Re-measure, regenerate the defect registry, commit and push per batch.

## Technical Context

**Language/Version**: MATLAB R2025a; Python 3 for the inventory. **Primary Dependencies**:
COBRA Toolbox test harness (`runScriptFile`), `matlab.unittest` CodeCoveragePlugin (Cobertura).
**Storage**: JSON-lines measurement files in the feature folder (`coverage-runs/`).
**Testing**: each changed test re-run with the measurement tool. **Target Platform**: this
machine (reference) and CI. **Project Type**: MATLAB library (test back-fill).
**Constraints**: no `src/` change; existing assertions unchanged; tests keep their tier and
requirements. **Scale/Scope**: 527 mapped tests (78 out of scope).

## Constitution Check

*GATE: passed before research; re-checked after design: still passes.*

- **Scientific code quality**: `src/` read-only (III-Characterization).
- **Testing and reproducibility**: III-Coverage (goal and exemptions), III-Defects (defects
  recorded, inputs skipped, lines listed), III-Naming (no new test files for an existing
  function). Measurement tool and inventory are reproducible from the feature folder.
- **User experience and diagnostics**: new sections keep output minimal; no suppression.
- **Performance and numerical integrity**: tolerances justified in new assertions.
- **External-solver configuration audit**: no new solver use beyond what each test declares.
- **Spec-driven scope control**: only existing test files under `test/verifiedTests/`, the
  regenerated registry and this feature folder change.
- **MATLAB coding standards**: VII rules for test code.
- **Artifact placement**: measurement tools and data in the feature folder (not `src/`).

## Batches (by source domain of the function under test)

| Batch | Domain |
|-------|--------|
| B1 | src/base |
| B2 | src/analysis (A–M folders) |
| B3 | src/analysis (N–Z folders) |
| B4 | src/reconstruction |
| B5 | src/dataIntegration |
| B6 | src/design, src/visualization |

Batches are refined after the inventory (GAP counts per domain).

## Addendum: diagnosable failures in testCreateMetIntrcNetwork (FR-009)

CI on PR #2722 reported this test as failing with only `Assertion failed.`; 139 of 140 selected
tests passed and the test passes when run alone on the reference machine. The test gains
messages so that the next CI run names the failing check. This changes diagnostics only: it
does not fix the failure, which is addressed once its cause is known.

- Use `assert(condition, message, values...)`, keeping each condition exactly as it is.
- Format numbers with `mat2str` and text as it stands, so empty or array values still print.
- `verifyCobraFunctionError` returns only true or false, so a local function at the end of the
  test returns the message actually thrown, for the three expected-error checks. The shared
  helper in `test/` does not change, because other tests depend on it.
- Scope is this one test; other tests keep their current assertions.

## Complexity Tracking

No constitution violations; nothing to justify.
