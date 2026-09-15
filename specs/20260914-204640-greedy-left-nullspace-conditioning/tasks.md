# Tasks: Left-Nullspace Basis Conditioning And Bad-Scaling Diagnosis For `greedyExtremeRayBasis`

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-09-14
**Branch**: `20260914-204640-greedy-left-nullspace-conditioning`

**Input**: spec.md, plan.md, research.md, data-model.md, contracts/, quickstart.md

## Reading this file before executing any of it

Three rules govern the order, and violating any one of them produces the exact defect
this feature exists to remove:

1. **Measurement precedes remedy.** Phase 2 (R1–R7) completes before any behavioural
   task begins. R1 can overturn the seed's diagnosis and it *selects* the remedy. No task
   below names a remedy; tasks that write the fix say "the remedy selected by R1/R7".
2. **Two numbers may not be invented.** The accuracy target (FR-002) and the regime
   boundary (FR-006) come from T009 and T010 with recorded derivations. A task that hard-codes
   either without its derivation is a defect against SC-008, not a shortcut.
3. **`findExtremePool.m` is outside the spec's named scope.** Every task touching it
   carries **[GATE2-SCOPE]** and is blocked until that specific extension is approved.
   Approving "all tasks" at Gate 2 does **not** approve those; they need their own yes.

**File legend** — `GERB` = `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m`;
`FEP` = `src/analysis/topology/extremeRays/optimalRays/findExtremePool.m`;
`TEST` = `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m`.

---

## Phase 1: Setup

- [X] T001 Create the measurement workspace `specs/20260914-204640-greedy-left-nullspace-conditioning/measurements/` for probe scripts and raw outputs, and confirm no measurement artifact is written under `src/` or `test/` (Principle IX)
- [X] T002 [P] Record the environment baseline in `specs/20260914-204640-greedy-left-nullspace-conditioning/measurements/environment.md`: MATLAB version, installed LP solvers and versions, and `getCobraSolverParams('LP','feasTol')` as actually returned (expected 1e-6 per `src/base/solvers/param/getCobraSolverParams.m:90`) — every later measurement is meaningless without it (SC-008)

---

## Phase 2: Foundational — Phase 0 measurement (BLOCKS every user story)

**No behavioural change may begin until T008 is complete.** These tasks fill the empty
Result slots in `research.md`.

- [X] T003 Write the throwaway probe `specs/.../measurements/probeRayResidual.m` that, for one ray, retains BOTH `x_raw = sol.full` and the truncated `x` that `FEP:66` produces, per quickstart.md §2 — probe only, committed under the feature directory, not under `src/` (SC-008, Principle IX)
- [X] T004 **R1 (leading hypothesis, run first)** Using T003, measure `norm(S'*x_raw,inf)` against `norm(S'*x_trunc,inf)`, absolute and scaled, over >= 200 rays, >= 2 models, >= 2 LP solvers; record entries zeroed per ray, largest magnitude zeroed, and `sol.stat`/`sol.origStat`. Apply the decision rule fixed in research.md §R1 and **record the verdict either way — a refutation is a successful measurement**. Write into `research.md` §R1 Result (FR-002, SC-008)
- [X] T005 [P] **R2** Measure the LP's genuinely attainable residual floor on raw untruncated solutions, per solver, sweeping feasibility/optimality tolerances to find the plateau; record cost. Write into `research.md` §R2 Result (FR-002, SC-008)
- [X] T006 [P] **R5** Complete the external-solver configuration audit (Constitution Principle IV) for `solveCobraLP` as invoked by `FEP`: enumerate the configuration surface, cross-check every default against the problem's structural profile, and specifically assess the `sum(x)=1` normalisation (`FEP:53-54`), the hard-coded ±100 bounds (`FEP:57-61`, including whether any ray is clipped), and the coupling of the truncation threshold to the global `feasTol`. Write into `research.md` §R5 Result
- [X] T007 [P] **R6** Determine the fixture set: construct F1–F3 with exactly-known non-negative left nullspaces (square; `m != n`; empty nullspace), select the CI-available well-scaled genome-scale model F4 with its measured scaling recorded, and define the controlled badly-scaled construction F5. Write into `research.md` §R6 Result (FR-018, SC-001)
- [X] T008 **R7** Assess each candidate remedy against BOTH criteria — residual improvement and preservation of `Zpos >= 0` — and select one. Exclude explicitly, with reasons, any candidate that cannot preserve non-negativity (FR-004). Write into `research.md` §R7 Result. **This task selects the remedy that T013/T014 implement**
- [X] T009 **R3 — derive the accuracy target (FR-002)** State the derivation symbolically from the singular-value separation a rank determination needs, then substitute a representative case. Validate against the two known outcomes: it MUST classify the seed's `1.418e-07` (scaled `2.218e-09`) as failing and `~1e-16` as passing; a derivation reproducing neither is wrong. Write into `research.md` §R3 Result (SC-008)
- [X] T010 **R4 — measure the regime boundary (FR-006)** Choose the grounding and justify it against the two rejected alternatives; measure across the graded scaling family; locate the crossover where T009's target stops being attainable. Write into `research.md` §R4 Result (SC-008)
- [X] T011 Fill `research.md`'s "Consolidated decisions" table (D1–D6), each with Decision / Rationale / Alternatives considered, each citing the measurement that supports it (SC-008)
- [X] T012 Create `TEST` with its harness skeleton only: `prepareTest('needsLP', true)` requirement declaration, fixed random seed, justified tolerance constants sourced from T009, and the F1–F3 fixture constructors from T007 (FR-018)

