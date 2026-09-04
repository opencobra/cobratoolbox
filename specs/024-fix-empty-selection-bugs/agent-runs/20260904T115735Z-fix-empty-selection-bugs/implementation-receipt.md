# Implementation Receipt: 024-fix-empty-selection-bugs

**Run**: 20260904T115735Z-fix-empty-selection-bugs
**Path**: `/speckit-implement` (inline, single-session execution — all 27 tasks in `tasks.md`)

## Prompt

`/speckit-implement` (no additional user input this turn), executing `specs/024-fix-empty-selection-bugs/tasks.md` (27 tasks, T001-T027) against the approved `spec.md`/`plan.md`/`tasks.md` for this feature, following the checklist-complete gate (`checklists/requirements.md`, 16/16 items PASS) confirmed at the start of this run.

## Final response

Both bugs are fixed, tested, and verified with real execution — not just written and assumed correct. MATLAB R2024b turned out to be installed locally (`/usr/local/MATLAB/R2024b`), so I ran everything for real rather than writing blind.

**User Story 1** (`identifyConservedReactingMoieties.m`): added `RM_sets = {}; RM_graph = {};` before the STEP-5 loops. Verified against the real MACACI/rh:14817 pair (one of the four originally-crashing pairs) — reproduced the exact pre-fix crash (`Unrecognized function or variable 'RM_sets'`) live, then confirmed the fix resolves it (`{}` outputs, no error).

**User Story 2** (`buildReactingMoietyTables.m`): removed the `~isempty(F)`/`~isempty(B)` guards so `BondChange` is always assigned, and removed the bare-`table()` special case — one change closes FR-003, FR-004, and FR-009 (the latent third crash found during spec validation) together, since the existing processing pipeline already handles zero rows correctly once the schema is unconditional. Verified live with two new tests using the existing r0317/ACONTm/r0426 fixture plus phantom reaction names: pre-fix, both hit real errors (`table()` schema loss and `vertcat:SizeMismatch`); post-fix, both pass.

