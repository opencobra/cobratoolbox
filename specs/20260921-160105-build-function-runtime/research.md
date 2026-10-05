# Research: build-function runtime reductions

Phase 0 of `/speckit-plan` for `specs/20260921-160105-build-function-runtime/spec.md`. Every
decision below was checked against the current source on this branch (`a4a9f6d70`, which
is `develop` `64efe1dc8` plus the spec). Line numbers are from that revision.

## R1: Where the five parses per reaction come from

- **Investigation**: `readABRXNFile` is called from:
  - `checkABRXNFiles.m:102` and, through `addBondMappingsRXNFile`, `:118`: block 1, run for
    the first reaction that has an RXN file only (the decompartmentalisation probe; the flag
    is reset at `:143`).
  - `checkABRXNFiles.m:154` and, through `addBondMappingsRXNFile`, `:163`: block 2, every
    reaction with an RXN file.
  - `buildAtomAndBondTransitionMultigraph.m:191`: the atom-side decompartmentalisation probe,
    first mapped reaction only, between the check pass and the atom loop.
  - `buildAtomAndBondTransitionMultigraph.m:260`: atom loop, every mapped reaction.
  - `buildAtomAndBondTransitionMultigraph.m:636` and, through `addBondMappingsRXNFile`, `:637`:
    bond loop, every mapped reaction.
  - `addBondMappingsRXNFile.m:62`: its own parse on every call.

  For `r` mapped reactions this is `2r + 2` (check pass) `+ 1` (probe) `+ r` (atom loop)
  `+ 2r` (bond loop) `= 5r + 3`; for bileacid, `r = 143` gives 718, the profiled count.
