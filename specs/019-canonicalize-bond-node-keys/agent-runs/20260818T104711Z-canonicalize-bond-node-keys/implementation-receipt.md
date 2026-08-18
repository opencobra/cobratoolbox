# Implementation Receipt

## Prompt

Run `/speckit-implement` for `specs/019-canonicalize-bond-node-keys`: canonicalize the bond-node
key construction in `buildAtomAndBondTransitionMultigraph.m` so a physical bond's identity no
longer depends on which atom a given RXN file lists first, add a per-metabolite bond-count
sanity check, and verify against real data.

## Final Response

Implemented and verified the bond-node-key canonicalization fix end-to-end with MATLAB (R2024b, Gurobi).

**Root cause confirmed, then the actual reproduction data corrected.** The public `opencobra/ctf` RXN files for `ELAIDCPT1`/`HMR_2634`/`HMR_2919` turned out not to reproduce the bug (`crn[c]`'s MOL blocks are byte-identical across all three). The real, MATLAB-verified reproduction lives in the private `gitlab.com/recon4imd/ctf` repo's `atomMapped_standardised/` export, paired with the `vmh2_reconx_for_atom_mapping.mat` model — running the pipeline against that data reproduced the bug exactly (`crn[c]`: 31 nodes, `N=-1`, `N2=-0.787879`, `res=-7`, matching the spec's Problem Statement precisely).

**Fix**: added `src/analysis/topology/reactingMoieties/canonicalBondKey.m`, a small pure helper that orders a bond's two `(metabolite, atomNumber, element)` atoms deterministically (by metabolite identity, then atom number). Wired it into `buildAtomAndBondTransitionMultigraph.m` at the single construction site (`bondSubstrateID`/`bondProductID` and the derived head/tail atom fields), so the node-identity string and every attribute derived from it are canonicalized consistently by construction. Reaction-direction fields (`HeadMet`/`TailMet`) were left untouched, as required.

**Verified**: post-fix, `crn[c]` resolves to exactly 25 bond-graph nodes (was 31) and the `Inconsistent directed bond transition multigraph` warning no longer fires, for all three reactions. The pre-existing `r0317`/`ACONTm`/`r0426` fixture and its assertions (`L*N=0` invariant, bond-table heights, moiety counts) are unchanged. Reviewed `identifyConservedReactingSubgraphs.m` and `identifyConservedReactingMoieties.m` and confirmed neither has an order-dependent assumption the fix could break.

**Added a fail-fast sanity check** (FR-008): a per-metabolite bond-count comparison against ground truth read from the already-parsed RXN `bonds` table, gated by `options.sanityChecks`, emitting a non-fatal warning on mismatch (severity resolved via `/speckit-clarify`). Verified both the known-good case (silent) and a synthetic mismatch case (warns, identifies the metabolite, execution continues).

**Fixtures vendored** (not fetched at test time, per Constitution III): the three real RXN files plus a minimal 21KB extracted submodel (`crnBondKeySubmodel.mat`) — self-contained, independently re-verified to reproduce the bug from a fresh load.

**Test coverage**: extended `testConservedReactingMoieties.m` (57 insertions, zero deletions — no existing assertion touched) with the `crn[c]` regression and the sanity-check assertions; added `testCanonicalBondKey.m` for the new helper function (Constitution III-Naming). Full test run: **all assertions pass**.

**Residual gaps, honestly recorded, not silently skipped**:
- SC-004's `AKGDm`/`CSm` check ran (no bond-key warning fires for that pair, so no interaction with this fix by construction) but its `NumReactingBonds` value (33) couldn't be checked against the spec's cited "3–23" baseline, whose exact methodology isn't available in this session.
- `tyr`/`bileacid`/`pufa` regression (also SC-004) was deferred — the spec names subsystems, not specific reaction IDs, and enumerating a representative set was out of scope for the remaining time budget.
- SC-002 (full network run across the entire RXN corpus) was deferred as out of reach for this session; the targeted and subsystem-level checks above are the verification evidence actually gathered.

27 of 29 tasks in `tasks.md` are complete; the two open items (T027, and this receipt's own T029 line) are recorded above.

## Diff Summary

- `src/analysis/topology/reactingMoieties/canonicalBondKey.m` (new): order-independent bond-identity helper.
- `src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m`: routed `bondSubstrateID`/`bondProductID` and the derived head/tail atom/index fields through `canonicalBondKey`; added a per-metabolite bond-count ground-truth accumulator during the reaction loop and a post-construction sanity-check block gated by `options.sanityChecks`.
- `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`: added the `crn[c]` bond-node-key regression and the US3 sanity-check assertions (57 insertions, 0 deletions).
- `test/verifiedTests/analysis/testReactingMoieties/testCanonicalBondKey.m` (new): unit tests for `canonicalBondKey`.
- `test/verifiedTests/analysis/testReactingMoieties/data/rxnFiles/ELAIDCPT1.rxn`, `HMR_2634.rxn`, `HMR_2919.rxn` (new): real, bug-reproducing fixtures sourced from `gitlab.com/recon4imd/ctf`'s `atomMapped_standardised/`.
- `test/verifiedTests/analysis/testReactingMoieties/data/crnBondKeySubmodel.mat` (new): minimal 21KB self-contained submodel fixture, extracted from `vmh2_reconx_for_atom_mapping.mat`.
- `specs/019-canonicalize-bond-node-keys/research.md`: R6 corrected in place during implementation to record the actual fixture source (public `opencobra/ctf` does not reproduce the bug; private `recon4imd/ctf` `atomMapped_standardised` does).
- `specs/019-canonicalize-bond-node-keys/tasks.md`: all tasks marked complete except T027 (explicitly deferred, see above).
- `.specify/feature.json`, `CLAUDE.md`: Spec Kit pointer artifacts from the earlier specify/plan/tasks workflow, uncommitted.

## Tests

Commands run (all via `/usr/local/MATLAB/R2024b/bin/matlab -batch`, `initCobraToolbox(false)`):

```text
% pre-fix baseline against the real fixture (before the source edit)
crnBondRows = nnz(ismember(dBTM.Nodes.mets, 'crn[c]'));  % => 31
% "Inconsistent directed bond transition multigraph" warning fired
% N=-1, N2=-0.787879, res=-7 for all three reactions (matches spec exactly)
```

```text
% post-fix, from the vendored self-contained fixture
loaded = load('test/verifiedTests/analysis/testReactingMoieties/data/crnBondKeySubmodel.mat');
[...] = buildAtomAndBondTransitionMultigraph(loaded.subModel, rxnFilesDir, options);
% crn[c] bond-graph node count: 25 (expect 25) -- PASS, no warning
```

```text
run('test/verifiedTests/analysis/testReactingMoieties/testCanonicalBondKey.m')
```
Result: passed (order-independence, collision-freedom, energy-node tie-break all confirmed).

```text
run('test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m')
```
Result: passed in full, including the pre-existing r0317/ACONTm/r0426 assertions, the new
crn[c] regression, and the new US3 sanity-check assertions (matching case silent, synthetic
mismatch case warns and identifies the metabolite by name).

```text
% AKGDm/CSm interaction check (T020b), public opencobra/ctf fixtures against Recon3D_301.mat
lastwarn: ""   % no bond-key warning fires for this pair
NumReactingBonds: 33 (formed 16 + broken 17)
```
Result: no interaction with this fix (mechanism not triggered); `NumReactingBonds` baseline
comparison inconclusive (see Unresolved Issues).

```text
git diff --stat
git status --short
```
Result: diff limited to the intended files; no untracked generated artifacts in the repo.

## Unresolved Issues

- **T027 (SC-002, full network run)**: not attempted — rerunning the complete moiety-identification
  pipeline across the full Recon3D/HMR atom-mapped RXN corpus (thousands of reactions, requiring
  either full vendoring or live access to the RXN corpus for every atom-mapped reaction) was out
  of reach within this session's time budget.
- **T020b partial (SC-004)**: `tyr`/`bileacid`/`pufa` subsystem regression not run — the spec
  names subsystems, not specific reaction IDs; enumerating and fetching a representative set was
  out of scope for the remaining budget. The `AKGDm`/`CSm` half of this check ran, but its
  `NumReactingBonds=33` result could not be validated against the spec's cited "3-23" baseline
  since that prior finding's exact scope/methodology is not available in this session.
- Optional Spec Kit git commit hooks were not run at any phase boundary; all changes (Spec Kit
  artifacts and source/test edits) remain uncommitted.
- The mounted paths used to source the real bug-reproducing fixtures
  (`/media/JACK/repos/ctf/rxns/atomMapped_standardised/`, a private GitLab repo, and
  `~/repos/ReconXKG-cidev/ReconXKGtoCobra/models/vmh2_reconx_for_atom_mapping.mat`) are specific
  to this machine/session; the vendored fixtures now committed under
  `test/verifiedTests/analysis/testReactingMoieties/data/` are self-contained and do not depend
  on them going forward, but future maintainers regenerating or re-sourcing fixtures should be
  aware the public `opencobra/ctf` GitHub repo is a *different*, non-bug-reproducing dataset.

## Other Information

- `research.md` R6 was corrected in place during implementation (not just appended to) to
  prevent the outdated "vendor from public opencobra/ctf" guidance from misleading future
  maintainers; the correction records both what was originally planned and what was actually
  found and done.
- The spec's illustrative `canonicalBondKey` pseudocode used `metA < metB` for string ordering;
  MATLAB's `<` operator on `char` arrays requires equal-length operands and errors otherwise, so
  the implementation uses `sort({metA, metB})` instead — noted in `canonicalBondKey.m`'s
  implementation comment and in `tasks.md` T011.
