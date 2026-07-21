---
description: "Task list for feature 015 — solver-spine consolidation & abstraction hardening"
---

# Tasks: Solver-Spine Consolidation and Abstraction Hardening

**Input**: Design documents from `/specs/015-solver-spine-hardening/`

**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅

**Tests**: REQUIRED — FR-012 mandates the narrowest practical automated test per phase,
`prepareTest`-gated, justified tolerances. Test tasks precede implementation in each story.

**Organization**: by user story (US1=P1, US2=P2, US3=P3). Per spec Clarifications 2026-07-19
all three ship in this feature and are delivered in order 1 → 2 → 3 (safest-first); each is
independently testable. Equivalence standard (FR-013): identical `.stat` **and** `.origStat`,
optimal objective within a justified tolerance, returned point feasible; solution vector NOT
asserted.

**Grounding**: all file:line references are from [research.md](./research.md); re-confirm at
edit time. Behaviour-preservation oracle = the feature-009 characterization net +
`testMapSolverStatus.m`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: can run in parallel (different files, no incomplete-task dependency)
- **[Story]**: US1 / US2 / US3 (setup, foundational, polish carry no story label)

---

## Phase 1: Setup (baseline capture)

**Purpose**: record the "before" state the whole feature is measured against. No project init
(existing MATLAB toolbox).

- [X] T001 Capture the behaviour-preservation baseline: `initCobraToolbox(false)` then
  `runtests('test/verifiedTests/base/testSolvers')` (incl. the feature-009 characterization
  net + `testMapSolverStatus.m`); save pass/fail + timings as the quickstart "before" per
  `specs/015-solver-spine-hardening/quickstart.md`.
- [X] T002 [P] Record the installed-solver set (gurobi, mosek, and any others) via
  `changeCobraSolver`/`initCobraToolbox` output — this is the FR-014 audit scope and the
  "across every installed solver" set for SC-001/SC-004.

**Checkpoint**: baseline recorded — implementation may begin.

---

## Phase 2: Foundational (blocking guardrails)

**Purpose**: standards guardrail that constrains every subsequent edit.

- [X] T003 [P] Apply the MATLAB coding-standards guardrail to all files this feature will
  touch (constitution VII): no `evalc` that shadows built-ins or suppresses warnings; warnings
  stay visible; `try/catch` propagates `ME.stack`; optional args via `exist`/`isempty` not
  `nargin`; openCOBRA help header on new functions (VII-E). Invoke the MATLAB best-practice
  skill (`matlab-core:matlab-review-code`) and use `mcp__matlab__check_matlab_code` as the
  static gate on each edited file.

**Checkpoint**: guardrail active — user-story work can begin (in priority order).

---

## Phase 3: User Story 1 — One canonical solver status, no silent drift (Priority: P1) 🎯 MVP

**Goal**: make native→canonical status translation a single shared, tested function
(`mapSolverStatus`), delete the duplicated `dqqStatMap` and all inline maps, and fix the two
store-side bugs + the `buildOptProblemFromModel` mosek-debug sizing bug. Additive, lowest-risk.

**Independent Test**: for every installed solver × {LP,QP,MILP,MIQP}, the post-consolidation
`.stat`/`.origStat` equal the pre-consolidation values on the 009 net and a status-map fixture
covering every native code the inline maps handle; the mosek-debug `names.con` crash no longer
reproduces on a `model.C`-without-`model.ctrs` model. (Covers FR-001..FR-005, SC-001..SC-003.)

### Tests for User Story 1

- [X] T004 [P] [US1] Extend `test/verifiedTests/base/testSolvers/testMapSolverStatus.m`: one
  fixture per `(solver, problemType, nativeStatus)` the inline maps handle (research.md R1.1,
  incl. the by-problem-type divergences R1.6) asserting the exact pre-refactor `.stat`;
  fallback code → `-1` (no throw); unknown solver/problemType → `COBRA:mapSolverStatus:unmappedSolver`
  / `:unmappedProblemType`. Pure — needs no solver.
- [X] T005 [P] [US1] New `test/verifiedTests/base/testSolvers/testBuildOptProblemNamesCon.m`:
  build a model with `model.C` (and separately `model.E`) but no `model.ctrs`/`model.evars`,
  call `buildOptProblemFromModel(..., 'debug', true)` under mosek; assert
  `numel(names.con)==size(A,1)` and `numel(names.var)==size(A,2)`, no mosek Error 1201.
