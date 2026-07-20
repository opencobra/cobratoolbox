# Feature Specification: Relocate vendored third-party code and static data blobs out of `src/`

**Feature Branch**: `013-relocate-vendored-code`

**Created**: 2026-07-17

**Status**: Draft

**Input**: User description: "Relocate vendored third-party code and static data blobs out of src/ (weakness W9). Move vendored non-MATLAB code and data/generated blobs out of the src/ toolbox tree into the existing external/<domain>/ structure (and other role-correct locations), leaving only thin MATLAB wrappers in src/. Behavior-preserving; no public MATLAB function name/signature/behavior change. Full-cleanup scope: SAMMI JS app, Perl 13C solver, GAMS models, orphan scratch, NIST data table, large .xlsx, .mlx tutorial, checked-in cache .mat and generated SAMMI HTML. Out of scope: the base layering inversion (feature 014) and the analysis↔reconstruction cycle."

## Clarifications

### Session 2026-07-17

- Q: Destination for relocated static third-party data (NIST table, large `.xlsx`) → A: A **dedicated
  repository resource path** — a curated location separate from `external/` (which is reserved for
  third-party *code*). The exact path and naming convention are fixed in `/speckit-plan`.
- Q: Handling of `analysis/persephone/SeqC_pipeline/taxa2proc_{a2a,agora}_out.txt` → A: **Leave in
  place; excluded from feature 013** (no move, no deletion). Revisit only if later confirmed
  regenerable by the SeqC pipeline.
- Q: Disposal of genuinely orphan/dead files (`src/base/io/python/tmp/*`, dead `demo.json`) → A: **Move
  to `deprecated/`** (not deleted), keeping them in-tree and trivially restorable.

## User Scenarios & Testing *(mandatory)*

