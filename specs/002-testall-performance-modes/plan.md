# Implementation Plan: testAll performance modes

**Branch**: `002-testall-performance-modes` | **Date**: 2026-07-13 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/002-testall-performance-modes/spec.md`

## Summary

Add two capabilities to the COBRA Toolbox test harness without changing what any
test asserts: (1) a **fast (default) vs full** execution mode that removes
redundant work — chiefly per-test loops over every installed solver when the
assertions are solver-independent, plus large-model re-parsing, dead waits, and
duplicated model builds — with an explicit, documented revert to the complete
full-mode behaviour; and (2) an **opt-in profiling report** that surfaces a ranked
per-test timing table and MATLAB-profiler hotspots. CI runs full mode so the
`001-ci-coverage-gating` gate is unaffected; fast mode may reduce measured
coverage by at most 5 percentage points (absolute).

The mechanism centres on a single mode resolver and on the **existing**
`prepareTest` `useMinimalNumberOfSolvers` capability: in fast mode `prepareTest`
returns the default (single) solver per class unless a test explicitly requests
multiple solvers, transparently trimming the many tests that loop over
`prepareTest`'s returned lists. Tests that hardcode multi-solver cell arrays get a
small mode-aware edit; tests whose purpose IS cross-solver agreement keep all
solvers in both modes.

## Technical Context

**Language/Version**: MATLAB (R2026a locally; harness supports R2014b+)

**Primary Dependencies**: COBRA Toolbox test harness (`test/testAll.m`,
`test/runTestSuite.m`, `test/runScriptFile.m`), `src/base/install/prepareTest.m`,
MATLAB profiler (`profile`/`profsave`), MoCov (coverage, from feature 001).

**Storage**: Regenerable run artifacts (timing CSV, profiler HTML) written to a
gitignored output location; no persistent data store.

**Testing**: The COBRA test suite itself is the system under change. Verification
uses a fast-vs-full comparison over a representative subset plus per-test pass
checks in both modes, run via the MATLAB MCP server.

**Target Platform**: Linux/macOS/Windows (MATLAB); CI via `COBRA_CI=1`.

**Project Type**: MATLAB library + script-based test harness (single project).

**Performance Goals**: Fast mode reduces full-suite wall-clock by ~40–50% on a
multi-solver machine (SC-001); no change to any solve's objective/residual/status.

**Constraints**: Full mode byte-for-behaviour identical to today (FR-004); no
change to assertions, expected values, tolerances, or public interfaces (FR-006);
fast-mode coverage within 5 pp absolute of full (FR-003); CI = full (FR-012).

**Scale/Scope**: 260 test files (~235 executed); runtime concentrated (top 10
tests ≈ 51% of 824.8 s). Fast-mode edits target the ~15–20 highest-cost tests plus
the shared `prepareTest` hook.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: No formulation, solver formulation, model math, or
  public interface is touched. Changes are confined to test-orchestration
  (how many solvers/models a test exercises) and to a solver-*selection* default in
  `prepareTest`. Objective/flux/residual/status semantics are unchanged; full mode
  reproduces current behaviour exactly.
- **Testing and reproducibility**: Narrowest checks — (a) each modified test still
  passes in both fast and full mode via `mcp__matlab__run_matlab_test_file`;
  (b) a fast-vs-full comparison over a representative subset (wall-time lower;
  pass/fail identical; coverage within 5 pp) via a quickstart script. Coverage
  measured with the existing MoCov path from feature 001.
- **User experience and diagnostics**: Mode is selected by a documented control
  (env var + optional global), default fast, CI forced full. The profiling report
  prints the slowest tests and writes a CSV + profiler HTML only when enabled;
  warnings stay visible; a backward-compat note documents the new default.
- **Performance and numerical integrity**: Fast mode reduces redundant *repetition*
  of solves, never the quality of any individual solve — objective, residual,
  status, and certificate quality are untouched. Per the constitution's
  "skippable verification must stay default-on": the cross-solver re-validation
  that fast mode trims **remains default-on in CI (full mode, FR-012)** and is
  always available locally via full mode; it is only the *local convenience default*
  that favours speed. This deliberate default is tracked in Complexity Tracking.
- **External-solver configuration audit**: N/A for solver *configuration* — no
  solver option/parameter/default is changed. Fast mode only reduces the *count* of
  solvers looped, choosing the already-configured class default (LP=mosek,
  MILP=gurobi locally) as the representative. No new solver settings introduced.
- **Spec-driven scope control**: Edit — `test/testAll.m` (mode resolve + profiling
  report), `src/base/install/prepareTest.m` (fast-mode minimal-solver default), new
  `src/base/install/getCobraTestMode.m` (mode resolver), and a bounded set of
  `test/verifiedTests/**/test*.m` (the highest-cost solver-looped / large-model /
  dead-wait tests). Read-only — all solver internals, `src/` analysis/algorithm
  code, expected-result `.mat` fixtures. New regenerable artifacts gitignored.
- **MATLAB coding standards**: No `evalc` suppression or built-in shadowing;
  warnings remain visible; the profiling block uses try/catch that warns (never
  swallows) and does not fail the run; error stacks propagate; no `nargin`-based
  logic added; MATLAB testing/review skills consulted during implementation.
- **Parameter-setting fidelity**: N/A — no ported/literate/cross-language output.
- **Artifact placement**: New source helper under `src/base/install/` (beside
  `prepareTest`), source only. Profiling/timing artifacts are regenerable → written
  to a gitignored output dir (`test/performance/`, added to `.gitignore`), never
  committed. Test edits stay beside their tests. No file moves.

## Project Structure

### Documentation (this feature)

```text
specs/002-testall-performance-modes/
├── plan.md              # This file
├── research.md          # Phase 0 — decisions (folds in the slow-test analysis)
├── data-model.md        # Phase 1 — mode, timing record, artifacts
├── quickstart.md        # Phase 1 — fast-vs-full + profiling validation
├── contracts/           # Phase 1 — mode-control, solver-helper, profiling-report
│   ├── mode-control.md
│   ├── solver-selection.md
│   └── profiling-report.md
├── checklists/
│   └── requirements.md  # from specify (all pass)
├── human-loop.md        # orchestration state
└── tasks.md             # Phase 2 (/speckit-tasks — not created here)
```

### Source Code (repository root)

```text
src/base/install/
├── prepareTest.m          # EDIT: fast-mode → minimal (default) solver set unless
│                          #       the test explicitly requests multiple solvers
└── getCobraTestMode.m     # NEW: resolve effective mode ('fast'|'full');
                           #      default fast; COBRA_CI=1 → full; global override

