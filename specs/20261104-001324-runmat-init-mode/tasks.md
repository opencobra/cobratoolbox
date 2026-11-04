# Tasks: RunMat initialisation mode with recorded compatibility debt

**Input**: `specs/20261104-001324-runmat-init-mode/` (spec.md, plan.md, research.md R4, data-model.md, contracts/,
quickstart.md)

**Tests**: requested by the spec (Traceability). They are written before the code they cover: the extended
`testInitCobraToolbox.m` (US1, US2) and the four-case `PERFORMANCE_REPORT` check (US3).

**Paths**:
- `F` = `specs/20261104-001324-runmat-init-mode`
- `RC` = `test/runtimeCompatibility/RunMat`
- `P` = `specs/20261102-153951-runmat-compat`, the previous feature

**RunMat**: set `RUNMAT` to the v0.6.2 binary and `RUNMAT_LIBS` to the folder holding the `libhdf5.so.103` link
(quickstart.md).

**Constitution**: v1.8.0. VIII-Runtime governs every marker and register row.

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup

- [X] T001 Start the MATLAB `testAll` baseline in the background.
  - Use a full local clone at commit `afe0fac8f` (the spec and plan commit, with source identical to the branch
    base `87573f1e8`), with submodules, because `initCobraToolbox` fails in a git worktree.
  - Run `COBRA_CI=1 xvfb-run matlab -batch "cd('<clone>/test'); testAll"`, as in `$P/reports/testAll-after-summary.md`.
  - Save `resultTable` to `$F/baseline/testAll-before.csv`.
- [X] T002 [P] Save the analyzer snapshot of `initCobraToolbox.m` and `test/testAll.m` to
  `$F/baseline/analyzer-before.json`, using `$P/tools/analyzerSnapshot.m`.
- [X] T003 [P] Create `$RC/debtRegister.md` with:
  - a header that cites constitution VIII-Runtime;
  - the two empty tables *Workarounds* and *Blocking defects without a workaround*, with the columns in
    `$F/contracts/debt-register.md`.

## Phase 2: Foundational (blocks every story)

- [X] T004 Create the reproducers `$RC/repro/<id>/<id>.m` (at most 10 lines each) for D5, D6, D10, D24, D26, D27,
  D28 and D29.
  - Copy them from `$P/reports/repro/` where they exist, and from `$F/research.md` R1–R2 otherwise.
  - D27 and D28 use a `lib/` subfolder and `addpath`.
  - Run each in MATLAB from its own folder, and write the output to `expected.txt`.
- [X] T005 Write `$RC/recheckRunMat.sh RUNMAT [REPO_ROOT]` exactly as in `$F/contracts/debt-register.md`:
  - copy each reproducer folder to a fresh temporary folder and run it;
  - drop the `WARN` lines and compare the output with `expected.txt`;
  - print `<id>\t(still needed|removable)\t<first differing line>`;
  - check the `RUNTIME-DEBT(RunMat:` markers in `.m` files outside `specs/` against the *Workarounds* rows;
  - exit 1 only when markers and rows do not match.

  Run it: every defect must be *still needed* under v0.6.2.
- [X] T006 Fill the *Blocking defects without a workaround* table in `$RC/debtRegister.md` for D26 (outside the
  two files), D27, D28 and D29: effect on COBRA, number of in-scope files affected (`$F/research.md` R2), and
  reproducer path.

**Checkpoint**: the register, reproducers and re-check exist. The re-check exits 0, with 0 markers and 0
workaround rows.

## Phase 3: User Story 1 - Initialise the toolbox under RunMat (P1) 🎯 MVP

**Goal**: `initCobraToolbox(false, 'runmat')` runs its own start-up under RunMat and stops only at a registered
blocking defect. In MATLAB it equals `'agent'` mode.

**Independent Test**:
- MATLAB: `COBRA_TESTS=testInitCobraToolbox testAll` passes.
- RunMat: the driver from T012 stops on a registered blocking defect.

- [X] T007 [US1] Rename `test/verifiedTests/base/testInstall/testInitCobraToolboxAgentMode.m` to
  `test/verifiedTests/base/testInstall/testInitCobraToolbox.m` with `git mv` (constitution III-Naming). Update its
  header and its error identifiers to the new name. Commit the rename on its own.
- [X] T008 [US1] Add tests to `test/verifiedTests/base/testInstall/testInitCobraToolbox.m`, written before the code
  (they must fail now):
  - `initCobraToolbox(false, 'nope')` gives a message that lists `'runmat'`;
  - `initCobraToolbox(true, 'runmat')` raises `initCobraToolbox:invalidMode`, with `'runmat'` and
    `updateToolbox` in the message;
  - after `initCobraToolbox(false, 'agent')` and after `initCobraToolbox(false, 'runmat')`, `CBTDIR` is equal and
    the sets of `strsplit(path, pathsep)` entries under `CBTDIR` are equal (SC-004);
  - `SOLVERS` and `OPT_PROB_TYPES` are set after `'runmat'` mode;
  - global git `http.sslVerify` is unchanged after `'runmat'` mode, reusing the file's existing check.

  Clear `CBT_INITIALIZED` between calls, so that the idempotency guard does not skip the second call.
