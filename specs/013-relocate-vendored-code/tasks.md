# Tasks: Relocate vendored third-party code and static data blobs out of `src/`

**Input**: Design documents from `specs/013-relocate-vendored-code/`
**Prerequisites**: plan.md, spec.md, research.md (D1–D9), data-model.md (relocation manifest)

**Tests**: This is a behavior-preserving relocation. The "test" for every slice is a **baseline
comparison** (touched-domain suites + smoke, captured before any move) plus `check_matlab_code` on each
edited wrapper and a signature-diff check. No net-new functional tests are required.

**Organization**: grouped by the three user-story slices (P1 SAMMI, P2 Perl+GAMS, P3 data/orphans/
tutorial), each independently implementable and testable.

## Format: `[ID] [P?] [Story] Description`
- **[P]**: parallelizable (different files, no incomplete dependency)
- All moves use `git mv` (byte-identical — FR-009); wrapper edits change only path resolution (FR-003).

---

## Phase 1: Setup

- [X] T001 Create the run directory `specs/013-relocate-vendored-code/agent-runs/<UTC>-relocate-vendored-code/` with a `baseline.md` skeleton (no source edit).
- [X] T002 Verify the path-resolution foundation: confirm how `initCobraToolbox` adds `external/` to the MATLAB path (selective per-dependency per research D1) and that `CBTDIR = fileparts(which('initCobraToolbox'))` resolves the toolbox root; record findings in `baseline.md`.

## Phase 2: Foundational (blocking prerequisites for all stories)

- [X] T003 Capture the per-domain **test baseline** via MATLAB MCP (`run_matlab_test_file`) for visualization/SAMMI, dataIntegration/fluxomics c13, design/optForce, dataIntegration/chemoInformatics molecularWeight, analysis/thermo groupContribution; record pass/skip/fail counts (absent `perl`/`gams` → skip is baseline) in `baseline.md`.
- [X] T004 Re-grep every candidate orphan (`src/base/io/python/tmp/*`, `src/visualization/SAMMIM/demo.json`, `c13solver/validator.pl`) for inbound references across the repo; record confirmation that each is unreferenced before any move (FR-005 / edge case).

**Checkpoint**: baseline recorded and orphans confirmed — user-story slices can begin.

---

## Phase 3: User Story 1 — SAMMI web app leaves `src/` (Priority P1) 🎯 MVP

**Goal**: The GPLv3 SAMMI JS/CSS/HTML template lives under `external/`; `sammi.m` still renders.
**Independent test**: `src/visualization/SAMMIM/` holds only `.m` + `README`; `sammi(model)` writes+opens
HTML whose local script srcs resolve to the `external/` copy; `sammi.m` signature unchanged.

- [X] T005 [US1] `git mv` SAMMI vendored assets (`helpfunctions.js`, `uploaddownload.js`, `simulationfunctions.js`, `sammi.css`, `index.html`) from `src/visualization/SAMMIM/` to `external/visualization/SAMMIM/`.
- [X] T006 [US1] `git mv` dead `src/visualization/SAMMIM/demo.json` to `deprecated/_SAMMIM_demo/`.
- [X] T007 [US1] Delete committed generated HTML `src/visualization/SAMMIM/{index_load.html,index_load2.html,sammi_test_output.html}`.
- [X] T008 [US1] Edit `src/visualization/SAMMIM/sammi.m`: resolve the template dir via `CBTDIR` (replace the `which('sammi')`-based `sfolder` used for the `fileread` template read at ~L112); rewrite the generated HTML local `<script src>` to CBTDIR-absolute paths; **preserve the default output location and the function signature**.
- [X] T009 [US1] Add generated-SAMMI-HTML patterns to `.gitignore` (e.g. `src/visualization/SAMMIM/index_load*.html`, `**/sammi_test_output.html`).
- [X] T010 [US1] Verify: `check_matlab_code('src/visualization/SAMMIM/sammi.m')`; run the SAMMI/visualization suite + `sammi` smoke; compare to baseline (SC-004); confirm no `sammi.m` signature change (SC-006) and no web-app assets remain under `src/` (SC-001).

**Checkpoint**: MVP complete — the headline GPLv3 offender is out of `src/` with SAMMI still working.

---

## Phase 4: User Story 2 — Perl and GAMS solvers leave `src/` (Priority P2)

**Goal**: `c13solver/*.pl` and `optForceGAMS/*.gms` + `licememo.gms` live under `external/`; wrappers
still invoke them.
**Independent test**: no `.pl`/`.gms` under `src/`; wrappers build CBTDIR-anchored paths; behavior with
`perl`/`gams` present matches baseline, and absence matches baseline (not a regression).

