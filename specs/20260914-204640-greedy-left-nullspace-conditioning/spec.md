# Feature Specification: Left-Nullspace Basis Conditioning And Bad-Scaling Diagnosis For `greedyExtremeRayBasis`

**Feature Branch**: `20260914-204640-greedy-left-nullspace-conditioning`

**Created**: 2026-09-14

**Status**: Draft

**Input**: User description: see `feature-request.md` in this directory (the "Prompt"
section is the feature description; the remainder is measured provenance, constraints
and acceptance criteria, all binding on this specification).

**Function under change**: `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m`

---

## Problem Statement

`greedyExtremeRayBasis` returns a non-negative basis `Zpos` (called `L` by its
callers) for the left nullspace of a stoichiometric matrix. Callers splice that
basis into a larger matrix — for example the cyclic model `S_cyc = [N, -I; 0, L]` —
and then ask for that matrix's rank or nullspace.

A basis row is accepted today when its residual against the stoichiometric matrix
falls below an **absolute** tolerance of `1e-6`. Rows accepted at that tolerance are
mathematically in the left nullspace only to about seven digits. When such rows are
spliced into a larger matrix, the singular values that ought to sit at machine zero
instead smear across many orders of magnitude, the rank gap closes, and every
independent rank routine returns a different integer. A consumer that asks for the
nullspace of the augmented matrix then receives a confident, well-formed, **wrong**
answer, with no error raised anywhere.

Measured on `iDopaNeuroC` (see `feature-request.md` for full provenance):

| Quantity | Measured |
|---|---|
| residual of today's basis, absolute | 1.418e-07 |
| the same, scaled by the two matrix norms | 2.218e-09 |
| the same for an exact basis | ~1e-16 |
| passes the current `1e-6` guard? | yes, with 7x margin |
| rank of the augmented matrix, by structure | 1240 |
| ... by SVD at relative 1e-9 / 1e-12 / machine-epsilon | 1240 / 1255 / 1265 |
| ... by `getRankLUSOL` | 1261 |
| ... by `getNullSpace` | 1271 |
| residual of the nullspace basis `getNullSpace` then returns | **14.1** |

The unaugmented matrix is clean at all three tolerances (rank 1136, all routines
agreeing, residual 2.15e-13), which isolates the augmentation as the cause.

**What is not the cause.** The augmented matrix has an 8.8e5 within-matrix
entry-magnitude ratio. That is a *symptom*. Rescaling the basis, or equilibrating the
augmented matrix, would not tighten the residual that created the softness.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A basis that leaves the augmented matrix's rank well defined (Priority: P1)

A modeller computes a non-negative left-nullspace basis for a reasonably well scaled
stoichiometric matrix, augments the stoichiometric matrix with that basis, and asks
for the augmented matrix's rank or nullspace. Every rank routine they might
reasonably reach for agrees on one integer, and the nullspace basis they get back
actually annihilates the matrix.

**Why this priority**: this is the defect's primary consequence. Without it, every
downstream rank or nullspace computation on an augmented matrix is silently
unreliable, and no amount of downstream guarding recovers the lost information.

**Independent Test**: on fixtures whose non-negative left nullspace is known exactly,
and on a well-scaled genome-scale model, compute the basis, form the augmented
matrix, and confirm that the rank agrees across independent routines and across
tolerances spanning several orders of magnitude.

**Acceptance Scenarios**:

1. **Given** a small matrix whose non-negative left nullspace is known exactly,
   **When** the basis is computed, **Then** the returned rows span that known
   nullspace, every entry is non-negative, and the residual against the
   stoichiometric matrix is at or below the accuracy target of FR-002 in both
   absolute and scaled form.
2. **Given** a reasonably well scaled genome-scale model, **When** the basis is
   computed and spliced into the augmented matrix, **Then** `getRankLUSOL`,
   `getNullSpace` and a singular-value decomposition report the **same** rank
   integer, and that integer is unchanged across rank tolerances spanning at least
   three orders of magnitude.