**Checkpoint**: measurements recorded, remedy selected, target and boundary derived. Only now may behaviour change.

---

## Phase 3: User Story 1 — Basis that leaves the augmented matrix's rank well defined (P1) 🎯 MVP

**Goal**: a returned basis accurate enough that the augmented matrix has one unambiguous rank.
**Independent test**: F1–F4; augmented rank agrees across `getRankLUSOL`, `getNullSpace` and SVD over >= 3 orders of magnitude of tolerance.

- [X] T013 [US1] Implement the remedy selected by T008 inside `GERB` — the portion that does not require the Gate-2 scope extension (FR-001, FR-003)
- [~] T014 [US1] **[GATE2-SCOPE] NOT NEEDED — see research.md D1.** R1 refuted the truncation hypothesis (gurobi truncates 0 entries and achieves 1.185e-16), so there is no defect in `FEP` for this feature to fix. The Gate-2 scope extension was approved but is deliberately NOT exercised; `findExtremePool.m` is unchanged. Original task text: Implement the `FEP`-side portion of the remedy selected by T008 in `FEP`, as a new parameter defaulting to today's behaviour so `optimalExtremePoolDriver.m:119` and `testFindExtremePathway.m:75` are unaffected (plan.md option (b)) (FR-001, FR-003). **BLOCKED until Gate 2 approves the scope extension to `FEP` specifically**
- [X] T015 [US1] Add per-row accuracy verification on the RETURNED object in `GERB`, not inferred from the acceptance path (FR-003)
- [X] T016 [US1] Implement drop-and-continue for a candidate ray that cannot meet the target, counting rejections in `status.raysRejectedForAccuracy`, and make an accuracy-exhausted run distinguishable from a time-exhausted one (FR-003a, SC-014)
- [X] T017 [US1] Assert non-negativity on the returned `Zpos` (FR-004)
- [X] T018 [P] [US1] Test: F1–F3 exact fixtures — returned basis spans the known nullspace, all entries non-negative, residual within T009's target in both forms, in `TEST` (SC-001)
- [X] T019 [P] [US1] Test: F4 genome-scale — augmented-matrix rank identical across the three instruments and across >= 3 orders of magnitude of tolerance, in `TEST` (SC-002)
- [X] T020 [P] [US1] Test: F4 — nullspace basis of the augmented matrix has a machine-precision-scale residual, not order 1, in `TEST` (SC-003)
- [X] T021 [P] [US1] Test: accuracy-rejection path forced, `raysRejectedForAccuracy` reported and distinguishable from time exhaustion, in `TEST` (SC-014)

