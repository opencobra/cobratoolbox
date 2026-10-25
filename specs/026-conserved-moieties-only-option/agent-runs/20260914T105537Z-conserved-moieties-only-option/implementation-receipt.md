# Implementation Receipt

## Prompt

"my PI wants me to add an option to the reacting code to allow for only the computation
of the conserved moieties. Once this is implemented, they want me to test against the
original code to determine if they produce the same results." — relayed by the user
regarding `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m`,
driven through this repository's full gated Spec Kit workflow
(`specs/026-conserved-moieties-only-option/`) per Constitution Principle VI, with the user
selecting `/speckit-implement` as the sanctioned implementation invocation at Gate 2.

## Final response

Both parts of your PI's ask are implemented and pushed through the full Spec Kit workflow
on branch `026-conserved-moieties-only-option`:

**1. The option.** `identifyConservedReactingMoieties.m` now accepts
`options.conservedMoietiesOnly` (default `false`, so every existing call site is
unaffected). When set `true`, the function runs the exact same conserved-moiety
computation it always has, then returns immediately after `arm.L` is populated — skipping
the entire reacting-moiety bond-graph/minimum-set-cover section, including the MILP solve,
so it works with no MILP solver installed. `reacting` in this mode comes back as
`struct('computed', false)`, an explicit "not computed" marker rather than partial data.
The function's documentation header is updated to match.

**2. The equivalence test.** `testConservedReactingMoieties.m` (this function's one
existing test file) now also calls the function in conserved-only mode on the same
fixture it already uses, and asserts `arm.L`, `arm.M2M`, `arm.M2R`, and `moietyFormulae`
are identical between that call and the pre-existing full-mode call — plus re-checks the
`L*N = 0` conservation invariant on the conserved-only output. I also relocated the file's
`prepareTest('needsMILP', true)` gate (it used to sit at the very top of the script,
before anything else ran) to sit just before the full-mode call instead, so the new
conserved-only assertions are genuinely exercised even on a machine with no MILP solver —
this was flagged during the pre-implementation cross-artifact analysis (finding F1) and
you approved fixing it as an extra task before I started.

Every pre-existing assertion in that test file is untouched — I diffed to confirm.

**What I could not do**: this device shell has no MATLAB installation, so I was not able
to actually run the extended test file myself. Everything above is implemented and I
traced the logic by hand (the diffs are small and linear — no branching subtlety), but it
is not yet MATLAB-verified. Please run
`test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` (or
`test/testAll.m`) once you're at a MATLAB session, and let me know if anything doesn't
pass — most likely candidate for a surprise is a typo I can't catch by eye, not a logic
error, given how mechanical the change is.

Full detail — spec, plan, tasks, cross-artifact analysis, and this receipt — is in
`specs/026-conserved-moieties-only-option/`.

## Diff summary

- `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m` (+31/-1):
  - Documented `options.conservedMoietiesOnly` under `OPTIONAL INPUTS`, and the new
    `reacting` shape under `OUTPUTS`.
  - Added `~isfield(options,'conservedMoietiesOnly')` default-handling block (mirrors the
    existing `sanityChecks`/`useOpenSourceMoietyTools` pattern exactly).
  - Added an early `return` immediately after `arm.L = L;` and before the reacting-moiety
    section: when `conservedMoietiesOnly` is true, sets `reacting = struct('computed',
    false);` and returns.
- `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
  (+48/-5):
  - Removed the top-of-script `prepareTest('needsMILP', true)` call.
  - Added a conserved-moieties-only call + assertions (`reacting.computed == false`, no
    `selectedReactionNames` field) immediately after the existing `dATM`/`BG` sanity
    assertions, before any MILP-gated code.
  - Re-inserted `prepareTest('needsMILP', true)` immediately before the pre-existing
    full-mode call (the only part of this file that genuinely needs a MILP solver).
  - Added equivalence assertions (`arm.L`, `arm.M2M`, `arm.M2R`, `moietyFormulae` equality;
    re-check of `L*N = 0`) immediately after the pre-existing full-mode assertions.
  - No other line in the file was touched (confirmed via `git diff`).

## Tests

- **Executed by the user, 2026-09-14** (T012): no MATLAB installation is reachable from
  this environment's sandboxed shell (checked: `matlab` not on `PATH`, no
  `/usr/local/MATLAB` or `/opt/matlab*` visible here, no MATLAB MCP server connected this
  session — confirmed this is a genuine sandbox boundary, not a missing install, since the
  user's real `/usr/local/MATLAB/R2024b` is outside the two folders bridged into this
  session). The user ran
  `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` in
  their own MATLAB R2024b session and pasted the full console transcript. Result: the
  script ran end-to-end with no MATLAB error and no failed `assert()`, confirmed to have
  executed past every new assertion this feature adds (conserved-only call, relocated
  `prepareTest('needsMILP', true)`, full-mode call, and all US2 equivalence checks) as well
  as every pre-existing regression section in the file, ending in a clean return to the
  prompt. A MILP solver was available (no `COBRA:RequirementsNotMet` skip occurred).
- **T014 (quickstart.md manual spot-check)**: satisfied via T012's run rather than a
  separately executed interactive snippet — see tasks.md T014 for detail on why the
  automated assertions already cover the same four claims.
- **Static verification performed** (T013, MATLAB coding-standards compliance,
  Constitution Principle VII): no `evalc` introduced; no warning suppressed; no `nargin`
  introduced (`isfield`/`exist`-based option defaulting, matching this file's own existing
  pattern exactly — VII-D); no `try/catch` introduced (none needed for this change); no
  proprietary-toolbox call added; openCOBRA documentation header format followed (VII-E) —
  `{(0),1}` style, indentation, keyword placement matching the existing
  `sanityChecks`/`useOpenSourceMoietyTools` entries.
- **Traced by hand**: every new assertion's expected value follows directly from the
  unmodified conserved-moiety code path being identical in both modes (it is the same
  code, executed then either returned-from or continued-past) — there is no new branching
  logic in the conserved-moiety computation itself for this comparison to get wrong.

## Unresolved issues

- **F2 (accepted risk, from implementation-review.md)**: "no MILP solver required" is
  verified structurally (the new assertions are no longer behind any `prepareTest('needsMILP',
  ...)` gate, so CI will actually run them on a solver-less runner) rather than by a
  positive runtime assertion that `intlinprog`/`solveCobraMILP` was never called — MATLAB
  has no simple built-in for that, and this is accepted as documented in
  implementation-review.md.
- **F3 (accepted risk)**: no task explicitly re-asserts the function's signature is
  unchanged; satisfied implicitly (no task touches the signature line) — documented for
  traceability, not blocking.
- **Committed to git**: per the user's earlier Gate 3 choice ("leave uncommitted for you to
  test") followed by their confirmation that `testConservedReactingMoieties.m` passed
  end-to-end, the two-file diff above was committed on branch
  `026-conserved-moieties-only-option` after this receipt was updated.
- **Stray branch from workflow setup**: an earlier, empty branch,
  `025-conserved-moieties-only-option` (created during this session before the final
  `026-...` name was settled via `--allow-existing-branch`), has no commits beyond
  `develop` and no spec directory. Left untouched per this session's no-destructive-git-
  ops-without-explicit-request policy; the user may want to delete it.