3. **Given** that same augmented matrix, **When** a nullspace basis of it is
   requested, **Then** the residual of that nullspace basis against the augmented
   matrix is at machine-precision scale, not order 1.
4. **Given** a matrix with more rows than columns and one with more columns than
   rows, **When** the basis is computed, **Then** both return correctly shaped,
   non-negative bases satisfying the same accuracy target.
5. **Given** a matrix whose left nullspace is empty, **When** the basis is computed,
   **Then** an empty basis is returned without error and the status records that the
   nullspace is empty rather than that the computation failed.

---

### User Story 2 - An unmissable diagnosis when the input is too badly scaled to serve (Priority: P1)

A modeller supplies a badly scaled stoichiometric matrix. Rather than returning a
basis that will silently destroy the rank gap downstream, the routine tells them —
in a form their code can branch on without reading console text — that the input is
badly scaled, by how much, and what repair is indicated.

**Why this priority**: a wrong answer delivered confidently is worse than no answer.
Where no basis routine could produce a usable result, returning one is the defect.
This story is what makes the failure mode *visible* instead of silent, and it is the
only protection for callers that never read warnings.

**Independent Test**: construct a deliberately badly scaled input, call the routine,
and confirm that it returns the diagnosis, returns no basis, and that a caller
inspecting only the returned status — never the console — can tell what happened and
what to do.

**Acceptance Scenarios**:

1. **Given** a deliberately badly scaled stoichiometric matrix, **When** the basis is
   requested, **Then** both returned bases are empty, no error is raised, and the
   third output reports the bad-scaling classification.
2. **Given** that same call, **When** the caller inspects only the returned status and
   never reads the console, **Then** they can determine (a) that the call did not
   produce a basis, (b) which quantity is badly scaled, (c) the measured magnitude of
   the problem, and (d) the indicated repair to the stoichiometric matrix.
3. **Given** a caller that suppresses all warnings and printed output, **When** the
   badly scaled input is supplied, **Then** the diagnosis is still fully available
   from the returned value alone.
4. **Given** an input on the well-scaled side of the boundary, **When** the basis is
   requested, **Then** the routine proceeds to compute a basis and does not
   false-positive into the diagnosis path.
5. **Given** the classification boundary, **When** its value is inspected in the
   feature's research record, **Then** it is traceable to a measured quantity the
   problem itself defines, with the measurement recorded — not to an unexplained
   constant.

---

### User Story 3 - An incomplete basis that admits it is incomplete (Priority: P2)

A modeller's basis search hits its time budget before finding every ray. The value
they get back does not claim, by its shape, to be a complete basis.

**Why this priority**: independent of accuracy, this is a second mechanism by which
today's return destroys the augmented rank gap. The result is preallocated to the
full expected height and its unfilled trailing rows are all zero, so a caller testing
only the number of rows — which is exactly what the known downstream guards do — is
told the basis is complete when it is not. All-zero rows in the augmented matrix are
rank-deficient by construction.

**Independent Test**: force an early termination with a short time budget and confirm
that the returned basis has no all-zero rows, that its row count equals the number of
rays actually accepted, and that the status records incompleteness.

**Acceptance Scenarios**:

1. **Given** a time budget too short to complete the basis, **When** the search
   terminates early, **Then** the returned basis contains no all-zero rows.
2. **Given** that same early termination, **When** the caller inspects the returned
   row count, **Then** it equals the number of rays actually accepted, not the number
   expected.
3. **Given** that same early termination, **When** the caller inspects the status,
   **Then** it records that the basis is incomplete and how many of how many rays
   were found.

---

### User Story 4 - Parameters and documentation that mean what they say (Priority: P3)

A modeller reads the function's help text, sets the documented parameters, and gets
the behaviour the documentation describes.

**Why this priority**: these are correctness defects in the same file with no
numerical consequence for the headline scenarios, but each misleads a caller. They
are grouped so they can be taken or deferred as one decision, explicitly, rather than
being fixed silently as a side effect of the numerical work.

