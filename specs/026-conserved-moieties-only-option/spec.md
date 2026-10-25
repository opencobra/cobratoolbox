# Feature Specification: Conserved-Moieties-Only Option for identifyConservedReactingMoieties

**Feature Branch**: `026-conserved-moieties-only-option`

**Created**: 2026-09-14

**Status**: Draft

**Input**: User description: "my PI wants me to add an option to the reacting code to allow for only the computation of the conserved moieties. Once this is implemented, they want me to test against the original code to determine if they produce the same results." (relayed by the user on behalf of their PI, regarding `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m`)

## Clarifications

### Session 2026-09-14

- Q: Should the equivalence check (User Story 2 / SC-002) run only on the existing small
  deterministic Recon3D-subnetwork fixture already shipped with the test, or also against a
  larger/real network as an additional manual check? → A: Existing fixture only — the
  automated CI test extends the existing small deterministic Recon3D-subnetwork fixture; no
  additional manual/large-network validation is required for this feature.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Compute conserved moieties without paying for reacting-moiety analysis (Priority: P1)

A researcher calling `identifyConservedReactingMoieties` only needs the conserved-moiety
decomposition (`arm`, `moietyFormulae`) for a network. Today the function always also runs
the reacting-moiety bond-graph analysis (condensed reacting-bond graph, CRB2R construction,
and a minimum-set-cover MILP solve) even when the caller has no use for `reacting`. This
forces every caller to pay that cost, and to have a MILP solver installed, even when they
only want conserved moieties. The researcher can request a conserved-moieties-only mode so
the function skips that work.

**Why this priority**: This is the literal, explicit ask — without it, nothing else in this
feature has a reason to exist.

**Independent Test**: Call `identifyConservedReactingMoieties(model, BG, dATM, options)` with
the new option enabled on the function's existing self-contained test fixture (the
Recon3D-subnetwork model in `test/verifiedTests/analysis/testReactingMoieties/`) and confirm
it returns `arm`/`moietyFormulae` without error, without requiring a MILP solver, and without
attempting the reacting-bond/set-cover computation.

**Acceptance Scenarios**:

1. **Given** a model, bond graph `BG`, and directed atom transition multigraph `dATM` for
   which the function currently succeeds, **When** it is called with the new
   conserved-moieties-only option enabled, **Then** it returns `arm` and `moietyFormulae`
   and does not execute the reacting-moiety bond-graph/minimum-set-cover section of the
   function.
2. **Given** the option is enabled, **When** the call completes, **Then** the third output
   (`reacting`) is returned in a form that clearly indicates reacting-moiety analysis was
   not performed, rather than partially-populated or stale data.
3. **Given** a machine with no MILP solver installed, **When** the function is called with
   the option enabled, **Then** it does not raise a MILP-solver-required error (this error
   path is only reachable through the reacting-moiety section it now skips).

---

### User Story 2 - Confirm the new mode agrees with the existing computation (Priority: P1)

The PI wants evidence that adding the option did not change the conserved-moiety algorithm
itself: the conserved-moieties-only path and the existing full (conserved + reacting) path
must produce identical conserved-moiety results on the same inputs.

**Why this priority**: This is the second explicit instruction from the PI, and it is what
makes User Story 1 trustworthy — an option that skips code but silently changes results
would be worse than not having it.

**Independent Test**: On the same test fixture and inputs, run the function once with the
new option enabled and once with default (existing) behavior, and assert the two runs'
`arm` and `moietyFormulae` are equal (within the same numerical tolerance the existing test
already uses for this function).

**Acceptance Scenarios**:

1. **Given** identical `model`, `BG`, and `dATM` inputs, **When** the function is called once
   with the conserved-moieties-only option and once without it, **Then** the two calls'
   `moietyFormulae` outputs are identical.
2. **Given** the same two calls, **When** their `arm` outputs are compared, **Then**
   `arm.L`, `arm.M2M`, and `arm.M2R` are identical (or, for any field whose values are
   derived through floating-point arithmetic, equal within the existing test's tolerance).
3. **Given** the conserved-moieties-only run, **When** the existing conservation invariant
   check is applied, **Then** `norm(full(arm.L) * N) < tol` still holds (the same invariant
   the existing test already asserts for the full computation), where `N` is the atom-mapped
   stoichiometric submatrix.
4. **Given** the option is left at its default (unset/false), **When** existing callers
   invoke the function exactly as before, **Then** behavior and outputs are unchanged from
   before this feature (no regression).

### Edge Cases

- What happens when the option is enabled but a caller still expects the third (`reacting`)
  output to be a valid struct (e.g., checks `isfield`/accesses a sub-field before checking
  whether reacting analysis ran)? The returned placeholder must fail loudly/predictably on
  such access rather than silently returning zeros or empty matches that look like "no
  reacting moieties found."
- What happens when the option is enabled on a network where the reacting-moiety section
  would have thrown an error (e.g., the known `extractBondSubgraphs`/bond-cleaving edge
  case, or a missing MILP solver)? Conserved-moieties-only mode must succeed on such inputs
  precisely because it never reaches that code.
- What happens when both `options.sanityChecks` and the new conserved-only option are
  enabled together? Sanity checks that apply only to the conserved-moiety computation must
  still run; sanity checks (if any) that apply only to the reacting-moiety computation must
  be skipped along with the section they check, not error out on missing reacting data.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `identifyConservedReactingMoieties` MUST accept a new boolean field on its
  existing `options` input struct, alongside `options.sanityChecks` and
  `options.useOpenSourceMoietyTools`, that requests conserved-moieties-only computation.
  Default (field absent or false) MUST preserve today's behavior exactly (Constitution
  Principle II, backward compatibility).