- [X] T006 [P] [US1] Add regression guards (in `testMapSolverStatus.m` or a small companion):
  Bug A — MIQP gurobi returns numeric `.stat` and string `.origStat` (not swapped); Bug B —
  LP ibm_cplex native `101` does not yield `.stat==0`.

### Implementation for User Story 1

- [X] T007 [US1] Extend `src/base/solvers/statusMapping/mapSolverStatus.m` to the full
  `(solver, problemType, nativeStatus)` relation per `contracts/mapSolverStatus.md`: add
  MILP and MIQP branches and all remaining LP/QP solvers; keep `dqqStatMap` as the **single**
  definition with the guarded `'UNMAPPED'`/`-1` fallback (restore what the 009 LP branch
  dropped); keep the two defined error ids. Pure/O(1). (Blocks T008–T011.)
- [X] T008 [US1] `src/base/solvers/solveCobraLP.m`: replace the remaining inline native→`.stat`
  maps (glpk, lp_solve, mosek_linprog, gurobi, matlab, tomlab_cplex, cplexlp, ibm_cplex, pdco)
  with `mapSolverStatus(solver,'LP',nativeStatus)`; **fix Bug B** (assign a defined `.stat` for
  ibm_cplex `101`, @1332-1336); keep the dynamic `INF_OR_UNBD`/code-4 re-solve control flow in
  the dispatcher (contract "division of responsibility").
- [X] T009 [US1] `src/base/solvers/solveCobraQP.m`: route all branches through
  `mapSolverStatus(solver,'QP',...)` and **delete** the inline `dqqStatMap` literal + lookup
  (@1010-1035). (Satisfies SC-002 "defined exactly once".)
- [X] T010 [US1] `src/base/solvers/solveCobraMILP.m`: replace inline maps (glpk, cplex_direct,
  gurobi_mex, ibm_cplex, gurobi incl. `TIME_LIMIT`, tomlab_cplex) with
  `mapSolverStatus(solver,'MILP',nativeStatus)`, preserving the native code as `.origStat`.
- [X] T011 [US1] `src/base/solvers/solveCobraMIQP.m`: route branches through
  `mapSolverStatus(solver,'MIQP',...)` and **fix Bug A** — store numeric canonical in `.stat`
  and native string in `.origStat` (@273,@343,@344); also store gurobi_mex native `origStat`.
- [X] T012 [US1] `src/base/solvers/buildOptProblemFromModel.m`: size `names.con` (@342-346)
  and `names.var` (@347-351) from the true assembled `size(optProblem.A,1)` /
  `size(optProblem.A,2)` — append placeholder ids for `model.C` coupling rows when `ctrs`
  absent, and for `model.E` columns when `evars` absent (FR-005).

### Verification for User Story 1

- [X] T013 [US1] Run `testMapSolverStatus`, `testBuildOptProblemNamesCon`, and the feature-009
  net; confirm zero `.stat`/`.origStat` divergence vs T001 baseline, objective within tol,
  `dqqStatMap` defined once, no per-dispatcher inline map remains (SC-001/002/003). Use
  `mcp__matlab__run_matlab_test_file`.

**Checkpoint**: US1 fully functional & independently testable — the MVP (removes a correctness
hazard + closes the open bug) even if US2/US3 followed later.

---

## Phase 4: User Story 2 — Analysis modules run under any configured solver (Priority: P2)

**Goal**: route every routable direct-backend caller outside `src/base/solvers` through
`solveCobra{LP,QP,MILP,MIQP}` (16 files, research.md R2.1); document + harden the 11 islands
(R2.2). Restores solver portability. Depends on US1 (consolidated status layer).

**Independent Test**: each routed module runs under a non-native configured solver and returns
FR-013-equivalent status+objective; the count of direct-solver references outside
`src/base/solvers` drops to exactly the documented island set (FR-006/007/008, SC-004).

- [X] T014 [US2] Capture the pre-Phase-2 baseline: count files naming a solver directly
  outside `src/base/solvers` (grep for `gurobi(|Cplex(|cplexlp|cplexqp|glpk(|intlinprog(|linprog(|solveCobraLPCPLEX|pdco(`),
  record the number for the SC-004 before/after.
- [X] T015 [US2] Author the documented **solver islands list** per
  `contracts/solverIslands.md` (11 entries: file, backend, capability, fallback) as a Spec Kit
  artifact under `specs/015-solver-spine-hardening/` (e.g. `islands.md`); add a durable
  in-tree pointer only if a source-level `README`/help reference is warranted.

### Tests for User Story 2

