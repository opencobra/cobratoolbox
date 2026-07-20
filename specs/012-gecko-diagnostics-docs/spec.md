# Feature Specification: GECKO documentation header and enzyme-aware KKT/thermodynamic diagnostics for entropicFluxBalanceAnalysis

**Feature Branch**: `012-gecko-diagnostics-docs`

**Created**: 2026-07-16

**Status**: Draft

**Input**: User description: "The entropicFluxBalanceAnalysis header needs to be updated to reflect new [GECKO] ability. Also, the Thermo conditions diagnostics needs to be updated for the gecko case." (surfaced while landing features 010-gecko-entropic-fba and 011-entropicfba-dual-fixes)

<!--
  CHARACTERIZATION MODE: Part 2 (diagnostics) back-fills a pin on the CURRENT
  non-enzyme printed-diagnostic output of an existing function so the additive
  enzyme-aware change is provably invariant for non-GECKO models. See Constitution
  Principle III (Characterization: Legacy Back-Fill Mode). The "Existing Contract"
  section captures that current behaviour.
-->

## Clarifications

### Session 2026-07-17

- Q: How should the enzyme-column KKT condition (`ce + E'*y_N + D'*y_C + z_ve`) reported by the diagnostics be established? → A: Derive it analytically from the problem Lagrangian and verify against BOTH backends' returned duals (mosek and pdco use opposite reduced-cost sign conventions — found in 011), not an empirical match to solver output.
- Q: Which `printLevel > 1` diagnostic blocks are made enzyme-aware? → A: ALL blocks that currently omit enzyme terms — "Optimality conditions (biochemistry)", "Derived optimality conditions (biochemistry)", and "Thermo conditions" (plus their "(regularised)" variants) — for the `'fluxes'` method, not only the "Thermo conditions" block.
- Q: What test strategy proves the change? → A: Both — a GECKO check asserting the enzyme-augmented residual is small (FR-003) AND a characterization pin that the non-enzyme diagnostic output is unchanged (FR-004).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - The GECKO/enzyme capability is documented in the function header (Priority: P1)

A user reads `help entropicFluxBalanceAnalysis` (or the generated Sphinx page) to learn whether and how enzyme-constrained (GECKO/ecModel) models are supported. Today the header (≈lines 1–130) documents `S, c, lb, ub, C/d, g/f, Q/H, SConsistent*` but says nothing about the optional enzyme fields that feature 010 added, the `param.enzymeEntropyWeight` option, or the returned enzyme solution fields — so the capability is undiscoverable from the documentation.

**Why this priority**: Zero numerical risk (comments only) and it is the prerequisite for anyone to *use* the GECKO path landed in 010. A documented interface is the smallest self-contained increment that delivers value on its own, so it is the MVP.

**Independent Test**: Inspect the header after the change: it names every optional enzyme field (`model.E`, `model.D`, `model.evarlb`, `model.evarub`, `model.evarc`, `model.evars`), the `param.enzymeEntropyWeight` option (linear default; experimental opt-in), and the returned `solution.e` / `solution.z_e`, in the existing INPUT / OPTIONAL INPUTS / OUTPUT layout, and the file still parses (`check_matlab_code` clean; function runs unchanged).

**Acceptance Scenarios**:

1. **Given** the revised function, **When** a user runs `help entropicFluxBalanceAnalysis`, **Then** the OPTIONAL INPUTS section documents `model.E/D/evarlb/evarub/evarc/evars` and `param.enzymeEntropyWeight`, and the OUTPUT section documents `solution.e` and `solution.z_e`.
2. **Given** the revised function, **When** its diff against the prior version is inspected, **Then** only comment/header lines changed — no executable statement was added, removed, or reordered.

---

### User Story 2 - KKT/thermodynamic diagnostics are correct for the GECKO case (Priority: P2)

An analyst solves a GECKO/enzyme-constrained model with `printLevel > 1` (debug) to check the optimality/thermodynamic consistency of the returned solution. Today the printed "Optimality conditions (biochemistry)", "Derived optimality conditions (biochemistry)", and "Thermo conditions" blocks are written purely in the flux/coupling quantities (`N, B, C, y_N, y_C, y_vi, z_*`) and omit the enzyme-variable stationarity and coupling contributions, so for a GECKO model the reported residuals are incomplete and misleadingly large (e.g. the enzyme-column stationarity `ce + E'*y_N + D'*y_C + z_ve` is never shown as converged). The analyst cannot use the diagnostics to trust an enzyme-constrained solution.

**Why this priority**: Higher effort (requires the enzyme-column KKT derivation) and it affects only debug-level output, so it follows the documentation slice. It is a Principle-I correctness improvement (diagnostics must not mislead) and unblocks trusting GECKO entropic-FBA ahead of the deferred full-mode liver-GECKO dual-validation.

