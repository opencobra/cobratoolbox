# Contract Addition: Coverage Reporting on `greedyExtremeRayBasis`

**Feature**: [../spec.md](../spec.md) | **Date**: 2026-09-15

**Additive only.** The signature `[Zpos, Z, status] = greedyExtremeRayBasis(model, param)`
is unchanged, and every field the parent feature defined keeps its meaning. A caller
written against the parent contract continues to work untouched.

## New status fields

| Field | Type | Meaning |
|---|---|---|
| `shortfallKind` | char | `'none'`, `'sampling'`, `'structural'` or `'notAssessed'` |
| `attainableDimension` | double | dimension of `span(K)`; equals `raysExpected` under stoichiometric consistency, smaller otherwise |
| `attainableDimensionAssessed` | logical | whether that was determined or assumed |
| `tunedSolverSettingsApplied` | logical | whether a tuned set existed for the active solver |
| `tunedSolverName` | char | which solver the applied set targets, empty if none |

`attainableDimension` exists because `raysExpected` is derived from a rank computation and
is only the right target when the input is consistent. Reporting a shortfall against a
target that was never reachable is the FR-006 defect.

`tunedSolverSettingsApplied` exists so a user on an untuned solver is never left believing
they received tuning they did not get (FR-023).

## New optional parameters

| Parameter | Default | Meaning |
|---|---|---|
| `param.compareSolvers` | `{}` (off) | solvers to compare at each greedy state; when non-empty the paired record is produced |
| `param.solverSettings` | unset | override the built-in tuned set, for the measurement campaign |

**`param.compareSolvers` empty is the default and MUST be inert**: with it off, results are
identical to the same call before this feature (SC-011). Measurement apparatus that
perturbs what it measures is worthless, so this is asserted by test rather than assumed.

## Invariants carried forward unchanged

1. Non-negativity of `Zpos`, asserted on the returned object.
2. Every returned row meets the derived accuracy target; a failing candidate is dropped.
3. No all-zero placeholder row; `raysFound == size(Zpos, 1)`.
4. Five terminal outcomes, mutually exclusive, populated on every call.
5. Regime-B withholds both bases and returns gracefully.
6. Both residual forms reported together.
7. The same guarantees in both nullspace modes.

**This feature may not relax any of them to obtain coverage.** Trading accuracy for
coverage is the failure mode the spec exists to prevent, which is why the status reports
both on every call.
