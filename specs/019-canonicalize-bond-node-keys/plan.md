# Implementation Plan: Canonicalize Bond-Node Keys in Atom/Bond Transition Multigraph Construction

**Branch**: `019-canonicalize-bond-node-keys` | **Date**: 2026-08-18 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/019-canonicalize-bond-node-keys/spec.md`

## Summary

`buildAtomAndBondTransitionMultigraph.m` builds each bond-graph node's identity string directly
from the raw, file-order atom pair in a reaction's RXN connection table
(`bondSubstrateID`/`bondProductID`, lines 593–604), with no canonicalization. When two
reactions share a metabolite whose RXN files were generated independently and list the same
physical bond's atoms in opposite order (confirmed for `crn[c]` across `ELAIDCPT1`, `HMR_2634`,
`HMR_2919`), the same bond produces two distinct node identities, inflating that metabolite's
node count and triggering a spurious `Inconsistent directed bond transition multigraph`
warning from the existing `N`-vs-`N2` stoichiometry check (line 823). The fix canonicalizes the
node-identity string (and every field derived from the same head/tail atom assignment) so a
physical bond always resolves to the same identity regardless of source RXN file, adds a
per-metabolite bond-count sanity check as a runtime guard against this bug class recurring, and
is validated against the existing `testConservedReactingMoieties.m` workflow test plus new
fixture-backed assertions for the `crn[c]` case. Phase 0 research (independently re-verified
against the live repo, not assumed from the spec author's own investigation) confirms the root
cause, the absence of any better upstream fix point, and — critically — that the three named
downstream consumers (`identifyConservedReactingMoieties.m`, `identifyConservedReactingSubgraphs.m`,
`extractBondSubgraphs.m`) have no order-dependent assumption that canonicalization could break.
The one concrete new gap surfaced by research: the RXN fixtures needed for the spec's own
targeted regression (`ELAIDCPT1`/`HMR_2634`/`HMR_2919`) do not exist in-repo and must be sourced
during implementation.

## Technical Context

**Language/Version**: MATLAB, local validation on R2024b+ (COBRA Toolbox baseline); headless
`matlab -batch` in CI (Linux/Docker, Xvfb).

**Primary Dependencies**: COBRA Toolbox reacting-moieties pipeline functions
(`buildAtomAndBondTransitionMultigraph`, `readABRXNFile`, `addBondMappingsRXNFile`,
`checkABRXNFiles`, `identifyConservedReactingMoieties`, `identifyConservedReactingSubgraphs`,
`extractBondSubgraphs`, `mapAontoBOld`), MATLAB's `digraph`/`graph` and `table` types. A MILP
solver for the existing test's minimum-set-cover step (already declared via
`prepareTest('needsMILP', true)`). No new third-party dependency.

**Storage**: N/A — in-memory COBRA model structs, MATLAB `table`/`digraph` structures, and
static RXN-file fixtures committed under `test/verifiedTests/analysis/testReactingMoieties/data/`.

**Testing**: Existing MATLAB verified test
`test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`, extended
with new assertions and a new fixture subset for `ELAIDCPT1`/`HMR_2634`/`HMR_2919` (research
R6, R7). No new test file, per Constitution III-Naming.

**Target Platform**: Headless MATLAB on Linux, matching the existing test's environment; no
solver-specific behavior beyond the existing MILP requirement.

**Project Type**: MATLAB scientific library, single project.

**Performance Goals**: No performance target beyond preserving current runtime — canonicalizing
a string-ordering decision at construction time is O(1) per bond and does not change the
function's asymptotic behavior. Correctness (a metabolite's node count matching its true bond
count) takes priority over any speed consideration.

**Constraints**: No public interface change (function signature, argument order, and existing
`options.sanityChecks`/`options.bondTransitionMultigraph` fields are unchanged); no new
user-facing parameter; the within-bond atom head/tail canonicalization MUST NOT alter
`dBTM.Edges.HeadMet`/`.TailMet` (reaction-direction semantics, spec FR-004); the new
per-metabolite sanity check MUST be a non-fatal warning gated by `options.sanityChecks`, not a
hard error (resolved via `/speckit-clarify`); no RXN-generation toolchain change (spec G3);
tests MUST NOT fetch fixtures over the network at run time (Constitution III) — fixtures are
vendored, not downloaded during test execution.

**Scale/Scope**: One primary source file
(`src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m`) in scope for
edits; possibly one new small helper source file if the canonical-key construction is factored
out (decision deferred to `/speckit-tasks`, per research R7's Alternatives). One existing test
file (`testConservedReactingMoieties.m`) extended; new RXN fixture files added under its
`data/` directory. Spec Kit artifacts live under `specs/019-canonicalize-bond-node-keys/`.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: Touches bond-graph node identity construction in
  `buildAtomAndBondTransitionMultigraph.m` — a diagnostic/topology layer built on top of
  `model.S`/`model.mets`/`model.rxns`, not the constraint-based model itself. Stoichiometry
  (`N`), reaction bounds, objective, and status semantics are never read or written by this
  function; the fix only changes how bond identities are strung together from atom-mapping
  data already parsed from RXN files. The `N`-vs-`N2` consistency check (line 801) is a
  diagnostic residual, not a solver result — eliminating its false positives is a correctness
  fix to that diagnostic, not a change to any model's scientific meaning.
- **Testing and reproducibility**: Narrowest proof is
  `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`, extended
  with assertions for the `crn[c]`/`ELAIDCPT1`/`HMR_2634`/`HMR_2919` case (spec SC-001) and for
  the new sanity check (spec SC-006). No new test file (Constitution III-Naming; research R7).
  Reproducibility command documented in [quickstart.md](./quickstart.md). RXN fixtures are
  vendored into the repo, not fetched at test time (Constitution III, "avoid internet access").
- **User experience and diagnostics**: No new user-facing parameter. The existing
  `options.sanityChecks` flag (default on) continues to gate diagnostic output; the new
  per-metabolite bond-count check follows the same non-fatal, `fprintf`/`warning`-style
  diagnostic pattern already used at lines 708–722 and 755–795, resolved via `/speckit-clarify`
  (spec Clarifications, 2026-08-18). The `Inconsistent directed bond transition multigraph`
  warning's existing format is unchanged; it simply stops firing for the specific false-positive
  case this feature corrects.
- **Performance and numerical integrity**: No solver call is added or changed. Canonicalizing a
  two-element ordering decision per bond is O(1) and negligible relative to the existing
  RXN-file parsing and graph-construction cost. Diagnostic volume is expected to *decrease*
  (fewer false-positive warnings), not increase. No debug/diagnostic/verification step is made
  skippable — the new sanity check is additive and remains behind the existing
  `options.sanityChecks` default-on gate, consistent with the pattern already used in this
  function.
- **External-solver configuration audit**: N/A — no external solver/library is invoked by this
  feature. (The existing test's minimum-set-cover step uses a MILP solver via
  `identifyConservedReactingMoieties`, unaffected and unchanged by this fix.)
- **Spec-driven scope control**: Edits limited to
  `src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m` (and,
  optionally, one new small helper source file under the same domain folder if the
  canonical-key construction is factored out — decision made at task-authoring time) plus
  `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` and its
  `data/rxnFiles/` fixture directory. Per research R2/R3, `readABRXNFile.m`,
  `checkABRXNFiles.m`, `addBondMappingsRXNFile.m`, `identifyConservedReactingMoieties.m`,
  `identifyConservedReactingSubgraphs.m`, and `extractBondSubgraphs.m` are confirmed to need no
  change and MUST NOT be edited as part of this feature (no order-dependent assumption found in
  any of them). No `external/`, `deprecated/`, or `binary/` path is touched. No migration, no
  new dependency.
- **MATLAB coding standards**: Implementation must avoid `evalc`, warning suppression, and
  `nargin`-driven optional-argument handling; any new `try/catch` must preserve full `ME` stack
  (none is currently anticipated — this is pure data-transformation logic, not I/O or solver
  interaction); diagnostic output stays gated by the existing `options.sanityChecks` convention.
  Before implementation, the implementer must search for any available MATLAB coding/linting
  skill; if none exists, follow the openCOBRA/MATLAB conventions already cited by the
  constitution and the style already established in this function (e.g. `fprintf`-based
  diagnostics, `addvars`/`mapAontoBOld` table idioms).
- **Parameter-setting fidelity**: N/A. This feature does not render code into another language
  or literate document.
- **Artifact placement**: Spec Kit artifacts under `specs/019-canonicalize-bond-node-keys/`.
  Source changes remain under `src/analysis/topology/reactingMoieties/`; test and fixture
  changes remain under `test/verifiedTests/analysis/testReactingMoieties/`. New RXN fixture
  files (sourced per research R6) are committed test fixtures beside the test that consumes
  them, matching the existing `data/rxnFiles/` pattern — not raw data under `data/` at the repo
  root, and not a `.mat`/binary artifact requiring Git LFS. No generated diaries, logs, or
  figures are committed.

**Result**: PASS (initial). No Constitution Check violations are required.

**Post-design re-check**: PASS. Phase 0 research (R1–R7) confirms the fix stays scoped to bond-
node identity construction inside one function, requires no upstream or downstream file changes
beyond the one source file and its existing test, introduces no new public interface or
dependency, and resolves the one open design question (sanity-check severity) via
`/speckit-clarify` rather than expanding scope. The one new item research surfaced — RXN fixture
acquisition for the targeted regression (R6) — is a test-fixture/data task, not a Constitution
Check violation; it is carried into `tasks.md`.

## Project Structure

### Documentation (this feature)

```text
specs/019-canonicalize-bond-node-keys/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── buildAtomAndBondTransitionMultigraph-bond-key.md
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 output (/speckit-tasks; not created by /speckit-plan)
```

### Source Code (repository root)

```text
src/analysis/topology/reactingMoieties/
└── buildAtomAndBondTransitionMultigraph.m
    # optional: a new small helper (e.g. canonicalBondKey.m) in the same folder,
    # decision deferred to /speckit-tasks per research R7

test/verifiedTests/analysis/testReactingMoieties/
├── testConservedReactingMoieties.m
└── data/
    └── rxnFiles/
        ├── r0317.rxn        # existing fixture, unchanged
        ├── ACONTm.rxn       # existing fixture, unchanged
        ├── r0426.rxn        # existing fixture, unchanged
        ├── r1109.rxn        # existing fixture, unchanged
        ├── ELAIDCPT1.rxn    # new fixture (research R6)
        ├── HMR_2634.rxn     # new fixture (research R6)
        └── HMR_2919.rxn     # new fixture (research R6)
```

**Structure Decision**: Single MATLAB-library feature. The fix belongs entirely inside the
reacting-moieties analysis domain because it is specific to bond-graph node identity
construction in `buildAtomAndBondTransitionMultigraph.m` and must preserve that function's
public contract (no signature change) and its downstream consumers' existing behavior. The
existing `testConservedReactingMoieties.m` workflow test remains the primary regression surface,
extended with new fixtures rather than a new test file, per Constitution III-Naming.

## Complexity Tracking

*No Constitution Check violations to justify; this table is intentionally empty.*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| (none) | - | - |