**Independent Test**: set each documented parameter, and call with default parameters
on a model lacking the optional field, asserting the documented effect in each case.

**Acceptance Scenarios**:

1. **Given** a caller who supplies the per-basis time budget and not the total time
   budget, **When** the routine runs, **Then** the total-time parameter is
   nonetheless defined, and each budget governs the period its documentation
   describes — or the redundant parameter is removed with a documented migration.
2. **Given** a caller who supplies a total time budget, **When** the total elapsed
   time exceeds it, **Then** the search terminates on that budget.
3. **Given** a model lacking the optional stoichiometric-consistency field and
   default parameters, **When** the routine is called, **Then** it returns an
   actionable diagnosis naming the missing field, not an undefined-field error from
   deep inside the routine.
4. **Given** the usage examples in the function's help text, **When** they are
   executed verbatim, **Then** they run.

---

### Edge Cases

- **Empty left nullspace** — the stoichiometric matrix has full row rank. An empty
  basis is correct and must be distinguishable from failure.
- **Non-square inputs** — both more rows than columns and more columns than rows.
- **Early termination** — the time budget expires before the basis is complete
  (User Story 3).
- **Borderline scaling** — an input sitting near the classification boundary. Which
  side it falls on must be determined by the measured criterion, and the routine must
  behave consistently (a basis meeting the accuracy target, or the diagnosis) rather
  than producing a basis that fails the target.
- **The accuracy target cannot be met on a well-scaled input** — if the attainable
  residual is floored below the required accuracy by the underlying optimization, the
  routine must not return a basis that silently fails the target; it must surface
  that outcome (see FR-003 and the Assumptions section).
- **Expected basis size derived from an unreliable rank** — the number of rays sought
  is itself obtained from a rank computation on the input. On badly conditioned
  input, that count is exactly as unreliable as the rank computations this feature
  exists to protect, so the target row count cannot be treated as ground truth.
- **A caller that ignores every output but the first** — the diagnosis must still be
  impossible to mistake for a valid basis.
- **Suppressed console output** — all diagnostic content must be available from the
  returned value.

## Requirements *(mandatory)*

### Functional Requirements

**Regime A — accuracy on reasonably well scaled input**

- **FR-001**: For a reasonably well scaled stoichiometric matrix, the routine MUST
  return a non-negative left-nullspace basis accurate enough that augmenting the
  stoichiometric matrix with it yields a matrix with an **unambiguous numerical
  rank**: the same integer from `getRankLUSOL`, from `getNullSpace`, and from a
  singular-value decomposition evaluated at rank tolerances spanning at least three
  orders of magnitude.
- **FR-002**: The accuracy target that FR-001 requires of each basis row MUST be
  **derived from what a rank determination actually needs** — that is, from the
  separation required between the retained and discarded singular values of the
  augmented matrix — and MUST be stated together with its derivation in the feature's
  research record. A target chosen for convenience, or stated without derivation, does
  not satisfy this requirement.
- **FR-003**: Every row of the returned non-negative basis MUST satisfy the accuracy
  target of FR-002, and this MUST be verified on the returned object rather than
  assumed from the acceptance path that produced it.
- **FR-003a**: A candidate ray that cannot meet the accuracy target MUST be **dropped
  and the search continued**; it MUST NOT be returned. The status MUST record how many
  candidate rays were rejected for accuracy, since that count is the evidence that the
  attainable residual floor sits above the target. If the time budget expires with
  fewer accepted rays than expected, the call terminates in the incomplete-basis
  outcome of FR-010; a run that rejects every candidate for accuracy MUST be
  distinguishable in the status from one that simply ran out of time.
- **FR-004**: Every entry of the returned non-negative basis MUST be greater than or
  equal to zero. This is a hard requirement, not a preference: any treatment applied
  to improve accuracy MUST preserve it, and it MUST be asserted on the returned
  object.

