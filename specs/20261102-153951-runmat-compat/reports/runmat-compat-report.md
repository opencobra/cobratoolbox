# RunMat compatibility of COBRA Toolbox source: report (T020, SC-005)

- **Feature**: `20261102-153951-runmat-compat`. Source changes: `aa51dcd2a..3c2bbad64` (US1), `25c3d1fd6` (US2).
- **RunMat**: v0.6.2, built from `feature/clean-room-matlab-builtins` @ `ebc6509f3` (quickstart.md).
- **MATLAB**: R2026a.
- **Scope**: 2,306 tracked `.m` files under `src/`, `test/` and `initCobraToolbox.m`
  (`tools/scope_files.py`). `external/`, `deprecated/` and submodule paths are excluded, and none of them changed
  (T032).

## 1. RunMat test discovery, before and after

Discovery is `runmat test --list` over the in-scope files (`tools/runmat_discovery.sh`). Files RunMat cannot
measure are set aside (D7 panics, non-UTF-8 files).

| | Before (`baseline/`) | After US1 (`reports/runmat-discovery-after-us1.txt`) |
|---|---|---|
| Files measured | 2,302 | 2,302 |
| Files set aside | 3 | 3 |
| Files with a discovery error | **1,184** | **342** |
| `expected 'end'` | 735 | 3 |
| `expected '}' to close cell literal` | 127 | 8 |
| `expected 'catch' after try` | 24 | 0 |
| `undefined variable` | 195 | 225 |

The undefined-variable count rose because RunMat reports only the first error per file. Once the parse errors
were fixed, later undefined names in the same files became visible. Each of the 342 remaining files is
classified in `reports/residual.tsv`:

| Class | Files |
|---|---|
| D5: name not assigned on every path to its use (latent COBRA bug or RunMat strictness) | 105 |
| Out of slice: needs per-file judgement (`load` without output, `eval`, command syntax) | 58 |
| RunMat defect, not reduced to a reproducer | 54 |
| D4 | 30 |
| D13 | 22 |
| D15 | 19 |
| D14 | 18 |
| D17 | 13 |
| D16 | 8 |
| D22 | 6 |
| D19 | 5 |
| D3, D18, D20, D21 | 1 each |

After US2 (`25c3d1fd6`), `initCobraToolbox.m` passes discovery. `test/testAll.m` still fails with D5.

## 2. Files changed per category

Each category was committed on its own and checked file by file. A file that failed its check was reverted and
listed as rejected.

| Category (FR) | Commit | Accepted | Rejected or skipped | Check |
|---|---|---|---|---|
| UTF-8 re-encoding (FR-009) | b54fe95fe | 1 | 0 | decoded characters identical |
| Function terminators (FR-001) | 7cc5b6b48 | 733 | 2 (`surfNet.m`, D3; `intergrate`, not valid MATLAB) | parse tree identical |
| Cell and matrix separators (FR-002) | 94bbf739c | 141 | 6 rejected, 3 lexer skips | parse tree identical |
| Empty `catch` (FR-003) | 25cf50634 | 44 (105 blocks) | 6 | tree identical apart from the added CATCH nodes; analyzer |
| Terminators, rerun (FR-001) | f16d1a7d3 | 46 | 3 | parse tree identical |
| Explicit `name()` calls (FR-004) | 934536abd, 3c2bbad64 | 133 (24 names) | 34 (variable risk, or a classdef naming itself) | analyzer; MATLAB `testAll` |
| `PERFORMANCE_REPORT` guard (FR-005) | 25c3d1fd6 | `test/testAll.m` | — | value equal in all 7 env-var × variable cases; analyzer |
| Entry-point `name()` calls (FR-004, FR-008) | 25c3d1fd6 | `test/testAll.m` (`initCobraToolbox`, `exit`), `initCobraToolbox.m` (`prefdir`, `ispc` ×4) | — | analyzer |

Lists of accepted and rejected files: `reports/accepted-*.txt` and `reports/rejected-*.txt`.

**Analyzer check (SC-002, T031).** All 975 changed in-scope files were compared with the baseline
`baseline/analyzer-before.json`. The snapshot after the change is `reports/analyzer-after.json`. No file gains a
`checkcode` message identifier.

`greedyExtremeRayBasis.m` was also changed on `089-large-model-solver-speed`, so its feature-branch version was
the one compared.

