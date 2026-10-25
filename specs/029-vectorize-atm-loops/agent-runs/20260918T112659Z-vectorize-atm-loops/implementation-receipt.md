# Implementation Receipt: feature 029-vectorize-atm-loops

**Run**: 2026-09-18, UTC 11:26:59 | **Agent**: Claude Opus 5 (Claude Code) | **Command**: `/speckit-implement`

**Scope of this run**: all 29 tasks in tasks.md (T001-T024, including the suffixed T006a,
T008a, T011a, T012a, T013a). Both user stories implemented and validated.

## Prompt

`/speckit-implement` (no additional user input), invoked on branch `029-vectorize-atm-loops`
after two `/speckit-analyze` rounds reported zero CRITICAL findings and their remediation edits
were applied. One mid-run user decision was taken via a question: zero-edge input to
`createBIGraph` — the user chose "Return an empty BIG (fix it)".

## Final response

> Feature 029 is implemented: all 29 tasks are done, both rewrites are in, and every check passes.
>
> **Correctness.** Both rewrites give byte-identical (`isequal`) output to the pre-change code on all 8 fixtures, including `bileacid` and `pufa`, with every run on the same recorded corpus state as its baseline. The synthetic stage02 section also shows the rewrite identical to the original loop on all 5 edge cases, including orientation-`0` rows (the R1 trap no fixture was guaranteed to contain). The stage02 `sanityChecks` guard, which nothing had previously exercised, passes before and after on `tyr`. Both CI tests pass on the final shipped code: `testConservedReactingMoieties.m` (untouched) and the new `testCreateBIGraph.m`.
>
> **Speed (SC-004, measured on `tyr`):**
>
> | Hotspot | Before | After | Speedup | Floor |
> |---|---|---|---|---|
> | stage02 | 6.11 s | 0.034 s | **180×** | ≥100× |
> | `createBIGraph` | 5.05 s | 0.006 s | **824×** | ≥200× |
>
> On `pufa` (682 reactions): stage02 went from 309 s to 0.58 s and `createBIGraph` from 313 s to 0.09 s, about 10 minutes saved per run.
>
> **One deliberate behaviour change.** The new test found that the old `createBIGraph` crashed on zero-edge input (line 81). Per your decision, it now returns an empty `BIG`; this is recorded in the spec and contract, and pinned by test case (e).
>
> **One design change during the run.** The temporary capture hook can also stop the run right after stage02, since nothing later is needed for the comparison. That cut `pufa`'s baseline capture from hours to about 17 minutes. The hook is fully removed, and the shipped diff is exactly two `src/` files (+35/−44) with no timing or capture code.
>
> **The finding that matters most for your `pufa` goal:** this feature is not the fix for `pufa`'s runtime. The old conserved-only `pufa` run, on pre-change code, went 2 h 48 min into `identifyConservedReactingMoieties` without finishing. This feature removes about 10 of those minutes. At least 2.5 hours are spent somewhere else, and that's the next thing to profile, most usefully with manual `tic`/`toc` stages like the ones that found these two hotspots.
>
> **Not done / open:**
> - Nothing is committed. The changes are ready: 2 `src/` files, 1 new test, and the spec 029 folder including 7.8 MB of snapshots, each under the 10 MB limit.
> - To re-run the reproducibility harness later, T007's temporary hook has to be re-inserted, because that's how it reads `ATM.Edges`.
> - Timings were measured while unrelated diagnostic MATLAB jobs were running. The speedups are far above that noise, but the absolute seconds aren't clean benchmarks.
> - FR-001 still describes the reverse case as `== -1`; the code correctly uses `~= 1`. I proposed a one-line spec fix earlier, and it's still waiting on your go-ahead.
> - The 550-reaction `pufa` diagnostic is still running on pre-change code and will record one more ladder row.

## Diff summary

`cobratoolbox` source (the shipped change, SC-005 — exactly two `src/` files, +35/−44):

- `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m`: the stage02
  `for i=1:nTransInstances` loop (lines 321-335) replaced by vectorized statements —
  `forwardOriented = orientationATM2dATM == 1`, reverse applied to `~forwardOriented`
  (research.md R1), forward `Trans` via `cellfun` over `strtok` (R2), bulk head/tail swap with
  both new columns computed before assignment and `Trans` rebuilt via
  `cellfun(@(h,t)[h '#' t], ...)` (R3). No other line changed; help header untouched.