**Regime B — diagnosis on badly scaled input**

- **FR-005**: The routine MUST classify its input as reasonably well scaled or badly
  scaled before committing to return a basis. The classification MUST be applied to
  the matrix the routine will **actually operate on** — after any restriction to the
  stoichiometrically consistent subset and after any transposition for the requested
  nullspace mode — not to `model.S` as supplied, since it is the operative matrix
  whose conditioning determines whether a usable basis exists. The status MUST state
  which matrix was classified.
- **FR-006**: The classification boundary between the two regimes MUST be grounded in
  a quantity the problem itself defines — for example machine precision relative to
  the norm of the stoichiometric matrix, the residual floor the underlying
  optimization can actually deliver, or a condition estimate — and the measurement
  that establishes it MUST be recorded in the feature's research record. A boundary
  chosen by the implementing agent without measurement is a defect against this
  requirement, not an acceptable default.
- **FR-007**: On badly scaled input the routine MUST NOT return a basis of either
  kind: both the non-negative basis and the sign-unrestricted second output MUST be
  returned empty. One consistent rule applies — badly scaled input yields no basis —
  so that no caller can obtain a well-formed object it might use without reading the
  status.
- **FR-008**: On badly scaled input the routine MUST return a **machine-readable
  status** as a **third positional output** — `[Zpos, Z, status]` — that a caller can
  branch on without parsing console text and without catching an error, reporting:
  that no basis was produced; which quantity is badly scaled; the measured magnitude
  of the problem; and the repair to the stoichiometric matrix that is indicated. A
  printed message alone does not satisfy this requirement. The routine MUST return
  gracefully in this case rather than raising an error.
- **FR-009**: The third output MUST be populated on **every** call, not only in
  Regime B, and MUST distinguish each terminal outcome from the others: a complete
  basis meeting the accuracy target; an incomplete basis (FR-010); an empty left
  nullspace; badly scaled input (FR-007); and a missing required input field
  (FR-013). A caller MUST be able to tell these apart from the status alone.

**Truthful completeness**

- **FR-010**: When the search terminates before a complete basis is found, the
  returned basis MUST NOT contain placeholder all-zero rows. Its row count MUST equal
  the number of rays actually accepted, and the status MUST record that the basis is
  incomplete together with the number of rays found and the number expected. The
  status MUST label the expected count as **derived from a rank computation on the
  operative matrix**, because that count is produced by the same class of computation
  whose reliability under poor conditioning this feature exists to question; it is a
  target, not ground truth, and MUST NOT be presented as the latter.

**Parameter and documentation correctness**

- **FR-011**: Each documented time-budget parameter MUST govern the period its
  documentation describes, and the field a guard tests MUST be the field it assigns.
  Alternatively a redundant parameter MUST be removed or deprecated with a documented
  migration under Principle II. This requirement MUST be discharged explicitly — taken
  or deferred with a stated reason — and MUST NOT be fixed silently as a side effect
  of the numerical work.
- **FR-012**: A caller who supplies only the per-basis budget MUST NOT be left with an
  undefined total budget.
- **FR-013**: Calling the routine with default parameters on a model lacking the
  optional stoichiometric-consistency field MUST produce an actionable diagnosis
  naming the missing field and how to obtain it, **delivered as a graceful return with
  the corresponding status outcome of FR-009** — consistent with FR-008's
  return-don't-raise rule — not as an undefined-field error raised from inside the
  routine. This path is live, not hypothetical: the in-repo caller
  `src/analysis/topology/extremeRays/optimalRays/optimalExtremePoolDriver.m:121`
  invokes the routine with no parameter argument at all.
- **FR-014**: The function's help header MUST document a usage form that actually
  works, and MUST be updated in the same change as the behaviour it describes
  (Constitution Principle VII-E).

**Interface, reporting and verification**

