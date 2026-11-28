% The COBRAToolbox: testTestOptKnockSol.m
%
% Purpose:
%     - testOptKnockSol(model, targetRxn, deletions) knocks out the given reactions, maximises
%       the model objective (growth) and, when the strain is feasible, returns the minimum and
%       maximum flux of targetRxn at that growth rate (0 and 0 otherwise). The function is
%       QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): the growth
%       rate is fixed only on reactions whose objective coefficient is exactly 1, so with any
%       other coefficient the production range is computed at any growth rate; no assertion
%       about the function is made.
%
% Function under test:
%     src/design/testOptKnockSol.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - three LPs on a hand-built model; a test would declare
%     prepareTest('needsLP', true) and loop over the LP solvers (gurobi on the reference
%     machine).
%
% Coverage exemptions:
%     every line - testOptKnockSol is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The growth rate is not fixed when the objective coefficient is not 1
%       SEVERITY: wrong-result
%       TRIGGER: model = createModel({'EX_A'; 'R1'; 'R2'; 'R5'; 'EX_D'; 'BIO'; 'ATPM'; 'EX_P';
%         'EX_Q'}, {'EX_A'; 'R1'; 'R2'; 'R5'; 'EX_D'; 'BIO'; 'ATPM'; 'EX_P'; 'EX_Q'}, {'A <=> ';
%         'A -> B'; 'A -> B + P'; 'D -> P'; 'D <=> '; 'B -> '; 'B -> '; 'P <=> '; 'Q <=> '},
%         'lowerBoundList', [-10 0 0 0 -5 0 1 0 0], 'upperBoundList', 1000 * ones(1, 9));
%         model = changeObjective(model, 'BIO'); model.c(6) = 2;
%         [growthRate, minProd, maxProd] = testOptKnockSol(model, 'EX_P', {'R1'})
%       OBSERVED: (R2025a, gurobi, 2026-11-25) growthRate = 18, minProd = 1, maxProd = 15; with
%         model.c(6) = 1 the same call gives 9, 10, 15. Line 42 selects the reaction to fix
%         with modelKO.c == 1, which matches no reaction, so the growth rate is not fixed and
%         minProd is the minimum at any growth rate (1, forced by ATPM)
%       EXPECTED: minProd = 10 (with R1 knocked out the only route to biomass, R2, makes one P
%         per B, so the maximal biomass flux 9 needs EX_P >= 10), the minimum production at
%         the maximal growth rate as the help text says, for any objective coefficient
%       LINES: 41-42
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTestOptKnockSol'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined and not called, so no
% solver is needed; the call is the standard opening of a COBRA test and the place where the
% requirement (an LP solver) is added when the defect is fixed
prepareTest();

% change the directory
cd(currentDir)
