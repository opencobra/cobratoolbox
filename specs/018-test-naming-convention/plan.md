# Implementation Plan: Single-Test-Per-Function Naming Convention

**Branch**: `018-test-naming-convention` | **Date**: 2026-08-17 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/018-test-naming-convention/spec.md`

## Summary

Two-part feature. **Part 1**: amend `.specify/memory/constitution.md` with a new
sub-clause under Principle III — one test file per source function, named
`test<FunctionName>.m`; future characterization work extends that file rather than
creating a `testCharacterize<Name>.m` sibling — following the constitution's own
Governance amendment process (Sync Impact Report, MINOR version bump). **Part 2**:
apply the rule retroactively. Merge three `testCharacterize<Name>.m` files into
the pre-existing conventional test of the same function (content merge: append the
characterization block immediately before the destination file's closing
`cd(currentDir)`, then move any local helper function to the true end of the file
— nothing downstream of the insertion point reads the appended block's locals, so
this ordering is safe by construction, no variable-collision risk). Rename the
fourth (no existing counterpart) in place. Update live spec/plan/tasks/research/
data-model/quickstart/human-loop/implementation-review references in features 009,
010, 011, and 017; historical `agent-runs/*/implementation-receipt.md` files are
untouched. No `src` change.

## Technical Context

**Language/Version**: MATLAB (COBRA Toolbox baseline) for the test-file work;
Markdown for the constitution amendment.

**Primary Dependencies**: `solveCobraLP`, `optimizeCbModel`,
`entropicFluxBalanceAnalysis`, `buildOptProblemFromModel` (all read-only, unchanged
— the functions under test, not touched by this feature); `prepareTest`,
`changeCobraSolver`, `runTestSuite`/`testAll.m` (the test harness the merged files
must keep integrating with).

**Storage**: N/A — no new files/fixtures; `getDistributedModel`/
`getDistributedModelFolder` calls already used by the affected tests are unchanged.

**Testing**: The four affected files themselves ARE the testing surface. Each
merged file MUST be run standalone and through `runTestSuite` after the merge,
confirmed to still cover every assertion its two source files had, with `prepareTest`
requirements equal to the union of what each side declared (so skip behaviour is
preserved, not narrowed).

**Target Platform**: same as the affected tests today — `testSolveCobraLP.m` and
`testOptimizeCbModel.m` need an LP solver (broad `useSolversIfAvailable` lists,
CI runs several); `testEntropicFluxBalanceAnalysis.m` needs `mosek` (`requiredSolvers`)
plus the characterization block's own mosek/pdco loop.

**Project Type**: brownfield MATLAB library — test-suite reorganization +
governance document amendment.

**Performance Goals**: no material runtime change — the merged files run the same
assertions the two source files already ran, just in one process instead of two,
which if anything removes duplicate `initCobraToolbox`/path-resolution overhead
from having two separate test *files* (not that this was measured or is a goal;
it's an incidental side effect, not something this feature optimizes for).

**Constraints**: no `src` change (FR-009); every assertion from both sides of each
merge MUST survive with unchanged meaning (FR-003/004/005); `prepareTest` union,
not intersection, of requirements (FR-007); historical `agent-runs/*/
implementation-receipt.md` files MUST NOT be edited (FR-008); the constitution
amendment MUST follow its own Governance section (Sync Impact Report + version
bump; FR-010).

**Scale/Scope**: 1 constitution edit (new Principle III sub-clause + version bump);
3 test-file merges (append + move-local-function, no new files); 1 test-file
rename; reference updates across ~4 features' live planning docs (grep-confirmed
scope: 009, 010, 011, 017 — not 004/006, corrected from the original request during
specify).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.* — **PASS**
(no `src` edit; the constitution edit is the feature's explicit, spec-approved
subject matter, not an incidental violation of Principle X/VI).

- **Scientific code quality**: N/A to the merge mechanics — no stoichiometry,
  bounds, objective, or status-semantics object is touched; the merge relocates
  assertions about those objects without altering the assertions themselves.
- **Testing and reproducibility**: The four merged/renamed files remain each
  other's own reproducibility check — `runTestSuite('test(SolveCobraLP|OptimizeCbModel|EntropicFluxBalanceAnalysis|BuildOptProblemFromModel)')`
  is the narrowest command that proves Part 2 (see quickstart.md). `prepareTest`
  requirements are preserved as a union per merge, so skip-clean behaviour is
  unchanged, not narrowed.
- **User experience and diagnostics**: No new console output pattern is
  introduced; each merge keeps the two source blocks' own `fprintf`/`printLevel`
  gating exactly as it was, just concatenated into one file.
- **Performance and numerical integrity**: No numerical result changes — the
  assertions are relocated verbatim, not recomputed or re-tolerance'd. No `src`
  performance change.
- **External-solver configuration audit**: N/A — no `src` change and no new
  solver call is introduced; the merged files call the same
  `solveCobraLP`/`optimizeCbModel`/`entropicFluxBalanceAnalysis` entry points with
  the same parameters each side already used.
- **Spec-driven scope control**:
  - Edit (content merge, not `src`): `test/verifiedTests/base/testSolvers/testSolveCobraLP.m`,
    `test/verifiedTests/analysis/testOptimizeCbModel/testOptimizeCbModel.m`,
    `test/verifiedTests/base/testEntropicFBA/testEntropicFluxBalanceAnalysis.m`.
  - Rename: `test/verifiedTests/base/testSolvers/testCharacterizeBuildOptProblemFromModel.m`
    → `testBuildOptProblemFromModel.m`.
  - Delete (after merge): `testCharacterizeSolveCobraLP.m`,
    `testCharacterizeOptimizeCbModel/` (file + now-empty directory),
    `testCharacterizeEntropicFBA/` (file + now-empty directory).
  - Edit: `.specify/memory/constitution.md` (the feature's explicit subject).
  - Edit (references only): live docs in `specs/009-fba-characterization-statusmap/`,
    `specs/010-gecko-entropic-fba/`, `specs/011-entropicfba-dual-fixes/`,
    `specs/017-buildgurobifrommodel-tests/` — excluding every `agent-runs/*/
    implementation-receipt.md` (read-only, historical).
  - MUST NOT touch: any `src/` file; any `agent-runs/*/implementation-receipt.md`.
- **MATLAB coding standards**: merged files keep each side's existing header/
  boilerplate conventions (no `evalc`, no suppressed warnings, existing
  `try/catch` in the destination files is untouched, no `nargin` introduced);
  `camelCase` local-function naming preserved (`buildToyModel`) since no rename is
  needed (each merge target is a distinct file, so the two files' identically-named
  `buildToyModel()` helpers never collide with each other).
- **Parameter-setting fidelity**: N/A — no cross-language port or literate render.
- **Artifact placement**: all edits/deletes stay within `test/verifiedTests/`
  (Principle IX: "test or fixture → `test/`") and `specs/<feature>/` (Spec Kit
  artifacts) plus the one governance file `.specify/memory/constitution.md`
  (also an established Spec Kit location). No new top-level location introduced.

**Re-check after design (Phase 1)**: unchanged — `data-model.md`'s merge-point
specification for each of the three pairs confirms the insertion point (immediately
before the destination's closing `cd(currentDir)`) makes every appended local
variable dead-on-arrival for anything downstream, so no `src` touch-point or new
public interface emerged. PASS.

## Project Structure

### Documentation (this feature)

```text
specs/018-test-naming-convention/
├── spec.md               # Feature spec (/speckit-specify command output)
├── plan.md                # This file (/speckit-plan command output)
├── research.md            # Phase 0 output (/speckit-plan command)
├── data-model.md           # Phase 1 output (/speckit-plan command)
├── quickstart.md          # Phase 1 output (/speckit-plan command)
├── checklists/
│   └── requirements.md    # Spec quality checklist (/speckit-specify command)
└── tasks.md               # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

