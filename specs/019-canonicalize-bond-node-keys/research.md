# Phase 0 Research: Canonicalize Bond-Node Keys

**Feature**: 019-canonicalize-bond-node-keys
**Input**: specs/019-canonicalize-bond-node-keys/spec.md, FR-011 (mandatory pre-implementation
investigation), Constitution Principle VI gate.

This document resolves the upstream/downstream investigation the spec requires before any
source change, against the current state of the repository (not the spec author's earlier,
separate investigation). Findings below were independently re-verified by reading the live
files and grepping the repository; every citation is a current file:line, not a recollection.

## R1: Root cause and canonicalization sites — confirmed exactly as specced, with precise current line numbers

**Decision**: Canonicalize at the single point where `bondSubstrateID`/`bondProductID` are
built, and propagate the same canonical ordering into every field derived from them, exactly
as the spec's §6.3 table describes. No design change from the spec is needed.

**Rationale**: The bug is structural, not incidental. `dBTM = digraph(EdgeTable)`
(`src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m:637`) auto-creates
one node per distinct string that appears in `EdgeTable.EndNodes`. Those strings are
`bondSubstrateID`/`bondProductID`, built at lines 593–604 directly from
`bondMappings.headAtoms(...)`/`.tailAtoms(...)` — the raw MOL-file row order, with no
canonicalization:

```matlab
% lines 593-598 (verbatim)
bondSubstrateID =[bondMappings.mets{substrateBondNumber}...
    '#' num2str(bondMappings.headAtoms(substrateBondNumber))...
    '#' bondMappings.headAtomElements{substrateBondNumber}...
    '#' bondMappings.mets{substrateBondNumber}...
    '#' num2str(bondMappings.tailAtoms(substrateBondNumber))...
    '#' bondMappings.tailAtomElements{substrateBondNumber}];
```

A bond read as `(atomA, atomB)` by one reaction's RXN file and `(atomB, atomA)` by another's
therefore produces two distinct `dBTM.Nodes` rows for one physical bond. This directly inflates
`M2BiE`/`M2BiW` (built at lines 728–738 by summing every `dBTM.Nodes` row attributed to a
metabolite) and feeds the residual `res` at line 801, which triggers
`warning('Inconsistent directed bond transition multigraph')` at line 823.

Confirmed current line numbers for every site in the spec's §6.3 table (all within 1–2 lines of
the spec's citations; the file has not materially drifted despite two merged bug-fix commits
touching it earlier this month, `97fa32bd0` and `35f6490c8`):

| Site | Current lines | What it builds |
|---|---|---|
| Node-key strings | 593–604 | `bondSubstrateID`, `bondProductID` (used verbatim as `EdgeTable.EndNodes`, line 607–608) |
| Bond-type label strings | 605–606 | `bondSubstrateType`, `bondProductType` (e.g. `'C-O'`) |
| Per-edge head/tail atom fields | 612–619 | `HeadBondHeadAtom`/`HeadBondTailAtom`/`TailBondHeadAtom`/`TailBondTailAtom` and their `*Index` counterparts |
| Node-level head/tail atom fields | 651–668 | `dBTM.Nodes.BondHeadAtom`/`BondTailAtom`/`BondHeadAtomIndex`/`BondTailAtomIndex`, assembled via `mapAontoBOld` from the edge-level fields above, then `addvars`'d at line 668 |
| `BondElmts` recompute | 670–674 | Recomputed **per node** from the node's own final head/tail atom indices, not from the raw edge strings — already internally self-consistent per node today; canonicalizing the ID changes what "final" head/tail *is*, but does not introduce a new internal inconsistency here |
| N-vs-N2 consistency check | 798–824 | The check whose false positives are this feature's symptom |
| `checkABRXNFiles` call site | 168 | Unrelated validation (see R2) |
| Energy-node hardcoded `AtomNumber` | 579 | `EnergyNode=table({'E'}', size(dATM.Nodes,1)+1, {model.rxns{i}}', 1, {'E'}', ...)` — 4th column is `AtomNumber`, literal `1` |

**Alternatives considered**: Canonicalizing inside `digraph(EdgeTable)`'s node-collapsing step
itself (e.g. post-processing `dBTM.Nodes.Name` after construction) was considered and rejected —
it would require reverse-engineering which of two possible raw strings a given canonical node
corresponds to for every edge, duplicating exactly the work `canonicalBondKey` already does more
directly, with more surface area for the node/edge fields to disagree (violates FR-005).

