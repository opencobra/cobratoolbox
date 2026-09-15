# Phase 1 Data Model: Paired Record, Tuned Sets, Shortfall Classification

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-09-15

Remedy-independent: identical whichever approach is adopted, so it can be reviewed
before Phase 0 selects the remedy.

## 1. The paired comparison record

One row per (greedy state, solver). The state is shared across the row group, which is
what makes the comparison matched.

### 1.1 Shared per comparison point

| Field | Type | Meaning |
|---|---|---|
| `pointIndex` | double | sequence number of this comparison point |
| `raysAccepted` | double | `k`, rays in the partial basis at this point |
| `objectiveHash` | char | digest of the drawn objective vector, so a reader can confirm every solver in the group got the SAME vector |
| `supportMaskCount` | double | metabolites already carrying support |

`objectiveHash` exists to make the pairing auditable. Without it the claim "the same
objective was used" is an assertion; with it, it is checkable.

### 1.2 Per solver at that point

| Field | Type | Meaning |
|---|---|---|
| `solver` | char | solver name |
| `residualAbsolute` | double | `norm(Sop'*x, inf)` for the returned ray |
| `residualScaled` | double | the same, scaled |
| `meetsTarget` | logical | would the ray be accepted at the derived accuracy target |
| `independentOfBasis` | logical | does it add a new direction to the current `Zpos` |
| `basisReturned` | logical | did the solver return `vbasis`/`cbasis` — the vertex-vs-interior discriminator (R2) |
| `atBoundCount` | double | components sitting exactly at a bound; a second, solver-independent vertex indicator |
| `solveTime` | double | seconds |
| `stat` / `origStat` | double / char | solver status, so a non-optimal solve is never mistaken for a tolerance effect |

**`meetsTarget` and `independentOfBasis` together are the point of the whole exercise.**
They separate "this solver is more accurate" from "this solver finds more diverse
vertices", which is the question the coverage/accuracy split turns on and which whole-run
figures cannot answer.

## 2. Tuned parameter sets, as data

Held as data rather than scattered through control flow, so they can be listed, recorded
and audited against Principle IV.

| Field | Type | Meaning |
|---|---|---|
| `solver` | char | which solver this set applies to |
| `settings` | struct | the name/value pairs passed through `solveCobraLP` |
| `rationale` | struct | per setting, the default/profile mismatch it corrects |
| `verifiedObservable` | struct | per setting, the observable proving it took effect (FR-022) |

Two rules the shape enforces:

- **Every setting carries its rationale.** A tuned value without a recorded mismatch is
  indistinguishable from a guess, which Principle IV forbids.
- **Every setting carries its verification.** A setting whose effect could not be observed
  is recorded as unverified rather than silently retained (R4).

No tuned set exists for a solver not covered; that is reported, not hidden (FR-023).

## 3. Shortfall classification

| Value | Meaning | Right response |
|---|---|---|
| `'none'` | coverage complete | — |
| `'sampling'` | directions reachable but not found; `ker(N')` holds a strictly positive vector | tuning, tie-breaking, targeted search |
| `'structural'` | part of the nullspace unreachable with non-negative weights; the input is stoichiometrically inconsistent | report the ATTAINABLE dimension, not the nullity (FR-006); no search can fix it |
| `'notAssessed'` | the classifying check was not run | say so rather than imply either |

Conflating `'sampling'` and `'structural'` is the error the parent feature made and had to
correct. They have opposite remedies: one is worth more search, the other is worth none.

## 4. Status additions

Additive only — the parent's five terminal outcomes and every existing field are
unchanged. See
[contracts/greedyExtremeRayBasis.status-additions.md](./contracts/greedyExtremeRayBasis.status-additions.md).

## 5. Fixtures

| Fixture | Property | Exercises |
|---|---|---|
| `G1` | stoichiometrically inconsistent, attainable dimension known exactly by construction | FR-005, FR-006, `'structural'` |
| `G2` | coverage-incomplete but reachable, CI-available if one exists (R7) | FR-001, `'sampling'` |
| `G3` | `iDopaNeuroC` — the known stalling case; submodule-resident, documented check only | SC-001 |
| F1, F2, F2b, F3 | the parent's exact fixtures | SC-004 no regression |

`G1` must be constructed rather than found, so its attainable dimension is known
independently of the routine being tested — the same discipline as the parent's exact
fixtures.