**Independent Test**: Solve the committed GECKO toy (`buildEnzymeToy`) at `printLevel > 1` under mosek + pdco; the enzyme-augmented optimality/thermo residuals print small (KKT satisfied) where the enzyme-omitting expression was large; and the printed diagnostic text for a non-enzyme model is byte-for-byte identical to the pre-change output.

**Acceptance Scenarios**:

1. **Given** a GECKO model with enzyme columns, **When** it is solved at `printLevel > 1`, **Then** the printed optimality/thermo blocks include the enzyme stationarity and coupling terms and their residuals are below the stated tolerance under both backends.
2. **Given** a non-enzyme model, **When** it is solved at `printLevel > 1`, **Then** the printed diagnostic blocks are unchanged (identical text and residual labels) from before this feature.
3. **Given** either model, **When** solved with any `printLevel`, **Then** the returned `solution` (primal `v`, objective, `.stat`, `.origStat`, all fields) is unchanged within 1e-6 — the change is print-only.

---

### Edge Cases

- **`printLevel ≤ 1`**: no diagnostic blocks are printed; this feature changes nothing on that path.
- **Non-enzyme model at `printLevel > 1`**: the enzyme-aware branch is not taken; output must be byte-identical to today (the characterization invariant).
- **`entropicFBAMethod = 'fluxesConcentrations'` with enzymes**: enzyme support was added by 010 only for the `'fluxes'` method; the enzyme-aware diagnostics are scoped to `'fluxes'`. The concentration diagnostics are out of scope and left unchanged.
- **Partial enzyme fields** (e.g. `model.D` empty with no coupling rows): handled by the existing 010 validation (`prepareEnzymeConstrainedEP`); the diagnostics use whatever enzyme duals the solve returned.
- **`enzymeEntropyWeight > 0`** (experimental entropy on enzymes): the enzyme stationarity gains an entropy term; the diagnostics should reflect the linear-default case correctly and, where feasible, the opt-in case — but the experimental entropy path is not a required correctness target (its dual validation is a separate deferred item).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001** (US1): The help header MUST document, in the existing Sphinx-parseable INPUT / OPTIONAL INPUTS / OUTPUT layout, the optional enzyme fields `model.E`, `model.D`, `model.evarlb`, `model.evarub`, `model.evarc`, `model.evars`; the `param.enzymeEntropyWeight` option (enzyme columns linear by default at weight 0; entropy on enzyme columns is experimental opt-in when > 0); and the returned `solution.e` (enzyme-usage primal) and `solution.z_e` (enzyme reduced cost).
- **FR-002** (US1): The header change MUST be documentation-only — no executable statement added, removed, or reordered; the change is confined to the comment/header region.
- **FR-003** (US2): When enzyme columns are present and `printLevel > 1`, ALL the affected diagnostic blocks — "Optimality conditions (biochemistry)", "Derived optimality conditions (biochemistry)", and "Thermo conditions" (plus their "(regularised)" variants) for the `'fluxes'` method — MUST include the enzyme-column KKT stationarity (`ce + E'*y_N + D'*y_C + z_ve`, adjusted for any `enzymeEntropyWeight` term) and the enzyme contribution to the mass-balance / coupling residuals, so the reported residuals reflect the true KKT conditions of the enzyme-augmented problem. The stationarity is derived analytically and verified against both backends' returned duals (Clarifications 2026-07-17).
- **FR-004** (US2): When enzyme columns are ABSENT, the printed diagnostic output MUST be byte-for-byte identical to the pre-change output under both `mosek` and `pdco`.
- **FR-005** (US2): The diagnostics change MUST be print-only: no change to the returned `solution`, the primal, `.stat`, `.origStat`, or any numerical result.
- **FR-006**: The feature MUST preserve the documented public interface, argument order, model-field and solution-field meanings, solver-call abstraction (no change to `solveCobraEP` or any solver call), and the `src/base/solvers/entropicFBA/` file location (Principle II/IV/IX).
- **FR-007**: The feature MUST define the narrowest reproducibility checks: a characterization test pinning the non-enzyme printed-diagnostic invariance (FR-004), and a GECKO verification asserting the enzyme-augmented residual is small (FR-003), both under `mosek` + `pdco` via the MATLAB MCP server.
- **FR-008**: The enzyme-augmented KKT/thermo residual on the committed GECKO toy MUST be below a stated tolerance under both backends; the non-enzyme residual values and labels MUST be unchanged.
- **FR-009** (allowed edit set): Only `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m` (source) and one test under `test/verifiedTests/<category>/` may be modified. No change to `solveCobraEP.m` or any other source.

### Key Entities *(include if feature involves data)*

- **Enzyme-usage variables (`e`)**: the GECKO/ecModel column variables (`model.E`/`model.D` columns, bounds `evarlb`/`evarub`, objective `evarc`), returned as `solution.e` with reduced cost `solution.z_e` (added by feature 010).
- **Printed diagnostic blocks**: the `printLevel > 1` KKT/thermo read-out sections ("Optimality conditions (biochemistry)", "Derived optimality conditions", "Thermo conditions", and their `(regularised)` variants) computed from the returned primal/dual solution — the subject of Part 2.
- **Enzyme dual terms**: `y_N` (mass-balance dual, contributes `E'*y_N`), `y_C` (coupling dual, contributes `D'*y_C`), `z_ve` (enzyme bound reduced cost) — the quantities the diagnostics currently omit.

