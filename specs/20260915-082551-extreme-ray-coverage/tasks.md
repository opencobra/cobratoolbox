# Tasks: Extreme-Ray Coverage Without Sacrificing Accuracy

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-09-15
**Branch**: `20260915-082551-extreme-ray-coverage` (on top of the parent feature, **not**
`develop` — rebase when the parent merges)

## Read this before executing any of it

Four rules govern the order. Each exists because breaking it produces a measurement that
looks like evidence and is not.

1. **The paired harness comes first.** Every comparison runs through it. A comparison
   assembled from independent whole runs confounds solver behaviour with search path — it
   is precisely what this feature exists to replace.
2. **Measurement before tuning.** R2 and R3 complete before any setting is chosen. Tasks
   that apply tuning say "apply the settings selected by R3/R4", never a concrete value.
3. **A setting is not adopted until it is verified to take effect.** The toolbox reports
   no algorithm: gurobi's `Method` label is off by one against its own comment *and* is
   never returned. Verification comes from an observable, not from having set the value.
4. **A1 is out of scope.** No task builds the two-phase two-solver approach. If neither A2
   nor A3 meets SC-001, the deliverable is User Story 3.

**Gate decisions already settled — reflected here, not re-raised**: (a) `findExtremePool.m`
is in scope via a default-preserving settings pass-through; (b) A1 dropped; (c) the paired
instrumentation ships, off by default.

**File legend** — `GERB` = `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m`;
`FEP` = `src/analysis/topology/extremeRays/optimalRays/findExtremePool.m`;
`TEST` = `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m`.

---

## Phase 1: Setup

- [ ] T001 Create `specs/20260915-082551-extreme-ray-coverage/measurements/` for probes and raw records, and confirm nothing generated is written under `src/` or `test/` (Principle IX)
- [ ] T002 [P] Record the environment baseline in `specs/.../measurements/environment.md`: MATLAB version, installed solvers and versions, `getCobraSolverParams('LP', ...)` values as actually returned, and the parent-branch commit this sits on — every later figure is meaningless without it (SC-006)

---

## Phase 2: Foundational — the paired harness (BLOCKS every user story)

- [ ] T003 Add `param.compareSolvers` (default `{}`) and the paired-record plumbing to `GERB`, per contracts/greedyExtremeRayBasis.status-additions.md. At each greedy state build the LP ONCE and hand the identical problem to each listed solver (FR-016, FR-017)
- [ ] T004 Record per solver per point: returned ray, residual absolute and scaled, `meetsTarget`, `independentOfBasis`, `basisReturned` (from `vbasis`/`cbasis`), `atBoundCount`, `solveTime`, `stat`/`origStat` — see data-model.md §1 (FR-018)
- [ ] T005 Record the shared per-point fields including `objectiveHash`, so a reader can CONFIRM every solver in a group received the same objective rather than take it on trust (data-model.md §1.1)
- [ ] T006 Ensure the search advances on ONE nominated solver's ray and consumes the random stream identically whether or not comparison is on, so the harness cannot perturb the search it measures (R1 design question)
- [ ] T007 Test in `TEST`: with `compareSolvers` unset and with it `{}`, results are identical to the pre-feature call under a fixed seed — the harness is provably inert when off (SC-011)
- [ ] T008 **R1** Write `specs/.../measurements/pairedHarness.md`: the mechanism chosen for holding state identical, the inertness evidence from T007, and the number of paired points collected with their `k` range. Fill research.md §R1 Result

**Checkpoint**: no comparison may run before T008 completes.

---

## Phase 3: Foundational — measurement campaign (BLOCKS all tuning)

- [ ] T009 **R2** Using the harness, measure per solve whether a basis was returned (`vbasis`/`cbasis`), the solver's own reported algorithm taken from solver output NOT the toolbox, and a solver-independent vertex classification from components at a bound. Apply the decision rule fixed in research.md §R2 and **record the verdict either way — a refutation is a successful measurement**. Fill research.md §R2 Result
- [ ] T010 [P] **R3** Complete the Principle IV configuration-surface audit for gurobi and mosek against this problem's profile — sparse, all-equality, `sum(x)=1`-normalised, non-negative orthant, massively degenerate, ~1244 x 2954. Enumerate options, record defaults, identify mismatches, propose the tuned sets for A2 and A3 with the mismatch each setting corrects. Fill research.md §R3 Result
- [ ] T011 [P] **R6** Measure the cost of the consistency LP (`N'x = 0, x >= 1`) at genome scale and decide where it belongs in the flow — always, or only on shortfall. Fill research.md §R6 Result
- [ ] T012 [P] **R7** Determine whether ANY CI-available model stalls on coverage (`ecoli_core` and `iAF1260` both reach full coverage today, so neither serves); construct the G1 stoichiometrically-inconsistent fixture with its attainable dimension known by construction. Fill research.md §R7 Result
- [ ] T013 **R4** For each setting proposed by T010, establish an observable that changes when and only when it takes effect, and record before/after values. A setting whose effect cannot be observed is recorded as **unverified** and MUST NOT be adopted (FR-022). Fill research.md §R4 Result

