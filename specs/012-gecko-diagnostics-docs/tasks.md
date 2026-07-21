# Tasks: GECKO documentation header and enzyme-aware KKT/thermodynamic diagnostics

**Feature**: 012-gecko-diagnostics-docs | **Branch**: `012-gecko-diagnostics-docs`
**Input**: plan.md, research.md, data-model.md, quickstart.md, spec.md

**Implementation gate (Principle VI)**: authoring this file does NOT authorize edits. Source/test edits
(T004+) may begin only after an explicit `/speckit-implement`. Verified via the MATLAB MCP server
(mosek + pdco). Per-phase git commits deferred (commit at bundle boundary / on request).

**Allowed edit set (FR-009)** — only these two files may be modified:
- `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m`
- `test/verifiedTests/analysis/testEntropicFBAgeckoDiagnostics/testEntropicFBAgeckoDiagnostics.m` (new)

Every source/test edit carries these acceptance constraints: warnings stay visible (VII-B), any
`try/catch` propagates `ME.message`+`ME.stack` (VII-C), no `evalc` SUPPRESSION or built-in shadowing in
SOURCE (VII-A), openCOBRA/Sphinx header preserved (VII-E), `camelCase`/`filesep` (VII-G); tests gate via
`prepareTest`/`mosekopt` existence and skip gracefully (III); NO public signature / model-field /
`solution`-field-meaning / `.stat`/`.origStat` / default (non-enzyme) printed-diagnostic change (II/IV);
diagnostics are print-only and computed from the already-returned `solution` (IV).

---

## Phase 1: Setup & Baseline (read-only — no source edits)

- [X] T001 [P] Baseline the NON-enzyme printed diagnostics: solve a non-enzyme model (ecoli_core and the Recon3D consistent subset used by `testEntropicFluxBalanceAnalysis`) via `entropicFluxBalanceAnalysis` at `param.printLevel=2` under mosek + pdco through the MATLAB MCP; capture the printed "Optimality/Derived/Thermo" block text (and/or the recomputed residual values) as the FR-004 reference. Save to `specs/012-gecko-diagnostics-docs/agent-runs/<UTC>-<name>/baseline.md`.
- [X] T002 [P] Capture the `check_matlab_code` baseline for `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m` (record existing flags so SC-005 "no NEW flags" is measurable). Save to baseline.md.
- [X] T003 [P] Reproduce the GECKO diagnostic gap: solve `buildEnzymeToy(3,2)` (local fixture from `testEntropicFBAgecko.m`) at `printLevel=2` under mosek + pdco; recompute `model.evarc + model.E'*y_N + model.D'*y_C + solution.z_e` and record its (large / sign-ambiguous) value BEFORE the fix, plus the per-backend `solution.z_e`/`y_N`/`y_C` sign convention (R5). Read-only. Save to baseline.md.

**Checkpoint**: baseline.md records the non-enzyme reference output, static-analysis flags, and the pre-fix enzyme residual + backend sign conventions.

---

## Phase 2: User Story 1 — GECKO capability documented in the header (Priority: P1)

**Goal**: the openCOBRA help header documents the enzyme surface (FR-001/FR-002, SC-001/SC-002).

**Independent test**: V1 — `help entropicFluxBalanceAnalysis` lists the enzyme fields/param/outputs; the diff below the header is empty (comments-only).

- [X] T004 [US1] In the header of `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m`, add to OPTIONAL INPUTS: `model.E` (`m x nEvar` enzyme columns in the metabolite rows), `model.D` (`nCoupling x nEvar` enzyme columns in the coupling rows), `model.evarlb`/`model.evarub` (enzyme bounds), `model.evarc` (enzyme linear objective), `model.evars` (enzyme names), and `param.enzymeEntropyWeight` (enzyme columns LINEAR by default at weight 0; entropy on enzyme columns experimental opt-in when > 0). Add to OUTPUT: `solution.e` (enzyme-usage primal) and `solution.z_e` (enzyme reduced cost). Keep the existing INPUT/OPTIONAL INPUTS/OUTPUT Sphinx-parseable layout (VII-E). Comments only — no executable statement changed. (FR-001/FR-002)
- [X] T005 [US1] Verify US1: run `testEntropicFBAgecko` and `testEntropicFluxBalanceAnalysis` (mosek + pdco) via the MATLAB MCP — still green; run `check_matlab_code` — no NEW flags vs T002; confirm `git diff` of the function shows only comment lines above the first executable statement (SC-002).

**Checkpoint**: header documents the full enzyme surface; function behaviour and static analysis unchanged.

---

## Phase 3: User Story 2 (part A) — HARD GATE: characterize non-enzyme diagnostic invariance (Priority: P2)

> **HARD GATE (T007)**: the non-enzyme diagnostic characterization MUST be green before any
> diagnostic-logic edit (Phase 4). Principle III: pin current behaviour first.

**Goal**: a test that fails if the non-enzyme printed diagnostics change (FR-004/SC-004).

**Independent test**: V3 — non-enzyme diagnostic residuals identical pre/post under both backends.

- [X] T006 [US2] Create `test/verifiedTests/analysis/testEntropicFBAgeckoDiagnostics/testEntropicFBAgeckoDiagnostics.m` with an openCOBRA header (VII-E). Add a NON-enzyme characterization case: solve a small non-enzyme model at `printLevel=2` under mosek + pdco and assert the recomputed non-enzyme diagnostic residuals (mass balance, dual optimality, thermo) match the T001 reference within tolerance. Gate via `prepareTest`/`mosekopt` existence, skip gracefully (III); keep warnings visible (VII-B); `try/catch` re-raises with `ME.message`+`ME.stack` (VII-C). No source edit yet. (FR-004/SC-004)
- [X] T007 [US2] HARD GATE: run `testEntropicFBAgeckoDiagnostics` (non-enzyme case) via the MATLAB MCP against the UNCHANGED source; confirm green (it characterizes current behaviour). Record in the receipt.

