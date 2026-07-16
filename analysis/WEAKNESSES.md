# COBRA Toolbox — Architectural Weakness Register

Prioritized, evidence-backed register of **structural** weaknesses (not style), ordered by
severity. Each entry is framed as a candidate `/speckit-specify` feature so it can drop
straight into the Spec Kit workflow. Evidence paths and metrics are reproducible from
`analysis/metrics/` and the MATLAB Code Analyzer run (`analysis/metrics/matlab-codeanalyzer.md`).

Severity key: **High** = threatens correctness, backward-compat, testability, or the
polyglot goal on a core path. **Medium** = real structural debt with contained blast radius.
**Low** = localized cleanup.

Constitution anchors are cited per item (Principles II, III, IV, V, VII, VIII, IX).

---

## HIGH

### W1 — Solver/config state lives in ~18 mutable globals accessed via `eval`
- **Severity:** High. (Constitution IV solver abstraction; VIII polyglot; VII-D.)
- **Evidence:** `initCobraToolbox.m:47–64` establishes 18 globals (`CBTDIR`, `SOLVERS`,
  `OPT_PROB_TYPES`, `CBT_{LP,QP,MILP,MIQP,NLP,EP,CLP}_SOLVER`, `CBT_*_PARAMS`, `*_PATH`,
  `ENV_VARS`). `changeCobraSolver.m:177–192` declares 16 globals (all Code-Analyzer-flagged:
  "Global variables are inefficient and make errors difficult to diagnose"). Solver name and
  params are set/read through `eval`-built names — `changeCobraSolver.m:531–564`,
  `parseSolverParameters.m:33–34`, `changeCobraSolverParams.m:85`.
- **Risk:** Solver selection is ambient, not a parameter — so unit tests must mutate/restore
  globals, parallel/`parfor` runs are unsafe, static analysis can't follow the `eval`, and a
  language-neutral (Python/Julia) solver contract is impossible while state is MATLAB-global.
- **Candidate feature:** *Introduce a `CobraSolverState` accessor/struct (backward-compatible
  shim over the existing globals) and thread it explicitly through `solveCobra*`.*

### W2 — Solver dispatch is a monolithic per-solver `switch`; status maps duplicated 4×
- **Severity:** High. (Constitution IV.)
- **Evidence:** `solveCobraLP.m` is 1,897 lines / complexity 158 with a 17-solver `switch`
  spanning lines 235–1545; `solveCobraQP.m` (10 cases), `solveCobraMILP.m` (7),
  `solveCobraMIQP.m` (4) repeat the pattern. There is **no central status map**: gurobi's
  native→canonical `.stat` translation is rewritten independently in LP/QP/MILP/MIQP, and the
  `dqqStatMap` table is duplicated *twice within one file* (`solveCobraLP.m:419` and `:555`).
  Only mosek is factored out (`mosek/parseMskResult.m`). Code Analyzer flags 10 unreachable
  statements in `solveCobraLP.m`.
- **Risk:** Adding or fixing a solver means editing 4–6 giant files in lockstep; the four
  dispatchers drift, so the canonical `.stat` a caller sees can disagree across problem types
  — a silent scientific-correctness hazard (Principle I).
- **Candidate feature:** *Extract one `mapSolverStatus(solver, problemType, origStat)` helper
  and a per-solver `solvers/<name>/` adapter, converting the switch into a registry lookup on
  `SOLVERS`.*

### W3 — ~26 analysis/design/dataIntegration files bypass the solver abstraction
- **Severity:** High. (Constitution IV; II.)
- **Evidence:** 39 files outside `src/base/solvers` name a solver directly
  (`analysis/metrics/coupling-corroboration.txt`); ~26 are production leaks. Whole subtrees
  are single-solver islands: `analysis/multiSpecies/SteadyCom/*` constructs `Cplex()` objects
  directly (CPLEX-only), `design/TrimGdel/*` calls `gurobi()` directly (Gurobi-only).
  Point leaks include `analysis/ICONGEMs/ICONGEMs.m:277` (`gurobi(model2,params)`),
  `analysis/QFCA/directionallyCoupled.m:42`, `dataIntegration/transcriptomics/SWIFTCORE/core.m`
  (`strcmp(solver,'gurobi')` / `'cplex'` branch), `analysis/uFBA/buildUFBAmodel.m`
  (hardcodes `changeCobraSolver('gurobi',…)` ×7).
