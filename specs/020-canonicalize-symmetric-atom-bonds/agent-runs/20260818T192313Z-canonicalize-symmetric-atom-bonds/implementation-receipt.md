# Implementation Receipt: Canonicalize Bond-Node Keys for Symmetric/Resonance-Equivalent Atom Groups

**Feature**: `020-canonicalize-symmetric-atom-bonds`
**Date**: 2026-08-18 (UTC timestamp `20260818T192313Z`)
**Branch**: `020-canonicalize-symmetric-atom-bonds`

## Context: why this run happened

Two prior `/speckit-implement` attempts on this feature crashed the MATLAB process
(kernel OOM kills, `anon-rss` 17.9GB and 25.3GB, against 31GB total system memory,
2026-08-18 16:50:42 and 17:01:35 — confirmed via `journalctl -k` and a MATLAB crash dump).
Root-caused (separate diagnostic conversation, before this implement run) to
`identifyAtomEquivalenceClasses.m`'s colour-refinement loop carrying the full
concatenated string history forward every round instead of a compact per-round label,
causing multiplicative memory growth. Two tasks were added to `tasks.md` ahead of this
run to address it: **T011a** (the memory fix) and a rewritten **T022** (bounded,
batched corpus sample instead of the full ~16,485-file corpus). This run executed the
full `tasks.md` from that state.

## Files changed