- **Decision**: remove the redundant parse in each pass as follows.
  - **Check pass**: block 1 parses once and hands `atoms`/`bonds` to
    `addBondMappingsRXNFile`. Block 2 parses once and hands them on, except for the reaction
    block 1 just handled, where it reuses block 1's `atoms`/`bonds` (one reaction's tables,
    already live in the same loop iteration). Every `addBondMappingsRXNFile` call stays
    where it is (see R5).
  - **Atom loop and probe**: unchanged (FR-010 puts the atom-loop body out of scope, and
    reusing the probe's parse would mean keeping a parse across passes, which FR-006 forbids).
  - **Bond loop**: `:637` becomes `addBondMappingsRXNFile(model.rxns{i}, RXNFileDir, atoms, bonds)`.
- **Resulting count**: `r` (check) `+ 1` (probe) `+ r` (atom) `+ r` (bond) `= 3r + 1`; 430 on
  bileacid, within the spec's "at most about 431". Each of the three passes parses each
  reaction exactly once. The first mapped reaction is still parsed four times in total because
  of the probe, which lies outside the three passes. SC-005 now states this directly
  (spec Clarifications 2026-09-22): at most once per reaction per pass, plus the one probe
  read; total ≤ 3r + 2.
- **Rationale**: this is the largest parse reduction that keeps no parsed result beyond the
  loop iteration that produced it.
- **Alternatives considered**: a per-model cache keyed by reaction (rejected by FR-006,
  clarification 2); passing the check pass's parses into the build function (same objection,
  and it would change `checkABRXNFiles`'s call form, FR-007); dropping block 1's
  `addBondMappingsRXNFile` call because its result is discarded (rejected, R5).

## R2: Equivalence of a pre-parsed call to `addBondMappingsRXNFile`

- **Investigation**: `addBondMappingsRXNFile` normalises `rxnfileName` (strips `.rxn`) and
  `rxnfileDirectory` (adds `filesep`) and then calls `readABRXNFile(rxnfileName, rxnfileDirectory)`.
  `readABRXNFile` applies the same two normalisations itself (`readABRXNFile.m:47`, `:61`) and
  its default `options.readBonds = 1`. The callers pass the same reaction identifier and the
  directory without a trailing separator, and use default options. `readABRXNFile` is
  deterministic (it reads a file and has no state). MATLAB tables are value objects, so
  `addBondMappingsRXNFile`'s `bonds.bondIndex = ...` (`:87`) changes only its local copy, never
  the caller's `bonds`.
- **Decision**: add two optional trailing inputs, `atoms` and `bonds`. The function parses
  the file itself when either is absent or empty
  (`~exist('atoms','var') || isempty(atoms) || ~exist('bonds','var') || isempty(bonds)`,
  Principle VII-D, no `nargin`); otherwise it uses them. The two-input call form is unchanged.
- **Rationale**: an empty-table parse result falls back to a fresh parse, which returns the
  same table, so the fallback cannot change the result; it can only cost one extra parse on a
  degenerate file.
- **Alternatives considered**: a single `parsed` struct input (rejected: less discoverable
  and no advantage); a new internal helper function (rejected: new `src/` file, FR-010).

## R3: The `energy` table (FR-003)

- **Investigation**: `addBondMappingsRXNFile.m:163` builds a one-row, 14-variable table on
  every iteration of `for i = 1:size(bondMappings,1)`. It is read only in the two branches at
  `:164` (broken bond) and `:173` (formed bond), each of which overwrites four fields and
  appends it. Facts checked: the loop bound is evaluated once, so appended energy rows are not
  iterated; the two branches cannot both fire in one iteration (`isReacting(i)` cannot be both
  `< 0` and `> 0`, and the first sets `bondTransitionNrs(i)` non-zero); the variable names come
  from `bondMappings.Properties.VariableNames`, which the loop never changes; `rxnfileName` is
  fixed before the loop; `energy` is not used after the loop or returned.
- **Decision**: move the unchanged `energy = table(...)` statement into the start of each of
  the two branches, before the four field writes, keeping the literal constructor arguments
  and the historical comment.
- **Rationale**: each branch then sees exactly the table it saw before, so rows, values,
  order, and variable types are the same by construction. The number of constructions equals
  the number of reacting-bond rows that take a branch (SC-005).
- **Alternatives considered**: building one template before the loop and copying it
  (faster still, but FR-003 and SC-005 require construction only where used and an equal
  count); collecting energy rows and appending once after the loop (changes the row
  arithmetic `bondMappings.bondIndex(size(bondMappings,1))+1` that numbers each energy row, so
  it risks different `bondIndex` values; out of scope).

## R4: Vectorising `dBTM.Nodes.BondElmts` (FR-004)

- **Investigation**: `buildAtomAndBondTransitionMultigraph.m:809-813` assigns one cell per
  bond node into the digraph's node table (`dBTM.Nodes.BondElmts(i) = ...`) and reads
  `dATME.Nodes` twice per iteration; each `dATME.Nodes` / `dBTM.Nodes` access copies the node
  table, which is why the per-bond cost grows with size. The string is
  `[Element{BondHeadAtomIndex(i)} '-' Element{BondTailAtomIndex(i)}]` (the loop's variable
  names are swapped). `BondHeadAtomIndex` and `BondTailAtomIndex` in the node table are the
  same vectors passed to `addvars` at `:807`, and `addvars` does not reorder rows. `dATME` is
  whatever the last bond-loop iteration left, and if no iteration assigned it, the loop only
  avoids an "undefined variable" error because the node table is then empty.
- **Decision**: after `addvars` (the column position and the `addvars` call are unchanged),
  when `height(dBTM.Nodes) > 0`: read `dATME.Nodes.Element` once into a local cell, index it
  with `full(dBTM.Nodes.BondHeadAtomIndex)` and `full(dBTM.Nodes.BondTailAtomIndex)` (column
  vectors), build the strings with
  `cellfun(@(a, b) [a '-' b], headElmts, tailElmts, 'UniformOutput', false)`, and assign the
  whole column once. When the table is empty, do nothing, exactly as the empty loop did.
- **Rationale**: the same `[a '-' b]` expression and the same `dATME` give the same strings;
  one node-table write replaces 16,671 on bileacid. A `NaN`, zero, non-integer or
  out-of-range index still raises MATLAB's indexing error (from a paren index instead of a
  brace index; FR-004 requires an error, not its wording). `full` guards against a sparse
  index vector from `mapAontoBOld`, and is a no-op on a full one.
- **Alternatives considered**: `strcat` (rejected: its whitespace handling differs between
  char and cell inputs, a needless risk); computing the column before `addvars` and passing it
  in (equivalent, but moving the error before `addvars` is a larger diff for no gain).

## R5: Messages, warnings and errors (FR-008, FR-009)

