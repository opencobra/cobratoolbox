# Feature Specification: Solver-Spine Consolidation and Abstraction Hardening

**Feature Branch**: `015-solver-spine-hardening`

**Created**: 2026-07-19

**Status**: Draft

**Input**: User description: "Solver-spine consolidation and abstraction hardening — a phased, strictly behaviour-preserving refactor of the LP/QP/MILP/MIQP solver core under `src/base/solvers` (weaknesses W1+W2+W3 plus one open latent bug), delivered as ONE feature in three sequenced phases from safest/additive to riskiest, guarded throughout by the feature-009 FBA characterization net."

## Clarifications

### Session 2026-07-19

- Q: For this feature's definition of done, must all three phases ship, or may the riskiest phase defer? → A: All three phases must ship in this feature — P1 (status consolidation + names.con bug), P2 (bypass routing), and P3 (CobraSolverState). None is deferred out of this feature.
- Q: For Phase 2, must every non-island bypass file be routed, or is a prioritized subset acceptable? → A: All files bypassing the abstraction outside the documented single-solver islands MUST be routed in this feature (no point leak left un-routed).
- Q: Must the set of canonical `.stat` values stay exactly as today, or may a new "unknown/other" sentinel be added? → A: Keep the exact current `.stat` value set. Unmapped native codes fold into an existing canonical value; this feature introduces no new `.stat` value. `.origStat` still preserves the raw code (Principle II).
- Q: What equivalence standard proves each phase behaviour-preserving? → A: Identical `.stat`/`.origStat` **and** optimal objective value equal within a justified tolerance. The optimal solution **vector** (primal fluxes and dual values) is NOT required to match, because non-strictly-convex problems can have non-unique optima; the returned point MUST still be feasible (satisfy the imposed constraints) and optimal (objective matches).

## User Scenarios & Testing *(mandatory)*

This feature hardens the toolbox's solver abstraction layer — the "spine" through
which every constraint-based analysis reaches an optimization solver. The three
user stories are the three delivery phases, ordered safest-first. All three are in
scope for this feature (Clarifications 2026-07-19); each is nonetheless an
independently testable and independently valuable slice — implementing only Phase 1
already removes a correctness hazard and closes an open bug.

The audience is the maintainer/contributor and the downstream analysis author who
relies on stable, solver-independent behaviour. "The system" below means the COBRA
Toolbox solver layer (`solveCobraLP/QP/MILP/MIQP`, `buildOptProblemFromModel`,
`changeCobraSolver`, and the analysis code that calls them).

**Equivalence standard (applies to every "behaviour-preserving" / "equivalent"
claim below)**: two solves are equivalent when their canonical `.stat` and raw
`.origStat` are identical and their optimal objective values agree within a
justified tolerance, and the returned point is feasible. The primal/dual solution
vectors are NOT required to be identical, because a non-strictly-convex problem can
have multiple optimal points with the same objective (Clarifications 2026-07-19).

### User Story 1 - One canonical solver status, no silent drift (Priority: P1)

A contributor adds or fixes support for a solver and needs the toolbox's canonical
solution status (`.stat`) to mean the same thing regardless of whether the problem
was an LP, QP, MILP, or MIQP. Today each dispatcher re-implements the
native→canonical status translation independently, so the four can — and do — drift
apart, and the same solver can report a different canonical `.stat` for an LP than
for a QP on the same underlying condition. This story makes status translation a
single, shared, tested function, and simultaneously fixes a latent mosek-debug
crash in the problem builder.

**Why this priority**: It is the additive, lowest-risk slice, it directly pays down
the debt behind the recent solver-status CI firefighting, and it removes a
scientific-correctness hazard (a caller acting on a wrong feasibility/optimality
verdict). It requires no change to any public signature and is fully guarded by the
existing feature-009 characterization net. It delivers standalone value even though
Phases 2 and 3 also ship in this feature.

