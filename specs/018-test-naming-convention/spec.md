# Feature Specification: Single-Test-Per-Function Naming Convention

**Feature Branch**: `018-test-naming-convention`

**Created**: 2026-08-17

**Status**: Draft

**Input**: User description: "Codify a project-wide test-naming convention in the
constitution: every test file MUST be named test<FunctionName>.m (test + PascalCase
of the source function name), with exactly one test file per source function. When
new characterization work needs to pin behavior not yet covered by an existing test
of that function, the new assertions MUST be added into that function's existing
single test file rather than creating a second, separately-named test file (no
'Characterize' or other infix). Apply this retroactively: merge the 3 existing
testCharacterize<Name>.m files that collide with an already-existing conventional
test of the same function into that conventional test file, then remove the
now-redundant file/directory. A 4th file with no existing counterpart is a pure
rename. Update spec/plan/tasks traceability references. No src/ behavior may
change."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A maintainer always finds one, complete test per function (Priority: P1)

A maintainer looking for the test of a given `src/` function opens
`test/verifiedTests/<category>/` and finds exactly one test file named after that
function (`test<FunctionName>.m`) that already contains every assertion the project
has ever written for it — not a second, differently-named file holding assertions
that were added later and might be missed.

**Why this priority**: This is the entire feature — right now, three functions
(`solveCobraLP`, `optimizeCbModel`, `entropicFluxBalanceAnalysis`) each have their
coverage **split across two files** (an original test and a later
`testCharacterize*` file with a different name), so a maintainer who finds one may
not know the other exists, and CI runs both as unrelated entries instead of one
coherent suite for the function.

**Independent Test**: For each of the three affected functions, confirm
`test/verifiedTests/<category>/` contains exactly one `test<FunctionName>.m` file,
that running it exercises every assertion previously split across the two source
files, and that the old `testCharacterize<FunctionName>.m` file/directory no longer
exists.

**Acceptance Scenarios**:

1. **Given** `solveCobraLP` currently has assertions split between
   `testSolveCobraLP.m` and `testCharacterizeSolveCobraLP.m`, **When** this feature
   is complete, **Then** `test/verifiedTests/base/testSolvers/testSolveCobraLP.m`
   alone contains both sets of assertions and `testCharacterizeSolveCobraLP.m` no
   longer exists.
2. **Given** `optimizeCbModel` currently has assertions split between
   `testOptimizeCbModel.m` and `testCharacterizeOptimizeCbModel.m`, **When** this
   feature is complete, **Then**
   `test/verifiedTests/analysis/testOptimizeCbModel/testOptimizeCbModel.m` alone
   contains both sets of assertions and the
   `testCharacterizeOptimizeCbModel/` directory no longer exists.
3. **Given** `entropicFluxBalanceAnalysis` currently has assertions split between
   `testEntropicFluxBalanceAnalysis.m` and `testCharacterizeEntropicFBA.m`, **When**
   this feature is complete, **Then**
   `test/verifiedTests/base/testEntropicFBA/testEntropicFluxBalanceAnalysis.m`
   alone contains both sets of assertions and the `testCharacterizeEntropicFBA/`
   directory no longer exists.
4. **Given** `buildOptProblemFromModel` currently has its only test named
   `testCharacterizeBuildOptProblemFromModel.m` (no prior conventional test to
   collide with), **When** this feature is complete, **Then** the file is renamed
   to `testBuildOptProblemFromModel.m` with identical content.
5. **Given** any of the four renamed/merged tests, **When** it is run individually
   and as part of the suite, **Then** it passes with no assertion weakened, removed,
   or made order-dependent relative to its pre-merge behaviour.

---

### User Story 2 - Future characterization work extends, not forks, a function's test (Priority: P1)

A contributor adding a characterization test for a function that already has a test
edits that function's existing `test<FunctionName>.m` file to add the new
assertions, instead of creating a new, differently-named file — so the "does this
function have a test, and is it complete" question always has one obvious place to
look, permanently, not just after this one cleanup.

**Why this priority**: Without a durable rule, the same split-coverage problem this
feature fixes today will recur the next time someone characterizes an
already-tested function. The rule, not just the one-time cleanup, is the lasting
value.

**Independent Test**: Read the constitution's testing section; confirm it states
the one-file-per-function naming rule and the instruction to extend an existing
test file rather than create a second one, in language a future contributor (human
or agent) can follow without re-deriving today's decision.

**Acceptance Scenarios**:

1. **Given** the amended constitution, **When** a contributor looks up how to name
   a new test file for `myFunction`, **Then** the answer is unambiguous:
   `testMyFunction.m`.
2. **Given** `myFunction` already has `testMyFunction.m`, **When** a contributor
   needs to add characterization assertions for behaviour that file does not yet
   cover, **Then** the constitution instructs them to add to that file, not create
   `testCharacterizeMyFunction.m` or any other second file for the same function.

---

