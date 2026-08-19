# Feature Specification: Canonicalize Bond-Node Keys for Symmetric/Resonance-Equivalent Atom Groups

**Feature Branch**: `020-canonicalize-symmetric-atom-bonds`

**Created**: 2026-08-18

**Status**: Draft

**Input**: User description: after feature 019 (`canonicalize-bond-node-keys`) shipped, re-running `buildAtomAndBondTransitionMultigraph.m` with `options.sanityChecks=1` over a broader random sample of the network surfaces the FR-008 per-metabolite bond-count sanity check that feature 019 itself added, firing on metabolites feature 019 did not cover: `coa[m]`, `coa[x]`, `coa[r]` (each 86 bond-graph nodes vs. a true bond count of 82, confirmed from each metabolite's own RXN-file molblock) and `crn[m]` (29 vs. true 25 — a different compartment instance of carnitine than the `crn[c]` case feature 019 fixed). Independent diagnosis (see `research.md`) confirms this is a distinct bug class from feature 019's: the affected atoms are not reordered file-to-file, they are members of a genuinely symmetric or resonance-equivalent local group within the metabolite itself (e.g. CoA's gem-dimethyl pair, carnitine's three N-methyl groups, carnitine's two resonance-equivalent carboxylate oxygens), so the RXN-file-generation tool assigns different, non-corresponding raw atom numbers to chemically-indistinguishable atoms across independently-generated files. Feature 019's `canonicalBondKey.m` canonicalizes atom order *within* a bond but trusts atom number as a stable cross-file identity anchor for each atom — an assumption that does not hold for these atoms, which is exactly the edge case feature 019's spec flagged as out of scope ("a metabolite's atom numbering itself found unstable across RXN files... would invalidate atom-number-based canonicalization"). Fix by detecting symmetry-equivalence classes of atoms within each metabolite's own molblock and canonicalizing bond-node identity by equivalence class rather than by raw atom number, implemented entirely within the existing MATLAB pipeline (no change to the chemPy/RDT RXN-generation toolchain, per explicit decision — see Assumptions).

## Clarifications

### Session 2026-08-18

- Q: Should the fix for symmetric/resonance-equivalent atoms live upstream (chemPy/RDT atom-mapping generation) or downstream (MATLAB, this repository)? → A: Downstream in MATLAB, consistent with feature 019's precedent and scope. Revisiting the RXN-generation toolchain is out of scope for this feature.
- Q: What should happen with this diagnosis right now? → A: Start this Spec Kit feature (spec.md + research.md) as a starting point for implementation planning in a later session; no source change in this pass.
- Q: For a resonance-equivalent bond where two RXN files record different formal bond types for the same physical bond (FR-003), which value should the canonicalized bond-node record as its bond type? → A: First-seen file wins — the bond type recorded in the first RXN file encountered for that metabolite becomes canonical, mirroring the existing `metBondCountGroundTruth` first-seen precedent (`buildAtomAndBondTransitionMultigraph.m:581-588`).
- Q: If the equivalence-class detection algorithm cannot confidently classify some atoms of a metabolite (an inconclusive automorphism computation, or a malformed/unusual molblock), what should the pipeline do for that metabolite? → A: Warn and fall back — emit a visible, non-suppressed warning (constitution VII-B) naming the metabolite, fall back to feature 019's atom-number-based canonicalization for it, and continue processing every other metabolite; the flagged metabolite may still show an FR-008 mismatch, exactly as it does today pre-fix.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Correct Bond-Node Identity For Metabolites With Symmetric Atom Groups (Priority: P1)

A COBRA Toolbox developer runs the moiety-identification pipeline over a model containing reactions that share a metabolite with a locally symmetric or resonance-equivalent atom group — for example coenzyme A's gem-dimethyl pair (pantoate's two methyl carbons attached to the same central carbon), L-carnitine's three chemically-equivalent N-methyl groups on its quaternary nitrogen, or L-carnitine's two resonance-equivalent carboxylate oxygens. Today, because these atoms are chemically indistinguishable, independently-generated RXN files assign them different, non-corresponding raw atom numbers (and, for the carboxylate case, a different formal bond type — single vs. double — to each of the two equivalent oxygens), so feature 019's atom-number-based canonicalization cannot collapse them onto one bond-node identity: the metabolite's bond-graph node count is inflated above its true bond count (confirmed: `coa[m]`/`coa[x]`/`coa[r]` 86 vs. true 82; `crn[m]` 29 vs. true 25). After the fix, atoms belonging to the same symmetry-equivalence class resolve to the same canonical identity regardless of which RXN file's raw numbering produced them, so every affected metabolite's bond-graph node count matches its true bond count and the FR-008 sanity check (feature 019) no longer fires for these metabolites.

**Why this priority**: This is the actual defect, and it is a different mechanism from feature 019's (already-fixed) bug — it directly undermines the FR-008 sanity check feature 019 added specifically to catch this class of problem, and produces the same category of false-positive `Inconsistent directed bond transition multigraph` warnings and inflated node counts that feature 019 was meant to eliminate.

**Independent Test**: Can be fully tested by rebuilding `dBTM` for a small model containing exactly `PPACOAATREVm`, `HMR_3173`, and `HYPGCOAHLm` (all sharing `coa[m]`), confirming `coa[m]` resolves to exactly 82 bond nodes rather than 86; and separately for a model containing `HMR_2634` and `PPACOAATREVm` (sharing `crn[m]`), confirming `crn[m]` resolves to exactly 25 bond nodes rather than 29.

**Acceptance Scenarios**:

1. **Given** a metabolite with an atom that has one or more chemically-equivalent partners (e.g. a methyl group's three hydrogens, or two methyl groups on the same carbon), **When** independently-generated RXN files assign those equivalent atoms different raw atom numbers, **Then** `buildAtomAndBondTransitionMultigraph.m` resolves bonds to/from those atoms to the same canonical bond-node identity across all such files.
2. **Given** a metabolite with two resonance-equivalent atoms where the formal bond type (single vs. double) to a shared neighbor differs between RXN files, **When** the multigraph is built, **Then** the bond-node identity and its associated bond type are resolved consistently rather than producing two distinct nodes for what is chemically one resonance-averaged bond.
3. **Given** the FR-008 per-metabolite bond-count sanity check (feature 019), **When** it runs after this fix for a previously-affected metabolite, **Then** it reports no mismatch.

---

### User Story 2 - No Regression For Non-Symmetric Metabolites Or Feature 019's Fix (Priority: P2)

A COBRA Toolbox developer relies on `dBTM` output for metabolites with no internal symmetry, and on feature 019's already-verified fix for `crn[c]`'s bond-row-order bug. After this fix, neither is altered: non-symmetric metabolites' node counts, keys, and edges are unchanged, and `crn[c]` across `ELAIDCPT1`/`HMR_2634`/`HMR_2919` continues to resolve to exactly 25 nodes with no warning.

**Why this priority**: Symmetry-class detection is inherently more aggressive than feature 019's simple order-canonicalization; an overly broad equivalence-class detector could incorrectly merge genuinely distinct atoms/bonds, which would be a more severe regression than the bug being fixed (mirrors feature 019's FR-002/User Story 2 concern, one level up).

**Independent Test**: Rebuild `dBTM` before and after the fix for feature 019's existing regression fixtures (`r0317`/`ACONTm`/`r0426`, the `crn[c]` 3-reaction case, and the `AKGDm`/`CSm`/`tyr`/`bileacid`/`pufa` cases referenced in feature 019) and confirm node counts, edge counts, and keys are byte-for-byte unchanged for every metabolite without a genuine symmetry class.

**Acceptance Scenarios**:

1. **Given** a metabolite with no atoms sharing a symmetry-equivalence class, **When** the fix is applied, **Then** its bond-node count, keys, and edges are unchanged.
2. **Given** two atoms of the same metabolite that happen to share an element and similar local environment but are **not** truly symmetry-equivalent (e.g. distinguishable by their position in the larger molecular graph), **When** the fix is applied, **Then** they are NOT merged into the same equivalence class, and remain distinct bond-node identities (collision-free, mirrors feature 019 FR-002).
3. **Given** `crn[c]` across `ELAIDCPT1`/`HMR_2634`/`HMR_2919` (feature 019's fixed case), **When** rebuilt after this fix, **Then** it still resolves to exactly 25 nodes with no warning.

---

### User Story 3 - Scope The Full Blast Radius Before Implementation (Priority: P3) — SATISFIED, see FR-009

A COBRA Toolbox developer needs to know how many other metabolites in the network carry an undetected symmetric or resonance-equivalent atom group before designing the canonicalization approach, since the three groups confirmed so far (CoA's gem-dimethyl, carnitine's trimethylammonium, carnitine's carboxylate) were found only because they happened to appear in the 75-reaction random sample already investigated, not through an exhaustive search.

**Why this priority**: Without this scoping, an implementation tuned only to the three known cases risks missing the general pattern (e.g. other fatty-acyl or resonance-bearing metabolites elsewhere in the network) and merely trading three specific warnings for a differently-shaped set of remaining ones.

**Independent Test**: Run the FR-008 sanity check (feature 019) with `options.sanityChecks=1` across the full network (or a materially larger random sample than 75 reactions) and catalogue every metabolite that mismatches, before finalizing the implementation's design.

**Acceptance Scenarios**:

1. **Given** the full network (or a large random sample), **When** the FR-008 sanity check runs pre-fix, **Then** every mismatching metabolite is catalogued with its actual vs. true bond-node count.
2. **Given** that catalogue, **When** each mismatching metabolite's RXN files are inspected, **Then** each is classified as either an instance of this symmetry/resonance bug class or a distinct, separately-scoped issue.

### Edge Cases

- A metabolite has more than one independent symmetry-equivalence class (confirmed: `crn[m]` has both a 3-fold-equivalent trimethylammonium group and a 2-fold-equivalent carboxylate) — the detection and canonicalization must handle multiple, independent classes within one molecule correctly and simultaneously.
- Only a subset of an equivalence class's members are swapped between two given RXN files, not a full rotation (confirmed for CoA: one hydrogen per methyl, e.g. H49/H52, stays put as an anchor while H50/H51 and H53/H54 trade places) — canonicalization must not assume swaps are complete permutations of the whole class.
- A resonance-equivalent bond's formal bond type (single vs. double) differs between the two RXN-file representations of the same physical/resonance-averaged bond (confirmed: carnitine's carboxylate C=O is recorded against atom 3 in one file and atom 6 in the other) — canonicalization must reconcile bond type consistently, not just atom-number order; per FR-003, the first-encountered RXN file's bond type is canonical.
- Two atoms of the same element with superficially similar local bonding are genuinely distinguishable (not symmetry-equivalent) by their position elsewhere in the molecular graph — an over-aggressive equivalence-class detector must not merge them (would be a new, more severe bug, mirroring feature 019's final edge case one level up).
- A metabolite's true bond count (the FR-008 ground truth, feature 019) must remain achievable as the post-fix node count — canonicalizing by equivalence class must actually make node count equal true bond count, not merely suppress the sanity-check warning by another route.
- An atom transition number (`atomTransitionNrs`, distinct from the raw MOL-block row number `metNrs`/atom number) exists per reaction and is not itself a stable cross-file identity for a given atom of a metabolite (it numbers atoms 1:q per reaction, not per metabolite) — must not be assumed usable as a substitute stable key without verification.
- The equivalence-class detection algorithm is inconclusive for a metabolite (e.g. an ambiguous/non-terminating automorphism computation, or a malformed or unusual molblock it cannot classify) — per the Clarifications above, the system must emit a visible warning naming the metabolite, fall back to feature 019's atom-number-based canonicalization for that metabolite only, and continue processing every other metabolite without halting.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST identify, for each metabolite, groups of atoms that are symmetry-equivalent or resonance-equivalent within that metabolite's own canonical structure (i.e. interchangeable without changing the physical molecule), independent of any single RXN file's arbitrary atom numbering.
- **FR-002**: Bond-node identity for two atoms belonging to the same symmetry-equivalence class MUST resolve to the same canonical identity regardless of which RXN file's raw atom numbering produced them, including when only a subset of the class's members are swapped between two files (not necessarily a full-class rotation).
- **FR-003**: For a resonance-equivalent bond whose formal bond type (single/double/triple) differs between two RXN-file representations of the same physical bond, the system MUST resolve bond-node identity and bond type consistently rather than producing distinct nodes per representation. The canonical bond type MUST be the bond type recorded in the first RXN file encountered for that metabolite (first-seen wins), consistent with the existing `metBondCountGroundTruth` first-seen precedent (`buildAtomAndBondTransitionMultigraph.m:581-588`); it MUST NOT vary based on which file happens to be processed later or introduce a new bond-type value outside the existing single/double/triple domain.
- **FR-004**: The equivalence-class detection MUST remain collision-free — atoms or bonds that are not genuinely symmetry-equivalent MUST NOT be merged into the same canonical identity (mirrors feature 019 FR-002, applied to whole equivalence classes rather than single bonds).
- **FR-005**: The system MUST support metabolites with multiple, independent symmetry-equivalence classes within the same molecule (e.g. carnitine's trimethylammonium and carboxylate groups simultaneously).
- **FR-006**: For every metabolite with no symmetry-equivalence class, and for feature 019's already-fixed `crn[c]` case and existing regression fixtures, the multigraph's node count, edge count, node keys, and derived diagnostic outputs MUST be unchanged by this fix.
- **FR-007**: After the fix, the FR-008 per-metabolite bond-count sanity check (feature 019) MUST report no mismatch for `coa[m]`, `coa[x]`, `coa[r]`, and `crn[m]` when built from the RXN files that currently trigger it (`PPACOAATREVm`/`HMR_3173`/`HYPGCOAHLm` for `coa[m]`; the corresponding sets for `coa[x]`/`coa[r]`; `HMR_2634`/`PPACOAATREVm` for `crn[m]`).
- **FR-008**: The fix MUST be implemented entirely within the existing MATLAB pipeline (`buildAtomAndBondTransitionMultigraph.m` and/or new helper functions alongside `canonicalBondKey.m`), and MUST NOT require any change to the chemPy/RDT RXN-file-generation toolchain — per explicit product decision (see Clarifications), even though an upstream fix is also possible in principle.
- **FR-009**: Before implementation, the full network (or a materially larger sample than the 75 reactions already investigated) MUST be scanned with the existing FR-008 sanity check to catalogue every metabolite affected by this bug class, so the implementation is designed against the true blast radius rather than only the three groups (CoA gem-dimethyl, carnitine trimethylammonium, carnitine carboxylate) confirmed so far. **Status: done.** A standalone script (`experiments/moietySizing/scan_symmetric_atoms.py`) reproducing the FR-008 check outside MATLAB scanned the full 16,485-file corpus in 10 seconds and found 1,998 mismatched metabolite instances (1,171 distinct base metabolites, ~16.7% of all 11,940 metabolites seen) — see `research.md` R4 for the full report and caveats. This is a materially larger blast radius than the four instances found by hand, and includes highly symmetric molecules (squalene, myo-inositol, spermine, diadenosine tetraphosphate, oxidized glutathione) beyond the CoA/carnitine cases.
- **FR-010**: For every downstream consumer of the changed node/edge fields (`identifyConservedReactingMoieties.m`, `identifyConservedReactingSubgraphs.m`, `extractBondSubgraphs.m`, and any additional consumer identified during investigation, per feature 019 FR-007), this fix MUST NOT change that consumer's output for previously-correct (non-symmetric) metabolites, and any change to previously-affected symmetric metabolites' output MUST be attributable to the intended correction alone.
- **FR-011**: If equivalence-class detection is inconclusive for a given metabolite (e.g. an ambiguous or non-terminating automorphism computation, or a malformed/unusual molblock), the system MUST emit a visible, non-suppressed warning naming the metabolite (per constitution VII-B), fall back to feature 019's atom-number-based canonicalization for that metabolite only, and MUST continue processing every other metabolite without halting the run.

### Key Entities

- **Symmetry-Equivalence Class**: A set of two or more atoms within one metabolite's own canonical molecular structure that are chemically interchangeable (by molecular symmetry, e.g. CoA's two methyl carbons, or by resonance, e.g. carnitine's two carboxylate oxygens), such that different, non-corresponding raw RXN-file atom numbers may legitimately be assigned to different members of the class across independently-generated files.
- **Canonical Atom Rank**: A deterministic tie-break assigned to each member of a symmetry-equivalence class (e.g. by a stable secondary sort key not subject to the same instability) so that bond-node identities constructed from class members resolve consistently, extending feature 019's `canonicalBondKey.m` scheme from raw-atom-number ordering to equivalence-class-aware ordering.
- **Metabolite Bond-Count Ground Truth**: (from feature 019) the true number of distinct bonds a metabolite has, read once from its own canonical RXN-file molblock; this feature's success is measured by making the post-fix node count equal this existing ground truth for the newly-affected metabolites.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: For a model containing `PPACOAATREVm`, `HMR_3173`, and `HYPGCOAHLm`, `coa[m]` resolves to exactly 82 bond-graph nodes (its true bond count), with no FR-008 sanity-check warning.
- **SC-002**: The same holds for `coa[x]` (built from `DDCDATMTCOAHLx`/`FAOXC2442246x`/`PTCA3ZCOAHLx`/`VITEATENCOXCOAxr`) and `coa[r]` (built from `DCA4Z7ZCOAr`/`STCOAATr`): exactly 82 nodes each, no warning.
- **SC-003**: For a model containing `HMR_2634` and `PPACOAATREVm`, `crn[m]` resolves to exactly 25 bond-graph nodes (its true bond count), with no warning.
- **SC-004**: Feature 019's fixed case (`crn[c]` across `ELAIDCPT1`/`HMR_2634`/`HMR_2919`, 25 nodes) and its existing regression fixtures continue to hold unchanged after this fix.
- **SC-005**: A full-network (or materially larger sample) scan with the FR-008 sanity check shows the count of mismatching metabolites attributable to this bug class drop to zero, and any remaining mismatches are manually confirmed to stem from a cause outside this feature's scope.
- **SC-006**: Every downstream consumer identified during investigation produces output changes, before vs. after the fix, limited to the intended correction for previously-affected symmetric metabolites, with no other behavioral difference.

## Assumptions

- The three symmetry-equivalence groups confirmed so far (CoA's gem-dimethyl pair; carnitine's trimethylammonium methyls; carnitine's carboxylate oxygens) are illustrative of the bug class, not an exhaustive list; FR-009's pre-implementation scoping pass (now done — see research.md R4) confirms the actual blast radius is far larger: 1,171 distinct metabolites (~16.7% of the network), including highly symmetric molecules (squalene, myo-inositol phosphates, spermine, diadenosine tetraphosphate, oxidized glutathione) not yet individually diagnosed the way CoA and carnitine were. This scale favors a general, automorphism-based detection approach over a hardcoded pattern list (see research.md R4's closing caveat) but the final implementation approach is still left to the planning phase.
- Per explicit product decision, the fix is scoped to the existing MATLAB pipeline only; the chemPy/RDT RXN-generation toolchain is out of scope for this feature, consistent with feature 019's non-goals, even though a canonical, symmetry-aware atom ranking applied at generation time is a plausible alternative fix location in principle.
- Atom row order *within* a molblock (independent of the symmetry-equivalence issue) remains stable and canonical, as established by feature 019 (re-confirmed here: element sequences are identical row-for-row across every `coa[m]`/`coa[x]`/`coa[r]`/`crn[c]`/`crn[m]` instance checked) — this feature only needs to address atoms that are *symmetry-ambiguous*, not atom ordering in general.
- The `atomTransitionNrs` field (per-reaction atom transition numbering, distinct from the per-molblock atom number) is not assumed to be a ready-made stable identity for a symmetric atom across files without separate verification, since it numbers atoms 1:q per reaction rather than per metabolite.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001, FR-002, FR-005, SC-001, SC-002, SC-003 | Targeted regression rebuilding `dBTM` for the `coa[m]`/`coa[x]`/`coa[r]`/`crn[m]` file combinations; confirm node counts match true bond counts | src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m, src/analysis/topology/reactingMoieties/canonicalBondKey.m (or new equivalence-class helper) |
| US1 / FR-003 | Bond-type consistency check on carnitine's carboxylate (atom 3/6 double-bond swap case) | src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m |
| US2 / FR-004, FR-006, SC-004 | Before/after comparison against feature 019's regression fixtures and non-symmetric metabolites | src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m |
| US2 / FR-010, SC-006 | Downstream-consumer regression on `identifyConservedReactingMoieties.m`, `identifyConservedReactingSubgraphs.m`, `extractBondSubgraphs.m` | src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m, src/analysis/topology/reactingMoieties/identifyConservedReactingSubgraphs.m, src/analysis/topology/reactingMoieties/extractBondSubgraphs.m |
| US3 / FR-009, SC-005 | Full-network (or large-sample) FR-008 sanity-check scan, pre- and post-fix | src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m |
| US1 / FR-008 | Implementation location review (MATLAB-only, no chemPy/RDT change) | src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m, src/analysis/topology/reactingMoieties/canonicalBondKey.m |
| US2 / FR-011 | Fault-injection regression: an inconclusive/malformed molblock triggers a visible warning naming the metabolite, falls back to feature 019's canonicalization for that metabolite only, and does not halt processing of other metabolites | src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m |
