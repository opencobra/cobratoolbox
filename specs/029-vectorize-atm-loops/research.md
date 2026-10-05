# Phase 0 Research: Vectorize the stage02 reorientation loop and createBIGraph's edge-expansion loop

No open NEEDS CLARIFICATION markers remain in plan.md's Technical Context. The six
spec-level clarifications are recorded in spec.md (Session 2026-09-18); the last two — the
`SCP2x.rxn` quarantine and corpus provenance — retired R6 and added R11. This document
records the implementation-level decisions, every one of which was checked against the actual
source or verified by running MATLAB — because this feature's acceptance bar is `isequal`
output, the traps below are the whole risk surface.

## R1: The stage02 `else` branch is `orientation ~= 1`, not `orientation == -1`

- **Investigation**: `identifyConservedReactingMoieties.m:321-335` reads
  `for i=1:nTransInstances / if orientationATM2dATM(i)==1 ... else ... end`. The
  `orientationATM2dATM` vector is initialised to zeros (line 305) and set to `1`/`-1` by
  `forwardBool`/`reverseBool`. A row that is neither forward nor reverse keeps `0`. The
  `sanityChecks` block at lines 312-316 errors on any `0` — **but only when `sanityChecks` is
  enabled**, and both the CI test's full-mode call and the reconXmoieties fixtures run with
  `options.sanityChecks = 0`.
- **Decision**: Vectorize with `fwdBool = (orientationATM2dATM == 1)` and treat the reverse
  branch as `~fwdBool`, **not** as `orientationATM2dATM == -1`.
- **Rationale**: With `sanityChecks` off, any `0`-orientation row currently takes the `else`
  branch and gets head/tail swapped. Using `== -1` would silently leave such rows untouched —
  different output, failing `isequal`, and only on models that have such rows (i.e. not on the
  small CI fixture). This is the single easiest way to get a rewrite that passes every test we
  run and is still wrong.
- **Alternatives considered**: Treating `0` as an error unconditionally (rejected — changes
  behaviour for `sanityChecks = 0` callers, out of scope and a Principle II break).

## R2: Forward-branch `Trans` rewrite semantics (`strtok` + `rem(2:end)`)

- **Investigation**: The forward branch is `[~,rem]=strtok(ATM.Edges.Trans{i},'#'); ATM.Edges.Trans{i}=rem(2:end);`.
  `strtok(s,'#')` returns the remainder *starting at* the first `#`, so `rem(2:end)` is
  "everything after the first `#`". Two edge cases follow: a `Trans` with no `#` yields
  `rem = ''` and therefore `Trans = ''` (empty, not unchanged); a `Trans` with several `#`
  keeps every subsequent `#` in the result.
- **Decision**: Reproduce with `cellfun` over the forward subset, applying the identical
  `strtok`/`rem(2:end)` expression, with `'UniformOutput', false`.
- **Rationale**: Exactness beats elegance here. `extractAfter(s,'#')` returns `<missing>` when
  the delimiter is absent (not `''`), and `regexprep(s,'^[^#]*#','')` leaves the string
  *unchanged* when absent — both differ from the loop precisely in the no-`#` case.
- **Alternatives considered**: `extractAfter` and `regexprep` (rejected, above); a fully
  index-based split via `strfind` (rejected — more code, same result, more chances to diverge).

## R3: Reverse-branch column swap and `Trans` reconstruction

- **Investigation**: The reverse branch sets `HeadAtomIndex = EndNodes(i,2)`,
  `TailAtomIndex = EndNodes(i,1)`, swaps `HeadAtom`/`TailAtom`, and then sets
  `Trans = [newHeadAtom '#' newTailAtom]` — i.e. the reverse branch does **not** strip a
  reaction prefix; it rebuilds `Trans` from the (swapped) atom names.
- **Decision**: Bulk logical-index assignment for the four scalar/cell columns
  (`HeadAtomIndex`, `TailAtomIndex`, `HeadAtom`, `TailAtom`), then build `Trans` for those rows
  with `cellfun(@(h,t)[h '#' t], newHead, newTail, 'UniformOutput', false)`.
- **Rationale**: `strcat` is the obvious vectorized choice and is wrong here: `strcat` strips
  trailing whitespace from char-array inputs, and its cell-array behaviour differs from plain
  concatenation. `cellfun` with explicit `[h '#' t]` is byte-identical to the loop by
  construction. Note the swap must read the *old* values (compute both new columns before
  assigning either), which is trivial when vectorized but is the classic aliasing bug.
