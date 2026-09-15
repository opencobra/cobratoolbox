# Quickstart: Validating the Conserved-Moieties-Only Option

## Prerequisites

- MATLAB R2024b+ with the COBRA Toolbox initialized (`initCobraToolbox`).
- A MILP solver installed/licensed (needed only to also exercise the pre-existing full-mode
  assertions already in the test file — NOT needed for the new conserved-only assertions
  this feature adds).

## Automated check (what CI runs)

```matlab
% from the repository root, after initCobraToolbox
run(fullfile('test', 'verifiedTests', 'analysis', 'testReactingMoieties', ...
    'testConservedReactingMoieties.m'));
```

Expected: the existing assertions pass as before (or skip cleanly via
`COBRA:RequirementsNotMet` if no MILP solver is present), and the new assertions added by
this feature pass regardless of MILP-solver availability, confirming:

1. `identifyConservedReactingMoieties(subModel, BG, dATM, optionsConservedOnly)` — with
   `optionsConservedOnly.conservedMoietiesOnly = true` — returns without error and without
   requiring a MILP solver.
2. `reacting.computed == false` for that call.
3. `arm.L`, `arm.M2M`, `arm.M2R`, and `moietyFormulae` from that call are identical (within
   `tol = 1e-8`) to the corresponding values from the file's existing full-mode call.
4. `norm(full(arm.L) * N) < tol` still holds for the conserved-only run's `arm.L`.

## Manual/interactive spot-check

```matlab
options.sanityChecks = 0;
options.conservedMoietiesOnly = true;
[armConservedOnly, moietyFormulaeConservedOnly, reacting] = ...
    identifyConservedReactingMoieties(subModel, BG, dATM, options);

reacting.computed          % should print: 0 (false) — reacting-moiety analysis was skipped
isequal(armConservedOnly.L, arm.L)                 % should print: 1 (true)
isequal(moietyFormulaeConservedOnly, moietyFormulae)  % should print: 1 (true)
```

(`subModel`, `BG`, `dATM`, `arm`, `moietyFormulae` here are whatever the surrounding script
already built with the default/full-mode call — see
`testConservedReactingMoieties.m` for a concrete, runnable instance of this pattern.)

## Out of scope for this quickstart

Per the spec's resolved Clarification, validating this feature against a larger or real
(e.g. VMH-scale) network is explicitly out of scope — the automated check above, on the
existing small deterministic fixture, is the full validation surface for this feature.