- [X] T016a [US1] **ADDED DURING IMPLEMENTATION, beyond the Gate-2 approved list, on the user's explicit instruction**: on exhausting the per-basis budget, discard the accumulated basis and restart from fresh randomness rather than persisting in a dead end, keeping the best basis found across restarts (`status.nRestarts`). Motivated by measurement: under gurobi on iDopaNeuroC the hit rate collapses to 0.46% and the search stalls at 101 of 105 rays
- [X] T016b [US1] **ADDED — defect found during implementation**: the `continue` on a rejected candidate skipped the timeout checks entirely, so a run rejecting every candidate never consulted its time budget and spun indefinitely. Latent before this feature (rejection was rare at 1e-6); reachable and severe once acceptance tightened. Budget checks moved to the TOP of the search loop, and `t2` initialised before the loop so `toc(t2)` cannot be reached undefined
- [X] T016c [US1] **PULLED FORWARD from T035 (US4), because T016a requires it**: the guard at `:54-58` tested `maxNewBasisTime` but assigned `maxTime`, leaving `param.maxTime` never set for a caller who supplied only `maxNewBasisTime`. Restart needs a genuine total budget distinct from the per-basis budget, so the guard is fixed and the two budgets now mean what the header documents. `param.maxTime` defaults to `param.maxNewBasisTime`, reproducing the historical behaviour (FR-011, FR-012)

**Checkpoint**: US1 independently testable and complete.

---

## Phase 4: User Story 2 — Unmissable diagnosis on badly scaled input (P1)

**Goal**: badly scaled input yields no basis and a machine-readable diagnosis.
**Independent test**: F5 and the F6 boundary pair; all console output suppressed; caller reads only the returned status.

- [X] T022 [US2] Implement the `status` struct of data-model.md §2 in `GERB`, populated on EVERY call with all five terminal outcomes (FR-009)
- [X] T023 [US2] Populate the accuracy/verification block: `residualAbsolute` AND `residualScaled` together, `nonNegative`, `impliedNullity`, `independentRank`, `elapsedTime` (FR-016)
- [X] T024 [US2] Implement regime classification against T010's boundary, applied to the OPERATIVE matrix — after consistency restriction and after transposition — and record which matrix was classified (FR-005)
- [X] T025 [US2] Implement Regime-B withholding: BOTH `Zpos` and `Z` returned empty, graceful return, no error raised (FR-007)
- [X] T026 [US2] Populate the Regime-B diagnosis block — `scalingQuantity`, `scalingValue`, `scalingBoundary`, `scalingBoundaryBasis`, `recommendedRepair` (FR-008)
- [X] T027 [US2] Add the third output to the signature, keeping the two-output call syntax working unchanged (FR-015); emit a visible warning alongside the status in Regime B, never a suppressed one (Principle VII-B)
- [X] T028 [P] [US2] Test: F5 badly scaled — both outputs empty, no error, diagnosis fields populated, in `TEST` (SC-004)
- [X] T029 [P] [US2] Test: same call with ALL console output suppressed — the diagnosis is still fully available from the status alone, in `TEST` (FR-017)
- [X] T030 [P] [US2] Test: F6 boundary pair — correct behaviour on BOTH sides, so the guard is exercised against the failure it guards and against a false positive, in `TEST` (FR-019, SC-007)
- [X] T031 [P] [US2] Test: all five terminal outcomes distinguishable from the status alone, in `TEST` (FR-009)
- [X] T031a [P] [US2] Test: BOTH call arities — an existing `[Zpos, Z] = ...` call runs unmodified and without error, and a `[Zpos, Z, status] = ...` call receives a populated status on every terminal outcome, in `TEST` (FR-015, **SC-010**)

- [X] T022a [US2] **CORRECTION made during US2**: the exact spectrum-derived accuracy target became the DEFAULT, and `param.exactAccuracyTarget` was removed. During US1 it had been made opt-in because a full `svd` appeared to cost minutes; that timing was an artefact of a wedged MATLAB session. Re-measured headless: **0.15 s** for the 1244 x 1710 iDopaNeuroC operative matrix and 0.35 s for 1668 x 2382 iAF1260. Making it the default also removes the US1 limitation that the conservative surrogate was too loose for a badly scaled matrix, and it is what makes regime classification possible on every call
- [X] T022b [US2] `status.scalingValue` and `status.scalingBoundary` reported on EVERY call, not only in Regime B, so a caller can see its margin rather than only that it had one. `data-model.md` updated to match (they moved from section 2.4 to 2.2)

