# Quickstart: Validating the Conserved-Moiety Cross-Function Equivalence Test

## Prerequisites

- MATLAB R2024b+ with the COBRA Toolbox initialized (`initCobraToolbox`).
- No MILP solver required for the new assertions this feature adds (a MILP solver is
  only needed to also exercise the file's pre-existing full-mode assertions, gated by
  the file's own `prepareTest('needsMILP', true)`).

## Automated check (what CI runs)

```matlab
% from the repository root, after initCobraToolbox
run(fullfile('test', 'verifiedTests', 'analysis', 'testReactingMoieties', ...
    'testConservedReactingMoieties.m'));
```

Expected: the file's existing assertions pass as before (or skip cleanly via
`COBRA:RequirementsNotMet` if no MILP solver is present), and the new assertions
added by this feature pass regardless of MILP-solver availability, confirming:

1. `identifyConservedMoieties(subModel, dATM, optionsSibling)` — with
   `optionsSibling.sanityChecks = 0` — returns without error and without requiring a
   MILP solver, on the same `subModel`/`dATM` fixture already built earlier in the
   file.
2. `isequal(armConservedOnly.L, armSibling.L)` is `true`.
3. `isequal(armConservedOnly.M2M, armSibling.M2M)` is `true`.
4. `isequal(armConservedOnly.M2R, armSibling.M2R)` is `true`.
5. `isequal(moietyFormulaeConservedOnly, moietyFormulaeSibling)` is `true`.

## Manual/interactive spot-check

```matlab
optionsSibling.sanityChecks = 0;
[armSibling, moietyFormulaeSibling] = identifyConservedMoieties(subModel, dATM, optionsSibling);

isequal(armConservedOnly.L, armSibling.L)                       % should print: 1 (true)
isequal(armConservedOnly.M2M, armSibling.M2M)                   % should print: 1 (true)
isequal(armConservedOnly.M2R, armSibling.M2R)                   % should print: 1 (true)
isequal(moietyFormulaeConservedOnly, moietyFormulaeSibling)     % should print: 1 (true)
```

(`subModel`, `dATM`, `armConservedOnly`, `moietyFormulaeConservedOnly` here are
whatever `testConservedReactingMoieties.m` already built earlier in the script — see
that file for the concrete, runnable fixture setup and the feature-026 conserved-only
call this feature's assertions immediately follow.)

## Known, out-of-scope failure mode

Setting `options.sanityChecks = 1` on the conserved-only
`identifyConservedReactingMoieties` call crashes with `Error using
identifyIsomorphicClasses ... Inconsistent mapping of atoms to connected
components` — a pre-existing defect in an unrelated bond-subgraph classification
path. This quickstart, and the assertions this feature adds, deliberately keep
`sanityChecks = 0` on both compared calls to avoid it; fixing that defect is a
separate, out-of-scope change (see spec.md Edge Cases and Assumptions).

## Out of scope for this quickstart

Per the spec, this equivalence is validated only on the one existing self-contained
fixture (the 4-metabolite/3-reaction Recon3D subnetwork already used by
`testConservedReactingMoieties.m`); validating it against a larger or real
(e.g. VMH-scale) network is explicitly out of scope.
