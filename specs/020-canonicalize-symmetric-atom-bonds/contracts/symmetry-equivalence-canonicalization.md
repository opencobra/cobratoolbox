# Contract: Symmetry/Resonance-Equivalence Bond-Node Canonicalization

**Feature**: 020-canonicalize-symmetric-atom-bonds
**Public function (unchanged signature)**: `src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m`
**Read, not modified**: `src/analysis/topology/reactingMoieties/canonicalBondKey.m`
**New internal helper (named at `/speckit-tasks`)**: `src/analysis/topology/reactingMoieties/identifyAtomEquivalenceClasses.m`

## Public call surface

No signature change to `buildAtomAndBondTransitionMultigraph.m`. Existing calls remain valid,
including the ones feature 019's contract already documents:

```matlab
options.directed = 0;
options.sanityChecks = 1;
[dATM, metAtomMappedBool, rxnAtomMappedBool, M2Ai, Ti2R, dATME, BG, dBTM, ...
    M2BiE, M2BiW, BTi2R, BTiE] = ...
    buildAtomAndBondTransitionMultigraph(model, RXNFileDir, options);
```

No new user-facing parameter is introduced. `options.sanityChecks` continues to gate the existing
FR-008 (feature 019) per-metabolite bond-count check, now expected to stop firing for
symmetric/resonance-equivalent metabolites once this feature is implemented.

The new helper function is internal (called only from `buildAtomAndBondTransitionMultigraph.m`),
not part of the toolbox's public API surface; its own contract (inputs/outputs) is decided at
`/speckit-tasks` alongside its name, and documented then in its own openCOBRA header
(Constitution VII-E) plus `test<FunctionName>.m`.

## Behavioural contract

1. For two atoms of one metabolite that are symmetry- or resonance-equivalent (spec Key Entities:
   Symmetry-Equivalence Class), a bond touching either atom MUST resolve to the same
   `dBTM.Nodes.Bond` identity regardless of which RXN file supplied that bond's row and regardless
   of which specific raw atom number that file assigned to which class member (spec FR-002),
   including when only a subset of the class's members are swapped between two files (spec FR-002,
   edge case: CoA's H49/H52-anchor-with-partial-swap pattern).
2. Two atoms that are NOT genuinely symmetry-equivalent (including two atoms of the same element
   with superficially similar local bonding but distinguishable elsewhere in the molecular graph)
   MUST NOT be merged into the same class or the same canonical atom number — collision-free (spec
   FR-004).
3. For a resonance-equivalent bond whose two RXN-file representations record different formal bond
   types, `dBTM.Nodes.BondType` for that bond's node MUST equal the bond type recorded in whichever
   RXN file was processed first (in `model.rxns` order) for that metabolite, deterministically
   (spec FR-003; research R7) — not whichever file `mapAontoBOld`'s internal duplicate-key
   resolution happens to prefer.
4. For a metabolite with multiple, independent Symmetry-Equivalence Classes (e.g. `crn[m]`'s
   trimethylammonium and carboxylate groups simultaneously), each class MUST be detected and
   canonicalized correctly and independently of the others (spec FR-005).
5. For a metabolite with no Symmetry-Equivalence Class, and for feature 019's already-fixed
   `crn[c]` case and its existing regression fixtures, every field of `dBTM.Nodes`/`dBTM.Edges`
   and derived matrices (`M2BiE`, `M2BiW`, `BTi2R`, `BTiE`) MUST be byte-for-byte unchanged by this
   feature (spec FR-006).
6. If equivalence-class detection is inconclusive for a metabolite, the function MUST emit a
   visible, non-suppressed warning naming that metabolite (Constitution VII-B), fall back to plain
   atom-number canonicalization (feature 019's existing behavior) for that metabolite only, and
   MUST continue processing every other metabolite and reaction without halting (spec FR-011).
7. `canonicalBondKey.m`'s existing behavioral contract (order-independent key; collision-free for
   two atoms of one metabolite with different atom numbers; energy-node handling) is unchanged and
   continues to hold verbatim — this feature supplies it class-canonicalized `atomNumber` inputs,
   it does not alter `canonicalBondKey.m` itself (research R6).