**Independent Test**: For every installed solver and every problem type
(LP/QP/MILP/MIQP), assert that the canonical `.stat` returned after consolidation is
identical to the canonical `.stat` the pre-consolidation dispatchers returned,
across the feature-009 characterization models and a status-map fixture covering
every native status code the current inline maps handle; and assert that the
`buildOptProblemFromModel` mosek-debug crash no longer reproduces on a model with
coupling rows (`model.C`) but no `model.ctrs`.

**Acceptance Scenarios**:

1. **Given** a solver and a native status code that the current LP dispatcher maps
   to a canonical `.stat`, **When** the same native code is translated for a QP,
   MILP, and MIQP, **Then** it yields the identical canonical `.stat` (single source
   of truth) and the original code is preserved verbatim in `.origStat`.
2. **Given** any feature-009 characterization model solved before and after the
   change with the same configured solver, **When** the solves are compared, **Then**
   `.stat` and `.origStat` are identical and the optimal objective value agrees
   within the characterization tolerance, and the returned point is feasible — the
   primal/dual vectors are not required to match (non-unique optima).
3. **Given** a model that has coupling constraints (`model.C`) but no `model.ctrs`,
   **When** it is solved through mosek with `param.debug` enabled, **Then** no
   `err_argument_dimension` (mosek Error 1201, `prob.names.con`) is raised and the
   constraint names have the same length as the true constraint-row count.
4. **Given** the consolidated status mapper, **When** the source is inspected,
   **Then** the `dqqStatMap` table is defined exactly once and no per-dispatcher
   inline status map remains.

---

### User Story 2 - Analysis modules run under any configured solver (Priority: P2)

A user whose configured solver is (say) gurobi runs an analysis module that was
historically written against CPLEX-only or Gurobi-only idioms. Today several
modules bypass the solver abstraction and call `Cplex()`/`gurobi()` directly, so
they break, silently pick the wrong solver, or re-implement status/param handling
the spine already provides. This story routes those modules through
`solveCobra{LP,QP,MILP,MIQP}` so they honour `changeCobraSolver`. Every bypassing
file outside the documented single-solver islands is routed in this feature
(Clarifications 2026-07-19); a module that genuinely requires a solver-specific
capability is documented as a justified island rather than left as an undocumented
leak.

**Why this priority**: It restores portability across the community's heterogeneous
solver installations (the reason the abstraction exists), but it touches many files
across `analysis/`, `design/`, and `dataIntegration/` and carries more behavioural
risk than Phase 1, so it follows the safe consolidation.

**Independent Test**: For each module brought through the spine, run it under a
configured solver different from the one it originally hard-coded and confirm it
completes and returns the same solver status and an optimal objective value within a
justified tolerance (solution vector not required to match); and confirm the count
of files naming a solver directly outside `src/base/solvers` drops to only the
documented, justified islands.

**Acceptance Scenarios**:

1. **Given** a module that previously constructed `Cplex()` or called `gurobi()`
   directly, **When** it is run with a different configured solver capable of the
   required problem type, **Then** it completes without a solver-availability error
   and returns the same solver status and an optimal objective value within a
   justified tolerance (the returned point is feasible; its exact vector need not
   match the original).
2. **Given** a module that genuinely needs a capability only one solver exposes,
   **When** the abstraction cannot yet carry that capability, **Then** the module is
   recorded in a documented islands list with the specific reason, and it degrades or
   errors gracefully (a clear requirement message) rather than silently.
3. **Given** the post-Phase-2 source tree, **When** direct solver references outside
   `src/base/solvers` are counted, **Then** the number is reduced to the documented
   island set and every remaining reference is traceable to that list.

---

### User Story 3 - Solver state is an explicit, inspectable contract (Priority: P3)

A test author, or a future polyglot (Python/Julia) solver contract, needs to know
and set which solver and parameters are in effect without mutating and restoring
process-global variables or parsing `eval`-built names. Today solver selection is
ambient: ~18 mutable globals hold it and `eval` builds the accessor names. This
story introduces a backward-compatible `CobraSolverState` accessor/struct over the
existing globals and threads it explicitly through `solveCobra*`, removing the
`eval`-built name access — without breaking any existing global-based caller.