**FR-005 amendment** (`~/repos/reconXmoieties/moietySignature/functions/constructCanonicalMoietySignature.m`, the scope widening you approved during `/speckit-plan`): removed the `if isempty(T)` special case there too, for the same reason — it was discarding the schema regardless of what the cobratoolbox fix produced. Verified live with the real RETI3/rh:55352 pair (the actual named US2 reproduction case): pre-fix, reproduced the exact downstream crash (`Unrecognized table variable name 'BondChange'`, inside `compareMoietySignatures.m`'s `reactingPatternSetEqual`); post-fix, `compareMoietySignatures` reaches a real verdict (`MATCH`) without any change to `compareMoietySignatures.m` itself, exactly as scoped.

**Beyond what tasks.md required**: T024 was written as an optional "recommended follow-up" (I didn't expect MATLAB to be available). Since it was, I actually ran all 9 originally-crashing real pairs end-to-end through the fixed pipeline — all 9/9 pass. I also ran the entire `testReactingMoieties` test directory (not just the file I touched) for extra non-regression confidence — 4/4 files pass, no new warnings anywhere.

**One thing I found but did not fix** (out of scope for this feature): glpk's MEX wrapper throws `A cannot be an empty matrix` on the same fully-unconstrained MILP that gurobi solves trivially — a different, unrelated bug in glpk's zero-row handling. I used gurobi throughout and gated the new MACACI/rh:14817 test to skip gracefully (with a warning) if gurobi isn't available, rather than let it fail on this unrelated issue. Worth a separate look if this repo's CI relies on glpk for MILP.

**Files changed**:
- `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m` — fix + header NOTE
- `src/analysis/topology/reactingMoieties/buildReactingMoietyTables.m` — fix + header NOTE
- `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` — extended (US1 + US2 + FR-009 assertions)
- `test/verifiedTests/analysis/testReactingMoieties/data/rxnFiles/MACACI.rxn`, `rh:14817.rxn` — new, vendored fixtures
- `~/repos/reconXmoieties/moietySignature/functions/constructCanonicalMoietySignature.m` — fix (separate repository)
- `~/repos/reconXmoieties/moietySignature/tests/scripts/stage5_pilot_empty_reacting_pattern_schema.m` — new test (separate repository)
- `~/repos/reconXmoieties/moietySignature/tests/data/pilot_empty_reacting_pattern_rxnfiles/` — new, vendored fixtures (separate repository)
- `specs/024-fix-empty-selection-bugs/` — tasks.md and quickstart.md updated to record what was actually done

Nothing is committed in either repository — that's your call. Both `/speckit-git-commit` (cobratoolbox) and a manual commit in reconXmoieties (outside this session's normal workflow) are available whenever you want them.

## Diff summary

**cobratoolbox** (this repo):
- `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m`: +12/-0 (init `RM_sets`/`RM_graph` before STEP-5 loops; header `NOTE:` block)
- `src/analysis/topology/reactingMoieties/buildReactingMoietyTables.m`: +17/-11 (unconditional `BondChange` assignment, removed bare-`table()` branch; header `NOTE:` block)
- `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`: +122/-0 (US1 MACACI/rh:14817 regression; US2 both-empty + one-empty (FR-009) phantom-reaction regressions; non-regression check)
- `test/verifiedTests/analysis/testReactingMoieties/data/rxnFiles/MACACI.rxn`, `rh:14817.rxn`: new files (vendored from reconXmoieties' staged reproduction data)
- `specs/024-fix-empty-selection-bugs/tasks.md`, `quickstart.md`: updated to record actual (not merely planned) execution
- Pre-existing, not from this run: `.specify/feature.json`, `CLAUDE.md` (both already modified before this implementation phase began — `CLAUDE.md` from `/speckit-plan`'s agent-context pointer update), `binary` (pre-existing, unrelated to this feature)

**reconXmoieties** (separate repository, `~/repos/reconXmoieties`):
- `moietySignature/functions/constructCanonicalMoietySignature.m`: +10/-6 (removed the empty-`T` special case; `compareMoietySignatures.m` untouched)
- `moietySignature/tests/scripts/stage5_pilot_empty_reacting_pattern_schema.m`: new file
- `moietySignature/tests/data/pilot_empty_reacting_pattern_rxnfiles/`: new directory (staged RETI3.rxn/rh:55352.rxn)
- Pre-existing, not from this run: `moietySignature/tests/data/pilot16_rxnfiles/*`, `moietySignature/tests/scripts/stage5_pilot_16_category_a_tautomer_overlap.m` (already modified before this session touched the repo)

## Tests

All live-executed via `/usr/local/MATLAB/R2024b/bin/matlab -batch`, `changeCobraSolver('gurobi','MILP',0)`:

- `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` (extended): **1 Passed, 0 Failed, 0 Incomplete** (27.26s). Confirmed pre-fix failures first: `Unrecognized function or variable 'RM_sets'` (US1, real MACACI/rh:14817 data) and `MATLAB:table:vertcat:SizeMismatch` / `Error using tabular/vertcat` (US2/FR-009, real r0317/ACONTm/r0426 data + phantom reactions) — both now pass. `lastwarn()` empty before and after (SC-005).
- Whole `test/verifiedTests/analysis/testReactingMoieties/` directory (`testCanonicalBondKey`, `testClassifySubgraphIsomorphism`, `testConservedReactingMoieties`, `testIdentifyAtomEquivalenceClasses`): **4/4 Passed, 0 Failed** — non-regression beyond the tasks.md-required scope.
- `~/repos/reconXmoieties/moietySignature/tests/scripts/stage5_pilot_empty_reacting_pattern_schema.m` (new): confirmed FAILING pre-amendment (`Unrecognized table variable name 'BondChange'`, real RETI3/rh:55352 data through the full Stage 4-5 pipeline) and **PASSING** post-amendment (`combinedVerdict = "MATCH"`, `forward.reactMatch = true`).
- All 9 originally-crashing real pairs (MACACI/rh:14817, RPE/rh:13677, UDPG4E/rh:22168, UAG4E/rh:20517, RETI3/rh:55352, RETI2/rh:55348, RETI1/rh:19141, MMEm/rh:20553, RE2624M/rh:40455), each hand-built into a minimal combined model from its own staged RXN files and run through the real fixed pipeline: **9/9 PASS** (SC-001, SC-002).

No test failed after the fixes were applied. No behavior was left unverified within this feature's scope.

## Unresolved issues

- **glpk MILP + fully-unconstrained (zero-row) problem**: `solveCobraMILP` via glpk throws `A cannot be an empty matrix` on the exact degenerate MILP this feature's zero-selection case produces (confirmed empirically on MACACI/rh:14817). gurobi handles it correctly. This is a distinct, out-of-scope defect (not in either function this feature touches) — not fixed here. The new MACACI/rh:14817 test gates on gurobi specifically and skips gracefully (with a warning) if unavailable, so it does not fail CI on this unrelated issue, but CI environments relying solely on glpk for MILP would not exercise this specific sub-check. Worth a separate spec/fix if glpk is a supported CI solver for this domain.
- **SC-003** (full 300-pair `exp_positive_control_broad` re-run): not performed — out of scope (requires reconXmoieties' full experiment/notebook harness, not just the two functions and one branch this feature touches). Per spec Assumptions, this was already framed as a recommended, not required, follow-up.
- **reconXmoieties commit**: the `constructCanonicalMoietySignature.m` fix and new test/fixtures are uncommitted in that separate repository. This session did not commit there (no instruction to, and it falls outside this repo's own `/speckit-git-commit` hook, which only covers cobratoolbox).