8. After the fix, the FR-008 (feature 019) per-metabolite bond-count sanity check MUST report no
   mismatch for `coa[m]`, `coa[x]`, `coa[r]`, and `crn[m]` when built from the RXN files that
   currently trigger it (spec FR-007).

## Numerical contract

- For a model containing exactly `PPACOAATREVm`, `HMR_3173`, `HYPGCOAHLm`, `coa[m]` resolves to
  exactly 82 `dBTM.Nodes` rows (its true bond count), not 86 (spec SC-001).
- The same holds for `coa[x]` (`DDCDATMTCOAHLx`/`FAOXC2442246x`/`PTCA3ZCOAHLx`/`VITEATENCOXCOAxr`)
  and `coa[r]` (`DCA4Z7ZCOAr`/`STCOAATr`): exactly 82 nodes each (spec SC-002).
- For a model containing `HMR_2634` and `PPACOAATREVm`, `crn[m]` resolves to exactly 25
  `dBTM.Nodes` rows, not 29 (spec SC-003).
- Feature 019's fixed `crn[c]` case (`ELAIDCPT1`/`HMR_2634`/`HMR_2919`, 25 nodes) and its existing
  regression fixtures (`r0317`/`ACONTm`/`r0426`) are unchanged (spec SC-004).

## Downstream consumer contract (re-confirmed from feature 019 research R3; not changed by this feature)

- `identifyConservedReactingSubgraphs.m` reads `dBTM.Edges.HeadMet`/`.TailMet` (reaction direction,
  unaffected by atom-identity canonicalization) and treats `BondIndex`/`BondHeadAtomIndex`/
  `BondTailAtomIndex` as opaque identifiers / an unordered set — continues to function correctly
  with corrected, smaller node counts for previously-affected symmetric metabolites.
- `identifyConservedReactingMoieties.m` does not read `dBTM` directly; it consumes `BG` (built from
  `dBTM.Nodes.BondHeadAtomIndex`/`.BondTailAtomIndex`) and treats both atoms of a bond
  symmetrically. Continues to function correctly.
- `extractBondSubgraphs.m` has no direct `dBTM` field access. Continues to function correctly.
- Per spec FR-010, this feature MUST NOT change any of the three consumers' output for
  previously-correct (non-symmetric) metabolites; any output change for previously-affected
  symmetric metabolites MUST be attributable to the intended correction alone — to be re-confirmed
  during implementation (this contract does not itself constitute that re-confirmation).

## Test contract

Primary end-to-end validation (existing test, extended — no new file for the workflow-level proof,
per Constitution III-Naming and research R9):

```matlab
testConservedReactingMoieties
```

New unit-level validation (new file, per Constitution III-Naming — the new equivalence-class
helper is new source):

```matlab
testIdentifyAtomEquivalenceClasses
```

Required outcomes:

- Existing assertions in `testConservedReactingMoieties.m` (feature 019's `crn[c]` case, the
  `r0317`/`ACONTm`/`r0426` fixture, the `L*N = 0` invariant, moiety/subgraph counts) continue to
  pass unchanged (spec FR-006, US2).
- New assertions in `testConservedReactingMoieties.m` confirm `coa[m]`/`coa[x]`/`coa[r]` resolve to
  exactly 82 nodes and `crn[m]` to exactly 25 nodes, with no
  `does not match its true bond count` (FR-008) warning, for the RXN-file combinations spec FR-007
  names.
- New assertions in the new helper's test file confirm: (a) a known symmetric group (e.g. a
  gem-dimethyl pair) is detected as one class and canonicalizes to one shared atom number; (b) two
  atoms sharing an element but not truly symmetric are NOT merged (collision-free, FR-004); (c) a
  resonance bond-type disagreement resolves to the first-encountered file's type (FR-003); (d) a
  deliberately inconclusive/malformed input triggers the FR-011 warn-and-fall-back path without
  raising an error, mirroring feature 019's synthetic-mismatch fault-injection pattern in
  `testConservedReactingMoieties.m:140-156`.

Implementation may add focused assertions to either file if needed, but must not weaken or remove
existing assertions in `testConservedReactingMoieties.m` or `testCanonicalBondKey.m`.
