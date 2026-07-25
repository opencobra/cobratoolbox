# Phase 0 Research: Relocate vendored code/data out of `src/`

All findings are from read-only inspection of the repo at branch `013-relocate-vendored-code`.

## D1 — Path-resolution anchor for relocated assets

**Decision**: Every `src/` wrapper resolves its relocated asset from the toolbox root
`CBTDIR = fileparts(which('initCobraToolbox'))` (the established global), building the path with
`filesep`. No bare `fopen`/`cd`-relative/`which('<asset>')` resolution.

**Rationale**: `CBTDIR` is already the canonical anchor across `src/` (`solveCobraLP.m`,
`getDistributedModel.m`, `sbmlTestModelToMat.m`, `generateSystemConfigReport.m` all use
`fileparts(which('initCobraToolbox'))`). Critically, **`external/` is NOT added to the MATLAB path
wholesale** — `initCobraToolbox` adds `external/` subtrees *selectively per dependency* (e.g.
`checkCNAinstallation.m:26` does `addpath(genpath([CBTDIR filesep 'external' filesep 'analysis' filesep
'CnaCobraInterface']))`). So a relocated asset under `external/` is generally *not* on the path, and
`which`/path-search resolution would fail. CBTDIR-anchored absolute paths are robust regardless of
what is on the path — this discharges FR-004 and the "external/ not on path" edge case.

**Alternatives rejected**: (a) wrapper-relative `which('<wrapper>')` — works only while the asset sits
beside the wrapper, which it no longer does; (b) adding the new `external/`/data dirs to the path via
`initCobraToolbox` — larger blast radius, and unnecessary once resolution is CBTDIR-anchored.

## D2 — Destination for static third-party DATA (the "dedicated resource path")

**Decision**: New top-level **`data/<domain>/`** (e.g. `data/dataIntegration/chemoInformatics/…` for
the NIST table). `binary/` is compiled platform binaries only (`glnxa64/bin/*.mexa64`, `.class`,
`.jar`) — not a data home.

**Constitution note (surfaced, not resolved here)**: constitution v1.3.0's Principle IX role map
(lines 510–533) does **not** define a `data/` (or `resources/`) role — it maps `external/`,
`deprecated/`, `tutorials/`, `documentation/`, `specs/`. `docs/repository-layout.md` does not exist.
The plan-template's placement bullet references `data/`/`results/`/Git-LFS, but that is upstream Spec
Kit boilerplate not reconciled with this constitution, and **the constitution wins**. Introducing
`data/` is therefore a *new layout convention*. Per Principle X (single-sourcing) it must be recorded
in the constitution's role map. Because a feature must not edit the constitution directly, the
**static-data-move slice is gated on a companion `/speckit-constitution` amendment** that adds the
`data/` role. This is tracked in Complexity Tracking and flagged for Gate 2.

**Alternatives rejected**: `external/` (user's clarify decision was explicitly *separate* from
third-party code); keep in `src/` (that is the weakness). `resources/` was considered; `data/` chosen
to match the plan-template's evident intent and "raw immutable input data" phrasing.

## D3 — SAMMI slice mechanics

**Findings**: `sammi.m:111` `sfolder = regexprep(which('sammi'),'sammi.m$','')`; `:112` reads
`[sfolder 'index.html']` (template); `:191` injects JSON at `//MATLAB_CODE_HERE//`; `:202` writes the
output HTML to `fullfile(sfolder, [name ext])` (i.e. **into `src/` beside `sammi.m`** — itself a layout
smell). `index.html` loads the local `.js` by relative `<script src>` **and** remote CDN scripts
(pre-existing internet dependency).

**Decision**:
- Move `helpfunctions.js`, `uploaddownload.js`, `simulationfunctions.js`, `sammi.css`, `index.html`
  → `external/visualization/SAMMIM/`. Move dead `demo.json` → `deprecated/` (D6).
- `sammi.m` resolves the template dir via CBTDIR: `[CBTDIR filesep 'external' filesep 'visualization'
  filesep 'SAMMIM' filesep]`.
- The generated HTML's local `<script src>` paths are rewritten to CBTDIR-anchored absolute file paths
  so they resolve wherever the output HTML is written.
