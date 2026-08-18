# Phase 0 Research: Canonicalize Bond-Node Keys for Symmetric/Resonance-Equivalent Atom Groups

**Feature**: 020-canonicalize-symmetric-atom-bonds
**Input**: specs/020-canonicalize-symmetric-atom-bonds/spec.md, FR-009 (pre-implementation
blast-radius scoping), following the same pre-implementation-investigation discipline as
feature 019.

This document records an investigation carried out entirely by re-parsing the raw RXN files
that trigger feature 019's FR-008 sanity check post-fix, independent of any earlier
conversation or PR — the diagnosis was reproduced from first principles against the current
repository state and the RXN files at
`~/repos/reconXmoieties/chempy_results/vmh2_reconx_for_atom_mapping/rxnfiles/atomMapped/`
(the on-disk source behind `exp_investigate_symmetry_problem.mlx`'s `atomMappedDir`). Every
finding below is backed by a small, self-contained Python script that parses `$RXN`/`$MOL`
blocks per `readABRXNFile.m`'s own conventions (`src/analysis/topology/reactingMoieties/readABRXNFile.m:140-211`)
and replicates `canonicalBondKey.m`'s sort-by-`(met, atomNumber)` logic exactly — no MATLAB
runtime was used, and none was needed: the script reproduces the pipeline's actual reported
counts (86/86/86 for `coa[m]`/`coa[x]`/`coa[r]`, 29 for `crn[m]`) from the twelve flagged RXN
files alone.

## R1: The symptom is produced by feature 019's own sanity check, on metabolites outside its fix's scope

**Finding**: `buildAtomAndBondTransitionMultigraph.m:729-747` is the FR-008 sanity check added by
feature 019. It compares, per metabolite, `nnz(strcmp(dBTM.Nodes.mets, met))` (the actual node
count after `canonicalBondKey` canonicalization) against `metBondCountGroundTruth(met)` — the
metabolite's own bond count, recorded once per metabolite the first time it is seen, at
`buildAtomAndBondTransitionMultigraph.m:581-588`, directly from `readABRXNFile.m`'s `bonds`
table (`nnz(strcmp(bonds.mets, bMet) & bonds.instances==1)`). This is exactly the check that
fired for `coa[m]`/`coa[x]`/`coa[r]` (86 vs. 82) and `crn[m]` (29 vs. 25) in the updated
`exp_investigate_symmetry_problem.mlx` run. The canonicalization it is checking —
`canonicalBondKey(...)`, called at `buildAtomAndBondTransitionMultigraph.m:604-609` — sorts each
bond's two `(met, atomNumber, element)` triples by `atomNumber` (see `canonicalBondKey.m:52-59`);
it does not know or check whether `atomNumber` itself is a stable cross-file identity for a
given physical atom.

## R2: Root cause is symmetry/resonance ambiguity in the metabolite, not file-order instability — confirmed by direct reproduction

**Decision**: The bug class is distinct from feature 019's. Atom *row order* (and therefore
`metNrs`/`atomNumber`, per `readABRXNFile.m:184-194`) is identical, element-for-element, across
every instance of `coa[m]`, `coa[x]`, `coa[r]`, `crn[c]`, and `crn[m]` checked (verified by
comparing `atoms.elements` row-for-row across all RXN files sharing each metabolite — no
differences found for any of the five). So feature 019's premise (raw row order is stable;
only bond-row atom-pair order was the problem) still holds in general. The new bug instead
comes from *which specific raw atom number* an independently-generated RXN file assigns to each
member of a locally symmetric or resonance-equivalent atom group — a choice that has no single
correct answer because the atoms really are chemically interchangeable.

**Rationale — three confirmed cases, all found in the twelve flagged RXN files**
(`DCA4Z7ZCOAr`, `DDCDATMTCOAHLx`, `ELAIDCPT1`, `FAOXC2442246x`, `HMR_2634`, `HMR_2919`,
`HMR_3173`, `HYPGCOAHLm`, `PPACOAATREVm`, `PTCA3ZCOAHLx`, `STCOAATr`, `VITEATENCOXCOAxr`):

