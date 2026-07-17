# Implementation Plan: GECKO documentation header and enzyme-aware KKT/thermodynamic diagnostics for entropicFluxBalanceAnalysis

**Branch**: `012-gecko-diagnostics-docs` | **Spec**: [spec.md](./spec.md)
**Input**: spec.md (US1 header docs; US2 enzyme-aware diagnostics) + Clarifications 2026-07-17

## Summary

Two additive, print-and-docs-only improvements to `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m`:
- **US1 (P1)** — document the GECKO/enzyme surface added by 010 in the openCOBRA help header (comments only).
- **US2 (P2)** — make the `printLevel > 1` KKT/thermo diagnostic blocks enzyme-aware by adding, guarded
  by `hasEnzymes`, (i) an enzyme-column stationarity line `model.evarc + model.E'*y_N + model.D'*y_C +
  solution.z_e`, (ii) the `model.E*solution.e` term in the primal mass-balance residual, and (iii) a
  coupling primal residual `model.C*(vf-vr) + model.D*solution.e - model.d` when `model.C` is present —
  in BOTH the pdco and mosek `'fluxes'` branches. Non-enzyme output is byte-identical (FR-004).

## Technical Context

**Language/Version**: MATLAB (R2026a locally); solvers mosek 11.2 + pdco via `changeCobraSolver`.
**Primary dependencies**: `solveCobraEP` (unchanged), `prepareEnzymeConstrainedEP` (010, unchanged),
the committed `buildEnzymeToy` fixture (010).
**Storage**: N/A. **Project type**: single (MATLAB toolbox).
**Target**: `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m` + one new test under
`test/verifiedTests/`. **Allowed edit set (FR-009)**: those two files only; NOT `solveCobraEP.m`.
**Performance/integrity**: print-only; returned `solution` (`v`, objective, `.stat`, `.origStat`)
unchanged within 1e-6 (SC-006); enzyme stationarity residual ≤ ~1e-3 on the toy under both backends (SC-003).
**Scope of diagnostic edits**: the `'fluxes'` method blocks only (enzymes are supported only there);
`'fluxesConcentrations'`/`'fluxConcNorm'` diagnostics unchanged.

**Resolved unknowns** (see research.md): R1 block locations & in-scope variables; R2 `ve/ce/z_ve` are
external reactions NOT enzymes (use `solution.e`/`z_e`/`model.E/D/evarc`); R3 linear enzyme columns ⇒
no cone/`Fty_K` reindexing; R4 the three enzyme-augmented expressions; R5 verify backend dual sign
empirically (011 pattern); R6 recompute the enzyme residual in the test rather than parse stdout.

## Constitution Check

*Constitution v1.3.0. Gates evaluated before Phase 0 and re-checked after design.*

- **I (Scientific correctness)**: positive — the feature REMOVES a misleading diagnostic (enzyme
  KKT never shown for GECKO). Enzyme stationarity derived analytically (R4) and verified vs both
  backends' duals (R5).
- **II (Backward compatibility)**: PASS — no public interface, argument order, model-field, or
  solution-field-meaning change; all diagnostic additions guarded by `hasEnzymes`; non-enzyme printed
  output byte-identical (FR-004/SC-004); returned solution unchanged (FR-005/SC-006). Header change is
  comments-only (FR-002/SC-002).
- **III (Testing + characterization)**: PASS — the non-enzyme diagnostic invariance is pinned FIRST
  (characterization) before the enzyme-aware additions; new GECKO residual assertion added.
- **IV (Solver abstraction)**: PASS — no change to `solveCobraEP` or any solver call; diagnostics
  computed from the already-returned `solution`. Canonical `.stat`/`.origStat` untouched.
- **VII (MATLAB standards)**: VII-E header stays Sphinx-parseable (US1 edits the existing header
  layout); VII-B warnings stay visible (the test must not hide warnings when capturing stdout — R6
  prefers recompute over `evalc`); VII-A no `evalc` suppression in source; VII-G camelCase/filesep.
- **IX (File placement)**: PASS — source stays at `src/base/solvers/entropicFBA/`; test under
  `test/verifiedTests/<category>/`.

**Gate result**: PASS, no violations, no Complexity Tracking entries required.

## Project Structure

### Documentation (this feature)
```
specs/012-gecko-diagnostics-docs/
├── spec.md, plan.md, research.md, data-model.md, quickstart.md
├── checklists/requirements.md
├── human-loop.md, implementation-review.md
└── agent-runs/<UTC>-<name>/implementation-receipt.md   (Bundle 3)
```

### Source Code (repository root)
```
src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m   # US1 header + US2 diagnostics (guarded)
test/verifiedTests/analysis/testEntropicFBAgeckoDiagnostics/  # new: characterization + GECKO residual
    testEntropicFBAgeckoDiagnostics.m
```
(Exact test path/category finalized in tasks; reuse `buildEnzymeToy`; no change to 010/011 tests.)

## Complexity Tracking

No constitution deviations — table intentionally empty.

## Phase sequence (for tasks)

1. **Setup/Baseline** (read-only): capture current non-enzyme diagnostic output + `check_matlab_code`
   baseline for the function; reproduce the GECKO diagnostic gap on `buildEnzymeToy` at `printLevel=2`.
2. **US1 (P1)**: header docs (comments only) → verify function still runs + `check_matlab_code`.
3. **US2 characterization gate**: pin non-enzyme diagnostic invariance (must be green before enzyme edits).
4. **US2 (P2)**: add the guarded enzyme stationarity + primal terms in pdco and mosek branches; verify
   enzyme residual small on the toy (both backends) + non-enzyme output unchanged.
5. **Polish**: `check_matlab_code` (no NEW flags), Principle II/IV diff review, receipt.
