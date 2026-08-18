# Implementation Plan: Canonicalize Bond-Node Keys for Symmetric/Resonance-Equivalent Atom Groups

**Branch**: `020-canonicalize-symmetric-atom-bonds` | **Date**: 2026-08-18 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/020-canonicalize-symmetric-atom-bonds/spec.md`

## Summary

`canonicalBondKey.m` (feature 019, now merged to `develop` — see research R5) canonicalizes a
bond's two `(met, atomNumber, element)` triples by sorting on raw `atomNumber`, on the
presupposition that `atomNumber` is a stable cross-file identity for one physical atom of a
metabolite. That presupposition holds in general (row order/element sequence is stable
file-to-file — feature 019's own finding, reconfirmed here) but fails specifically for atoms that
are chemically interchangeable within their own metabolite: CoA's gem-dimethyl pair, carnitine's
three N-methyl groups, carnitine's two resonance-equivalent carboxylate oxygens, and — per this
feature's FR-009 full-network scoping pass — roughly 1,171 other metabolites (~17% of the
network) with their own symmetric or resonance-equivalent atom groups. Independently-generated
RXN files assign these interchangeable atoms different, non-corresponding raw numbers (and, for
resonance bonds, different formal bond types), so `canonicalBondKey`'s atom-number sort cannot
collapse them onto one bond-node identity, inflating affected metabolites' node counts above
their true bond count and re-triggering the FR-008 sanity check feature 019 added specifically to
catch this class of problem.

The fix (research R6) detects each metabolite's symmetry-equivalence classes once per metabolite
— via iterative color-refinement over that metabolite's own atom-adjacency graph, built with
MATLAB's existing `graph`/`isisomorphic` machinery (already used elsewhere in this domain folder,
no new dependency) — and remaps each class's members to one canonical raw atom number before
`canonicalBondKey` is called, so `canonicalBondKey`'s existing atom-number-based ordering
correctly canonicalizes across files without changing its own signature or tests. A companion
first-seen bond-type cache (research R7) resolves FR-003's resonance bond-type ambiguity
explicitly, and a warn-and-fall-back path (research R9, FR-011) handles metabolites the detector
cannot classify, without halting a run. The whole computation is cached per metabolite (mirroring
the existing `metBondCountGroundTruth` pattern), so cost does not scale with reaction count.

## Technical Context

**Language/Version**: MATLAB, local validation on R2024b+ (COBRA Toolbox baseline); headless
`matlab -batch` in CI (Linux/Docker, Xvfb).

**Primary Dependencies**: COBRA Toolbox reacting-moieties pipeline functions
(`buildAtomAndBondTransitionMultigraph`, `canonicalBondKey`, `readABRXNFile`,
`addBondMappingsRXNFile`, `identifyConservedReactingMoieties`, `identifyConservedReactingSubgraphs`,
`extractBondSubgraphs`, `mapAontoBOld`). MATLAB's built-in `graph`/`digraph` objects and
`isisomorphic`/`isomorphism` functions (base MATLAB Graph and Network Algorithms) for the
equivalence-class detector — already used for a structurally analogous problem in this same
domain folder (`identifyIsomorphicClasses.m`), so no new third-party dependency is introduced. A
MILP solver for the existing workflow test's minimum-set-cover step
(`prepareTest('needsMILP', true)`, already declared).

**Storage**: N/A — in-memory COBRA model structs, MATLAB `table`/`digraph` structures, and static
RXN-file fixtures committed under `test/verifiedTests/analysis/testReactingMoieties/data/`. New
fixtures for `coa[m]`/`coa[x]`/`coa[r]`/`crn[m]` must be vendored from
`~/repos/reconXmoieties/chempy_results/vmh2_reconx_for_atom_mapping/rxnfiles/atomMapped/`
(research R10) — not present in-repo yet, `HMR_2634` excepted (already vendored for feature 019).

**Testing**: Extend `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
with new fixture-backed assertions (`coa[m]`/`coa[x]`/`coa[r]`/`crn[m]` node counts, no FR-008
warning) following the exact `crn[c]`/`crnBondKeySubmodel.mat` pattern feature 019 established
there. A new equivalence-class helper function is new source and requires its own new
`test<FunctionName>.m` file per Constitution III-Naming (research R9) — not a second file for
`canonicalBondKey.m`, whose own `testCanonicalBondKey.m` is unaffected (research R6: its
signature/behavior does not change). A fault-injection assertion for FR-011's fallback path is
added alongside that new test file.

