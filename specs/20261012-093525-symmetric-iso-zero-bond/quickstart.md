# Quickstart: Exact isomorphism for near-symmetric bond components, and zero-bond RXN reading

Validation scenarios for [spec.md](spec.md). MATLAB R2024b, COBRA Toolbox initialised (`initCobraToolbox(false)`).

## 1. Unit tests

```matlab
results = runtests({'testClassifySubgraphIsomorphism', 'testReadABRXNFile', 'testBuildAtomAndBondTransitionMultigraph', 'testConservedReactingMoieties'});
assert(all([results.Passed]))
```

**Expected**: all pass; golden references unchanged; the stuck pair is one class within 5 s; randomized equivalence with `isisomorphic` holds on every generated case.

## 2. Stuck pair timing (SC-001)

Classify the stored pair three times; report the maximum time. **Expected**: ≤ 5 s each.

## 3. Classification time (SC-005)

Conserved-moiety identification on the 1,960-reaction model of feature 20260930-102230, before (develop) and after, N = 3 each; compare median classification time. **Expected**: ≤ +10%.

## 4. External check (SC-003)

In reconXmoieties, `results/ki001_strip_h/`: `SUBMODELS_MAT=... PUFA_N=514 RUNS=B matlab -batch "run('runPufaNoH.m')"` with this branch on the path. **Expected**: finishes with moiety graphs (does not finish today in 30 min). Then the full pufa subsystem (`runSubsysNoH.m`, `SUBSYS=pufa`, `CORPUS=noH`, `GRAPHS=1`): report finished, or the next blocking pair.
