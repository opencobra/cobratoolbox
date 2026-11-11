# Quickstart: validate the remaining toolbox-free replacements

All MATLAB runs go through the memory-capped wrapper used on this machine (`matlab-safe`, at most
three sessions); elsewhere use `matlab -batch` with the same commands.

## 1. New functions pass on base MATLAB

```matlab
initCobraToolbox(false);
results = runTestSuite('testCobra(Anova1|Kruskalwallis|Ranksum|Ttest2|Kstest2|Hygecdf|Tiedrank|Ksdensity|Cmdscale|Confusionmat|FitGauss1|Fminunc|Ga|Boxplot|OptimalLeafOrder|Clustergram|Fitglm|Fitlm|GeneralizedLinearModel|LinearModel|Fitcsvm)');
```

Expected: every test passes; each parity section prints a skip line on a machine without the
toolbox and passes where it is installed (SC-002, SC-004).

## 2. Reference values are reproducible

```bash
<reference-venv>/bin/python -I specs/20261111-152503-toolbox-free-remaining/references/g1_stats.py
# likewise g2_fit_optim.py, g3_regression.py, g4_figures.py
```

Expected: the printed values equal the constants in the test files (headers state library versions).

## 3. No inventory call remains (SC-001)

```matlab
addpath('specs/20261111-152503-toolbox-free-remaining/references');
scanUnresolved(pwd, fullfile(tempdir, 'unresolved.tsv'));
```

Expected: outside `old/` and `deprecated/`, the only toolbox names left are those of the left
toolbox-gated call sites (spec Scope) and the optional `matlab` solver backend.

## 4. Tests that only needed a toolbox now run (SC-003, SC-005)

```matlab
results = runTestSuite();   % full suite, base MATLAB + Gurobi
```

Expected: exactly three skips name a toolbox (`testSampleCbModel`, `testSampleCbModelRHMC`,
`testConnectedComponents`); every other skip names a solver, web address or program; no test
of a changed call-site file newly fails.
