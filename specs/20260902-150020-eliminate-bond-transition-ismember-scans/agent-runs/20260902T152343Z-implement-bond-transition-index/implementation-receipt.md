# Implementation Receipt

**Feature**: `20260902-150020-eliminate-bond-transition-ismember-scans`
**Run**: 20260902T152343Z-implement-bond-transition-index

## Prompt

`/speckit-implement` (no additional user input), following an approved `spec.md` ->
`plan.md` -> `tasks.md` -> `/speckit-analyze` (5 findings remediated) chain earlier in
this same session, for feature
"Eliminate remaining cell.ismember scans in buildAtomAndBondTransitionMultigraph's
bond-transition loop." Continued in a follow-up turn: "matlab is available on this
machine. Try running the remaining tasks to completion once you have found the matlab
instance on this machine. Let me know when it is done."

## Final response

All 15 tasks run to completion. MATLAB R2024b was found at `/usr/local/MATLAB/R2024b`
(not on `PATH`, hence the initial "MATLAB unavailable" assessment was wrong — it just
needed locating). Running the pending tasks surfaced two real bugs, which are now fixed,
and one genuine success-criterion shortfall (SC-002), which is not a defect but an
out-of-scope limitation — details below.

**Bugs found and fixed while running T007** (`testConservedReactingMoieties.m`):
1. `sprintf('%s\x1f%d\x1f%s', ..., dATM.Nodes.AtomNumber(r), ...)` errored ("Function is
   not defined for sparse inputs") — `AtomNumber` is sparse for this test's smaller model
   (it happened to be full/dense for the Tyrosine benchmark, which is why T003's capture
   didn't catch it). Fixed with `full(...)` around the `AtomNumber` argument in both the
   index-build loop (`buildAtomAndBondTransitionMultigraph.m`) and inside
   `resolveAtomNodeIndex.m` itself (defense in depth).
2. **This feature's own FR-004 assumption was wrong.** The spec asserted "lines 677-684
   never resolve the energy pseudo-node" — real data disproves it: ACONTm, r0317, and
   r0426 (the test's own fixture reactions) all have a product-side bond whose head atom
   *is* the reaction's own energy node. My index was built only from the reaction-invariant
   `dATM.Nodes`, which excludes every reaction's energy node, so those lookups failed with
   `resolveAtomNodeIndex:missingNodeIdentity` — correctly explicit, per FR-005, but wrong
   for genuinely valid input. Fixed by registering each reaction's own energy-node key into
   the same `dATMNodeIndexMap` right after `dATME = addnode(dATM, EnergyNode)` (cheap, O(1)
   per reaction — the energy-node key is unique per reaction since reaction names are
   unique), and switching the 4 `resolveAtomNodeIndex` calls to index `dATME.Nodes` (real
   atoms + this reaction's own energy node) instead of `dATM.Nodes`. Both are now
   documented in-code and this deviation from the original spec assumption is recorded
   here and in `tasks.md`.

After both fixes, `testConservedReactingMoieties.m` passed completely — every existing
assertion, including all the crn[c]/coa[m,x,r]/crn[m] symmetry fixtures and the T009b
BondType checks from features 019/020.

**Success-criteria results (T008, Tyrosine benchmark, post-fix)**:
- **SC-001 PASS, decisively**: `cell.ismember` = 1,754 calls, 0.3% of the pre-feature-022
  baseline (508,534) — target was <=10%.
- **SC-003 PASS**: `arm.L`/`moietyFormulae`/`reacting.selectedReactionNames`
  byte-identical to the pre-change golden snapshot.
- **SC-005 PASS**: wall-clock 38.0s vs. the post-feature-022 baseline of 55.0s.
- **SC-004 PASS** (T007, above).
- **SC-006 PASS** (T010, below).
- **SC-002 FAILS**: `tabular.dotReference` = 1,049,026 calls, 56.3% of the pre-feature-022
  baseline (1,863,426) — target was <=30% (<=559,028).

**Root cause of the SC-002 shortfall** (via a `profile('info')` parent-call breakdown for
`tabular.dotReference`, scoped to the same `buildAtomAndBondTransitionMultigraph` call
this feature's own SC-001 baseline was measured against): of the 1,049,026 calls, the
large majority trace to `readABRXNFile` (254,348), `addBondMappingsRXNFile` (187,229),
`buildAtomAndBondTransitionMultigraph` itself (170,000 — from the ATOM-transition loop
and the sanity-check/M2Ai/Ti2R sections, not the bond-transition loop this feature edited),
`digraph.subsref` (46,527 — MATLAB's own digraph-property-access machinery), and
`tabular.dotListLength` (385,486 — internal table machinery invoked throughout the whole
call tree). None of these are in this feature's scope, which FR-001 explicitly limited to
the bond-transition loop (the old lines 677-684) only. This feature's own contribution to
`dotReference` — the bond-transition loop's `dATME.Nodes.mets`/`.AtomNumber`/`.Element`/
`.Atom`/`.AtomIndex` accesses — was fully eliminated (replaced by 4
`resolveAtomNodeIndex` calls instead of 8 mask expressions), but the pipeline's total
`dotReference` count is dominated by other call sites this feature was never scoped to
touch. **SC-002's >=70%-reduction target does not appear achievable by this feature's
scoped fix alone** — it would require a follow-up feature touching `readABRXNFile.m`,
`addBondMappingsRXNFile.m`, and/or the atom-transition loop, each requiring its own
Spec Kit cycle (Constitution Principle V/VI: no scope expansion without an approved spec).

**T010 (new unit test)**: PASSED — all three cases (unique match, missing key, ambiguous
key) against synthetic tables.

**Recommendation**: accept this feature's result as-is (US1's stated primary goal — the
disproportionate 16-`ismember`-per-bond-transition hotspot — is closed, decisively, and
SC-001/SC-003/SC-004/SC-005/SC-006 all pass) and, if the remaining `tabular.dotReference`
volume matters, open a follow-up feature scoped to `readABRXNFile.m`/
`addBondMappingsRXNFile.m`/the atom-transition loop specifically, informed by this run's
profile breakdown. I did not attempt that here since it is out of this feature's approved
scope.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01QhFDz59yWvXhUNYiwwrR5c

## Diff summary

```
 src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m | 51 ++++++++++++++++++++++-----
 1 file changed, 43 insertions(+), 8 deletions(-)
```

Plus 3 new untracked files:
- `src/analysis/topology/reactingMoieties/resolveAtomNodeIndex.m` (new, ~65 lines)
- `test/verifiedTests/analysis/testReactingMoieties/testResolveAtomNodeIndex.m` (new, ~87 lines)
- `specs/20260902-150020-eliminate-bond-transition-ismember-scans/tyrosineReproducibilityCheck.m` (new, ~180 lines)

No other `src/` or `test/` file touched (verified via `git status --porcelain -- src/ test/`
both before and after the mid-run bug fixes).

Operational note: found and removed a stale `.git/index.lock` (dated the previous day,
no active `git` process holding it — confirmed via `ps aux`/`lsof`) that was blocking
`git stash`, needed to capture a true pre-change baseline for T003.

## Tests

- `testResolveAtomNodeIndex.m` (new): **PASSED** (T010) — unique match, missing key
  (`resolveAtomNodeIndex:missingNodeIdentity`), ambiguous key
  (`resolveAtomNodeIndex:ambiguousNodeIdentity`), all against synthetic tables.
- `testConservedReactingMoieties.m` (existing, unmodified): **PASSED** (T007) after the
  two bug fixes above — every existing assertion, unchanged.
- `tyrosineReproducibilityCheck.m` (new, non-CI): run in both CAPTURE (T003, pre-change,
  via `git stash`) and COMPARE (T008, post-change) modes. SC-001/SC-003/SC-005 pass;
  SC-002 fails (root-caused above, not a defect).

## Unresolved issues

- **SC-002 (`tabular.dotReference` <=30% of pre-feature-022 baseline) is not met** and, per
  the profile breakdown above, does not appear achievable within this feature's approved
  scope. Recommend either accepting SC-001/SC-003/SC-004/SC-005/SC-006 as the feature's
  delivered result, or scoping a follow-up feature at `readABRXNFile.m`/
  `addBondMappingsRXNFile.m`/the atom-transition loop.
- This feature's own FR-004 assumption ("the energy pseudo-node is never resolved by lines
  677-684") was factually wrong and has been corrected in the implementation (not yet
  reflected as a formal spec.md amendment — `spec.md` itself was not edited during this
  implementation run, per the implementation phase's scope; a future `/speckit-clarify` or
  spec update could correct FR-004's wording to match the as-built behavior).
- Quickstart step 6's zero-bond-transition edge case remains unverified by direct
  execution (no confirmed fixture identified in the corpus) — verified by code inspection
  only, as `quickstart.md` documents.
