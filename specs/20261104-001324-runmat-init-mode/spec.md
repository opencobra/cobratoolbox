# Feature Specification: RunMat initialisation mode with recorded compatibility debt

**Feature Branch**: `20261104-001324-runmat-init-mode`

**Created**: 2026-11-04

**Status**: Draft

**Input**: User description: "Give initCobraToolbox a new input argument that makes it run in a RunMat-compatible way
(as a RunMat-compatible script), and acknowledge the technical debt this creates." The context given with it:

- Feature `20261102-153951-runmat-compat` found that `testAll` and `initCobraToolbox` stop under RunMat at
  defects D5, D6 and D10. Its report is `specs/20261102-153951-runmat-compat/reports/runmat-compat-report.md`.
- That feature's FR-008 forbade RunMat-specific fallbacks.
- This feature deliberately adds an opt-in RunMat mode, off by default, and records the resulting debt.

## Clarifications

### Session 2026-11-04

- Q: How is the RunMat option requested? → A: As a new value `'runmat'` of the existing `mode` argument:
  `initCobraToolbox(updateToolbox, 'runmat')`. The signature does not change.
- Q: Which files are in scope? → A: `initCobraToolbox.m` and `test/testAll.m`. `testAll` gets its own opt-in
  RunMat path, so that the end-to-end goal (`testAll` reaching its per-test loop under RunMat) can be measured.
- Q: Where is the debt recorded? → A: In a debt register and in a uniform, searchable marker at every
  RunMat-specific code path. A companion constitution amendment defines, project-wide, how compatibility debt is
  recorded and where its register lives.
- Q (planning blocker, research.md R2): RunMat v0.6.2 cannot run toolbox functions that read `nargin` or a
  global, or that are called with fewer arguments than declared (D27–D29), so initialisation cannot complete
  under RunMat with workarounds confined to the two files. How to proceed? → A: "Narrow: mode + debt now". Keep
  the mode, the start-up workarounds, the debt register and the re-check. Success under RunMat means getting
  through `initCobraToolbox`'s own start-up steps and stopping at its first toolbox call with a registered
  defect. Full initialisation waits for RunMat fixes, which the re-check detects.

## Background

RunMat is an independent MATLAB-language runtime. The previous feature made COBRA source acceptable to it through
rewrites that leave MATLAB behaviour unchanged. What remains at start-up are RunMat defects that no such rewrite
can avoid:

- **D4/D5**: RunMat checks names when it compiles a file. It rejects a whole file that reads a variable it
  cannot prove exists, even inside a guard that MATLAB evaluates first.
- **D6**: `which` returns text, not empty, for a missing file.
- **D10**: functions are missing, among them `prefdir`, `ispc`, `exit`, `profile` and `gcp`.

The previous feature's FR-008 deliberately excluded RunMat-specific workarounds. This feature reverses that
decision, but only for an explicitly requested mode and only in the two start-up files. Every workaround is
recorded as debt, to be removed when RunMat fixes the defect behind it.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Initialise the toolbox under RunMat (Priority: P1)

A developer evaluating COBRA under RunMat calls `initCobraToolbox(false, 'runmat')`. Its own start-up steps
run without calling any function that RunMat lacks or implements differently: the toolbox root is known and the
source folders are on the path. With RunMat v0.6.2, the first call into a toolbox function then stops on a
registered RunMat defect (D27–D29, research.md R2), and that defect is the reported stopping point. Once RunMat
fixes those defects, the same call completes initialisation without any change to COBRA.

**Why this priority**: every other COBRA use under RunMat starts here. Today initialisation cannot complete under
RunMat at all.

**Independent Test**: under RunMat, run a script that calls `initCobraToolbox(false, 'runmat')`, then checks the
initialised state (toolbox root, a COBRA function resolvable on the path, solver registry present). The script
exits without error.

**Acceptance Scenarios**:

1. **Given** a COBRA checkout and RunMat v0.6.2, **When** `initCobraToolbox(false, 'runmat')` is called,
   **Then** every step before its first toolbox-function call completes, and the run stops there with an error
   that the debt register lists as a RunMat defect (not a COBRA error and not an unregistered RunMat error).
2. **Given** a RunMat release that fixes D26–D29, **When** RunMat mode runs with no external solver installed,
   **Then** it reports that no solver is available and completes. Not verifiable with v0.6.2; the re-check
   (US4) shows when it becomes verifiable.
3. **Given** MATLAB, **When** `initCobraToolbox(false, 'runmat')` is called, **Then** it also completes, and the
   toolbox root and the COBRA folders it puts on the path are the same as in `'agent'` mode.