- **Alternatives considered**: `strcat`/`join`/`append` (rejected — whitespace and type
  semantics differ from `[h '#' t]`).

## R4: `createBIGraph` expansion order — `repelem` on row indices

- **Investigation**: `createBIGraph.m:40-61` iterates edges in order and, per edge, appends
  `Weight`-many copies, growing every array with `[array; x]` (the O(n^2) pattern). Every
  property column is copied per instance except `Weight`, which is forced to `1`.
- **Decision**: `rowIdx = repelem((1:numEdges)', max(floor(graphNoE.Edges.Weight), 0));` (count guard below) then index every
  property column by `rowIdx` in one pass, and set `Weight = ones(numel(rowIdx),1)`.
- **Rationale**: `repelem` on row indices reproduces the loop's emission order exactly
  (edge-major, instance-minor), and index-copying a column works identically for numeric and
  cell columns — which matters because `BG.Edges` carries both (spec Edge Cases).
- **Alternatives considered**: Preallocating and filling in a loop (rejected — still a loop,
  far less clear, same result); `repmat` per edge (rejected — wrong order).
- **Guard (applied unconditionally)**: `repelem` requires non-negative integer counts, whereas
  the loop's `for bInstance = 1:bondMult` silently truncates a non-integer `Weight` (`1:2.7` is
  `[1 2]`) and emits nothing for a zero or negative one (`1:0` and `1:-1` are empty). The count
  is therefore `max(floor(Weight), 0)`, which reproduces the loop exactly for any finite
  `Weight` and is a no-op for the expected small positive integers — so it needs no data survey
  to decide. A non-finite `Weight` (`NaN`/`Inf`) is not addressed; neither is expected, and the
  loop's own behaviour on them is not a contract worth preserving.

## R5: `addedge` sorts edges — the construction sequence must be preserved verbatim

- **Investigation (ran MATLAB to confirm)**: `digraph`'s `addedge` stores edges sorted by
  (source, target), not in call order. Probe: inserting `(3,4),(1,2),(3,1),(2,3)` yields stored
  order `(1,2),(2,3),(3,1),(3,4)`; duplicate edges are kept and stay in insertion order
  relative to each other. The current code calls
  `addedge(BIG, newEdgesTable.Source, newEdgesTable.Target)` and *then* assigns each property
  column positionally from `newEdgesTable` — which is only correct if the stored order equals
  the emission order.
- **Decision**: Keep the existing construction sequence exactly — build the same
  `newEdgesTable` in the same order, call `addedge` the same way, assign properties positionally
  afterwards, skipping `EndNodes` as today. Change only how `srcNodes`/`tgtNodes`/`edgeProps`
  are *accumulated*.
- **Rationale**: The positional assignment is safe today because `graphNoE.Edges` comes from an
  undirected `graph` and is therefore already sorted by (min,max) endpoint, so the expanded
  order is sorted and `addedge` preserves it. That is an invariant of the input, not of the
  code. Preserving the sequence keeps the feature a pure accumulation rewrite and keeps the
  `isequal` bar meaningful; building the graph a "better" way (e.g. `digraph(edgeTable)`) risks
  a different row order and would fail the bar.
- **Explicitly NOT fixed here**: if a future input ever arrives unsorted, the positional
  assignment would mis-attach properties. That is a pre-existing latent defect, out of scope
  for this feature (Principle VI — it would need its own spec), and must not be "fixed" as a
  drive-by, since doing so would change output on exactly the inputs it claims to repair.

## R6: `bileacid` harness mirror — RETIRED

- **Status**: Retired by Clarifications (Session 2026-09-18, `SCP2x.rxn` quarantine entry). This
  decision previously designed a harness-local copy of the stage02 logic, proven equivalent to
  the pipeline on a runnable fixture before being trusted for `bileacid`, which then could not
  reach stage02 through the pipeline.
- **Why it is no longer needed**: `bileacid`'s build failure was caused by one corpus file,
  `SCP2x.rxn`, which the user quarantined into `atomMapped_std/flagged_for_review/`. Probed
  2026-09-18: `bileacid` built successfully 3 of 3 times with identical results (21,600 atom
  transitions, 15,905 bond-graph nodes), and `SCP2x` appears in no other subsystem model. Every
  fixture is now validated through the real pipeline, so the shipped code is what gets tested.
- **What this removes**: the feature's one acknowledged drift risk (a copy of the code under test
  diverging from the code actually shipped), a Complexity Tracking entry in plan.md, the
  saved-input capture path, and the mirror-equivalence assertion.
- **Lesson carried forward into R11**: the failure was first read as structural — a code-level
  limitation to route around — when it was a property of a mutable input corpus.