**Why this priority**: It is the highest-risk slice (it touches initialization and
the most widely-depended-on selection path) and delivers its full value only once
Phases 1 and 2 have de-risked the layer, so it is sequenced last. It is in scope for
this feature (Clarifications 2026-07-19).

**Independent Test**: Confirm `CobraSolverState` reports the same solver selection
and parameters as the current globals for every problem type; confirm an existing
script that reads/sets the globals directly still behaves identically; and confirm a
solve can be driven from an explicit state object without touching the globals,
producing a solution with the identical status and objective (within tolerance).

**Acceptance Scenarios**:

1. **Given** a solver selected via `changeCobraSolver`, **When** the selection is
   read through `CobraSolverState` and through the legacy globals, **Then** both
   report the identical solver name and parameters for LP/QP/MILP/MIQP/NLP/EP.
2. **Given** existing user code that reads or assigns the solver globals directly,
   **When** it runs after this change, **Then** its behaviour is unchanged
   (backward-compatible shim).
3. **Given** an explicit solver-state object, **When** a solve is driven from it
   without relying on ambient globals, **Then** the returned solution has the
   identical `.stat`/`.origStat` and an objective value within tolerance of the
   globals-driven solve.
4. **Given** the changed selection path, **When** the source is inspected, **Then**
   the `eval`-built solver-name/param access in the selection path is replaced by
   struct-field access.

---

### Edge Cases

- A solver returns a native status code not present in any current inline map (new
  solver version): the canonical mapper MUST fall back to a defined non-optimal
  canonical status **drawn from the existing `.stat` value set** and still preserve
  the raw code in `.origStat`, never silently coercing it to "optimal".
- A native status is meaningful for one problem type but not another (e.g. a
  MILP-only "node limit"): the mapper MUST resolve it per `(solver, problemType)`
  and not leak a MILP-only verdict into an LP result.
- A model has `model.C` (coupling) but no `model.ctrs`, no `model.mets`, or mismatched
  lengths under mosek `param.debug`: constraint names MUST be sized from the true
  constraint-row count.
- Degenerate / alternate optimum: a before/after comparison finds the same `.stat`
  and objective value but a different primal or dual vector. This is EXPECTED for
  non-strictly-convex problems and MUST NOT be reported as a regression; only status
  and objective (plus feasibility of the returned point) are asserted.
- A Phase-2 module's only viable solver is not installed on the user's machine: it
  MUST skip/error with a clear requirement message (via the standard requirements
  mechanism), not crash deep inside a hard-coded solver call.
- Parallel execution (`parfor`): explicit solver state MUST be usable per worker
  without cross-worker global contention (Phase 3 enabling goal; full parfor-safety
  is not required to be proven in this feature unless a test already exercises it).

## Requirements *(mandatory)*

### Functional Requirements

**Phase 1 — status consolidation + builder bug (P1)**

- **FR-001**: The system MUST provide a single shared status-mapping function that
  translates a solver-native status into the toolbox's canonical `.stat`, resolved by
  `(solver, problemType, nativeStatus)`, and MUST preserve the raw native status in
  `.origStat` unchanged.
- **FR-002**: `solveCobraLP`, `solveCobraQP`, `solveCobraMILP`, and `solveCobraMIQP`
  MUST obtain their canonical `.stat` from that single function; no per-dispatcher
  inline status map and no duplicated `dqqStatMap` table may remain.
- **FR-003**: The canonical `.stat` produced for every `(solver, problemType,
  nativeStatus)` combination the current code handles MUST be identical to the value
  the pre-change code produced (behaviour-preserving; verified against the current
  maps and the feature-009 net).
- **FR-004**: For an unrecognized native status, the mapper MUST return a defined
  non-optimal canonical status and preserve `.origStat`, never defaulting to a
  feasible/optimal verdict. This fallback MUST reuse an existing canonical `.stat`
  value — this feature introduces NO new `.stat` value (Principle II).
- **FR-005**: `buildOptProblemFromModel` MUST size the mosek-debug constraint-name
  vector (`names.con`) from the true constraint-row count (rows of `[S; C]` /
  `[S E; C D]`), so a model with `model.C` but no `model.ctrs` no longer raises mosek
  Error 1201 (`err_argument_dimension`, `prob.names.con`) under `param.debug`.