**MATLAB suite (SC-003, T030).** Before the change: 537 tests, 497 passed, 4 failed, 36 skipped. After: one
difference, `testSurfNet`, traced to `clear surfNet()` (934536abd) and fixed in 3c2bbad64.
`reports/testAll-after-summary.md` has the details.

The full suite was not rerun after that fix or after `25c3d1fd6`. That commit makes only `name()` rewrites and
a value-identical guard, and the analyzer accepted it.

## 3. `testAll` under RunMat (SC-004)

> **Erratum (2026-11-04, feature `20261104-001324-runmat-init-mode`).** The stop recorded at `test/testAll.m:55`
> (`cd(CBTDIR)`) and attributed to D6 was not D6. RunMat reported the error at the wrong location. Its message,
> `cell literal rows realize different widths` (`RunMat:MirAggregateShapeInvalid`), comes from the empty cell
> literal `{}` (`SOLVERS = {};` in `initCobraToolbox`), new defect **D26**. D6 is real but was not the observed
> stopping point. Further defects found since this report:
> - D23: `usejava` errors;
> - D24: `mfilename` returns a string;
> - D25: `genpath` of a missing folder errors;
> - D26: `{}` fails;
> - D27–D29: functions on the path that read `nargin` or a global, or that are called with fewer arguments than
>   declared, fail.
>
> See `specs/20261104-001324-runmat-init-mode/research.md` R1–R2 and
> `test/runtimeCompatibility/RunMat/debtRegister.md`.

SC-004 is **not met**: `testAll` does not reach the per-test loop.

| Run | Stops at | Cause |
|---|---|---|
| T019, before US2 (`reports/runmat-testAll.txt`) | `test/testAll.m:73`, bare `initCobraToolbox` | D4 |
| After US2, `25c3d1fd6` (`reports/runmat-testAll-after-us2.txt`) | `test/testAll.m:285`, `PERFORMANCE_REPORT` read inside an `if exist('PERFORMANCE_REPORT', 'var')` block | D5: RunMat rejects the whole file at compile time, even though MATLAB never evaluates the read when the variable is absent |
| Same, with the D5 line replaced in a scratch copy only (measurement, not committed) | `test/testAll.m:55`, `cd(CBTDIR)` | D6: `which('initCobraToolbox.m')` returns text, so `CBTDIR` is not a folder |

After D6, the next known blockers in start-up are the missing functions `prefdir` and `ispc` (D10), called at
`initCobraToolbox.m:104` and later.

FR-008 rules out COBRA-side workarounds: `eval` to hide the read, a RunMat check, or shims. Getting further
needs fixes in RunMat. A run with shims (`SHIMS=`, `tools/runmat_testall.sh`) would not measure COBRA under
RunMat alone.

There are 1,093 files set aside in the T019 run (`reports/runmat-testAll.txt`): 1,066 failed discovery over the
whole runtime path, which includes `external/` and the submodules, 17 hit the D7 panic, and 10 are not UTF-8.

## 4. RunMat defects

Each reproducer is in `reports/repro/<id>/` and was run with RunMat v0.6.2 (`runmat run <file>`, or
`runmat test --list` for D11). Run each reproducer in its own folder: RunMat compiles every file in the folder,
so a D7 file next to it makes it panic too.

The "COBRA files" column counts in-scope files:
- a number from `reports/residual.tsv` is the number of files that still fail with that defect;
- a number marked "grep" is the number of files that name the construct (an upper bound).

