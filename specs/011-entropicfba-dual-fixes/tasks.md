# Tasks: Entropic-FBA infeasible-diagnostic hardening, legacy-test repair, and GECKO dual-residual resolution

**Feature**: 011-entropicfba-dual-fixes | **Branch**: `011-entropicfba-dual-fixes`
**Input**: plan.md, research.md, data-model.md, quickstart.md, spec.md

**Implementation gate (Principle VI)**: authoring this file does NOT authorize edits. Source/test
edits (T005+) may begin only after an explicit `/speckit-implement`. Tasks are verified via the
MATLAB MCP server (mosek + pdco). Per-phase git commits deferred (commit at bundle boundary / on
request).

**Allowed edit set (FR-009)** — only these four files may be modified:
- `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m`
- `src/base/solvers/entropicFBA/solveCobraEP.m`
- `test/verifiedTests/base/testEntropicFBA/testEntropicFluxBalanceAnalysis.m`
- `test/verifiedTests/analysis/testEntropicFBAgecko/testEntropicFBAgecko.m`

Every source/test edit carries these acceptance constraints: warnings stay visible (VII-B), any
`try/catch` propagates `ME.message` + `ME.stack` (VII-C), no `evalc` suppression (VII-A), openCOBRA
header on any new/revised function (VII-E), `camelCase`/`filesep` (VII-G); tests gate via
`prepareTest` needsEP/mosek and skip gracefully (III); no public signature / model-field /
`.stat`/`.origStat` change (II/IV).

---

## Phase 1: Setup & Baseline (read-only — no source edits)

**Purpose**: pin the pre-change state so every later change is measured against it. All tasks here
run existing code only.

- [x] T001 [P] Baseline-run `testCharacterizeEntropicFBA` and `testEntropicFBAgecko` under mosek + pdco via the MATLAB MCP server; record pass/fail and, for the two GECKO mosek cases, the exact `[mosek] Dual optimality ... residual = …` value(s). Save to `specs/011-entropicfba-dual-fixes/agent-runs/<UTC>-<name>/baseline.md`.
- [x] T002 [P] Baseline-run `testEntropicFluxBalanceAnalysis` twice: (a) standalone in a fresh workspace to capture the `Unrecognized function or variable 'k'` error; (b) with `k = 1` predefined to confirm the underlying function passes on Recon3D. Record both in baseline.md.
- [x] T003 [P] Capture `check_matlab_code` baseline for all four allowed-edit files (record existing flags so SC-005 "no NEW flags" is measurable).
- [x] T004 Reproduce the infeasible-enzyme crash: build a strictly-infeasible `buildEnzymeToy` instance (`kcat*eMax < 2`, e.g. `buildEnzymeToy(0.5, 2)`) and call `entropicFluxBalanceAnalysis(model, struct('solver','mosek'))`; capture the exact error and stack (undefined `message` and/or mosek `err_argument_dimension`) to pin the throwing line(s) in `entropicFluxBalanceAnalysis.m` and `solveCobraEP.m`. Read-only diagnostic (no edits yet).

**Checkpoint**: baseline.md records current pass/fail, residual values, static-analysis flags, and the reproduced crash stack.

---

## Phase 2: User Story 1 — Infeasible enzyme-constrained EP returns a clean status (Priority: P1)

**Goal**: an infeasible EP (with or without enzyme columns, any `optimizeCbModel` diagnostic status)
returns `stat = 0` with a populated `messages`, no crash. (FR-001/002/003, SC-001)

**Independent test**: V2 — `buildEnzymeToy(0.5,2)` under mosek returns `solution.stat==0`,
`~isempty(solution.messages)`, no thrown error.