- **Risk:** These modules break whenever the user's configured solver differs, re-implement
  status/param handling the spine already provides, and are unusable in the community's
  heterogeneous solver installs — exactly what the abstraction exists to prevent.
- **Candidate feature:** *Route the SteadyCom and TrimGdel islands (and the point leaks)
  through `solveCobra{LP,QP,MILP,MIQP}`; where a genuinely solver-specific capability is
  needed, expose it behind the dispatcher.*

### W4 — Circular dependency `analysis ↔ reconstruction` and a `base` layering inversion
- **Severity:** High. (Constitution IX file organization; V scope control.)
- **Evidence:** `analysis/metrics/coupling-matrix.txt`. `reconstruction → analysis` = 1,672
  refs (`optimizeCbModel` in 31 files, `printRxnFormula`, `changeRxnBounds`); `analysis →
  reconstruction` = 888 (`addReaction`/`removeRxns` in 14 files each, `verifyModel`). The
  foundation `base` calls **up**: `base/solvers/optimizeTwoCbModels.m`,
  `entropicFBA/entropicFluxBalanceAnalysis.m`, `NLP/optimizeCbModelNLP.m` call
  `optimizeCbModel`; `io/readCbModel.m`, `io/writeCbModel.m`, `solvers/buildOptProblemFromModel.m`
  call `verifyModel` (up into reconstruction).
- **Risk:** No acyclic layering means any refactor of the FBA core or model-construction
  primitives ripples both ways; `base` cannot be reused or ported independently; the polyglot
  split (which needs a clean core) is blocked.
- **Candidate feature:** *Break the cycle by relocating the shared primitives (`verifyModel`,
  `columnVector`, GPR helpers) into `base`, and define `base` as a dependency sink that never
  calls up into `analysis`/`reconstruction`.*

### W5 — Monolithic god-files on core and validation paths
- **Severity:** High. (Constitution VII MATLAB standards; III testability; IX one-function-per-file.)
- **Evidence (`analysis/metrics/scc-complexity-top.txt`):**
  `src/analysis/wholeBody/PSCMToolbox/Test4HumanFctExtv5.m` (7,718 lines, complexity 1,044),
  `src/reconstruction/modelGeneration/test4HumanFctExt.m` (8,378 lines, cx 466) — two
  validation god-scripts totalling ~14 K lines shipped in the source tree;
  `src/dataIntegration/XomicsToModel/XomicsToModel.m` (2,290 lines, cx 325; Code Analyzer: 6
  grow-in-loop + 12 unreachable warnings); `src/analysis/FBA/optimizeCbModel.m` (1,045 lines,
  cx 107) fuses 8+ `minNorm` strategies plus `if 0` debug blocks.
- **Risk:** The single most-depended-upon analysis function (`optimizeCbModel`, 940 call
  sites) and the flagship omics builder are effectively untestable and unsafe to change; the
  two validation monoliths inflate complexity and belong in a test/validation area, not `src/`.
- **Candidate feature:** *Decompose `optimizeCbModel` per-`minNorm` strategy behind a dispatch
  table (behavior-preserving), and relocate `Test4HumanFctExtv5.m`/`test4HumanFctExt.m` to a
  validation harness under `test/`.*

### W6 — No schema validation on the default FBA path; no model accessor layer
- **Severity:** High. (Constitution I model correctness; II field stability.)
- **Evidence:** `optimizeCbModel` never calls `verifyModel` (0 grep hits); validation runs
  only when `verify=true`, whose default is off (`getCobraSolverParams.m:98`, gated in
  `buildOptProblemFromModel.m:138`). Field access is pervasive and unmediated: `model.rxns`
  in 286 src files, `model.S` in 184, `model.lb` in 137. The schema itself is a hand-edited
  TSV run through nested `eval` (`getDefinedFieldProperties.m:181–183`) and already contains a
  typo (`comps` default `['C' num2str{i}]`, curly-brace syntax error, `COBRA_structure_fields.tab:15`).
- **Risk:** A malformed model (wrong-sized `lb`, missing `csense`) silently reaches the solver
  and yields a wrong or misinterpreted result; any field rename/retype touches hundreds of
  files because there is no getter/setter seam.