**Target Platform**: Headless MATLAB on Linux, matching the existing test's environment; no
solver-specific behavior beyond the existing MILP requirement.

**Project Type**: MATLAB scientific library, single project.

**Performance Goals**: No performance target beyond preserving current runtime characteristics.
Equivalence-class detection is O(1) amortized per bond at multigraph-build time because it is
computed and cached once per distinct metabolite (mirroring `metBondCountGroundTruth`), not once
per reaction or per file — bounded by the number of distinct metabolites seen (research R6), not
by reaction count. Correctness (matching each metabolite's true bond count) takes priority over
speed; no debug/diagnostic/verification step is made skippable.

**Constraints**: No public interface change to `buildAtomAndBondTransitionMultigraph.m` (signature,
`options.sanityChecks` semantics unchanged) or to `canonicalBondKey.m` (signature unchanged,
research R6); the new equivalence-class remapping MUST NOT alter `dBTM.Edges.HeadMet`/`.TailMet`
(reaction-direction semantics, mirrors feature 019 FR-004); FR-003's bond-type resolution MUST be
first-RXN-file-encountered, explicitly cached (research R7), not left to `mapAontoBOld`'s
incidental Head-before-Tail ordering; FR-011's fallback MUST emit a non-suppressed warning and
continue processing other metabolites, never halt a run; no chemPy/RDT RXN-generation toolchain
change (FR-008); no file created under `experiments/` in this repository — the FR-009 scan
tooling lives in the sibling `reconXmoieties` repository (research R8), out of this feature's
source-edit scope; tests MUST NOT fetch fixtures over the network at run time — fixtures are
vendored, not downloaded during test execution (Constitution III).

**Scale/Scope**: Two primary source files in scope for edits
(`buildAtomAndBondTransitionMultigraph.m`, and a new small helper file for equivalence-class
detection, both under `src/analysis/topology/reactingMoieties/`); `canonicalBondKey.m` is read
but not modified (research R6). One existing test file
(`testConservedReactingMoieties.m`) extended with new fixtures; one new test file for the new
helper function. Per research R4, the true blast radius is ~1,171 metabolites network-wide, but
this feature's targeted regression proof (FR-007, SC-001–003) covers the four confirmed groups
(`coa[m]`, `coa[x]`, `coa[r]`, `crn[m]`) plus the general, non-pattern-specific detection
mechanism (research R6) intended to generalize to the rest without per-metabolite tuning; SC-005's
full-network confirmation re-runs the sibling repository's existing scan script (research R8), not
a new in-repo equivalent.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: Touches bond-graph node identity construction inside
  `buildAtomAndBondTransitionMultigraph.m` — the same diagnostic/topology layer feature 019
  touched, built on top of `model.S`/`model.mets`/`model.rxns` but never reading or writing
  stoichiometry, bounds, objective, or solver-status semantics. The FR-008 sanity check (feature
  019) is a diagnostic residual, not a solver result; making it stop firing for genuinely
  symmetric metabolites is a correctness fix to that diagnostic and to the topology it reports on,
  not a change to any model's scientific meaning. The new equivalence-class detector introduces a
  new mathematical object (graph automorphism / orbit partition of a metabolite's own atom
  adjacency graph) — its domain (atoms of one metabolite, one RXN-derived molblock) and use (a
  canonical-rank remap applied only to bond-node-identity construction) are stated in research R6
  and data-model.md.
- **Testing and reproducibility**: Narrowest proof is `testConservedReactingMoieties.m`, extended
  with fixture-backed assertions for `coa[m]`/`coa[x]`/`coa[r]`/`crn[m]` (spec SC-001–003) plus a
  new `test<FunctionName>.m` file for the new equivalence-class helper (Constitution III-Naming;
  research R9), including a fault-injection assertion for FR-011. Reproducibility commands
  documented in [quickstart.md](./quickstart.md). New RXN fixtures are vendored into the repo
  (research R10), not fetched at test time (Constitution III).
- **User experience and diagnostics**: No new user-facing parameter. `options.sanityChecks`
  (existing, default on) continues to gate the FR-008 check, now correctly silent for symmetric
  metabolites. FR-011's new warning follows the same non-fatal `warning(...)` pattern already used
  by the FR-008 check it sits beside, naming the affected metabolite so a developer can act on it
  (Constitution VII-B: warnings visible, never suppressed).
- **Performance and numerical integrity**: No solver call is added or changed. Equivalence-class
  detection is cached once per distinct metabolite (research R6), not recomputed per reaction —
  negligible relative to existing RXN-file parsing/graph-construction cost even at the ~1,171
  metabolite, ~11,940-metabolite-corpus scale research R4 found. Diagnostic volume is expected to
  *decrease* (fewer FR-008 false positives); FR-011 may occasionally *add* a warning for a
  genuinely inconclusive metabolite, which is intended, visible, and non-fatal. No
  debug/diagnostic/verification step is made skippable.
- **External-solver configuration audit**: N/A — no external solver/library is invoked by this
  feature. (The existing test's minimum-set-cover step uses a MILP solver via
  `identifyConservedReactingMoieties`, unaffected and unchanged by this fix.)
- **Spec-driven scope control**: Edits limited to
  `src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m` and one new
  small helper source file in the same folder (name decided at `/speckit-tasks`), plus
  `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`, its
  `data/rxnFiles/` fixture directory, new `.mat` submodel fixture(s), and one new test file for
  the helper. `canonicalBondKey.m` is read but not edited (research R6 — its existing contract
  already does the right thing once its inputs are class-canonicalized upstream).
  `readABRXNFile.m`, `addBondMappingsRXNFile.m`, `identifyConservedReactingMoieties.m`,
  `identifyConservedReactingSubgraphs.m`, and `extractBondSubgraphs.m` need no change (feature
  019's research R3 finding still holds — none has an order- or count-dependent assumption this
  feature's atom-identity remap would break; to be re-confirmed per FR-010/SC-006 during
  implementation). No `experiments/`, `external/`, `deprecated/`, or `binary/` path is touched
  (research R8). No migration, no new dependency.
- **MATLAB coding standards**: Implementation must avoid `evalc`, warning suppression, and
  `nargin`-driven optional-argument handling; the new helper function follows the openCOBRA header
  convention (VII-E) matching `canonicalBondKey.m`'s own documented style; any new `try/catch`
  (none currently anticipated — pure data-transformation and graph-refinement logic) must preserve
  full `ME` stack. Before implementation, the implementer must search for any available MATLAB
  coding/linting skill; if none exists, follow the openCOBRA/MATLAB conventions already cited by
  the constitution and this function's established idioms (`containers.Map` caching,
  `fprintf`/`warning`-gated diagnostics, `mapAontoBOld` table idioms).