---

### User Story 2 - MATLAB users see no change (Priority: P1)

A MATLAB user who calls `initCobraToolbox`, `initCobraToolbox(true)`, `initCobraToolbox(false)` or
`initCobraToolbox(false, 'agent')` gets exactly the behaviour they had before this feature.

**Why this priority**: the initialisation contract is a public interface (Constitution Principle II). Any change to
the default path is a regression for every user.

**Independent Test**: the MATLAB `testAll` result (pass, fail and skip per test) is unchanged from the baseline.
A targeted test confirms that the default and `'agent'` modes produce the same initialised state and output as
before.

**Acceptance Scenarios**:

1. **Given** MATLAB, **When** `initCobraToolbox` is called with no mode or with `'default'` or `'agent'`, **Then**
   it takes the same code paths as before this feature. The only RunMat-related code that runs is the
   MATLAB-equivalent rewrites (`cell(0, 0)` for `{}`, the `isfolder` guard) and the registered compile-time
   entry D5, which constitution VIII-Runtime allows without an opt-in.
2. **Given** MATLAB and `testAll` without the RunMat opt-in, **When** the suite runs, **Then** every test has the
   same status as in the baseline run.

---

### User Story 3 - `testAll` reaches its test loop under RunMat (Priority: P2)

A developer runs `testAll` under RunMat with an explicit opt-in. `testAll` compiles under RunMat, gets through
its own start-up and calls `initCobraToolbox` in RunMat mode. With RunMat v0.6.2 the run then stops where US1
stops; once RunMat fixes D26–D29 it reaches its per-test loop and reports pass, fail and skip counts.

**Why this priority**: this is the end-to-end measurement the previous feature could not reach (its SC-004). It
depends on User Story 1.

**Independent Test**: run `testAll` under RunMat with the opt-in, using the previous feature's measurement runner.
The log shows that the per-test loop started.

**Acceptance Scenarios**:

1. **Given** RunMat v0.6.2 and the `testAll` RunMat opt-in, **When** `testAll` runs, **Then** `testAll`
   compiles, runs its own start-up and calls `initCobraToolbox(false, 'runmat')`, and the run stops at the
   registered defect of US1, scenario 1.
2. **Given** MATLAB with the `PERFORMANCE_REPORT` workspace variable set to true, **When** `testAll` runs without
   the RunMat opt-in, **Then** the performance report is still produced, as before.

---

### User Story 4 - The debt is visible and removable (Priority: P2)

A maintainer can list every RunMat-specific code path. For each one they can see which RunMat defect it works
around and what must happen before it can be removed. They can re-check which defects RunMat has since fixed, so
that a workaround is removed as soon as it is no longer needed.

**Why this priority**: a workaround that is not recorded becomes permanent. The user asked for the debt to be
acknowledged explicitly.

**Independent Test**: a search for the debt marker finds exactly the entries in the debt register, and the
register's re-check command reports each entry as still needed or now removable.

**Acceptance Scenarios**:

1. **Given** the finished feature, **When** the code is searched for the debt marker, **Then** every hit has a
   register entry and every register entry has at least one hit.
2. **Given** a newer RunMat that fixes one of the listed defects, **When** the re-check runs, **Then** that
   defect's entries are reported as removable.

---

### Edge Cases

- **`'runmat'` together with `updateToolbox = true`**: RunMat mode does not update the toolbox or its submodules.
  The call fails at once with an error that names the incompatible combination. It does not silently skip the
  update.
- **Repeated call in the same session**: the existing idempotency guard applies to RunMat mode exactly as it does
  to the other modes.
- **Unknown mode**: the error message lists `'runmat'` among the accepted values.
- **`'runmat'` in MATLAB**: allowed, so that the mode can be tested in MATLAB CI (US1, scenario 3). It does not
  save the MATLAB path and does not change git configuration.
- **A RunMat that has fixed some defects**: RunMat mode still works. The debt re-check reports which workarounds
  can be removed.
- **The `testAll` RunMat opt-in under MATLAB**: allowed. Results may differ from a default run only where the
  register records a difference.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `initCobraToolbox` MUST accept `'runmat'` as a value of its existing `mode` argument. The default
  mode MUST stay `'default'`, and `'default'` and `'agent'` MUST behave exactly as before (Principle II).
- **FR-002**: In `'runmat'` mode, `initCobraToolbox`'s own statements MUST NOT call any function that RunMat
  lacks or implements differently (D6, D10, D24, D25, D26). Under RunMat v0.6.2 every step before its first
  toolbox-function call MUST complete. A stop at that call MUST be a registered blocking defect (D26–D29). In
  MATLAB, and under a RunMat that fixes D26–D29, the mode MUST set:
  - the toolbox root;
  - the COBRA source and test folders on the path;
  - the solver registry and the environment variables;
  - the initialised flag.
