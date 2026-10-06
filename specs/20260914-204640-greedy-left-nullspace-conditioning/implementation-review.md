# Implementation Review

**Feature**: Left-nullspace basis conditioning and bad-scaling diagnosis for `greedyExtremeRayBasis`
**Branch**: `20260914-204640-greedy-left-nullspace-conditioning` | **Date**: 2026-09-14
**Status**: Gate 2 passed 2026-09-14 — scope T001-T021 approved. **No source or test
file has been modified yet**: Principle VI requires an explicit `/speckit-implement`
invocation, which has not been given.

## Summary

`greedyExtremeRayBasis` returns a non-negative left-nullspace basis accurate to about
seven digits. Spliced into an augmented matrix, those rows close the rank gap: three
independent rank routines return three different integers, and `getNullSpace` then
hands back a "nullspace basis" with residual 14.1. The caller gets a confident,
well-formed, wrong answer with nothing raised anywhere.

The feature delivers two regimes — an accurate basis where the input permits one, and a
machine-readable refusal where it does not — with both governing numbers *derived and
measured* rather than chosen.

**The single most consequential thing in this packet**: reading the source produced a
hypothesis that contradicts the seed's stated cause, and it is testable in one
measurement. See "What reading the code changed" below.

## Embedded Core Commands Completed

| Command | Outcome |
|---|---|
| constitution | **checked**, not regenerated — v1.5.0 read in full; no principle change requested |
| specify | `spec.md` — 24 FRs, 15 SCs, 4 prioritised user stories |
| clarify | 3 questions asked and answered; integrated as Session 2026-09-14 |
| checklist | `checklists/numerical-integrity.md` — 46 items, 46/46 pass after Gate-1 revision |
| plan | `plan.md`, `research.md`, `data-model.md`, `quickstart.md`, `contracts/` |
| tasks | `tasks.md` — 47 tasks across 7 phases |
| analyze | 5 findings (1 HIGH, 2 MEDIUM, 2 LOW); 4 applied, 1 accepted as-is; 0 critical |

## What reading the code changed

The seed named the operative cause as the absolute `1e-6` **acceptance** test at
`greedyExtremeRayBasis.m:126`, and explicitly warned against re-diagnosing it as a
scaling problem. Reading `findExtremePool.m` — the LP worker the seed does not discuss —
surfaced a third possibility it did not consider:

```matlab
% findExtremePool.m:36-39
if ~exist('epsilon','var')                            % always true: epsilon is never an argument
    feasTol = getCobraSolverParams('LP','feasTol');   % 1e-6 by default
    epsilon = feasTol*10;                             % => 1e-5
end
% findExtremePool.m:66
x(abs(x)<epsilon)=0;    % zeroes every entry below 1e-5 AFTER the LP solved, unchecked
```

Two pieces of the seed's own evidence corroborate it, read a different way:

- the seed reports `L`'s entries "reach 1.252e-05" — the smallest surviving entries sit
  **just above the 1e-5 truncation floor**, the fingerprint of a hard threshold rather
  than of a solver tolerance;
- the 8.8e5 entry-magnitude ratio the seed set aside as "a symptom, not the cause" is
  what O(10) stoichiometry against a 1e-5 floor produces.

If this is right, the `1e-6` acceptance test is not the cause but a **filter** — it
admits exactly those rays where the truncation damage happened to land below `1e-6`.
Tightening it alone would then not improve attainable accuracy; it would reject more
rays, possibly all of them.

**This is a hypothesis, not a finding.** It is R1, sequenced first, with a decision rule
fixed in advance and an explicit instruction to record a refutation prominently. No
requirement in `spec.md` depends on either diagnosis being correct — the requirements
state the accuracy *outcome*, never its cause.

## Cross-Artifact Analysis Summary

- Requirement coverage **39/39 (100%)** after applying the analysis findings.
- Terminal outcomes and all 25 status field names consistent across `data-model.md` and
  `contracts/`. `spec.md` deliberately carries none of them, leaving `data-model.md` the
  single source (Principle X).
- **No over-promising anywhere**: no artifact asserts an attainable residual, a runtime,
  or which regime any named model falls into — all three forbidden by the seed's
  reporting discipline and the spec's Assumptions.
- Measurement-before-remedy is enforced by the dependency graph, not merely asserted:
  T008 selects the remedy, and T013/T014 are worded "the remedy selected by T008".
- Constitution: no violations. The Principle II break is approved with a migration path;
  III-Naming satisfied; IV's solver audit is R5/T006; V's scope question is routed here
  rather than assumed.

## Proposed Implementation Scope

**Tasks proposed**: T001–T046 plus T031a (47 total), in 7 phases.

**First independently testable slice (proposed MVP)**: **Phase 1 + Phase 2 + Phase 3
(US1)** — setup, the full measurement phase, and Regime-A accuracy. That delivers the
feature's core claim with its accuracy target derived and recorded.

