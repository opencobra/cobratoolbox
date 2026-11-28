% The COBRAToolbox: testTestModelMassChargeBalance.m
%
% Purpose:
%     - testModelMassChargeBalance(model, excludeExchanges, biomassReaction) (DEMETER test
%       suite) calls checkMassChargeBalance and returns tables of the mass and charge
%       imbalanced reactions (with formulas and imbalances), of the metabolites involved in
%       them, and of the metabolites without formula, optionally leaving out exchange
%       reactions and the biomass reaction. Quarantined: no behaviour of
%       testModelMassChargeBalance is asserted until the defect below is fixed.
%
% Function under test:
%     src/reconstruction/demeter/suite/tests/testModelMassChargeBalance.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model look-up on a hand-built model, no solver.
%
% Coverage exemptions:
%     every line - testModelMassChargeBalance is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A model whose reactions are all mass balanced but not all charge balanced stops
%       with an error
%       SEVERITY: error
%       TRIGGER: m = struct('S', sparse([-1 0; 1 -1; 0 1]), 'rxns', {{'R1'; 'R2'}}, 'mets',
%         {{'a[c]'; 'b[c]'; 'c[c]'}}, 'metNames', {{'A'; 'B'; 'C'}}, 'metFormulas',
%         {{'C'; 'C'; 'C'}}, 'metCharges', [0; 0; 1], 'lb', [0; 0], 'ub', [1000; 1000]);
%         testModelMassChargeBalance(m) (no exchange reaction; R2 is charge imbalanced)
%       OBSERVED: (R2025a, 2026-11-25) "Conversion to double from cell is not possible." at
%         line 83; with testModelMassChargeBalance(m, false) "Mass imbalanced reactions: 1" is
%         printed (R1 is listed as mass imbalanced, line 100) and the call stops at line 113
%         with "The logical indices contain a true value outside of the array bounds."
%         checkMassChargeBalance returns imBalancedMass = [] when every reaction is mass
%         balanced, as its help documents; lines 83, 90, 100 and 113 index it as an nRxn x 1
%         cell
%       EXPECTED: massImbalancedRxns with the header row only, chargeImbalancedRxns listing
%         R2 with its formula and charge imbalance 1, imbalancedRxnMets listing b[c] and c[c]
%       LINES: 83, 90, 100, 113
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTestModelMassChargeBalance'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