- **Investigation**: `readABRXNFile` emits five `warning`s and two `fprintf` lines per parse
  and one `error` (`readABRXNFile.m:73, 115, 169, 212, 219, 222, 226, 237`). These may now
  appear fewer times. `addBondMappingsRXNFile` emits one warning of its own (`:81`,
  unbalanced substrate/product graphs), once per call, not per parse; FR-011 requires its
  count to be unchanged, so no `addBondMappingsRXNFile` call is removed (this is why R1 keeps
  block 1's call even though its result is discarded). An error in block 1 propagates out of
  `checkABRXNFiles` (`rethrow`), one in block 2 is caught and reported with `getReport(ME)`;
  in both versions, the first failing statement of a reaction is the same, because the
  statement order within each block is unchanged.
- **Stack-frame text (interpretation to confirm)**: two kinds of console line carry source
  locations and will change even though no message does: (a) the warning backtrace lines
  (`> In readABRXNFile (line 73)` / `In addBondMappingsRXNFile (line 62)` ...) — a
  `readABRXNFile` warning raised from inside `addBondMappingsRXNFile` loses that frame when the
  parse moves to the caller, and a warning from `addBondMappingsRXNFile.m:81` moves down by the
  number of header lines added; (b) `getReport` output after a caught error
  (`Error in checkABRXNFiles (line 154)` plus the echoed source line), whose line numbers
  shift when lines are added above. **Decision**: the console comparison (FR-011) treats these
  stack-frame lines as location metadata, not message text. They are removed from both texts
  before the counting rule is applied, and every removed frame that differs is listed in the
  results file for review. Message lines, including `Warning:` and error-message lines, are
  compared exactly. The user confirmed this on 2026-09-22, and it is now written into spec
  FR-009/FR-011 (Clarifications, Session 2026-09-22). The alternative, keeping every line
  number fixed in three edited files, is not practicable without distorting the code.
- **Classification rule**: a message line counts as "printed by `readABRXNFile`" when it
  matches one of the eight templates above turned into regular expressions (the `%s`
  reaction identifier and formula as wildcards). All other message lines must be identical in
  sequence after the `readABRXNFile` lines are removed from both texts; each `readABRXNFile`
  line must satisfy `1 ≤ count_modified ≤ count_original` and appear in both.

## R6: Memory bound (FR-006)

- **Decision**: no new variable outlives the loop iteration that creates it. The only reuse,
  block 1 to block 2 in `checkABRXNFiles`, is within one iteration of `for i = 1:nRxns` and
  holds one reaction's `atoms`/`bonds`, variables that already existed there before this
  change. The pre-parsed argument is passed by value with copy-on-write; the one copy made
  when `addBondMappingsRXNFile` adds `bondIndex` replaces the table its own parse used to
  allocate. So peak memory is, by construction, not higher than before.
- **Measurement**: the harness also records each run's peak resident memory (Linux
  `/proc/self/status` `VmHWM`, read at the end of a fresh `matlab -batch` process for
  each fixture and version; MATLAB's `memory` is Windows-only). Gate (spec Edge Cases,
  Clarifications 2026-09-22): modified ≤ original + max(0.05 × original, 50 MB); larger
  differences are a failure to investigate.

## R7: Golden snapshot, timing and counts (FR-011, FR-012)

- **Baseline code**: the unmodified three files are extracted with
  `git show 64efe1dc8:<path>` into a temporary directory (outside the repository) that is
  put at the front of the path for "original" runs and removed for "modified" runs, with
  `clear functions` and `rehash` after each switch. All other functions resolve to the
  working tree, which is unchanged outside these three files. This lets the harness alternate
  versions in one session and re-measure the original after the source edit.
- **Capture before any source edit** (029 R9 precedent): per fixture, the twelve outputs in
  default and dense mode, `checkABRXNFiles`'s three outputs, `addBondMappingsRXNFile`'s
  `bondMappings` for every RXN file the fixture's reactions reference, the `diary` text of
  one default-mode call, and provenance (corpus path, top-level `.rxn` count, sorted
  `flagged_for_review/` list, submodel file path and its modification time, reaction and
  metabolite counts). Stored as `snapshots/<fixture>-golden-snapshot.mat` (compressed `-v7`);
  if the directory exceeds 10 MB, stop and ask before committing it (the 029 snapshots were
  7.8 MB).
