# Implementation Plan: Extreme-Ray Coverage Without Sacrificing Accuracy

**Branch**: `20260915-082551-extreme-ray-coverage` | **Date**: 2026-09-15 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/20260915-082551-extreme-ray-coverage/spec.md`

## Summary

No single LP solver currently gives `greedyExtremeRayBasis` both coverage and accuracy.
gurobi clears the derived accuracy target by four orders but finds 101 of 105 rays; mosek
finds all 105 but misses the target by four orders. The geometry is not the obstacle — the
non-negative cone provably spans the whole left nullspace — so the shortfall is vertex
selection under degeneracy.

The plan is **paired measurement first, tuning second**. A matched harness inside the
routine hands every solver the identical partial basis and the identical objective vector,
so a solver's contribution is separated from the search path it would otherwise diverge
onto. Only then are tuned per-solver settings chosen, and only then — if neither tuned
single-solver approach succeeds — is the two-solver fallback built.

**Nothing is tuned before it is measured, and no mechanism is assumed.** The parent
feature's lesson was that a plausible mechanism recorded as established is the trap; the
interior-point-versus-simplex story in R2 is written as a hypothesis with a decision rule,
not as a finding.

## Technical Context

**Language/Version**: MATLAB, baseline R2024b or newer; developed against R2026a, which
errors on non-scalar colon operands (`1:size(x,1)` explicitly, never `1:size(x)`).

**Primary Dependencies**: the COBRA solver abstraction (`solveCobraLP`,
`changeCobraSolver`, `getCobraSolverParams`) and the parent feature's derived accuracy
target. No new dependency.

**Storage**: N/A. Measurement records are artifacts under this feature directory.

**Testing**: `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m` —
**extended, not duplicated** (Principle III-Naming: exactly one test file per function).

**Target Platform**: headless Linux in Docker (`matlab -batch`).

**Project Type**: single MATLAB project; change confined to one analysis function plus,
contingent on a gate decision, its LP worker.

**Performance Goals**: none promised. Runtime is reported so a remedy's cost is visible.
A tuned setting that buys coverage at unusable cost is a finding, not a success.

**Constraints**: the parent feature's contract is inherited whole and MUST NOT be
weakened — derived accuracy target, five terminal outcomes, trimmed basis, Regime-B
diagnosis, non-negativity. Instrumentation must be inert when off.

**Scale/Scope**: operative matrices to ~1244 x 1710; augmented ~1349 x 2954; sparse.

**Solvers installed here**: gurobi 1302, mosek 11.2, glpk, pdco. Not installed:
ibm_cplex, matlab.

**Inherited, not introduced**: this branch is cut from
`20260914-204640-greedy-left-nullspace-conditioning`, **not `develop`**, because it builds
on that feature's unmerged code. **It MUST be rebased once the parent merges.** The
parent's approved breaking change is inherited; this feature adds no second break.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: the object at risk is the spanning property of a basis, and
  the distinction this plan must keep sharp is between a ray set that is *incomplete* and
  one that is *inaccurate*. Conflating them is the defect. No model field changes meaning.
- **Testing and reproducibility**: the existing `testGreedyExtremeRayBasis.m` is extended
  with coverage, instrumentation-inertness, tuned-setting and untuned-solver cases.
  `prepareTest` declares requirements; seeds are fixed. The `iDopaNeuroC` case remains a
  documented reproducibility check, not CI, because `papers/` is a submodule.
- **User experience and diagnostics**: the status gains coverage-versus-accuracy
  reporting and a sampling-versus-structural distinction. Console output stays behind
  `printLevel`; the status stays complete independently of it.
- **Performance and numerical integrity**: no diagnostic is made skippable for speed. The
  paired harness is off by default and must be *proved* inert (SC-011), not assumed —
  measurement apparatus that perturbs what it measures is worthless.
- **External-solver configuration audit**: **this is the centre of the feature**, and it
  is R3. For gurobi and mosek the plan must enumerate the relevant configuration surface
  and cross-check each default against the actual structural profile — sparse,
  all-equality, simplex-normalised `sum(x)=1`, non-negative orthant, massively
  degenerate, ~1244 x 2954 — then identify and override the mismatches with rationale
  recorded. Principle IV requires precisely this and requires mismatched defaults to be
  overridden rather than merely noted.
- **Spec-driven scope control**: paths to edit are `greedyExtremeRayBasis.m` and the
  existing test. `findExtremePool.m` is **contingent on a gate decision** (below).
  Read-only: `src/base/solvers/**` (used through its interface, deliberately NOT modified
  after the scope narrowing), `varkin`, `getRankLUSOL`, `getNullSpace`,
  `optimalExtremePoolDriver.m`, `testFindExtremePathway.m`, `papers/`, `external/`,
  `deprecated/`.
- **MATLAB coding standards**: no `evalc`; warnings stay visible; any `try/catch ME`
  propagates `ME.message` with `ME.stack(1).file` and `ME.stack(1).line`; optional
  arguments via `~exist(...) || isempty(...)`, not `nargin`; help header updated in the
  same change as the behaviour.
- **Parameter-setting fidelity**: N/A — nothing is ported into another language.
- **Artifact placement**: source change stays in the existing
  `src/analysis/topology/extremeRays/optimalRays/` domain folder; the test stays in
  `test/verifiedTests/analysis/testTopology/`; every measurement record, probe and
  comparison table lives under this feature directory. Nothing generated is written
  under `src/`.

**Gate result: PASS.** The configuration audit is deferred to Phase 0 by design rather
than unresolved. Three decisions are deliberately routed to the implementation-approval
gate rather than taken here.

## Hazards found while reading the solver interface — carry into Phase 0

These are facts about the code this feature will lean on, discovered while preparing the
plan. They are recorded because each could silently corrupt a measurement.

1. **The gurobi `Method` label is off by one against its own comment.**
   `solveCobraLP.m:918-939` documents `0=primal simplex, 1=dual simplex, 2=barrier`, but
   the switch maps `1 -> 'primal simplex'`, `2 -> 'dual simplex'`, `3 -> 'barrier'`, and
   `0` falls through to `'deterministic concurrent'`. **Do not trust this label when
   attributing behaviour to an algorithm.**
2. **That label is a dead variable.** `method` is assigned and never returned or printed,
   so there is no in-toolbox report of which algorithm actually ran. R4's "verify the
   setting took effect" therefore cannot be discharged from the toolbox's own reporting
   and must come from the solver's output.
3. **`vbasis`/`cbasis` are the verification handle.** `solveCobraLP.m:906-913` saves them
   with the comment "only available if crossover was used or simplex method". Their
   presence or absence is a direct, already-surfaced discriminator between a vertex
   solution and an interior one — exactly what R2 needs, and better evidence than any
   parameter echo.
4. **`NUMERICALEMPHASIS` is inconsistent in the shared layer**: defaulted to 1 by
   `getCobraSolverParams`, set to 0 by `CPLEXParamSet`, ignored by every other interface.
   Out of scope here by decision; recorded for a future feature.

## Decisions taken at the approval gate (2026-09-15)

All three were put to the user and answered. They are recorded here as settled, with the
reasoning retained so a reviewer can see what was chosen against what.

| Decision | Answer | Consequence |
|---|---|---|
| **(a)** Edit `findExtremePool.m`? | **Yes — option (a1)** | A solver-settings struct is threaded from `greedyExtremeRayBasis` through `findExtremePool` to `solveCobraLP`, defaulting to today's behaviour so `optimalExtremePoolDriver.m:119` and `testFindExtremePathway.m:75` are unaffected. Tuning reaches the LP where it is built. |
| **(b)** Build A1, the two-solver approach? | **No — dropped entirely** | Not deferred, not conditional. If neither A2 nor A3 meets SC-001 there is no remaining approach, and the deliverable becomes User Story 3: an honest account of the limit. Scope is smaller and the risk of quietly settling for a two-solver dependency is removed. |
| **(c)** Ship the paired instrumentation? | **Yes — off by default** | The comparison stays re-runnable when a solver version changes, at the cost of a permanently supported mode. SC-011 requires proving it inert when off. |

Because (a) is approved, `findExtremePool.m` is **in scope** and the Complexity Tracking
entry below is discharged: the change is additive, with defaults preserving the historical
behaviour of both other callers (Principle II).

### The options as they stood, retained for review

**(a) Is `findExtremePool.m` edited?** It builds the LP whose vertex selection is the
whole problem, so tuned parameters may have to reach it.

| Option | Blast radius | Trade-off |
|---|---|---|
| **(a1) — recommended** Pass a solver-parameter struct from `greedyExtremeRayBasis` through `findExtremePool` to `solveCobraLP`, defaulting to today's behaviour | Additive; `optimalExtremePoolDriver.m:119` and `testFindExtremePathway.m:75` unaffected | Tuning reaches the LP where it is built, without changing any other caller's results |
| (a2) Tune inside `findExtremePool` directly | Both other callers change behaviour | Fixes it for everyone; changes a second public function's numerics unasked |
| (a3) Keep everything in `greedyExtremeRayBasis` and re-solve rays after the fact | None outside the named function | Cannot influence vertex SELECTION, which is the actual mechanism — likely to fail on the merits |

**(b) Is A1 (two-solver) built at all?** *Answered: no, dropped entirely.* The original
reasoning was to sequence it last so it could not bias the comparison; dropping it removes
the question and shrinks scope.

**(c) Does the paired instrumentation ship?** *Answered: yes, off by default.* It is
measurement apparatus; removing it after the campaign would leave the evidence
unreproducible by a later maintainer.

## Project Structure

### Documentation (this feature)

```text
specs/20260915-082551-extreme-ray-coverage/
├── spec.md                  # requirements (23 FR, 14 SC)
├── plan.md                  # this file
├── research.md              # Phase 0: R1-R7, procedures with empty result slots
├── data-model.md            # paired record, tuned parameter sets, shortfall classification
├── quickstart.md            # how a reviewer reproduces the comparison
├── contracts/
│   └── greedyExtremeRayBasis.status-additions.md
├── checklists/requirements.md
├── measurements/            # probes, comparison tables, raw records
└── tasks.md                 # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
src/analysis/topology/extremeRays/optimalRays/
├── greedyExtremeRayBasis.m      # EDIT — tuned settings, paired harness, shortfall classification
├── findExtremePool.m            # EDIT CONTINGENT ON GATE DECISION (a)
└── optimalExtremePoolDriver.m   # READ ONLY

src/base/solvers/                # READ ONLY — used through its interface; NOT modified
test/verifiedTests/analysis/testTopology/
└── testGreedyExtremeRayBasis.m  # EXTEND — one test file per function (III-Naming)
```

**Structure Decision**: unchanged layout. The feature edits existing code in an existing
correctly-placed domain folder, so Principle IX's "new code in a new subfolder" rule — which
governs new modules — does not apply.

## Phase 0 — Research

See [research.md](./research.md). Seven questions, each with a procedure and an explicitly
empty result slot. **R1 (the paired harness) is sequenced first** because every other
measurement runs through it. **R2 is a hypothesis with a decision rule fixed in advance**,
including what to record if it is refuted.

## Phase 1 — Design & Contracts

See [data-model.md](./data-model.md) for the paired-comparison record, the tuned parameter
sets as data, and the sampling-versus-structural classification; and
[contracts/greedyExtremeRayBasis.status-additions.md](./contracts/greedyExtremeRayBasis.status-additions.md)
for the additive status fields. [quickstart.md](./quickstart.md) is the reproduction guide.

The design is deliberately independent of which approach wins: the paired record, the
status additions and the classification are identical whether A2, A3 or A1 is adopted, so
Phase 1 can be reviewed before Phase 0 selects the remedy.

## Complexity Tracking

> Editing `findExtremePool.m` was approved at the gate as option (a1) and is recorded
> below as a justified scope extension under Principle V.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Editing `findExtremePool.m`, outside the single function the spec names | The LP whose vertex selection is the entire problem is built there; tuned settings must reach it to influence vertex SELECTION rather than repair a ray after the fact | (a3), keeping everything in `greedyExtremeRayBasis` and re-solving afterwards, cannot influence which vertex is returned and so fails on the merits. (a2), tuning inside `findExtremePool` unconditionally, would change results for two other callers unasked. (a1) is additive and default-preserving. |
