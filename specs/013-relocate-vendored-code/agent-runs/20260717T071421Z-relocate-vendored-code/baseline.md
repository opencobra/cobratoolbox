# Baseline (feature 013, pre/at-move) — 20260717T071421Z

## Environment
- MATLAB R2026a (26.1.0.3276743), COBRA Toolbox on path.
- `CBTDIR = fileparts(which('initCobraToolbox'))` = `/home/rfleming/drive/sbgCloud/code/fork-cobratoolbox` (repo root — initCobraToolbox.m is at root). All relocated-asset resolution is CBTDIR-anchored.
- Path foundation (T002): `external/` is added to the MATLAB path **selectively per-dependency** (e.g. checkCNAinstallation.m), not wholesale — so CBTDIR-anchored absolute paths are required, not `which`/path-search.

## Tool availability
- `perl`: **present** → the c13 solver path executes (edit correctness matters).
- `gams`: **absent** → optForce/GAMS wrappers skip/error the same before and after the move (baseline, not a regression).
- `statistics_toolbox`: **absent** → `testSammi` cannot run its body.

## Touched-domain test baseline (T003)
- `testSammi`: **RequirementsNotMet** — errors at `prepareTest` (line 19, requires `statistics_toolbox`) *before* any SAMMI code or my edits (sammi.m L110+, testSammi.m L222) is reached. Identical before/after this feature. Substantive verification done via direct `sammi(...)` smoke (template resolves from external/, output written, asset paths rewritten to external/, demo.json fixture case works).
- `testOptForce`: gated by `gams` (absent) → skips; unaffected by path-only edits.
- c13 `generateIsotopomerSolver`: no dedicated verifiedTest found; verified via `check_matlab_code` + path-resolution reasoning (perl present).
- `wang` group-contribution: `autoFragment_*.mat` cache referenced by no code/test (grep empty) → safe to delete; regenerable.

## Orphan re-confirmation (T004)
- `demo.json`: **NOT an orphan** — live fixture in `testSammi.m:222`. Relocated to `test/verifiedTests/visualization/testSammi/demo.json` (user-approved deviation), not `deprecated/`.
- `base/io/python/tmp/*`: genuine orphans (the `writeGDXFromCOBRA.m` grep hit was "my**mod**el" in a comment).
- `validator.pl`: mentioned only in a comment (`generateIsotopomerSolver.m:4`); moves to `external/` with the `*.pl` set.