## R2: Upstream files — no better/earlier place to canonicalize, no interaction hazard

**Decision**: Keep canonicalization entirely inside
`buildAtomAndBondTransitionMultigraph.m`, per the spec's Non-Goal G3. No change to
`readABRXNFile.m`, `checkABRXNFiles.m`, or `addBondMappingsRXNFile.m`.

**Rationale**:

- `readABRXNFile.m:196–208` parses MOL connection-table bond rows in file order into
  `bHeadAtom`/`bTailAtom` with zero reordering or normalization (`headAMetNrs=str2num(bondLine(1:3)); tailAMetNrs=str2num(bondLine(4:6));`,
  stored verbatim). Lines 254–267 only attach element/transition-number lookups per existing
  head/tail number — no row reordering. There is no earlier point upstream where
  canonicalizing once would be more natural; the row order genuinely originates in the RXN
  file itself (out of scope per spec Non-Goals, G3/G5).
  - **Unrelated finding, noted for awareness only**: `readABRXNFile.m:148–180` contains a
    pre-existing, deliberate assertion (`readABRXNFile:blockOrderMismatch`, added in already-merged
    commit `adb94a8ed`) that `$MOL` block order matches the reaction-formula header order — a
    *metabolite-block* identity safeguard, unrelated to bond-atom-pair order within one block.
    No interaction with this fix.
- `checkABRXNFiles.m` (301 lines, read in full) validates atom-transition-number ordering
  (lines 215–232), elemental conservation (236–260), and bond-transition **counts**
  (`nTotalBondTransitions`, line 264) — never which atom within a bond is head vs. tail. No
  order-dependent validation exists here to interact with the fix.
- `addBondMappingsRXNFile.m:125,134` (verbatim): `...|((bondMappings.headAtomTransitionNrs==vb(i))&(bondMappings.tailAtomTransitionNrs==ub(i))&(bondMappings.isSubstrate))); %the order of atoms in the bonds is not important.`
  Both the broken-bond loop (122–130) and formed-bond loop (132–140) check both `(head,tail)`
  and `(tail,head)` combinations explicitly. The `bTypes>1` split into multiple
  `bondTypeInstance` rows is confirmed at lines 95–114 (`type=2` → exactly 2 rows). Spec's
  "Resolved (not a bug)" characterization of this file is accurate; no change needed.

**Alternatives considered**: Fixing the RXN-generation toolchain (chemPy/RDT) so atom-pair row
order is stable at the source was considered and rejected per spec Non-Goals — it is outside
this repository, would not help already-generated RXN files already in `~/fork-ctf`, and the
MATLAB-side fix is strictly more general (it also protects against any *future* reordering,
not just the one currently observed).

## R3: Downstream consumers — the full set is confirmed, and none has an order-dependent assumption

**Decision**: No consumer-side change is required beyond the canonicalization itself. FR-007/G5
("no downstream consumer silently changes behavior beyond the intended correction") holds
structurally today, contingent only on the count-based effects covered by R4.

**Rationale**: Repo-wide grep (`src/`, `test/`, and elsewhere `.m` files live) for every field
the spec's §3.2 flags confirms the candidate list in the spec is complete — no other file reads
`dBTM.Nodes.Bond`/`.BondHeadAtom`/`.BondTailAtom`/`.BondHeadAtomIndex`/`.BondTailAtomIndex`,
`dBTM.Edges.HeadBond`/`.TailBond`/`.HeadBondIndex`/`.TailBondIndex`, or `M2BiE`/`M2BiW`/`BTi2R`/`BTiE`
outside `buildAtomAndBondTransitionMultigraph.m` itself, except:

- **`identifyConservedReactingSubgraphs.m`** (118 lines, read in full): the only other file
  touching `dBTM.Nodes`/`dBTM.Edges` directly.
  - Lines 53–54 use `dBTM.Edges.TailMet`/`.HeadMet` — the **reaction-direction** field
    (substrate-vs-product side, driven by `isSubstrate` in `addBondMappingsRXNFile.m`), which
    is a completely different field from the within-bond atom head/tail order this fix
    touches. Confirmed untouched, matching FR-004.
  - Lines 100–102 and 108 treat `BondIndex` and `[BondHeadAtomIndex; BondTailAtomIndex]` as
    opaque numeric identifiers / an unordered set (`unique([...])`) — order-independent by
    construction.
  - **Verdict: no order-dependent assumption.**
