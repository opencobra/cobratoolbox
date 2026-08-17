# Phase 0 Research: Characterize buildGurobiProblemFromModel

No `[NEEDS CLARIFICATION]` markers remain in `spec.md`; this document records the
decisions made from repository inspection rather than open unknowns.

## R1 — Which function does "buildGurobiFromModel" refer to?

- **Decision**: `src/base/solvers/gurobi/buildGurobiProblemFromModel.m`.
- **Rationale**: A repo-wide case-insensitive search for `buildgurobifrommodel`
  returns no matches anywhere in `src/`, `test/`, or documentation — that exact
  name does not exist. The closest and evidently-intended match is
  `buildGurobiProblemFromModel`, the only function in the repository that builds a
  native-Gurobi struct from a COBRA model (confirmed via
  `grep -rli "function.*= *build.*[Gg]urobi"`). Its docstring states it performs
  "the same translation used internally by `solveCobraLP.m`'s `'gurobi'` case,"
  matching the user's intent ("test function ... based on the cobratoolbox
  standards").
- **Alternatives considered**: none — no other candidate function exists.

## R2 — Is this function already covered by a test?

- **Decision**: No. Zero coverage.
- **Rationale**: `grep -rli buildgurobifrommodel .` (whole repo, excluding `.git/`)
  returns nothing under `test/`. The function was introduced in commit
  `03415118f` ("Adding testing functions and fixing the CI license") without an
  accompanying test — this is a genuine Constitution Principle III characterization
  candidate, not a duplicate-coverage situation.

## R3 — What test pattern/style should the new test follow?

- **Decision**: Mirror `test/verifiedTests/base/testSolvers/testBuildOptProblemFromModel.m`
  exactly in structure and idiom.
- **Rationale**: That file is the sibling characterization test for
  `buildOptProblemFromModel`, the function `buildGurobiProblemFromModel` wraps
  internally (`optProblem = buildOptProblemFromModel(model, verify);` at line 42).
  It already demonstrates the accepted house style for this exact situation
  (small toy model built by a local helper function, `isequal`-based exact
  assertions, no solver dependency, standard directory save/restore, minimal
  header) and lives in the same directory the new test belongs in. Reusing it
  minimizes review friction and guarantees consistency with an already-approved
  precedent (feature 009-fba-characterization-statusmap).
- **Alternatives considered**: The more elaborate `testGurobiSettings.m` /
  `benchmarkGurobiSimple.m` style (loads Recon3D, requires a live Gurobi license,
  measures timing) — rejected because it tests solver *behaviour* under various
  parameters, not the pure struct-construction function `buildGurobiProblemFromModel`
  itself, and would incorrectly gate the test behind a Gurobi license the function
  under test does not actually require.

## R4 — Does the test need `prepareTest` / a solver requirement?

- **Decision**: No `prepareTest` call is needed.
- **Rationale**: `buildGurobiProblemFromModel` never calls `gurobi()` — it only
  renames/reshapes fields already computed by `buildOptProblemFromModel` (pure
  model→struct translation, confirmed by reading the full function body, 61
  lines). `testBuildOptProblemFromModel.m` — testing the layer directly
  beneath it — likewise declares no solver requirement. Requiring a solver here
  would narrow CI coverage (skip on solver-less runners) without matching an actual
  dependency of the code under test.

## R5 — What toy model and expected values pin the contract?

- **Decision**: Reuse the same toy-model shape as the sibling test (tiny linear
  pathway, 2 metabolites / 3 reactions) but extend `csense` to include all three
  COBRA senses (`'E'`, `'L'`, `'G'`) in one model, since `buildGurobiProblemFromModel`
  adds sense-translation logic that `buildOptProblemFromModel` characterization
  does not exercise (`buildOptProblemFromModel`'s own sibling test uses an
  all-`'E'` model). A second toy model with `osenseStr = 'min'` covers the
  `modelsense` minimization branch (the sibling's toy model is `'max'`-only).
- **Rationale**: Principle III requires pinning the EXISTING contract with
  concrete, reproducible values; reading `buildGurobiProblemFromModel.m` directly
  (lines 44-58) gives the exact, deterministic mapping to assert against without
  needing to run MATLAB — `sense` defaults to `'='` then is overwritten per-row for
  `'L'`→`'<'` and `'G'`→`'>'`; `modelsense` is `'max'` iff `osense == -1`, else
  `'min'`. These are pure MATLAB semantics (char array indexing, ternary-style
  if/else) with no solver- or platform-dependent behaviour, so tolerances are not
  needed — `isequal` suffices, matching the sibling test's own choice.
- **Alternatives considered**: A genome-scale model (e.g. `Recon3DModel_301.mat`)
  — rejected per `testGuide.rst`'s "please only load *small* models, i.e. less
  than 100 reactions" guidance and because the transformation under test is purely
  structural, not scale-dependent.