## R7: Golden-snapshot size and placement policy

- **Investigation**: Features 021 and 022 each committed one `tyrosine-golden-snapshot.mat`
  beside their harness in `specs/<feature>/`. This feature needs up to 8 snapshots, and the
  largest fixture is far bigger: `pufa` at 682 reactions produced ~51k atoms / ~53k atom
  transitions at the 450-reaction rung alone (measured 2026-09-17), so its `ATM.Edges` plus
  `BIG.Nodes`/`BIG.Edges` capture is orders of magnitude larger than `tyr`'s.
- **Decision**: One snapshot file per fixture under
  `specs/029-vectorize-atm-loops/snapshots/`. Any snapshot exceeding **10 MB** is *not*
  committed: it is written to the sibling `reconXmoieties` results tree (as this project's
  bulky experiment output already is, per feature 028's precedent), and the results file records
  its path plus a hash. Constitution Principle IX-G (Git LFS for tracked binary `.mat`) applies
  only if a large snapshot is ever deliberately committed, which this policy avoids.
- **Rationale**: Keeps the repository reviewable and avoids committing hundreds of megabytes of
  regenerable intermediate state, while keeping the small fixtures' evidence in-repo where a
  reviewer can actually re-run it.
- **Alternatives considered**: Committing every snapshot with LFS (rejected — heavyweight for
  regenerable data, and the constitution reserves LFS for tracked input data); storing only
  hashes for all fixtures (rejected — passes/fails without saying *where* output diverged,
  which is the first question on a mismatch).

## R8: Harness environment — the corpus path in features 021/022 is stale

- **Investigation**: `specs/022-eliminate-table-object-hotspots/tyrosineReproducibilityCheck.m:46`
  hardcodes `rxnFilesDir = '/media/JACK/repos/ctf/rxns/atomMapped_standardised'`. That directory
  no longer exists; the corpus is now `/media/JACK/repos/ctf/rxns/atomMapped_std` (confirmed
  2026-09-17; the newer reconXmoieties scripts, including the one that built the subsystem
  submodels, already use it).
- **Decision**: The new harness uses `atomMapped_std`, and asserts the directory exists up front
  with a clear message rather than failing deep inside the pipeline. Fixture models are loaded
  from `~/repos/ReconXKG-cidev/ReconXKGtoCobra/models/subsystemSubModels/subsystemSubModels.mat`.
- **Rationale**: Copying the stale constant forward would make the check unrunnable on this
  machine. The 021/022 harnesses are not edited (out of scope, and they are historical records).
- **Note for implementation**: fixture reaction counts in that `.mat` have changed since the
  15 Sept 2026 sizing record (`tyr` is 127, not 140; `pufa` 682, not 732), so the harness must
  record the counts it actually observes rather than hardcoding expected sizes.

## R9: Baseline capture must happen before any source edit

- **Decision**: Task order is: write the harness → run capture mode on all 8 fixtures against
  **unmodified** `src/` → only then apply the two rewrites → run compare mode. `pufa`'s capture
  is a multi-hour background run and may proceed in parallel with writing (but not applying) the
  rewrite.
- **Rationale**: The golden snapshot is by definition pre-change output; once either file is
  edited, the baseline is unrecoverable without `git stash`/checkout gymnastics on a dirty tree.
  Sequencing this explicitly avoids the most expensive possible mistake in this feature (losing a
  multi-hour `pufa` baseline).

## R10: SC-004 timing instrumentation is temporary and reverted

- **Decision**: For the measurement runs only, `src/` gets a temporary stage02 capture hook
  (design below), which records stage02's `tic`/`toc` timing alongside `ATM.Edges`.
  `createBIGraph` is timed by the harness around its own direct call, with no `src/` change.
  The harness records all numbers into `vectorization-reproducibility-results.md`. The hook is
  removed before the feature is committed, and `git diff` must show no timing or capture code.
- **Rationale**: Clarifications chose this over shipping permanent timing fields. It keeps
  SC-006 (unchanged documented signatures) and SC-005 (two-file diff) exactly true, and leaves the
  results file as the durable record. The trade-off — the numbers cannot be reproduced later
  without re-instrumenting — is acceptable because the results file preserves them and the
  check is explicitly non-CI.
- **Hook design (added after `/speckit-analyze` finding U1)**: `ATM` is a local variable of
  `identifyConservedReactingMoieties` and is never returned (`arm.ATG`, line 1457, is a
  different graph built later), so a harness cannot observe `ATM.Edges` from outside. The
  temporary instrumentation is therefore a capture hook, not only a timer: placed immediately
  **after** the stage02 `sanityChecks` block (lines 337-349), it runs
  `save(getenv('CBT029_CAPTURE_FILE'), 'stage02AtmEdges', 'stage02Seconds')` when that
  environment variable is set, and does nothing otherwise. Its position after the
  `sanityChecks` block is deliberate: with `options.sanityChecks = 1`, the capture file exists
  only if that block ran and passed, which gives FR-006's otherwise-unexercised guard a clean
  pass signal (analysis finding G1). It uses `save`/`getenv`, never `evalc` (VII-A).
- **`createBIGraph` needs no instrumentation**: verified that `BG` is not reassigned anywhere in
  `identifyConservedReactingMoieties` before the `createBIGraph(BG)` call at line 566. The
  harness can therefore call `createBIGraph` directly on the build output `BG`, receiving
  exactly the in-function input, and time and capture `BIG` itself. The `BIG`/`dATM` guard at
  line 567 is unconditional, so every pipeline run already exercises it.

## R11: Corpus provenance is recorded with every snapshot

- **Investigation**: On 2026-09-17 and 2026-09-18, `bileacid` produced three different outcomes
  across runs with the same code, fixture file (`subsystemSubModels.mat`, unchanged since
  2026-09-17 14:05), options, and output arity: it failed in this feature's first sweep and in
  the reconXmoieties `createBIGraph` validation at 09:58, then succeeded in the reconXmoieties
  stage02 validation at 10:24. The cause was a corpus edit between runs — the user moved
  `SCP2x.rxn` into `flagged_for_review/`. Nothing in any harness recorded the corpus state, so
  the difference was invisible from the results alone.
- **Decision**: Every golden snapshot and every results-file entry records corpus provenance:
  the corpus path, the count of top-level `.rxn` files (17,223 at the time of writing), and the
  sorted list of files in `flagged_for_review/`. In compare mode, if the current provenance
  differs from the snapshot's, the harness reports **"corpus changed since capture"** and does
  not report an `isequal` mismatch for that fixture as a code regression.
- **Rationale**: This feature's entire correctness argument is `isequal` against a stored
  baseline. A baseline is only meaningful relative to the inputs that produced it, and the
  corpus is edited in place by an active curation workflow. Recording provenance turns a
  silent, misleading mismatch into an explicit, attributable one — which is exactly the
  distinction that was missing when `bileacid` was misdiagnosed.
- **Alternatives considered**: A full content hash of every `.rxn` file (rejected as the default
  — hashing 17k files adds minutes per fixture and is overkill for detecting the file moves and
  quarantines this workflow actually performs; can be added later if content edits in place
  become common); hashing only the files each fixture's reactions reference (a stronger check,
  noted as a possible refinement, but it requires resolving each fixture's reaction list against
  the corpus first).

