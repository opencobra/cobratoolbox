# Known issues: conserved and reacting moieties

## KI-001: Arbitrary pairing of interchangeable hydrogens splits equivalent moieties

**Status:** OPEN. Worked around, not fixed (2026-10-02).
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

### Fix options (to decide later)

- **Pairing-blind comparison (preferred):** before testing isomorphism, collapse each heavy atom's hydrogens into a count label on that atom, so arbitrary hydrogen pairing cannot affect the result. Needs no change to the RXN data.
- **Canonical hydrogen pairing:** rewrite each reaction's hydrogen mapping to a consistent convention. Depends on stable per-metabolite hydrogen numbering across files, which features 019/020 showed is not guaranteed.

Either belongs with feature 020 (symmetric/resonance-equivalent atoms): geminal hydrogens are its most common case.

### First measurement to make when revisiting

On the ~2,000-reaction test model, compare the number of conserved-moiety isomorphism classes with and without hydrogens collapsed. That gives the size of the over-split, and therefore how much the provisional results are affected.
