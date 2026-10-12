# Known issues: conserved and reacting moieties

## KI-001: Arbitrary pairing of interchangeable hydrogens splits equivalent moieties

**Status:** OPEN for the hydrogen over-splitting (consequence 2). The bond-level stage no longer stalls in `classifySubgraphIsomorphism`, and RXN files with no bonds can be read (feature `20261012-093525-symmetric-iso-zero-bond`, 2026-10-12; see "Update 2026-10-12" below).
**Affects:** `identifyConservedReactingMoieties.m` (bond-level stage and, expected, atom-level isomorphism classes), `findAndExtractMolecularGraphs.m`, `classifySubgraphIsomorphism.m` callers.
**Revisit before:** reporting moiety counts, comparing MTGs across networks, or treating results from the 2026-10 VMH/Rhea runs as final.

### Summary

The two (or three) hydrogens on a CH2 (or CH3) are chemically interchangeable, and the atom mapper pairs them arbitrarily in each reaction: H1 -> H1' and H2 -> H2' in one reaction, H1 -> H2' and H2 -> H1' in another. Each mapping is chemically correct. But the pipeline gives every hydrogen its own identity, so these arbitrary per-reaction choices become graph structure. Two chemically equivalent positions then end up with differently wired hydrogen graphs, and are treated as different moieties.

### Evidence (2026-09-24 to 2026-10-02)

- `identifyConservedReactingMoieties(conservedMoietiesOnly=true)` never returned on the `pufa` subsystem once reaction 495 (`DKPGD2COAB3FAOXCOA`) was added; 494 reactions finish in about 5 minutes.
- The hang is in the unlabelled `classifySubgraphIsomorphism(bondSubgraphs)` call in `findAndExtractMolecularGraphs.m` (bond-level stage). One pair of bond components (leader 227 vs candidate 250, 225 nodes and 381 edges each) never resolves in `isisomorphic`.
- Each component is one CH2 inside the CoA scaffold, traced through 75 CoA-thioester metabolites (1 C + 2 H each). The two components share 63 of about 65 reactions and differ only at four thioester hydrolyses (`CHOL4ENCOAHL`, `TDKPGD2COAHL` vs `IUCDCHACCOAHL`, `TXB2DNORCOAHL`).
- Those four RXN files map every CoA scaffold heavy atom and hydrogen to the correct position (checked with `checkCoAScaffoldMapping.py`, reconXmoieties `scripts/`). So this is not a mapping error.
- Splitting the pair by element (mets-labelled `isisomorphic`):
  - carbon-only subgraphs (75 nodes, 75 edges): **isomorphic**, 0.08 s;
  - hydrogen-only subgraphs (150 nodes, 156 edges): **not isomorphic**, 0.09 s.
- A consistent pairing would give a hydrogen graph that exactly doubles the carbon graph (150 edges). The 6 extra edges come from metabolite pairs joined by several reactions that pair the hydrogens differently (straight in one, crossed in another).
- Conclusion: the carbon skeletons are the same; everything that distinguishes the two components is hydrogen-pairing wiring. Exact isomorphism on such near-identical, highly symmetric graphs is close to worst case for VF2, which explains the hang.

Diagnostic scripts: reconXmoieties `experiments/2026-10-01-conserved-only-cliff/inspectHangingPair.m` (modes `split:C`, `split:H`); saved pair in `data/moietySizing/conserved-only-cliff/lastUnlabelledPair.mat`.

### Consequences

1. **Bond-level stage:** the unlabelled classification in `findAndExtractMolecularGraphs.m` can fail to terminate on genome-scale networks (CoA, carnitine, long acyl chains). Only its largest isomorphic group is used.
2. **Atom-level conserved moieties (expected, not yet measured):** hydrogen components of chemically equivalent positions can land in different isomorphism classes. The result is still mathematically valid (each class is a real conservation relation, so L*N = 0 holds), but moieties are over-split: redundant rows in L, inflated moiety counts, and duplicated or near-duplicated MTGs.
3. **Reconciliation work:** any VMH/Rhea comparison built on these MTGs inherits the over-splitting. Equivalent moieties may fail to match across networks for hydrogen-pairing reasons alone.

### Interim workaround (decision 2026-10-02)

To unblock conserved-moiety identification for the full VMH and Rhea networks (needed for the MTG-based reconciliation), the bond-level stage can be skipped in conserved-only mode:

```matlab
options.conservedMoietiesOnly = true;
options.computeMoietyGraphs   = false;   % new, default true
[arm, moietyFormulae] = identifyConservedReactingMoieties(model, BG, dATM, options);
```

With `computeMoietyGraphs = false`, `arm.MG` is an empty cell array and every other output is identical to the default (regression-tested in `testConservedReactingMoieties.m`). The default (`true`) leaves all existing behaviour and golden-test outputs unchanged. Combining `false` with `conservedMoietiesOnly = false` is an error.

Verified 2026-10-02 (details and artefacts in `specs/20261002-conserved-only-skip-moiety-graphs/spec.md`, Evidence):