- **Parameter-setting fidelity**: N/A. This feature does not render code into another language or
  literate document.
- **Artifact placement**: Spec Kit artifacts under `specs/020-canonicalize-symmetric-atom-bonds/`.
  Source changes remain under `src/analysis/topology/reactingMoieties/`; test and fixture changes
  remain under `test/verifiedTests/analysis/testReactingMoieties/`, matching the existing
  `data/rxnFiles/` and `data/*.mat` submodel-fixture pattern feature 019 established (not raw data
  under a repo-root `data/`, not a location requiring Git LFS). No file is created under
  `experiments/` in this repository (research R8) — that tooling belongs to, and stays in, the
  sibling `reconXmoieties` repository. No generated diaries, logs, or figures are committed.

**Result**: PASS (initial). No Constitution Check violations are required.

**Post-design re-check**: PASS. Phase 0 research (R5–R10) confirms the fix stays scoped to bond-
node identity construction and its immediate upstream inputs inside one function plus one new
helper, requires no change to `canonicalBondKey.m`'s public contract, no upstream (chemPy/RDT) or
downstream-consumer file changes beyond re-confirmation, no new public interface, and no new
third-party dependency (MATLAB's own graph functions suffice, already precedented in this domain
folder). Two items research surfaced are carried into `tasks.md` as concrete work, not
Constitution Check violations: (1) vendoring new RXN/`.mat` fixtures for
`coa[m]`/`coa[x]`/`coa[r]`/`crn[m]` (research R10), and (2) naming and creating the new helper
function plus its dedicated test file (research R6, R9).