1. **CoA gem-dimethyl pair (`coa[m]`/`coa[x]`/`coa[r]`, accounts for all 4 extra nodes, 82→86,
   in every compartment)**: atom 2 (pantoate's central carbon) is bonded to two chemically
   equivalent methyl carbons — atom 1 (→ H49, H50, H51) and atom 3 (→ H52, H53, H54). Comparing
   all instances of `coa[m]` (`PPACOAATREVm`, `HMR_3173`, `HYPGCOAHLm`), `coa[x]`
   (`DDCDATMTCOAHLx`, `FAOXC2442246x`, `PTCA3ZCOAHLx`, `VITEATENCOXCOAxr`), and `coa[r]`
   (`DCA4Z7ZCOAr`, `STCOAATr`): every pairing shows the same pattern — H49/H52 stay put as
   anchors, while H50/H51 and H53/H54 trade places between atom 1's and atom 3's methyl,
   independently per file. Canonical-key sets per file are self-consistent (82 unique keys each,
   82 bonds each — the metabolite's own molblock is internally correct); combined across files
   sharing the metabolite, exactly 4 keys diverge (`coa[m]#1#C#coa[m]#50#H`,
   `#1#C#...#51#H`, `#3#C#...#53#H`, `#3#C#...#54#H`, vs. their 50↔53/51↔54-swapped
   counterparts), reproducing 86 combined unique keys in every case checked.
2. **Carnitine's trimethylammonium (`crn[m]`, part of its 4-node inflation)**: the quaternary
   nitrogen (atom 10) is bonded to atom 1 (a `CH2` bridging into the rest of the molecule — not
   symmetric with the other three) and three chemically-equivalent N-methyl carbons: atom 4 (→
   H16, H17, H18/H21), atom 9 (→ H21/H18, H22, H23/H26), atom 11 (→ H23/H24, H24/H25, H26/H25).
   `HMR_2634` and `PPACOAATREVm` (the two files sharing `crn[m]`) assign different permutations
   of {H16,H17,H18,H21,H22,H23,H24,H25,H26} across these three methyls' hydrogen slots — a
   different specific case of the same "symmetric group, arbitrary correspondence" issue as CoA's
   methyls, but three-fold instead of two-fold, and this time between only two files rather than
   the CoA case's three-or-four.
3. **Carnitine's resonance-equivalent carboxylate (`crn[m]`, the rest of its inflation)**: atom 5
   (the carboxylate carbon) is bonded to two oxygens, atom 3 and atom 6, which are chemically
   equivalent by resonance (a carboxylate's two C-O bonds are only formally single/double; the
   real bond order is intermediate and symmetric between them). `HMR_2634` records the formal
   double bond as atom5=atom3 (bond type 2) and atom5=atom6 as single (type 1); `PPACOAATREVm`
   records the reverse — atom5=atom6 double, atom5=atom3 single. This is a strictly harder case
   than (1) and (2): the ambiguity changes the recorded **bond type**, not just which atom number
   is head vs. tail, so a fix here cannot rely solely on atom-number canonicalization even in
   principle — it must also reconcile which of the two equally-valid bond-type assignments is
   canonical.

Coordinates (x,y in the molblock) were also compared as a secondary check: for CoA, ~9-13 of 80
atoms differ in coordinate between any two files, exactly at the swapped-methyl positions
(matching the canonical-key divergence one-for-one); for carnitine's `crn[m]`, all 26 atoms
differ in coordinate between `HMR_2634` and `PPACOAATREVm` (a full 2D-layout rotation/reflection,
unsurprising and chemically immaterial on its own — connectivity, not literal (x,y) coordinates,
is what a fix must key off).

**Why this defeats feature 019's fix, specifically**: `canonicalBondKey.m:52-59` sorts a bond's
two ends by `atomNumber` (secondary key, when `met` matches on both ends) to make the bond's
*internal* head/tail order file-independent. This presupposes `atomNumber` uniquely and
consistently identifies one physical atom of the metabolite across files. For a symmetric atom
group, that presupposition is false by construction — there is no fact-of-the-matter "correct"
atom number for "one of the three interchangeable N-methyl hydrogens," so no purely
atom-number-based sort, however it orders ties, can make two files agree on which raw number
means which physical atom. This is precisely the edge case feature 019's `spec.md` (Edge Cases
section) flagged and explicitly left unaddressed: "A metabolite's atom numbering itself is found
to be unstable across independently-generated RXN files (not just its bond row order) — this is
a more severe condition than the confirmed bug and must be detected and reported distinctly...
since it would invalidate atom-number-based canonicalization for that metabolite."

**Alternatives considered**: Treating this as the same bug as feature 019 (i.e. assuming a
larger/different canonical sort key over raw atom numbers would resolve it) was considered and
rejected — verified directly: no monotonic re-sort of atom numbers can reconcile two files that
assigned *different subsets* of an equivalence class's raw numbers to the *same* class member
(confirmed by the partial-swap pattern in R2.1, where only 2 of a methyl's 3 hydrogens swap, not
a clean rotation), and cannot address the bond-*type* ambiguity in R2.3 at all, since bond type
is not part of `canonicalBondKey`'s sort key.

## R3: Candidate implementation approaches for symmetry-equivalence-class detection (not yet decided — for a future plan.md)

Per the explicit product decision (spec.md Clarifications), the fix must be implemented
downstream, inside the existing MATLAB pipeline, without modifying chemPy/RDT. Two broad
approaches are apparent from this investigation and are noted here as candidates for the
planning phase, not yet chosen between:

- **Graph-automorphism / canonical-labeling approach**: for each metabolite, build its atom
  adjacency graph once (from any one of its own RXN-file molblocks, analogous to how
  `metBondCountGroundTruth` already reads a ground-truth bond count "once, the first time it is
  seen," `buildAtomAndBondTransitionMultigraph.m:581-588`), compute a canonical atom ranking that
  is invariant under the molecule's own automorphism group (e.g. a Morgan-algorithm-style
  iterative refinement keyed on element and local bonding pattern, with a final deterministic
  tie-break — such as lowest raw atom number seen — for atoms that remain tied after refinement,
  i.e. atoms that are genuinely symmetry-equivalent), and use that canonical rank instead of raw
  `atomNumber` as `canonicalBondKey`'s secondary sort key.
- **Direct equivalence-class lookup**: since the confirmed cases so far are a small, identifiable
  set of functional-group patterns (terminal methyl hydrogens on a shared carbon; resonance
  carboxylate oxygens), a narrower approach could detect these specific local patterns per
  metabolite molblock and assign each class a canonical member deterministically, without a
  general graph-automorphism computation. This would be simpler to verify but risks missing
  equivalence classes outside the patterns it explicitly checks for — FR-009's full-network
  scoping pass (not yet performed; only the 75-reaction sample and its 12 flagged files have been
  examined) is needed to judge whether the pattern set is actually small and closed, or whether a
  general automorphism-based approach is warranted.

Bond-type reconciliation (R2.3) is a separate sub-problem from atom-identity canonicalization
and will need its own design regardless of which atom-identity approach is chosen — noted here,
not resolved.

## R4: Full-network blast-radius scan (FR-009) — completed

**Finding**: A standalone script, `experiments/moietySizing/scan_symmetric_atoms.py`, reproduces
the FR-008 sanity check's logic (ground-truth bond count from the first-seen occurrence of each
metabolite; union of `canonicalBondKey`-style canonical bond keys across every occurrence of that
metabolite anywhere in the corpus; mismatch = union size ≠ ground truth) without invoking
`buildAtomAndBondTransitionMultigraph.m`, `readABRXNFile.m`, or any other MATLAB code — each
`$MOL` block's own first line already names its metabolite directly, so no reaction-formula/
stoichiometry parsing is needed either, which is what makes this fast enough to be feasible at
full scale where the MATLAB pipeline (per the user's own report) becomes infeasible above roughly
500 reactions. This mirrors the existing precedent in
`experiments/moietySizing/scanRXNFilesForWarnings.m`, which already establishes the pattern of
calling per-file parsing logic directly instead of running the full pipeline just to find flagged
files.

Run against the entire `chempy_results/vmh2_reconx_for_atom_mapping/rxnfiles/atomMapped/`
corpus — 16,485 RXN files (the same corpus `exp_investigate_symmetry_problem.mlx` draws its
random samples from) — in **10.0 seconds**, at ~1,650 files/second, with 0 files failing to
parse:

- 11,940 distinct metabolites appear across the corpus.
- **1,998 metabolite instances (compartment-specific identifiers, e.g. `coa[m]`) mismatch** —
  roughly 16.7% of all metabolites seen. This is a materially larger blast radius than the four
  instances (`coa[m]`, `coa[x]`, `coa[r]`, `crn[m]`) found in the original 75-reaction sample.
- Collapsing compartment tags, **1,171 distinct base metabolites** are affected.
- The mismatch-size distribution (`observed − true` bond-node count) is dominated by small even
  numbers — +2 (756 metabolites), +4 (544), +6 (272) — consistent with the paired-atom-swap
  mechanism confirmed in R2 (each independent 2-way symmetric swap contributes 2 extra canonical
  keys). A long tail extends past +50, dominated by molecules with large or multiple symmetric
  groups: `sql[r]`/`sql[c]` (squalene, true 79 bonds, +76/+48 extra — an isoprenoid chain with
  many structurally-equivalent methyl branches), `inost[c]`/`minohp[c]`/`mi1346p[c]` (myo-inositol
  and its phosphates — a symmetric six-membered ring), `sprm[c]` (spermine, a symmetric
  polyamine), `ap4a[c]`/`ap4a[m]`/`ap4a[e]` (diadenosine tetraphosphate — literally two symmetric
  adenosine halves), and `gthox[c]`/`gthox[m]`/`gthox[n]`/`gthox[r]` (oxidized glutathione, a
  disulfide-linked symmetric dimer). Every one of these is chemically plausible as a genuinely
  symmetric molecule, which is a strong independent sanity check on the R2 diagnosis holding at
  scale, not just for the three groups found by hand.
- Full CSV report (`metabolite, true_bond_count, observed_node_count, extra_nodes,
  n_files_seen_in, example_files`, sorted by `|extra_nodes|` descending) committed at
  `experiments/moietySizing/rxnFileWarningScan/symmetricAtomScan_full.csv`.

**Caveats**:
- This scan reproduces the FR-008 node-identity check specifically; it does not reproduce the
  full `buildAtomAndBondTransitionMultigraph.m` pipeline (energy-node handling, reaction-level
  edge construction, `rbool`/model-inclusion filtering), so it is a superset scope check — some
  flagged metabolites might not actually appear together in any single model's `rbool`-selected
  reaction set. For blast-radius *scoping* (the FR-009 requirement) this is the right tool; it is
  not a substitute for confirming any individual case against the real pipeline.
- Not every flagged metabolite has been manually verified to be genuine molecular symmetry as
  opposed to a different, unrelated data-quality problem (e.g. a malformed RXN file, of the kind
  `scanRXNFilesForWarnings.m` already screens for separately) producing the same numeric symptom.
  The scale (1,171 distinct metabolites) makes case-by-case manual verification of all of them
  impractical; a sample beyond the CoA/carnitine cases already confirmed in R2 should be spot-
  checked before the implementation approach is finalized.
- This scale (~17% of metabolites, spanning >1,000 distinct base metabolites) argues against the
  "narrow pattern-matched" candidate approach in R3 — hardcoding detection for a short list of
  known functional-group patterns (terminal methyls, resonance carboxylates) is unlikely to
  generalize to squalene's isoprenoid branching or myo-inositol's ring symmetry. It favors the
  general graph-automorphism/canonical-labeling candidate, though the final choice is left to the
  planning phase per this document's original scope.

- **Downstream consumers**: feature 019's FR-007 investigation (`identifyConservedReactingMoieties.m`,
  `identifyConservedReactingSubgraphs.m`, `extractBondSubgraphs.m`) was not re-run for this
  feature; it should be re-confirmed against whatever equivalence-class approach is chosen, per
  this feature's FR-010.