- **Candidate feature:** *Add a lightweight dimension/consistency assert in
  `buildOptProblemFromModel` (default-on for interactive calls) and introduce
  `getModelField`/`setModelField` accessors, migrating the hottest fields first.*

### W7 — Core paths and entire high-value subtrees have zero or near-zero tests
- **Severity:** High. (Constitution III testing.)
- **Evidence (`analysis/metrics`, agent-verified):** `XomicsToModel` (34 files, the flagship
  builder) has **0** tests (`rg XomicsToModel test` = 0); `dataIntegration/metaboAnnotator`
  (72 files) **0**; `analysis/wholeBody`/`PSCMToolbox` (57 files) **0**;
  `buildOptProblemFromModel` referenced by only 3 tests; `visualization/metabolicCartography`
  (49 files) 1 test. Overall src:test ratio 6.1:1; `dataIntegration` is thinnest at 11.3:1.
- **Risk:** The refactors above (W1–W6) cannot be done safely without a behavioral net; core
  scientific behavior can regress undetected.
- **Candidate feature:** *Add minimal characterization/smoke tests (build a tiny model → run →
  assert feasibility + pinned objective) for `optimizeCbModel`, `buildOptProblemFromModel`,
  `XomicsToModel`, and one test per zero-coverage subtree, each `prepareTest`-gated.*

### W8 — Coverage is never measured in CI; only ~18% of tests declare requirements
- **Severity:** High. (Constitution III; CI reproducibility.)
- **Evidence:** `codecov.yml` exists but `rg codecov .github Jenkinsfile` = nothing; the MoCov
  branch in `testAll.m` (lines 103, 263) fires only when `MOCOV_PATH`+`JSONLAB_PATH` are set,
  which `testAllCI_step1.yml`'s Docker run never sets — CI publishes only pass/fail via
  JUnit→CTRF. Only **48 of ~260** verifiedTests call `prepareTest` (`prepareTest.m`); the other
  ~82% hard-fail (not skip) when a solver/toolbox is absent. CI runs only gurobi, so
  cplex/mosek/tomlab-pinned tests silently skip and skip-count is not a gate.
- **Risk:** Coverage erosion and solver-specific regressions are invisible; "green CI" is
  misleading; the constitution's coverage-maintained success criterion can't be checked.
- **Candidate feature:** *Wire MOcov + `codecov/codecov-action` into `testAllCI_step1.yml`,
  backfill `prepareTest` declarations across ungated tests, and make skip-count a CI threshold.*

---

## MEDIUM

### W9 — Vendored third-party code and data blobs live inside `src/`
- **Severity:** Medium. (Constitution IX `external/` boundary; V vendored-path rule.)
- **Evidence:** A complete GPL-3 JavaScript web app (SAMMI) sits in
  `src/visualization/SAMMIM/` — `helpfunctions.js` (128 KB, cx 1,016) + `demo.json` (1.1 MB,
  31,916 LOC), ~84% of the visualization dir's LOC. Also: a Perl 13C solver
  (`dataIntegration/fluxomics/c13solver/*.pl`, 1,253 LOC), GAMS models
  (`design/optForceGAMS/*.gms`), scratch Python + a Jupyter notebook (`base/io/python/tmp/`),
  and a 2,818-line NIST data table in `chemoInformatics/`.
- **Risk:** Inflates `src/` LOC/complexity, mixes non-MATLAB licenses into the toolbox tree,
  and violates the layout that keeps source reviewable.
- **Candidate feature:** *Relocate vendored assets to `external/` (or fetch-on-demand) and
  static data to a resource path, leaving only thin MATLAB wrappers in `src/`.*

### W10 — Embedded research applications inside the library tree
- **Severity:** Medium. (Constitution IX; V.)
- **Evidence:** `analysis/persephone/` (50 files — a standalone microbiome-metabolomics stats
  pipeline: volcano/forest plots, regressions, `runMars`/`runSeqC`), `analysis/wholeBody/PSCMToolbox/`
  (57 files, versioned `v5`), `reconstruction/demeter/` (95 files — an AGORA pipeline with its
  own tests/reports/SBML writer), `reconstruction/rBioNet/` (40-file interactive GUI).
- **Risk:** Blurs the library/application boundary, bloats domain complexity, and drags GUI +
  external-tool orchestration into a headless-CI-required toolbox.