**Checkpoint**: the non-enzyme diagnostic invariant is pinned and green against unchanged source.

---

## Phase 4: User Story 2 (part B) — enzyme-aware diagnostics (Priority: P2, print-only)

**Goal**: the `printLevel>1` blocks report the enzyme KKT for GECKO (FR-003/FR-005/FR-008, SC-003/SC-006).

**Independent test**: V4 — enzyme stationarity residual small on `buildEnzymeToy` (both backends); V3 non-enzyme output still identical; V5 returned solution unchanged.

- [X] T008 [US2] In the pdco `'fluxes'` diagnostic block (~L420–532) of `entropicFluxBalanceAnalysis.m`, guarded by `hasEnzymes`, add: (i) the enzyme stationarity line `norm(model.evarc + model.E'*y_N + model.D'*y_C + solution.z_e, inf)` with a clear label (sign per the T003 backend convention); (ii) the `+ model.E*solution.e` term in the printed primal mass-balance residual; (iii) when `isfield(model,'C')`, a coupling primal line `norm(model.C*(v) + model.D*solution.e - model.d, inf)`. Use `solution.e`/`solution.z_e`/`model.E`/`model.D`/`model.evarc`; count via `size(model.E,2)`. Non-enzyme path untouched (guard). (FR-003/FR-005)
- [X] T009 [US2] Apply the same three guarded additions in the mosek `'fluxes'` diagnostic block (~L763+), using that branch's `y_N`/`y_C` and `solution.z_e` (verify the sign against T003 for mosek, per the 011 pattern). Keep the additions strictly inside `if hasEnzymes`. (FR-003/FR-005)
- [X] T010 [US2] Extend `testEntropicFBAgeckoDiagnostics.m` with the GECKO case: solve `buildEnzymeToy(3,2)` at `printLevel=2` under mosek + pdco; assert the recomputed enzyme stationarity residual ≤ tolerance (target ≤ ~1e-3) on BOTH backends (FR-003/FR-008/SC-003); assert the returned `solution.v`/objective/`.stat`/`.origStat` equal the `printLevel=0` values within 1e-6 (print-only, FR-005/SC-006).
- [X] T011 [US2] Re-run `testEntropicFBAgeckoDiagnostics` (non-enzyme + GECKO), `testEntropicFBAgecko`, and `testEntropicFluxBalanceAnalysis` under mosek + pdco; confirm the non-enzyme diagnostic characterization (T007) still green (FR-004/SC-004) and all nets green.

**Checkpoint**: GECKO diagnostics report the enzyme KKT (small residual, both backends); non-enzyme output and returned solution unchanged.

---

## Phase 5: Polish & Verification (cross-cutting)

- [X] T012 [P] Run `check_matlab_code` on both edited files; confirm no NEW flags vs the T002 baseline (SC-005); confirm the header stays Sphinx-parseable (VII-E) and camelCase/filesep (VII-G).
- [X] T013 [P] Principle II/IV diff review: confirm no change to the `entropicFluxBalanceAnalysis` signature, documented params, model fields, `solution` field meanings, or `.stat`/`.origStat`; confirm NO edit to `solveCobraEP.m` or any solver call; confirm the diagnostics read `solution` only (print-only).
- [X] T014 Confirm the diff is confined to the two allowed files (FR-009) — no stray edits (V6).
- [X] T015 Write the implementation receipt at `specs/012-gecko-diagnostics-docs/agent-runs/<UTC-timestamp>-<short-name>/implementation-receipt.md` with the mandated sections (Prompt, Final response, Diff summary, Tests, Unresolved issues), including the baseline vs post-change enzyme residual values and the per-backend sign determination.

---

## Dependencies & Execution Order

- **Phase 1 (T001–T003)** first — read-only baseline; T001 is the FR-004 reference, T003 pins the backend sign for T008/T009.
- **Phase 2 (US1, T004–T005)** is independent (header comments) and can land as the low-risk MVP before US2.
- **Phase 3 (T006–T007)** HARD GATE — must be green before Phase 4.
- **Phase 4 (T008–T011)** only after T007. T008 (pdco) and T009 (mosek) touch different regions of the same file → sequential (same file); T010/T011 verify.
- **Phase 5** after Phase 4.

## Parallel Opportunities

- T001, T002, T003 are `[P]` (independent read-only runs).
- T012, T013 are `[P]` in Phase 5.
- US1 (header) and the US2 characterization (T006) are independent and could be authored in either order, but T008/T009 (same file, diagnostic regions) run after the T007 gate.

## Independent Test Criteria

- **US1**: V1 — header documents the enzyme surface; diff is comments-only.
- **US2**: V3 (non-enzyme diagnostics unchanged) + V4 (GECKO enzyme residual small) + V5 (solution unchanged).

## Suggested MVP

US1 (header docs, comments-only, zero numerical risk) is the MVP; US2 (enzyme-aware diagnostics) is the
substantive correctness slice gated behind the non-enzyme characterization.

## Total: 15 tasks

- Setup/Baseline: 3 (T001–T003) · US1: 2 (T004–T005) · US2-A gate: 2 (T006–T007) ·
  US2-B: 4 (T008–T011) · Polish: 4 (T012–T015).
