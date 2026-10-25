# Implementation receipt: 20260928-100409-extract-bond-subgraphs-local-peeling

## Prompt

`/speckit-implement` (no arguments), run on branch `20260928-100409-extract-bond-subgraphs-local-peeling` against `specs/20260928-100409-extract-bond-subgraphs-local-peeling/tasks.md` (T001–T033). User follow-ups during the run: "continue" (after the auto-mode classifier stopped giving verdicts), and a decision on SC-006: "Run 154310 check instead (Recommended)".

## Final response

The feature is implemented and verified. `extractBondSubgraphs` is about 10× faster on the 1,960-reaction model, and every output is identical to the original's. All 33 tasks are complete, and every success criterion passes. The one exception is that the feature 021 and 022 checks couldn't run; the substitute you chose passed.

| Criterion | Result |
|---|---|
| SC-001: identical outputs | All six real fixtures (Tyrosine, 332, 531, 1,067, 1,604 and 1,960 reactions) are byte-identical to the original's (SHA-256 fingerprints equal), and so are all 24 CI fixtures. |
| SC-002: end-to-end | On the 1,960-reaction model, `identifyConservedReactingMoieties` returns identical `arm`, `moietyFormulae` and `reacting`. |
| SC-003: no whole-graph calls | 0 `rmedge` and 0 `subgraph` calls, down from 41,671 and 83,342 per run on the 1,960-reaction model. |
| SC-004 (gate) | On n1960, 77.9 s against 776.8 s: a ratio of 0.100, where the limit was 0.15. |
| SC-005 | The scaling exponent fell from 1.72 to 1.27, under the 1.3 target. |
| SC-006 | All 11 `testReactingMoieties` tests pass. The feature 20260921-154310 check is 16/16 equal (8 subsystems × default and conserved-only modes). |

The new-to-original time ratio falls as models grow: 0.43 at 127 reactions, 0.23 at 332, 0.17 at 531, 0.13 at 1,067, 0.11 at 1,604 and 0.10 at 1,960. The full 1,960-reaction conserved-moiety run took 857 s, against 1,205 s for the reference run. That reference run had capture overhead, so read the 29% as indicative. The isolated saving is about 700 s per run.

**What changed**
- **`src/analysis/topology/reactingMoieties/extractBondSubgraphs.m`:**
  - The main path now groups bond edges and atom-transition edges once, by component pair.
  - A per-edge flag and a pointer to the first remaining edge replace `rmedge`, `subgraph` and the growing `ismember` scan.
  - Each pair's tables are built directly, in the order `subgraph` would give them.
  - The `NOTE` help text and the author line are updated.
  - The precondition checks and `extractBondSubgraphsByComponentScan` are byte-identical to the base commit.
  - The old loop is kept, verbatim, as `extractBondSubgraphsByEdgeScan`, for inputs whose `Component` labels differ from `conncomp(ATG)`.
- **`test/.../testExtractBondSubgraphs.m`:** extended with 23 new main-path cases (hand-built, 20 random, label mismatch, and an out-of-range atom that must raise the original error). It also asserts the five `subgraph`/`rmedge` ordering rules the new code relies on, so a future MATLAB release that changes them fails in CI.
- **`test/.../data/bondSubgraphPeelingReference.mat`** (new, 470 KB): the references for those cases, captured from the original code.
- **Feature directory:** spec, plan, research, tasks, the capture and check scripts, the original-code copies, the results file, the Story 1 patch and this receipt.

**Things you should know**
1. **The original function can hang.** If `ATG.Nodes.Component` differs from `conncomp(ATG)`, the original loop can fail to terminate. The pipeline never produces such input. The preserved loop behaves identically, so nothing changes for users, but it is a latent defect worth its own fix.
2. **Local references are fingerprints, not full outputs.** Full outputs would take many GB (377 MB for Tyrosine alone). If a fingerprint ever differs, the check script re-runs the original copy and decides equality with `isequaln`.
3. **The 332-reaction fixture was not committed.** It is 36.8 MB, above your 1 MB limit, so CI uses the synthetic fixtures.
4. **The 021/022 checks are stale.** They hard-code `/media/JACK/repos/ctf/rxns/atomMapped_standardised`, which is now `atomMapped_std`. Their scripts were not edited.
5. **Another feature's file was changed.** Running the substitute check appended one results row to `specs/20260921-154310-reacting-moiety-optimisation/reacting-optimisation-reproducibility-results.md`, as that script is designed to do.
6. **Not verified:** the MATLAB versions used in CI. Everything ran on R2024b Update 8. The ordering-contract test exists to catch a version difference.

Nothing is committed. The local captures (about 3.9 GB, including a 3.0 GB end-to-end reference) are in `~/repos/reconXmoieties/experiments/moietySizing/results/outputs/extractBondSubgraphsPeeling/`, and you can delete them once you no longer need them for re-checking.

## Diff summary

