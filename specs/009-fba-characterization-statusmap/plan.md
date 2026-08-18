# Implementation Plan: LP/FBA characterization net + consolidated mapSolverStatus

**Branch**: `009-fba-characterization-statusmap` | **Date**: 2026-07-15 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/009-fba-characterization-statusmap/spec.md`

## Summary

Two-part, additive, Principle-II-safe feature on the LP/FBA solver spine. **Part 1** adds a
characterization test net pinning the CURRENT behavior of
`optimizeCbModel → buildOptProblemFromModel → solveCobraLP` across the axes today's tests miss
(full status matrix, all `minNorm` strategies, both senses, loopless on/off, primal+dual).
**Part 2** (gated behind Part 1 green) extracts a single
`mapSolverStatus(solver, problemType, origStat)` and routes the four `solveCobra*` dispatchers
through it, removing the duplicated status maps — reproducing every existing mapping EXACTLY
(including the `106||106` quirk). Research (`research.md`) established the status-map inventory,
fixture strategy, reference-capture via the MATLAB MCP, and the helper's placement/signature.

## Technical Context

**Language/Version**: MATLAB R2024b+ (headless, `matlab -batch`).

**Primary Dependencies**: COBRA solver interface (`changeCobraSolver`, `solveCobra*`,
`buildOptProblemFromModel`); test harness (`prepareTest`, `test/testAll.m`); CI runs gurobi.

**Storage**: N/A (tests + a helper function; optional `ref_*.mat` fixtures beside tests).

**Testing**: New characterization tests under `test/verifiedTests/analysis/` (optimizeCbModel)
and `test/verifiedTests/base/testSolvers/` (buildOptProblemFromModel, solveCobraLP, mapSolverStatus
unit). `prepareTest('needsLP'|'needsQP')`, tolerance asserts, fixed `rng`, run in `testAll.m`+CI.
Reference values captured by running current code under the MATLAB MCP.

**Target Platform**: headless Linux/Docker CI (gurobi); other solvers characterized where present.

**Project Type**: brownfield MATLAB library — solver core.

**Performance Goals**: tiny fixtures, fast; no genome-scale runs. No performance change to `src`.

**Constraints**: no public-interface or model-field change (Principle II); status semantics
identical (Principle I/IV); Part 2 edits ONLY status-map routing in the four dispatchers; no
change to `optimizeCbModel`/`buildOptProblemFromModel` logic; no W1/W5/W16/W17 cleanup.

**Scale/Scope**: ~4 new test files + 1 new helper (`src/base/solvers/statusMapping/mapSolverStatus.m`)
+ edits to 4 dispatchers (status-map call sites only).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.* — **PASS** (no unjustified
violations; the src edits are approved by the feature spec and confined to status-map routing).

- **Scientific code quality**: The characterized objects are `.stat`/`.origStat` status semantics,
  objective, feasibility, and duals. Part 1 pins them; Part 2 MUST keep canonical `.stat` and
  `.origStat` identical for every characterized case. No stoichiometry/bounds/objective-sense change.
- **Testing and reproducibility**: Narrowest tests named in `quickstart.md` (V1–V6); all
  `prepareTest`-gated (`needsLP`/`needsQP`), tolerance-based, fixed-seed, run in `testAll.m`+CI,
  skip cleanly when a solver is absent. References captured via MATLAB MCP.
- **User experience and diagnostics**: no console/printLevel behavior change; tests keep output
  gated behind `printLevel`.
- **Performance and numerical integrity**: no `src` performance change; fixtures tiny. No
  verification made skippable. Numerical `.stat==3` case characterized only where reproducible.
- **External-solver configuration audit**: DONE in `research.md` R1 — per (solver, problemType)
  status-code surface enumerated; representative instance = gurobi (CI); others audited from code
  and tested where installed. Mismatch risk (cplex LP vs MILP code families) handled by keying on
  problemType.
- **Spec-driven scope control**:
  - Edit: `src/base/solvers/solveCobra{LP,QP,MILP,MIQP}.m` (status-map call sites ONLY);
    add `src/base/solvers/statusMapping/mapSolverStatus.m` (new); add tests under
    `test/verifiedTests/analysis/` and `test/verifiedTests/base/testSolvers/`.
  - MUST NOT touch: `optimizeCbModel.m`/`buildOptProblemFromModel.m` logic, `changeCobraSolver`
    signature, any model field, `mosek/parseMskResult.m` (already factored), the lindo dead block,
    `.origStat` post-solve mutation, and everything W1/W5/W16/W17.
- **MATLAB coding standards**: helper carries the openCOBRA header (`USAGE`/`INPUTS`/`OUTPUTS`/
  `Author`), camelCase, `if singleCond`, `filesep`/`pwd`; no `evalc` shadowing; warnings visible;
  `try/catch ME` propagates `ME.stack`; no `nargin` for new optional args (use `exist`/`isempty`).
  Run `mcp__matlab__check_matlab_code` on the helper + edited dispatchers.
- **Parameter-setting fidelity**: N/A — no cross-language port / literate render.
- **Artifact placement**: helper in a NEW subfolder `src/base/solvers/statusMapping/` (Principle
  IX); tests under `test/verifiedTests/<category>/`; no generated output in `src`.

**Re-check after design (Phase 1)**: unchanged — the mapSolverStatus contract (data-model.md) keeps
`.stat`/`.origStat` semantics identical; no interface change. PASS.

## Project Structure

### Documentation (this feature)

```text
specs/009-fba-characterization-statusmap/
├── spec.md              # + Clarifications 2026-07-15 (both parts in 009)
├── plan.md              # this file
├── research.md          # R1 status-map inventory + audit, R2 fixtures, R3 refs, R4 helper
├── data-model.md        # mapSolverStatus contract + characterization axes/fixtures
├── quickstart.md        # V1–V6 validation guide
├── checklists/requirements.md
├── human-loop.md
└── tasks.md             # (/speckit-tasks)
```

(`contracts/`: the `mapSolverStatus` function contract is documented in `data-model.md`; no
external API/CLI surface, so no separate `contracts/` dir.)

### Source Code (repository)

```text
src/base/solvers/
├── solveCobraLP.m     # EDIT: route dqq/lp_solve/gurobi status maps -> mapSolverStatus
├── solveCobraQP.m     # EDIT: route the 3× cplex-family block -> mapSolverStatus
├── solveCobraMILP.m   # EDIT: route cplex/gurobi/glpk MILP maps -> mapSolverStatus
├── solveCobraMIQP.m   # EDIT: route cplex/gurobi MIQP maps -> mapSolverStatus
└── statusMapping/
    └── mapSolverStatus.m   # NEW: single canonical (solver,problemType,origStat)->stat map

test/verifiedTests/
├── analysis/testOptimizeCbModel/   # NEW (Part 1)
└── base/testSolvers/
    ├── testBuildOptProblemFromModel.m  # NEW (Part 1)
    ├── testSolveCobraLP.m              # NEW (Part 1)
    └── testMapSolverStatus.m                       # NEW (Part 2 unit)
```

**Structure Decision**: solver-core change confined to `src/base/solvers/` (+ new `statusMapping/`
subfolder) and `test/verifiedTests/`. Part 1 (tests) lands and goes green before Part 2 (helper +
rerouting) so the net guards the refactor.

## Complexity Tracking

No Constitution Check violations. Risk notes (not violations) recorded for Gate 2:

| Item | Note |
|------|------|
| Part 2 touches 4 large dispatchers | Status maps differ by (solver, problemType) and are duplicated 2–3× within files; behavior-preservation requires per-site exact reproduction. Mitigated by Part-1 net + gating. |
| `106 || 106` quirk | Preserved verbatim (characterization); recorded as a follow-up defect, not fixed here. |
| Non-gurobi solver maps | Consolidated from code but only test-exercised where the solver is installed; CI covers gurobi. Skips are clean, not silent failures. |