**Phase 2 — abstraction bypasses (P2)**

- **FR-006**: Every analysis/design/dataIntegration file that currently calls a
  solver directly, outside the documented islands (FR-007), MUST be routed through
  `solveCobra{LP,QP,MILP,MIQP}` (honouring `changeCobraSolver`) in this feature — a
  prioritized subset is NOT sufficient (Clarifications 2026-07-19). A routed module
  MUST produce the same solver status and an optimal objective value within a
  justified tolerance (its solution vector need not match — see FR-013).
- **FR-007**: Any module that cannot be abstracted because it requires a genuinely
  solver-specific capability MUST be recorded in a documented "solver islands" list
  with the specific capability and reason, and MUST fail/skip with a clear
  requirement message when its required solver is absent (no silent wrong-solver
  execution).
- **FR-008**: The number of files naming a solver directly outside `src/base/solvers`
  MUST be reduced to only the documented island set, with each remaining reference
  traceable to that list.

**Phase 3 — solver-state encapsulation (P3)**

- **FR-009**: The system MUST provide a `CobraSolverState` accessor/struct that
  reports and sets the effective solver selection and parameters, implemented as a
  backward-compatible shim over the existing globals so that code reading or writing
  those globals directly continues to behave identically.
- **FR-010**: `solveCobra*` MUST be able to obtain the solver selection and
  parameters through explicit state (not solely ambient globals), and the
  `eval`-built solver-name/param access in the selection path MUST be replaced by
  struct-field access, with no change to the resulting selection or solution.

**Cross-cutting**

- **FR-011**: The system MUST preserve documented public interfaces and diagnostic
  semantics unchanged: `changeCobraSolver`, `solveCobraLP/QP/MILP/MIQP`,
  `optimizeCbModel`, `buildOptProblemFromModel`, `initCobraToolbox`, and the returned
  solution fields (`.stat`, `.origStat`, `.full`, `.obj`, dual fields). The set of
  canonical `.stat` values is unchanged. No solver is removed; superseded paths are
  deprecated (shimmed), never deleted (Principle II).
- **FR-012**: Each phase MUST be verified by the narrowest practical automated test
  under `test/verifiedTests/<category>/` that runs within `test/testAll.m`, declaring
  solver/toolbox requirements via `prepareTest` so it skips gracefully, and using
  justified tolerances for floating-point comparisons (Principle III).
- **FR-013**: Each phase MUST be behaviour-preserving under the equivalence standard:
  `.stat` and `.origStat` identical, and the optimal objective value equal within a
  justified tolerance, with the returned point feasible. The optimal primal/dual
  vector is NOT required to be identical (non-unique optima under non-strict
  convexity). Verified with the feature-009 characterization net plus targeted
  before/after comparisons on representative LP/QP/MILP/MIQP models across every
  installed solver (Principles I, IV).
- **FR-014**: A Phase-0/plan research note MUST enumerate, for each solver touched,
  the native status codes and the relevant configuration surface being consolidated,
  and cross-check them against the current inline maps so no native code is dropped
  or silently re-mapped (Principle IV configuration-surface audit).

### Key Entities *(include if feature involves data)*

- **Canonical solver status**: the toolbox-internal, solver-independent
  feasibility/optimality verdict (`.stat`) plus the preserved raw solver code
  (`.origStat`); the single meaning every caller relies on across problem types. The
  set of canonical `.stat` values is fixed by this feature (no new value introduced).
- **Solver status map**: the `(solver, problemType, nativeStatus) → canonicalStatus`
  relation, currently duplicated across four dispatchers, to become one shared
  definition (the existing mosek `parseMskResult` is the precedent to generalize).
- **Solver island**: an analysis/design module that legitimately depends on a
  single solver's capability, recorded with its reason in a documented list.