- **FR-002**: When the new option is true, the function MUST NOT execute the reacting-moiety
  bond-level analysis (the unconditional block beginning at the `%% Reacting moiety
  (bond-level) analysis` section: condensed reacting-bond graph construction, CRB2R
  construction, and the minimum-set-cover solve), and in particular MUST NOT require a MILP
  solver to be installed in this mode.
- **FR-003**: When the new option is true, the conserved-moiety computation (everything the
  function currently does up through populating `arm.L`, i.e. the same algorithm
  `identifyConservedMoieties.m` implements) MUST still run in full and MUST produce `arm`
  and `moietyFormulae` values identical to what the existing (default, full) computation
  produces on the same inputs.
- **FR-004**: When the new option is true, the third output (`reacting`) MUST be returned as
  a value that unambiguously signals "not computed" (e.g., an empty struct, or a struct
  whose only field marks it as skipped) — never a partially-populated or default-valued
  struct that could be mistaken for a genuine reacting-moiety result.
- **FR-005**: The function's existing positional signature,
  `identifyConservedReactingMoieties(model, BG, dATM, options)`, MUST NOT change — `BG`
  remains a required positional argument even in conserved-moieties-only mode (it is simply
  not processed in that mode), so existing call sites that already construct a valid `BG`
  are unaffected either way.
- **FR-006**: The function's openCOBRA documentation header MUST be updated to document the
  new `options` field in the same `{(0),1}`-style already used for `options.sanityChecks`
  and `options.useOpenSourceMoietyTools`, and MUST note what the third output becomes when
  the option is enabled (Constitution Principle VII-E).
- **FR-007**: The narrowest practical reproducibility check for this change MUST extend the
  existing test file for this function,
  `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
  (Constitution Principle III-Naming: one test file per source function; this file already
  covers `identifyConservedReactingMoieties`), rather than introducing a second test file for
  the same function.
- **FR-008**: The equivalence check (User Story 2) MUST run on the self-contained
  Recon3D-subnetwork fixture already shipped beside the existing test (no new fixture data
  required for the automated CI test), and MUST continue to assert the existing `L*N = 0`
  conservation invariant and the existing structural assertions (matrix dimensions,
  `moietyFormulae` count) on the conserved-moieties-only path.
- **FR-009**: Existing behavior and existing test assertions for the default (full
  computation) path MUST continue to pass unmodified after this change.

## Key Entities

- **`options.<newField>`**: New boolean field on the existing options struct passed to
  `identifyConservedReactingMoieties`; requests that only the conserved-moiety part of the
  computation run.
- **`arm`**: Atomically-resolved-model structure already returned by the function; unchanged
  in content and meaning by this feature, only in when the reacting-moiety code below it in
  the function runs.
- **`moietyFormulae`**: Existing output; unchanged in content by this feature.
- **`reacting`**: Existing third output; this feature adds a new, explicit "not computed"
  state for it, in addition to its existing populated state.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A caller who only needs conserved moieties can obtain `arm`/`moietyFormulae`
  from `identifyConservedReactingMoieties` without the reacting-moiety analysis running, and
  without needing a MILP solver installed.
- **SC-002**: On the existing test fixture, the conserved-moieties-only run and the existing
  full-computation run produce identical `arm.L`, `arm.M2M`, `arm.M2R`, and `moietyFormulae`
  (exact match for integer/combinatorial fields, and within the existing test's numerical
  tolerance, `1e-8`, for any floating-point-derived comparison).
- **SC-003**: The pre-existing assertions in
  `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` for the
  default (unset-option) code path continue to pass unmodified — i.e., zero regression for
  existing callers.
- **SC-004**: The function's documentation header accurately and completely describes the
  new option and the resulting shape of `reacting` when it is enabled.

## Assumptions

- New option field name: `options.conservedMoietiesOnly` (default `false`), matching this
  function's existing options-struct convention. The exact name may be revisited during
  planning without materially changing this specification's requirements.
- "Same results" (the PI's ask) is interpreted as: the conserved-moiety-specific fields of
  `arm` (`L`, `M2M`, `M2R`) and `moietyFormulae` are equal between the conserved-only run and
  the default full run on identical inputs — not that the two runs' *entire* `arm` structs
  are identical, since fields that exist only to support the reacting-moiety computation
  (e.g., structures the reacting-moiety section itself adds/consumes) are expected to differ
  by construction between the two modes.
- The reacting-moiety section's known open issues tracked separately for this codebase (e.g.
  the CRB2R over-attribution bug, the bond-node head/tail canonicalization work) are out of
  scope for this feature: conserved-moieties-only mode sidesteps that code rather than fixing
  it, and this feature neither depends on nor blocks on those fixes.
- The existing test file's name, `testConservedReactingMoieties.m` (rather than the strict
  `testIdentifyConservedReactingMoieties.m` form Principle III-Naming would otherwise
  require), predates this feature; renaming it is a separate, unrelated concern and is out of
  scope here.



## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001, FR-002, FR-004 | `testConservedReactingMoieties.m` (new assertions) | `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m` |
| US1 / FR-005 | `testConservedReactingMoieties.m` (new assertions, same call signature) | `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m` |
| US2 / FR-003, FR-008 | `testConservedReactingMoieties.m` (new comparison assertions) | `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m` |
| US2 / FR-009 | `testConservedReactingMoieties.m` (pre-existing assertions, unmodified) | `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m` |
| FR-006 | — (no source function; documentation review) | `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m` (header) |
