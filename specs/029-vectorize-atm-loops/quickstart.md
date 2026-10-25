# Quickstart: Validating the stage02 and createBIGraph vectorizations

## Prerequisites

- MATLAB R2024b+ with the COBRA Toolbox initialized (`initCobraToolbox(false)`).
- A MILP solver (Gurobi or GLPK) for the CI test's full-mode section. Neither rewritten code
  path needs a solver itself.
- **For the reproducibility check only** (not needed for the CI test):
  - the atom-mapped corpus at `/media/JACK/repos/ctf/rxns/atomMapped_std` (note: *not*
    `atomMapped_standardised`, which features 021/022 referenced and which no longer exists —
    research.md R8);
  - the subsystem submodels at
    `~/repos/ReconXKG-cidev/ReconXKGtoCobra/models/subsystemSubModels/subsystemSubModels.mat`;
  - patience: `pufa` takes hours per run, so plan it as a background session.

## Automated check (what CI runs)

```matlab
% from the repository root, after initCobraToolbox
run(fullfile('test', 'verifiedTests', 'analysis', 'testReactingMoieties', ...
    'testConservedReactingMoieties.m'));
run(fullfile('test', 'verifiedTests', 'analysis', 'testReactingMoieties', ...
    'testCreateBIGraph.m'));   % new: createBIGraph edge cases on synthetic graphs
```

Expected: passes with **every existing assertion intact and unmodified** (FR-009, SC-001). This
file is not edited by this feature — verify with `git diff` that it is untouched. It reaches
both rewritten code paths, because stage02 and the `createBIGraph` call both execute before the
`conservedMoietiesOnly` branch, so a gross regression fails here immediately. It does not prove
correctness at scale; the reproducibility check below does that.

## Reproducibility check (non-CI, the real evidence)

Order matters — the baseline must be captured **before** either source file is edited
(research.md R9).

```matlab
% 1. BEFORE any src/ edit: capture the golden baseline, per fixture
run('specs/029-vectorize-atm-loops/vectorizationReproducibilityCheck.m');

% 2. Apply the two rewrites (see tasks.md), then re-run the same script:
run('specs/029-vectorize-atm-loops/vectorizationReproducibilityCheck.m');
```

Mode is selected per fixture by whether that fixture's snapshot already exists, so an
interrupted run resumes rather than restarting (FR-011).

Expected on the second (compare) run, per fixture:

1. `ATM.Edges` after stage02 is `isequal` to the snapshot (SC-002) — all 8 fixtures, through
   the normal pipeline.
2. `BIG.Nodes`/`BIG.Edges` are `isequal` to the snapshot (SC-003) — all 8 fixtures, including
   `bileacid` now that `SCP2x.rxn` is quarantined.
3. The corpus provenance recorded for this run matches each snapshot's. If it doesn't, the
   harness reports "corpus changed since capture" for that fixture instead of a code
   regression — re-capture before trusting any comparison (research.md R11).
4. Before/after timings and derived speedups are appended to
   `vectorization-reproducibility-results.md`, with `tyr` meeting SC-004's ≥100x and ≥200x
   floors.

## Confirming the shipped diff is clean

```bash
git diff --stat            # exactly 2 files under src/, nothing else (SC-005)
git diff -- src/ | grep -nE "tic|toc"   # must print nothing (research.md R10)
```

The temporary timing instrumentation used for SC-004 must be reverted before commit; the
results file is the durable record of those numbers, not the code.

## Out of scope for this quickstart

- The `SCP2x.rxn` atom-mapping defect itself (FR-007). The file is quarantined in
  `atomMapped_std/flagged_for_review/`, which is why `bileacid` now completes; this feature
  neither fixes the defect nor depends on the quarantine being reversed. If the file is restored
  to the corpus, `bileacid` will fail again and its baseline becomes invalid.
- The two latent behaviours preserved deliberately (orientation-`0` rows; positional property
  assignment after `addedge`) — see contracts/function-interface.md. Neither may be "fixed"
  here.
