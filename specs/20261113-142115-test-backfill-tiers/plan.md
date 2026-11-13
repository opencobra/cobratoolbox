# Implementation Plan: Bottom-up test back-fill with defect quarantine

**Branch**: `20261113-142115-test-backfill-tiers` | **Date**: 2026-11-13 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/20261113-142115-test-backfill-tiers/spec.md`

## Summary

Write characterization tests for the 1085 `src/` files that have none, bottom-up: Tier 1, 2, 3,
then 4/5, and within a tier callees before callers, from a static call graph
([research](research.md) R1–R4). A defect of severity wrong-result, error or unusable-option
quarantines the function (its test records the defect, asserts nothing) and blocks every untested
caller (R5, R6). Work proceeds in waves of functions whose callees are done; helper agents write
the tests of a wave in parallel (≤ 3 at a time, one memory-capped MATLAB session each) and return
result records; the lead integrates, propagates blocking and commits each wave (R7, R11). At the
end: registry regenerated, independent review, full suite, summary with coverage before/after, one
PR when the maintainer asks.

## Technical Context

**Language/Version**: MATLAB R2025a (tests); Python 3 (ledger tools).

**Primary Dependencies**: COBRA Toolbox test harness (`prepareTest`, `runScriptFile`,
`runTestSuite`), MATLAB `getcallinfo`, `matlab.unittest` CodeCoveragePlugin; Gurobi for Tier 3.

**Storage**: tab-separated ledger and JSON-lines results in the feature folder (`inventory/`).

**Testing**: each new test run with coverage (`tools/measureCoverage.m`, from feature
20261104-115314-test-coverage-100); each wave's tests re-run together; full suite at the end.

**Target Platform**: reference machine (Linux, R2025a, Gurobi, no paid toolboxes) and CI.

**Project Type**: MATLAB library — test back-fill (characterization).

**Performance Goals**: none imposed on tests (III-Coverage); the campaign's limit is memory: at most
3 MATLAB sessions at once, each memory-capped.

**Constraints**: no `src/` change (III-Characterization); one test per function (III-Naming);
quarantine rules (III-Defects 1.8.0, FR-007); no output or warning suppression (VII); no submodule
pointer commits; push only when asked.

**Scale/Scope**: 1085 untested files: 930 PENDING (Tier 1: 391, Tier 2: 226, Tier 3: 274,
Tier 4/5: 39) and 155 EXCLUDED at inventory (R1); 4 call cycles.

## Constitution Check

*GATE: passed before Phase 0; re-checked after Phase 1: passes.*

- **Scientific code quality (I, IV)**: no source change; Tier 3 tests check feasibility, bounds,
  status and objective, never one optimal flux vector among many.
- **Backward compatibility (II)**: no public interface touched (FR-010, FR-019).
- **Testing and reproducibility (III)**: III-Characterization (pin existing behaviour);
  III-Naming (one `test<Name>.m` per file, R8); III-Coverage (100% or documented exemptions, tier in
  header, `prepareTest` opening, memory rules; contract `contracts/test-file.md`); III-Defects with
  quarantine (constitution 1.8.0; FR-007 limits quarantine to three severities); registry
  regenerated (FR-013).
- **Spec-driven scope (V, VI)**: this spec/plan/tasks; implementation only after the maintainer's
  instruction ("continue with the speckit your self to the end", 2026-11-13).
- **MATLAB standards (VII)**: no `evalc`, no warning suppression, seeds fixed, no leftover state.
- **Polyglot (VIII)**: not affected (MATLAB tests only).
- **File placement (IX)**: tests under `test/verifiedTests/`; tools, ledger and results in the
  feature folder; no new top-level folder.
- **Single-sourcing (X)**: rules referenced, not restated; the test contract fixes layout only.
- **Receipt ledger**: `agent-runs/<UTC>-implement/implementation-receipt.md` at the end.

No violations; Complexity Tracking not needed.

## Project Structure

### Documentation (this feature)

```text
specs/20261113-142115-test-backfill-tiers/
├── spec.md, plan.md, research.md, data-model.md, quickstart.md
├── contracts/            # test-file.md, agent-result.md
├── tools/                # dumpCallGraph.m, build_inventory.py, measureCoverage.m,
│                         # update_ledger.py (blocking, waves, checks, summary)
├── inventory/            # callgraph-raw.tsv, ledger.tsv, extra-edges.tsv, quarantine.md,
│                         # summary.md, results/wave<NN>-<slice>.jsonl, coverage runs
├── review.md
├── checklists/
└── agent-runs/<UTC>-implement/implementation-receipt.md
```

### Source Code (repository root)

```text
test/verifiedTests/<category>/test<Area>/test<Name>.m   # new tests (≈930)
test/known-defects.md                                   # regenerated
src/                                                    # unchanged
```

**Structure Decision**: tests go into the existing category folders by source area (R8).

## Phases (for /speckit-tasks)

1. Setup: tools (`update_ledger.py`, copy of `measureCoverage.m`), sync the local models checkout
   (R8), coverage baseline (R10).
2. Tier 1 waves → 3. Tier 2 waves → 4. Tier 3 waves → 5. Tier 4/5 waves; each wave: form, write
   (agents), verify quarantines, integrate, re-run, commit.
6. Polish: registry, review, full suite, summary, receipt.

## Complexity Tracking

Not needed (no constitution violation).
