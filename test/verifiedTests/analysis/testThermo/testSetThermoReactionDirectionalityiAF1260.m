% The COBRAToolbox: testSetThermoReactionDirectionalityiAF1260.m
%
% Purpose:
%     - setThermoReactionDirectionalityiAF1260 is the E. coli iAF1260 specific second pass of
%       the assignment of reaction directions: it sets the bounds of the internal reactions
%       from the qualitative thermodynamic directions in model.directions, compares the growth
%       rate with the one of the reconstruction directions, relaxes or tightens named iAF1260
%       reactions and cofactor-driven reactions, and returns the model with the bounds
%       lb_reconThermo/ub_reconThermo and the FBA solutions. The function is quarantined for
%       the defect below (it stops with an error under gurobi once the thermodynamic bounds
%       keep at least a tenth of the growth rate). This file only opens the test; it asserts
%       nothing about the function.
%
% Function under test:
%     src/analysis/thermo/thermoDirectionality/setThermoReactionDirectionalityiAF1260.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - FBA (optimizeCbModel) on a hand-built model carrying the thermodynamic fields.
%
% Coverage exemptions:
%     every line - setThermoReactionDirectionalityiAF1260 is quarantined for the defect below
%     (feature 20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The growth check fails with an error when the LP solver reports a text status
%       SEVERITY: error
%       TRIGGER: with gurobi as LP solver, m = createModel({'EX_a','R1','R2','R3','R4','EX_b'},
%         {'','','','','',''}, {' -> a[c]','a[c] -> b[c]','b[c] <=> c[c]','c[c] <=> d[c]',
%         'd[c] <=> b[c]','b[c] -> '}, 'printLevel', 0); m.lb(1) = 0; m.ub(1) = 10;
%         m = changeObjective(m, 'EX_b'); m.directions.fwdThermoOnlyBool = false(6, 1);
%         m.directions.revThermoOnlyBool = false(6, 1);
%         m.directions.reversibleThermoOnlyBool = false(6, 1); m.SIntRxnBool = false(6, 1);
%         m.NaNdG0RxnBool = false(6, 1); setThermoReactionDirectionalityiAF1260(m)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) both growth rates are 10, then the error
%         "Operands to the logical AND (&&) and OR (||) operators must be convertible to logical
%         scalar values." at line 292: solution.origStat is the text 'OPTIMAL' under gurobi
%         (optimizeCbModel returns the solver's own status), so solution.origStat~=1 is a
%         7-element vector; under glpk origStat is the number 5, which never equals 1, so the
%         relaxation block of lines 293-514 runs even for an optimal solution
%       EXPECTED: the relaxation block runs only when the thermodynamic directions reduce the
%         growth rate below a tenth or the FBA is not optimal (test of the standardised
%         solution.stat)
%       LINES: 292
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSetThermoReactionDirectionalityiAF1260'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file runs no
% solver; the call is the standard opening of a COBRA test and the place where a requirement
% (an LP solver) is added when the test is written
prepareTest();

% change the directory
cd(currentDir)
