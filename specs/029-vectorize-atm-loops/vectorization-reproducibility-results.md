
### Synthetic stage02 section — 2026-09-18 10:43 UTC

| Case | Rows | Original copy ran | Original vs new |
|---|---|---|---|
| mixed | 6 | yes | pending T011a (new-block copy not yet added) |
| empty | 0 | yes | pending T011a (new-block copy not yet added) |
| allForward | 3 | yes | pending T011a (new-block copy not yet added) |
| allReverse | 3 | yes | pending T011a (new-block copy not yet added) |
| orientationZero | 2 | yes | pending T011a (new-block copy not yet added) |
| 2026-09-18 10:44 | nglycan | 0 | capture | CAPTURED | 3 | 9 | - | - | - | yes | 0.1760 | 0.4708 | 17223, 224 flagged | in repo (0.0 MB) | 4b8409d5cf25+src-uncommitted | (commit marker corrected by hand: this row predates the shortCommit fix; the snapshot itself stores the full string) |
| 2026-09-18 10:44 | phe | 0 | capture | CAPTURED | 14 | 42 | - | - | - | yes | 0.8106 | 1.1317 | 17223, 224 flagged | in repo (0.1 MB) | 4b8409d5cf25+src-uncommitted |  |
| 2026-09-18 10:45 | andest | 0 | capture | CAPTURED | 29 | 69 | - | - | - | yes | 1.6868 | 2.2491 | 17223, 224 flagged | in repo (0.2 MB) | 4b8409d5cf25+src-uncommitted |  |
| 2026-09-18 10:45 | chol | 0 | capture | CAPTURED | 61 | 125 | - | - | - | yes | 6.4982 | 6.6149 | 17223, 224 flagged | in repo (0.5 MB) | 4b8409d5cf25+src-uncommitted |  |
| 2026-09-18 10:46 | urea | 0 | capture | CAPTURED | 67 | 132 | - | - | - | yes | 2.2060 | 2.8094 | 17223, 224 flagged | in repo (0.3 MB) | 4b8409d5cf25+src-uncommitted |  |
| 2026-09-18 10:46 | tyr | 0 | capture | CAPTURED | 127 | 197 | - | - | - | yes | 6.1070 | 5.0455 | 17223, 224 flagged | in repo (0.4 MB) | 4b8409d5cf25+src-uncommitted |  |
| 2026-09-18 10:49 | bileacid | 0 | capture | CAPTURED | 145 | 217 | - | - | - | yes | 28.7577 | 22.1994 | 17223, 224 flagged | in repo (1.2 MB) | 4b8409d5cf25+src-uncommitted |  |
| 2026-09-18 10:50 | tyr | 1 | capture | CAPTURED | 127 | 197 | - | - | - | yes | 9.1775 | 7.9449 | 17223, 224 flagged | in repo (0.4 MB) | 4b8409d5cf25+src-uncommitted |  |
| 2026-09-18 11:03 | pufa | 0 | capture | CAPTURED | 682 | 924 | - | - | - | yes | 309.3576 | 312.7922 | 17223, 224 flagged | in repo (4.6 MB) | 4b8409d5cf25+src-uncommitted |  |

### Synthetic stage02 section — 2026-09-18 11:07 UTC