- **FR-015**: The **call syntax** MUST remain compatible: an existing caller
  requesting the two documented outputs MUST continue to run without modification, and
  adding the third output of FR-008 MUST NOT affect callers that do not request it.
  A caller that passes a parameter the routine previously accepted MUST NOT begin to
  error on that account.
- **FR-015a**: The **results** returned under default parameters are deliberately
  changed. This is an **approved breaking change** under Constitution Principle II,
  approved in this specification by the Session 2026-09-14 clarification: the
  corrected acceptance accuracy becomes the default and **no parameter value
  reproduces the pre-change behaviour**. The existing acceptance-tolerance parameter is
  **retained but clamped**: it MUST continue to be accepted without error (FR-015), it
  MAY tighten acceptance below the accuracy target derived under FR-002, and it MUST
  NOT loosen acceptance above that target. The clamp is what enforces the no-opt-out
  decision, and the help header MUST document the parameter's changed meaning.
- **FR-015b**: Because Principle II permits a breaking change only when the
  specification documents a **migration path**, the change MUST be announced where a
  caller will meet it: the function's help header MUST state that the acceptance
  accuracy changed, on what date and under which feature, that results computed with
  the previous default are not reproducible through the current function, and that
  reproducing them requires a prior release of the toolbox. A caller relying on the
  previous numerical output MUST NOT be able to upgrade without that statement being
  visible in the documentation of the function they call.
- **FR-016**: The **routine** MUST report, per call, quantities it can know from that
  call: the residual of the basis against the operative matrix in **both** absolute and
  scaled form (scaled by the product of the two matrix norms); the nullity implied by
  the returned basis against the rank computed independently; whether non-negativity
  holds; and that call's elapsed time. These MUST be available from the status
  irrespective of console verbosity.
- **FR-016a**: The **feature's measurement record** — an artifact under this feature
  directory, not an output of the routine — MUST report the same quantities per case
  across repeated runs, together with the **replicate count** behind each figure. A
  replicate count is a property of a measurement campaign and cannot be known to a
  single invocation; separating the two reporters is what keeps FR-016 satisfiable.
- **FR-017**: Console output MUST remain gated behind the existing verbosity control,
  and the machine-readable status MUST be complete independently of it
  (Constitution Principle VII-G).
- **FR-018**: The feature MUST ship the narrowest practical automated test under
  `test/verifiedTests/` that runs within `test/testAll.m` and CI, named for the
  function under test per Constitution Principle III-Naming, declaring its solver and
  toolbox requirements through `prepareTest` so it skips gracefully, fixing random
  seeds for reproducibility, and using justified tolerances for all floating-point
  comparisons.
- **FR-019**: Every guard the feature introduces or modifies MUST be exercised
  against the failure it guards, not only against a successful path.
- **FR-020**: Every requirement in this specification applies **identically in both
  nullspace modes**. Where the routine is asked for the right nullspace it operates on
  the transpose, which is incidental to the mathematics; the accuracy target (FR-002),
  the regime classification (FR-005), the withholding rule (FR-007), the status
  (FR-008, FR-009) and the completeness rule (FR-010) all carry over unchanged. Read
  "left nullspace" throughout as "the requested nullspace". The feature MUST NOT leave
  one mode carrying the pre-change acceptance behaviour while the other is corrected.

### Key Entities

- **Stoichiometric matrix** (`model.S`): the input whose left nullspace is sought;
  its scaling determines the regime.
- **Non-negative basis** (`Zpos`, called `L` downstream): the primary output; every
  entry non-negative, every row in the left nullspace to the accuracy target.
- **Linear basis** (`Z`): the second, sign-unrestricted output, obtained from a rank
  computation on the input. Withheld (returned empty) in Regime B along with the
  non-negative basis, because it is produced by the same rank computation whose
  unreliability under bad conditioning motivates the diagnosis.
- **Augmented matrix**: the matrix a caller forms by splicing the basis alongside the
  stoichiometric matrix; the object whose rank must be unambiguous. Formed by the
  caller, not by this routine — this feature is accountable for the basis's fitness
  for that use, not for forming it.