### User Story 3 - Historical records stay historically accurate (Priority: P3)

A maintainer reading a past feature's spec, plan, tasks, or research document sees
the test file names that were actually current when that feature was implemented;
only the still-open planning artifacts get updated to the new names, and the
point-in-time implementation receipts under `agent-runs/` are left untouched as an
accurate record of what happened at the time.

**Why this priority**: Lowest priority because it is a documentation-hygiene
concern, not the functional core of the feature, but it matters for not corrupting
the project's own audit trail.

**Independent Test**: Grep the repository for the four old test file names after
implementation; confirm no hits remain in live `spec.md`/`plan.md`/`tasks.md`/
`research.md`/`data-model.md`/`quickstart.md`/`human-loop.md`/
`implementation-review.md` files, but hits remain unchanged inside any
`agent-runs/*/implementation-receipt.md`.

**Acceptance Scenarios**:

1. **Given** features 009, 010, 011, and 017 each reference one or more of the four
   old test file names in their live planning documents, **When** this feature is
   complete, **Then** every such reference in those live documents uses the new
   name.
2. **Given** those same features' `agent-runs/*/implementation-receipt.md` files
   also mention the old names, **When** this feature is complete, **Then** those
   receipt files are unchanged.

### Edge Cases

- Merging two files that both declare solver/toolbox requirements via
  `prepareTest` must not silently narrow the merged file's requirements to only one
  side's — the merged file's requirements must remain the union of what each side
  needed for its own assertions to run.
- If both files being merged define local helper functions with the same name but
  different bodies (e.g. both build "a toy model" differently), the merge must not
  let one silently shadow or overwrite the other's fixture — same-purpose overlap
  should be reconciled explicitly, not left as an unreviewed collision.
- The merge must preserve the destination file's pre-existing directory-save/restore
  and header conventions; assertions move, boilerplate does not duplicate.
- A merged file that changes real behaviour visible to `changeCobraSolver` or global
  state (solver selection) must restore that state exactly as the original two files
  did individually, even though they now run in one process instead of two.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The constitution MUST state a binding test-naming rule: every test
  file is named `test<FunctionName>.m`, where `<FunctionName>` is the PascalCase
  form of the corresponding `src/` function's exact name (verbatim capitalization
  of the function name with only the leading letter uppercased, per the existing
  `solveCobraLP` → `testSolveCobraLP.m` pattern), and there is exactly one test file
  per source function.
- **FR-002**: The constitution MUST state that when characterization work
  (Principle III) needs to pin behaviour of a function that already has a test, the
  new assertions are added to that function's existing test file; a second,
  differently-named file for the same function (e.g. a `Characterize` infix) MUST
  NOT be created.
- **FR-003**: `test/verifiedTests/base/testSolvers/testCharacterizeSolveCobraLP.m`'s
  assertions MUST be merged into
  `test/verifiedTests/base/testSolvers/testSolveCobraLP.m`, after which the
  `Characterize` file MUST NOT exist. No assertion from either original file may be
  dropped, weakened, or made order-dependent on the other's fixtures.
- **FR-004**: `test/verifiedTests/analysis/testCharacterizeOptimizeCbModel/testCharacterizeOptimizeCbModel.m`'s
  assertions MUST be merged into
  `test/verifiedTests/analysis/testOptimizeCbModel/testOptimizeCbModel.m`, after
  which the `testCharacterizeOptimizeCbModel/` directory MUST NOT exist. No
  assertion from either original file may be dropped, weakened, or made
  order-dependent on the other's fixtures.
- **FR-005**: `test/verifiedTests/analysis/testCharacterizeEntropicFBA/testCharacterizeEntropicFBA.m`'s
  assertions MUST be merged into
  `test/verifiedTests/base/testEntropicFBA/testEntropicFluxBalanceAnalysis.m`, after
  which the `testCharacterizeEntropicFBA/` directory MUST NOT exist. No assertion
  from either original file may be dropped, weakened, or made order-dependent on the
  other's fixtures.
- **FR-006**: `test/verifiedTests/base/testSolvers/testCharacterizeBuildOptProblemFromModel.m`
  MUST be renamed to
  `test/verifiedTests/base/testSolvers/testBuildOptProblemFromModel.m` with
  unchanged content (no existing conventional test to merge with).
- **FR-007**: Each merged or renamed test MUST continue to declare its solver/
  toolbox requirements via `prepareTest` covering (at minimum) the union of what
  each contributing file declared, so it continues to skip cleanly rather than error
  where a requirement is unavailable.
