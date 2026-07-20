# Implementation Plan: Optional GECKO support in entropicFluxBalanceAnalysis

**Branch**: `010-gecko-entropic-fba` | **Date**: 2026-07-15 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/010-gecko-entropic-fba/spec.md`

## Summary

Add optional enzyme-constrained (GECKO) support to `entropicFluxBalanceAnalysis`: when the
`E`/`evarlb`/`evarub`/`evarc`/`D` fields are present, fold `[S E; C D]` + evar bounds/objective into
the entropic problem and apply entropy weights to the enzyme variables (CQ2); when absent, behave
byte-for-byte as today. Research (`research.md`) established that the external `AdaptGECKO` fork is a
**partial** reference only — it represents enzymes as external reactions and does NOT put entropy on
them — so 010 implements the cleaner `E`/`evar*`/`D` representation (matching `buildOptProblemFromModel`)
plus new entropy-on-enzyme handling, harvesting only the fork's consistency-skip discipline, then
retiring the fork. Scope 010 to the `fluxes` method under both `mosek` and `pdco`; a characterization
net pins the current non-GECKO behaviour first.

## Technical Context

**Language/Version**: MATLAB R2024b+ (dev env R2026a, headless-capable).

**Primary Dependencies**: `solveCobraEP` (entropic solver, mosek/pdco), `buildOptProblemFromModel`
(the `E`/`evar*`/`D` semantics source of truth), `findStoichConsistentSubset`, `processFluxConstraints`.

**Storage**: N/A. Fixtures: a minimal committed enzyme-constrained model under `test/`.

**Testing**: characterization test pinning current `fluxes` non-GECKO behaviour (both backends) +
a GECKO test on the minimal fixture; `prepareTest`-gated; MATLAB MCP for reference capture/verification.
Liver-GECKO full-mode-only (CQ3).

**Target Platform**: headless Linux/Docker CI; local mosek + pdco available.

**Project Type**: additive change to a core solver function.

**Performance Goals**: no change to the default (no-`E`) path; tiny GECKO fixture for CI.

**Constraints**: Principle II (no interface/field/default-result change); Principle IV (route via
`solveCobraEP`, canonical `.stat`, preserve `.origStat`); the enzyme columns must stay in the entropy
log-domain (strictly positive) when `d>0`.

**Scale/Scope**: edit `entropicFluxBalanceAnalysis.m` (additive, behind field detection) + a new shared
enzyme-block helper under `entropicFBA/`; 2 new tests + 1 fixture. `fluxes` method; mosek+pdco.

## Constitution Check

*GATE: pre- and post-design.* — **PASS** (additive; no unjustified violations).

- **Scientific code quality**: the change preserves stoichiometry/objective-sense semantics; adds
  enzyme variables with entropy terms. The status/feasibility/objective meaning is unchanged for
  non-GECKO models; for GECKO models the `[S E; C D]` system and evar bounds/objective define the
  science. Model fields consumed match `buildOptProblemFromModel` (single source of truth).
- **Testing and reproducibility**: characterization test pins current `fluxes` behaviour (`.stat`,
  objective, flux, duals within tol, both backends) BEFORE the change; GECKO test on the minimal
  fixture asserts a feasible enzyme-constrained solution. `prepareTest`-gated; references captured via
  MATLAB MCP; runs in `testAll.m`/CI; liver-GECKO full-mode-only.
- **User experience and diagnostics**: no console/printLevel change on the default path; clear errors
  (with `ME.stack`) on E/evar/D dimension mismatch.
- **Performance and numerical integrity**: default path unchanged; entropy on enzyme columns keeps the
  log-domain (strictly-positive) invariant the existing entropy vars use; no verification skipped.
- **External-solver configuration audit (Principle IV)**: DONE in `research.md` R4/R6 — both mosek
  (`nExpCone=nnz(d)`, one PEXP cone per entropy column) and pdco (`deq` entropy term) represent the
  enzyme entropy columns; the caller's post-solve index bookkeeping (`Fty_K` reordering,
  `auxPrimal/coneF/auxRcost` offsets) MUST be updated when `nExpCone` grows. Representative instance:
  the minimal fixture under both backends.
- **Spec-driven scope control**:
  - Edit: `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m` (additive, behind field
    detection); NEW `src/base/solvers/entropicFBA/<helper>.m` (enzyme-block validate/prepare).
  - Read-only reference (retire, do not depend at runtime): the external `AdaptGECKO*` fork.
  - MUST NOT change: the default (no-`E`) code path/results, `solveCobraEP` signature, public interface,
    any existing model field meaning. `fluxConc`/`fluxConcNorm` enzyme support is OUT (documented follow-up).
- **MATLAB standards (VII)**: openCOBRA header on new/edited functions; `exist`/`isempty` for optional
  fields (not `nargin`); warnings visible; `try/catch ME` propagates `ME.stack`; no `evalc` shadowing;
  camelCase. Run `check_matlab_code` on new/edited files.
- **Parameter-setting fidelity**: N/A (no cross-language port).
- **Artifact placement (IX)**: new source under `entropicFBA/`; tests under `test/verifiedTests/`;
  fixture beside its test.

## Project Structure

### Documentation (this feature)

```text
specs/010-gecko-entropic-fba/
├── spec.md · plan.md · research.md · data-model.md · quickstart.md
├── checklists/requirements.md · human-loop.md · tasks.md
```

### Source / tests

```text
src/base/solvers/entropicFBA/
├── entropicFluxBalanceAnalysis.m   # EDIT: optional E/evar*/D detection + [S E; C D] fold-in
│                                   #       + entropy-d on enzyme columns + scoped consistency relax
│                                   #       + updated post-solve unpacking/cone-dual reindexing
└── prepareEnzymeConstrainedEP.m    # NEW (working name): validate dims + build the enzyme block/helper

test/verifiedTests/analysis/ (or base/testSolvers/)
├── testCharacterizeEntropicFBA/    # NEW: pin current non-GECKO 'fluxes' behaviour (mosek+pdco)
└── testEntropicFBAgecko/           # NEW: minimal committed enzyme fixture through the GECKO path
```

**Structure Decision**: additive edit confined to `entropicFBA/` + a new helper; tests under
`verifiedTests/`. Characterization first (regression net), then the GECKO fold-in.

## Complexity Tracking

No Constitution violations. Risk/decision notes for Gate 2:

| Item | Note |
|------|------|
| Entropy on enzyme columns (CQ2) | New vs the fork (which uses `d=0`). Requires growing `nExpCone` and re-indexing the post-solve cone-dual reordering + variable/dual extraction per backend — the main risk; mitigated by the characterization net + backend audit. |
| Representation choice | 010 uses `E`/`evar*`/`D` (buildOptProblemFromModel), NOT the fork's external-reaction hack — cleaner + single-sourced, but means less of the fork is directly reusable. |
| Method scope | `fluxes` only; `fluxConc`/`fluxConcNorm` enzyme support documented as follow-up (avoid a partial, poorly-verified multi-method change). |
| Log-domain | Enzyme entropy columns must stay strictly positive; reuse the existing entropy-var domain handling. |
