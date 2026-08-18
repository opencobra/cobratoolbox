# Feature Specification: Canonicalize Bond-Node Keys in Atom/Bond Transition Multigraph Construction

**Feature Branch**: `019-canonicalize-bond-node-keys`

**Created**: 2026-08-18

**Status**: Draft

**Input**: User description: fix a bond-node identity bug in `buildAtomAndBondTransitionMultigraph.m` where the same physical bond of a shared metabolite (confirmed for `crn[c]` across `ELAIDCPT1`, `HMR_2634`, `HMR_2919`) produces two different node keys depending on which reaction's RXN file listed the bond's atom pair first. This inflates the metabolite's bond-graph node count and triggers spurious `Inconsistent directed bond transition multigraph` warnings from the existing N-vs-N2 stoichiometry consistency check. Fix by canonicalizing the bond-node key so it is order-independent, verified with a targeted upstream/downstream investigation (per Constitution Principle VI gate) before any source change, plus a new per-metabolite bond-count sanity check to catch this class of bug earlier.

## Clarifications

### Session 2026-08-18

- Q: What severity should the new per-metabolite bond-count sanity check use when it finds a mismatch? → A: Non-fatal warning (matches existing `options.sanityChecks` style) — pipeline continues, mismatch is logged.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Consistent Bond Identity Across Independently-Generated RXN Files (Priority: P1)

A COBRA Toolbox developer runs the moiety-identification pipeline (`buildAtomAndBondTransitionMultigraph.m`) over a model containing reactions that share a metabolite whose RXN files were generated independently (e.g. `ELAIDCPT1`, `HMR_2634`, `HMR_2919`, all sharing `crn[c]`). Today, a bond listed with its two atoms in reversed order in one RXN file relative to another produces two distinct bond-node identities for what is physically the same bond, inflating that metabolite's node count and causing the model-derived stoichiometry estimate (`N2`) to diverge from the model's own stoichiometry (`N`). After the fix, the same physical bond always resolves to the same node identity regardless of which reaction's RXN file it was read from, so the metabolite's node count matches its true bond count and the stoichiometry estimates agree.

**Why this priority**: This is the actual defect. Without it, the pipeline emits incorrect diagnostics (`res`/`N2` mismatches) and inflates bond-graph node counts for any metabolite affected by cross-file atom-order instability, undermining trust in the multigraph's correctness for every reaction that touches such a metabolite.

**Independent Test**: Can be fully tested by rebuilding `dBTM` for a small model containing exactly `ELAIDCPT1`, `HMR_2634`, and `HMR_2919`, and confirming `crn[c]` resolves to exactly 25 bond nodes (its true bond count from its own MOL block) rather than 31, with no `Inconsistent directed bond transition multigraph` warning for any of the three reactions.

**Acceptance Scenarios**:

1. **Given** a metabolite whose bonds are listed with reversed atom order in one RXN file relative to another reaction sharing that metabolite, **When** `buildAtomAndBondTransitionMultigraph.m` builds the directed bond transition multigraph, **Then** the metabolite's bond nodes in `dBTM.Nodes` number exactly its true bond count (no duplicate nodes for the same physical bond).
2. **Given** the same scenario, **When** the existing `N`-vs-`N2` stoichiometry consistency check runs for the affected reactions, **Then** it no longer reports a mismatch caused by inflated node/bond counts for that metabolite.
3. **Given** `dBTM.Edges` for two different reactions that both touch the same physical bond of a shared metabolite, **When** each reaction's edges are filtered to that bond, **Then** both reactions reference the same bond-node identity (the same `BondIndex`/node key).

---

### User Story 2 - No Regression For Unaffected Metabolites, Reactions, Or Downstream Consumers (Priority: P2)

A COBRA Toolbox developer or downstream script relies on `dBTM.Nodes`, `dBTM.Edges`, and the matrices derived from them (`M2BiE`, `M2BiW`, `BTi2R`, `BTiE`) for metabolites and reactions that are not affected by the bond-key bug, and on the double/triple-bond edge-multiplicity behavior that is already correct. After the fix, none of that existing, correct behavior changes — including which side of an edge represents the substrate vs. the product, and which bond-type instance produces which edge.