- **Fixtures**: `nglycan`, `phe`, `andest`, `chol`, `urea`, `tyr`, `bileacid` from
  `~/repos/ReconXKG-cidev/ReconXKGtoCobra/models/subsystemSubModels/subsystemSubModels.mat`
  with the corpus `/media/JACK/repos/ctf/rxns/atomMapped_std` (029 R8; both confirmed present
  on 2026-09-22, 17,075 top-level `.rxn` files), plus the CI fixture (Recon3D
  `r0317`/`ACONTm`/`r0426`, `test/verifiedTests/analysis/testReactingMoieties/data/rxnFiles`).
  Optional `pufa` (FR-014). If provenance differs from the snapshot, report
  "corpus changed since capture" instead of a regression (029 R9).
- **Timing**: per fixture, 5 whole-function runs of each version with `sanityChecks = 1`
  and default options, alternating (original, modified, original, ...), after one untimed
  warm-up of each. Report both medians, the ratio, and the original's half-range
  `(max − min)/2` as the noise estimate. Pass: modified median ≤ original median + noise; on a
  shortfall, repeat the fixture once before recording a failure. The profile-based reference
  (the targeted share of profiled time) is reported for comparison only.
- **Counts**: one profiled run per version on bileacid (and every fixture, since it is
  cheap): `readABRXNFile` `NumCalls` from `profile('info').FunctionTable`, and the
  execution count of the `energy = table(` line(s) from that function's `ExecutedLines`,
  compared with the number of rows taking a reacting branch, which equals the number of
  energy rows in the returned `bondMappings` (rows whose `mets` is the reaction identifier,
  one appended per reacting-branch row). Original: one construction per row; modified: one per
  energy row. No counting code is added to `src/`.
- **Output**: append-only `reproducibility-results.md` in the feature directory; the
  harness is `buildRuntimeReproducibilityCheck.m` there, not in `src/` or `test/` (IX).

## R8: CI tests (FR-013)

- **Fixture**: the 18 shipped files in
  `test/verifiedTests/analysis/testReactingMoieties/data/rxnFiles` and the Recon3D submodel
  already used by the two existing tests (no new external data).
- **Expected values**: captured from the unmodified functions before any source edit and
  stored beside the tests as `data/addBondMappingsRXNFileExpected.mat` and
  `data/checkABRXNFilesExpected.mat` (small; tables and logical/NaN vectors). The capture is
  a mode of the feature harness, so it runs against the baseline copies of R7.
- **Derived failure fixtures**, built at test time in a `tempname` directory removed in an
  `onCleanup`: (i) *missing*: the submodel plus one reaction with no RXN file (a copy of a
  submodel reaction under a new identifier); (ii) *unparsable*: a copy of the shipped files
  in which one non-first reaction's file is replaced by a fixed truncated text (its header
  lines only), which makes `readABRXNFile` throw; the capture uses the same construction.
  The first mapped reaction is never the broken one, because a block-1 failure rethrows and
  would test only that an error occurs (covered separately with `verifyCobraFunctionError`
  on a fixture whose first file is broken).
- **`testAddBondMappingsRXNFile.m`**: for every shipped RXN file, the two-input call and the
  four-input call (with `readABRXNFile`'s output) are `isequaln` to each other and to the
  stored table; empty `atoms`/`bonds` falls back to parsing; a missing file errors in both
  forms.
- **`testCheckABRXNFiles.m`**: all ten quality fields of `modelOut` and both counts equal the
  stored values on the CI submodel and on (i) and (ii); (ii)'s `RXNParsedBool` entry is 0.
- **Conventions**: `prepareTest()` with no requirements (no solver used), `assert`-based,
  exact equality for these discrete/NaN values via `isequaln`, output kept to the functions'
  own prints, no `evalc`, no warning suppression, header per VII-E.

## R9: MATLAB best-practice discovery (VII-F)

- No registered skill covers MATLAB conventions (the listed skills are Spec Kit, artifact
  and document skills). The rules applied, from MathWorks documentation already cited in
  features 029 and 20260921-125236 research: index a table variable once into a local
  array instead of dot-indexing inside a loop ("Access Data in Tables", performance note);
  graph `Nodes` returns a copy on each access; `cellfun` with `'UniformOutput', false` for
  cell-of-char results; value semantics and copy-on-write for tables passed to functions;
  `exist(...,'var')` over `nargin` (VII-D). The proposal to add a project MATLAB skill made in
  the earlier features stands; this feature does not add one.

## R10: External-solver configuration audit

- N/A: no solver or external library is called by the changed code or the tests.