> **An honest caveat about that MVP.** If T004 refutes the R1 hypothesis *and* T005 shows
> the LP floor sits above the derived target, US1 may be **unachievable**, and US2
> (Regime B) becomes the real deliverable. The spec anticipates this and calls it a
> legitimate, valuable outcome. This is exactly why the measurement phase blocks
> everything: it decides which slice is the MVP. Approving "US1 only" is therefore
> approving "measure, then deliver Regime A *if the measurement says it exists*".

**Files likely to change**

| File | Change | Note |
|---|---|---|
| `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m` | edit | the function `spec.md` names |
| `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m` | create | clean create; no test exists today |
| `specs/.../research.md` | fill in | empty Result slots -> measurements |
| `specs/.../measurements/` | create | probes, environment record, results, reproducibility check |
| `src/analysis/topology/extremeRays/optimalRays/findExtremePool.m` | **edit — NEEDS ITS OWN APPROVAL** | see below |

**Files that should NOT change**: the `varkin` repository (a different repository —
`createCyclicModel.m`, `driver_optimizeVKmodel_VK1to3m.m`); `getRankLUSOL` /
`getNullSpace` (measurement instruments); `optimalExtremePoolDriver.m`;
`testFindExtremePathway.m`; `papers/` (submodule); `external/`; `deprecated/`.

## The scope decision that needs its own answer

`findExtremePool.m` is **not** the file `spec.md` names, and it has two other callers.
If R1 confirms the truncation is the cause, that is where the fix belongs.

| Option | Blast radius | Trade-off |
|---|---|---|
| (a) Edit `findExtremePool.m` directly | `optimalExtremePoolDriver.m:119` and `testFindExtremePathway.m:75` change behaviour too | fixes it for every caller; silently changes a second public function's numerical output |
| **(b) recommended** — new parameter on `findExtremePool`, defaulting to today's behaviour, set by `greedyExtremeRayBasis` | additive only; other callers unaffected | fixes it where the spec requires, leaves the same latent defect for two other callers, which must then be recorded as a known follow-up |
| (c) Refine each ray inside `greedyExtremeRayBasis` after the fact | none outside the named function | strictly in scope, but repairs damage rather than avoiding it, and may not recover what truncation destroyed |

Every task touching `findExtremePool.m` is tagged **`[GATE2-SCOPE]`** in `tasks.md`, so
approving "all tasks" does **not** approve this. It needs a separate yes.

## Tests and Validation Expected

**Narrowest relevant test first**: `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m`
— `prepareTest('needsLP', true)`, fixed random seed (the greedy search draws random
objectives), justified tolerances sourced from the T009 derivation, no submodule
dependency.

Each of the five terminal outcomes has a fixture that **forces** it, and every guard is
tested against the failure it guards, not only against success (FR-019, SC-007). The
`iDopaNeuroC` regression runs as a **documented reproducibility check, not a CI test**,
because `papers/` is a git submodule — Principle III sanctions the substitute and
requires the reason stated.

## Blocking Issues

**None.** Analysis found 0 CRITICAL. The one HIGH (SC-010 untested) was fixed by adding
T031a before this packet was written.

## Acceptable Risks

1. **The remedy is not yet known.** By design — naming it now is the failure mode this
   feature exists to avoid. The risk is schedule, not correctness.
2. **US1 may prove unachievable** if the LP floor sits above the derived target. Spec'd
   as a legitimate outcome; it would mean Regime B is right for more models than expected.
3. **Option (b) leaves two other callers exposed** to the same latent truncation defect.
   Must be recorded as a known follow-up at Gate 3, not quietly dropped.
4. **The approved breaking change** alters results for every caller relying on the
   default, including out-of-repo `varkin`. Mitigated only by documentation (FR-015b),
   because you chose no opt-out.

## Human Approval

- Approved: **yes — Gate 2 passed 2026-09-14**
- Approved option: "Approve Phase 1-3 slice"
- Approved tasks/scope: **T001-T021** (Phase 1 Setup, Phase 2 Foundational measurement,
  Phase 3 User Story 1). Explicitly **not** approved in this slice: T022-T046 and T031a
  (User Stories 2, 3, 4 and the cross-cutting phase) — they return for a fresh decision.
- `findExtremePool.m` scope extension approved: **yes — option (b) only**. A new
  parameter on `findExtremePool` controlling the truncation, **defaulting to today's
  behaviour** so `optimalExtremePoolDriver.m:119` and `testFindExtremePathway.m:75` are
  bit-for-bit unaffected (Principle II). Option (a), editing the truncation directly for
  every caller, is **not** approved. T014 is unblocked on this basis and on no wider one.
- Known follow-up this creates: the two other `findExtremePool` callers keep the latent
  truncation defect. Must be reported at Gate 3, not quietly dropped.
- Required implementation invocation per constitution: `/speckit-implement`, **or** the
  agent-assign pipeline (`/speckit-agent-assign-assign` -> `-validate` -> `-execute`) run
  in series. A Gate-2 menu choice alone does **not** authorise edits (Principle VI).
- Date (UTC): 2026-09-14