**Why this priority**: The fix touches identity-string construction used throughout the multigraph; a correction that is too broad could silently alter output for metabolites and downstream consumers that were never buggy, turning a bug fix into a regression.

**Independent Test**: Can be tested by rebuilding `dBTM` before and after the fix for reactions/subsystems known to be sensitive from prior debugging on this pipeline (symmetric-molecule cases such as CoA in `AKGDm`/`CSm`; the `tyr`, `bileacid`, `pufa` subsystems previously fixed for the `extractBondSubgraphs` component-merge bug) and confirming their node counts, edge counts, and any known-good diagnostic outputs are unchanged.

**Acceptance Scenarios**:

1. **Given** a metabolite whose bond-node keys were already consistent across all reactions that reference it, **When** the fix is applied, **Then** its bond-node count, node keys, and edge structure in `dBTM` are unchanged.
2. **Given** a bond with `BondType` greater than 1 (double/triple bond) that legitimately produces multiple edges collapsing onto one node, **When** the fix is applied, **Then** the same multiplicity and node-collapsing behavior is preserved.
3. **Given** a `dBTM` edge whose `HeadBond`/`TailBond` encode which molecule instance is the reaction substrate vs. product, **When** the fix canonicalizes the within-bond atom head/tail order, **Then** the edge's substrate-vs-product (reaction-direction) assignment is unchanged.
4. **Given** any identified downstream consumer of the changed node/edge fields (e.g. `identifyConservedReactingMoieties.m`, `identifyConservedReactingSubgraphs.m`, `extractBondSubgraphs.m`, or any other consumer found during investigation), **When** it is re-run on a model containing a previously-affected metabolite, **Then** its output changes only in the ways attributable to the intended correction (e.g. corrected node counts) and not in any other respect.

---

### User Story 3 - Fail Fast On Future Bond-Node Identity Bugs (Priority: P3)

A COBRA Toolbox developer building `dBTM` for any model receives an immediate, per-metabolite signal if a metabolite's bond-graph node count ever again disagrees with its own true bond count, instead of discovering the problem indirectly, several reactions later, as a fractional stoichiometry mismatch.

