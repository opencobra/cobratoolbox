# COBRA Toolbox — Architecture Overview

**Scope:** read-only architectural research over `src/`, `test/`, `tutorials/`, and the
legacy/vendored surface, produced to feed later `/speckit-specify` features. Nothing in
the toolbox was modified. Every claim below is grounded in a file path plus a metric
(scc / ctags / ripgrep / MATLAB Code Analyzer); raw evidence lives under
`analysis/metrics/` and rendered diagrams under `analysis/diagrams/`.

**How to read this for Spec Kit:** each structural finding here has a matching entry in
[`WEAKNESSES.md`](WEAKNESSES.md) framed as a candidate feature. This document is the map;
that document is the prioritized backlog.

---

## 1. Size & complexity map

Measured with `scc 3.7.0` (`analysis/metrics/scc-*.txt/json`). `src/` is **1,572 MATLAB
files, ~189,354 code lines, aggregate cyclomatic complexity ~25,843**. Domain breakdown:

| Domain (`src/`) | .m files | code LOC | complexity | share of src complexity |
|---|---:|---:|---:|---:|
| `analysis/` | 604 | 79,862 | 10,239 | **40%** |
| `reconstruction/` | 316 | 43,285 | 5,232 | 20% |
| `base/` | 238 | 25,430 | 4,023 | 16% |
| `dataIntegration/` | 248 | 24,543 | 3,941 | 15% |
| `design/` | 60 | 8,414 | 1,096 | 4% |
| `visualization/` | 110 | 7,820 (16% of dir) | 1,312 | 5% |

Test suite: **260 `test*.m`** under `test/verifiedTests/` (a 1:1 mirror of the six src
domains). Tutorials are a submodule.

**Complexity hotspots** (`analysis/metrics/scc-complexity-top.txt`). The two heaviest
files are not library functions but monolithic validation scripts:

| File | code LOC | complexity | note |
|---|---:|---:|---|
| `src/analysis/wholeBody/PSCMToolbox/Test4HumanFctExtv5.m` | 6,799 | **1,044** | validation god-script (~8.5% of analysis code) |
| `src/reconstruction/modelGeneration/test4HumanFctExt.m` | 7,381 | **466** | validation god-script (~17% of reconstruction code) |
| `src/dataIntegration/XomicsToModel/XomicsToModel.m` | 1,562 | **325** | flagship omics→model builder, one function |
| `src/base/solvers/solveCobraLP.m` | 972 | **158** | LP dispatch (17-solver switch) |
| `src/base/solvers/optimizeCardinality.m` | 847 | 159 | |
| `src/dataIntegration/XomicsToModel/metabolomics/constrainRxns.m` | 919 | 156 | |
| `src/analysis/FBA/optimizeCbModel.m` | 637 | 107 | central FBA entry point |
| `src/base/solvers/solveCobraQP.m` | 838 | 85 | |

---

## 2. Layered view

The toolbox is not formally layered, but a de-facto stack exists. From the bottom:

```
initCobraToolbox.m (root)  ──sets 18 globals, genpath, submodule init, solver probe──┐
                                                                                      │
  ┌───────────────────────── CORE CONTRACTS (everything depends on) ─────────────────┤
  │  COBRA model schema            Solver abstraction (src/base/solvers, 102 files)   │
  │  S, mets, rxns, lb, ub, c, b,  changeCobraSolver · solveCobra{LP,QP,MILP,MIQP,EP} │
  │  csense, osenseStr, genes,     buildOptProblemFromModel · getCobraSolverParams    │
  │  rules/grRules, C/d, E         contract: .stat / .origStat / .full / .obj         │
  └──────────────────────────────────────────────────────────────────────────────────┘
        ▲                    ▲                    ▲                    ▲
  analysis (604)     reconstruction (316)   dataIntegration (248)  design (60) / visualization (110)
        │                    │                    │
        └──── external/ (vendored: libSBML, glpk, lusol, pdco) · binary/ (246 M mex/exe) ─────┘
```

The clean layering is violated in three places (see §6): `base` calls **up** into
`analysis`/`reconstruction`; `analysis` and `reconstruction` form a **cycle**; and
vendored third-party code lives **inside** `src/` rather than under `external/`.