- **Regime classification**: reasonably-well-scaled or badly-scaled, decided by the
  measured boundary of FR-006.
- **Status**: the third positional output; the machine-readable record of the
  terminal outcome on every call and, in Regime B, the diagnosis and the indicated
  repair. Populated whether or not console output is enabled.

## Clarifications

### Session 2026-09-14

- Q: Should the tightened ray-acceptance become the default, be opt-in, or be default
  with an opt-out? -> A: **Tighten the default, with no opt-out.** The corrected
  accuracy is the only behaviour; the pre-change basis cannot be reproduced through
  this function. This is an explicitly approved breaking change under Constitution
  Principle II (FR-015a records the approval; FR-015b the migration path it obliges).
- Q: How should the machine-readable status required by FR-008 reach the caller,
  given a two-output signature with no structure output? -> A: **A third positional
  output**, `[Zpos, Z, status] = greedyExtremeRayBasis(model, param)`. Callers that
  request only the two documented outputs are unaffected by its addition.
- Q: In Regime B, is the sign-unrestricted second output `Z` withheld along with the
  non-negative basis, or returned flagged as unreliable? -> A: **Both outputs are
  withheld.** One consistent rule: badly scaled input yields no basis of either kind,
  and the status explains why.
- Q: Do the new guarantees apply to right-nullspace mode as well as left? -> A:
  **The same contract applies in both modes.** The transpose is incidental to the
  mathematics, so the accuracy target, the regime classification and the status apply
  identically whichever nullspace is requested (FR-020).
- Q: What happens to a computed ray that cannot meet the derived accuracy target?
  -> A: **Drop it and keep searching**, recording the count of accuracy-rejected rays
  in the status. If the budget expires with too few accepted rays the call lands in
  the incomplete-basis outcome already specified by FR-010 (FR-003a).
- Q: What becomes of the existing acceptance-tolerance parameter? -> A: **Retained but
  clamped.** It is still accepted, so no existing caller errors; it may tighten
  acceptance below the derived target but can never loosen it above (FR-015a).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On fixtures whose non-negative left nullspace is known exactly —
  including at least one with unequal row and column counts, and at least one whose
  left nullspace is empty — the returned basis spans the known nullspace exactly, with
  every entry non-negative.
- **SC-002**: On a reasonably well scaled genome-scale case, the augmented matrix's
  rank is reported as the **same integer** by `getRankLUSOL`, by `getNullSpace`, and
  by singular-value decomposition evaluated across rank tolerances spanning at least
  three orders of magnitude.
- **SC-003**: For that same case, a nullspace basis of the augmented matrix has a
  residual at machine-precision scale rather than order 1, demonstrating the rank gap
  is restored.
- **SC-004**: A deliberately badly scaled case returns the bad-scaling diagnosis and
  returns **no basis**; a caller reading only the returned status, with all console
  output suppressed, can determine what is badly scaled, by how much, and what repair
  is indicated.
- **SC-005**: `iDopaNeuroC` either yields a basis giving the augmented matrix an
  unambiguous rank under SC-002's test, or returns the bad-scaling diagnosis. Either
  outcome is acceptable; silently returning a basis with today's accuracy is not. This
  regression runs as a **documented reproducibility check** (a script plus its expected
  output and trace) rather than as a CI test, because the model ships in
  `papers/2023_iDopaNeuro/models/iDopaNeuroC.mat` and `papers/` is a **git submodule**
  whose initialization is gated during toolbox init, so it cannot be relied on to be
  present in CI. Constitution Principle III sanctions this substitute where automation
  is not yet practical, and requires the reason for deferral to be stated — it is
  stated here.
- **SC-006**: A run terminated early by its time budget returns a basis with no
  all-zero rows, a row count equal to the number of rays accepted, and a status
  recording incompleteness — and a caller that inspects only the row count cannot be
  misled into treating it as complete.
- **SC-007**: Every guard introduced or modified by the feature has a test that
  exercises the failure it guards, in addition to any success-path test.