## Project Structure

### Documentation (this feature)

```text
specs/020-canonicalize-symmetric-atom-bonds/
├── spec.md
├── plan.md               # this file
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── symmetry-equivalence-canonicalization.md
└── tasks.md               # Phase 2 output (/speckit-tasks; not created by /speckit-plan)
```

### Source Code (repository root)

```text
src/analysis/topology/reactingMoieties/
├── buildAtomAndBondTransitionMultigraph.m   # extended: remap through equivalence classes
│                                              before canonicalBondKey calls; first-seen bond-type
│                                              cache; FR-011 warn-and-fall-back path
├── canonicalBondKey.m                        # unchanged (research R6) — read, not edited
└── identifyAtomEquivalenceClasses.m          # new: per-metabolite symmetry/resonance
                                                # equivalence-class detection (named at
                                                # /speckit-tasks)

test/verifiedTests/analysis/testReactingMoieties/
├── testConservedReactingMoieties.m           # extended: coa[m]/coa[x]/coa[r]/crn[m] assertions
├── testIdentifyAtomEquivalenceClasses.m      # new: unit coverage for the new helper (Constitution
│                                                # III-Naming), including an FR-011 fault-injection case
└── data/
    ├── crnBondKeySubmodel.mat                # existing fixture (feature 019), unchanged
    ├── <new submodel fixture(s)>.mat         # new: coa[m]/coa[x]/coa[r]/crn[m] submodels
    └── rxnFiles/
        ├── r0317.rxn, ACONTm.rxn, r0426.rxn, r1109.rxn   # existing, unchanged
        ├── ELAIDCPT1.rxn, HMR_2634.rxn, HMR_2919.rxn     # existing (feature 019), unchanged
        ├── PPACOAATREVm.rxn, HMR_3173.rxn, HYPGCOAHLm.rxn        # new (coa[m])
        ├── DDCDATMTCOAHLx.rxn, FAOXC2442246x.rxn,
        │   PTCA3ZCOAHLx.rxn, VITEATENCOXCOAxr.rxn                # new (coa[x])
        └── DCA4Z7ZCOAr.rxn, STCOAATr.rxn                         # new (coa[r]; crn[m] reuses
                                                                     # HMR_2634.rxn + PPACOAATREVm.rxn)
```

**Structure Decision**: Single MATLAB-library feature, in the same reacting-moieties analysis
domain as feature 019 for the same reason: the fix is specific to bond-graph node identity
construction in `buildAtomAndBondTransitionMultigraph.m` and must preserve that function's public
contract and `canonicalBondKey.m`'s existing contract unchanged. The existing
`testConservedReactingMoieties.m` workflow test remains the primary regression surface for the
end-to-end node-count claims (SC-001–004); a new, separate test file covers the new helper
function's own unit-level contract, per Constitution III-Naming.

## Complexity Tracking

*No Constitution Check violations to justify; this table is intentionally empty.*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|---------------------------------------|
| (none) | - | - |
