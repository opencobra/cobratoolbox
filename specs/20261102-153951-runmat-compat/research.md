# Research: RunMat compatibility of COBRA Toolbox source

**Date**: 2026-11-02 | **Feature**: [spec.md](spec.md)

All findings come from prototype runs on a scratch copy of `src/`, `test/` and `initCobraToolbox.m` at
`467094a5d`; no repository file was changed. RunMat: `feature/clean-room-matlab-builtins` @ `ebc6509f3`
(0.6.2, built without OCCT and CUDA). MATLAB: R2026a (GLNXA64), used for the code analyzer and `mtree`.

The measure throughout is RunMat's test-runner discovery (`runmat test --list --path=src --path=test
test/verifiedTests`), which compiles every file on its search path and refuses to run any test while one fails.
Per-file `runmat check` was rejected as the measure, because it reports only the first error per file, applies
deeper static analysis than the runner, and segfaulted under parallel load.

## R1 — Function files without a closing `end` (FR-001)

- **Decision**: insert `end` after the last code line of each function in a file whose functions are all
  unterminated (`tools/add_function_ends.py`). A rewrite is accepted only if MATLAB's parse tree (node kinds and
  strings, via `mtree`) is unchanged and the code analyzer reports no new message.
- **Rationale**: RunMat requires `end`; MATLAB accepts both forms, and the parse tree is identical (733 of 734
  prototype rewrites). An already-terminated file gains a parse error instead, so the check also decides
  whether a file was unterminated.
- **Evidence**: 735 files failed at line 1 with "expected 'end'". One (`surfNet.m`) was already terminated: RunMat
  treats a line beginning `%{'metNames'; ...}` as opening a block comment (RunMat defect D3). After the
  other layers were fixed, 30 more unterminated files surfaced.
- **Alternatives**: a regex heuristic on column-0 `end` lines was wrong for 676 of 735 files (they close
  unindented `if`/`for` blocks), so it was rejected.

## R2 — Separators in cell and matrix literals (FR-002)

- **Finding**: RunMat does not accept whitespace as an element separator inside `{...}` (`{1 2}` and `{'a' 'b'}`
  fail; commas work), and does not accept a bare newline as a row separator in cell literals. Inside `[...]`,
  RunMat accepts whitespace, but **reads a bare newline as a column break**: `[1 2` newline `3 4]` gives a 1x4
  result, where MATLAB gives 2x2 (RunMat defect D1; silent wrong result). Comment lines inside literals are fine.
- **Decision**: a single-pass MATLAB lexer (`tools/explicit_separators.py`) inserts `,` between cell elements
  separated only by whitespace, and `;` before a newline that MATLAB reads as a row break, in `{}` and `[]`.
  Every rewritten file must have an unchanged MATLAB parse tree; otherwise it is reverted and listed.
- **Evidence**: over the 2,303 in-scope files, 147 change (86 files gain 3,406 commas; 107 files gain 6,200
  semicolons; 3 files are skipped by the lexer). 141 of the 147 had identical parse trees; 6 were mis-lexed and
  are reverted for manual handling.
- **Note**: the `[]` newline rewrite also fixes files that RunMat already accepts but would mis-evaluate (D1).

## R3 — Layered failures (scope)

| Step (prototype) | Runner discovery errors (`src/` + `test/`) |
|---|--:|
| Baseline | 1,186 |
| After R1 (function `end`) | 551 |
| After R1 + R2 | 499 |

Each layer lets RunMat parse further and exposes the next error in the same file. After R1 and R2 the residue
is:

| Residual error | Files | Nature |
|---|--:|---|
| undefined name | 312 | mix: bare calls to COBRA functions (COBRA-side `name()` fix); bare calls to functions RunMat lacks (`ispc`, `uiwait`, `nexttile`: `name()` plus a RunMat defect); `java.*`, `py.*`, `parallel.*` namespaces (RunMat defect, no COBRA fix); variables created by `load` without an output (COBRA rewrite needs per-file judgement) |
| `try` without `catch` | 44 | COBRA-side mechanical fix (FR-003) |
| unterminated functions surfaced late | 30 | R1 again |
| other parse errors | about 110 | mostly RunMat parser gaps: command syntax with several words (`format long g`), `methods`/`properties` blocks, `!` shell escape, member names after `.` that are keywords, `-` in command arguments |
| unknown argument validator | 1 | `mustBeCobraModel` is a COBRA function used in an `arguments` block (RunMat defect) |

## R4 — RunMat defects found (for the report; not fixed here)

| ID | Defect | COBRA impact |
|---|---|---|
| D1 | Newline inside `[...]` read as a column break instead of a row break | silent wrong results in 107 files |
| D2 | Whitespace-separated elements in `{...}` rejected | 86 files |
| D3 | `%{` followed by text on the same line opens a block comment | 1+ files |
| D4 | Bare-name no-argument calls resolved when compiling, against the script's folder only | `testAll`, about 100+ files |
| D5 | A short-circuited, never-evaluated undefined variable rejects the whole file | `testAll.m` |
| D6 | `which` returns "'x' not found." instead of empty | `testAll.m` start-up |
| D7 | Compiler panic (`runmat-hir/src/lowering/ctx.rs:630`, "semantic lowering scope") | 2 files in `src/analysis/sampling/BarrierRound`, 6 in a submodule |
| D8 | Function files without a closing `end` rejected | 765 files |
| D9 | `try` without `catch` rejected | 44 files |
| D10 | Missing functions: `prefdir`, `ispc`, `exit`, `profile`, `gcp`, `uiwait`, `nexttile` and others | start-up and tests |
| D11 | Test runner rejects a source tree containing a non-UTF-8 file | 1 in-scope file |
| D12 | `runmat check` segfaults under parallel invocation | tooling only |

## R5 — Verification method

- **Decision**: three independent checks per rewritten file:
  1. the MATLAB parse tree (`mtree` kinds and strings) is unchanged, for R1/R2 (`tools/parseTreeEquivalence.m`);
  2. the MATLAB code analyzer gains no message (`tools/analyzerSnapshot.m`);
  3. the RunMat runner discovery error count falls.
  The MATLAB `testAll` pass/fail/skip comparison before and after is the end-to-end check (SC-003).
- **Rationale**: parse-tree identity proves MATLAB reads the file identically, which is stronger than a test run
  for a syntax-only rewrite, and it rejects rewriter mistakes automatically (6 caught in R2).
- **Limits**: changes that alter the tree by design (`name` → `name()`, an added `catch`) need a different
  equivalence argument: an identifier call versus an explicit empty-argument call, and an empty `catch` versus
  none. These are reviewed by category.