- [X] T016 [P] [US2] New `test/verifiedTests/base/testSolvers/testSolverAbstractionRouting.m`:
  for representative routed modules (SWIFTCORE `core.m`, TrimGdel `gDel_minRN.m`, QFCA
  `directionallyCoupled.m`), assert FR-013 equivalence under a non-native configured solver;
  for each island assert the graceful-requirement (defined "requires `<solver>` (`<capability>`)"
  error id, or the listed fallback runs) when the solver is absent. `prepareTest`-gated.

### Implementation for User Story 2 (routing — different files, parallelizable)

- [X] T017 [P] [US2] Route `src/dataIntegration/transcriptomics/SWIFTCORE/core.m` and
  `blocked.m` (gurobi/linprog/cplexlp @core:61,77,91 / blocked:37,52,65) through `solveCobraLP`.
- [X] T018 [P] [US2] Route `src/design/TrimGdel/step2and3.m`, `gDel_minRN.m`, `GRPRchecker.m`
  (plain gurobi LP/MILP) through `solveCobraLP`/`solveCobraMILP`.
- [X] T019 [P] [US2] Route `src/analysis/QFCA/directionallyCoupled.m` (gurobi/linprog) through
  `solveCobraLP`, and `src/analysis/rMTA/MTA_MIQP.m` (Cplex MIQP) through `solveCobraMIQP`
  (an `else` branch already calls it — make it the sole path).
- [X] T020 [P] [US2] Route the legacy `solveCobraLPCPLEX`/`solveCobraLPCPLEXcard` callers
  through `solveCobraLP` (card equivalent): `analysis/thermo/thermoDirectionality/setThermoReactionDirectionalityiAF1260.m`,
  `analysis/wholeBody/PSCMToolbox/{organEssentiality,checkIEM_WBM,hostMicrobeInteraction/analyzeHMmodel}.m`,
  `analysis/exploration/findBlockedReaction.m`, `design/optGeneFitness.m`,
  `design/optGeneFitnessTilt.m`, `dataIntegration/metabotools/findMinCardModel.m`.
- [X] T021 [P] [US2] Route
  `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m` `intlinprog`
  call (@1629) through `solveCobraMILP`.
- [X] T022 [US2] Harden the 11 islands (R2.2) to the graceful-requirement of
  `contracts/solverIslands.md`: clear identified "requires `<solver>` (`<capability>`)" error
  when absent, route to the listed fallback where present (SteadyCom `LPonly`), no `evalc`/
  warning suppression added.

### Verification for User Story 2

- [X] T023 [US2] Re-run the T014 count (must equal the 11-file island set), run
  `testSolverAbstractionRouting` and the touched modules' existing verifiedTests
  (e.g. `testSWIFTCORE`, `testTrimGdel`, relevant FVA/thermo tests); confirm no regression vs
  T001 baseline (FR-008, SC-004).

**Checkpoint**: US1 + US2 both work independently; portability restored.

---

## Phase 5: User Story 3 — Solver state is an explicit, inspectable contract (Priority: P3)

**Goal**: add a backward-compatible `CobraSolverState` façade over the 14 globals, migrate the
10 `eval`-built access sites to struct-field access, and thread explicit state through
`solveCobra*`. Highest-risk; sequenced last. Depends on US1+US2.

**Independent Test**: `CobraSolverState` reports the same selection/params as the globals for
every type; existing global-based code behaves identically; a solve driven from explicit state
matches the globals-driven solve (`.stat`/`.origStat` identical, objective within tol)
(FR-009/010, SC-005).

### Tests for User Story 3

- [X] T024 [P] [US3] New `test/verifiedTests/base/testSolvers/testCobraSolverState.m`:
  round-trip equivalence across all 7 solver + 7 param types (accessor ↔ global); old-style
  `global CBT_LP_SOLVER` read sees an accessor-written value; `changeCobraSolver` parity (same
  resulting state, same validation error on a bogus solver, same rollback) with gurobi+mosek;
  explicit-state solve equivalence. `prepareTest`-gated, justified tolerances, fixed seeds.

### Implementation for User Story 3

- [X] T025 [US3] Create `src/base/solvers/getSetSolver/CobraSolverState.m` per
  `contracts/cobraSolverState.md`: `get`/`getSolver`/`setSolver`/`getParams`/`setParam` over
  the 14 globals via a fixed `switch` on validated type — **no `eval`**; defined error
  `COBRA:CobraSolverState:unknownType`; openCOBRA help header. (Blocks T026–T028.)