## Existing Contract *(characterization mode — Part 2)*

- **Function(s) under test**: `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m`
- **Current inputs / arities**: `[solution, modelOut] = entropicFluxBalanceAnalysis(model, param)`; signature unchanged since 010. Enzyme fields (`E/D/evar*`) and `param.enzymeEntropyWeight` are optional (010). Diagnostic blocks print only when `param.printLevel > 1` / `param.debug`.
- **Current outputs**: `solution` (with `.e`/`.z_e` when enzymes present, from 010); printed KKT/thermo diagnostic text at `printLevel > 1`.
- **Invariants & expected results**: for a non-enzyme model, every printed diagnostic block (text, labels, and residual magnitudes to the printed precision) and every returned field are UNCHANGED by this feature. The current non-enzyme "Thermo conditions" full-condition residual on the Recon3D consistent subset is ~6e-4 (small); the "ideal reduced" thermo lines are large by construction (only hold under the header's stated ideal assumptions) — both are preserved verbatim.
- **Coverage gap**: the printed diagnostic blocks have never had a test asserting their content or invariance, and the enzyme case has no KKT read-out at all (surfaced by 010/011).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001** (US1): A reader of the header / generated docs can identify all six optional enzyme fields, the `enzymeEntropyWeight` option, and the `solution.e`/`solution.z_e` outputs — 100% of the enzyme surface added by 010 is documented.
- **SC-002** (US1): The header change adds zero executable statements — the diff within the function body (below the header) is empty.
- **SC-003** (US2): On the GECKO toy at `printLevel > 1`, the enzyme-augmented KKT/thermo residual is ≤ the stated tolerance (target: same order as the existing non-enzyme optimality residuals, ≤ ~1e-3) under `mosek` + `pdco`, where the enzyme-omitting expression was ≥ several orders larger.
- **SC-004** (US2): On a non-enzyme model at `printLevel > 1`, the printed diagnostic block text is identical pre/post change under both backends (characterization invariant).
- **SC-005**: The MATLAB verification (characterization test + GECKO diagnostic check) completes with the expected solver status strings (`OPTIMAL`, `MSK_RES_OK`) and residual labels.
- **SC-006**: The returned `solution` (`v`, objective, `.stat`, `.origStat`) for both GECKO and non-GECKO models is unchanged within 1e-6 (print-only change).

## Assumptions

- **Enzyme KKT form (confirmed, Session 2026-07-17)**: for the linear-default enzyme columns the stationarity is `ce + E'*y_N + D'*y_C + z_ve = 0` (no entropy term because enzyme columns are linear by default); the enzyme-aware diagnostics derive from this analytically and verify against both backends' returned duals, rather than empirically matching solver output.
- **Blocks in scope (confirmed, Session 2026-07-17)**: all `printLevel > 1` biochemistry diagnostic blocks that currently omit enzyme terms — "Optimality conditions (biochemistry)", "Derived optimality conditions (biochemistry)", and "Thermo conditions" (plus their `(regularised)` variants) — for the `'fluxes'` method, not only the "Thermo conditions" block the user named.
- **Test strategy (confirmed, Session 2026-07-17)**: add a GECKO diagnostic-residual assertion (enzyme-augmented residual small) AND a characterization pin of the non-enzyme diagnostic invariance — not documentation-only.
- **Method scope**: enzyme support exists only in the `'fluxes'` `entropicFBAMethod` (010); the `'fluxesConcentrations'` diagnostics are out of scope and unchanged.
- **Fixture**: the committed `buildEnzymeToy` fixture (from 010's `testEntropicFBAgecko`) is sufficient; no new heavyweight model is required. The non-enzyme invariant is checked on the Recon3D stoichiometrically consistent subset used by `testEntropicFluxBalanceAnalysis` (011).
- **Trigger unchanged**: `printLevel > 1` / `debug` remains the sole trigger for the diagnostic blocks.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001, FR-002 (header documents enzyme surface; docs-only) | header inspection + `check_matlab_code` + existing `testEntropicFBAgecko` still green | `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m` |
| US1 / SC-002 (zero executable diff) | diff review (body unchanged) | `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m` |
| US2 / FR-003, FR-008, SC-003 (enzyme-augmented residual small) | new GECKO diagnostic check on `buildEnzymeToy`, mosek + pdco | `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m` |
| US2 / FR-004, SC-004 (non-enzyme diagnostic text unchanged) | new characterization pin of non-enzyme diagnostic output, mosek + pdco | `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m` |
| US2 / FR-005, SC-006 (print-only; solution unchanged) | assert `v`/objective/`.stat`/`.origStat` unchanged within 1e-6 (GECKO + non-GECKO) | `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m` |