This is an explicit **repository-layout feature** (Constitution Principle IX; the tree "MUST NOT be
reorganised except through an explicit repository-layout feature"). The people served are toolbox
maintainers and contributors (who need a reviewable, single-license MATLAB source tree) and existing
users of the affected MATLAB wrappers (whose calls must keep working unchanged). Every story is a
behavior-preserving relocation verified by the existing test suite; none changes a public function.

### User Story 1 - The GPLv3 SAMMI web app leaves `src/`, `sammi` still renders (Priority: P1)

The complete third-party GPLv3 SAMMI JavaScript web app (JS/CSS/HTML template) no longer sits inside
the MATLAB source tree; it lives under `external/visualization/SAMMIM/`. The dead 1.1 MB `demo.json`
moves to `deprecated/` (it is unreferenced). The thin MATLAB wrappers (`sammi.m`, `openSammi.m`,
`makeSAMMI*.m`, `expa.m`) stay in `src/` and still produce and open a working SAMMI visualization by
reading the relocated template.

**Why this priority**: This is ~84% of the visualization directory's LOC and the only non-MATLAB
*license* (GPL-3) mixed into the toolbox tree — the single largest and most consequential offender in
W9. Fixing it delivers most of the weakness's value on its own.

**Independent Test**: Move only the SAMMI assets and update `sammi.m` path resolution; confirm
`src/visualization/SAMMIM/` retains only `.m` files + `README.md`, and that a `sammi(...)` call writes
and opens an HTML page whose local `<script src>` assets resolve from the `external/` copy.

**Acceptance Scenarios**:

1. **Given** an initialized toolbox, **When** the visualization source tree is scanned, **Then** it
   contains no `.js`, `.css`, `.json`, or browser `.html` files (only MATLAB wrappers + `README`).
2. **Given** a model and options, **When** `sammi(model, ...)` is invoked, **Then** it locates the
   relocated `index.html` template via a path resolved from the wrapper's own location, writes the
   generated HTML, and returns/opens it without error (SAMMI's pre-existing internet/CDN requirement
   is unchanged and out of scope).
3. **Given** the relocation, **When** the `sammi.m` public signature is diffed, **Then** its name,
   arguments, and documented behavior are unchanged.

---

### User Story 2 - Vendored Perl and GAMS solvers leave `src/`, wrappers still invoke them (Priority: P2)

The Perl 13C solver (`c13solver/*.pl`) and the GAMS models (`optForceGAMS/*.gms`, `gams/licememo.gms`)
move to `external/`, and their MATLAB wrappers continue to shell out to them from the new location.

**Why this priority**: These are additional non-MATLAB *code* bodies (Perl, GAMS) inflating and
mixing languages into `src/`, but they affect narrower workflows (13C fluxomics, OptForce/MustFind)
than SAMMI and depend on optional external tools.

**Independent Test**: Move only the `.pl`/`.gms` files; confirm the wrappers
(`generateIsotopomerSolver.m`, `optForceWithGAMS.m`, `findMust*WithGAMS.m`, `getAvailableGAMSSolvers.m`)
resolve and invoke the relocated files; where the external tool (perl/GAMS) is absent the wrapper
fails/ skips exactly as it did before the move (same behavior, new path).

**Acceptance Scenarios**:

1. **Given** the relocation, **When** `src/dataIntegration/fluxomics/c13solver/` and
   `src/design/optForceGAMS/` are scanned, **Then** they contain no `.pl`/`.gms` files.
2. **Given** `perl` is available, **When** `generateIsotopomerSolver` runs, **Then** it invokes the
   relocated `generatorEMU.pl` etc. and produces the same solver output it did before.
3. **Given** a GAMS-driven call (`optForceWithGAMS`/`findMust*WithGAMS`), **When** it constructs its
   `system('gams …')` invocation, **Then** the referenced model path points at the relocated `.gms`.

---

### User Story 3 - Orphan scratch, generated artifacts, static data and a misplaced tutorial are cleaned up (Priority: P3)

Unreferenced scratch (`base/io/python/tmp/`, dead `demo.json`) moves to `deprecated/`; checked-in
generated artifacts (`groupContribution/wang/cache/*.mat`, generated SAMMI output HTML) are removed and
gitignored; static third-party data (NIST atomic-weights table, large `.xlsx`) moves to a dedicated
resource path with hardened loaders; and the 1.9 MB `tutorial_eFBA.mlx` moves to `tutorials/`.

**Why this priority**: These reduce `src/` bloat and remove committed generated/scratch content, but
each is lower-risk and independently valuable; grouping them lets P1/P2 ship first.

**Independent Test**: Perform only these deletions/moves; confirm the orphans and generated blobs are
gone from `src/` and gitignored, the NIST-dependent functions still return the identical element
table, and the tutorial opens from `tutorials/`.

**Acceptance Scenarios**:

1. **Given** the cleanup, **When** `src/` is scanned, **Then** `base/io/python/tmp/` and `demo.json`
   are absent from `src/` (relocated to `deprecated/`), and the `wang/cache/*.mat` files and the
   generated SAMMI `index_load*.html`/`sammi_test_output.html` are absent and their patterns listed in
   `.gitignore`.
2. **Given** the NIST table moved and its loader hardened, **When** `getMolecularMass`/
   `computeElementalMatrix` run, **Then** they load the atomic-weights data and return results
   identical to the pre-move baseline.
3. **Given** the tutorial moved, **When** the source tree is scanned, **Then** no `.mlx` remains under
   `src/visualization/`.

### Edge Cases

- **`external/` not on the MATLAB path**: if `initCobraToolbox` does not add the relocated directory
  to the path, `which`/`fopen`-based loaders would fail. Mitigation: loaders are hardened to resolve
  relative to the wrapper (`fileparts(mfilename('fullpath'))`), independent of cwd and path.
- **`cd`-based shell-out** (`generateIsotopomerSolver.m`, GAMS wrappers write inputs beside the model):
  the working-directory change and any output files written next to the solver must still land in a
  writable location after the move (the relocated tree may be read-only; write to a temp/output dir).
- **Optional external tool absent** (no `perl`, no `gams`): behavior after relocation must match
  behavior before (same skip/error), so absence of the tool is not a regression.
- **A file assumed orphan is actually referenced**: any file slated for deletion must be re-grep'd at
  implementation time; if a reference exists, it is relocated (not deleted).
- **Case/name collision on move**: a relocated file must not overwrite an existing `external/` file.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: All vendored non-MATLAB **code** currently under `src/` (SAMMI JS/CSS/HTML template; the
  five `c13solver/*.pl`; the seven `.gms` models incl. `licememo.gms`) MUST be relocated to the
  matching `external/<domain>/` subtree, which already mirrors `src/<domain>/`.
- **FR-002**: The thin MATLAB wrappers for each relocated asset MUST remain under `src/` and MUST
  continue to locate and use their asset from the new location.
- **FR-003**: The change MUST be behavior-preserving: no public MATLAB function name, argument order,
  option name, or documented behavior may change (Constitution Principle II). Only file locations and
  the internal path-resolution inside wrappers change.
- **FR-004**: Every relocated asset MUST stay reachable via a resolution mechanism that does not depend
  on the current working directory: wrappers resolve their asset relative to the wrapper's own file
  location (or a confirmed on-path `external/` location). This covers all three mechanisms in use:
  computed-folder reads (`sammi.m`), path/`which`/`fopen` reads, and `cd`-then-shell-out.
- **FR-005**: Unreferenced scratch/orphan files (`src/base/io/python/tmp/*`, the dead
  `src/visualization/SAMMIM/demo.json`) MUST be moved to `deprecated/` (not deleted) after re-confirming
  they are referenced nowhere.
- **FR-006**: Checked-in **generated** artifacts (`src/analysis/thermo/groupContribution/wang/cache/*.mat`;
  the generated SAMMI output HTML `index_load.html`, `index_load2.html`, `sammi_test_output.html`) MUST
  be removed and their patterns added to `.gitignore` so they are not re-committed.
- **FR-007**: Static third-party **data** (the NIST atomic-weights table; large `.xlsx` such as
  `VMH_reactionList.xlsx`, `Parsed_hmdbConc.xlsx`) MUST be relocated to a **dedicated repository
  resource path** (separate from `external/`; exact path fixed in `/speckit-plan`), and the loaders
  that read them MUST be hardened to wrapper-relative resolution so content is loaded byte-identically
  after the move.
- **FR-008**: The misplaced Live Script tutorial `src/visualization/entropicFBA/tutorial_eFBA.mlx` MUST
  move to the `tutorials/` subtree (Principle IX: tutorial → `tutorials/`).
- **FR-009**: The relocation MUST preserve the content of every moved file byte-for-byte (a move, not a
  rewrite); only the wrappers/loaders that reference them are edited.
- **FR-010**: The change MUST be verified against the existing MATLAB test suites for the touched
  domains (visualization/SAMMI, fluxomics/c13, design/optForce, chemoInformatics/molecularWeight,
  thermo/groupContribution) with no new failures relative to a pre-change baseline.
- **FR-011**: `analysis/persephone/SeqC_pipeline/taxa2proc_{a2a,agora}_out.txt` are **out of scope for
  feature 013** and MUST be left in place (no move, no deletion) — see Clarifications.

### Key Entities *(include if feature involves data)*

- **Vendored code asset**: a non-MATLAB source file shipped in the toolbox (`.js`, `.pl`, `.gms`,
  browser `.html`, `.css`). Destination: `external/<domain>/`.
- **Static data asset**: a third-party reference/input data file (`.txt` NIST table, `.xlsx`).
  Destination: a dedicated repository resource path (separate from `external/`; exact path fixed in plan).
- **Generated artifact**: a file produced by running the toolbox that was committed by mistake
  (`cache/*.mat`, generated SAMMI HTML). Destination: removed + gitignored.
- **Thin wrapper**: the MATLAB function that references a relocated asset (`sammi.m`,
  `generateIsotopomerSolver.m`, `optForceWithGAMS.m`, `findMust*WithGAMS.m`, `getAvailableGAMSSolvers.m`,
  `parse_Atomic_Weights_and_Isotopic_Compositions_for_All_Elements.m`). Stays in `src/`, gains
  path-independent resolution.
- **`external/` tree**: the existing third-party area mirroring `src/<domain>/` (Principle IX).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A scan of `src/` finds **zero** vendored non-MATLAB code files of the targeted classes:
  no SAMMI web-app `.js`/browser-`.html`/`demo.json`, no `c13solver/*.pl`, no `*.gms`.
- **SC-002**: The enumerated orphan and generated blobs are absent from `src/`: `base/io/python/tmp/`
  and the dead `demo.json` are relocated to `deprecated/`; `wang/cache/*.mat` and the generated SAMMI
  output HTML are removed and their patterns appear in `.gitignore`.
- **SC-003**: Each affected wrapper still resolves and uses its relocated asset: `sammi(...)` renders
  and opens its HTML; `generateIsotopomerSolver` invokes the relocated Perl when `perl` is present; the
  GAMS wrappers reference the relocated `.gms`; the NIST loader returns the same element table.
- **SC-004**: The touched-domain MATLAB test suites pass with no new failures versus the recorded
  pre-change baseline.
- **SC-005**: Measured `src/` size drops by at least the relocated footprint — the SAMMI JS+`demo.json`
  (~1.3 MB), the Perl solver, the GAMS models, and the two `wang/cache/*.mat` (~2.2 MB) — with figures
  confirmed against `analysis/metrics/scc-complexity-top.txt` rather than asserted.
- **SC-006**: A `git diff` of `src/*.m` shows only path-resolution edits (and deletions) — no change to
  any public function signature.

## Assumptions

- **Static-data destination** is a **dedicated repository resource path** (separate from `external/`),
  per Clarifications; the exact path/convention is fixed in `/speckit-plan`. Loaders resolve their data
  relative to the wrapper regardless of the chosen path.
- **Orphan/dead files move to `deprecated/`** (not deleted), per Clarifications; generated build
  artifacts (cache `.mat`, generated SAMMI HTML) are instead removed and gitignored (a build cache is
  not "superseded functionality" to deprecate).
- `initCobraToolbox` adds `external/` (recursively) to the MATLAB path; to be **verified as an early
  implementation task**. Regardless of the outcome, loaders are hardened to wrapper-relative resolution
  so correctness does not depend on this.
- The files identified as orphan (`base/io/python/tmp/*`, `demo.json`, and `validator.pl` if confirmed
  uninvoked) are genuinely unreferenced; each is re-grep'd before deletion (FR-005).
- Perl and GAMS are **optional** external tools; the touched tests already skip or fail cleanly when
  they are absent, so relocation is verified by path-resolution + smoke, not by requiring the tools.
- SAMMI's dependence on remote CDN scripts and internet access is pre-existing and out of scope; this
  feature does not change SAMMI's runtime network behavior.
- `taxa2proc_*.txt` are excluded from feature 013 (left in place); no classification or action is taken
  on them here (FR-011).

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1-1 / FR-001, FR-002 | repo-scan check (visualization tree has no web-app assets) + `testSammi`/visualization suite | `src/visualization/SAMMIM/sammi.m` |
| US1-2 / FR-002, FR-004 | `sammi` smoke (writes+resolves relocated `index.html`) | `src/visualization/SAMMIM/sammi.m` |
| US1-3 / FR-003 | signature diff of `sammi.m` (no public change) | `src/visualization/SAMMIM/sammi.m` |
| US2-1 / FR-001 | repo-scan check (no `.pl`/`.gms` under `src/`) | — (repository layout, no source function) |
| US2-2 / FR-002, FR-004 | fluxomics c13 suite / `generateIsotopomerSolver` smoke (perl present) | `src/dataIntegration/fluxomics/c13solver/generateIsotopomerSolver.m` |
| US2-3 / FR-002, FR-004 | optForce/MustFind path-resolution check | `src/design/optForceGAMS/optForceWithGAMS.m` |
| US3-1 / FR-005, FR-006 | repo-scan + `.gitignore` check (orphans/generated gone) | — (repository layout, no source function) |
| US3-2 / FR-007, FR-009 | `getMolecularMass`/`computeElementalMatrix` return-value equality vs baseline | `src/dataIntegration/chemoInformatics/molecularWeight/parse_Atomic_Weights_and_Isotopic_Compositions_for_All_Elements.m` |
| US3-3 / FR-008 | repo-scan check (no `.mlx` under `src/visualization/`) | — (repository layout, no source function) |
| SC-004 / FR-010 | touched-domain suites vs recorded baseline | (multiple, per domain above) |