### High-level architecture (Mermaid)

Rendered SVG of the actual coupling graph:
[`diagrams/module-coupling.svg`](diagrams/module-coupling.svg) (source
`diagrams/module-coupling.dot`). Mermaid source of the conceptual layering:
[`diagrams/architecture.mmd`](diagrams/architecture.mmd).

```mermaid
flowchart TB
    init["initCobraToolbox.m<br/>sets 18 globals · genpath · submodule init · solver probe"]
    subgraph CONTRACT["Core contracts"]
        schema["COBRA model schema<br/>S, lb/ub, c, b, csense, osenseStr,<br/>genes, rules/grRules, C/d, E<br/>def: base/io/definitions/COBRA_structure_fields.tab"]
        solverapi["Solver abstraction (base/solvers)<br/>changeCobraSolver · solveCobra{LP,QP,MILP,MIQP,EP}<br/>buildOptProblemFromModel · .stat/.origStat/.full/.obj"]
    end
    analysis["analysis (604)<br/>FBA · FVA · sampling · thermo · multiSpecies · wholeBody"]
    recon["reconstruction (316)<br/>refinement · verifyModel · demeter · rBioNet"]
    dataint["dataIntegration (248)<br/>XomicsToModel · GIMME/iMAT/INIT · metabolomics"]
    design["design (60)<br/>optForce · OptKnock · TrimGdel"]
    viz["visualization (110)<br/>Paint4Net · SAMMI · efmviz · maps"]
    ext["external/ vendored + binary/ (246 M) + deprecated/ (on path!)"]

    init --> CONTRACT
    schema --> solverapi
    analysis --> schema & solverapi
    recon --> schema & solverapi
    dataint --> analysis & schema
    design --> analysis
    viz --> analysis
    solverapi --> ext
    analysis <-.->|"cycle 53/36"| recon
    solverapi -.->|"base calls up (layering inversion)"| analysis

    classDef c fill:#1f77b4,color:#fff; classDef s fill:#2ca02c,color:#fff;
    class schema,solverapi c; class ext s;
```

---

## 3. The core contracts (model + solver spine)

Everything else is a client of two contracts.

### 3.1 The COBRA model schema

The canonical field list is a **tab-separated data file**,
`src/base/io/definitions/COBRA_structure_fields.tab` (82 rows), parsed by
`src/base/io/utilities/getDefinedFieldProperties.m` and mirrored for humans in
`documentation/source/guides/COBRAModelFields.rst`. Load-bearing fields (dims: m=mets,
n=rxns, g=genes, k=coupling ctrs, e=extra vars):

| Field | Meaning | Dims |
|---|---|---|
| `S` | stoichiometric matrix | m×n |
| `mets`, `rxns`, `genes` | identifiers | m×1, n×1, g×1 |
| `lb`, `ub`, `c` | flux bounds, linear objective | n×1 |
| `b`, `csense` | RHS of S·v, constraint sense {E,L,G} | m×1 |
| `osenseStr` | 'max'/'min' (numeric `osense` derived by `getObjectiveSense.m`) | scalar |
| `rules` / `grRules` | GPR in `x(1)|x(2)` form / human-readable form | n×1 |
| `C`, `d`, `dsense` | coupling constraints | k×n, k×1, k×1 |
| `E`, `evarlb/ub/c`, `D` | extra continuous variables | m×e, e×1, k×e |

Enforcement is **opt-in, not automatic**. The nearest thing to a validator is
`src/reconstruction/modelGeneration/modelVerification/verifyModel.m`, invoked only when a
caller sets `verify=true` (default is off — `getCobraSolverParams.m:98`). There is **no
accessor layer**: fields are read directly across the codebase — `model.rxns` in **286**
src files, `model.S` in **184**, `model.lb` in 137, `model.ub` in 121 (counts from
`analysis/metrics`, agent-verified). The schema is therefore extremely load-bearing and
any field change ripples through hundreds of files.

Construction/validation entry points: `createModel.m`, `convertOldStyleModel.m` (renames 9
legacy fields; converts old `A`-matrix coupling into `S`/`C`), `generateRules.m`
(grRules→rules), `creategrRulesField.m` (rules→grRules).

