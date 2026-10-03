# Feature Specification: Greedy Extreme-Ray Basis Stall on Recon3D

**Feature Branch**: `20261003-132730-greedy-recon3d-stall`

**Created**: 2026-10-03

**Status**: Draft

**Input**: Follow-up to features `20260914-204640-greedy-left-nullspace-conditioning` and
`20260915-082551-extreme-ray-coverage` (both merged into `develop`). User report:
`greedyExtremeRayBasis` "seems to be stalling or slow" on
`~/drive/sbgCloud/projects/variationalKinetics/data/Recon3T/Recon3DModel_301_xomics_input_VK_withL.mat`;
and: is the `model.L` shipped with that model a basis for the left nullspace of
`model.S(:,model.SConsistentRxnBool)`?

**Function under change**: `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m`
(and, only as far as Principle II allows, its helper
`src/analysis/topology/extremeRays/optimalRays/findExtremePool.m`).

---

## Problem Statement

On Recon3D the routine does not finish. The operative matrix
`N = S(:,SConsistentRxnBool)` is 5824 x 8748, rank 5573, so the left nullity is **251**.
Its spectrum has a clean gap (`sigma_r = 8.9e-4`, `sigma_{r+1} = 7.8e-15`,
`sigma_1 = 136.6`), so the matrix is **well scaled**: this is not the Regime-B case the
parent feature diagnoses.

### Measured baseline (pre-feature diagnosis, 2026-10-03)

One call with gurobi, `internalStoichiometriMatrixLeftNullspace = 1`, `maxTime = 180 s`:

| Quantity | Value |
|---|---|
| rays found / expected | **237 / 251**, outcome `incomplete`, reason `timeBudget` |
| candidates rejected for accuracy | **884** (against 238 accepted) |
| candidates rejected for dependence | 1 |
| targeted objectives used | **0** |
| restarts | 0 |
| regime | `notAssessed` (spectrum skipped) |
| accuracy target | 3.03e-14 (fallback), not derived |
| shortfall reported | **`structural`**, attainable dimension 237 |

### Root causes (measured, not assumed)

1. **Truncation manufactures accuracy failures.** The LP helper zeroes every ray entry
   below `10*feasTol` (1e-5 under default parameters). Once the objective is zeroed on
   already-covered metabolites, the solver returns large-support rays with many entries
   below that threshold (in replay a median 196 such entries, median smallest entry
   5.5e-6). The **untruncated** ray has residual <= 3.2e-16 and would pass the target.
   The **truncated** ray has residual ~1.6e-4 and is rejected. In replay **20 of 20**
   such candidates were rejected for this reason alone. The solver is not the cause.
2. **Accuracy rejections never trigger the stall remedy.** A candidate rejected for
   accuracy does not count as a failed attempt. So a run of accuracy rejections never
   switches off coverage-zeroing and never invokes the targeted objective introduced by
   the predecessor feature (`nTargetedObjectives = 0`). The search repeats the same
   failing objective family until the time budget expires. That loop is the observed
   stall. In replay, objectives aimed at the uncovered metabolites returned **exact**
   rays (residual 0) **20 of 20** times.
3. **The spectrum is skipped by a hair.** `numel(N) = 5.09e7` just exceeds the
   5e7-element ceiling for the dense spectrum. So the accuracy target falls back to
   `eps*normest(N) = 3.03e-14`, about 13x stricter than the derived target
   (~3.9e-13), and the regime is not assessed. The dense spectrum of this matrix was
   computed without difficulty during diagnosis.
4. **The structural/sampling verdict is wrong.** The attainable-dimension check
   maximises `sum(x)` over `{N'x = 0, 0 <= x <= 1}`. That does **not** guarantee maximal
   support: it excluded 19 metabolites and reported 237. A correct maximal-support
   formulation reaches all 5824 metabolites and gives an attainable dimension of
   **251 = the full nullity**. The shortfall is therefore `sampling`, and the
   `structural` verdict tells the caller that no further search can help, which is
   false.

### Is the shipped `model.L` a left-nullspace basis? (measured answer, recorded here)

`model.L` is 251 x 5824, non-negative, has no zero rows, and has rank 251 = the nullity,
so **dimensionally and in sign it is a non-negative basis**. Its accuracy, however:

| Measure on `L` against `N = S(:,SConsistentRxnBool)` | Value |
|---|---|
| `max |L*N|` | 3.2e-9 |
| per-row residual: median / 90th percentile | 1.8e-13 / 3.2e-11 |
| rows with residual > 1e-12 / > 1e-10 | 76 / 12 |
| largest distance of a row from `ker(N')` | 1.2e-8 (11 rows > 1e-10) |
| `rank([Zpos; L])` with an exact `Zpos` of 237 rays (LUSOL) | **256 > 251** |

So `L` is a non-negative left-nullspace basis to roughly **1e-8** accuracy. It does
**not** meet the accuracy contract the conditioning feature requires (a target of order
1e-13 for this matrix). Some of its rows lie measurably outside the exact nullspace,
enough that a matrix augmented with them shows extra numerical rank.

## Clarifications

### Session 2026-10-03

- Q: What is the reference call and input? → A (user): the VK model file **as-is**,
  `~/drive/sbgCloud/projects/variationalKinetics/data/Recon3T/Recon3DModel_301_xomics_input_VK_withL.mat`
  (variable `model`, no preprocessing), called exactly as the caller does:

  ```matlab
  paramGreedyExtremeRayBasis.internalStoichiometriMatrixLeftNullspace=1;
  paramGreedyExtremeRayBasis.solver='gurobi';
  [L, Llin] = greedyExtremeRayBasis(model,paramGreedyExtremeRayBasis);
  model.L = L;
  ```

  Note this sets **no** `maxTime`, so the defaults apply (`maxTime = maxNewBasisTime =
  10000 s`): on the baseline the call spins at 237/251 for ~2.8 h before returning.
  That, not a crash, is the reported "stall".
- Q: Is SC-001's 10-minute bound on the development workstation right? → A (user): yes.
- Q: How does CI get a fixture? → A (user): use a different model, the small E. coli
  model in the COBRA.models submodule (`test/models/mat/ecoli_core_model.mat`). The
  Recon3D VK file is loaded with `load(...)` for feature development (see Assumptions).