**Checkpoint**: tuning may begin only now, and only with settings that T013 verified.

---

## Phase 4: User Story 1 — one call both complete and accurate (P1) 🎯 MVP

**Goal**: a single call returning `outcome = 'complete'` with `raysFound == raysExpected` and `residualAbsolute <= accuracyTarget`.
**Independent test**: SC-001 on the case identified by T012, and on `iDopaNeuroC` as a documented check.

- [ ] T014 [US1] Thread a solver-settings struct from `GERB` through `FEP` to `solveCobraLP`, **defaulting to today's behaviour** so `optimalExtremePoolDriver.m:119` and `testFindExtremePathway.m:75` are bit-for-bit unaffected, reached through the solver abstraction rather than a solver API (gate decision (a1), FR-020, SC-007)
- [ ] T015 [US1] Test in `TEST` that the two other `FEP` callers are unaffected by T014 — the default-preservation claim is asserted, not assumed (Principle II)
- [ ] T016 [US1] Encode the tuned per-solver sets in `GERB` as data — settings, rationale per setting, and the verifying observable — per data-model.md §2, applying **the settings selected by R3 and verified by R4**, each recorded with the measurement that justifies it (FR-019, FR-021, FR-015, SC-007)
- [ ] T017 [US1] Report `tunedSolverSettingsApplied` and `tunedSolverName` in the status, so a user on an untuned solver is never left believing they received tuning they did not get (FR-023)
- [ ] T018 [P] [US1] Test in `TEST`: a solver with no tuned set still produces a working result and reports that no tuned set was applied (SC-013)
- [ ] T019 [P] [US1] Test in `TEST`: each adopted setting demonstrably takes effect for its target solver, via the T013 observable (SC-012)
- [ ] T020 [US1] **R5** Run the A0/A2/A3 comparison — control included — on the same model and seed, and record coverage, accuracy, runtime and replicate counts in one comparable table. Fill research.md §R5 Result
- [ ] T021 [P] [US1] Test in `TEST`: SC-001 on the case from T012 — complete AND accurate in one call
- [ ] T022 [P] [US1] Test in `TEST`: the augmented matrix from that basis has one rank integer across at least three orders of magnitude of tolerance, at the structural rank (SC-002)
- [ ] T023 [P] [US1] Test in `TEST`: the parent's exact fixtures F1, F2, F2b, F3 do not regress in coverage or non-negativity (SC-004)

**Checkpoint**: if T020 shows neither A2 nor A3 meets SC-001, record it plainly and proceed to US3 as the deliverable — that is an acceptable landing point, not a failure (SC-009).

---

## Phase 5: User Story 2 — coverage and accuracy reported together (P1)

**Goal**: a configuration that trades one for the other is visible rather than implied.

- [ ] T024 [US2] Ensure the status reports coverage and accuracy together on every call, including the accuracy baseline comparison, so a coverage gain bought with accuracy is detectable (FR-007)
- [ ] T025 [P] [US2] Test in `TEST`: accuracy does not regress against the parent's measured baseline on any case where the parent met the target (SC-003)

---

## Phase 6: User Story 3 — an honest contract when the gap cannot be closed (P2)

**Goal**: a sampling shortfall and a structural one are distinguishable, and coverage is reported against the ATTAINABLE dimension.

- [ ] T026 [US3] Implement the shortfall classification of data-model.md §3 — `'none'`, `'sampling'`, `'structural'`, `'notAssessed'` — using the consistency test, placed per T011 (FR-005)
- [ ] T027 [US3] Report `attainableDimension` and `attainableDimensionAssessed`, so a shortfall is never reported against a target that was never reachable (FR-006)
- [ ] T028 [P] [US3] Test in `TEST` with the G1 fixture: a structural shortfall is classified as such and the attainable dimension is reported, not the nullity (SC-005)
- [ ] T029 [P] [US3] Test in `TEST`: a sampling shortfall is classified distinctly from a structural one, each with its shortfall quantified (SC-005, FR-013)

---

## Phase 7: Cross-cutting and closeout