**Why this priority**: This is a guard against recurrence, not the fix itself; it improves diagnosability for this whole class of bug (including bugs the current fix doesn't anticipate) but delivers no value on its own without User Story 1.

**Independent Test**: Can be tested by deliberately constructing (or reusing a fixture representing) a metabolite whose bond-graph node count does not match its molfile-derived bond count, and confirming the sanity check flags it immediately after `dBTM` construction, without requiring a downstream stoichiometry comparison to notice.

**Acceptance Scenarios**:

1. **Given** `dBTM` has been constructed for a model, **When** the per-metabolite sanity check runs, **Then** every atom/bond-mapped metabolite's distinct bond-node count is compared against its own true bond count read once from its canonical RXN-file molblock.
2. **Given** a metabolite whose node count matches its true bond count, **When** the sanity check runs, **Then** no diagnostic is emitted for that metabolite.
3. **Given** a metabolite whose node count does not match its true bond count, **When** the sanity check runs, **Then** a non-fatal warning identifying the metabolite and the mismatch is emitted, consistent with the existing `options.sanityChecks` diagnostic style, and pipeline execution continues.

### Edge Cases

- A bond connects two atoms belonging to different metabolites (e.g. a bond to a reaction's hardcoded energy node, whose `AtomNumber` is always `1`) — canonicalization must resolve ordering via metabolite identity, not atom number, since atom number alone cannot disambiguate this case.
- A metabolite has a double or triple bond, which `addBondMappingsRXNFile.m` deliberately splits into multiple bond-transition rows — canonicalization must not create additional spurious nodes for these legitimate multi-edge bonds, nor collapse genuinely distinct bonds together.
- A metabolite appears in only one reaction (no cross-file atom-order instability possible) — its behavior must be unchanged by the fix.
- A metabolite's atom numbering itself is found to be unstable across independently-generated RXN files (not just its bond row order) — this is a more severe condition than the confirmed bug and must be detected and reported distinctly from the ordinary bond-key mismatch, since it would invalidate atom-number-based canonicalization for that metabolite.
- Two genuinely different bonds of the same metabolite (e.g. C1–C7 and C1–N10) must remain distinguishable after canonicalization — collapsing them onto the same key would be a new, more severe bug than the one being fixed.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The bond-node identity for a given physical bond of a given metabolite MUST be identical regardless of which reaction's RXN file it was read from, and MUST NOT depend on which of the bond's two atoms that RXN file happened to list first.
- **FR-002**: The bond-node identity scheme MUST remain collision-free — two genuinely distinct bonds of the same metabolite (or a bond to a different metabolite/energy node) MUST continue to resolve to distinct identities.
- **FR-003**: Bond-type classification (single/double/triple) and its existing multi-edge-per-node behavior for double/triple bonds MUST be preserved exactly as today.
- **FR-004**: The substrate → product (reaction-direction) assignment of a `dBTM` edge MUST NOT be altered by canonicalizing the within-bond atom head/tail order; only which atom is listed first within a single bond's identity is affected.
- **FR-005**: Any node or edge attribute derived from the bond's head/tail atoms (node key string, head/tail atom labels, head/tail atom indices) MUST stay mutually consistent with each other and with the canonicalized identity — no attribute may reflect the pre-canonicalization raw order while another reflects the canonicalized order.
- **FR-006**: For every metabolite and reaction not affected by the cross-file atom-order inconsistency, the multigraph's node count, edge count, node keys, and derived diagnostic outputs MUST be unchanged by this fix.
- **FR-007**: For every downstream consumer of the changed node/edge fields (including but not limited to `identifyConservedReactingMoieties.m`, `identifyConservedReactingSubgraphs.m`, `extractBondSubgraphs.m`, and any additional consumer identified during investigation), the fix MUST NOT change that consumer's output for previously-correct (non-buggy) bonds or metabolites, and any change to previously-buggy metabolites' output MUST be attributable to the intended correction alone.
- **FR-008**: The system MUST provide a per-metabolite sanity check, run once after `dBTM` construction, that independently compares each atom/bond-mapped metabolite's distinct bond-node count in `dBTM.Nodes` against that metabolite's own true bond count read from its canonical RXN-file molblock, and reports any mismatch as a non-fatal warning consistent with the existing `options.sanityChecks` style, without halting pipeline execution.
- **FR-009**: The `N`-vs-`N2` stoichiometry consistency check MUST NOT report a mismatch for any reaction/metabolite pair whose disagreement was solely caused by the cross-file bond-key inconsistency this feature corrects.
- **FR-010**: The fix MUST be deterministic and MUST NOT require any change to upstream RXN-file generation (chemPy/RDT export) — canonicalization occurs entirely within the existing MATLAB pipeline.
- **FR-011**: Before any source change is made, the upstream source of the non-canonical atom order and the full set of downstream consumers of the affected fields MUST be identified and checked for order-dependent assumptions that a canonicalization could silently break, per the Constitution's Spec-Driven Development gate.
- **FR-012**: The feature MUST define the narrowest reproducibility check that proves the fix — rebuilding `dBTM` for a minimal model containing `ELAIDCPT1`, `HMR_2634`, and `HMR_2919` and confirming `crn[c]`'s corrected node count and the absence of its warning.

### Key Entities

- **Bond-Node Identity (Bond Key)**: The string identifier used to represent one physical, undirected bond between two atoms (possibly belonging to different metabolites, e.g. an energy-node bond) as a single row in `dBTM.Nodes`. Must be order-independent with respect to which atom a given RXN file listed first.
- **Directed Bond Transition Multigraph (`dBTM`)**: The graph structure, with `Nodes` (bonds) and `Edges` (bond transitions between a reaction's substrate- and product-side bond instances), built per reaction and merged across reactions sharing metabolites.
- **Metabolite Bond-Count Ground Truth**: The true number of distinct bonds a metabolite has, derived once from its own canonical RXN-file molblock, used as the independent reference for the new sanity check and for scoping which metabolites are affected.
- **Stoichiometry Consistency Check (`N` vs `N2`)**: The existing per-reaction check comparing the model's stoichiometric coefficient for a metabolite against a bond-graph-derived estimate, whose false-positive warnings are the symptom this feature eliminates.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: For a model containing exactly `ELAIDCPT1`, `HMR_2634`, and `HMR_2919`, `crn[c]` resolves to exactly 25 bond-graph nodes, and none of the three reactions produce an `Inconsistent directed bond transition multigraph` warning attributable to `crn[c]`.
- **SC-002**: Across a full network run of the moiety-identification pipeline, the count of `Inconsistent directed bond transition multigraph` warnings decreases relative to the pre-fix baseline, and every remaining warning is manually confirmed to stem from a cause unrelated to bond-node-key ordering.
- **SC-003**: For every metabolite identified as affected during the pre-implementation scoping pass, its post-fix bond-graph node count matches its true bond count from its own molblock.
- **SC-004**: Previously-fixed regression cases (symmetric-molecule handling in `AKGDm`/`CSm`; `tyr`, `bileacid`, `pufa` subsystem behavior) continue to hold after this fix, with no new interaction effects introduced.
- **SC-005**: Every downstream consumer of the affected `dBTM` fields identified during investigation produces output changes, when re-run before vs. after the fix, that are limited to the intended correction (e.g. corrected node/bond counts) with no other behavioral difference.
- **SC-006**: The new per-metabolite bond-node sanity check runs after every `dBTM` construction and correctly distinguishes metabolites with matching node/bond counts (no diagnostic) from metabolites with mismatched counts (non-fatal warning emitted, pipeline continues), verified against at least one known-good and one deliberately-mismatched fixture.

## Assumptions

- Atom numbering is stable across independently-generated RXN files for a given metabolite; this is confirmed directly for `crn[c]` and MUST be re-confirmed not to be a `crn[c]`-specific coincidence during the pre-implementation investigation before the atom-number-based canonicalization design is relied upon network-wide. If atom numbering is found to be unstable for any metabolite, canonicalization for that metabolite's bonds needs a different approach, out of scope for this spec to redesign in advance.
- The RXN-generation toolchain (chemPy/RDT) is out of scope for change; understanding why its row order differs across files is diagnostic only, to rule out a deeper non-determinism, not a target for remediation here.
- `addBondMappingsRXNFile.m` requires no source change, per direct inspection: its formed/broken-bond classification already checks both atom orderings and simply relays the raw order through; this assumption must be reconfirmed if investigation surfaces a consumer with an undiscovered order dependency.
- The three confirmed reactions (`ELAIDCPT1`, `HMR_2634`, `HMR_2919`) and the `crn[c]` metabolite are illustrative of a class of bug that may affect other metabolites/reactions network-wide; the pre-implementation investigation is relied upon to size the actual blast radius rather than this spec presupposing a fixed list.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001, FR-002, FR-009, FR-012, SC-001 | Targeted regression rebuilding `dBTM` for `ELAIDCPT1`, `HMR_2634`, `HMR_2919`; confirm `crn[c]` node count and absence of warning | src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m |
| US1 / FR-005 | Node/edge attribute mutual-consistency check (canonicalized key vs. head/tail atom fields) as part of the fix itself | src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m |
| US2 / FR-003 | Symmetric-atom / double-bond edge-multiplicity check on `ELAIDCPT1`'s C=O bond | src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m |
| US2 / FR-004, FR-006 | Before/after comparison of edge substrate/product assignment and attribute consistency for unaffected metabolites | src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m |
| US2 / FR-006, SC-004 | Subsystem regression: `AKGDm`, `CSm`, `tyr`, `bileacid`, `pufa` | src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m |
| US2 / FR-007, SC-005 | Downstream-consumer regression on `identifyConservedReactingMoieties.m`, `identifyConservedReactingSubgraphs.m`, `extractBondSubgraphs.m` and any consumer found during investigation | src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m, src/analysis/topology/reactingMoieties/identifyConservedReactingSubgraphs.m, src/analysis/topology/reactingMoieties/extractBondSubgraphs.m |
| US3 / FR-008, SC-006 | Per-metabolite bond-node sanity check exercised against a known-good and a deliberately-mismatched fixture | src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m |
| US1 / FR-010, FR-011, SC-002, SC-003 | Full network run of the moiety-identification pipeline; warning-count comparison and blast-radius scoping pass | src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m |
