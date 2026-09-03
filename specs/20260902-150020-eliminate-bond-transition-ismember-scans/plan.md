# Implementation Plan: Eliminate remaining cell.ismember scans in buildAtomAndBondTransitionMultigraph's bond-transition loop

**Branch**: `20260902-150020-eliminate-bond-transition-ismember-scans` | **Date**: 2026-09-02 | **Spec**: `specs/20260902-150020-eliminate-bond-transition-ismember-scans/spec.md`

**Input**: Feature specification from `/specs/20260902-150020-eliminate-bond-transition-ismember-scans/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Feature 022 hoisted `EdgeTable`-building off live `table` dot-indexing but never touched
the read-side hotspot in the same file: `buildAtomAndBondTransitionMultigraph.m`'s
bond-transition loop (lines 677-684) still resolves each bond-transition's four
substrate/product atom identities via 8 boolean-mask expressions — each combining two
`ismember` calls (on `dATME.Nodes.mets` and `dATME.Nodes.Element`) plus an `AtomNumber`
equality — 16 `ismember` calls per bond-transition, the dominant remaining term behind
022's SC-002/SC-003 shortfall (66.8% vs. >=90% `cell.ismember` reduction; 27.4% vs. >=70%
`tabular.dotReference` reduction). This is the identical "no lookup index" anti-pattern
022's own User Story 1 already fixed in `readABRXNFile.m` (research.md R1 there: a
`containers.Map` keyed by a composite identity, built once, replacing per-row linear
scans) — this feature applies the same fix shape here, one call site later.

The fix: build a `containers.Map` once over `dATM.Nodes` (the base multigraph node table,
finalized at line 386 and never mutated afterward — only `dATME`, its per-reaction
extension with the energy pseudo-node, changes per reaction), keyed on
`(mets, AtomNumber, Element)`, immediately before the bond-transition per-reaction loop
begins (FR-002). A new, narrowly-scoped helper function,
`resolveAtomNodeIndex.m`, wraps the guarded map lookup plus the `Atom`/`AtomIndex`
column read and raises a named, identifiable error (`resolveAtomNodeIndex:missingNodeIdentity`
/ `resolveAtomNodeIndex:ambiguousNodeIdentity`) on a zero- or multi-match key, satisfying
both FR-005 (must fail at least as clearly as today's element-count-mismatch error) and
User Story 2's explicit requirement that "the lookup" itself — not a downstream assignment
several lines later — is what raises the error, independently unit-testable without
constructing a full RXN-parsing pipeline. The bond-transition loop body calls this helper
four times per iteration (one per substrate/product head/tail atom) instead of evaluating
8 mask expressions, cutting today's 16 `ismember` calls per bond-transition to zero.
Neither `buildAtomAndBondTransitionMultigraph`'s signature, return values, nor the
`EdgeTable`/`dATM`/`dBTM` schema change (FR-006) — verified by the unmodified
`testConservedReactingMoieties.m` (SC-004) and a new Tyrosine-benchmark reproducibility
check (`tyrosineReproducibilityCheck.m`, reusing features 021/022's script as a structural
template — research.md R3) reporting before/after `cell.ismember`/`tabular.dotReference`
call counts (SC-001, SC-002) and byte-identical `arm.L`/`moietyFormulae`/
`reacting.selectedReactionNames` (SC-003).

## Technical Context

**Language/Version**: MATLAB (R2024b+ supported baseline per constitution;
`containers.Map` and `profile` are core MATLAB, no version constraint beyond the existing
baseline)

**Primary Dependencies**: MATLAB core (`table`, `digraph`, `containers.Map`, `profile`);
no new toolboxes or external packages

**Storage**: N/A (in-memory MATLAB values only; the FR-008 reproducibility check persists
a `.mat` golden snapshot and a `.md` results file as feature artifacts under
`specs/20260902-150020-eliminate-bond-transition-ismember-scans/`, not toolbox storage)

**Testing**: MATLAB `test/testAll.m` harness via
`test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
(existing, CI-covered, unmodified per SC-004); a new CI-covered unit test,
`test/verifiedTests/analysis/testReactingMoieties/testResolveAtomNodeIndex.m`, for the
new `resolveAtomNodeIndex.m` helper (US2, SC-006); plus a new non-CI documented
reproducibility check (`tyrosineReproducibilityCheck.m`) per Principle III's fallback for
the externally-dependent, multi-minute Tyrosine benchmark (FR-007/FR-008)

**Target Platform**: Headless Linux CI (GitHub Actions `testAllCI_*`, `.artenolis.yml`),
matching the existing toolbox CI environment

**Project Type**: Single MATLAB toolbox library (no frontend/backend split)