test/
├── testAll.m              # EDIT: resolve mode; run profiling report when enabled
├── runTestSuite.m         # (read-only unless a mode-pass-through is needed)
└── verifiedTests/**/test*.m  # EDIT (bounded set): reduce hardcoded multi-solver
                              #   loops in fast mode; .mat vs large SBML; drop dead
                              #   waits; skip plot-only work; dedupe model builds

.gitignore                 # EDIT: ignore test/performance/ run artifacts
documentation/source/...    # EDIT: contributor note (fast default + how to revert)
```

**Structure Decision**: Single MATLAB project. The mode resolver lives in
`src/base/install/` beside `prepareTest` (the natural home for test-prerequisite
tooling and the place the solver-trimming hook is implemented). The harness edits
stay in `test/`. This keeps source under `src/`, test infra under `test/`, and
regenerable artifacts out of version control (Principle IX).

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|--------------------------------------|
| Fast is the **default**, so cross-solver re-validation is default-off locally (tension with "skippable verification stays default-on") | The feature's explicit purpose (and the user's request) is a faster suite *by default* with an opt-in return to full rigor | Making full the default was rejected: it defeats the feature's stated goal. Mitigations keep it constitutional in spirit — CI runs full by default (FR-012) so authoritative verification is default-on where it gates; full mode is always available and documented; fast-mode coverage is bounded to ≤5 pp drop. |