- **`M2BiE`/`M2BiW`/`BTi2R`/`BTiE`**: live only inside the definer function. The only other
  places these names appear at all are
  `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m:53–54` and
  `test/tutorialDerived/analysis/reactingMoieties/tutorial_conservedAndReactingMoieties.m:131`,
  where they are captured as unused destructured outputs and never read afterward. **No live
  consumer exists outside the definer.**
- **`identifyConservedReactingMoieties.m`** (1720 lines): does **not** read `dBTM` at all
  (`grep 'dBTM\.'` → zero hits). It consumes `BG`, whose edges are built directly from
  `dBTM.Nodes.BondHeadAtomIndex`/`.BondTailAtomIndex` at line 690, and its own derived
  `BondIndex`. The previously-fixed CRB2R logic (lines 1580–1638, the "CRB2R over-attribution"
  bug referenced in the spec's Non-Goals) checks both atoms against both head and tail of every
  atom transition symmetrically (`involved = (headATM==a1 | tailATM==a1 | headATM==a2 | tailATM==a2)`,
  line ~1590s) — fully unordered-pair treatment. `moietyBondIndex` logic (1118–1149) compares
  moiety membership of the two endpoints symmetrically. **Verdict: no order-dependent
  assumption**, despite being the deepest and most complex consumer in scope.
- **`extractBondSubgraphs.m`**: named in the spec's candidate list; has zero test coverage in
  the repo (confirmed via `grep -rl "extractBondSubgraphs" test/` → no hits) despite being
  called from `identifyConservedReactingMoieties.m` and despite an already-merged fix earlier
  this month (`196399431`, "Fix extractBondSubgraphs subgraph() crash on bond-cleaving
  reactions"). No direct `dBTM` field access was found in this file either — it operates on
  `BG`/`arm` structures already abstracted away from the raw node/edge strings.

**Alternatives considered**: A broader defensive rewrite of all three downstream consumers "just
in case" was considered and rejected — Constitution Principle V (scope control) and this
feature's G4/Non-Goals both require staying within the smallest coherent change; since no
order-dependence was found, touching these files would be unjustified scope expansion.

## R4: Atom-numbering stability generalization and blast-radius scoping — cannot be fully resolved by static reading; downgraded to a runtime-checked invariant

**Decision**: Do not attempt to prove atom-numbering stability network-wide by static analysis
(it cannot be — it is a property of exported RXN file content, not of this repository's
MATLAB source). Instead, rely on the new per-metabolite sanity check (spec FR-008, this
feature's own deliverable) as the runtime guard: if atom numbering for some metabolite turns
out to still be unstable after this fix, that metabolite's bond count will *still* disagree
with its molfile bond count, and the new warning will surface it immediately, distinctly from
the ordinary reversed-atom-order case this feature targets (per spec Edge Cases, bullet 4).
Do not block this feature on first exhaustively proving atom-number stability for every
metabolite in the network — that would require running the full pipeline against real models,
which is an implementation/validation-time activity (spec §8, test plan items 4 and 6), not a
planning-time one.

**Rationale**: `crn[c]`'s atom numbering is confirmed stable directly (identical
`(atomNumber, element)` tables read from `ELAIDCPT1` and `HMR_2919`'s RXN files, established in
the spec's own prior investigation and not re-litigated here — this is data, not code, so it
cannot be re-verified by reading `.m` files). Whether this generalizes to every other
metabolite in the network is an empirical question about the `~/fork-ctf` RXN corpus, not a
question the MATLAB pipeline's logic can answer statically. The pipeline's own existing
`options.sanityChecks` blocks (lines 708–722, 755–795) already establish the precedent of
catching structural anomalies (reordering, zero-column/row incidence, disconnected bonds) as
runtime checks rather than static guarantees — this feature's new check (FR-008) fits the same
pattern and is the correct place to catch an atom-numbering anomaly if one exists.

**Alternatives considered**: Blocking this feature until a full network run against real RXN
files proves atom-number stability everywhere was considered and rejected — it would gate a
correctness fix on infrastructure (real HMR/Recon3D RXN file access, a MATLAB+solver
environment) not required to *implement* the fix correctly, and the new sanity check already
provides the safety net the spec's Edge Cases section asks for. This scoping question is
carried forward into the test plan (R6) as an explicit task, not silently dropped.

## R5: Sanity-check severity — resolved via `/speckit-clarify`

**Decision**: Non-fatal warning via `fprintf`/`warning`, gated by `options.sanityChecks`
(default on), consistent with the existing blocks at lines 708–722, 716–722, and 755–795, none
of which are hard errors except the incidence-matrix structural checks at 758/762/767/772
(which check a different, more fundamental invariant — every column/row must be non-zero and
have exactly two entries — and are pre-existing, out of scope to change here).

**Rationale**: Recorded in spec.md's Clarifications section (2026-08-18): "Non-fatal warning
(matches existing `options.sanityChecks` style) — pipeline continues, mismatch is logged."
Matches FR-008 as amended.

## R6: Regression-test fixture availability — resolved during implementation with MATLAB-verified real data (supersedes the Phase 0 plan below)

**Decision (as planned at Phase 0)**: The three reactions the spec's targeted regression
(SC-001, test plan item 1) and `crn[c]` depend on — `ELAIDCPT1`, `HMR_2634`, `HMR_2919` — did
not exist as RXN files anywhere in this repository at planning time, and neither did `crn[c]`
(repo-wide grep for these four identifiers returned zero hits). The plan was to vendor them from
`opencobra/ctf` per the function's own docstring
(`buildAtomAndBondTransitionMultigraph.m:70–71`): `git clone https://github.com/opencobra/ctf
~/fork-ctf; RXNFileDir = ~/fork-ctf/rxns/atomMapped`.

**Correction made during implementation**: The public `opencobra/ctf` GitHub repo's
`rxns/atomMapped/` files for `ELAIDCPT1`/`HMR_2634`/`HMR_2919` were fetched first, but their
`crn[c]` MOL blocks are **byte-identical across all three files** — no reversed atom order
exists in that data, so it does not reproduce the bug (confirmed both by a raw diff and by
actually running `buildAtomAndBondTransitionMultigraph` against them: `crn[c]` already resolves
to 25 nodes pre-fix with the public data — nothing to fix). The real, MATLAB-verified
reproduction data lives at `rxns/atomMapped_standardised/` in the **private**
`gitlab.com/recon4imd/ctf` repository (a locally-generated, chemPy/RDT-wrapped,
atom-number-canonicalized-but-not-bond-order-canonicalized export — consistent with the §3.1
hypothesis about RDT export non-determinism), paired with the `vmh2_reconx_for_atom_mapping.mat`
model (not `Recon3D_301.mat` — the public data's metabolite names for the non-`crn[c]`
reactants/products, e.g. `od2coa[c]`/`elaidcrn[c]`, do not match this model's
`ocdcacoaE[c]`/`eldccrn[c]`/`hdca2Ecrn`/`hcsa17Zcrn` naming). Running the pipeline against this
real data reproduces the bug exactly: `crn[c]` resolves to 31 nodes pre-fix, atom numbering for
`crn[c]` is confirmed stable across all three files (`readABRXNFile` output compared directly),
and the `N`-vs-`N2` residual matches the spec's Problem Statement numbers exactly (`N=-1`,
`N2=-0.787879`, `res=-7`) for all three reactions.

**Fixture actually vendored**: Per Constitution Principle III ("Tests MUST... avoid internet
access"), the test cannot fetch from either the public or private `ctf` repo at run time.
Instead:
- The three real RXN files (`ELAIDCPT1.rxn`, `HMR_2634.rxn`, `HMR_2919.rxn`, sourced from
  `atomMapped_standardised`) are committed under
  `test/verifiedTests/analysis/testReactingMoieties/data/rxnFiles/`, alongside the existing
  `r0317.rxn`/`ACONTm.rxn`/`r0426.rxn`/`r1109.rxn`. These are standardised outputs with a
  different atom-numbering scheme and different sibling-metabolite names than the public
  `opencobra/ctf` release of the same reaction IDs — do not conflate the two sources.
- Rather than committing the full 2.4MB `vmh2_reconx_for_atom_mapping.mat` model, a minimal
  10-metabolite/3-reaction submodel was extracted once (`extractSubNetwork` on the three
  reactions) and saved as a small, self-contained 21KB fixture:
  `test/verifiedTests/analysis/testReactingMoieties/data/crnBondKeySubmodel.mat`. Loading this
  fixture fresh and rebuilding `dBTM` against the vendored RXN files independently reproduces
  the same pre-fix result (31 nodes, warning, `res=-7`), confirming the fixture is
  self-contained and does not depend on the external model or either `ctf` repo at test time.

**Alternatives considered**:
- *Hand-author a minimal synthetic fixture* — rejected once real, MATLAB-verified reproduction
  data was located; unnecessary since the real `crn[c]` case is now available and self-contained.
- *Vendor the full `vmh2_reconx_for_atom_mapping.mat` (2.4MB)* — rejected in favor of a minimal
  extracted submodel (21KB), consistent with the existing `Recon3D_301.mat` precedent of using a
  pre-reduced model and Principle IX's preference for minimal test fixtures.
- *Use the public `opencobra/ctf` RXN files* — rejected; verified not to reproduce the bug.

## R7: Test placement — extend the existing workflow test, per Constitution III-Naming

**Decision**: Add new assertions to the existing
`test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` rather than
creating a new test file.

**Rationale**: This is the **only** automated test touching
`buildAtomAndBondTransitionMultigraph.m` (confirmed via repo-wide grep for the function name
under `test/`); no `testBuildAtomAndBondTransitionMultigraph.m` exists. Constitution
III-Naming explicitly requires: "When characterization work needs to pin behaviour of a
function that already has a test, the new assertions MUST be added to that function's existing
test file; a second, differently-named file for the same function MUST NOT be created." The
existing test's own header (lines 1–16) documents it as an intentional multi-function workflow
test spanning `buildAtomAndBondTransitionMultigraph`, `identifyConservedReactingMoieties`,
`identifyConservedReactingSubgraphs`, `buildReactingMoietyTables`, `displayReactingMoieties`,
`createMoietyGraph`, and `getMetMoietySubgraphs` together — consistent with treating it as the
single home for pipeline-level regression coverage, including this fix's targeted regression
and the new sanity-check assertions. `addBondMappingsRXNFile.m` also has no dedicated test file
and is only covered indirectly through this same test — same placement rule applies if any
assertion needs to target it directly.

`extractBondSubgraphs.m` has zero existing coverage; this feature does not change that file
(R3 confirms no order-dependence there) and adding coverage for it is out of scope (spec
Non-Goals) unless implementation surfaces a concrete need.

**Alternatives considered**: A new, separate test file scoped narrowly to this bug (e.g.
`testCanonicalBondKey.m` for a standalone helper, if one is introduced) was considered. If
implementation introduces a small, independently unit-testable helper function (as the
originating investigation suggested, though the plan does not mandate a specific helper name —
see spec Key Entities), that helper is a **new** source function under
`src/analysis/topology/reactingMoieties/`, and Constitution III-Naming's one-file-per-function
rule would apply to it *directly* — a `test<HelperName>.m` file would be correct and required
for that new function specifically, while the *integration* assertions (node counts, warning
absence, downstream-consumer stability) still belong in `testConservedReactingMoieties.m`. This
distinction is deferred to the design decision made during Phase 1/tasks, not fixed here.

## Summary of resolved unknowns

| Spec section | Status after R1–R7 |
|---|---|
| §3.1 upstream trace | Resolved (R1, R2) — no upstream fix opportunity, no interaction hazard |
| §3.2 downstream consumers | Resolved (R3) — complete consumer list confirmed, none order-dependent |
| §3.3 blast-radius scoping | Partially deferred to implementation/validation (R4) — cannot be resolved by static reading; runtime sanity check is the safety net |
| §9 atom-numbering generalization | Downgraded from a blocking pre-condition to a runtime-checked invariant (R4) |
| §9 sanity-check severity | Resolved via `/speckit-clarify` (R5) |
| §8 fixture availability | New finding, not anticipated by the spec (R6) — real gap requiring new fixture acquisition |
| Test placement | Resolved (R7) — existing `testConservedReactingMoieties.m`, per Constitution III-Naming |