**Performance Goals**: On the Tyrosine metabolism subsystem benchmark (139 reactions),
reduce total pipeline `cell.ismember` calls to <=50,853 (<=10% of the pre-feature-022
baseline of 508,534, completing the >=90% reduction target 022 fell short of at 66.8%,
SC-001), and reduce `tabular.dotReference` calls to <=559,028 (<=30% of the pre-022
baseline of 1,863,426, completing the >=70% reduction target 022 fell short of at 27.4%,
SC-002), while total wall-clock time on the same benchmark does not regress relative to
the post-022 baseline of 55.0s (SC-005, a further reduction expected but not gated).

**Constraints**: No change to `buildAtomAndBondTransitionMultigraph`'s public signature,
inputs, outputs, or documented meaning (FR-006); no change to `EdgeTable`/`dATM`/`dBTM`
row count, order, or content (FR-006, Acceptance Scenario 1); the index is built once per
function call from `dATM.Nodes` only, never once per reaction or per bond-transition
(FR-002), and never needs to include the per-reaction energy pseudo-node (FR-004,
Assumptions); a lookup key resolving to zero or multiple `dATM.Nodes` rows MUST fail
explicitly, never silently pick an arbitrary match or silently drop the bond-transition
(FR-005).

**Scale/Scope**: Tyrosine metabolism subsystem (139 reactions) as the performance-benefit
benchmark; the existing small CI fixture used by `testConservedReactingMoieties.m` as the
correctness-preserving benchmark (Edge Cases: a reaction with zero bond-transitions must
build the index without error even if never queried that iteration).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: No stoichiometric, bound, objective, or solver-status
  semantics are touched (Principle I N/A — this feature operates purely on the
  bond-transition atom/bond multigraph's node-identity resolution, not on the COBRA model
  `S`/`lb`/`ub`/`c` objects). `dATM.Nodes`/`dATME.Nodes` column semantics
  (`Atom`, `AtomIndex`, `mets`, `AtomNumber`, `Element`) are read-only inputs to this
  feature's lookup mechanism and are contractually unchanged in value
  (contracts/unchanged-public-contract.md).