- [x] T005 [US1] In `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m` (`otherwise` branch ~L1699): initialise `message` to a generic default (e.g. `'entropicFluxBalanceAnalysis: EPproblem is not feasible (optimizeCbModel status N).'`) BEFORE the inner `switch solution_optimizeCbModel.stat`, so cases 0/1 override it and any other status is still defined. Leave the feasible (`stat==1`) path untouched. (FR-001)
- [x] T006 [US1] In `src/base/solvers/entropicFBA/solveCobraEP.m`, size the mosek infeasibility-diagnostic name/vector arrays (the path around the `sol.stat==0` / `msklpopt` diagnostic, L982–998, plus any `prob.names` construction it depends on) from the actual enzyme-augmented dimension (`size(EPproblem.A)` / `size(prob.a)`), using the exact throwing line pinned in T004. Minimal, localised to the diagnostic path. (FR-003)
- [x] T007 [US1] In `test/verifiedTests/analysis/testEntropicFBAgecko/testEntropicFBAgecko.m`, add a strictly-infeasible enzyme case using `buildEnzymeToy` with `kcat*eMax < 2`: assert `solution.stat == 0`, `~isempty(solution.messages)`, and that no error is thrown (wrap in `try/catch` that fails the test with `ME.message`+`ME.stack` if it throws, per VII-C). Gate under mosek via the existing backend loop / `mosekopt` existence check. (FR-001/002, SC-001)
- [x] T008 [US1] Re-run `testEntropicFBAgecko` (feasible + binding + new infeasible) and `testCharacterizeEntropicFBA` under mosek + pdco; confirm the previously-passing feasible/binding assertions and the no-enzyme net are unchanged (FR-004/SC-004) and the new infeasible case passes (V2/V4).

**Checkpoint**: infeasible enzyme-constrained EP returns cleanly; feasible/binding/no-enzyme nets still green.

---

## Phase 3: User Story 2 — Legacy test runs standalone (Priority: P2)

**Goal**: `testEntropicFluxBalanceAnalysis` runs from a fresh workspace and actually exercises the
function. (FR-005, SC-002)

**Independent test**: V1 — run standalone with no stray `k`; it reaches
`entropicFluxBalanceAnalysis(model,param)` and asserts `solution.stat==1`.

- [x] T009 [US2] In `test/verifiedTests/base/testEntropicFBA/testEntropicFluxBalanceAnalysis.m:29`, replace `solverPkgs.EP{k}` with `solverPkgs.EP{1}` (single required solver is mosek); do not change any assertion. (FR-005)
- [x] T010 [US2] Run `testEntropicFluxBalanceAnalysis` standalone in a fresh workspace; confirm no undefined-`k` error and that it reaches and passes the `entropicFluxBalanceAnalysis` call (V1/SC-002).

**Checkpoint**: legacy test green standalone.

---

## Phase 4: HARD GATE + User Story 3 — GECKO dual-optimality residual (Priority: P3, highest risk — LAST)

> **HARD GATE (T011)**: the regression net (Phase 2 + Phase 3) MUST be green under mosek + pdco
> before any change to the dual-residual computation. Do not start T012+ until T011 passes.

**Goal**: pursue a fix so the mosek dual-optimality residual is reported in the reduced/structural
coordinates (matching pdco), the warning no longer fires, the non-enzyme residual does not regress,
and the primal/`.stat`/`.origStat` are unchanged. Fall back to characterize-and-tolerate only per the
research.md R1 decision rule. (FR-006, SC-003)

**Independent test**: V3 — feasible GECKO toy under mosek emits no dual-optimality warning (fix path)
OR a documented tolerated residual (characterize path); `testEntropicFBAgecko` deterministic.

- [x] T011 [US3] HARD GATE: re-run `testCharacterizeEntropicFBA` + `testEntropicFBAgecko` + `testEntropicFluxBalanceAnalysis` under mosek + pdco; confirm all green. Record in the receipt.
- [x] T012 [US3] Diagnostic spike (read-only): run `entropicFluxBalanceAnalysis` under mosek with `printLevel>1, debug=1` on (a) `buildEnzymeToy(3,2)` and (b) the non-enzyme Recon3D; dump `sol.T` (`tot,c,Aty,z,Ftdoty,Fty_K`), identify which `prob.names.var` rows carry the residual, and compute the reduced-coordinate residual `c + d.*logx + A'*sol.dual + sol.rcost` on structural variables. Apply the research.md R1 decision rule; record the determination (fix vs characterize) in the receipt.
- [x] T013 [US3] Per the T012 determination, edit `src/base/solvers/entropicFBA/solveCobraEP.m` (dual-optimality check ~L1059–1073): **fix path** — compute/report the dual residual `res2` in the structural/original reduced coordinates so `tmp2 ≤ optTol` for well-solved enzyme and non-enzyme problems; keep the warning wording and `optTol` label, keep it visible (VII-B); do NOT alter the primal, `.stat`, `.origStat`, or `sol.full`. **Fallback (characterize) path** — leave the residual computation, document it, and defer the test-side tolerance to T014.
- [x] T014 [US3] Make `testEntropicFBAgecko`'s dual-optimality outcome deterministic: **fix path** — assert the mosek feasible/binding cases run without the dual-optimality warning (e.g. capture warnings via `lastwarn`/an `onCleanup` warning-state check that keeps warnings visible, VII-A/VII-B) and residual ≤ tolerance. **Characterize path** — assert primal constraint satisfaction + KKT/optimality + exact status strings (`OPTIMAL`, `MSK_RES_OK`) and tolerate the documented residual. (FR-006/SC-003)
- [x] T015 [US3] Re-run the full net (`testCharacterizeEntropicFBA`, `testEntropicFBAgecko`, `testEntropicFluxBalanceAnalysis`) under mosek + pdco; confirm the non-enzyme residual did not regress and the primal solutions are unchanged within existing tolerances (FR-004/SC-004/SC-006).