- **Default output location is preserved** (Principle II): the generated HTML still lands where users
  expect (the `options.htmlName`/`sfolder` default). Only the *committed* generated HTML files are
  removed and the pattern is gitignored (D7) — the runtime still writes output; it is just never
  committed.

**Rationale**: keeps the `sammi.m` signature and default output behavior unchanged while removing the
committed GPLv3 JS and committed generated HTML from `src/`. **Alternative rejected**: changing the
default output directory (a Principle II behavior change).

## D4 — Perl 13C slice mechanics

**Findings**: `generateIsotopomerSolver.m:88` `cd(xdir)` then `:90–96` `perl generatorEMU.pl;` … ;
`:98` `cd(oriFolder)`. The `.pl` read/write `IsotopomerModel.txt` in the working directory (written by
the same `.m` via `export(...)`).

**Decision**: Move the five `.pl` → `external/dataIntegration/fluxomics/c13solver/`. Invoke each with
its **CBTDIR-anchored absolute path** (`perl [CBTDIR filesep 'external' … filesep 'generatorEMU.pl']`)
from a *writable* working directory (the existing `IsotopomerModel.txt` I/O location — a `src/` or temp
dir), rather than `cd`-ing into the now-external (read-only) solver dir. Preserves the read/write-in-cwd
contract; only the script source path changes. `validator.pl` (uninvoked) moves with the set.

## D5 — GAMS slice mechanics

**Findings**: `optForceWithGAMS.m` / `findMust*WithGAMS.m` build `system(['gams ' <model> ' … gdx=…'])`;
`getAvailableGAMSSolvers.m:37` `which('licememo.gms')`, `:45` `copyfile(...)`, `:49` `system('gams
licememo')`. GAMS writes `.gdx` outputs to cwd.

**Decision**: Move `optForceGAMS/*.gms` → `external/design/optForceGAMS/`; `gams/licememo.gms` →
`external/base/solvers/gams/`. Reference each model by CBTDIR-anchored absolute path in the `gams`
invocation (and replace `which('licememo.gms')` with the CBTDIR path). Keep the working directory that
receives `.gdx`/input `.txt` writable (unchanged from today). Invocation semantics unchanged; only the
model path changes (Principle IV preserved).

## D6 — Orphans → `deprecated/`

**Decision**: Move `src/base/io/python/tmp/*` and the dead `src/visualization/SAMMIM/demo.json` to
`deprecated/`, following the existing underscore-prefixed style (e.g. `deprecated/_io_python_tmp/`,
`deprecated/_SAMMIM_demo/`). **Re-grep each file for inbound references immediately before moving**; if
any reference exists, treat it as live code (relocate appropriately), not an orphan.

## D7 — Generated artifacts → delete + gitignore

**Findings**: `.gitignore` currently has no SAMMI/cache/tmp entries.
**Decision**: Delete `src/analysis/thermo/groupContribution/wang/cache/autoFragment_*.mat` and the
generated SAMMI output HTML (`index_load.html`, `index_load2.html`, `sammi_test_output.html`); add
patterns to `.gitignore` (`**/groupContribution/wang/cache/`, the SAMMI generated-HTML pattern). These
are regenerable build outputs, not "superseded functionality," so delete+ignore (not `deprecated/`).

## D8 — Tutorial → `tutorials/`

**Decision**: Move `src/visualization/entropicFBA/tutorial_eFBA.mlx` → `tutorials/analysis/`
(entropic-FBA is an analysis method; `tutorials/` has per-domain subdirs but no `visualization/`).
Confirm the exact subdir at implementation; `.mlx` is byte-identical moved.

## D9 — Verification strategy

**Decision**: Capture a per-domain **baseline** (touched-domain tests + smoke) via the MATLAB MCP
(`run_matlab_test_file`, `run_matlab_file`) *before* any move, recording pass/skip status (absent
`perl`/`gams` → skip = baseline, not regression). After each slice, re-run and compare (SC-004); run
`check_matlab_code` on every edited wrapper. Smoke: `sammi(...)` resolves+writes from `external/`;
`getMolecularMass`/`computeElementalMatrix` return the identical element table post-move; GAMS/c13
wrappers build paths pointing at relocated files.