- **Testing and reproducibility**: `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
  is the CI-covered regression gate (SC-004) — no existing assertion is loosened, removed,
  or replaced. The new `resolveAtomNodeIndex.m` helper is a new `src/` module and per
  Principle III/III-Naming ships its own new CI test file,
  `test/verifiedTests/analysis/testReactingMoieties/testResolveAtomNodeIndex.m` (US2,
  SC-006, data-model.md E3). The Tyrosine-benchmark reproducibility check (FR-007, FR-008)
  is the documented, non-CI substitute Principle III sanctions for the externally-dependent,
  multi-minute benchmark; see `quickstart.md` step 4 and research.md R3.
- **User experience and diagnostics**: No new user-facing output, print level, or
  diagnostic for the golden path. On a malformed zero/multi-match node identity, the new
  `resolveAtomNodeIndex:missingNodeIdentity` / `resolveAtomNodeIndex:ambiguousNodeIdentity`
  errors are strictly more explicit and identifiable than today's generic MATLAB
  size-mismatch error (FR-005, US2, research.md R1) — a diagnostic improvement, not a
  regression, and no existing diagnostic is removed.
- **Performance and numerical integrity**: Performance goal (SC-001/SC-002) is explicitly
  subordinate to output identity (Acceptance Scenario 1, SC-003) — research.md R1 shows the
  lookup-index replacement cannot change any `Atom`/`AtomIndex` value returned for a given
  key, only how many `cell.ismember`/`tabular.dotReference` calls and how much wall-clock
  time computing that same value takes. No diagnostic/verification step is removed or made
  skippable; the malformed-input failure path (duplicate or missing node-identity key) is
  deliberately preserved and made *more* explicit, not papered over (research.md R1, US2).
- **External-solver configuration audit**: N/A — no external solver is invoked by this
  feature (`testConservedReactingMoieties.m`'s MILP requirement is for an unrelated,
  pre-existing minimum-set-cover step this feature does not touch).
- **Spec-driven scope control**: Edit:
  `src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m` (the
  bond-transition per-reaction loop, currently lines ~605-696, only — the node-identity
  index is built once immediately before this loop begins; the atom-transition loop above
  it, lines 217-355, is out of scope, already addressed by feature 022). Create (new
  `src/` module, justified by FR-001/FR-005 and US2's independent-testability requirement):
  `src/analysis/topology/reactingMoieties/resolveAtomNodeIndex.m` and its test
  `test/verifiedTests/analysis/testReactingMoieties/testResolveAtomNodeIndex.m`. Create
  (Spec Kit artifacts, not `src/`):
  `specs/20260902-150020-eliminate-bond-transition-ismember-scans/tyrosineReproducibilityCheck.m`
  (new, non-CI, reusing 021/022's script as structural template),
  `specs/20260902-150020-eliminate-bond-transition-ismember-scans/tyrosine-golden-snapshot.mat`
  (generated once, pre-change),
  `specs/20260902-150020-eliminate-bond-transition-ismember-scans/tyrosine-reproducibility-results.md`
  (generated). Read-only / do not touch: the atom-transition loop and every other section
  of `buildAtomAndBondTransitionMultigraph.m`; every other file in
  `src/analysis/topology/reactingMoieties/` (`readABRXNFile.m`, `addBondMappingsRXNFile.m`,
  `checkABRXNFiles.m`, `canonicalBondKey.m`, `identifyAtomEquivalenceClasses.m`, etc.) —
  none of feature 022's or 020's already-shipped fixes are touched or duplicated; every
  other `src/` path.
- **MATLAB coding standards**: No `evalc`, no suppressed warnings, no bare `nargin` in the
  new helper (it takes no optional arguments). `resolveAtomNodeIndex.m` follows the
  existing `error('functionName:condition', 'message', ...)` convention already used
  throughout this same directory (`identifyAtomEquivalenceClasses.m`, `readABRXNFile.m`,
  `classifySubgraphIsomorphism.m`, `minimumSetCoverPlain.m` — grep-confirmed, research.md
  R1) and carries the openCOBRA help header (VII-E). The `containers.Map`-keyed-lookup
  pattern (research.md R1) mirrors the precedent already in this same function
  (`metBondCountGroundTruth`, `metAtomCanonicalRankMap`, `metUnsafeNeighborsMap`) and in
  `readABRXNFile.m`'s `atomIndexMap` (feature 022 R1), so no new MATLAB idiom is
  introduced. No relevant project MATLAB-lint skill is currently registered (VII-F) — this
  plan proposes none beyond the openCOBRA style guide already bound by reference (VII-G).
- **Parameter-setting fidelity**: N/A — this feature does not port, reuse, or render MATLAB
  code into another language or a literate document.
- **Artifact placement**: `resolveAtomNodeIndex.m` stays in the same domain folder as its
  only caller (`src/analysis/topology/reactingMoieties/`, Principle IX, source only, no new
  subfolder); its test follows the existing test-directory mirror
  (`test/verifiedTests/analysis/testReactingMoieties/`). The FR-007/FR-008 reproducibility
  script, its golden-snapshot `.mat`, and its results `.md` are new Spec Kit feature
  artifacts placed under `specs/20260902-150020-eliminate-bond-transition-ismember-scans/`
  (Principle IX: "Spec Kit artifact → specs/<feature>/"), reusing features 021/022's script
  as a structural template rather than editing either prior feature's own artifact
  directory (research.md R3).

## Project Structure

### Documentation (this feature)

```text
specs/20260902-150020-eliminate-bond-transition-ismember-scans/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output — R1-R4
├── data-model.md        # Phase 1 output — E1-E4
├── quickstart.md        # Phase 1 output — validation steps 1-5
├── contracts/
│   └── unchanged-public-contract.md   # Phase 1 output — buildAtomAndBondTransitionMultigraph's preserved contract + resolveAtomNodeIndex's new contract
└── tasks.md             # Phase 2 output (/speckit-tasks command — NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
src/analysis/topology/reactingMoieties/
├── buildAtomAndBondTransitionMultigraph.m  # MODIFIED — bond-transition loop (lines ~605-696 only) resolves atom identity via resolveAtomNodeIndex instead of 16 ismember calls per bond-transition
├── resolveAtomNodeIndex.m                  # NEW — guarded node-identity lookup helper (FR-001, FR-003, FR-005; US2)
└── (all other files in this folder)        # UNCHANGED — out of scope, including readABRXNFile.m, addBondMappingsRXNFile.m, checkABRXNFiles.m (already addressed by features 019-022)

test/verifiedTests/analysis/testReactingMoieties/
├── testConservedReactingMoieties.m         # UNCHANGED — regression gate, every assertion intact (SC-004)
└── testResolveAtomNodeIndex.m              # NEW — direct unit test of the extracted lookup helper (US2, SC-006)

specs/20260902-150020-eliminate-bond-transition-ismember-scans/
├── tyrosineReproducibilityCheck.m          # NEW — non-CI FR-007/FR-008 script (reuses features 021/022's script as structural template)
├── tyrosine-golden-snapshot.mat            # NEW — generated pre-change baseline
└── tyrosine-reproducibility-results.md     # NEW — generated before/after report
```

**Structure Decision**: Single MATLAB toolbox project (Option 1 shape, toolbox-specific
paths). The source change stays within the existing
`src/analysis/topology/reactingMoieties/` domain folder per Principle IX; the one new
helper function lives beside its only caller, with its test mirrored under
`test/verifiedTests/analysis/testReactingMoieties/` per the existing test taxonomy
(`test/verifiedTests/<category>/test*.m` run through `test/testAll.m`) — no
`tests/contract|integration|unit` split applies.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

*No Constitution Check violations. One new `src/` file is created
(`resolveAtomNodeIndex.m`); this is not a Complexity Tracking violation — Principle V
requires new files to be justified by feature need, and research.md R4 documents that
justification (US2's independent-unit-testability requirement cannot be met by an
inline-only implementation, unlike feature 022's `readABRXNFile.m` fix, which had no
equivalent independent-test requirement).*