- **CobraSolverState**: an explicit, inspectable representation of the effective
  solver selection and parameters, a backward-compatible shim over the current
  globals.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: For every installed solver × every problem type (LP/QP/MILP/MIQP), the
  canonical `.stat` and preserved `.origStat` after Phase 1 match the pre-change
  values on 100% of the feature-009 characterization models and the status-map
  fixture (zero divergences), and the optimal objective value matches within the
  justified tolerance.
- **SC-002**: The `dqqStatMap` table is defined exactly once in the codebase and zero
  per-dispatcher inline status maps remain; all four dispatchers obtain `.stat` from
  the single shared function; the canonical `.stat` value set is unchanged.
- **SC-003**: The `buildOptProblemFromModel` mosek-debug case no longer reproduces
  `err_argument_dimension` on a model with `model.C` and no `model.ctrs`; a
  regression test asserts the constraint-name length equals the constraint-row count.
- **SC-004**: The count of files naming a solver directly outside `src/base/solvers`
  drops from its pre-feature baseline to only the documented island set, and each
  routed module runs to completion under a configured solver other than the one it
  originally hard-coded, returning the same status and an objective value within the
  stated tolerance.
- **SC-005**: `CobraSolverState` reports the identical solver selection and
  parameters as the legacy globals for all problem types, and a solve driven from an
  explicit state object returns a solution with the identical status and an objective
  within tolerance of the globals-driven solve; existing global-based caller
  behaviour is unchanged.
- **SC-006**: `test/testAll.m` remains green (no new failures; skips only where a
  required solver/toolbox is genuinely absent), and the feature-009 characterization
  net passes before and after each phase.

## Assumptions

- The feature-009 FBA characterization net exists, is runnable locally and in CI, and
  its model set is representative enough to serve as the primary behaviour-preservation
  oracle for the LP/FBA core; targeted QP/MILP/MIQP before/after comparisons supplement
  it where its coverage is thinner.
- At least gurobi and mosek are installed in the verification environment (the
  project's default solver policy), so the "across every installed solver" checks
  exercise more than one backend; tests still declare requirements via `prepareTest`
  so environments with fewer solvers skip gracefully.
- All three phases (P1, P2, P3) are in scope for this feature's definition of done
  (Clarifications 2026-07-19); they are delivered and verified in order (1 → 2 → 3),
  and none is deferred out of this feature.
- Within Phase 2, every bypassing file outside the documented islands is routed; the
  islands themselves are the only permitted exception. `SteadyCom` (CPLEX-oriented)
  and `TrimGdel` (Gurobi-oriented) are the expected islands: where a solver-specific
  capability they rely on cannot yet be carried by the abstraction, that specific
  capability is recorded in the islands list with its reason rather than forced, but
  the module is still routed through the spine for every problem type the abstraction
  can carry.
- Superseded selection/state access is deprecated via a compatibility shim, never
  deleted; new optional inputs default to the historical (globals-driven) behaviour.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001, FR-002, FR-004 | new `test/verifiedTests/base/solvers/` status-map test | `src/base/solvers/mapSolverStatus` (new) + `solveCobra{LP,QP,MILP,MIQP}` |
| US1 / FR-003, FR-013 | feature-009 characterization net + before/after `.stat`+objective comparison | `src/base/solvers/solveCobraLP` (and QP/MILP/MIQP) |
| US1 / FR-005 | new mosek-debug `names.con` regression test | `src/base/solvers/buildOptProblemFromModel` |
| US2 / FR-006, FR-008 | per-module portability test under a non-native configured solver | routed modules in `src/analysis/*`, `src/design/TrimGdel/*`, `src/dataIntegration/transcriptomics/SWIFTCORE/*` |
| US2 / FR-007 | documented islands list + graceful-requirement test | `src/analysis/multiSpecies/SteadyCom/*`, `src/design/TrimGdel/*` |
| US3 / FR-009, FR-010 | `CobraSolverState` equivalence + explicit-state solve test | `src/base/solvers/CobraSolverState` (new) + `changeCobraSolver`, `solveCobra*` |
| Cross-cutting / FR-011, FR-012 | `test/testAll.m` full run (green) + public-signature assertions | `src/base/solvers/*`, `src/base/install/changeCobraSolver` |