- `src/analysis/topology/reactingMoieties/createBIGraph.m`: the O(n²) nested accumulation loop
  replaced by `rowIdx = repelem((1:numEdges)', max(floor(Weight), 0))` and one indexed copy per
  property column (R4); the construction tail (`newEdgesTable`, `addedge`, positional property
  assignment) preserved verbatim (R5). Help header untouched.

New CI test:
- `test/verifiedTests/analysis/testReactingMoieties/testCreateBIGraph.m` — characterization test
  on synthetic graphs, cases (a)-(g).

Spec Kit artifacts (`specs/029-vectorize-atm-loops/`):
- `vectorizationReproducibilityCheck.m` — the non-CI harness (T005, T006, T006a, T011a).
- `snapshots/*.mat` — 9 golden snapshots (8 fixtures + `tyr` sanity), 7.8 MB total, each
  ≤10 MB so all kept in-repo (research.md R7).
- `vectorization-reproducibility-results.md` — append-only results plus the T019 summary.
- `spec.md`, `contracts/function-interface.md`, `tasks.md` — zero-edge decision recorded;
  tasks marked `[X]`.

Temporary and removed: the T007 capture hook (9 lines, all marked `% TEMPORARY (029 T007)`) was
added for measurement and deleted in T020; `git diff -- src | grep -E "tic|toc|CBT029_CAPTURE_FILE|TEMPORARY"`
prints nothing.

Outside this repository (not part of the diff): run logs under
`~/repos/reconXmoieties/experiments/moietySizing/results/outputs/vectorization029/logs/`.

## Tests

| Check | Result |
|---|---|
| Harness compare, stage02 `ATM.Edges`, all 8 fixtures (SC-002) | PASS (isequal) |
| Harness compare, `BIG.Nodes`/`BIG.Edges`, all 8 fixtures (SC-003) | PASS (isequal) |
| `BIG`/`dATM` node guard, all 8 fixtures (FR-006) | held |
| `tyr` with `sanityChecks = 1`, before and after (T008a/T012a, FR-006) | PASS |
| Synthetic stage02 section, 5 cases incl. orientation-0 (T011a) | identical |
| `testCreateBIGraph.m` before rewrite | (a)-(d),(f),(g) pass; (e) fails as expected (old crash) |
| `testCreateBIGraph.m` after rewrite | PASS |
| `testConservedReactingMoieties.m` on final shipped code (file unedited) | PASS |
| `testCreateBIGraph.m` on final shipped code | PASS |
| SC-004 on `tyr`: stage02 / `createBIGraph` | 179.6x / 823.9x (floors 100x / 200x) |
| Harness new-block copy vs shipped block (T021, R12) | byte-identical |
| Shipped lines: `evalc`, `nargin`, `try/catch`, `eval`, warning suppression | none |

All MATLAB runs: R2024b Update 8, headless `matlab -batch`, Gurobi configured.

## Unresolved issues

1. **Nothing committed.** Awaiting the user's decision on committing (optional `after_implement`
   git hook).
2. **Harness re-runs need the hook re-inserted.** `ATM` is internal, so the reproducibility check
   reads it only through T007's temporary hook, which has been removed (by design, R10).
3. **Timing load noise.** Baseline and compare runs overlapped with unrelated feature-028
   diagnostic MATLAB jobs; speedups far exceed the noise, absolute seconds are not clean
   benchmarks.
4. **FR-001 wording.** It still describes the reverse case as `orientation == -1`; the
   implementation correctly uses `~= 1` (R1). A one-line spec clarification was proposed and is
   awaiting approval — documentation only, no code impact.
5. **`pufa`'s dominant cost is elsewhere.** A pre-change conserved-only `pufa` run exceeded
   2 h 48 min in `identifyConservedReactingMoieties` without finishing; this feature removes
   about 10 minutes of that. Out of scope here; the obvious next investigation.

## Other information

The harness's stop-after-capture option (`CBT029_STOP_AFTER_CAPTURE`, part of the temporary
T007 hook) was an implementation-time refinement not spelled out in tasks.md: it ends the call
right after the stage02 capture, which is sound because both compared outputs are available by
then (`ATM.Edges` from the hook, `BIG` from the harness's own `createBIGraph` call). It reduced
`pufa`'s capture from a projected multi-hour run to about 17 minutes, and was removed with the
rest of the hook.
