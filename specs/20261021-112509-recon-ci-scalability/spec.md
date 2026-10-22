# Feature Specification: Runtime and memory scalability of the functions behind the ReconXKG CI feasibility pipeline

**Feature Branch**: `20261021-112509-recon-ci-scalability`

**Created**: 2026-10-21

**Status**: Draft

**Input**: User description: "The ReconXKG CI (GitLab, BlackNight runner) ran the feasible-model extraction for 21 130 s and the full job then hit its 24 h limit. The Recon4 models are about three times the size Recon3D was when these COBRA functions were written. Enhance the COBRA functions the CI calls so they scale in runtime and memory, with identical results. Every function touched must first have a test covering all its lines (exceptions per the constitution), written without touching the function; the test is then run unchanged after the enhancement."

## Why this feature exists

The CI pipeline calls, per reconstruction variant (Source, VMH, MNX), `removeTrivialStoichiometry`,
`checkDuplicateRxn` (methods `S` and `FR`), `findSExRxnInd`, `findFluxConsistentSubset`
(`null_fastcc`), `findMassLeaksAndSiphons` (`dc`), `findStoichConsistentSubset`, then repeats
`findStoichConsistentSubset`, `findMassLeaksAndSiphons`, `findFluxConsistentSubset` and adds
`maxCardinalityConservationVector` in its feasibility re-check. `removeRxns` and
`removeMetabolites` run between stages.

Measured on a stored Recon4 VMH model (30 665 metabolites x 38 841 reactions, 177 752 non-zeros),
unmodified toolbox at commit `35918b372`, one stage per process, 24 GB memory cap
(`specs/20261021-112509-recon-ci-scalability/research.md` holds the full table and the commands):

- `checkDuplicateRxn` method `S`: 8.4 s, 1.0 GB peak.
- `checkDuplicateRxn` method `FR`: killed by the 24 GB cap (no result). The method builds a dense
  square matrix from the number of reactions (`diag`) and loops over all reactions comparing a
  full-length logical vector each time.

Other stages are recorded in `research.md` as they are measured; this spec fixes the method
(measure, test, optimise, re-run) and the selection rule, not the list of functions, which is
confirmed from the measurements.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - The CI extraction completes on the biggest reconstructions (Priority: P1)

A maintainer of a large reconstruction runs the feasible-model extraction on a model several times
larger than Recon3D and it finishes within the CI time limit on the CI runner's memory, instead
of being killed or timing out.

**Why this priority**: today the job does not finish, so no CI report is produced at all.

**Independent Test**: run the per-stage benchmark (research.md) on the stored large Recon4 models
before and after; every stage that previously failed or dominated the time now completes, and the
total is lower.

**Acceptance Scenarios**:

1. **Given** a model with about 30 000 metabolites and 39 000 reactions, **When** any enhanced
   function is run under a 24 GB memory cap, **Then** it completes (no out-of-memory kill).
2. **Given** the same model and the same solver, **When** the extraction stages are run before and
   after the enhancement, **Then** the total wall-clock time is lower and the per-function times
   and peak memory are recorded side by side.

---

### User Story 2 - Results are identical (Priority: P1)

A user of any enhanced function gets exactly the results they got before.

**Why this priority**: this is a performance change; scientific meaning comes first
(Constitution I and IV).

**Independent Test**: the test written for the function before it was touched passes unchanged
after the enhancement; and a before/after comparison on real models shows identical outputs.

**Acceptance Scenarios**:

1. **Given** a function with no test, **When** it is selected for enhancement, **Then** a test
   per III-Naming exists and passes against the UNMODIFIED function before any edit.
2. **Given** that test, **When** the function is enhanced, **Then** the same test file, byte for
   byte, passes with no edit.
3. **Given** the stored Source, VMH and MNX models (and the smaller 2026-10-09 ones), **When**
   outputs are compared before and after, **Then** index sets and boolean vectors are identical,
   and floating-point outputs agree within the tolerance stated in the test header.

---

### User Story 3 - Each touched function is fully tested first (Priority: P1)

A reviewer can see, for every function changed, a test that reaches all its lines.

**Independent Test**: coverage of each touched function by its own test, measured with the
repository's coverage plugin, is 100 %, or every uncovered line is listed with a reason in the
test header (III-Coverage).

**Acceptance Scenarios**:

1. **Given** a function selected for enhancement, **When** its test is written, **Then** the file
   is named `test<FunctionName>.m` (III-Naming), opens with `prepareTest(...)` (III-Coverage),
   declares its tier, uses the smallest model that exercises every branch, and leaves no large
   artifacts.
2. **Given** a defect found while writing a test, **When** it is recorded, **Then** it follows
   III-Defects (documented in the header, never asserted, never fixed in this feature).

---

### User Story 4 - Same solver path, same diagnostics (Priority: P2)

A user who relies on warnings, printed output or solver choice sees the same behaviour.

**Independent Test**: the tests assert the warnings and error identifiers the function raises
today; none is removed.

**Acceptance Scenarios**:

1. **Given** an input that makes a function warn (for example a reaction with more than one
   replicate), **When** the enhanced function runs, **Then** the same warning is raised the same
   number of times for the same reactions.
2. **Given** any enhanced function that calls a solver, **When** it runs, **Then** it goes through
   the same `solveCobra*`/`buildOptProblemFromModel` layer with the same problems (same
   objective, constraints and tolerances); no algorithm or solver is substituted (Constitution IV).

