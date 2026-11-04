# Research: RunMat initialisation mode (Phase 0)

RunMat v0.6.2 (`feature/clean-room-matlab-builtins` @ `ebc6509f3`), MATLAB R2026a, 2026-11-04.

**Method**:
- Every probe runs in its own empty folder. RunMat compiles every `.m` file in the folder of the script it runs,
  so one bad file next to a probe makes the probe fail too, and that produced false results early on.
- `initCobraToolbox` was then driven step by step under RunMat in a scratch copy of the T019 measurement tree
  (`specs/20261102-153951-runmat-compat`), outside the repository.
- Each blocker was patched in the scratch copy only, to reach the next one.

## R1 — Built-ins `initCobraToolbox` and `testAll` use

Each built-in was probed alone (`x = f(...); disp(class(x))`).

**Work**:
- `isunix`, `ismac`, `genpath` on an existing folder, `pathsep`, `getenv`, `clock`, `tic`, `path`, `system`
- `exist(...,'dir'/'builtin')`, `version`, `isfolder`, `computer`, `datestr`, `isstring`, `contains`
- `verLessThan`, `rehash`, `userpath`, `which` on a builtin
- `eval` and `evalin` (a guarded read through `eval('X')` passes compilation)

**Fail or diverge**:

| Construct | RunMat result | MATLAB result | ID |
|---|---|---|---|
| `prefdir`, `ispc`, `exit`, `quit`, `feature` | `Undefined function` | built-in | D10 (extended: `quit`, `feature`) |
| `usejava('desktop')` / `usejava('jvm')` | `Java feature must be non-empty text` | logical | **D23** (new): the reason for commit `6a22237af` |
| `mfilename('fullpath')` | returns a `string` | returns `char` | **D24** (new): `[s filesep 'x']` then builds a 1×3 string array, and `genpath` rejects it |
| `genpath(missingFolder)` | error `RunMat:genpath:FolderNotFound` | returns `''` | **D25** (new) |
| `which('missing.m')` | `'missing.m' not found.` | `''` | D6 |

## R2 — Language-level defects found by driving `initCobraToolbox` (new)

| ID | Defect | Reproducer (≤ 10 lines) | Affected COBRA files (grep, in scope) |
|---|---|---|---|
| **D26** | An empty cell literal `{}` fails at run time with `cell literal rows realize different widths` (`RunMat:MirAggregateShapeInvalid`). The error is reported at a wrong file and line: the caller's script, with a column number past the end of the line. `cell(0, 0)` works. | `x = {};` | 417 files |
| **D27** | A function reached through the search path (not the running script's own folder) that reads `nargin` fails to compile: `local may be read before it is assigned`. | `lib/fa.m`: `function r = fa(x)`, `if nargin < 1 ... end`; driver: `addpath(lib); fa(2)` | 421 files |
| **D28** | Same setting: a function that reads a `global` before assigning it in that function fails to compile. | `lib/fg.m`: `function r = fg()`, `global GG`, `r = GG;` | most functions using COBRA globals (`CBTDIR`, `SOLVERS`, `CBT_*_SOLVER`, …) |
| **D29** | Calling a function with fewer arguments than it declares raises `Not enough input arguments` at the call, even when the function guards optional inputs with `exist('x','var')`. Seen in the script's own folder as well as on the path. | `fh.m`: `function r = fh(x)`, `if ~exist('x','var'), x = 0; end`, `r = x;`; driver: `fh()` | essentially every function with optional inputs (the constitution's own VII-D pattern) |

**Correction to the previous feature.** Its report (`reports/runmat-compat-report.md` §3 and
`reports/runmat-testAll-after-us2.txt`) says that `testAll`, with the D5 line bypassed, stops at D6 on
`testAll.m:55`. That location was the misreported D26 error: `SOLVERS = {};` inside `initCobraToolbox`, or a
`{}` in `testAll` itself. D6 is real, but it was not the observed stopping point. The report must be corrected.

## R3 — How far `initCobraToolbox(false, 'agent')` gets under RunMat, with scratch patches

Each workaround was applied only in the scratch copy:
1. `{}` → `cell(0, 0)` across the tree (D26);
2. `which` → `char(mfilename('fullpath'))` (D6, D24);
3. `prefdir`/`ispc` removed (D10);
4. the missing `docs/source/notes` folder guarded (D25).

It then stops at the first toolbox function it calls, `changeCbMapOutput`, with D27 (`nargin`) and D28 (global
read). Every later step of initialisation also calls toolbox functions that use `nargin`, globals or optional
inputs: `getDefinedFieldProperties`, `getDistributedModelFolder`, `configEnvVars`, `changeCobraSolver`. `testAll`
then runs tests that call everything else.

## Conclusion (blocker)

With RunMat v0.6.2, SC-001 (`initCobraToolbox(false, 'runmat')` completes) and SC-002 (`testAll` reaches its
per-test loop) cannot be met by workarounds confined to `initCobraToolbox.m` and `test/testAll.m` (FR-015,
VIII-Runtime containment). D27–D29 affect most of the toolbox:
- D27 and D29 hit the standard optional-argument patterns, both `nargin` and the `exist` guard.
- D28 hits the global-variable solver registry.

None has a MATLAB-equivalent rewrite at the call site. Rewriting `nargin` and optional-argument handling in
about 400+ files would change behaviour (for example for explicitly passed `[]`). It would also be far outside
this feature.