- `src/analysis/topology/reactingMoieties/identifyAtomEquivalenceClasses.m` (new,
  T011; fixed T011a; extended with a second collision guard mid-run — see "Defect found
  during implementation" below)
- `src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m`
  (extended, T012-T015 — this integration already existed in the working tree at the
  start of this run, carried over from a prior attempt; verified against research.md
  R5-R7 and left unchanged)
- `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
  (extended, T009/T009b — 74 insertions, 0 deletions, confirmed via `git diff --stat`)
- `test/verifiedTests/analysis/testReactingMoieties/testIdentifyAtomEquivalenceClasses.m`
  (new, T010/T018)
- `specs/020-canonicalize-symmetric-atom-bonds/tasks.md` (all 30 tasks marked `[X]`)
- Fixtures (already vendored at the start of this run, verified not re-created):
  `test/verifiedTests/analysis/testReactingMoieties/data/{coaM,coaX,coaR,crnM}BondKeySubmodel.mat`,
  nine new `data/rxnFiles/*.rxn` files.
- `canonicalBondKey.m`, `readABRXNFile.m`, `addBondMappingsRXNFile.m`,
  `identifyConservedReactingMoieties.m`, `identifyConservedReactingSubgraphs.m`,
  `extractBondSubgraphs.m`: **not modified**, per plan.md's constraint — re-confirmed
  (T020) by direct grep for order/index-dependent assumptions and by the unchanged
  pass/fail outcome of every pre-existing regression assertion.

## Defect found during implementation (beyond T011a's memory fix)

While running T022's corpus-scale validation, batch 1 (files 1-100 of the corpus)
surfaced a genuine regression not caught by the four originally-targeted metabolites:

**`gthox[c]` (oxidized glutathione / glutathione disulfide)**, encountered via
`10H17HPDHAGTHP.rxn`, dropped from 69 bond-graph nodes (its true count, confirmed
correct against the pre-020 HEAD baseline, commit `1fa6c76c1`) to 46 — a new
under-count, not present before this feature's equivalence-class remap.

**Root cause**: `gthox[c]` is a two-fold-symmetric dimer (two glutathione moieties
joined by a disulfide bond); colour refinement correctly finds that nearly every atom
in one half has a genuine graph-automorphic mirror in the other half (29 non-singleton
classes covering all 70 atoms — verified directly). The existing "unsafe neighbour"
guard (T011's original design) only protects against one failure mode: a single hub
atom bonded to 2+ members of the *same* class (the gem-dimethyl anchor pattern). It did
not protect against a second, distinct failure mode: two different bonds, each between
a member of one class and a member of a different class, whose substituted keys
coincide because *both* classes are simultaneously present and mirrored — a "parallel
bond" collision with no shared hub atom at all.

**Fix**: added a second guard to `identifyAtomEquivalenceClasses.m` (appended after the
existing per-class hub check, same function, no signature change): simulate the
caller's actual per-bond substitution decision (mirroring
`safeCanonicalizeOneAtom`/`safeCanonicalizeBondAtoms` exactly, via a new local function
`simulateSafeCanonicalizeOneAtom`), detect any two distinct bonds whose simulated
substituted keys collide, and add each such bond's raw endpoints to each other's
class's unsafe set — iterating to a fixed point (bounded: can only add entries, never
remove, converges within `numel(headAtoms)` rounds). Verified this restores `gthox[c]`
to 69 nodes with no FR-008 warning, and that it does not change the outcome for any of
the four originally-targeted metabolites (re-ran the full test suite after the fix;
unchanged pass).

This was not anticipated by `plan.md`/`research.md` (which scoped analysis to CoA's
gem-dimethyl pair and carnitine's trimethylammonium/carboxylate) and was found only by
actually running the pipeline at corpus scale, which is exactly what T022 is for.

## Checks run and results

| Check | Result |
|---|---|
| T011a synthetic-chain smoke test (20-atom chain, memory/convergence regression) | PASS — 0.53s, no fallback warning, correctly finds 10 mirror-pair classes (chain reflection symmetry) |
| `testConservedReactingMoieties.m` (full file, including pre-existing feature-019 assertions and new T009/T009b) | PASS |
| `testIdentifyAtomEquivalenceClasses.m` (new, T010/T018, 4 cases + T011a regression + FR-011 fault injection) | PASS |
| T016 targeted regression: coa[m]/coa[x]/coa[r] = 82 nodes (was 86), crn[m] = 25 (was 29), no FR-008 warning | PASS (all four) |
| T009b: crn[m] carboxylate bond-node `BondType` = PPACOAATREVm's first-seen value (2 for atom-5/atom-3, 1 for atom-5/atom-6) | PASS |
| T025 downstream spot check: `identifyConservedReactingMoieties`/`identifyConservedReactingSubgraphs` on `coa[m]` | PASS (9 conserved moieties, no error) |
| T022 corpus-scale run: 400 files (batches of 100, 4 separate MATLAB processes, memory-watchdog wrapped) | PASS — 0 crashes, 0 FR-008 mismatches after the `gthox[c]` fix; found and fixed 1 regression (`gthox[c]`) during batch 1 before batches 2-4 confirmed the fix |
| T023 MATLAB standards (no `evalc`, no `nargin`, no warning suppression, `ME.stack` propagated) | PASS (grep-verified) |
| T024 diff hygiene (`testConservedReactingMoieties.m`/`testCanonicalBondKey.m`, no deletions) | PASS — 74 insertions/0 deletions; `testCanonicalBondKey.m` untouched |
| T026 `git status --short` (no stray artifacts, nothing under `experiments/`) | PASS |

## T022 blast-radius confirmation detail

- Sample: 400 RXN files (alphabetically first 400 of the 16,485-file corpus at
  `~/repos/reconXmoieties/chempy_results/vmh2_reconx_for_atom_mapping/rxnfiles/atomMapped/`),
  ~5.3x the original 75-file baseline, within tasks.md's revised 300-500 target.
- Method: a self-contained pseudo-model built directly from each RXN file's own header
  stoichiometry (via `readABRXNFile`, mirroring `buildAtomAndBondTransitionMultigraph.m`'s
  own internal stoichiometry reconstruction) — no dependency on locating an external
  genome-scale model covering an arbitrary corpus sample.
- Batching: 4 batches of 100 files, each a separate `matlab -batch` process, wrapped in
  a shell memory-watchdog (kill above 10GB RSS) as defense-in-depth beyond the T011a fix.
- Results: batch 1 (files 1-100) surfaced the `gthox[c]` regression (fixed mid-run, see
  above); batches 1-4 post-fix: 0 crashes, 0 timeouts, wall-clock 67-113s per batch,
  **0 FR-008 mismatches** across all 400 files.
- Not attempted: the full ~16,485-file corpus, per the revised T022 (explicitly ruled
  out given the memory-crash history; 400 files was judged sufficient to confirm the
  fix at a materially larger-than-75 scale without re-taking that risk).

## Residual unverified / out-of-scope items

- **`h2o2[x]` in the `coa[x]` fixture** (`FAOXC2442246x.rxn`): triggers its own
  pre-existing FR-008 "does not match its true bond count (2 vs 3)" warning, confirmed
  unrelated to and unaffected by this feature's changes (h2o2 is not part of the four
  target metabolites' symmetric/resonance-atom root cause). Classified as a
  separately-scoped issue per T022's own instruction; not fixed here.
- T022 sampled the corpus's first 400 files alphabetically, not a random sample; the
  `gthox[c]` case shows this scale is sufficient to surface a real defect, but a
  different 400-file slice could in principle surface a different one. No further
  batches were run beyond the 300-500 target given this session's time budget.
- T007's pre-fix baseline (86/86/86/29) was not re-executed against the working tree
  (which already carried this feature's changes at session start); it is instead cited
  directly from `spec.md`'s Problem Statement and confirmed as feature-019's committed
  HEAD state (`1fa6c76c1`) via `git show`, which is the actual pre-020 baseline.

## Final response

Fixed both the OOM crash (T011a: bounded per-round colour labels in
`identifyAtomEquivalenceClasses.m`'s refinement loop, plus a related spurious-non-convergence
bug in the same loop's termination check) and completed the rest of `tasks.md`: added the
missing T009/T009b/T010/T018 tests, validated T016's target node counts (coa[m]/coa[x]/coa[r]
= 82, crn[m] = 25, all previously 86/86/86/29) against the real CoA-scale fixtures with no
crash, confirmed T017/T021 zero regressions on the full existing test suite, and ran T022's
corpus-scale confirmation across 400 real RXN files in memory-watchdog-wrapped batches.

That corpus run caught a second, previously-unknown regression: `gthox[c]` (glutathione
disulfide, a genuinely two-fold-symmetric molecule) dropped from its true 69 bond nodes to 46,
because the original "unsafe neighbour" safety check only guarded against one collision
pattern (a shared hub atom) and missed a second one (two mirrored bonds between two different
simultaneously-present equivalence classes). Fixed with a second, more general collision guard
in the same function, verified to restore `gthox[c]` to 69 nodes without changing any of the
four originally-targeted metabolites. Batches 2-4 (300 more files) then ran clean: 0 crashes, 0
FR-008 mismatches.

All 30 tasks in `tasks.md` are now marked complete. One pre-existing, out-of-scope issue
(`h2o2[x]`'s own unrelated bond-count mismatch) remains and is documented above as
separately-scoped, matching this feature's own instructions for handling such cases.