**Checkpoint**: US1 + US2 = both regimes complete.

---

## Phase 5: User Story 3 — An incomplete basis that admits it is incomplete (P2)

**Goal**: no zero-padded rows; row count equals rays accepted.
**Independent test**: F7 short time budget forces early termination.

- [X] T032 [US3] Remove the full-height preallocation path so the returned `Zpos` has exactly `raysFound` rows and never an all-zero placeholder row (FR-010) in `GERB`
- [X] T033 [US3] Populate `raysFound`, `raysExpected`, `raysRejectedForDependence` and `raysExpectedIsEstimate` — the last always true, because the expected count comes from a rank computation and is a target, not ground truth (FR-010) in `GERB`
- [X] T034 [P] [US3] Test: F7 forced early termination — no all-zero rows, row count equals rays accepted, status records incompleteness, and a caller inspecting only `size(Zpos,1)` cannot be misled, in `TEST` (SC-006)

- [X] T032a [US3] Assert the FR-010 property on the returned object: an all-zero row now raises `greedyExtremeRayBasis:zeroBasisRow` rather than being returned, so the guard fails loudly instead of silently
- [X] T032b [US3] Reverted the US2-era header warning that `.raysFound` may differ from `size(Zpos, 1)`. With the basis trimmed the two are equal again, and the header says so

**Checkpoint**: the second silent-wrongness mechanism is closed.

---

## Phase 6: User Story 4 — Parameters and documentation that mean what they say (P3)

**Goal**: each documented parameter governs what it documents; the documented usage runs.

- [ ] T035 [US4] Fix the guard at `GERB:54-59` that tests `maxNewBasisTime` but assigns `maxTime`, and make each budget govern the period its documentation describes — `GERB:157` and `:161` currently both test `maxNewBasisTime`, so there is no total-time budget. **If deferred instead, record the reason explicitly in this task and in the receipt; it may not be left silent** (FR-011, FR-012)
- [ ] T036 [US4] Make a default-parameter call on a model lacking `SConsistentRxnBool` return the `'missingField'` outcome gracefully with `missingFieldName` and `howToObtain`, instead of the undefined-field error `GERB:72` raises today (FR-013)
- [ ] T037 [US4] Rewrite the `GERB` help header: correct the USAGE block, which documents a string second argument (`:9`, `:13`) the code cannot accept; document the third output and the five outcomes; document the clamped meaning of `param.feasTol`; and carry the FR-015b migration statement — what changed, when, under which feature, and that reproducing pre-change results requires a prior release (FR-014, FR-015b, SC-012, Principle VII-E)
- [ ] T038 [P] [US4] Test: no-argument call mirroring `optimalExtremePoolDriver.m:121` returns the diagnosis rather than crashing, in `TEST` (SC-015)
- [ ] T039 [P] [US4] Test: each time-budget parameter governs its documented period; header usage form executes, in `TEST` (FR-011, FR-014)

---

## Phase 7: Cross-cutting — mode symmetry, reporting, regression

- [ ] T040 Verify every guarantee holds identically in right-nullspace mode; neither mode may retain the pre-change acceptance behaviour (FR-020) in `GERB`
- [ ] T041 [P] Test: F9 right-nullspace mode carries the same accuracy target and status semantics, in `TEST` (SC-013)
- [ ] T042 [P] Write the feature measurement record `specs/.../measurements/results.md`: per case, residual absolute AND scaled, implied nullity vs independent rank, non-negativity, runtime, **with the replicate count behind each figure** — distinct from the per-call status, since a single invocation cannot know a replicate count (FR-016a, SC-009)
- [ ] T043 Write the `iDopaNeuroC` reproducibility check `specs/.../measurements/iDopaNeuroCReproducibility.m` plus its expected output and trace, recording that it is NOT a CI test and why — `papers/` is a git submodule (SC-005, Principle III)
- [ ] T044 Confirm `TEST` depends on no git-submodule content and skips gracefully without an LP solver; run it through `test/testAll.m` (SC-011, FR-018)
- [ ] T045 Re-validate `checklists/numerical-integrity.md`, discharging the standing Completion Integrity item: every checked task maps to a real diff hunk AND to verification evidence (FR-019, SC-007)
- [ ] T046 Write the implementation receipt at `specs/20260914-204640-greedy-left-nullspace-conditioning/agent-runs/<UTC-timestamp>-<short-name>/implementation-receipt.md` with the five mandatory sections — Prompt, Final response, Diff summary, Tests, Unresolved issues — the Final response being the actual final user-facing text, not a paraphrase (constitution Implementation Receipt Ledger). **Implementation is not complete until this exists**