- **SC-008**: The classification boundary of FR-006 is recorded in the research record
  with the measurement that establishes it and the quantity it is derived from, such
  that a reviewer can re-derive it without re-running the implementation.
- **SC-009**: Results are reported per case with the residual in both absolute and
  scaled form, the implied nullity against the independently computed rank,
  non-negativity, runtime, and the replicate count behind each measurement.
- **SC-010**: An existing caller requesting the two documented outputs runs against
  the revised routine without modification and without error, and a caller that
  requests the new third output receives a populated status on every terminal outcome.
- **SC-011**: The feature's test runs within `test/testAll.m` and passes in CI,
  skipping gracefully where its declared solver requirements are unavailable, and
  depends on no git-submodule content.
- **SC-012**: The function's help header states the acceptance-accuracy change, its
  date and feature, that reproducing pre-change results requires a prior release, and
  the changed meaning of the acceptance-tolerance parameter — the migration path
  FR-015b requires.
- **SC-013**: The same accuracy target and status semantics are demonstrated in **both**
  nullspace modes, so neither mode retains the pre-change acceptance behaviour
  (FR-020).
- **SC-014**: A run in which candidate rays are rejected for accuracy is
  distinguishable, from the status alone, from a run that merely exhausted its time
  budget, and the count of accuracy-rejected rays is reported (FR-003a).
- **SC-015**: The in-repo caller `optimalExtremePoolDriver.m` — which passes no
  parameter argument — receives the FR-013 diagnosis rather than an undefined-field
  error.

## Assumptions

- The measured evidence in `feature-request.md` is taken as given and is not
  re-derived by this feature; it is reproducible from the frozen instances named
  there.
- **No attainable residual is promised.** Whether any particular accuracy target is
  reachable is a finding of this work, not an input to it. The rays are solutions of
  an optimization whose own feasibility tolerance may floor the attainable residual.
  If that floor turns out to sit above the accuracy target FR-002 derives, that is a
  legitimate and valuable outcome: it would mean the bad-scaling regime is the correct
  answer for more models than expected, and it MUST be reported plainly rather than
  worked around.
- **No runtime is promised**, and **no claim is made in advance about which regime any
  particular model falls into** — including `iDopaNeuroC`. Regime membership is an
  output of this work.
- No particular remedy is assumed to work. Tightening the acceptance tolerance,
  refining or re-projecting each accepted ray, cleaning the assembled basis, and exact
  arithmetic on small problems are all candidates; each must be measured before being
  relied upon. Any remedy that does not preserve non-negativity (FR-004) is excluded —
  ordinary orthogonalisation does not preserve it.
- The greedy search draws random objectives, so results vary between runs. Tests fix
  the random seed (FR-018); reported measurements state their replicate count
  (FR-016).
- "Reasonably well scaled" is defined only by the measured boundary of FR-006; it
  carries no prior meaning in this specification.

## Out of Scope

- **The downstream guards in the `varkin` repository MUST NOT be edited by this
  feature.** For the record they are inadequate: `createCyclicModel.m:223-225` checks
  the residual against a tolerance roughly nine orders of magnitude too loose to
  certify a rank-defining property; `createCyclicModel.m:227-229` checks spanning
  one-sidedly and therefore cannot detect rank over-estimation; and
  `driver_optimizeVKmodel_VK1to3m.m:691-693` raises a spanning error while comparing
  only a row count, never evaluating the residual. What `varkin` would need to assert
  once this routine is fixed MUST be stated in `plan.md` so that work can be specified
  separately, in that repository.
- Forming the augmented matrix, and any change to how callers construct it.
- Changing the in-repo caller `optimalExtremePoolDriver.m`. It is named here because it
  exercises the FR-013 path and is affected by the approved results break; whether it
  needs updating is a finding for `plan.md`, and any change to it is a separate
  decision rather than an assumed consequence of this feature.