- **FR-003**: `'runmat'` mode MUST follow `'agent'` mode's behaviour: silent apart from one summary line, and
  skipping git and submodule operations, network checks, solver probing, saving the path and toolbox updates. It
  differs only by the registered RunMat workarounds. Combined with `updateToolbox = true`, it MUST raise an
  error that names the combination.
- **FR-004**: `'runmat'` mode MUST also run in MATLAB. There, the toolbox root and the COBRA folders it adds to
  the path MUST equal those of `'agent'` mode.
- **FR-005**: `initCobraToolbox.m` and `test/testAll.m` MUST pass RunMat's compile-time checks in every mode, so
  that RunMat can load them at all (D4, D5). Where this needs a construct that the previous feature avoided (for
  example evaluating a name from text), that construct MUST be a registered debt entry. In MATLAB it MUST give the
  same result as the code it replaces.
- **FR-006**: `test/testAll.m` MUST provide an explicit RunMat opt-in, set from outside the script in the same way
  as its existing environment switches. With the opt-in, `testAll` MUST:
  - initialise the toolbox in `'runmat'` mode;
  - avoid the D6 and D10 calls in its start-up and exit;
  - keep every other step.
- **FR-007**: Without the RunMat opt-in, `testAll` MUST behave as before. That includes the `PERFORMANCE_REPORT`
  workspace switch and the CI exit.
- **FR-008**: Every RunMat-specific code path MUST carry the same searchable debt marker, and the marker MUST name
  the RunMat defect it works around (for example D6).
- **FR-009**: A debt register MUST list each RunMat-specific code path with:
  - the defect ID;
  - the file and the code construct;
  - the MATLAB behaviour it replaces;
  - the condition for removing it;
  - the reproducer that shows whether RunMat still has the defect.

  The register's location and format are those set by the constitution amendment (FR-011).
- **FR-010**: A re-check command MUST run each register entry's reproducer against a given RunMat binary and
  report each entry as still needed or removable.
- **FR-011**: A companion `/speckit-constitution` amendment MUST define project-wide how compatibility debt for
  an alternative runtime is recorded: the marker, the register's location and its required fields. It MUST also
  state that such workarounds are allowed only behind an explicit opt-in. Code that depends on this rule MUST NOT
  be merged before the amendment is adopted (gate, as in feature 013 T020).
- **FR-012**: This feature MUST record that it supersedes FR-008 of feature `20261102-153951-runmat-compat` for
  `initCobraToolbox.m` and `test/testAll.m` only. FR-008 continues to apply everywhere else.
- **FR-013**: The help header of `initCobraToolbox` MUST document the `'runmat'` mode, its limits (no update, no
  path saving), and the existence of the debt register (Principle VII-E).
- **FR-014**: In `'default'` mode, the documentation link in the start-up banner MUST again be a clickable
  hyperlink in the MATLAB desktop, as before commit `6a22237af`. `'runmat'` mode, like `'agent'` mode, prints no
  banner, so the `usejava` defect (D23) is never reached and needs no workaround.
- **FR-015**: `external/`, `deprecated/` and submodule paths MUST NOT change. Functions that RunMat lacks MUST NOT
  be added to the shared source tree as shadowing replacements; the workarounds stay inside the two start-up files.
- **FR-016** (Gate 3, 2026-11-05): `test/verifyCobraFunctionError.m` MUST contain no empty cell literal `{}`. Its one
  `{}` (line 35) becomes `cell(0, 0)`, which MATLAB evaluates identically, so it is not debt (VIII-Runtime
  compile-time exception) and gets no marker. Reason: under RunMat v0.6.2 a `{}` in any file of the script's folder
  stops that script before its first statement (D26), so `test/testAll.m` cannot start (reports/runmat-testAll.txt).

### Key Entities

- **RunMat mode**: the `'runmat'` value of `initCobraToolbox`'s `mode`, together with the `testAll` opt-in. Both
  are off by default.
- **Debt entry**: one RunMat-specific code path, with the fields listed in FR-009. Each entry is tied to exactly
  one RunMat defect.
- **Debt marker**: the uniform searchable tag that connects code to its debt entry.
- **RunMat defect**: a numbered RunMat incompatibility (D1–D22), with its reproducer, from the previous
  feature's report.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Under RunMat v0.6.2, `initCobraToolbox(false, 'runmat')` runs every step before its first
  toolbox-function call, and stops at that call with a defect listed in the debt register. With a RunMat that
  fixes D26–D29, the same call completes (verified when the re-check reports those entries removable).