### 3.2 The solver abstraction spine (`src/base/solvers/`, 102 files, ~17 K LOC)

Three tiers, all wired through **globals and untyped structs** (no interface class):

1. **Configure** — `changeCobraSolver.m` (`getSetSolver/`) sets the solver-name globals
   `CBT_{LP,QP,MILP,MIQP,NLP,EP,CLP}_SOLVER` and per-type `CBT_*_PARAMS`, plus a `SOLVERS`
   registry struct. It declares **16 globals** (lines 177–192, all Code-Analyzer-flagged)
   and reads/writes them through `eval`-built names (`eval(['CBT_' problemType '_SOLVER = …'])`).
2. **Dispatch** — `solveCobra{LP,QP,MILP,MIQP}.m` (+ `entropicFBA/solveCobraEP.m`,
   `NLP/solveCobraNLP.m`) take a canonical problem struct (`.A .b .c .lb .ub .osense
   .csense`, +`.F`/`.vartype`) and `switch` to a per-solver case block. Coverage is very
   uneven: **LP supports 17 solvers, QP 10, MILP 7, MIQP 4, EP/NLP 2 each**. The LP switch
   spans `solveCobraLP.m:235–1545` (~1,300 lines) — dispatch is a monolith, not a registry.
3. **Convert** — `buildOptProblemFromModel.m` turns a model into that problem struct
   (stacks `[S,E;C,D]`, RHS `[b;d]`, senses, bounds), and derives `osense` via
   `getObjectiveSense`. It is *not* called by the dispatchers; callers must compose
   build→solve themselves (9 disparate call sites).

**Canonical status contract:** `.stat` = 1 optimal / 0 infeasible / 2 unbounded / 3
near-optimal / −1 other; `.origStat` preserves the native code. But there is **no central
status map** — native→canonical translation is duplicated per solver *and* per problem
type (e.g. gurobi is mapped independently in LP/QP/MILP/MIQP; the `dqqStatMap` table is
duplicated twice within `solveCobraLP.m` at :419 and :555; only mosek is factored into
`mosek/parseMskResult.m`). The four dispatchers can and do drift.

### 3.3 Central FBA control flow

`src/analysis/FBA/optimizeCbModel.m` (1,045 lines) is the archetypal client:

```
model ──► resolve osenseStr ──► buildOptProblemFromModel(model) ──► solveCobraLP/QP/MILP
      ◄── repartition solver result by dimension ◄──────────────────────────────────────
          v = full(1:nRxns)   y = dual(1:nMets)   w = rcost(1:nRxns)   s = slack(1:nMets)
          f = objective       stat/origStat       (raw full/dual/rcost/slack stripped)
```

It deliberately separates the *definition* vocabulary (`S,lb,ub,c`) from the *result*
vocabulary (`v,y,w,s,f`) — a good contract — but does so inside one high-complexity
function branching over 8+ `minNorm` strategies (LP/QP/MILP/sparseLP/cardinality/QRLP/QRQP).

---

## 4. Per-domain responsibilities

Full sub-package tables in `analysis/metrics/module-file-counts.txt`.

**`base/` (238)** — the foundation. `solvers/` (102, the spine above), `io/` (74:
readCbModel/writeCbModel, SBML, BiGG, KEGG, JSON, XLS), `utilities/` (23, a catch-all),
`install/` (14: updateCobraToolbox, prepareTest), `cobrarrow/` (3: `COBRArrow.m`, a 70 KB
Apache-Arrow-Flight client to a remote solver service). `readCbModel.m` is a per-format god
function (cx 82).

**`analysis/` (604, 40% of complexity)** — methods over existing models. Biggest
sub-packages: `thermo/` (132: von Bertalanffy, group contribution, thermo-FBA),
`wholeBody/` (78: Harvey/Harvetta + the PSCMToolbox god-script), `topology/` (66: conserved
moieties, extreme rays), `exploration/` (55: findRxns…, printRxnFormula, surfNet),
`multiSpecies/` (51: SteadyCom + mgPipe), `persephone/` (50: a standalone
microbiome-metabolomics stats pipeline), `sampling/` (50: CHRR/ACHR). Core entry points:
`optimizeCbModel`, `fluxVariability`/`fastFVA`, `sampleCbModel`, `sparseFBA`, `pFBA`,
`MOMA`/`ROOM`, `relaxedFBA`.