| Case | Rows | Original copy ran | Original vs new |
|---|---|---|---|
| mixed | 6 | yes | identical (isequal) |
| empty | 0 | yes | identical (isequal) |
| allForward | 3 | yes | identical (isequal) |
| allReverse | 3 | yes | identical (isequal) |
| orientationZero | 2 | yes | identical (isequal) |
| 2026-09-18 11:08 | nglycan | 0 | compare | PASS | 3 | 9 | yes | yes | yes | yes | 0.1760 -> 0.0242 (7.3x) | 0.4708 -> 0.4740 (1.0x) | 17223, 224 flagged | in repo | 4b8409d5cf25+src-uncommitted |  |
| 2026-09-18 11:08 | phe | 0 | compare | PASS | 14 | 42 | yes | yes | yes | yes | 0.8106 -> 0.0164 (49.3x) | 1.1317 -> 1.3980 (0.8x) | 17223, 224 flagged | in repo | 4b8409d5cf25+src-uncommitted |  |
| 2026-09-18 11:08 | andest | 0 | compare | PASS | 29 | 69 | yes | yes | yes | yes | 1.6868 -> 0.0116 (145.9x) | 2.2491 -> 2.6742 (0.8x) | 17223, 224 flagged | in repo | 4b8409d5cf25+src-uncommitted |  |
| 2026-09-18 11:09 | chol | 0 | compare | PASS | 61 | 125 | yes | yes | yes | yes | 6.4982 -> 0.0315 (206.2x) | 6.6149 -> 6.5863 (1.0x) | 17223, 224 flagged | in repo | 4b8409d5cf25+src-uncommitted |  |
| 2026-09-18 11:09 | urea | 0 | compare | PASS | 67 | 132 | yes | yes | yes | yes | 2.2060 -> 0.0173 (127.5x) | 2.8094 -> 2.8256 (1.0x) | 17223, 224 flagged | in repo | 4b8409d5cf25+src-uncommitted |  |
| 2026-09-18 11:10 | tyr | 0 | compare | PASS | 127 | 197 | yes | yes | yes | yes | 6.1070 -> 0.0302 (202.4x) | 5.0455 -> 6.2334 (0.8x) | 17223, 224 flagged | in repo | 4b8409d5cf25+src-uncommitted |  |
| 2026-09-18 11:12 | bileacid | 0 | compare | PASS | 145 | 217 | yes | yes | yes | yes | 28.7577 -> 0.1016 (283.1x) | 22.1994 -> 23.8226 (0.9x) | 17223, 224 flagged | in repo | 4b8409d5cf25+src-uncommitted |  |
| 2026-09-18 11:13 | tyr | 1 | compare | PASS | 127 | 197 | yes | yes | yes | yes | 9.1775 -> 0.0493 (186.0x) | 7.9449 -> 5.0684 (1.6x) | 17223, 224 flagged | in repo | 4b8409d5cf25+src-uncommitted |  |
| 2026-09-18 11:14 | nglycan | 0 | compare | PASS | 3 | 9 | yes | yes | yes | yes | 0.1760 -> 0.0230 (7.6x) | 0.4708 -> 0.0754 (6.2x) | 17223, 224 flagged | in repo | 4b8409d5cf25+src-uncommitted |  |
| 2026-09-18 11:14 | phe | 0 | compare | PASS | 14 | 42 | yes | yes | yes | yes | 0.8106 -> 0.0175 (46.4x) | 1.1317 -> 0.0116 (97.7x) | 17223, 224 flagged | in repo | 4b8409d5cf25+src-uncommitted |  |
| 2026-09-18 11:15 | andest | 0 | compare | PASS | 29 | 69 | yes | yes | yes | yes | 1.6868 -> 0.0104 (162.3x) | 2.2491 -> 0.0098 (230.6x) | 17223, 224 flagged | in repo | 4b8409d5cf25+src-uncommitted |  |
| 2026-09-18 11:15 | chol | 0 | compare | PASS | 61 | 125 | yes | yes | yes | yes | 6.4982 -> 0.0326 (199.2x) | 6.6149 -> 0.0094 (704.3x) | 17223, 224 flagged | in repo | 4b8409d5cf25+src-uncommitted |  |
| 2026-09-18 11:15 | urea | 0 | compare | PASS | 67 | 132 | yes | yes | yes | yes | 2.2060 -> 0.0147 (149.8x) | 2.8094 -> 0.0206 (136.4x) | 17223, 224 flagged | in repo | 4b8409d5cf25+src-uncommitted |  |
| 2026-09-18 11:16 | tyr | 0 | compare | PASS | 127 | 197 | yes | yes | yes | yes | 6.1070 -> 0.0340 (179.6x) | 5.0455 -> 0.0061 (823.9x) | 17223, 224 flagged | in repo | 4b8409d5cf25+src-uncommitted |  |
| 2026-09-18 11:17 | bileacid | 0 | compare | PASS | 145 | 217 | yes | yes | yes | yes | 28.7577 -> 0.0996 (288.7x) | 22.1994 -> 0.0108 (2062.8x) | 17223, 224 flagged | in repo | 4b8409d5cf25+src-uncommitted |  |
| 2026-09-18 11:25 | pufa | 0 | compare | PASS | 682 | 924 | yes | yes | yes | yes | 309.3576 -> 0.5831 (530.6x) | 312.7922 -> 0.0925 (3381.2x) | 17223, 224 flagged | in repo | 4b8409d5cf25+src-uncommitted |  |

## Summary (T019) — SC-004 and overall outcome, 2026-09-18

**Correctness**: every fixture passes in compare mode with both rewrites in place — `ATM.Edges`,
`BIG.Nodes` and `BIG.Edges` byte-identical (`isequal`) to the pre-change golden baseline on all 8
fixtures (`nglycan`, `phe`, `andest`, `chol`, `urea`, `tyr`, `bileacid`, `pufa`), every run
against the same corpus provenance (17,223 top-level `.rxn`, 224 in `flagged_for_review/`) that
the baseline was captured with. The `BIG`/`dATM` node guard held on every fixture. The
`sanityChecks = 1` pass on `tyr` also matched (T008a/T012a), and the synthetic stage02 section
showed the rewrite identical to the original loop on all 5 edge cases, including
orientation-`0` rows (research.md R1).

**SC-004 (`tyr`, both rewrites in place)**:

| Hotspot | Before (s) | After (s) | Speedup | Floor | Met? |
|---|---|---|---|---|---|
| stage02 reorientation | 6.1070 | 0.0340 | **179.6x** | ≥100x | yes |
| `createBIGraph` | 5.0455 | 0.0061 | **823.9x** | ≥200x | yes |

(The US1-only compare run measured stage02 at 202.4x on `tyr`; both figures clear the floor.)

**Largest fixture (`pufa`, 682 reactions)**: stage02 309.36 s -> 0.58 s (530.6x);
`createBIGraph` 312.79 s -> 0.09 s (3381.2x). Together about 10.4 minutes removed per run.

**Measurement conditions, stated honestly**: baseline and compare runs shared the machine
(12 cores) with up to two unrelated long-running MATLAB diagnostic jobs from the feature-028
`pufa` investigation, so absolute timings carry some load noise. Each run is single-threaded
MATLAB, and the speedups are one to three orders of magnitude, far outside that noise; no floor
was close to the threshold. Timings came from the temporary capture hook (stage02) and from the
harness timing its own `createBIGraph` call, per research.md R10.

**The one deliberate behaviour change**: zero-edge input to `createBIGraph` now returns an empty
`BIG` instead of crashing (spec Clarifications, zero-edge entry); pinned by `testCreateBIGraph.m`
case (e), which failed before the rewrite and passes after.