- **`atomTransitionNrs` as a possible stable key**: `readABRXNFile.m`'s per-reaction atom
  transition numbering (distinct from the per-molblock `metNrs`) was noted as a plausible
  alternative identity source but not evaluated — it numbers atoms 1:q *per reaction*, not per
  metabolite, so it is not obviously reusable across the different reactions that share a
  metabolite; needs its own investigation before being relied upon or ruled out.

## R5: Feature 019 dependency — branch state resolved before planning

**Finding**: This feature's spec and FR-003/FR-007 reference `canonicalBondKey.m` and the FR-008
`metBondCountGroundTruth` sanity check as an already-shipped baseline ("after feature 019
shipped..."). At the start of `/speckit-plan`, that was not true of the working branch: `develop`
was exactly at the merge-base of `019-canonicalize-bond-node-keys` (commit `1fa6c76c1`), which
carries `canonicalBondKey.m`, the FR-008 sanity check, and 019's own Spec Kit artifacts as a
single, clean, conflict-free fast-forward (`git log --oneline 019-canonicalize-bond-node-keys..develop`
was empty; `develop..019-canonicalize-bond-node-keys` was exactly one commit).

**Decision**: Per explicit user confirmation during `/speckit-plan`, `019-canonicalize-bond-node-keys`
was fast-forward-merged into `develop` (`git merge --ff-only`) before this plan was written, so
that plan.md's file paths, line numbers, and behavioral assumptions are verified against the
actual working-tree state rather than assumed from the spec's narrative. `.specify/feature.json`
(the only file both branches had touched, pointing at each feature's own directory) was resolved
to keep pointing at `specs/020-canonicalize-symmetric-atom-bonds`. `develop` is now one commit
ahead of `origin/develop`; nothing has been pushed.

**Consequence for this plan**: All file paths, line numbers, and function contracts cited below
are read directly from the post-merge working tree, not inferred from the spec.

**Addendum (`/speckit-analyze`)**: This feature's own spec/plan/tasks had themselves been authored
directly on `develop`, with no dedicated feature branch — flagged as finding G1 during
`/speckit-analyze`. Per user confirmation, a `020-canonicalize-symmetric-atom-bonds` branch was
created from `develop` at that point (after the 019 fast-forward above, carrying forward the
already-uncommitted spec/plan/tasks/research changes), restoring the branch-per-feature pattern
feature 019 used. `plan.md`'s Branch header was updated to match.

## R6: Implementation approach for symmetry-equivalence-class detection — graph automorphism via MATLAB's existing `graph`/`isisomorphic` machinery, no new dependency

**Decision**: Detect each metabolite's symmetry-equivalence classes with a color-refinement
(1-dimensional Weisfeiler-Leman / Morgan-algorithm-style) iterative partition over that
metabolite's own atom-adjacency graph, built once per metabolite (first RXN file it is seen in,
mirroring `metBondCountGroundTruth`'s existing "read once, cache" pattern at
`buildAtomAndBondTransitionMultigraph.m:581-588`) from `readABRXNFile.m`'s `atoms`/`bonds` tables.
Atoms are assigned an initial invariant (element symbol), then iteratively refined by the
sorted multiset of (bond type, neighbor invariant) pairs until the partition stabilizes; atoms
that remain in the same partition cell at convergence are symmetry/resonance-equivalent by
construction (this is the standard sufficient condition used by canonical-labeling algorithms —
e.g. Weisfeiler-Leman refinement — for detecting graph automorphism orbits without exhaustively
enumerating permutations). No new third-party dependency is required: this repository's own
`identifyIsomorphicClasses.m` (same domain folder) already uses MATLAB's built-in
`graph`/`digraph` objects and `isisomorphic(...,'EdgeVariables',...)` for a structurally
analogous problem (comparing subgraphs), confirming the base-MATLAB Graph and Network Algorithms
functions are an accepted, already-vendored tool for this exact codebase and problem domain.
`isisomorphic`/`isomorphism` can also directly validate a candidate equivalence class (two atoms
are truly interchangeable iff swapping them yields an isomorphic vertex-labeled graph), giving a
cheap collision-free double-check (FR-004) on top of the color-refinement result for the atoms
within one metabolite (small graphs — the largest cases identified in R4, e.g. squalene at ~80
atoms, are far below any practical size concern for per-metabolite, cached-once automorphism
checking).

**Key simplification, reusing an already-established fact**: research R2 and this spec's own
Assumptions section establish that atom **row order** (`metNrs`/atom number) is stable
element-for-element across every independently-generated RXN file for a given metabolite — it is
only *which specific interchangeable atom* a symmetric position's number refers to that is
ambiguous, not the row/element structure itself. This means the equivalence-class partition and
its derived canonical-rank remapping table need to be computed only **once per metabolite** (not
once per file) and keyed directly by raw `atomNumber` (1..p, the stable row position) — the same
table is valid for every RXN file of that metabolite, because every file's row `N` has the same
element and the same local bonding pattern at that row (that stability is exactly what makes the
partition well-defined at all). This is what allows the fix to remain O(1) amortized per bond at
multigraph-build time: a per-metabolite `containers.Map` (analogous to `metBondCountGroundTruth`)
from raw `atomNumber -> canonicalAtomNumber` (the lowest raw atom number seen among each atom's
equivalence-class members, a stable deterministic tie-break), consulted before constructing each
bond's node-identity string.

**Where this plugs into existing code**: `canonicalBondKey.m`'s existing public contract (order
two `(met, atomNumber, element)` triples deterministically) does not need to change — its
existing atom-number secondary sort already does the right thing once its *inputs* are
class-canonicalized. The new step is upstream, in `buildAtomAndBondTransitionMultigraph.m`'s main
per-reaction loop (`buildAtomAndBondTransitionMultigraph.m:604-609`, immediately before the
existing `canonicalBondKey(...)` calls): remap `bondMappings.headAtoms`/`.tailAtoms` (and the
corresponding `dATME.Nodes.AtomNumber` used for the atom-index lookups that follow, lines
612-619) through that metabolite's cached `atomNumber -> canonicalAtomNumber` map before calling
`canonicalBondKey`. `canonicalBondKey.m`'s own signature and `testCanonicalBondKey.m`'s existing
assertions are unaffected; the new equivalence-class computation is naturally a new, separate
helper function/file (name deferred to `/speckit-tasks`) alongside `canonicalBondKey.m` in
`src/analysis/topology/reactingMoieties/`, consistent with Constitution IX (new code in the
correct existing domain subfolder).

