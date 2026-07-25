# Implementation Plan: Measure test coverage in CI and gate silent test-suite erosion

**Branch**: `001-ci-coverage-gating` | **Date**: 2026-07-13 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/001-ci-coverage-gating/spec.md`

## Summary

Make test coverage a first-class CI output, make requirement-gated tests skip (not
hard-fail) when a resource is absent, and surface/threshold the skipped-test count — all
without changing any scientific behaviour, public interface, model field, or solver-status
semantics. Technical approach: (1) provision the coverage tools the harness already knows how
to use (MoCov + jsonlab) inside the CI Docker run and set `MOCOV_PATH`/`JSONLAB_PATH` so
`test/testAll.m`'s existing coverage branch activates; emit a Cobertura XML in addition to the
existing `coverage.json`/`coverage_html`, always upload it as a CI artifact, and additionally
push to Codecov best-effort (`fail_ci_if_error: false`). (2) Backfill `prepareTest` requirement
declarations into all 169 currently-ungated tests under `test/verifiedTests/`, batched by the
six categories, using a repeatable audit of each test's solver/toolbox/OS/binary usage. (3) Add
a CI step that reads the `skipped=` count already present in `testReport.junit.xml`, compares it
to a committed baseline, and emits a GitHub warning (never a failure) when it rises.

## Technical Context

**Language/Version**: MATLAB R2024b+ (CI runs the `matlab` Docker image; local dev host is
R2026a). CI glue is GitHub Actions YAML + bash/node. Coverage tools MoCov + jsonlab are MATLAB.

**Primary Dependencies**: MoCov (`MOcov/MOcov`), jsonlab (`fangq/jsonlab`) — already referenced
by `test/testAll.m`; `codecov/codecov-action` (new, best-effort); `junit-to-ctrf` (existing).
`src/base/install/prepareTest.m` (existing gating function). No new MATLAB runtime dependency
enters the toolbox `src/`.

**Storage**: Coverage artifacts (`coverage.json`, `coverage_html/`, new `coverage.xml`) are
regenerable CI outputs (not committed). One committed data file: the skip-count baseline
(`test/verifiedTests/.skip-baseline.json` or equivalent).

**Testing**: The COBRA harness itself — `test/testAll.m` → `test/runTestSuite.m` (tests run as
scripts; skip = `COBRA:RequirementsNotMet`). Feature validation reuses this harness plus the
MATLAB MCP for a local skip/coverage smoke check.

**Target Platform**: Headless Linux in Docker (CI); cross-platform for the test metadata.

**Project Type**: Scientific MATLAB library with a CI/test harness (single project).

**Performance Goals**: MoCov profile-based instrumentation adds wall-clock to the suite; keep
the added time within a bound recorded in research.md (target: ≤ ~20% over the uninstrumented
run, measured on one CI run) so the ~60-min suite does not time out.

**Constraints**: No change to scientific/model behaviour, public interfaces, model fields, or
`.stat`/`.origStat` semantics. Codecov upload MUST be non-blocking. Skip gate MUST NOT fail the
build on rollout. CI has only the gurobi commercial solver + open-source solvers.

**Scale/Scope**: 260 tests total; **169 ungated** to backfill (91 already gated; base 51, analysis 42,
reconstruction 38, visualization 17, dataIntegration 12, design 9); 3 CI-config surfaces
(`testAllCI_step1.yml`, coverage-upload step, skip-gate step); at most a 1-line additive change
to `test/testAll.m` (add a Cobertura output path to the existing `mocov(...)` call).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: No formulation/solver/model interface is touched. The only
  possible `src/` edit is additive test metadata is in `test/`, not `src/`; the harness change
  (if any) adds an output-file argument to an existing `mocov` call and does not alter test
  outcomes. Model-field and solver-status contracts (Principle I/II/IV) are untouched.
- **Testing and reproducibility**: Narrowest check — run one requirement-gated test (e.g.
  `test/verifiedTests/base/testSolvers/testSolveCobraLP.m` after backfill) with no LP solver and
  confirm it is **skipped** (raises `COBRA:RequirementsNotMet`), then with a solver present and
  confirm it **runs/passes** unchanged; confirm `testAll.m` prints a coverage percentage and a
  skipped count when `MOCOV_PATH`/`JSONLAB_PATH` are set. Reproducible locally via the MATLAB MCP
  (host R2026a has only M2HTML + Matrix Computation toolboxes, so most solver-gated tests skip —
  a natural skip-path test).
- **User experience and diagnostics**: Coverage % and skip count appear in CI logs, a coverage
  artifact, a best-effort Codecov PR comment, and a GitHub `::warning::` when skips exceed
  baseline. The existing CTRF pass/fail PR comment is preserved. No new console noise in normal
  local runs (coverage stays gated behind the env vars).
- **Performance and numerical integrity**: Only added cost is MoCov instrumentation wall-clock
  (bounded, see research.md). No solver path, tolerance, residual, or objective is changed;
  performance is strictly subordinate and here irrelevant to solution quality. No
  debug/verification step is removed.
- **External-solver configuration audit**: No *external solver* is invoked by this feature
  (coverage/CI tooling only). The analogous audit for the tools introduced — MoCov options
  (`-cover_method profile` vs `file`, output formats), jsonlab, and `codecov-action`
  (`fail_ci_if_error`, `token`, `files`) — is done in research.md and cross-checked against the
  headless-Docker/gurobi-only environment. Solver *requirements* declared in backfilled tests
  use `prepareTest`'s existing keys and change no solver behaviour.
- **Spec-driven scope control**: **Edit** — `.github/workflows/testAllCI_step1.yml` (+ optional
  new upload/gate steps), `test/testAll.m` (at most one additive `mocov` output arg),
  `test/verifiedTests/**/test*.m` (add `prepareTest` calls only), a new committed skip baseline
  file, and an audit-record file under `specs/001-ci-coverage-gating/`. **Do NOT edit** — any
  `src/` scientific code, model schema, solver dispatch, `deprecated/`, `external/`, `binary/`.
  New dependency justification: MoCov + jsonlab are already assumed by `testAll.m`; provisioning
  them in CI is the missing wiring, not a new abstraction.
- **MATLAB coding standards**: Backfill adds `prepareTest(...)` calls at the top of each test in
  the openCOBRA style (spaces around operators, `camelCase`, no `evalc` suppression, warnings
  visible). Any harness edit keeps `try/catch` propagating `ME.stack` and adds no `nargin`
  logic. The MATLAB coding-guideline resource (MCP `guidelines://coding`) is consulted for the
  edits.