- [X] T009 [US1] In `initCobraToolbox.m`, change the argument handling:
  - accept `'runmat'` in the `mode` check, and list it in both `initCobraToolbox:invalidMode` messages;
  - set `runmatMode = strcmpi(mode, 'runmat')` and `agentMode = strcmpi(mode, 'agent') || runmatMode`;
  - raise `initCobraToolbox:invalidMode` when `runmatMode && updateToolbox`, naming the combination;
  - document `'runmat'` in the help header (`mode` list, limits, pointer to `$RC/debtRegister.md`), following
    VII-E.
- [X] T010 [US1] In `initCobraToolbox.m`, add the `runmatMode` workarounds, each with its marker
  (`% RUNTIME-DEBT(RunMat:<id>)`):
  - the root is `CBTDIR = fileparts(char(mfilename('fullpath')))` when `runmatMode`, and
    `fileparts(which('initCobraToolbox'))` otherwise (markers D6 and D24);
  - `defaultSavePathLocation` is computed with `prefdir()` only when `~runmatMode`, and set to `''` otherwise
    (marker D10).
- [X] T011 [US1] Make the MATLAB-equivalent rewrites in `initCobraToolbox.m`. These are not debt and carry no
  marker:
  - every `{}` becomes `cell(0, 0)` (9 occurrences, D26);
  - `addpath(genpath([CBTDIR ... 'docs' ... 'notes']))` is guarded with `isfolder` (D25).
- [X] T012 [US1] Add one *Workarounds* row per T010 marker to `$RC/debtRegister.md`, then run `$RC/recheckRunMat.sh`,
  which must exit 0.
  - Run `COBRA_TESTS=testInitCobraToolbox` in MATLAB; T008 must pass.
  - Under RunMat, run a driver that calls `initCobraToolbox(false, 'runmat')`. Run it in a work tree that
    `$P/tools/runmat_testall.sh` builds from a full clone of this branch (`WORK=<dir>`, then run the driver in
    `$WORK/tree`).
  - Save the stopping point to `$F/reports/runmat-init.txt`. It must be a *Blocking defects* entry (SC-001).
  - Commit US1.

**Checkpoint**: US1 is complete and testable on its own.

## Phase 4: User Story 2 - MATLAB users see no change (P1)

**Goal**: `'default'` and `'agent'` modes behave as before, and the banner link is restored.

**Independent Test**: T014 shows no new analyzer message. T026 shows the MATLAB suite unchanged.

- [X] T013 [US2] In `initCobraToolbox.m`, restore the desktop hyperlink in the banner: wrap `docLink` in an
  `<a href>` when `usejava('desktop')`, as before `6a22237af`. Only the default mode prints the banner (FR-014).
  - Check in MATLAB `-batch` that the banner prints the plain link and does not error.
  - Add a one-line assertion to `testInitCobraToolbox.m` that the default-mode call does not error. It is already
    covered by Test 1 there; add only a comment if so.
- [X] T014 [US2] Compare the analyzer snapshot of `initCobraToolbox.m` with `$F/baseline/analyzer-before.json`.
  It must have no new identifier, except one the register records.
  - Review the diff to confirm that every `'default'`/`'agent'` code path is unchanged, apart from the
    MATLAB-equivalent rewrites of T011.
  - Commit US2.

## Phase 5: User Story 3 - testAll under RunMat (P2)

**Goal**: with `COBRA_RUNMAT=1`, `testAll` compiles under RunMat, runs its own start-up and calls
`initCobraToolbox(false, 'runmat')`.

**Independent Test**: `runmat_testall.sh` with `COBRA_RUNMAT=1` stops where US1 stops. The four-case MATLAB check
passes.

- [X] T015 [US3] Write the four-case check, before the code. In MATLAB, evaluate the current
  `PERFORMANCE_REPORT_ON` statements and the planned `eval('PERFORMANCE_REPORT')` form in a script workspace, for:
  - `COBRA_PERF` equal to `'1'`, empty or `'0'`;
  - crossed with the variable absent, empty, false or true.

  Record the 7+ cases and their results in `$F/reports/performance-report-check.txt`.
- [X] T016 [US3] In `test/testAll.m`, read `PERFORMANCE_REPORT` as `eval('PERFORMANCE_REPORT')` inside its existing
  `exist('PERFORMANCE_REPORT', 'var')` guard, with marker `% RUNTIME-DEBT(RunMat:D5)`. This applies in every
  mode, as a compile-time entry under the VIII-Runtime exception. T015's cases must give the same values.