- **Candidate feature:** *Carve standalone pipelines/GUIs into a clearly-labelled
  `applications/` namespace (or separate repos) with their own manifests, keeping `src/` as
  reusable library functions.*

### W11 — `deprecated/` is on the runtime path with 2 shadow collisions
- **Severity:** Medium. (Constitution II; IX.)
- **Evidence:** `initCobraToolbox.m:351` includes `'deprecated'` in the `genpath` folder list,
  so all 74 deprecated `.m` become globally callable. Two basenames exist in **both** `src/`
  and `deprecated/` — `changeCbMapOutput` (`src/visualization/maps/ReconMap/` vs `deprecated/_maps_old/`)
  and `testFluxConsistency` — so which runs depends on path order.
- **Risk:** A retired implementation can silently shadow the live one, changing behavior by
  path accident — a reproducibility hazard.
- **Candidate feature:** *Remove `deprecated/` from the runtime path (keep it for reference
  only) and resolve the two shadowed names.*

### W12 — Duplicated logic families (design, visualization, thermo, GPR)
- **Severity:** Medium. (Constitution V; VII.)
- **Evidence:** `visualization/paint4net/` **and** `paint4Net/` ship near-identical drawing
  code (`bio_draw_by_rxn.m` cx 98 vs `draw_by_rxn.m` cx 93) — case-only-different folders that
  collide on case-insensitive filesystems. `design/optForce/` is mirrored file-for-file by
  `design/optForceGAMS/`, and `findMustUU/LL/UL.m` are ~712-line cx-42 triplets (×2 again in
  GAMS variants). `analysis/thermo/*/old` shadow `*/new`. The model carries `rules` **and**
  `grRules` with lossy bidirectional conversion (`generateRules.m` ↔ `creategrRulesField.m`)
  and nothing enforcing they agree (45 files read `grRules`, 28 read `rules`).
- **Risk:** Parallel copies drift; bug fixes land in one and not the other; case-variant
  folders are a portability landmine.
- **Candidate feature:** *Collapse the `findMust*`/optForce and paint4net duplicates into one
  parametrized implementation each, and make `grRules` a derived view of `rules`.*

### W13 — 246 MB of committed native binaries + unpinned vendored `external/`
- **Severity:** Medium. (Constitution IX; reproducibility.)
- **Evidence:** `binary/` is a 246 MB git submodule (`glnxa64` 101 M, `maci64` 77 M, `win64`
  29 M, `win32` 18 M) of mex/exe. `external/` (62 M) is mostly **checked-in copies, not
  submodules** — only 12 of its subfolders are pinned; glpkmex, libSBML-5.19, all of
  `visualization/*`, most `utilities/*`, a 3-file RAVEN stub, mptoolbox, mCADRE have no
  upstream version.
- **Risk:** Enormous clone/checkout cost; unpinned vendored code can't be audited or updated
  reproducibly; provenance of third-party numerics is unclear.
- **Candidate feature:** *Move platform binaries to per-arch release artifacts fetched on
  demand, and pin vendored `external/` as submodules or a versioned manifest with provenance.*

### W14 — Polyglot readiness gap: the toolbox is effectively MATLAB-only
- **Severity:** Medium (High against the stated fork goal). (Constitution VIII.)
- **Evidence:** No first-party `pyproject.toml`/`Project.toml`/`setup.py` outside vendored
  `papers/`. Python exists only as MATLAB-driven bridges (`base/io/python/`, `base/cobrarrow/`
  with `requirements.txt`=`pyarrow`, `condalab`) and loose PoCs — `base/solvers/optarrow/`
  (10 `.py`, an explicit Arrow-IPC proof-of-concept, not wired into init). Julia = one file
  (`test/models/updateModels.jl`).
- **Risk:** The polyglot objective has no packaging, dependency locking, CI, or language-
  neutral contract; cross-language parity (Principle VIII) cannot be tested.
- **Candidate feature:** *Package first-party adapters (optarrow, cobrarrow, thermo group
  contribution) into versioned Python/Julia projects with declared deps + CI, and define the
  Arrow-IPC solver call as the language-neutral solver contract (depends on W1).*

