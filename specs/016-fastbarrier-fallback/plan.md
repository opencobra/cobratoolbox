# Implementation Plan: FastBarrier Fallback

**Branch**: `016-fastbarrier-fallback` | **Date**: 2026-08-14 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/016-fastbarrier-fallback/spec.md`

## Summary

Add a reliability fallback for FVA fastBarrier solves: when the no-crossover fast path
encounters a recoverable numerical solver status and returns no usable solution, retry the
same reaction-bound LP with barrier crossover enabled or left at the solver default. The
fallback is scoped to `fastBarrier` in `fluxVariability`; ordinary FVA behaviour, public
arguments, output shapes, and error semantics stay unchanged. Validation is anchored by the
existing `testFVA` regression that currently fails in the fastBarrier section on the local
Gurobi-enabled MATLAB installation.

## Technical Context

**Language/Version**: MATLAB, local validation on R2025a; compatible with the COBRA
Toolbox MATLAB baseline used by CI.

**Primary Dependencies**: COBRA Toolbox FVA and solver abstraction functions
(`fluxVariability`, `solveCobraLP`, `solveCobraMILP`, `changeCobraSolver`,
`CobraSolverState`); Gurobi backend for fastBarrier mode. No new third-party dependency.

**Storage**: N/A. The feature operates on in-memory COBRA model structs and solver result
structs only.

**Testing**: Existing MATLAB verified test
`test/verifiedTests/analysis/testFVA/testFVA.m`; focused local probes may be used during
implementation to reproduce the PFK/PPS numeric-status cases before the full test run.

**Target Platform**: Headless MATLAB on Linux with Gurobi available; ordinary FVA must keep
skipping or passing according to existing `prepareTest` solver requirements.

**Project Type**: MATLAB scientific library, single project.

**Performance Goals**: Preserve the successful no-crossover fast path. Invoke the retry only
for recoverable numeric-status failures, so successful fastBarrier reactions add no extra
solver call. Correct flux bounds take priority over speed.

**Constraints**: No public interface change; no new fastBarrier user option; no change to
ordinary FVA or loopless FVA semantics; no silent conversion of infeasible/unbounded models
into finite flux values; solver warnings remain visible; active LP solver state is restored
after success and failure.

**Scale/Scope**: One source file (`src/analysis/FVA/fluxVariability.m`) and the existing FVA
verified test (`test/verifiedTests/analysis/testFVA/testFVA.m`) are in scope for later
implementation. Spec Kit artifacts live under `specs/016-fastbarrier-fallback/`.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: Touches reaction-level FVA min/max flux solves and solver
  status handling in `fluxVariability`. Stoichiometry, reaction bounds, objective
  coefficients, optimality percentage constraint, objective sense, and reaction ordering must
  remain unchanged between first attempt and fallback. Returned flux values must be derived
  from a valid solver solution, never from an error status or missing primal vector.
- **Testing and reproducibility**: Narrowest proof is the existing
  `test/verifiedTests/analysis/testFVA/testFVA.m` fastBarrier section, run through MATLAB with
  Gurobi available. Implementation may add a small assertion around the fallback-triggering
  reactions if needed, but must not weaken existing standard-vs-fastBarrier comparisons.
  Validation command is documented in [quickstart.md](./quickstart.md).
- **User experience and diagnostics**: Users still call `fluxVariability(...,
  'fastBarrier', 1)` with no new option. Successful fallback is transparent except for any
  existing solver diagnostics that naturally surface. If fallback also fails, the existing
  FVA failure path remains visible rather than returning partial or bogus values.
- **Performance and numerical integrity**: First choice remains the fast no-crossover barrier
  path. Retry is conditional on recoverable numerical failure only. The retry must match
  standard FVA flux bounds within the established `testFVA` tolerance; correctness and solver
  status validity are explicitly higher priority than avoiding the retry.
- **External-solver configuration audit**: Required. Gurobi LP configuration surface relevant
  here is `Method` and `Crossover`, passed through `solveCobraLP` after filtering by
  `setGurobiParam`. Representative local instance: `Ec_iJR904` FVA on `PFK` and `PPS`, where
  barrier with no crossover returned native status `NUMERIC`, while default solve, simplex,
  and barrier with crossover returned `OPTIMAL`. Decision and alternatives are recorded in
  [research.md](./research.md).
- **Spec-driven scope control**: Later source edits are limited to
  `src/analysis/FVA/fluxVariability.m` and, only if necessary to assert solver-state or
  fallback behaviour, `test/verifiedTests/analysis/testFVA/testFVA.m`. Do not edit
  `external/`, `deprecated/`, `binary/`, or archived paths. No migration and no new
  dependency.
- **MATLAB coding standards**: Implementation must avoid `evalc`, warning suppression, and
  `nargin`-driven new optional-argument handling. Any new `try/catch` must preserve full
  `ME` stack. Keep output gated by existing `printLevel` conventions. Before implementation,
  the implementer must search for any available MATLAB coding/linting skill; if none exists,
  use openCOBRA/MATLAB conventions already cited by the constitution.
- **Parameter-setting fidelity**: N/A. This feature does not render code into another
  language or literate document.
- **Artifact placement**: Spec Kit artifacts under `specs/016-fastbarrier-fallback/`.
  Source remains under `src/analysis/FVA/`; test remains under
  `test/verifiedTests/analysis/testFVA/`. No generated diaries, `.mat` probes, or logs are
  committed.

**Result**: PASS (initial). No Constitution Check violations are required.

**Post-design re-check**: PASS. Phase 0 and Phase 1 artifacts keep the feature scoped to a
conditional retry inside FVA, preserve solver abstraction by continuing through
`solveCobraLP`, and keep validation in the existing verified MATLAB test harness.

## Project Structure

### Documentation (this feature)

```text
specs/016-fastbarrier-fallback/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── fluxVariability-fastBarrier.md
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 output (/speckit-tasks; not created by /speckit-plan)
```

### Source Code (repository root)

```text
src/analysis/FVA/
└── fluxVariability.m

test/verifiedTests/analysis/testFVA/
└── testFVA.m
```

**Structure Decision**: Single MATLAB-library feature. The fallback belongs in the FVA
analysis implementation because it is specific to the fastBarrier option and must preserve
the existing `fluxVariability` public contract. The existing FVA verified test remains the
primary regression surface.

## Complexity Tracking

*No Constitution Check violations to justify; this table is intentionally empty.*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| (none) | - | - |