- **SC-002**: Under RunMat v0.6.2, `testAll` with the RunMat opt-in compiles, runs its own start-up and reaches
  the `initCobraToolbox(false, 'runmat')` call, then stops as in SC-001. The stopping point is recorded in the
  feature's measurement report.
- **SC-003**: The MATLAB `testAll` (`COBRA_CI=1`, no RunMat opt-in) gives the same status for every test as the
  baseline run before this feature.
- **SC-004**: In MATLAB, `'runmat'` mode and `'agent'` mode yield the same toolbox root and the same set of COBRA
  path entries.
- **SC-005**: The number of debt-marker hits equals the number of register entries, and no entry is without a
  hit (100% traceability in both directions).
- **SC-006**: The debt re-check reports a status for 100% of register entries, against a given RunMat binary, in
  a single command.
- **SC-008**: The debt register and reproducers cover D23–D29 found in research.md, as well as the start-up
  defects worked around (D5, D6, D10). The previous feature's report is corrected where it attributed the
  `testAll.m:55` stop to D6 (research.md R2).
- **SC-007**: The `initCobraToolbox` and `testAll` changes add no MATLAB code-analyzer message compared with the
  baseline, except messages that the register records against a debt entry.

## Assumptions

- The RunMat build and the measurement tools of feature `20261102-153951-runmat-compat` are reused:
  `runmat_testall.sh`, the defect reproducers and the full-clone requirement for `testAll`.
- Under RunMat, no external solver (gurobi, mosek, cplex) is available. A completed initialisation with an empty
  or minimal solver list is success for SC-001.
- The opt-in for `testAll` is an environment switch, matching `COBRA_CI` and `COBRA_PERF`. Its exact name is a
  planning decision.
- The defects worked around are those in the two start-up files' own code: D5, D6, D10, D23 (banner
  hyperlink), D24, D25 and D26. D26 is removed with the MATLAB-equivalent rewrite `{}` → `cell(0, 0)` in those
  two files, which is not debt. Defects in toolbox functions (D26 elsewhere, D27–D29) are recorded and reported,
  not worked around. That would need about 400+ files changed and is out of scope (research.md, Conclusion).
- Restoring the desktop hyperlink in MATLAB (FR-014) settles the open question about commit `6a22237af` from the
  previous feature in favour of MATLAB's historical behaviour.
- The constitution amendment (FR-011) is a separate Spec Kit command. Its wording is decided there. This spec
  depends only on its existence and on the fields named in FR-009.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1-1 / FR-001, FR-002, FR-003, SC-001 | RunMat script calling `initCobraToolbox(false, 'runmat')` (measurement, under the feature folder) | `initCobraToolbox.m` |
| US1-2 / FR-002 | same RunMat script, no external solver installed | `initCobraToolbox.m` |
| US1-3 / FR-004, SC-004 | `test/verifiedTests/base/testInstall/testInitCobraToolbox.m` (renamed from `testInitCobraToolboxAgentMode.m`), comparing `'runmat'` and `'agent'` mode in MATLAB | `initCobraToolbox.m` |
| US2-1 / FR-001, FR-014 | same test: default and `'agent'` modes, banner hyperlink in desktop mode | `initCobraToolbox.m` |
| US2-2 / FR-007, SC-003 | MATLAB `testAll` before and after (`compare_testall.py`) | `test/testAll.m` |
| US3-1 / FR-005, FR-006, SC-002 | `runmat_testall.sh` with the RunMat opt-in | `test/testAll.m` |
| US3-1 / FR-016, SC-002 | `runmat_testall.sh` with the RunMat opt-in; MATLAB `testAll` comparison (65 tests call it) | `test/verifyCobraFunctionError.m` |
| US3-2 / FR-007 | MATLAB check of the `PERFORMANCE_REPORT` switch (four cases, as in the previous feature's T017) | `test/testAll.m` |
| US4-1 / FR-008, FR-009, SC-005 | marker-versus-register consistency check | — (no source function) |
| US4-2 / FR-010, SC-006 | debt re-check command over the reproducers | — (no source function) |
| FR-011 | constitution amendment adopted (`/speckit-constitution`) | — (no source function) |
| FR-012 | note in the previous feature's spec FR-008 and report erratum (T021) | — (no source function) |
| FR-013, FR-015, SC-007 | help header review; path check; analyzer comparison | `initCobraToolbox.m` |