What remains feasible in this feature:
- the `'runmat'` mode interface;
- the start-up workarounds D5, D6, D10, D23, D24 and D25 in the two files;
- the debt register, the reproducers and the re-check command;
- `{}` → `cell(0, 0)` in the two files (MATLAB-equivalent, not debt);
- an honest measurement: under RunMat, `'runmat'` mode reaches its first toolbox call and stops at D27.

A human decision on scope is needed before the plan is completed (Gate: blocker).

**Decision (2026-11-04):** "Narrow: mode + debt now". The spec's SC-001 and SC-002 were reworded to reflect this.

## R4 — Design decisions (after the scope decision)

Each item gives the decision, the reason for it, and the alternative rejected.

- **`'runmat'` reuses `'agent'` mode's flow.** `initCobraToolbox` keeps `agentMode` true for both `'agent'` and
  `'runmat'`, and adds a `runmatMode` flag that only the registered workarounds read.
  - *Reason*: agent mode already skips git, network, solver probing and path saving (FR-003), and prints no
    banner, so the banner's `usejava` (D23) is never reached.
  - *Rejected*: a separate third flow, which would duplicate about 20 `if ~agentMode` branches.
- **Toolbox root in `'runmat'` mode.** `CBTDIR = fileparts(char(mfilename('fullpath')))` in place of
  `fileparts(which('initCobraToolbox'))`.
  - *Reason*: `which` diverges in RunMat (D6) and `mfilename` returns a string there (D24). In MATLAB both give
    the folder of the running `initCobraToolbox.m`.
  - Default and agent modes keep `which`. Debt markers: D6 and D24.
- **`prefdir`.** In `'runmat'` mode, `defaultSavePathLocation` is not computed. Its only use is saving the path,
  which agent and runmat modes skip.
  - Debt marker: D10, because the call stays in the other modes.
- **`ispc`.** Every call sits in a block that `'runmat'` mode skips (path saving, the printed solver table,
  GitBash installation). No workaround and no marker.
- **`{}` → `cell(0, 0)`.** Applied to the 9 occurrences in `initCobraToolbox.m` and those in `test/testAll.m`, in
  every mode.
  - *Reason*: MATLAB evaluates both to a 0×0 cell, so this is a MATLAB-equivalent rewrite (D26) and not debt
    (VIII-Runtime). Verified with the analyzer and the MATLAB tests.
- **`genpath` of `docs/source/notes`.** Guarded with `isfolder`, in every mode.
  - *Reason*: MATLAB's `genpath` returns `''` for a missing folder and `addpath('')` does nothing, so the guard
    is MATLAB-equivalent and not debt (D25).
- **testAll opt-in.** The environment switch `COBRA_RUNMAT=1`, read like `COBRA_CI` and `COBRA_PERF`. With it:
  - the toolbox root comes from `mfilename('fullpath')` instead of `which` (D6 and D24 markers);
  - `testAll` calls `initCobraToolbox(false, 'runmat')`;
  - the final `exit()` is skipped (D10 marker). `runmat run` ends when the script ends.
- **`PERFORMANCE_REPORT` (D5).** Read as `eval('PERFORMANCE_REPORT')` inside the existing `exist(...,'var')`
  guard, in every mode.
  - *Reason*: RunMat rejects the whole file at compile time otherwise, so a run-time opt-in cannot help. In a
    script, `eval` reads the same workspace and gives the same value. VII-A concerns `evalc` and is not touched.
  - It is registered as a compile-time debt entry under the VIII-Runtime exception (constitution v1.8.0).
- **Register layout.** `test/runtimeCompatibility/RunMat/`, with:
  - `debtRegister.md`, which has two tables:
    - *Workarounds*: one row per marker, checked one to one against the markers;
    - *Blocking defects without a workaround*: D26 outside the two files, and D27–D29. These rows have no
      marker; they say when SC-001 can be completed.
  - `repro/<defectId>/` folders, each holding the reproducer and `expected.txt`, the MATLAB output;
  - `recheckRunMat.sh RUNMAT`.
  - *Reason*: constitution VIII-Runtime and IX.
- **Re-check method.** For each reproducer, `recheckRunMat.sh`:
  1. copies the folder to a fresh temporary folder;
  2. runs `runmat run --color never <id>.m` (with `test --list` for a runner-level defect);
  3. strips RunMat's `WARN` lines;
  4. compares the output with `expected.txt`.

  An identical output means *removable*, and any other output means *still needed*. The script then greps the
  repository for `RUNTIME-DEBT(RunMat:` and fails when markers and Workarounds rows differ. It prints one line
  per entry.
  - *Rejected*: a MATLAB-side checker, because the runtime under test is RunMat and the check must run without
    MATLAB.
- **Test file.** `test/verifiedTests/base/testInstall/testInitCobraToolboxAgentMode.m` is renamed with `git mv` to
  `testInitCobraToolbox.m` (constitution III-Naming: one file per function), and gains:
  - the `'runmat'` mode assertions: SC-004 equality with agent mode, the `updateToolbox`+`'runmat'` error, and
    the invalid-mode message listing `'runmat'`;
  - a default-mode check of the banner link (FR-014).
  - *Rejected*: a second test file for the same function, which III-Naming forbids.
- **Correction of the previous feature's report.** `specs/20261102-153951-runmat-compat/reports/runmat-compat-report.md`
  §3 and `reports/runmat-testAll-after-us2.txt` get an erratum that points to this research (R2).