- [ ] T011 [US2] `git mv` `src/dataIntegration/fluxomics/c13solver/*.pl` (5 files) to `external/dataIntegration/fluxomics/c13solver/`.
- [ ] T012 [US2] Edit `src/dataIntegration/fluxomics/c13solver/generateIsotopomerSolver.m`: invoke `perl <CBTDIR-abs .pl>` from a writable working directory (replace `cd(xdir)` + bare `perl generatorEMU.pl` at ~L88–96); keep `IsotopomerModel.txt` I/O in a writable cwd.
- [ ] T013 [P] [US2] `git mv` `src/design/optForceGAMS/*.gms` (6) to `external/design/optForceGAMS/` and `src/base/solvers/gams/licememo.gms` to `external/base/solvers/gams/`.
- [ ] T014 [US2] Edit `src/design/optForceGAMS/optForceWithGAMS.m` and `findMust{L,LL,U,UL,UU}WithGAMS.m`: reference each `.gms` model by CBTDIR-absolute path in the `system('gams …')` invocation (invocation args otherwise unchanged).
- [ ] T015 [US2] Edit `src/base/solvers/gams/getAvailableGAMSSolvers.m`: resolve `licememo.gms` via `CBTDIR` (replace `which('licememo.gms')` at ~L37).
- [ ] T016 [US2] Verify: `check_matlab_code` on all edited wrappers; run c13 + optForce suites (or confirm clean skip when `perl`/`gams` absent); compare to baseline; confirm no signature changes and no `.pl`/`.gms` under `src/`.

---

## Phase 5: User Story 3 — Data, orphans, generated artifacts, tutorial (Priority P3)

**Goal**: orphans → `deprecated/`; generated cache removed+gitignored; tutorial → `tutorials/`; static
third-party data → `data/` (gated). **Independent test**: `src/` free of the enumerated blobs; NIST
loader returns the identical table; tutorial opens from `tutorials/`.

### Sub-slice 3a — sanctioned moves (no new convention; may proceed immediately)

- [ ] T017 [US3] `git mv` orphan `src/base/io/python/tmp/*` to `deprecated/_io_python_tmp/`.
- [ ] T018 [US3] Delete committed cache `src/analysis/thermo/groupContribution/wang/cache/autoFragment_*.mat`; add `**/groupContribution/wang/cache/` to `.gitignore`.
- [ ] T019 [P] [US3] `git mv` `src/visualization/entropicFBA/tutorial_eFBA.mlx` to `tutorials/analysis/` (confirm subdir).

### Sub-slice 3b — static data (GATED on the `data/` constitution amendment)

- [ ] T020 [US3] **GATE**: run a companion `/speckit-constitution` amendment adding the `data/` role to the Principle IX role map (single-sourcing, Principle X). T021–T022 MUST NOT proceed until this lands. If deferred, stop 3b here and deliver 3a only.
- [ ] T021 [US3] `git mv` NIST `Atomic_Weights_..._Elements.txt` from `src/dataIntegration/chemoInformatics/molecularWeight/basicPhysicochemicalData/` to `data/dataIntegration/chemoInformatics/molecularWeight/`; edit `parse_Atomic_Weights_and_Isotopic_Compositions_for_All_Elements.m` to resolve the file via `CBTDIR` (replace the bare `fopen` at ~L26).
- [ ] T022 [P] [US3] `git mv` `VMH_reactionList.xlsx` and `Parsed_hmdbConc.xlsx` to `data/<domain>/`; harden their loaders to CBTDIR resolution.
- [ ] T023 [US3] Verify: run molecularWeight + groupContribution suites; assert `getMolecularMass`/`computeElementalMatrix` (and the NIST element table) are equal to baseline (FR-007/FR-009); compare all touched suites to baseline; confirm no signature changes.

---

## Phase 6: Polish & Cross-Cutting

- [ ] T024 Update `analysis/WEAKNESSES.md` (W9) and `analysis/ARCHITECTURE.md` §7 to mark W9 resolved (Principle X single-sourcing); note any part deferred (e.g. taxa2proc, gated data slice).
- [ ] T025 Measure `src/` size reduction and confirm figures against `analysis/metrics/scc-complexity-top.txt` (SC-005).
- [ ] T026 Final full check: `git status` shows no committed generated artifacts (SC-002); `git diff src/**/*.m` shows only path-resolution edits (SC-006); all touched suites match baseline (SC-004).
- [ ] T027 Write the implementation receipt at `specs/013-relocate-vendored-code/agent-runs/<UTC>-relocate-vendored-code/implementation-receipt.md` (Prompt / Final response / Diff summary / Tests / Unresolved issues).

---

## Dependencies & Execution Order

- **Phase 1 → Phase 2** (setup + baseline) block everything.
- **US1, US2, US3-sub3a** are mutually independent after Phase 2 (different domains/files) — can be done in any order or parallel. Recommended order P1 → P2 → P3 for reviewability.
- Within each story, the move/edit tasks precede that story's **verify** task (T010, T016, T023).
- **T020 blocks T021–T022** (gate). If the `data/` amendment is deferred, US3 delivers sub-slice 3a only and T023 runs over the 3a-touched suites.
- Phase 6 runs after the delivered slices.

## Parallel Opportunities

- T013 [P] (GAMS moves) alongside T011/T012 (Perl) — different domains.
- T019 [P] (tutorial move) alongside T017/T018.
- T022 [P] (xlsx moves) alongside T021 (NIST) once the gate (T020) clears.

## Implementation Strategy

- **MVP = User Story 1 (SAMMI)**: the largest LOC + only foreign-license offender; ship first and stop
  for review if desired.
- Incremental delivery: each slice is a self-contained, baseline-verified increment. The gated
  static-data sub-slice (3b) is the only part with an external prerequisite; everything else is
  behavior-preserving file moves + wrapper path-resolution edits.
