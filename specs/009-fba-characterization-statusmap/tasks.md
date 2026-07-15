# Tasks: LP/FBA characterization net + consolidated mapSolverStatus

**Input**: Design documents from `specs/009-fba-characterization-statusmap/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md (all present)

**Tests**: This feature IS largely tests (characterization). Behavioral tests are mandatory
(Constitution III); run them via the MATLAB MCP (`run_matlab_test_file`), `prepareTest`-gated.

**Organization**: By user story. **STRICT ORDER: Part 1 (US1) must be GREEN before any Part 2
(US2) task.** All edits confined to `src/base/solvers/**` and `test/verifiedTests/**`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on incomplete tasks)
- **[US1]** = Part 1 characterization net; **[US2]** = Part 2 mapSolverStatus refactor

## Path note

Allowed: `test/verifiedTests/analysis/**`, `test/verifiedTests/base/testSolvers/**`,
`src/base/solvers/statusMapping/mapSolverStatus.m` (new), and status-map call sites in
`src/base/solvers/solveCobra{LP,QP,MILP,MIQP}.m`. NOT allowed: `optimizeCbModel.m`/
`buildOptProblemFromModel.m` logic, `mosek/parseMskResult.m`, the lindo dead block, the
`.origStat` post-solve mutation (W16), any interface/model-field change, W1/W5/W17.

---

## Phase 1: Setup

- [X] T001 Confirm the scoped change surface before editing (per `plan.md` Change map): only the
  four `solveCobra*` status-map sites, the new `src/base/solvers/statusMapping/`, and tests under
  `test/verifiedTests/`. No `optimizeCbModel`/`buildOptProblemFromModel` logic change; no
  W1/W5/W16/W17.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: shared fixtures + reference-capture that all Part 1 tests depend on.

- [X] T002 Build tiny in-test fixture constructors (feasible/optimal, contradictory-bounds/
  infeasible, unbounded-objective, and an L2/QP variant) as local helpers beside the Part 1 tests
  under `test/verifiedTests/base/testSolvers/`; fix `rng`, document `tol` (per `research.md` R2).
- [X] T003 Establish the reference-capture procedure (`research.md` R3): run the CURRENT
  `optimizeCbModel`/`buildOptProblemFromModel`/`solveCobraLP` on the fixtures via the MATLAB MCP
  (`run_matlab_file`/`evaluate_matlab_code`) and record `.stat` (exact), `.f`/residual/duals (tol)
  as `ref_*.mat`/literals beside each test.

**Checkpoint**: fixtures + references ready.

---

## Phase 3: User Story 1 - Characterization net (Priority: P1) 🎯 MVP

**Goal**: pin the CURRENT LP/FBA-spine behavior across the axes today's tests miss.

**Independent Test**: the suite passes (or skips cleanly), exercises every axis, and FAILS on a
deliberate perturbation (quickstart V1).

- [X] T004 [P] [US1] Write `test/verifiedTests/analysis/testCharacterizeOptimizeCbModel/testCharacterizeOptimizeCbModel.m`:
  status matrix (optimal/infeasible/unbounded, numerical where reproducible), all `minNorm`
  strategies (0/[], 'one', 'zero'+each `zeroNormApprox`, weighted vector, 'optimizeCardinality'),
  `osense` max & min, `allowLoops` on/off, primal+dual (`.v`/`.x`,`.f`,`.w`,`.y`); `prepareTest`
  `needsLP`/`needsQP`; tol asserts; fixed `rng`; references from T003.
- [X] T005 [P] [US1] Write `test/verifiedTests/base/testSolvers/testCharacterizeBuildOptProblemFromModel.m`:
  characterize the LP and QP model→problem mapping on a tiny model.
- [X] T006 [P] [US1] Write `test/verifiedTests/base/testSolvers/testCharacterizeSolveCobraLP.m`:
  characterize dispatcher-level status outcomes (optimal/infeasible/unbounded) on a built problem.
- [X] T007 [US1] Run T004–T006 via the MATLAB MCP (`run_matlab_test_file`); confirm all pass or
  skip cleanly; run the perturbation check (quickstart V1); confirm `git diff` shows NO change to
  `optimizeCbModel.m`/`buildOptProblemFromModel.m` (FR-007).

- [X] T007b [US1] **In-scope defect-fix (FR-013, folded in per clarify):** `solveCobraLP.m:911`
  `param` → `gurobiParam` on the `INF_OR_UNBD` retry (the latent bug the net caught). Verified via
  MCP: gurobi now returns clean `stat==2` for unbounded; optimal/infeasible unchanged.

**Checkpoint — GATE**: Part 1 net is GREEN (T004–T006 pass under gurobi; :911 fixed). Part 2
(T008–T014) MUST NOT begin until this passes — it now does.

---

## Phase 4: User Story 2 - Consolidated mapSolverStatus (Priority: P2)

**Goal**: one helper for the native→canonical status maps; results identical. **Gated on T007.**

**Independent Test**: with the net green, extract + reroute and the net stays green with identical
`.stat`/`.origStat`; duplicated map literals gone (quickstart V4/V5).

- [X] T008 [US2] Create `src/base/solvers/statusMapping/mapSolverStatus.m` transcribing EACH
  (solver, problemType, origStat)→`stat` map from `research.md` R1 EXACTLY — dqq, lp_solve, gurobi,
  cplex (LP/QP vs MILP/MIQP code families), tomlab, glpk — including the `106||106` quirk; outputs
  `[stat, origStatText]`; openCOBRA header, camelCase, warnings visible, no `nargin`.
- [X] T009 [US2] Write `test/verifiedTests/base/testSolvers/testMapSolverStatus.m`: feed
  representative native codes per (solver, problemType) and assert the canonical `.stat` (and the
  preserved quirk) — the unit net for the helper.
- [ ] T010 [US2] Reroute `src/base/solvers/solveCobraLP.m` status-map sites (dqqStatMap :419 & :555,
  lp_solve :661, gurobi block) through `mapSolverStatus`; leave mosek/glpk/lindo/`.origStat`
  mutation untouched. Re-run T004–T006 + T009 via MCP; confirm `.stat`/`.origStat` identical.
- [ ] T011 [US2] Reroute `src/base/solvers/solveCobraQP.m` (cplex-family block ×3 :218/:268/:325,
  qpng :375). Re-run the net + T009 via MCP; confirm identical.
- [ ] T012 [US2] Reroute `src/base/solvers/solveCobraMILP.m` (cplex ×3 :209/:302/:469, gurobi :274,
  glpk :149). Re-run the net + T009 via MCP; confirm identical.
- [ ] T013 [US2] Reroute `src/base/solvers/solveCobraMIQP.m` (cplex ×2 :127/:305, gurobi ×2
  :203/:268). Re-run the net + T009 via MCP; confirm identical.
- [ ] T014 [US2] Run `mcp__matlab__check_matlab_code` on `mapSolverStatus.m` and the four edited
  dispatchers; resolve style flags WITHOUT changing behavior.

**Checkpoint**: status maps consolidated; net still green; results identical.

---

## Phase 5: Polish & Cross-Cutting Concerns

- [ ] T015 Run the full `quickstart.md` V1–V6 via the MATLAB MCP; confirm existing
  `testOptimizeCbModel`, `testSolveCobraLP`, `testSolveCobraLPCPLEX` still pass unchanged.
- [ ] T016 Confirm diff scope confined to `src/base/solvers/**` + `test/verifiedTests/**` +
  `specs/009-fba-characterization-statusmap/**`; no signature/field change (FR-011); duplicated map
  literals removed (grep `dqqStatMap`).
- [ ] T017 Report files edited, checks run, pass/fail, and any unverified behavior.
- [ ] T018 Write the implementation receipt at
  `specs/009-fba-characterization-statusmap/agent-runs/<UTC-timestamp>-<short-name>/implementation-receipt.md`
  (Prompt, Final response verbatim, Diff summary, Tests, Unresolved issues).

---

## Dependencies & Execution Order

- **Setup (T001)** → **Foundational (T002–T003)** → **US1 (T004–T007)**.
- **T007 is a hard gate**: Part 2 (T008–T014) MUST NOT start until the Part 1 net is green.
- **T008** (helper) precedes **T010–T013** (reroute); **T009** after T008. T010→T011→T012→T013
  sequential, each re-verifying via MCP. **Polish (T015–T018)** after Part 2.

### Parallel opportunities

- **T004, T005, T006** are different files, no interdependency → **[P]** (all Part 1 tests).
- T010–T013 are NOT parallel (each re-verifies the whole net before the next, to localize any
  behavior drift to a single dispatcher).

## Implementation Strategy

- **MVP = US1 (Part 1 net)**, T001–T007 — independently valuable; if Part 2 slips, the net still
  closes the coverage gap.
- Then US2 (Part 2), extracting the helper and rerouting one dispatcher at a time with MCP
  re-verification, so any `.stat`/`.origStat` drift is caught immediately and localized.

## Notes

- MATLAB standards enforced on all new/edited `.m`: no `evalc` shadowing, warnings visible,
  `try/catch ME` propagates `ME.stack`, no `nargin`, openCOBRA header + camelCase.
- The `106||106` quirk and all fallthrough `-1` mappings are PRESERVED verbatim (characterization).
- No task edits `optimizeCbModel.m`/`buildOptProblemFromModel.m` logic, `changeCobraSolver`, or any
  model field.