- [ ] T030 Fill research.md's "Consolidated decisions" table D1-D6, each with Decision / Rationale / Alternatives considered and citing the measurement that supports it
- [ ] T031 [P] Write `specs/.../measurements/results.md` with the full campaign: per approach coverage, accuracy absolute and scaled, runtime, and **replicate counts** — distinct from the per-call status, since one invocation cannot know a replicate count. Include each configuration's effect on accuracy and runtime alongside its coverage, so a trade is visible (SC-006, FR-008)
- [ ] T032 [P] Update the `iDopaNeuroC` documented reproducibility check in the PARENT feature directory to record the coverage outcome under the new behaviour, or add this feature's own if the parent's would be disturbed (SC-001)
- [ ] T033 Confirm `TEST` runs within `test/testAll.m` using its `COBRA_TESTS` filter, passes, skips gracefully without a solver, and depends on no submodule content (SC-008)
- [ ] T034 Update the `GERB` help header for the new parameters and status fields, and the `FEP` header for the settings pass-through (Principle VII-E)
- [ ] T035 Re-validate `checklists/requirements.md` and any generated checklist, discharging the standing Completion Integrity item
- [ ] T036 Write the implementation receipt at `specs/20260915-082551-extreme-ray-coverage/agent-runs/<UTC-timestamp>-<short-name>/implementation-receipt.md` with the five mandatory sections — Prompt, Final response, Diff summary, Tests, Unresolved issues — the Final response being the actual final user-facing text. **Implementation is not complete until this exists**

---

## Dependencies

```text
Phase 1 (T001-T002)
   ↓
Phase 2 — PAIRED HARNESS (T003→T004→T005→T006→T007→T008)
   ↓  nothing may be compared before T008
Phase 3 — MEASUREMENT (T009, [T010|T011|T012], T013)
   ↓  T010 proposes settings; T013 verifies them; only verified settings may be adopted
   ├─→ Phase 4 US1 (T014-T023)   ← MVP
   ├─→ Phase 5 US2 (T024-T025)   ← needs US1's status work
   └─→ Phase 6 US3 (T026-T029)   ← independent of tuning; deliverable if US1 fails
          ↓
       Phase 7 (T030-T036)
```

- **T013 gates T016.** A setting that could not be verified must not be adopted.
- **T014 gates T016**: the settings cannot reach the LP until the pass-through exists.
- **US3 is independent of whether tuning succeeds** and becomes the deliverable if it does
  not — so it is the one slice that is worth doing regardless.

## Parallel opportunities

- **Phase 3**: T010, T011, T012 run in parallel after T009.
- **Phase 4**: T018, T019, T021, T022, T023 parallel once T014-T017 land.
- **Phase 6**: T028, T029 parallel after T026-T027.
- Tests marked [P] all write to the same `TEST` file — parallel means independently
  authorable, not concurrently editable. Serialise the writes.

## Implementation strategy

**MVP = Phase 1 + Phase 2 + Phase 3 + Phase 4 (US1).** That is the headline claim:
one call, complete and accurate.

**The honest caveat.** If T020 shows neither tuned configuration meets SC-001, US1 is not
achievable and **US3 becomes the deliverable** — coverage reported truthfully against the
attainable dimension, with the limit recorded. A1 is not available as a rescue: it was
dropped by decision. This is why Phase 3 blocks everything — it decides whether the
headline is reachable at all.

## Task-to-requirement coverage

| Requirement | Tasks |
|---|---|
| FR-001, SC-001 | T016, T020, T021 |
| FR-002, FR-009 (parent contract intact) | T023, T025 |
| FR-003 (non-negativity) | T023 |
| FR-004, SC-006 (remedy by measurement) | T010, T013, T020, T031 |
| FR-005, FR-006, SC-005 | T026, T027, T028, T029 |
| FR-007, SC-003 | T024, T025 |
| FR-008 (coverage effect reported with accuracy and runtime, replicates stated) | T024, T031 |
| FR-010, FR-020, SC-007 (through the abstraction; defaults preserved; rationale recorded) | T014, T015, T016 |
| FR-015 (each setting recorded with its justifying measurement) | T010, T013, T016, T031 |
| FR-011 (no two-solver requirement) | *satisfied by scope: A1 dropped* |
| FR-014, SC-006 (A0/A2/A3 compared) | T020 |
| FR-016, FR-017, FR-018, SC-010, SC-011 | T003, T004, T005, T006, T007, T008 |
| FR-019, FR-021, SC-014 | T010, T016 |
| FR-022, SC-012 | T013, T019 |
| FR-023, SC-013 | T017, T018 |
| FR-012, FR-013, SC-008 | T029, T033 |
| SC-002 | T022 |
| SC-004 | T023 |
| SC-009 | T020 checkpoint |
