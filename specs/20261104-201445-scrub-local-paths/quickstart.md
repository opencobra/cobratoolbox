# Quickstart: Validate the removal

Run from the repository root. `$USER` expands locally, so these commands hold no personal detail.
Run MATLAB only through the guarded launcher, one session at a time.

## 1. Scan (SC-001, SC-002)

```sh
git grep -n -I -E "[-/]home[-/]$USER|/Users/$USER" -- .
git grep -n -I -iE '[0-9]+ cores|[0-9]+ ?GB RAM' -- <the 19 files in the spec's Scope section>
```

Expected: no output from either.

## 2. Scope (FR-010, SC-006)

```sh
git diff --name-only upstream/develop...HEAD
```

Expected: the 19 listed files, the feature directory and `.specify/feature.json` only. Nothing under `src/` or `test/`.

## 3. Line review (FR-006, FR-007, SC-004, SC-005)

```sh
git diff -U0 upstream/develop...HEAD -- ':!specs/20261104-201445-scrub-local-paths'
```

Expected: every changed line holds a personal detail, its replacement, a redaction note or the new
path handling, and each of the five receipts has one note.

## 4. Scripts from another location (SC-003)

Copy the two `bench` folders into a temporary tree with the same `specs/<feature>/bench` layout. Add a
`src/` folder with a marker function, and stub `initCobraToolbox` and `changeCobraSolver` on the path.
Then confirm:

- `diffDup({})` and `diffRFE({})`: the working folder is the temporary root and
  `which('checkDuplicateRxnRef')` and `which('removeFieldEntriesForTypeRef')` are under it.
- `runTest` with an unknown test: the working folder is the temporary root.
- `profRun` and `stageRun` with an unknown stage and a small `.mat` file: the marker function resolves.
- `ownCode` with `COBRA_BENCH_MODEL` unset: stops with a message naming the variable.
- `ownCode` with it set to a small model: the marker function resolves.
- `stageRun('feasibility', ...)` with `COBRA_BENCH_EXTRA_CODE` unset: stops with a message naming it.

## 5. Scripts in the real clone (US2)

- `diffDup({})` and `diffRFE({})` print their summary lines.
- `runTest` on a small test writes `PASS` and the executed lines.
- `stageRun('dupFR', ...)` on a small distributed model appends a result line with status `ok`.
- `ownCode` with `COBRA_BENCH_MODEL` set to a small model prints its timing lines.
