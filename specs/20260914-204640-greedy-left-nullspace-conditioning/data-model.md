# Phase 1 Data Model: Status Object, Terminal Outcomes, Fixtures

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-09-14

This design is **remedy-independent**: it is identical whichever way R1 resolves, so it
can be reviewed before Phase 0's measurements select a remedy.

## 1. Terminal outcomes

Exactly five, mutually exclusive and exhaustive (FR-009). Every call ends in exactly
one, and a caller must be able to tell which from the status alone.

| `status.outcome` | Meaning | `Zpos` | `Z` | Raises? |
|---|---|---|---|---|
| `'complete'` | A full basis was found and every row meets the accuracy target | full basis, `>= 0` | linear basis | no |
| `'incomplete'` | Search ended before a full basis; every returned row still meets the target | accepted rows **only**, no zero padding | linear basis | no |
| `'emptyNullspace'` | The operative matrix has full row rank; there is no left nullspace | `[]` (0 rows) | `[]` | no |
| `'badlyScaled'` | Regime B: input too badly scaled for a usable basis to exist | `[]` | `[]` | no |
| `'missingField'` | A required input field is absent and was not computed | `[]` | `[]` | no |

Two distinctions the design must preserve, because collapsing either re-creates a
silent-wrongness path:

- `'emptyNullspace'` vs `'badlyScaled'` — both return empty, and they mean opposite
  things. "There is correctly nothing here" must never be confused with "I refuse to
  answer".
- `'incomplete'` because time ran out vs `'incomplete'` because candidates kept failing
  the accuracy target (FR-003a, SC-014). Both are incomplete; only the second is evidence
  that the residual floor sits above the target. `status.terminationReason` carries this.

## 2. `status` — the third output

Populated on **every** call, not only in Regime B (FR-009), and complete irrespective of
console verbosity (FR-017).

### 2.1 Always present

| Field | Type | Meaning |
|---|---|---|
| `outcome` | char | one of the five above |
| `terminationReason` | char | `'basisComplete'` \| `'timeBudget'` \| `'accuracyRejection'` \| `'notAttempted'` |
| `regime` | char | `'wellScaled'` \| `'badlyScaled'` \| `'notAssessed'` |
| `nullspaceSide` | char | `'left'` \| `'right'` — which nullspace was requested (FR-020) |
| `operativeMatrixSize` | 1x2 double | size of the matrix actually classified and operated on, after consistency restriction and transposition (FR-005) |
| `message` | char | one human-readable sentence; the console text and this field say the same thing |

### 2.2 Accuracy and verification (FR-003, FR-016)

| Field | Type | Meaning |
|---|---|---|
| `accuracyTarget` | double | the target derived per R3, as applied on this call |
| `residualAbsolute` | double | `norm(Zpos*Sop, inf)` on the **returned** object |
| `residualScaled` | double | the same divided by `norm(Zpos)*norm(Sop)` — reported alongside, never instead (FR-016) |
| `nonNegative` | logical | asserted on the returned object, not assumed |
| `impliedNullity` | double | `size(Zpos,1)` |
| `independentRank` | double | rank computed independently of the basis |
| `elapsedTime` | double | seconds for this call only |

`residualAbsolute` and `residualScaled` are both required. The seed's evidence shows why:
`1.418e-07` absolute reads as small; scaled it is `2.218e-09`, and it was still fatal.
Neither number alone tells the story.

### 2.3 Basis completeness (FR-010)

| Field | Type | Meaning |
|---|---|---|
| `raysFound` | double | rows actually accepted — equals `size(Zpos,1)` |
| `raysExpected` | double | target count |
| `raysExpectedIsEstimate` | logical | **always true** — see below |
| `raysRejectedForAccuracy` | double | candidates dropped under FR-003a |
| `raysRejectedForDependence` | double | candidates dropped as linearly dependent |

`raysExpectedIsEstimate` exists because `raysExpected` is derived from a rank
computation on the operative matrix — the same class of computation whose reliability
under poor conditioning this feature exists to question (FR-010). It is a target, not
ground truth, and the field forbids a consumer from treating it as such.

### 2.4 Regime B diagnosis (FR-008) — present when `outcome` is `'badlyScaled'`

| Field | Type | Meaning |
|---|---|---|
| `scalingQuantity` | char | *which* quantity is badly scaled |
| `scalingValue` | double | its measured value — "by how much" |
| `scalingBoundary` | double | the R4 boundary it violated |
| `scalingBoundaryBasis` | char | what the boundary is grounded in, so a reader can re-derive it |
| `recommendedRepair` | char | the indicated repair to `model.S` |

These four are what make the diagnosis actionable rather than merely negative: what is
wrong, by how much, against what threshold, and what to do.

### 2.5 Missing input (FR-013) — present when `outcome` is `'missingField'`

| Field | Type | Meaning |
|---|---|---|
| `missingFieldName` | char | the absent field |
| `howToObtain` | char | how to compute it |

This path is live: `optimalExtremePoolDriver.m:121` calls with no `param` at all.

## 3. Regime classification

| Property | Value |
|---|---|
| Applied to | the **operative** matrix — after consistency restriction, after transposition (FR-005) |
| Grounding | chosen and justified in R4; recorded in `scalingBoundaryBasis` |
| Timing | before any ray is computed, so Regime B costs no LP solves |
| Outputs | `status.regime`, and on Regime B the §2.4 block |

Classifying the operative matrix rather than `model.S` as supplied matters: in
right-nullspace mode the operative matrix is the transpose, and under consistency
restriction it is a submatrix. Classifying the wrong matrix would diagnose a different
problem from the one being solved.

## 4. Fixture set

Detailed construction is R6. Shape required here:

| Fixture | Property | Exercises |
|---|---|---|
| `F1` square, exact | non-negative left nullspace known by construction | FR-001, FR-004, SC-001 |
| `F2` `m != n` | as F1, non-square | SC-001 |
| `F3` empty left nullspace | full row rank | `'emptyNullspace'`, SC-001 |
| `F4` genome-scale, well scaled, CI-available | no submodule dependency | FR-001, SC-002, SC-003 |
| `F5` deliberately badly scaled | derived from F4/F1 by a known scaling factor | FR-007, FR-008, SC-004 |
| `F6` boundary pair | either side of the R4 crossover | FR-006, FR-019 |
| `F7` short time budget | forces early termination | FR-010, SC-006 |
| `F8` model lacking the consistency field | called with no `param` | FR-013, SC-015 |
| `F9` right-nullspace mode | any of the above, transposed request | FR-020, SC-013 |
| `F10` `iDopaNeuroC` | submodule-resident; reproducibility check only, not CI | SC-005 |

F1–F3 are constructed in the test rather than committed as files: a fixture whose
expected answer is known by construction is more trustworthy than a stored one, and it
carries no floating-point error of its own.