- Repairing the scaling of any model shipped with this repository. This feature
  *diagnoses* bad scaling and recommends repair; performing the repair is separate
  work.
- Changes to the rank routines themselves (`getRankLUSOL`, `getNullSpace`). They are
  used here as independent measurement instruments; that `getNullSpace` over-estimates
  rank on badly conditioned input is evidence for this feature, not a defect this
  feature fixes.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001, FR-002, FR-003 (accuracy target met; augmented rank unambiguous) | `testGreedyExtremeRayBasis.m` — well-scaled genome-scale case | `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m` |
| US1 / FR-004 (non-negativity) | `testGreedyExtremeRayBasis.m` — asserted on every returned basis | same |
| US1 / SC-001 (exact small fixtures, unequal dimensions, empty nullspace) | `testGreedyExtremeRayBasis.m` — exact-fixture cases | same |
| US2 / FR-005, FR-007, FR-008 (diagnose, withhold basis, machine-readable) | `testGreedyExtremeRayBasis.m` — badly scaled case, console suppressed | same |
| US2 / FR-006, SC-008 (measured boundary with recorded derivation) | `research.md` measurement record + boundary test at either side | same |
| US2 / FR-009 (terminal outcomes distinguishable) | `testGreedyExtremeRayBasis.m` — one assertion per terminal outcome | same |
| US3 / FR-010, SC-006 (no zero-padded rows; honest row count) | `testGreedyExtremeRayBasis.m` — forced early-termination case | same |
| US4 / FR-011, FR-012 (time budgets govern what they document) | `testGreedyExtremeRayBasis.m` — budget-parameter cases | same |
| US4 / FR-013 (missing field diagnosed, not crashed on) | `testGreedyExtremeRayBasis.m` — default-parameter call on model lacking the field | same |
| US4 / FR-014 (help header usage runs) | `testGreedyExtremeRayBasis.m` — documented usage executed | same |
| FR-015, SC-010 (two-output call syntax still runs; third output populated) | `testGreedyExtremeRayBasis.m` — output-arity cases (2-output and 3-output) | same |
| FR-015a (no parameter loosens acceptance below the derived target) | `testGreedyExtremeRayBasis.m` — loose-tolerance case asserts the target still holds | same |
| FR-015b, SC-012 (breaking change announced in the help header; migration path) | `testGreedyExtremeRayBasis.m` — header content check | same |
| US1 / SC-003 (augmented nullspace residual at machine-precision scale) | `testGreedyExtremeRayBasis.m` — augmented-rank case asserts the nullspace residual | same |
| SC-005 (iDopaNeuroC regression: unambiguous rank or diagnosis) | documented reproducibility check under this feature directory (not CI — `papers/` is a submodule) | same |
| FR-003a, SC-014 (failed rays dropped; accuracy-rejection count reported) | `testGreedyExtremeRayBasis.m` — forced accuracy-rejection case | same |
| FR-020, SC-013 (same contract in both nullspace modes) | `testGreedyExtremeRayBasis.m` — right-nullspace mode case | same |
| FR-013, SC-015 (no-parameter call diagnosed, not crashed on) | `testGreedyExtremeRayBasis.m` — no-argument call mirroring `optimalExtremePoolDriver.m:121` | same |
| FR-016, SC-009 (reporting: absolute and scaled residual, nullity, runtime) | `testGreedyExtremeRayBasis.m` — status content assertions | same |
| FR-016a, SC-009 (replicate counts across repeated runs) | feature measurement record under this feature directory | same |
| FR-017 (status complete with output suppressed) | `testGreedyExtremeRayBasis.m` — suppressed-output case | same |
| FR-018, SC-011 (narrowest test, `prepareTest`, seeded, in CI) | `testGreedyExtremeRayBasis.m` under `test/verifiedTests/`, run by `test/testAll.m` | same |
| FR-019, SC-007 (every guard exercised against its failure) | `testGreedyExtremeRayBasis.m` — one negative case per guard | same |