## R12: Stage02 edge cases are checked on synthetic input via harness copies

- **Problem (`/speckit-analyze` finding G2)**: the spec's stage02 edge cases (empty table,
  all-forward, all-reverse) and research's fidelity traps (orientation-`0` rows per R1, `Trans`
  without `#` or with several `#` per R2) are not guaranteed to appear in the CI fixture or in
  any of the 8 real fixtures. Stage02 is inline code (Clarifications), so no CI test can call it
  directly, and the R1 trap in particular would pass every fixture-based check.
- **Decision (chosen by the user over review-only)**: the harness gains a synthetic-input
  section with two local functions — a verbatim copy of the **original** stage02 loop (added
  before any `src/` edit) and a verbatim copy of the **new** vectorized block (added after the
  rewrite) — run on hand-built `ATM.Edges` tables covering every case above, asserting
  `isequal` between them and logging each case to the results file.
- **Scope, stated plainly**: these copies prove edge-case **semantics** only. They are not
  evidence that the shipped code is correct — the 8 fixture runs through the real pipeline
  remain that proof. This is the same drift risk R6 retired, reintroduced narrowly and
  deliberately.
- **Drift mitigation**: the review task (T021) confirms the new-block copy is character-for-
  character identical to the shipped lines in `identifyConservedReactingMoieties.m`, and the
  original-loop copy is taken from the pre-change file before T011 runs. Both copies are
  labelled in the harness as test copies of `src/` code, naming the source lines.
- **Alternatives considered**: review-only coverage against R1-R3 with the gap stated
  (rejected by the user in favour of executable checks); extracting stage02 into a callable
  `src/` helper so a CI test could call it (rejected in Clarifications — keeps the diff to two
  files).
