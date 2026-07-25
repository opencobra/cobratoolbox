# Backfill audit notes (feature 001-ci-coverage-gating)

- Total ungated test*.m under test/verifiedTests/: **169** (of 260; 91 already gated).
- **38** genuinely exercise a solver/toolbox and receive a `prepareTest(...)` guard (edit set;
  see backfill-audit.csv rows with noneNeeded=no).
- **131** are solver-free and receive **no** declaration (noneNeeded=yes): utility / exploration
  / IO / printing tests that do not call a solver and therefore never hard-fail on a missing one.

## Verified self-guarded cases left as none-needed (do NOT hard-fail):
- `analysis/testMultiSpeciesModelling/testTranslateMetagenome2AGORA.m` — entire body is wrapped
  in `if ispc && exist('AGORA_infoFile.xlsx','file')`; a silent no-op on Linux CI (it `curl`s
  ebi.ac.uk only under that guard). Candidate future improvement: convert to
  `prepareTest('needsWindows', true, 'needsWebAddress', '<url>')` so it reports as *skipped*
  rather than a silent pass — deferred (would change reported status).
- `base/testInstall/testAddKeyToKnownHosts.m` — checks `system('ssh-keyscan')` status before
  using it; degrades gracefully if ssh is absent.
- `reconstruction/testMassChargeBalance` (`system rm`), `reconstruction/testRBioNet/testRBioNetSaveLoad`
  (`system git checkout` of fixtures) — local file ops; git always present in CI.

## Verified: no none-needed file uses parfor/parpool, Statistics/Optimization-Toolbox
## functions, webread, or a solver — so none of the 131 will hard-fail on a missing
## solver/toolbox. (Confirmed by grep scans, 2026-07-13.)