(`contracts/`: omitted — no new public API/CLI/interface surface; the constitution
clause itself is the only new "contract," and it is written directly by this
feature's Part 1, not derived from a separate contracts artifact.)

### Source Code (repository)

```text
.specify/memory/
└── constitution.md                          # EDIT: new Principle III sub-clause + Governance version bump

test/verifiedTests/base/testSolvers/
├── testSolveCobraLP.m                       # EDIT: append characterization block + helper
├── testCharacterizeSolveCobraLP.m           # DELETE after merge
├── testBuildOptProblemFromModel.m           # RENAME from testCharacterizeBuildOptProblemFromModel.m
└── testCharacterizeBuildOptProblemFromModel.m  # DELETE (renamed away)

test/verifiedTests/analysis/testOptimizeCbModel/
└── testOptimizeCbModel.m                    # EDIT: append characterization block + helper

test/verifiedTests/analysis/testCharacterizeOptimizeCbModel/
└── (directory removed after merge)

test/verifiedTests/base/testEntropicFBA/
└── testEntropicFluxBalanceAnalysis.m        # EDIT: append characterization block

test/verifiedTests/analysis/testCharacterizeEntropicFBA/
└── (directory removed after merge)

specs/009-fba-characterization-statusmap/, specs/010-gecko-entropic-fba/,
specs/011-entropicfba-dual-fixes/, specs/017-buildgurobifrommodel-tests/
└── live docs only (spec/plan/tasks/research/data-model/quickstart/human-loop/
    implementation-review)          # EDIT: old test-file-name references → new
    agent-runs/*/implementation-receipt.md                                    # UNTOUCHED
```

**Structure Decision**: test-suite consolidation confined to
`test/verifiedTests/base/testSolvers/`, `test/verifiedTests/analysis/
testOptimizeCbModel/`, `test/verifiedTests/base/testEntropicFBA/` (deleting the
now-empty `testCharacterizeOptimizeCbModel/`/`testCharacterizeEntropicFBA/`
directories), plus the one governance file and reference-only edits in four other
features' already-published planning docs. No `src/` directory touched.

## Complexity Tracking

No Constitution Check violations to justify. Risk notes (not violations):

| Item | Note |
|------|------|
| Editing already-shipped features' live docs (009/010/011) | Reference-only (old path → new path); no requirement, decision, or traceability row is reinterpreted — mitigated by grep-verifying zero remaining old-name hits (SC-006) after the edit. |
| `testOptimizeCbModel.m`/`testSolveCobraLP.m` merges touch large, real-solver, genome-scale test files | Mitigated by the append-before-final-`cd` ordering (data-model.md): the appended block is provably dead code for anything after it, so it cannot alter the pre-existing assertions' behaviour. Each merged file is run standalone and through the harness post-merge to confirm both halves still pass. |
| Constitution amendment touches a governance document, not ordinary source | This is the feature's explicit, spec-approved subject (FR-001/002/010), not scope creep — handled via the constitution's own amendment process (Sync Impact Report, version bump), same as any other constitution change. |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: [Identify formulation/solver/interface
  boundaries touched; cite applicable docs and compatibility requirements]
- **Testing and reproducibility**: [Name the narrowest tests, MATLAB commands,
  fixtures, logs, or reproducibility checks required for this feature]
- **User experience and diagnostics**: [State expected diagnostic/reporting,
  status, print-level, file-location, or workflow behavior]
- **Performance and numerical integrity**: [State runtime, memory, diagnostic
  volume, residual, scaling, or solver-status constraints and measurements.
  State any performance goal and confirm it is subordinate to solution quality
  (objective, residuals, status, certificate quality must not degrade). If any
  debug/diagnostic/trace/verification step is made skippable for speed, confirm
  it is gated behind a documented, default-on parameter, not removed]
- **External-solver configuration audit**: [For each external solver/library
  this feature invokes, enumerate its relevant configuration surface (options,
  parameters, defaults) and cross-check every default against the problem data's
  structural profile — sparsity, cone types, dimensions, scale. Identify and
  override any default mismatched to that profile (e.g. dense path over sparse
  data), record the chosen settings and rationale, and cite the installed solver
  source/docs and the representative instance used. Write N/A if no external
  solver is invoked]
- **Spec-driven scope control**: [List source paths to edit, read-only paths to
  avoid, migration boundary, and any justified new dependency or abstraction]
- **MATLAB coding standards**: [Confirm: no evalc shadowing built-ins, warnings
  visible, try/catch propagates ME.stack, diary active, no nargin, relevant
  MATLAB best-practice skill consulted or proposed]
- **Parameter-setting fidelity**: [For any feature that ports, reuses, or renders
  code into another language / a literate document: confirm parameter-setting code
  (param.*, model.*, solver options) is not dropped — each parameter's value is
  surfaced as a natural-language translation with the prose that describes it, with
  no blank parameter labels (Principle VIII). Write N/A if the feature renders no
  ported/literate output]
- **Artifact placement**: [For every file this feature creates, moves, or emits,
  confirm its destination follows the Principle IX / docs/repository-layout.md
  placement procedure: src/ holds source only, including diagnostic/analysis
  tooling (no generated .html, executed notebooks, diaries, tables, figures);
  dependency/environment manifests stay at their module root and never under
  logs/; raw immutable input data -> data/, with tracked binary/.mat via Git LFS
  (IX-G) and explicit *.mat un-ignore carve-outs; test fixtures live beside their
  tests; executable scripts -> bin/ (executables only); regenerable output ->
  results/ (gitignored); curated tracked renders -> reports/; run/experiment
  output written into the in-repo results/ tree bundled per run, never a
  hard-coded external path; retired content -> old/ or archive/ (root or nested,
  read-only). List any file whose placement changes]

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command)
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
# [REMOVE IF UNUSED] Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [REMOVE IF UNUSED] Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [REMOVE IF UNUSED] Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure: feature modules, UI flows, platform tests]
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