### W15 — `initCobraToolbox.m` is a 992-line monolith with machine-global side effects
- **Severity:** Medium. (Constitution VII; III reproducibility.)
- **Evidence:** One ~800-line function that flips the user's **global** git config
  (`git config --global http.sslVerify false`, lines 228/758), runs `git init`/`remote add`
  on an untracked dir (185–200), initializes 16 submodules, writes `~/pathdef.m`/`savepath`
  (664–681), prepends to the system PATH, and carries `if 0` debug toggles (149/532/606).
- **Risk:** Non-pure bootstrap mutating machine-global state is hostile to CI/containers and
  hard to test; a failed run can leave global git config altered.
- **Candidate feature:** *Split bootstrap into pure, independently-testable helpers (path
  setup / solver detection / submodule sync) and stop mutating global git config.*

### W16 — `model → problem → solver` stages are decoupled with no orchestrator
- **Severity:** Medium. (Constitution IV.)
- **Evidence:** `buildOptProblemFromModel.m` (model→problem) is called by 9 disparate sites
  (`optimizeTwoCbModels.m`, `FASTCORE/fastcc.m`, `liftModel.m`, `XomicsToModel/.../constrainRxns.m`,
  …) but **never** by the `solveCobra*` dispatchers; each caller re-wires build→solve itself.
  `solveCobraLP/QP` also mutate `.origStat` with warning strings during post-solve residual
  re-checks that carry per-solver exclusions (`solveCobraLP.m:1616`, `solveCobraQP.m:1158`).
- **Risk:** Callers can compose the two stages inconsistently; the canonical status is not
  fully trustworthy because it is mutated with solver-name special-casing.
- **Candidate feature:** *Provide a single `solveCobraModel(model, problemType, params)` façade
  that composes build→solve, and move optimality verification into a separate utility that
  leaves `.origStat` immutable.*

---

## LOW

### W17 — Deprecated APIs and dead/unreachable code across core files
- **Severity:** Low. (Constitution VII-B warnings-are-defects.)
- **Evidence (`analysis/metrics/matlab-codeanalyzer.md`):** `solveCobraLP.m` — 10 unreachable
  statements + deprecated `clock`/`datestr`/`now`/`etime` in the timing path; `optimizeCbModel.m`
  — 3 unreachable + `clock`/`etime`; `XomicsToModel.m` — 12 unreachable + 6 missing-
  preallocation flags; `changeCobraSolver.m` — several unused assignments.
- **Risk:** Unreachable branches in solver dispatch and the FBA core are latent-defect markers;
  deprecated time APIs will eventually break under a MATLAB baseline bump.
- **Candidate feature:** *Modernize the timing/telemetry path (`datetime`) and remove dead
  branches under the characterization tests from W7.*

### W18 — Two divergent test harnesses; the unused one carries a latent crash
- **Severity:** Low. (Constitution III; X single-sourcing.)
- **Evidence:** `test/testAll.m` and `test/testAll_ghActions.m` are ~90% duplicated and have
  drifted; the CI-unused `testAll_ghActions.m` lacks JUnit generation and still has the
  unguarded `tracePerLine(1:(testSuitePosition - 7))` (line 222) that `testAll.m` already fixed
  with `max(idx-7,1)`.
- **Risk:** Confusion over which harness governs; the stale copy crashes if run.
- **Candidate feature:** *Delete `testAll_ghActions.m` or single-source the shared harness logic.*

### W19 — `readCbModel.m` is a per-format god-function
- **Severity:** Low. (Constitution VII; II.)
- **Evidence:** `src/base/io/readCbModel.m` (629 lines, cx 82) dispatches SBML/BiGG/XLS/JSON
  format handling inline; referenced by 27 src files (a hub).
- **Risk:** High-complexity IO hub is hard to extend for new formats (a polyglot concern) and
  hard to test per format.
- **Candidate feature:** *Split `readCbModel` into per-format strategy functions behind a thin
  dispatcher.*

---

## Recommended first `/speckit-specify` feature

**W7 + W2 combined, scoped to the LP/FBA core:** a **characterization-test harness plus a
single consolidated `mapSolverStatus` helper** for `optimizeCbModel` → `buildOptProblemFromModel`
→ `solveCobraLP`. Rationale: it is **additive** (no public-interface change — Principle
II-safe), directly closes the coverage gap on the most-depended-upon path (940 call sites),
removes the worst status-map duplication, and is the behavioral safety net that W1, W4, W5,
W6, and W16 all require before they can proceed. Everything else is higher-risk without it.