- [X] T026 [US3] Migrate the 7 eval sites in
  `src/base/solvers/getSetSolver/changeCobraSolver.m` (@259,260,348,531,532,559,564) to
  `CobraSolverState.getSolver/setSolver`; leave the `solveCobra<problemType>` dynamic
  capability-probe dispatch (@545,547) unchanged (out of scope — function dispatch).
- [X] T027 [US3] Migrate `src/base/solvers/param/parseSolverParameters.m` (@33,34) and
  `src/base/solvers/param/changeCobraSolverParams.m` (@85) eval sites to
  `CobraSolverState.getSolver` / `CobraSolverState.setParam`.
- [X] T028 [US3] Read `_PARAMS` via `CobraSolverState.getParams` in
  `src/base/solvers/getCobraSolverParams.m` (@118-153); add optional explicit-state input to
  `solveCobra{LP,QP,MILP,MIQP}` (via `exist`/`isempty`, not `nargin`) defaulting to the
  globals-driven behaviour (FR-010, FR-011 — no public signature broken).

### Verification for User Story 3

- [X] T029 [US3] Run `testCobraSolverState`; confirm SC-005 (accessor↔global equivalence,
  unchanged global-caller behaviour, explicit-state solve equivalence) and that the 10 eval
  sites are gone (`mcp__matlab__check_matlab_code`).

**Checkpoint**: all three stories independently functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T030 [P] Run the `quickstart.md` validation scenarios for all three phases end-to-end.
- [X] T031 Run `test/testAll.m` (fast mode, ~28 min baseline); confirm SC-006 — no new
  failures vs the pre-feature baseline, skipping only where a solver/toolbox is genuinely
  absent; the 11 known R2026a string/display-API failures stay out of scope (not conflated).
- [X] T032 [P] Help-header / diagnostics pass on the new functions (`mapSolverStatus` already
  exists; `CobraSolverState`) per VII-E; verify the islands pointer is discoverable.
- [ ] T033 Create the implementation receipt at
  `agent-runs/<UTC-timestamp>-solver-spine-hardening/implementation-receipt.md` with the
  required sections (Prompt, Final response [verbatim], Diff summary, Tests, Unresolved
  issues); point `human-loop.md` at it.
- [ ] T034 Report files edited, checks run, pass/fail results, and any unverified behaviour;
  update `human-loop.md` (Bundle 4 closeout).

---

## Dependencies & Execution Order

### Phase dependencies

- **Setup (P1)** → no deps.
- **Foundational (P2)** → after Setup; guardrail applies to all stories.
- **US1 (P3 phase)** → after Foundational. **MVP.**
- **US2 (P4 phase)** → after US1 (consolidated status layer in place). Sequenced per spec.
- **US3 (P5 phase)** → after US2 (layer de-risked). Sequenced per spec.
- **Polish (P6)** → after all stories.

### Within-story ordering

- Tests (T004–T006 / T016 / T024) authored before their implementation tasks.
- US1: **T007 blocks T008–T011** (dispatchers depend on the extended mapper); T012 independent
  of T007. Verify T013 after T007–T012.
- US2: T015 (islands list) before T022 (island hardening); routing T017–T021 are mutually `[P]`
  (different files) after T007–T012 landed; T016 before T017–T022 fail; T023 last.
- US3: **T025 blocks T026–T028**; T024 before them; T029 last.

### Parallel opportunities

- T002, T003 `[P]`. T004/T005/T006 `[P]` (different test targets). Routing T017–T021 `[P]`
  (distinct files). T030, T032 `[P]`.

---

## Implementation Strategy

- **MVP** = Phase 1 + 2 + US1 (T001–T013): delete the status-map duplication, close Bug A/Bug B
  and the mosek-debug sizing bug — standalone correctness value, fully oracle-guarded. **STOP &
  VALIDATE** here before US2.
- **Incremental**: US1 → validate → US2 (portability) → validate → US3 (state façade) →
  validate. Each story leaves `testAll` green (SC-006) and the 009 net passing.
- Commit after each task or logical group; stay within the Gate-2 approved scope/files.

## Notes

- `[P]` = different files, no incomplete-task dependency. `[Story]` = traceability to US1/2/3.
- Every behavioural edit carries the narrowest `prepareTest`-gated test with a justified
  tolerance (FR-012); the 009 net + `testMapSolverStatus` is the before/after oracle (FR-013).
- No public signature changes (FR-011); superseded paths are shimmed, never deleted (Principle II).