| ID | Defect | Reproducer | RunMat result | MATLAB result | COBRA files |
|---|---|---|---|---|---|
| D1 | A newline inside `[...]` is read as a column break, not a row break | `d1`: `x = [1 2⏎3 4]; disp(size(x))` | `1 4` (silent wrong result) | `2 2` | 107 (all rewritten, FR-002) |
| D2 | Whitespace-separated elements in `{...}` are rejected | `d2`: `c = {'a' 'b'};` | `expected '}' to close cell literal` | 1×2 cell | 86 (rewritten, FR-002) |
| D3 | `%{` followed by text on the same line opens a block comment | `d3`: `%{'a'; 'b'}` then `disp(x)`, `%}`, `disp(2)` | prints only `2`: the `disp(x)` is swallowed | prints `1`, `2` | 1 (`surfNet.m`) |
| D4 | A bare no-argument call is resolved at compile time, and only against the script's own folder, not the run-time path | `d4`: `addpath(lib); y = helperFn;` | `undefined variable 'helperFn'` | `42` | 30 still failing; 133 + 2 entry points rewritten |
| D5 | Reading an undefined variable rejects the whole file at compile time, even when the read is short-circuited (`false && X`) or guarded by `exist(X,'var')` | `d5`: `if exist('NOT_DEFINED','var') x = NOT_DEFINED; end` | `undefined variable 'NOT_DEFINED'` | prints `reached` | 105 + `test/testAll.m` |
| D6 | `which` returns `'x' not found.` instead of empty | `d6`: `disp(isempty(which('noSuchFile.m')))` | `0` | `1` | 13 (grep `isempty(which(`) |
| D7 | Compiler panic on a class property default that names a function (`NaN`, `struct(...)`) | `d7`: `properties w = NaN end` | panic, `runmat-hir/src/lowering/ctx.rs:630` | valid class | 3 set aside (`reports/runmat-defect-d7.md`) |
| D8 | A function file with no closing `end` is rejected | `d8`: `function d8()` … `function y = f(x)` with no `end` | `expected 'end'` | prints `2` | 779 (all rewritten, FR-001) |
| D9 | `try` without `catch` is rejected | `d9` | `expected 'catch' after try` | prints `reached` | 44 (all rewritten, FR-003) |
| D10 | Missing functions: `prefdir`, `ispc`, `exit`, `profile`, `gcp`, `uiwait`, `nexttile` | `d10`: `disp(ispc())` | `Undefined function: ispc` | `0` | 123 (grep; mostly `gcp` 55 and `ispc` 45) |
| D11 | The test runner refuses a source tree that holds any non-UTF-8 file | `d11`: a Latin-1 comment in `latin.m` plus `tests/testA.m`; `runmat test --list --path=. tests` | `stream did not contain valid UTF-8` | — | 10 in the runtime tree, 1 in scope (re-encoded, FR-009) |
| D12 | `runmat check` segfaults when run in parallel | 8 parallel `runmat check` processes (`xargs -P 8`) | segfault (seen in slice 1; not re-run here) | — | tooling only |
| D13 | A namespace or class reference without parentheses, such as `java.util.Hashtable` or `TestRunner.withTextOutput`, is read as an undefined variable | `d13`: `h = java.util.Hashtable;` | `undefined variable 'java'` (works as `java.util.Hashtable()`) | `java.util.Hashtable` | 22 |
| D14 | Command syntax with more than one argument | `d14`: `axis equal tight` | `'axis' command syntax accepts only one argument` | valid | 18 |
| D15 | Whitespace-separated outputs `[a b] = f(...)` | `d15` | `expected ']'` | `3` | 19 |
| D16 | Function declaration without `()` | `d16`: `function f` | `expected '('` | prints `reached` | 8 |
| D17 | `function [] = f(...)` | `d17` | `expected identifier or '~'` | prints `1` | 13 |
| D18 | `!` shell escape | `d18`: `!echo hi` | `Invalid token: '!'` | prints `hi` | 1 |
| D19 | Keyword used as a field name (`s.function`) | `d19` | `expected identifier` | prints `1` | 5 |
| D20 | A user function used as an `arguments` validator | `d20`: `x {mustBePositiveCustom}` | `unsupported arguments validator` | prints `1` | 1 (`mustBeCobraModel`) |
| D21 | Class attributes with a superclass list joined by `&` | `d21`: `classdef (Abstract) d21 < handle & matlab.mixin.Copyable` | `unexpected token: And` | valid class | 1 |
| D22 | Unary minus after `^` (`10^-2`) | `d22` | `unexpected token: Minus` | `0.0100` | 6 |

The 54 residual files classed "RunMat defect, not reduced" fail with parse errors of the same kinds (mostly
`expected ']'` and `Unexpected adjacency`). They were not reduced to a defect each.

## Reproducing these numbers

`quickstart.md` gives the commands: discovery (`tools/runmat_discovery.sh`), testAll under RunMat
(`tools/runmat_testall.sh`), the analyzer comparison (`tools/analyzerSnapshot.m`) and the MATLAB suite
comparison (`tools/compare_testall.py`).