- [X] T017 [US3] In `test/testAll.m`, add `runmatSwitch = strcmp(getenv('COBRA_RUNMAT'), '1');` near the
  `COBRA_CI` read. When it is on:
  - the root comes from `fileparts(char(mfilename('fullpath')))` and `..`, not `which` (markers D6 and D24);
  - the call is `initCobraToolbox(false, 'runmat')`, not `initCobraToolbox()`;
  - the CI `exit()` is skipped (marker D10).

  With the switch off, every line runs as before (`$F/contracts/testAll-runmat-switch.md`).
- [X] T018 [US3] In `test/testAll.m`, rewrite every `{}` as `cell(0, 0)` (MATLAB-equivalent, not debt).
  - Compare the analyzer snapshot of `test/testAll.m` (`$P/tools/analyzerSnapshot.m`) with
    `$F/baseline/analyzer-before.json`; it must show no new message, except one the register records.
  - Add the *Workarounds* rows for T016–T017 to `$RC/debtRegister.md`.
  - Run `$RC/recheckRunMat.sh`, which must exit 0.
- [ ] T019 [US3] Measure under RunMat:
  - run `COBRA_RUNMAT=1 $P/tools/runmat_testall.sh <full clone> $F/reports/runmat-testAll.txt` on a full clone
    of this branch;
  - the stopping point must be inside `initCobraToolbox(false, 'runmat')`, at a *Blocking defects* entry
    (SC-002);
  - commit US3.

## Phase 6: User Story 4 - The debt is visible and removable (P2)

**Goal**: the markers and the register match, and the re-check reports a status for every entry.

**Independent Test**: `recheckRunMat.sh` exits 0 and prints one line per register entry.

- [X] T020 [US4] Run `$RC/recheckRunMat.sh $RUNMAT` and save its output to `$F/reports/recheck.txt`. Then check:
  - the number of markers equals the number of *Workarounds* rows (SC-005);
  - there is one status line per entry (SC-006).
- [X] T021 [US4] Add an erratum to `$P/reports/runmat-compat-report.md` §3 and `$P/reports/runmat-testAll-after-us2.txt`:
  - the "D6 at `testAll.m:55`" stop was the misreported D26 (`{}`);
  - point to `$F/research.md` R2;
  - list the new defects D23–D29 (SC-008).
  - Add a note to `$P/spec.md` FR-008 that feature `20261104-001324-runmat-init-mode` supersedes it for
    `initCobraToolbox.m` and `test/testAll.m` (FR-012).
  - Commit.

## Phase 7: Polish & cross-cutting verification

- [ ] T022 Run the MATLAB `testAll` (`COBRA_CI=1`) on a full clone of the finished branch, and save
  `$F/reports/testAll-after.csv`.
  - Compare it with `$F/baseline/testAll-before.csv` using `$P/tools/compare_testall.py compare` (SC-003).
  - Any difference blocks completion and must be traced to its commit.
- [X] T023 [P] Check that `git diff --name-only develop HEAD` lists no path under `external/`, `deprecated/` or a
  `.gitmodules` path (FR-015).
- [X] T024 [P] Review the help header of `initCobraToolbox.m` against VII-E (FR-013) and run `checkcode` on the
  renamed test file.
- [ ] T025 Update `$F/quickstart.md` with the final commands. Write the implementation receipt in
  `$F/agent-runs/<UTC>-runmat-init-mode/implementation-receipt.md`, and update `$F/human-loop.md`.

## Dependencies & Execution Order

- T001 runs in the background and must finish before T022. T002 and T003 can run in parallel.
- Phase 2: T004 → T005 → T006. Phase 2 blocks all stories.
- US1: T007 → T008 → T009 → T010 → T011 → T012.
- US2 needs T009–T011, because it shares `initCobraToolbox.m`: T013 → T014.
- US3 needs T009, for the `'runmat'` value: T015 → T016 → T017 → T018 → T019.
- US4 needs US1 and US3, because all markers must exist: T020 → T021.
- T022–T025 come last. T023 and T024 can run in parallel.
- Tasks that touch the same file run in order: `initCobraToolbox.m` (T009–T011, T013), `test/testAll.m` (T016–T018)
  and `$RC/debtRegister.md` (T003, T006, T012, T018).

## Parallel Opportunities

- T002 ∥ T003, while T001 runs.
- Once T009 is done, the US3 work in `test/testAll.m` (T015–T018) can run alongside the US2 work in
  `initCobraToolbox.m` (T013–T014). The register rows (T012, T018) must still be written in order.
- T023 ∥ T024.

## Implementation Strategy

- **MVP**: Phases 1–3 (US1). The `'runmat'` mode, its tests and the register with the re-check.
- **Then**: US2, which completes the MATLAB-side guarantees; US3 and US4; then Phase 7.
- Commit per story. The MATLAB suite comparison (T022) is the end-to-end gate.