- Q: Is the in-repo Recon3D model equivalent to the VK model (fixture assumption)? →
  A (user): yes in intent. **Measured, however**: `test/models/mat/Recon3DModel_301_xomics_input.mat`
  is a corrupt download (an HTML page; MATLAB cannot load it), and
  `test/models/mat/Recon3DModel_301.mat` differs (5835 x 10600, no `SConsistentRxnBool`;
  its mets are a superset of the VK model's 5824). So no in-repo file currently
  reproduces the reference operative matrix; the reference fixture is the VK file above.
  The CI fixture is therefore a different model (next answer).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Complete accurate basis on Recon3D (Priority: P1)

A modeller computes the non-negative moiety (left-nullspace) basis of the internal
Recon3D stoichiometric matrix with the default solver. They get all 251 rays, each
meeting the accuracy target, in bounded time, instead of a timeout at 237.

**Why this priority**: This is the reported failure. Downstream variational-kinetics work
needs this basis.

**Independent Test**: Run the reference call (Clarifications) on the VK model file as-is,
with a fixed seed. Check `outcome == 'complete'`,
`raysFound == 251`, every row's residual within the acceptance target, and the elapsed
time within SC-001.

**Acceptance Scenarios**:

1. **Given** the Recon3D internal matrix and gurobi, **When** the routine is called with
   default parameters, **Then** it returns `outcome = 'complete'` with 251 non-negative
   rays, all within the acceptance target.
2. **Given** a stall in which candidates keep failing accuracy, **When** the stall
   persists for the configured number of attempts, **Then** the routine escalates to its
   stall remedy (the targeted objective) exactly as it does for dependence failures, and
   the status records that it did.
3. **Given** a candidate whose untruncated form meets the target, **When** it is
   evaluated, **Then** it is not rejected because of post-solve entry truncation.

---

### User Story 2 - Truthful shortfall classification (Priority: P2)

A caller whose basis is incomplete reads `shortfallKind` to decide whether to search
longer or repair the model. The verdict must be correct.

**Why this priority**: A false `structural` verdict sends the caller in the wrong
direction (repairing a model that does not need it). It is a correctness defect in
reporting, independent of whether US1 lands.

**Independent Test**: On the Recon3D internal matrix with a deliberately short time
budget, the routine returns `shortfallKind = 'sampling'` and `attainableDimension = 251`.
On a known stoichiometrically inconsistent fixture, it still returns `structural` with
the correct smaller dimension.

**Acceptance Scenarios**:

1. **Given** an incomplete run on a matrix whose non-negative cone spans the whole
   nullspace, **When** the shortfall is classified, **Then** it is `sampling` and
   `attainableDimension` equals the nullity.
2. **Given** a matrix in which some directions are unreachable with non-negative weights,
   **When** classified, **Then** it is `structural` with the true attainable dimension.

---

### User Story 3 - Derived accuracy target on large matrices (Priority: P2)

On a well-scaled genome-scale matrix just above the current size ceiling, the routine
derives its accuracy target and scaling regime from the spectrum rather than falling
back, provided the spectrum is affordable.

**Why this priority**: The fallback is about 13x stricter than needed and leaves the
regime unassessed. That raises rejection rates and hides the Regime-B diagnosis on
exactly the models where it matters most.

**Independent Test**: On the Recon3D internal matrix, `status.accuracyTargetDerived` is
true, `status.regime` is `'wellScaled'`, and the derivation cost is reported and within
SC-003.

**Acceptance Scenarios**:

1. **Given** the Recon3D internal matrix, **When** the routine is called, **Then** the
   target is derived and the regime assessed.
2. **Given** a matrix too large for the spectrum to be affordable, **When** called,
   **Then** the documented fallback still applies and is reported as such.

---

### User Story 4 - Validate a supplied basis (Priority: P3)

A modeller who already holds a basis (such as the `model.L` shipped with the
variational-kinetics model) can check it against the same accuracy contract and get the
same kind of verdict the routine applies to its own output: per-row residuals, the
target, the rows that fail, and whether it spans the nullspace.

**Why this priority**: It answers the user's question reproducibly. It is useful but
separable from the stall fix.

**Independent Test**: Applied to the shipped `model.L`, the check reports 251 rows, full
rank, non-negative, and identifies the rows failing the target (residual > target), in
agreement with the measurements in the Problem Statement.

**Acceptance Scenarios**:

1. **Given** a supplied non-negative basis and the operative matrix, **When** validated,
   **Then** the result states non-negativity, rank against nullity, per-row residuals
   against the derived target, and the list of failing rows.

---

### Edge Cases

- Rays that legitimately contain very small positive entries (large stoichiometric
  coefficients, e.g. lipid or polymer species): they must be neither destroyed by
  truncation nor accepted with negative noise.
- Solver noise producing tiny **negative** entries in an otherwise valid ray:
  non-negativity remains a hard requirement (FR-003 of the predecessor). The fix must
  not admit negative entries.
- Mixed failures (accuracy and dependence interleaved) must both count toward the stall
  remedy.
- A matrix with an empty nullspace, a badly-scaled matrix, and a missing
  `SConsistentRxnBool` keep their existing outcomes.
- A matrix exactly at, and just above, the spectrum size ceiling.
- `param.leftRight = 'right'`: every change applies identically (parent-feature rule).

## Requirements *(mandatory)*

### Functional Requirements

**Coverage and the stall**

- **FR-001**: The reference call (Clarifications) on the VK model file, with no
  `maxTime` set, MUST return a complete basis (251 rays) in which every row meets the
  acceptance target.
- **FR-002**: A candidate MUST NOT be rejected for accuracy as a consequence of the
  routine's own post-solve processing of the solver's output. The accuracy judgement
  MUST be made on the ray actually returned to the caller, and that returned ray MUST
  meet the target. Any cleaning of the solver output MUST NOT raise the residual above
  the target.
- **FR-003**: Non-negativity of every returned ray remains a hard requirement. No
  negative entry may be returned.
- **FR-004**: Accuracy rejections MUST count toward the stall-detection that triggers the
  predecessor feature's remedies (relaxing coverage-zeroing, targeted objective), so that
  a run of accuracy failures escalates exactly as a run of dependence failures does.
- **FR-005**: The accuracy target, its derivation and the clamp on `param.feasTol` MUST
  NOT be weakened (parent feature FR-002). Coverage is obtained by not discarding good
  rays, never by accepting worse ones.

**Accuracy target and regime**

- **FR-006**: The routine MUST derive the accuracy target and assess the scaling regime
  for the Recon3D internal matrix. The size ceiling for the spectrum MUST be set by the
  measured cost of the spectrum, not by an arbitrary element count, and the
  measurement MUST be recorded.
- **FR-007**: Where the spectrum is still unaffordable, the existing fallback and its
  `notAssessed` reporting MUST be preserved.

**Shortfall classification**

- **FR-008**: The attainable dimension MUST be computed by a formulation that provably
  attains maximal support of the non-negative cone. Its result on the Recon3D internal
  matrix MUST be 251.
- **FR-009**: The `structural` verdict MUST still be returned, with the true attainable
  dimension, on a fixture where part of the nullspace is unreachable with non-negative
  weights.

**Supplied-basis validation**

- **FR-010**: There MUST be a way to validate a caller-supplied basis against the same
  accuracy contract the routine applies to its own output. It reports non-negativity,
  rank versus nullity, per-row residual against the derived target, failing rows, and
  whether the basis spans the requested nullspace.

**Interface, compatibility and evidence**

- **FR-011**: The parent features' contracts MUST NOT be weakened: five terminal
  outcomes, trimmed basis, Regime-B diagnosis, derived target, tuned solver settings,
  and status fields are preserved. Any new status field is additive (Principle II).
- **FR-012**: The public behaviour of `findExtremePool` for its other callers
  (`optimalExtremePoolDriver`, and `testFindExtremePathway` via the extreme-pathway
  code) MUST be preserved. Any change in output is opt-in, or the change is confined to
  `greedyExtremeRayBasis`.
- **FR-013**: The predecessor features' recorded results MUST NOT regress: iDopaNeuroC
  105/105, plus the iAF1260 and ecoli_core outcomes in their measurement records, with
  accuracy and runtime reported alongside.
- **FR-014**: Each root cause (1)–(4) MUST be shown, by a measurement recorded in the
  feature's `measurements/`, to be resolved, with before and after counts (accuracy
  rejections, targeted objectives, rays found, elapsed time, target, regime, shortfall
  verdict).