**Alternatives considered**: A narrow, hardcoded pattern-matcher for the three known functional
groups (terminal methyls, resonance carboxylates) was rejected, consistent with research.md R4's
closing caveat — the 1,171-metabolite, ~17%-of-network blast radius (squalene's isoprenoid
branching, myo-inositol's ring symmetry, spermine, diadenosine tetraphosphate, oxidized
glutathione) is structurally too diverse for a short pattern list to generalize to, and a
general automorphism/canonical-labeling approach handles all of these uniformly without
per-functional-group logic.

## R7: Bond-type first-seen-wins mechanism (FR-003) — needs an explicit cache; `mapAontoBOld`'s existing behavior is close but not precise enough

**Finding**: `dBTM.Nodes.BondType` is currently populated at
`buildAtomAndBondTransitionMultigraph.m:655` via
`mapAontoBOld([dBTM.Edges.HeadBond; dBTM.Edges.TailBond], dBTM.Nodes.Name, [dBTM.Edges.HeadMetBondTypes; dBTM.Edges.TailMetBondTypes])`.
`mapAontoBOld.m` resolves duplicate keys via `ismember`'s "lowest index in `Akey`" semantics
(`mapAontoBOld.m:26`), which is deterministic per run but is not precisely "the bond type
recorded in the first RXN file encountered for that metabolite": because `Akey` is
`[HeadBond; TailBond]` concatenated (all Head entries before any Tail entries), a node's
`BondType` is currently determined by whichever edge instance reaches it first in that
Head-before-Tail, then-ascending-build-order sequence — a systematic Head-over-Tail bias, not a
clean first-RXN-file rule, and incidental rather than intentional (no comment or test currently
asserts this behavior).

