# Tier-2 pilot: style note for maintainer review

**Feature**: 20261102-142225-tier2-test-pilot · **Date**: 2026-11-02

The pilot wrote ten Tier-2 tests. Work stops here (FR-010) until the pattern below is approved or
changed; the next batch will follow whatever is decided.

## Results

| Function | Test file | Sections | Line coverage | Runtime | Defects recorded |
|---|---|---:|---|---:|---:|
| extractSubSysModel | testModelManipulation/testExtractSubSysModel.m | 3 | 2/2 | 0.2 s | 1 |
| extractCompModel | testModelManipulation/testExtractCompModel.m | 5 | 18/18 | 0.3 s | 0 |
| keepCompartment | testModelManipulation/testKeepCompartment.m | 3 | 20/20 | 0.3 s | 0 |
| orderModelFields | testModelManipulation/testOrderModelFields.m | 2 | 6/6 | 0.1 s | 0 |
| updateFieldOrderForType | testModelManipulation/testUpdateFieldOrderForType.m | 7 | 17/17 | 0.2 s | 2 |
| removeCompartments | testModelGeneration/testRemoveCompartments.m | 4 | 63/64 (line 93 unreachable, exempted) | 1.4 s | 6 |
| createEmptyFields | testIO/testUtilities/testCreateEmptyFields.m | 7 | 40/40 | 0.1 s | 3 |
| convertOldCouplingFormat | testIO/testUtilities/testConvertOldCouplingFormat.m | 6 | 25/25 | 0.1 s | 0 |
| findRxnFromCompartment | testExploration/testFindRxnFromCompartment.m | 4 | 5/5 | 0.1 s | 1 |
| findMetFromCompartment | testExploration/testFindMetFromCompartment.m | 2 | 8/8 | 0.1 s | 2 |

All ten pass through `runScriptFile` in one MATLAB session, every `%%` section also passes on
its own, no solver is used, and each file loads `ecoli_core_model` once through
`getDistributedModel`. The registry now lists 48 defects in 34 functions (15 new from this pilot).

## Pattern used

1. Header as in Tier 1, plus a "Reference values" paragraph: counts recorded from the first run on
   2026-11-02 with `ecoli_core_model`, no solver; they guard consistency, not independent
   correctness (III-Coverage Tier 5).
2. Before the first `%%`: `prepareTest()`, the model load, and small constants every section needs
   (field-name lists `rxnFields`, `metFields`, `geneFields`) so each section runs alone.
3. Per section: call the function; structural block (size of `S` against `mets`/`rxns`, every
   field of a type has the same length, `rxnGeneMat` size, gene indices in `rules` exist); content
   block (identifiers kept/removed derived independently from `S`, `subSystems` or `rxnGeneMat`;
   columns of `S`, bounds and objective equal to the input; GPRs compared after rewriting `x(i)` by
   gene name); Tier-5 counts with exact equality.
4. Warnings stay visible and are checked with `lastwarn('')` / `lastwarn`; console output is not
   suppressed.

## Decisions requested

1. **Shared assertion helper.** The structural block is repeated inline in every section (helper
   free, research R2), which makes tests long. Option: a small test helper (for example
   `test/verifiedTests/testUtils/assertModelConsistent.m`) used by every Tier-2 test.
   Recommendation: yes, before the next batch; it shortens tests and makes the Tier-2 checks
   uniform.
2. **GPR check by gene name** (rewrite `x(i)` to gene names, compare with the input) whenever genes
   are removed or renumbered. Recommendation: make it the standard Tier-2 check.
3. **Global side effects.** `removeCompartments` runs `warning('OFF')` and never restores it; the
   test restores the saved warning state after each call so later tests are unaffected. Please
   confirm this is "leaving no global state" and not suppression. The five registry severities
   have no category for side effects; it was recorded as `limitation`.
4. **Console volume.** `removeCompartments` prints about 300 lines per call and `keepCompartment`
   about 350 lines per run (each removed reaction once per foreign metabolite). Under the
   no-suppression rule this stays in CI logs until fixed. Should console-volume problems on the
   main path be recorded as `cosmetic` defects? (`keepCompartment`'s was not recorded.)
5. **Documented misuse.** Calls the documentation does not support (for example
   `keepCompartment(model, {'c'})`, which treats `c` as a regular expression, or a char instead
   of a cell) were not recorded as defects. Confirm that only documented inputs count.

## Defects found (summary; details in the test headers and `test/known-defects.md`)

- `removeCompartments`: global `warning('OFF')`; prints `newComp` and the loop index; duplicate
  reactions are not removed although documented; `metNames` returns metabolite IDs as a row;
  an empty `rev` field is left; several fields (`rxnGeneMat`, `rxnNames`, `metFormulas`,
  `csense`, `osenseStr`, `description`, `modelID`) are dropped.
- `createEmptyFields`: `proteinNames` and `comps` defaults from `COBRA_structure_fields.tab` fail;
  a two-dimensional cell field with a computed default fills only its first column.
- `updateFieldOrderForType`: type `'proteins'` is accepted but always errors; repeated indices
  are accepted silently.
- `extractSubSysModel`: a subsystem given as text instead of a cell selects almost every
  reaction.
- `findRxnFromCompartment`: a compartment with one metabolite returns the model's first reaction.
- `findMetFromCompartment`: a compartment with no metabolite errors (output unassigned); a symbol
  without brackets matches any ID containing that letter.

None of these was fixed (III-Defects); `removeCompartments` deserves a fix before other Tier-2
tests depend on it.