Modified (tracked):
- `src/analysis/topology/reactingMoieties/extractBondSubgraphs.m`: +236/−9. New main-path loop (pair-bucket index, `remaining` flag, `first` pointer, direct `GEdges`/`GNodes`/`combinedSubgraph` construction, error parity); local functions `extractBondSubgraphsByEdgeScan` (the old loop, verbatim) and `buildPairEdgeIndex`; `NOTE` rewritten and `.. Author:` line added. Lines 34–76 and `extractBondSubgraphsByComponentScan` byte-identical to `b57404773`.
- `test/verifiedTests/analysis/testReactingMoieties/testExtractBondSubgraphs.m`: +107. Peeling-reference cases, optional n332 case (absent), `checkSubgraphOrderingContract` (rules 1–5), purpose and authors updated. Existing assertions unchanged.
- `specs/20260921-154310-reacting-moiety-optimisation/reacting-optimisation-reproducibility-results.md`: +21. The row appended by its own check script during T030.
- `CLAUDE.md`: the SPECKIT plan pointer now names this feature's plan (from `/speckit-plan`).
- `.specify/feature.json`: the active feature directory (from `/speckit-specify`).

New (untracked):
- `test/verifiedTests/analysis/testReactingMoieties/data/bondSubgraphPeelingReference.mat` (470,460 bytes).
- `specs/20260928-100409-extract-bond-subgraphs-local-peeling/`: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`, `tasks.md`, `contracts/extractBondSubgraphs.md`, `checklists/requirements.md`, `research-prototype/` (4 scripts), `extractBondSubgraphsBaseline.m`, `extractBondSubgraphsBaselineAssertK.m`, `captureExtractBondSubgraphsInputs.m`, `captureLocalPeelingFixtures.m`, `buildLowSymmetrySubsetModels.m`, `fingerprintBondSubgraphOutputs.m`, `extractBondSubgraphsPeelingCheck.m`, `extractBondSubgraphsPeelingResults.md`, `matlab-practice-notes.md`, `increment-a-story1.patch`, and this receipt.

Outside the repository (not committed): `~/repos/reconXmoieties/experiments/moietySizing/results/outputs/extractBondSubgraphsPeeling/`, holding the six `-inputs.mat` and `-golden.mat` files, `-passcount.mat`, `n332-ci-candidate.mat`, `n1960-endToEnd-golden.mat` and `capture.log`.

## Tests

All runs used MATLAB R2024b Update 8, headless. Full tables are in `extractBondSubgraphsPeelingResults.md`.

- **Unchanged source:** `testExtractBondSubgraphs` PASS. Check-script self-check identical on 6/6 fixtures; pass counts 1,724 / 11,476 / 13,878 / 21,707 / 41,071 / 41,671.
- **Story 1:** `testExtractBondSubgraphs` PASS, `testConservedReactingMoieties` PASS; 6/6 identical; `rmedge` 0; `subgraph` = passes.
- **Stories 1+2:** both tests PASS; 6/6 identical; `rmedge` 0, `subgraph` 0.
- **T025 timing** (median of 3, alternating), new/original: tyr 0.434, n332 0.225, n531 0.173, n1067 0.128, n1604 0.112, n1960 0.100 (77.92 s vs 776.79 s). SC-004 PASS. SC-005: exponents original 1.72, new 1.27, output size 2.34; PASS.
- **T029 end-to-end n1960 (conservedOnly):** `arm`, `moietyFormulae` and `reacting` `isequaln` to the golden run; 857 s vs 1,205 s (the golden run's time includes capture overhead).
- **T030:** `runtests('test/verifiedTests/analysis/testReactingMoieties')` 11/11 PASS. 021/022 Tyrosine checks not run (`RxnFilesNotFound`, stale corpus path). Substitute `reactingOptimisationReproducibilityCheck.m` (`CBT_RMO_NO_TIMING_GATE=1`): 16/16 EQUAL.
- **Static review (T028):** PASS.
- **Research prototypes:** 336/336 inputs equal for both drafts before the source edit.

## Unresolved issues

- **Latent defect in the pre-change loop, preserved by design:** it does not terminate when `ATG.Nodes.Component` is not the `conncomp(ATG)` labelling. The pipeline never takes this path. A fix needs its own spec, because it changes behaviour.
- **Stale 021/022 check scripts:** they hard-code the old corpus path `atomMapped_standardised`. They were not run and not edited.
- **CI MATLAB versions:** not exercised. The ordering-contract assertions in `testExtractBondSubgraphs` are the safeguard.
- **Nothing committed:** commit or push only on the user's instruction.

## Other information

- VII-F: no MATLAB-conventions skill is registered. The practice rules applied are in `matlab-practice-notes.md`, which proposes a project skill.
- Deviations recorded in `tasks.md`/`research.md`:
  - T006 A3 was restricted so the pre-change loop terminates.
  - The local goldens are stored as fingerprints (R8).
  - T024 reads the FR-009 status recorded at capture.
  - T030 used the substitute check, at the user's decision.
- Story 2 shipped (clarification Q1). No deferral.