**Decision**: Add an explicit, intentional first-seen cache, analogous to
`metBondCountGroundTruth` and populated in the same per-reaction loop
(`buildAtomAndBondTransitionMultigraph.m:577-588`): a `containers.Map` keyed by the canonicalized
bond-node identity string (from R6/FR-002's canonicalization), recording each key's `bTypes`
value only the first time that key is encountered (`if ~isKey(...)`, the same idiom already used
for `metBondCountGroundTruth`). After `dBTM` is constructed, override `dBTM.Nodes.BondType` from
this cache (indexed by `dBTM.Nodes.Name`/`.Bond`) so the final value is guaranteed to be the
first-RXN-file-encountered bond type regardless of `mapAontoBOld`'s Head/Tail-order incidental
behavior. This keeps the fix explicit and testable (a dedicated assertion can construct the
carnitine carboxylate case and check the specific expected `bTypes` value) rather than relying on
an accidental ordering property of a general-purpose helper.

## R8: `experiments/moietySizing/` scope — the FR-009 scan script and CSV live in a separate, sibling repository, not this one

**Finding**: FR-009 and this document's R4 describe a standalone Python scan script
(`scan_symmetric_atoms.py`) and its CSV report, "committed at
`experiments/moietySizing/...`". Neither exists anywhere in `cobratoolbox`'s history (verified:
`git log --all` for both paths returns nothing, and no `experiments/` directory exists in this
repository — consistent with Constitution IX's role map, which does not list `experiments/` as a
recognized top-level `cobratoolbox` directory). Both files do exist, however, in the sibling
repository `~/repos/reconXmoieties/experiments/moietySizing/` (`scan_symmetric_atoms.py`,
`scanRXNFilesForWarnings.m` — the "existing precedent" R4 refers to — and
`rxnFileWarningScan/symmetricAtomScan_full.csv`), which is the chemPy/RDT-adjacent atom-mapping
generation project, i.e. exactly the toolchain this feature's Clarifications explicitly place out
of scope for source changes.