**`reconstruction/` (316)** — model construction/curation. `demeter/` (95: an embedded
AGORA reconstruction suite with its own tests/reports/SBML writer), `refinement/` (68:
createModel, addReaction, addMetabolite, removeRxns), `modelGeneration/` (49: verifyModel,
mass/charge/stoich consistency), `comparison/` (40: modelBorgifier merge GUI), `rBioNet/`
(40: interactive DB/reconstruction GUI), `fastGapFill/` (13).

**`dataIntegration/` (248)** — omics→model. `metaboAnnotator/` (72), `transcriptomics/`
(45: GIMME/iMAT/INIT/FASTCORE/rFASTCORMICS/MOOMIN), `fluxomics/` (35: 13C-MFA, with a
vendored Perl solver), `XomicsToModel/` (34: the cx-325 flagship builder + metabolomics),
`metabotools/` (30), `chemoInformatics/` (29).

**`design/` (60)** — strain design. `optForce/` (11) + a near-complete GAMS mirror
`optForceGAMS/` (10, with proprietary `.gms` files), `TrimGdel/` (13, Gurobi-only),
`optEnvelope/` (6), plus loose top-level OptKnock/optGene/GDLS/productionEnvelope.

**`visualization/` (110 .m but only 16% of the dir's LOC)** — `metabolicCartography/` (49,
flat), `cellDesigner/` (23), `SAMMIM/` (a full vendored GPL-3 JavaScript web app: 128 KB
`helpfunctions.js` + a 1.1 MB `demo.json`), duplicated `paint4net/` **and** `paint4Net/`,
`efmviz/`, `maps/` (ReconMap/MINERVA), `EscherMap/`.

---

## 5. Data & control flow (bootstrap → analysis)

```
initCobraToolbox.m (992-line monolith)
  ├─ resolve CBTDIR (which('initCobraToolbox'))
  ├─ genpath-add external/ + src/ + {tutorials,papers,binary,deprecated,test,.tmp}   ← adds deprecated/ to path
  ├─ git submodule update --init --recursive (16 submodules incl. binary 246 M, models, tutorials)
  ├─ prepend binary/<arch>/bin to system PATH (mex/exe: glpkcc, TranslateSBML, minos, lrs)
  ├─ configEnvVars → detect gurobi/cplex/mosek/tomlab paths
  ├─ probe every solver via changeCobraSolver loop → build SOLVERS status table
  └─ set 18 globals: CBTDIR, SOLVERS, OPT_PROB_TYPES, CBT_*_SOLVER, *_PATH, ENV_VARS, …

runtime call:  optimizeCbModel(model)  →  buildOptProblemFromModel  →  solveCobraLP
               (reads CBT_LP_SOLVER global)              (reads CBT_LP_PARAMS global)
               →  per-solver switch → native solve → status map → solution struct
```

The load-bearing observation: **solver selection and configuration are ambient global
state**, not parameters threaded through calls. This is the root cause behind several
weaknesses (testability, parallelism, polyglot portability).

---

## 6. Coupling & dependency graph

Method (deterministic, reproducible — `analysis/metrics/coupling-matrix.txt`): build a
function-name→domain map (one primary function per `.m` file; the six name sets are
disjoint, verified 0 overlap), extract identifier-token frequencies per caller domain, and
intersect with each callee domain's name set. Generic false positives (`compartment`,
`position`, `blocked`, …) were removed and each verified against real `name(` call counts.
The table below is **distinct callee functions referenced**; the parenthetical is the
**reference volume** (summed token frequency), which tells a second story.

| caller \ callee | analysis | base | dataInt | design | recon | viz | **out (distinct)** |
|---|---:|---:|---:|---:|---:|---:|---:|
| **analysis** | — | 49 | 15 | 0 | **51** | 4 | 119 |
| **base** | **18 ↑** | — | 2 | 0 | **10 ↑** | 1 | 31 |
| **dataIntegration** | 32 | 22 | — | 0 | 25 | 0 | 79 |
| **design** | 12 | 9 | 1 | — | 5 | 0 | 27 |
| **reconstruction** | **35** | 43 | 13 | 1 | — | 1 | 93 |
| **visualization** | 14 | 7 | 2 | 0 | 6 | — | 29 |
| **fan-in (distinct)** | **111** | **130** | 33 | 1 | **97** | 6 | |