**Checkpoint**: dual-optimality residual resolved (or documented+tolerated); all nets green; primal unchanged.

---

## Phase 5: Polish & Verification (cross-cutting)

- [x] T016 [P] Run `check_matlab_code` on all four edited files; confirm no NEW flags vs the T003 baseline (SC-005); confirm any new/revised function carries the openCOBRA header (VII-E) and camelCase/filesep (VII-G).
- [x] T017 [P] Diff review against Principle II/IV: confirm no change to `entropicFluxBalanceAnalysis`/`solveCobraEP` signatures, documented params, model fields, or `.stat`/`.origStat` semantics; confirm the default (no-enzyme) feasible-path `v`/objective unchanged within 1e-6 (SC-006).
- [x] T018 Confirm the diff is confined to the four allowed files (FR-009) — no stray edits.
- [x] T019 Write the implementation receipt at `specs/011-entropicfba-dual-fixes/agent-runs/<UTC-timestamp>-<short-name>/implementation-receipt.md` with the mandated sections (Prompt, Final response, Diff summary, Tests, Unresolved issues), including the T012 dual-residual determination and the baseline vs post-change residual values.

---

## Dependencies & Execution Order

- **Phase 1 (T001–T004)** first — read-only baseline; T004 pins the crash line for T005/T006.
- **Phase 2 (US1, T005–T008)** and **Phase 3 (US2, T009–T010)** are independent of each other and
  are the two low-risk slices; either order. Both must complete before the HARD GATE.
- **Phase 4 (US3)** only after **T011** (net green). T012 (spike) → T013/T014 (fix or characterize)
  → T015 (re-run net).
- **Phase 5** after Phase 4.

## Parallel Opportunities

- T001, T002, T003 are `[P]` (independent read-only runs).
- Within US1, T005 (entropicFluxBalanceAnalysis) and T006 (solveCobraEP) touch different files and
  are `[P]` after T004 pins the lines; T007 (test) can be authored in parallel, verified by T008.
- US1 and US2 slices are independent (`entropicFBA` src + gecko test vs. the legacy test file).
- T016, T017 are `[P]` in Phase 5.

## Independent Test Criteria

- **US1**: V2 — infeasible enzyme EP → `stat==0` + non-empty `messages`, no crash (mosek).
- **US2**: V1 — legacy test green standalone, reaches the function under test.
- **US3**: V3 — feasible GECKO toy under mosek: no dual-optimality warning (fix) or documented
  tolerated residual (characterize); `testEntropicFBAgecko` deterministic.

## Suggested MVP

US1 (the crash fix) is the highest-value slice and, with US2 (trivial), forms the low-risk MVP that
lands before the higher-risk US3 dual-residual work — matching the plan's success-gate ordering.

## Deviations (recorded 2026-07-16, all in the receipt)

- **T006 (FR-003):** root cause is `buildOptProblemFromModel.m:315` sizing `names.con = model.mets`
  when `ctrs` absent but `C` present (out of FR-009 scope). Fixed in-scope by naming the toy
  coupling constraint (`model.ctrs`). Latent `buildOptProblemFromModel` behaviour → follow-up.
- **US2 (FR-005):** the index fix alone left the test erroring on Recon3D's 10 inconsistent
  metabolites; added a stoichiometric-consistency restriction in the test (beyond "index only") so
  it validates the solve. Spec assumption ("passes on raw Recon3D") was solver-dependent.
- **US3 (FR-006):** resolved via a fix (not the characterize fallback) — a reduced-cost sign error
  in the mosek `res2` residual; drops 1.45→~3e-7 (GECKO) and 1187→2.5e-8 (non-enzyme).

## Total: 19 tasks

- Setup/Baseline: 4 (T001–T004) · US1: 4 (T005–T008) · US2: 2 (T009–T010) · US3: 5 (T011–T015) ·
  Polish: 4 (T016–T019).