**Decision**: FR-009's scoping evidence is accepted as-is (the scan was genuinely run, just
against a different repository's copy of the corpus, not this one) and no corresponding file is
created inside `cobratoolbox` by this feature — doing so would misplace analysis tooling for a
different repository's corpus under this repository's tree, with no Constitution IX-sanctioned
location for it (it is not toolbox source, not a test fixture, not documentation). If the
full-network scan needs to be re-run during this feature's implementation (SC-005, before/after
comparison), it re-runs from the sibling repository's existing script against the same corpus
path (`~/repos/reconXmoieties/chempy_results/vmh2_reconx_for_atom_mapping/rxnfiles/atomMapped/`),
exactly as it did for FR-009; this plan does not add a `cobratoolbox`-hosted equivalent.

## R9: Test placement — extend `testCanonicalBondKey.m` and `testConservedReactingMoieties.m`; a genuinely new helper function gets its own new test file per Constitution III-Naming

**Decision**: Following feature 019's own precedent (research R7 there) and Constitution
III-Naming ("exactly one test file per source function... a second, differently-named file...
MUST NOT be created"):

- `canonicalBondKey.m` is not changing its signature or behavior (R6) — no change needed to
  `testCanonicalBondKey.m` unless task-authoring time reveals otherwise.
- The equivalence-class helper function introduced by R6 is new source, so it requires its own
  new test file named `test<FunctionName>.m` (exact name deferred to `/speckit-tasks`, once the
  function's name is chosen) — not a second file for `canonicalBondKey.m`.
- The workflow-level regression proof extends `testConservedReactingMoieties.m` with new
  fixture-backed assertions for `coa[m]`/`coa[x]`/`coa[r]`/`crn[m]` (FR-007, SC-001–003),
  following the exact pattern already established there for the `crn[c]`/`crnBondKeySubmodel.mat`
  case (feature 019) — a new `.mat` submodel fixture (or fixtures) plus new RXN files under
  `data/rxnFiles/`, no new test file for the workflow-level proof.
- A fault-injection assertion for FR-011 (detection-inconclusive fallback) is added to whichever
  file most naturally exercises the equivalence-class helper directly — likely the new helper's
  own test file, mirroring how feature 019's per-metabolite sanity-check fault case (synthetic
  mismatch, `testConservedReactingMoieties.m:140-156`) was added to the file that already
  exercises the surrounding logic it is testing.

## R10: Fixture sourcing for `coa[m]`/`coa[x]`/`coa[r]`/`crn[m]` — RXN files exist on disk, need vendoring as new test fixtures

**Finding**: None of the twelve RXN files this feature's acceptance criteria name
(`PPACOAATREVm`, `HMR_3173`, `HYPGCOAHLm`, `DDCDATMTCOAHLx`, `FAOXC2442246x`, `PTCA3ZCOAHLx`,
`VITEATENCOXCOAxr`, `DCA4Z7ZCOAr`, `STCOAATr`) exist yet under
`test/verifiedTests/analysis/testReactingMoieties/data/rxnFiles/` (only `HMR_2634`, already
vendored for feature 019's `crn[c]` case, overlaps). All are present at
`~/repos/reconXmoieties/chempy_results/vmh2_reconx_for_atom_mapping/rxnfiles/atomMapped/<rxn>.rxn`
— the same on-disk source this spec's own diagnosis (Assumptions, R2 above) was built from — and
can be vendored into the test fixture directory the same way feature 019's
`ELAIDCPT1.rxn`/`HMR_2634.rxn`/`HMR_2919.rxn` were (research R6 there). A corresponding `.mat`
submodel fixture (or fixtures, one per SC-001/002/003 grouping, or one combined) following the
`crnBondKeySubmodel.mat` pattern is needed so `testConservedReactingMoieties.m` can build a small
`extractSubNetwork`-derived model without depending on the full genome-scale corpus at test run
time. This is a test-fixture/data task for `/speckit-tasks`, not a design decision — noted here so
implementation does not need to rediscover the source location.