- **Parameter-setting fidelity**: N/A — this feature renders no ported/literate output; it
  changes CI config and test metadata only.
- **Artifact placement (Principle IX)**: CI config → `.github/workflows/` (existing). Test
  requirement metadata → beside the tests it gates in `test/verifiedTests/` (existing). Skip
  baseline (small tracked data) → `test/verifiedTests/.skip-baseline.json`. Coverage outputs
  (`coverage.json/.xml/_html`) are regenerable → produced in the run root, uploaded as CI
  artifacts, **not committed** (add to `.gitignore` if they would otherwise be tracked). The
  per-test audit record → `specs/001-ci-coverage-gating/audit/` (planning artifact). No `src/`
  generated output introduced.

**Result: PASS** (no violations; Complexity Tracking empty).

## Project Structure

### Documentation (this feature)

```text
specs/001-ci-coverage-gating/
├── plan.md              # This file
├── research.md          # Phase 0: config-surface audit + decisions
├── data-model.md        # Phase 1: entities (coverage report, requirement declaration, skip baseline)
├── quickstart.md        # Phase 1: how to validate locally + in CI
├── contracts/           # Phase 1: CI-output contract, prepareTest-declaration contract, skip-gate contract
│   ├── ci-outputs.md
│   ├── prepareTest-declaration.md
│   └── skip-gate.md
├── audit/               # Phase 2/impl: per-test backfill audit record (auditability, FR-006)
├── checklists/          # requirements.md (spec quality) + ci-coverage.md (requirements quality)
├── human-loop.md        # orchestration state
└── tasks.md             # Phase 2 output (/speckit-tasks) — NOT created by /speckit-plan
```

### Source Code (repository root) — files this feature touches

```text
.github/workflows/
├── testAllCI_step1.yml      # EDIT: provision MoCov+jsonlab, set MOCOV_PATH/JSONLAB_PATH,
│                            #       add coverage-artifact upload + best-effort Codecov + skip-gate steps
└── testAllCI_step2.yml      # (unchanged) CTRF PR comment

test/
├── testAll.m                # EDIT (minimal, additive): add Cobertura output to the existing mocov(...) call
├── runTestSuite.m           # (unchanged) skip detection via COBRA:RequirementsNotMet
└── verifiedTests/           # EDIT: add prepareTest(...) to the 169 ungated test*.m (batched by category)
    ├── base/                #   51 ungated
    ├── analysis/            #   42 ungated
    ├── reconstruction/      #   38 ungated
    ├── dataIntegration/     #   12 ungated
    ├── design/              #    9 ungated
    ├── visualization/       #   17 ungated
    └── .skip-baseline.json  # NEW (tracked): recorded skipped-test-count baseline

codecov.yml                  # (unchanged config; now actually fed by CI)
src/base/install/prepareTest.m  # READ-ONLY reference (the gating mechanism; not edited)
```

**Structure Decision**: Single-project MATLAB toolbox. All changes are confined to CI config
(`.github/workflows/`), the test harness reporting glue (`test/testAll.m`, one additive line),
test requirement metadata (`test/verifiedTests/`), and one small tracked baseline file. No
`src/` scientific code is modified.

## Complexity Tracking

> No constitution violations — table intentionally empty.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| — | — | — |