- **FR-015**: The narrowest reproducibility check MUST be a test under
  `test/verifiedTests/analysis/testTopology/` that runs in bounded time on
  `ecoli_core_model.mat` from the COBRA.models submodule (Principle III). The Recon3D
  acceptance (SC-001..SC-004, SC-006) is a recorded local measurement on the VK file, not
  a CI assertion.
- **FR-016**: Numerical-integrity constraints: acceptance residual per row <=
  `status.acceptanceTarget`. The scaled residual is reported alongside the absolute
  one, never instead. Non-negativity is exact (min entry >= 0).

### Key Entities

- **Operative matrix**: `S` restricted to stoichiometrically consistent reactions (and
  transposed for the right nullspace). The object the basis is computed for.
- **Candidate ray**: the solver's vertex for one objective. It exists in raw form (as
  solved) and returned form (after any cleaning). Accuracy is judged on the returned
  form.
- **Status**: the existing outcome record, extended additively (e.g. with the count of
  accuracy rejections that triggered escalation, and the spectrum cost).
- **Supplied basis**: a caller-held non-negative matrix, such as `model.L`, to be
  judged against the operative matrix.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On the VK model file as-is, the reference call (Clarifications) returns
  **251 / 251** rays, all within the acceptance target, in **under 10 minutes** on the
  development workstation. (Baseline: 237 / 251 after 180 s, then no progress.)
- **SC-002**: The fraction of candidates rejected for accuracy on that run, defined as
  `raysRejectedForAccuracy / (raysRejectedForAccuracy + raysRejectedForDependence + raysFound)`,
  falls from the baseline **79 %** (884 / (884 + 1 + 237)) to **under 5 %**.