Findings:

- **Most depended-upon depends on the metric.** By **breadth**, `base` is #1 (130 distinct
  functions consumed) — the widest foundation, as expected. By **volume**, `analysis` is #1
  (**2,354** total references vs base's 1,367), almost entirely from `reconstruction →
  analysis` (**1,672** refs — chiefly `optimizeCbModel`, `changeRxnBounds`,
  `changeObjective`). Analysis and reconstruction are de-facto shared libraries, not leaves.
- **Circular dependency `analysis ↔ reconstruction`** — the strongest cycle in the codebase
  (888 refs / 51 fns one way, 1,672 / 35 the other). Reconstruction leans on FBA
  (`optimizeCbModel` in 31 files, `printRxnFormula`, `changeRxnBounds`); analysis leans on
  reconstruction (`addReaction`/`removeRxns` in 14 files each, `addSinkReactions`,
  `verifyModel`). There is no clean acyclic split between "build a model" and "analyse a
  model".
- **Layering inversion:** `base` (the foundation) calls **up** into `analysis` (18 fns) and
  `reconstruction` (10 fns). Concretely, `src/base/solvers/optimizeTwoCbModels.m`,
  `entropicFBA/entropicFluxBalanceAnalysis.m`, and `NLP/optimizeCbModelNLP.m` call
  `optimizeCbModel`; `io/readCbModel.m`, `io/writeCbModel.m`, and
  `solvers/buildOptProblemFromModel.m` call `verifyModel`. A foundation domain should be a
  sink, not a caller of higher layers.
- **Further cycles:** `analysis ↔ dataIntegration` (58 / 348), `reconstruction ↔
  dataIntegration` (44 / 129), `analysis ↔ visualization` (11 / 67).
- **Sinks:** `design` (fan-in 1) and `visualization` (fan-in 6) are true leaves — safe to
  move/refactor without ripple.
- **God-contract functions** (distinct src files referencing each; real call sites in
  parens): `optimizeCbModel` **90 files (940 call sites)**, `printRxnFormula` 62,
  `changeRxnBounds` 57, `changeObjective` 54, `columnVector` 53, `getCobraSolverParams` 51,
  `removeRxns` 50, `solveCobraLP` 41, `addReaction` 41, `readCbModel` 27, `changeCobraSolver`
  23, `verifyModel` 22. A change to any is a repository-wide event (Principle II).

Red edges in `diagrams/module-coupling.svg` mark the cycles and the `base`-calls-up
inversion. Two independent computations (this canonical one and a main-agent cross-check
with a different metric, `analysis/metrics/coupling-corroboration.txt`) produced the same
cycles, the same inversion, and the same leaves.

---

## 7. External & legacy boundaries

- **`external/` (62 M, ~688 vendored MATLAB files + C/C++/Fortran).** Solver bindings
  (`glpkmex`, `pdco` [submodule], `lusol` [submodule], `libSBML-5.19-matlab`), samplers
  (`Volume-and-Sampling`, `PolytopeSamplerMatlab` — both submodules), graph/geometry
  (`gaimc`, `GeoCalcLib`, `Smith-Decomposition`). **Only 12 of these are git submodules**
  (`.gitmodules`); the rest — glpkmex, libSBML, all of `visualization/*`, most `utilities/*`,
  a 3-file **RAVEN stub**, mptoolbox, StoichTools, mCADRE — are unpinned checked-in copies
  with no upstream version.
- **`binary/` (246 M, git submodule `opencobra/COBRA.binary`).** Committed native mex/exe
  across `glnxa64` (101 M), `maci64` (77 M), `win64` (29 M), `win32` (18 M): `glpkcc`,
  `TranslateSBML`/`OutputSBML`, `cplexFVA*`, DQQ/quadMinos, `lrs`. Loaded by prepending
  `binary/<arch>/bin` to the system PATH.
- **`deprecated/` (51 M, 74 `.m`).** No hard call-leak from `src` (verified: zero src calls
  to deprecated-unique functions), **but** `initCobraToolbox.m:351` adds `deprecated/` to
  the runtime path, making all 74 functions globally callable and creating **2 shadow
  collisions** with live `src` functions (`changeCbMapOutput`, `testFluxConsistency`) whose
  dispatch depends on path order.
- **Vendored code *inside* `src/`** (layout violation — should be under `external/`): the
  SAMMI JS web app (~40 K LOC + 1.1 MB `demo.json`) in `visualization/SAMMIM/`, a Perl 13C
  solver in `dataIntegration/fluxomics/c13solver/*.pl`, GAMS models in
  `design/optForceGAMS/*.gms`, scratch Python + a Jupyter notebook in `base/io/python/tmp/`,
  and large `.mat`/`.mlx`/`.xls`/`.txt` data blobs.

---

## 8. Test architecture

- **Harness:** `test/testAll.m` → `test/runTestSuite.m` globs `verifiedTests/**/test*.m`
  via `rdir` and runs each as a **bare script** (not `matlab.unittest`) sequentially in one
  process, resetting globals/warnings between tests. CI (`.github/workflows/testAllCI_step1.yml`)
  runs it headless in Docker with `COBRA_CI=1`, `changeCobraSolver("gurobi","all")`, then
  converts `testReport.junit.xml` → CTRF and comments it on the PR.
- **Requirement gating:** tests should declare needs via `prepareTest`
  (`src/base/install/prepareTest.m`; keys `needsLP/QP/MILP/MIQP/NLP/EP`, `requireOneSolverOf`,
  `requiredSolvers`, `requiredToolboxes`, `needsUnix/Windows/Mac`, `needsWebAddress`). Only
  **48 of ~260 tests (~18%)** call it; the other ~82% hard-fail (not skip) when a
  solver/toolbox is absent.
- **Coverage:** `codecov.yml` exists but is **never fed** — the MoCov branch in `testAll.m`
  only fires when `MOCOV_PATH`+`JSONLAB_PATH` are set, which the CI Docker run never sets;
  CI publishes only pass/fail. Coverage is effectively unmeasured.
- **Gaps:** entire high-value subtrees have **zero tests** — `XomicsToModel` (34 files, the
  flagship builder), `metaboAnnotator` (72), `wholeBody`/`PSCMToolbox` (57);
  `buildOptProblemFromModel` and `metabolicCartography` (49) are near-untested. Since CI runs
  only gurobi and skip-counts are not a gate, cplex/mosek/tomlab-pinned tests silently erode.

---

## 9. Polyglot readiness

The fork's stated goal is polyglot (MATLAB + Python + Julia); **today it is effectively
MATLAB-only**. There is no first-party `pyproject.toml`, `Project.toml`, or `setup.py`
outside vendored `papers/`. Python appears only as (a) MATLAB-driven bridges (`pyenv`/`py.*`
in `base/io/python/`, `base/cobrarrow/` with `requirements.txt`=`pyarrow`, `condalab`), and
(b) loose scripts/PoCs — `base/solvers/optarrow/` (10 `.py`, an explicit Arrow-IPC "proof of
concept" routing LP/QP to Python HiGHS/Pyomo, not integrated into init) and thermo
group-contribution scripts. **Julia = one file** (`test/models/updateModels.jl`, a download
utility). Reaching genuine polyglot status requires packaging first-party adapters with
declared deps and CI, and — critically — replacing the global solver state (§5) with a
**language-neutral solver contract**. The `optarrow` Arrow-IPC PoC is the only prototype
pointing that direction.

---

## 10. Where this points (for Spec Kit)

The architecture is dominated by two facts: (1) the **solver abstraction is the spine**, but
it leaks (globals, monolithic dispatch, ~26 bypass sites, duplicated status maps), and (2)
the **core paths are large and under-tested**, which blocks safe refactoring. The prioritized
remediation backlog — each item framed as a candidate `/speckit-specify` feature — is in
[`WEAKNESSES.md`](WEAKNESSES.md). The recommended first feature is a **characterization-test
harness plus a single consolidated solver status-map for the core LP/FBA path**: it is
additive (no public-interface change, Principle II-safe), directly attacks the coverage gap,
and is the safety net every subsequent structural fix depends on.
