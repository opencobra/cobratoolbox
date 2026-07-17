# Phase 1 Data Model: Relocation Manifest

This feature has no runtime data entities. Its "model" is the **relocation manifest**: each asset, its
current location, destination, resolution mechanism after the move, and disposition. Slices map to the
three user stories. Paths are repo-relative.

## Asset classes (entities)

- **VendoredCode** — non-MATLAB source shipped in `src/` → `external/<domain>/`. Referenced by a
  `src/` wrapper that resolves it via CBTDIR (D1).
- **StaticData** — third-party reference/input data → `data/<domain>/` (D2; gated on constitution
  amendment). Loader stays in `src/`, resolves via CBTDIR.
- **Orphan** — unreferenced scratch/dead file → `deprecated/` (D6). Re-grep before moving.
- **GeneratedArtifact** — committed build output → deleted + gitignored (D7).
- **Tutorial** — `.mlx` living under `src/` → `tutorials/<domain>/` (D8).

## Slice P1 — SAMMI (User Story 1)

| Asset | From | To | Resolution / disposition |
|---|---|---|---|
| helpfunctions.js, uploaddownload.js, simulationfunctions.js, sammi.css, index.html | src/visualization/SAMMIM/ | external/visualization/SAMMIM/ | `sammi.m` resolves template dir via CBTDIR; generated HTML `<script src>` rewritten to CBTDIR-absolute |
| demo.json (dead, 1.1 MB) | src/visualization/SAMMIM/ | deprecated/_SAMMIM_demo/ | Orphan; re-grep first |
| index_load.html, index_load2.html, sammi_test_output.html | src/visualization/SAMMIM/ | (deleted) | GeneratedArtifact; add gitignore pattern |
| sammi.m, openSammi.m, makeSAMMI*.m, expa.m | src/visualization/SAMMIM/ | (stay) | Wrapper edit: CBTDIR-anchored template + script-src paths; default output location unchanged |

## Slice P2 — Perl + GAMS (User Story 2)

| Asset | From | To | Resolution / disposition |
|---|---|---|---|
| generatorEMU.pl, generatorCumomer.pl, optimizerEMU.pl, optimizerCumomer.pl, validator.pl | src/dataIntegration/fluxomics/c13solver/ | external/dataIntegration/fluxomics/c13solver/ | `generateIsotopomerSolver.m` invokes `perl <CBTDIR-abs .pl>` from writable cwd |
| findMustL/LL/U/UL/UU.gms, optForce.gms | src/design/optForceGAMS/ | external/design/optForceGAMS/ | wrappers reference model by CBTDIR-abs path in `system('gams …')` |
| licememo.gms | src/base/solvers/gams/ | external/base/solvers/gams/ | `getAvailableGAMSSolvers.m` resolves via CBTDIR (replaces `which`) |
| generateIsotopomerSolver.m, optForceWithGAMS.m, findMust*WithGAMS.m, getAvailableGAMSSolvers.m | (respective src/) | (stay) | Wrapper edits: CBTDIR-anchored paths, invocation semantics unchanged |

## Slice P3 — Data / orphans / generated / tutorial (User Story 3)

| Asset | From | To | Resolution / disposition |
|---|---|---|---|
| Atomic_Weights_..._Elements.txt (NIST) | src/dataIntegration/chemoInformatics/molecularWeight/basicPhysicochemicalData/ | data/dataIntegration/chemoInformatics/molecularWeight/ | `parse_Atomic_Weights...m` resolves via CBTDIR (replaces bare `fopen`). **Gated on constitution `data/` amendment** |
| VMH_reactionList.xlsx | src/reconstruction/metaboRePort/ | data/reconstruction/metaboRePort/ | loader hardened to CBTDIR. Same gate |
| Parsed_hmdbConc.xlsx | src/analysis/wholeBody/PSCMToolbox/setConstraints/inputData/ | data/analysis/wholeBody/… | loader hardened to CBTDIR. Same gate |
| base/io/python/tmp/* | src/base/io/python/ | deprecated/_io_python_tmp/ | Orphan; re-grep first |
| wang/cache/autoFragment_*.mat | src/analysis/thermo/groupContribution/wang/cache/ | (deleted) | GeneratedArtifact; gitignore `**/wang/cache/` |
| tutorial_eFBA.mlx | src/visualization/entropicFBA/ | tutorials/analysis/ | Tutorial move (byte-identical) |
| taxa2proc_{a2a,agora}_out.txt | src/analysis/persephone/SeqC_pipeline/ | (unchanged) | **Out of scope** (Clarifications) |

## Invariants

- Every moved file is **byte-identical** (`git mv`/move, not rewrite) — FR-009.
- No public MATLAB function name/signature/documented behavior changes — FR-003.
- After each slice, touched-domain tests match the pre-change baseline — FR-010 / SC-004.
