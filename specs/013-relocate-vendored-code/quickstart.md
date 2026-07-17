# Quickstart / Validation Guide: 013 Relocate vendored code/data

This proves each slice is behavior-preserving. Run via the MATLAB MCP server. See
[data-model.md](./data-model.md) for the move manifest and [research.md](./research.md) for the
resolution decisions. **No source is edited until Gate 2 approval + `/speckit-implement`.**

## Prerequisites

- MATLAB with the COBRA Toolbox initialized: `initCobraToolbox(false)` (no update).
- `perl` and `gams` are optional; if absent, the c13/GAMS suites *skip* — record that as baseline, not
  a regression.

## Step 0 — Capture baseline (before any move)

For each touched domain, run its tests and record pass/skip/fail:

```matlab
% examples — run the actual test files present under test/verifiedTests/<domain>/
run_matlab_test_file('test/verifiedTests/visualization/testSammi.m')      % if present
run_matlab_test_file('test/verifiedTests/analysis/testChemoInformatics*') % molecularWeight/NIST
run_matlab_test_file('test/verifiedTests/dataIntegration/testC13*')       % fluxomics
run_matlab_test_file('test/verifiedTests/design/testOptForce*')           % GAMS
run_matlab_test_file('test/verifiedTests/analysis/testGroupContribution*')% thermo cache
```

Record results into `agent-runs/<run>/baseline.md` (pass/skip counts per suite). This is the SC-004
comparison target.

## Step 1 — Validate P1 (SAMMI)

After the slice:

```matlab
% no SAMMI web-app assets remain under src/
assert(isempty(dir(fullfile(fileparts(which('sammi')),'*.js'))))
% template resolves from external/ and sammi renders without error
CBTDIR = fileparts(which('initCobraToolbox'));
assert(exist(fullfile(CBTDIR,'external','visualization','SAMMIM','index.html'),'file')==2)
sammi(model);   % writes + opens output HTML; local <script src> resolve to external/ JS
```

Expected: `sammi.m` signature unchanged (SC-006); output HTML written to the same default location as
before; no `.js/.json/demo.json/generated .html` under `src/visualization/SAMMIM/` (SC-001/SC-002).

## Step 2 — Validate P2 (Perl + GAMS)

```matlab
% no .pl / .gms remain under src/
assert(isempty(dir(fullfile(fileparts(which('generateIsotopomerSolver')),'*.pl'))))
assert(isempty(dir(fullfile(fileparts(which('optForceWithGAMS')),'*.gms'))))
```

- With `perl` present: `generateIsotopomerSolver(...)` produces the same solver output as baseline.
- GAMS wrappers construct `system('gams <CBTDIR-abs .gms> …')` — confirm the referenced model path
  exists under `external/`. With `gams` absent, behavior matches baseline (same skip/error).

## Step 3 — Validate P3 (data / orphans / generated / tutorial)

```matlab
% NIST loader returns the identical table after the move
w1 = getElementalWeightMatrix();      % or getMolecularMass(...) on a known metabolite
% compare w1 to the baseline value captured in Step 0
assert(isequal(w1, baselineWeights))
% orphans relocated, generated removed, tutorial moved
assert(exist(fullfile(fileparts(which('initCobraToolbox')),'src','base','io','python','tmp'),'dir')==0)
assert(isempty(dir('**/wang/cache/autoFragment_*.mat')))    % removed + gitignored
```

Note: the static-data (`data/`) moves are **gated on the constitution `data/` amendment**; if that is
deferred, run Step 3 for the orphan/generated/tutorial parts only.

## Step 4 — Repo-level checks

```bash
# generated artifacts gitignored, none committed
git status --porcelain | grep -E 'wang/cache|index_load|sammi_test_output' && echo "LEAK" || echo "clean"
# measurable src/ reduction, confirmed against analysis/metrics
```

Expected: `git diff src/**/*.m` shows only path-resolution edits (SC-006); measured `src/` size drops
by at least the SAMMI JS+demo.json (~1.3 MB) + Perl + GAMS + wang cache (~2.2 MB), confirmed against
`analysis/metrics/scc-complexity-top.txt` (SC-005).