- **SC-003**: Deriving the spectrum for the reference operative matrix takes **under 15 s**
  on the development workstation, with `accuracyTargetDerived = true` and
  `regime = 'wellScaled'`. *(Re-derived during planning, 2026-10-03: the original "under
  10 % of total call time" fails narrowly at 5.3 s / 35.9 s = 15 %, only because the
  remedies made the search fast. See research.md R3.)*
- **SC-004**: On Recon3D the shortfall verdict for a deliberately truncated run is
  `sampling` with attainable dimension **251**. On an inconsistent fixture it remains
  `structural` with the correct dimension.
- **SC-005**: iDopaNeuroC still reaches **105 / 105** within its recorded accuracy, and
  `testGreedyExtremeRayBasis` and `testFindExtremePathway` pass unchanged in their
  existing assertions.
- **SC-006**: Validating the shipped `model.L` reproduces the Problem Statement
  measurements (251 rows, rank 251, non-negative, maximum residual 3.2e-9) and lists the
  rows that fail the derived target.

## Assumptions

- The reference fixture for SC-001..SC-004 and SC-006 is the VK model file loaded as-is
  and called with the reference call (Clarifications). Acceptance measurements are run
  on it locally and recorded in `measurements/`.
- The CI fixture is the small E. coli model from the COBRA.models submodule
  (`test/models/mat/ecoli_core_model.mat`, already loaded by `testGreedyExtremeRayBasis`).
  The Recon3D VK file is the **development and acceptance** fixture only: loaded locally
  with `load('~/drive/sbgCloud/projects/variationalKinetics/data/Recon3T/Recon3DModel_301_xomics_input_VK_withL.mat')`
  (`size(model.S) = 5824 x 10554`, `size(model.S(:,model.SConsistentRxnBool)) = 5824 x 8748`),
  with its results recorded in `measurements/`. It is not added to the repository.
- ecoli_core may be too small to exhibit the Recon3D failure naturally (large-support rays
  with sub-threshold entries). The plan MUST measure whether it does. If it does not, the
  CI test MUST still exercise each fixed mechanism directly on ecoli_core: an accuracy
  rejection counts toward escalation; the returned ray's own residual is what is judged;
  and the maximal-support attainable dimension agrees with the nullity on a consistent
  matrix and is smaller on an inconsistent one.
- gurobi is the default LP solver for this routine (predecessor feature). The mosek
  rejection added on `develop` (commit `a590dcca0`) stands.
- "Bounded, reasonable time" is SC-001's 10 minutes on the development workstation
  (confirmed by the user).
- The shipped `model.L` is an external artifact. This feature reports on it and does not
  modify it.
- The candidate remedies for root cause (1) (accept on the raw ray and clean
  conservatively; scale-aware truncation; truncation confined to the greedy path) are
  for the plan to choose by measurement, not for this spec.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001, FR-002, FR-003, SC-001, SC-002 | measurements/ record on the VK file (local); testGreedyExtremeRayBasis (ecoli_core mechanism case) | src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis |
| US1 / FR-004 | testGreedyExtremeRayBasis (accuracy-rejection escalation case) | src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis |
| US1 / FR-005, FR-016 | testGreedyExtremeRayBasis (residual and non-negativity assertions) | src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis |
| US2 / FR-008, FR-009, SC-004 | testGreedyExtremeRayBasis (shortfall classification cases) | src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis |
| US3 / FR-006, FR-007, SC-003 | testGreedyExtremeRayBasis (derived-target case) + measurements/ spectrum cost | src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis |
| US4 / FR-010, SC-006 | testCheckNullspaceBasis + measurements/ record on the VK file | src/analysis/topology/extremeRays/optimalRays/checkNullspaceBasis |
| FR-006, FR-007 (single-sourced target derivation) | testNullspaceAccuracyTarget | src/analysis/topology/extremeRays/optimalRays/nullspaceAccuracyTarget |
| FR-011, FR-012, SC-005 | testGreedyExtremeRayBasis, testFindExtremePathway (existing assertions) | greedyExtremeRayBasis, findExtremePool |
| FR-013, FR-014 | measurements/ before/after record | greedyExtremeRayBasis |
| FR-015 | testGreedyExtremeRayBasis | greedyExtremeRayBasis |