---

## Dependencies

```text
Phase 1 (T001-T002)
   ↓
Phase 2 — MEASUREMENT (T003 → T004 → [T005|T006|T007] → T008 → T009 → T010 → T011 → T012)
   ↓  T004 selects the remedy and decides whether T014 is needed at all
   ↓  T008 selects the remedy; T009/T010 produce the two derived numbers
   ├─→ Phase 3 US1 (T013-T021)   ← MVP
   ├─→ Phase 4 US2 (T022-T031)   ← needs the status struct; T022 precedes T023-T026
   ├─→ Phase 5 US3 (T032-T034)   ← needs T022 for the status fields
   └─→ Phase 6 US4 (T035-T039)   ← independent of the numerical work; could go first if desired
          ↓
       Phase 7 (T040-T046)
```

- **T014 is blocked twice**: by T004 (is it even needed?) and by Gate-2 scope approval for `FEP`.
- **T022 gates T023–T026, T033**: they populate fields of the struct T022 creates.
- US4 (Phase 6) has no dependency on the numerical work and is the one slice that could be delivered first if the measurements prove slow.

## Parallel opportunities

- **Phase 2**: T005, T006, T007 run in parallel after T004. T002 parallel with T001.
- **Phase 3**: T018–T021 parallel once T013/T015/T016 land.
- **Phase 4**: T028–T031 parallel once T022–T027 land.
- **Phase 7**: T041, T042 parallel.
- Tests within a story are marked [P] but all write to the same `TEST` file — parallel here means *independently authorable*, not concurrently editable. Serialise the writes.

## Implementation strategy

**MVP = Phase 1 + Phase 2 + Phase 3 (US1).** That delivers a basis accurate enough to
keep the augmented rank well defined, with its accuracy target derived and recorded —
the feature's core claim, independently testable.

**But note an honest caveat about the MVP.** If T004 refutes the R1 hypothesis and T005
shows the LP floor sits above T009's target, then US1 may be *unachievable* and US2
(Regime B) becomes the feature's real deliverable. In that case the MVP slice flips to
Phase 4, and that is a legitimate outcome the spec anticipates — not a failure. This is
why the measurement phase blocks everything: it decides which slice is the MVP.

**Incremental delivery**: US1 → US2 → US3 → US4, each leaving the function coherent and
tested. US4 can be pulled forward independently.

## Task-to-requirement coverage

| Requirement | Tasks |
|---|---|
| FR-001, FR-003 | T013, T014, T015, T018, T019 |
| FR-002 (derived target) | **T009** |
| FR-003a | T016, T021 |
| FR-004 (non-negativity) | T008, T017, T018 |
| FR-005 | T024 |
| FR-006 (measured boundary) | **T010**, T030 |
| FR-007 | T025, T028 |
| FR-008 | T026, T028 |
| FR-009 | T022, T031 |
| FR-010 | T032, T033, T034 |
| FR-011, FR-012 | T035, T039 |
| FR-013 | T036, T038 |
| FR-014 | T037, T039 |
| FR-016 | T023 |
| FR-016a | T042 |
| FR-017 | T029 |
| FR-018 | T012, T044 |
| FR-015, FR-015a, FR-015b | T027, T031a, T037 |
| FR-019 | T030, T034, T038, T045 |
| FR-020 | T040, T041 |
| SC-001 | T007, T018 |
| SC-002 | T019 |
| SC-003 | T020 |
| SC-004 | T028 |
| SC-005 | T043 |
| SC-006 | T034 |
| SC-007 | T030, T045 |
| SC-008 | T002, T003, T004, T005, T009, T010, T011 |
| SC-009 | T042 |
| SC-010 | **T031a** |
| SC-011 | T044 |
| SC-012 | T037 |
| SC-013 | T041 |
| SC-014 | T016, T021 |
| SC-015 | T038 |