- **FR-008**: Live planning documents (`spec.md`, `plan.md`, `tasks.md`,
  `research.md`, `data-model.md`, `quickstart.md`, `human-loop.md`,
  `implementation-review.md`) in features 009-fba-characterization-statusmap,
  010-gecko-entropic-fba, 011-entropicfba-dual-fixes, and
  017-buildgurobifrommodel-tests that name one of the four old test file paths MUST
  be updated to the new path. Files under any feature's `agent-runs/*/
  implementation-receipt.md` MUST NOT be modified — they remain accurate,
  point-in-time records of the names that were current when each ran.
- **FR-009**: The feature MUST NOT change the behaviour of `solveCobraLP`,
  `optimizeCbModel`, `entropicFluxBalanceAnalysis`, `buildOptProblemFromModel`, or
  any other `src` function — this is a test-file reorganization and a governance
  (constitution) amendment only.
- **FR-010**: The constitution amendment MUST follow the constitution's own
  Governance section: a Sync Impact Report, a semantic version bump (MINOR, per the
  Governance section's own rule for "materially expanded compliance requirements"),
  and review of dependent Spec Kit templates and `CLAUDE.md`/`AGENTS.md` for
  consistency.

### Key Entities

- **Test file**: a `test/verifiedTests/<category>/test<FunctionName>.m` file; after
  this feature, exactly one exists per characterized/tested `src/` function.
- **Merged assertion set**: the union of assertions from a conventional test and its
  former `Characterize` counterpart, now living in one file.
- **Constitution naming rule**: the new binding clause (Principle III sub-section)
  stating the one-file-per-function convention and the extend-don't-fork
  instruction for future characterization work.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: After the feature, exactly zero files matching
  `testCharacterize*.m` remain in the repository except by design (i.e., none —
  all four are eliminated by merge or rename).
- **SC-002**: `solveCobraLP`, `optimizeCbModel`, and `entropicFluxBalanceAnalysis`
  each have exactly one test file, and running it exercises every assertion that
  existed across both of its pre-merge source files (verifiable by counting
  `assert(` occurrences pre- and post-merge and confirming no reduction).
  `buildOptProblemFromModel` has one test file under its new name.
- **SC-003**: All four affected tests pass individually and within the existing
  suite (`runTestSuite`/`testAll`), with no other previously-passing test
  regressed.
- **SC-004**: No `src` file is changed (verified by an empty `git diff --stat --
  src/`).
- **SC-005**: The constitution's version number is bumped MINOR with a Sync Impact
  Report documenting the new clause, and `documentation/source/guides/testGuide.rst`
  (or an equivalent canonical guide location, per Principle X single-sourcing) is
  updated if the rule needs to live there rather than be restated.
- **SC-006**: A repository-wide search for the four old test file names finds zero
  hits in live planning documents (spec/plan/tasks/research/data-model/quickstart/
  human-loop/implementation-review) and unchanged hits in every
  `agent-runs/*/implementation-receipt.md`.

## Assumptions

- "PascalCase of the function name" means capitalizing only the function's leading
  character (matching every existing example in the repo: `solveCobraLP` →
  `testSolveCobraLP`, `optimizeCbModel` → `testOptimizeCbModel`,
  `buildOptProblemFromModel` → `testBuildOptProblemFromModel`) — not re-casing
  internal capitalization the function name already has.
- Merging is a content operation (moving/reconciling MATLAB assertions and any
  helper functions), not a mechanical file concatenation; where both files build
  similar fixtures for the same purpose, the merged file keeps one fixture and
  points every assertion that needs it at that one fixture, rather than keeping
  duplicate near-identical toy-model builders.
- The three merge targets (`testSolveCobraLP.m`, `testOptimizeCbModel.m`,
  `testEntropicFluxBalanceAnalysis.m`) are the surviving file identity (existing
  file keeps its name and place); the `Characterize` file's content moves into it,
  not the reverse, since the conventional file is the one other code/CI already
  references by name.
- This feature's own new test from 017-buildgurobifrommodel-tests
  (`testBuildGurobiProblemFromModel.m`) already complies with the rule being
  codified here and needs no further change.
- No other `testCharacterize*` files exist beyond the four identified by a
  repository-wide search at spec time; if implementation discovers another, it is
  handled the same way (merge if a conventional counterpart exists, rename if not).

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-003, FR-007 | test/verifiedTests/base/testSolvers/testSolveCobraLP.m | src/base/solvers/solveCobraLP.m |
| US1 / FR-004, FR-007 | test/verifiedTests/analysis/testOptimizeCbModel/testOptimizeCbModel.m | src/analysis/FBA/optimizeCbModel.m |
| US1 / FR-005, FR-007 | test/verifiedTests/base/testEntropicFBA/testEntropicFluxBalanceAnalysis.m | src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m |
| US1 / FR-006 | test/verifiedTests/base/testSolvers/testBuildOptProblemFromModel.m | src/base/solvers/buildOptProblemFromModel.m |
| US2 / FR-001, FR-002, FR-010 | — (no source function; verified by reading the amended `.specify/memory/constitution.md`) | — (no source function) |
| US3 / FR-008 | — (no source function; verified by repository-wide grep per SC-006) | — (no source function) |
| SC-004 / FR-009 | — (no source function; verified by `git diff --stat -- src/`) | — (no source function) |