---

### Edge Cases

- Empty model, model with no duplicates, a duplicate group of three or more reactions, reversible
  and irreversible duplicates, duplicates differing only by protons, zero columns and zero rows.
- Models whose `S` is already sparse, and models given as full matrices.
- Models with `lb`/`ub` columns when `boundsFlag` is set.
- Solver reports infeasible or unknown consistency (kept exactly as today).
- Output ordering: where today's output order is by first appearance, it stays so.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Before any source edit, each function selected for enhancement MUST have a
  `test<FunctionName>.m` (III-Naming, III-Coverage) that passes on the unmodified function and
  covers 100 % of its lines, except lines whose exemption is documented in the test header.
- **FR-002**: The enhanced function MUST pass that same test file, unedited, afterwards.
- **FR-003**: The enhanced function MUST return identical results for identical inputs: same
  outputs, same output order, same dimensions and types (sparse stays sparse), same warnings and
  error identifiers. Floating-point values may differ only within the tolerance stated and
  justified in the test header.
- **FR-004**: The enhanced function MUST NOT change its signature, optional arguments, defaults,
  or documented behaviour (Constitution II).
- **FR-005**: The enhancement MUST NOT change the solver path or algorithm: the same LP/MILP
  problems are built and solved (Constitution IV). Only data structures, vectorisation, repeated
  work and allocation may change.
- **FR-006**: Peak memory for a model of about 30 000 x 39 000 MUST stay below the 24 GB cap used in the
  benchmark; no allocation of a dense array whose size is the number of reactions (or metabolites)
  squared.
- **FR-007**: Runtime for each enhanced function MUST grow no faster than linear in the number of
  non-zeros plus the number of reactions, excluding time inside the solver.
- **FR-008**: Runtime and peak memory of every enhanced function MUST be measured before and after
  with the same command, model, solver version and machine, and recorded in `research.md`.
- **FR-009**: Only functions that the baseline shows to be a material share of runtime or memory
  in the CI path MAY be changed (selection rule in plan.md); functions outside the CI path are
  untouched.
- **FR-010**: Files under `external/`, `deprecated/`, `binary/` MUST NOT be edited.
- **FR-011**: The implementation receipt MUST be written (Implementation Receipt Ledger).

### Key Entities

- **Model**: a COBRA model structure; fields read or written by the functions in scope are listed
  per function in the Existing Contract.
- **Stage benchmark record**: stage, toolbox commit, seconds, peak resident memory (GB), model
  size, status.

## Existing Contract *(characterization mode)*

- **Function(s) under test**: confirmed after baseline; candidates are
  `src/reconstruction/modelGeneration/checkDuplicateRxn.m`,
  `src/reconstruction/refinement/removeTrivialStoichiometry.m`,
  `src/reconstruction/refinement/removeRxns.m`,
  `src/reconstruction/modelGeneration/massBalance/findSExRxnInd.m`,
  `src/reconstruction/modelGeneration/fluxConsistency/findFluxConsistentSubset.m`,
  `src/reconstruction/modelGeneration/stoichConsistency/findMassLeaksAndSiphons.m`,
  `src/reconstruction/modelGeneration/stoichConsistency/findStoichConsistentSubset.m`,
  `src/reconstruction/modelGeneration/stoichConsistency/maxCardinalityConservationVector.m`.
- **Current inputs / arities, outputs, invariants**: documented per function in `research.md`
  from the current source and pinned by the tests.
- **Coverage gap**: none of the candidates has a `test<FunctionName>.m`; they are exercised only
  indirectly through tutorial-derived and broader tests (a repository search for each name finds
  2 to 16 files, none named for the function).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On the stored 30 665 x 38 841 Recon4 VMH model, every stage of the extraction
  (excluding solver time that is unchanged) completes under the 24 GB cap; the method-`FR`
  duplicate check, which is killed today, completes.
- **SC-002**: For each enhanced function, peak memory and wall-clock time on that model are lower
  than at baseline, or the function is reported as "measured, not worth changing".
- **SC-003**: 100 % of the tests written for touched functions pass on the unmodified source and,
  unedited, on the enhanced source (file hashes equal).
- **SC-004**: Before/after outputs on the stored Source, VMH and MNX models are identical for
  discrete outputs (0 differing elements) and within the stated tolerance for numeric outputs.
- **SC-005**: The ReconXKG CI job for the three variants finishes within its 24 h limit (verified
  by the maintainer on the CI runner; locally by the per-stage benchmark).

## Assumptions

- The solver is Gurobi (installed 11.0.3 locally, 12.0 on the CI runner); solver time is not
  changed by this feature.
- The stored models under `models/` in the ReconXKG repository are representative of CI input.
- The ReconXKG repository's own functions (`extractFeasibleModel`, `checkFeasibilityConditions`)
  are out of scope for this feature; they are discussed in `research.md` only.
- CI clones the upstream `opencobra/cobratoolbox` `develop`; the change reaches CI only after it
  is merged there. This feature produces commits on the maintainer's fork.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / SC-001, SC-002 | benchmark in research.md (`runChain.sh`) | all enhanced functions |
| US2 / FR-001..003 | `test<FunctionName>.m` per function (see tasks.md) | each enhanced function |
| US3 / FR-001 | `test<FunctionName>.m` header coverage line | each enhanced function |
| US4 / FR-005 | warnings asserted in each test | each enhanced function |