- the unit test passes, including all existing golden cases;
- the `pufa` n=495 model that never returned now completes conserved-moiety identification in about 30 s (332 moieties, L*N = 0);
- at n=494, where both modes complete, all 20 other `arm` fields and `moietyFormulae` are identical between modes; only `arm.MG` differs (4700 graphs vs empty). Identify time 81.9 s -> 27.9 s.

**This removes the hang only. It does not fix consequence 2.** Results from runs made this way are expected to contain hydrogen-driven over-splitting and must be treated as provisional.

### Update 2026-10-12: hydrogen removal, a second mechanism, and what is fixed

Evidence from reconXmoieties exploration `ki001-hydrogen-stripping` (branch `explore/ki001-hydrogen-stripping`, `specs/20261012-080033-ki001-hydrogen-stripping/exploration.md`). Each run used develop f1581781c, MATLAB R2024b, and was run once. The RXN files had their hydrogens removed with a test stripper that renumbers atoms, bonds and mappings consistently. This is a way to test the effect of hydrogens, not an implicit-hydrogen corpus.

- **Hydrogen removal fixes the part caused by hydrogens (E3–E5, E9):**
  - pufa n = 495, the model that never returned: finishes with moiety graphs on in 27.6 s (292 moieties, 2,256 graphs);
  - ~2,000-reaction subset: finishes with graphs on;
  - fatty acid synthesis: did not finish in 20 min with hydrogens; finishes in 18 s without them;
  - every case: the heavy-atom moieties are exactly unchanged, and only the H-only moieties disappear (40 of 332 on pufa n = 495; 90 of 770, or 11.7%, on the subset). This is the size of consequence 2 on those models;
  - the 231 metabolites whose atom order differed between RXN files differed only in hydrogen rows.
- **A second mechanism does not involve hydrogens (E10–E11):**
  - the full pufa subsystem still did not finish without hydrogens; the smallest failing prefix is n = 514 (trigger `15DPGJ2GCSHL`);
  - the unlabelled `isisomorphic` call stalled on two bond components of 318 nodes and 337 edges each (309 O, 9 C), spanning 227 eicosanoid metabolites;
  - the components differ only in 6 glutathione-conjugate metabolites of mirrored (by name, R and S) branches. Restricted to one element, they are isomorphic and decided in under 0.1 s;
  - the stall is VF2 on two large, sparse, almost-symmetric graphs, not hydrogen pairing.
- **Zero-bond reactions:** without hydrogens, water, ammonium, hydroxide, sulfide and metal ions are single atoms with no bonds. `readABRXNFile` failed on reactions in which no molecule has a bond (31 reactions in the stripped std corpus).

**Resolved by feature `20261012-093525-symmetric-iso-zero-bond`:**
- `classifySubgraphIsomorphism` decides unlabelled candidate pairs with an exact test:
  - identical edge lists are isomorphic by the identity map;
  - otherwise it uses joint colour refinement, a verified greedy individualisation pass, and an exact individualisation-refinement search, with a bounded fallback to `isisomorphic` that is counted (`'getFallbackCount'`);
  - the saved stuck pair (`test/verifiedTests/analysis/testReactingMoieties/data/nearSymmetricBondComponentPair.mat`) is one class in at most 0.06 s (T011, N = 3);
  - labelled comparisons are unchanged.
- `readABRXNFile` returns an empty bond table with the usual variables and types for a reaction with no bonds. `checkABRXNFiles` counts no bond transitions for it, and `buildAtomAndBondTransitionMultigraph` builds such a model, with one `BTi2R` column per bond-mapped reaction.

**Verified 2026-10-12** (reconXmoieties stripped corpus, moiety graphs on, N = 1; `specs/20261012-093525-symmetric-iso-zero-bond/externalPufaCheck.sh`):
- pufa n = 514 finishes: identify 27.0 s, 297 moieties, 2,349 moiety graphs;
- the full pufa subsystem (681 reactions; the 31 zero-bond reactions still excluded by that script) finishes: identify 26.2 s, 271 moieties, 3,736 moiety graphs;
- both runs: max|L*N| = 0 and 0 fallbacks.

**Still open:**
- consequence 2, the hydrogen over-splitting with explicit hydrogens. Its fix is the hydrogen policy of the RXN data (an implicit-hydrogen corpus; reconXmoieties spec 033) or one of the options below;
- consequence 3, which follows from 2;
- whether other near-symmetric components exceed the search budget and fall back to `isisomorphic`. The fallback count reports this.

### Fix options (to decide later)

- **Pairing-blind comparison (preferred):** before testing isomorphism, collapse each heavy atom's hydrogens into a count label on that atom, so arbitrary hydrogen pairing cannot affect the result. Needs no change to the RXN data.
- **Canonical hydrogen pairing:** rewrite each reaction's hydrogen mapping to a consistent convention. Depends on stable per-metabolite hydrogen numbering across files, which features 019/020 showed is not guaranteed.

Either belongs with feature 020 (symmetric/resonance-equivalent atoms): geminal hydrogens are its most common case.

### First measurement to make when revisiting

On the ~2,000-reaction test model, compare the number of conserved-moiety isomorphism classes with and without hydrogens collapsed. That gives the size of the over-split, and therefore how much the provisional results are affected.
