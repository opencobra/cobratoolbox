# Data model

- **Mode** (`initCobraToolbox` `mode`): one of `'default' | 'agent' | 'runmat'`. `'runmat'` implies the agent
  flow and sets `runmatMode`, which only the registered workarounds read.
  - Validation: `'runmat'` together with `updateToolbox = true` is an error (`initCobraToolbox:invalidMode`).
- **RunMat switch** (`COBRA_RUNMAT`): on only when `'1'`.
- **Debt marker**: the comment `% RUNTIME-DEBT(RunMat:<id>)` on or directly above the changed code. It
  identifies (file, defect).
- **Workaround entry**: `{defect id, file, construct, MATLAB behaviour replaced, removal condition, reproducer
  path}`.
  - Must match the markers one to one, keyed by (file, defect).
  - States: *still needed* → *removable* (the re-check sees RunMat give the expected output) → removed by a
    spec-driven change.
- **Blocking-defect entry**: `{defect id, effect on COBRA, files affected (count), reproducer path}`. It has no
  marker.
  - States: *blocking* → *removable* (fixed in RunMat), after which SC-001 can be re-measured as complete.
- **Reproducer**: `{<id>.m (≤ 10 lines), expected.txt (MATLAB output), mode (run | test-list)}`.
