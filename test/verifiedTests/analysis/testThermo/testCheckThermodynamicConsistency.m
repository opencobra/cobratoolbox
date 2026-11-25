% The COBRAToolbox: testCheckThermodynamicConsistency.m
%
% Purpose:
%     - checkThermodynamicConsistency solves FBA, requires a thousandth of the optimal
%       biomass flux and then looks for a potential vector y with S*Q*S'*y = b and
%       lb <= Q*S'*y <= ub, returning v = S'*y and printing whether a thermodynamically
%       consistent flux producing biomass exists. The function is quarantined for the defects
%       below (the documented weighting vector q stops with an error; with gurobi every model
%       that grows stops with an error). This file only opens the test; it asserts nothing
%       about the function.
%
% Function under test:
%     src/analysis/thermo/thermoFBA/checkThermodynamicConsistency.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - FBA and one LP on a hand-built model.
%
% Coverage exemptions:
%     every line - checkThermodynamicConsistency is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The optional weighting vector q stops with an error
%       SEVERITY: error
%       TRIGGER: m = createModel({'EX_a','R1','R2','R3','R4','EX_b'}, {'','','','','',''},
%         {' -> a[c]','a[c] -> b[c]','b[c] <=> c[c]','c[c] <=> d[c]','d[c] <=> b[c]','b[c] -> '},
%         'printLevel', 0); m.lb(1) = 0; m.ub(1) = 10; m = changeObjective(m, 'EX_b');
%         checkThermodynamicConsistency(m, ones(6, 1))
%       OBSERVED: (R2025a, gurobi, 2026-11-25) error "Too many input arguments." at line 28,
%         Q=spdiag(q,0,n,n): spdiag is not a COBRA or MATLAB function; the one on the path comes
%         from a PolytopeSamplerMatlab copy (papers/ or external/) and takes one argument
%       EXPECTED: Q is the diagonal matrix of q (spdiags(q, 0, n, n)), as the help text states
%       LINES: 28
%     - DEFECT: Every model with a nonzero biomass flux makes the LP infeasible
%       SEVERITY: error
%       TRIGGER: the model above with gurobi as LP solver; checkThermodynamicConsistency(m)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) "Biomass flux, should be non-zero: 10", then
%         error "Index exceeds array bounds." at line 93: the LP of lines 62-90 has stat 0 and an
%         empty sol.full. With Q = I, S*S'*y = b = 0 forces S'*y = 0 (y'*S*S'*y = norm(S'*y)^2),
%         so the bound lb(biomass) = 0.001*FBA flux > 0 of line 46 cannot be met; under glpk
%         the same call prints "no thermodynamically consistent production of biomass" with
%         norm(v) = 0, and the message of line 97 cannot be reached for b = 0
%       EXPECTED: the infeasible LP is reported (or a feasible formulation is used) instead of
%         reading sol.full, and a model that grows can be found consistent
%       LINES: 46, 66-72, 90-93
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCheckThermodynamicConsistency'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file runs no
% solver; the call is the standard opening of a COBRA test and the place where a requirement
% (an LP solver) is added when the test is written
prepareTest();

% change the directory
cd(currentDir)
