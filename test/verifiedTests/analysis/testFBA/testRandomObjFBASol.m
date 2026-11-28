% The COBRAToolbox: testRandomObjFBASol.m
%
% Purpose:
%     - randomObjFBASol bounds the objective reaction from below by a fraction of the FBA
%       optimum (or by a given value) and returns the FBA solution of a random objective
%       (coefficients uniform in [-0.5, 0.5]); it is the default initFunction of
%       optimizeCbModelNLP. Quarantined: no behaviour of randomObjFBASol is asserted until
%       the defect below is fixed.
%
% Function under test:
%     src/analysis/FBA/randomObjFBASol.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LP on a toy model.
%
% Coverage exemptions:
%     every line - randomObjFBASol is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The minimum objective is not imposed when the objective coefficient is not 1
%       SEVERITY: wrong-result
%       TRIGGER: a model whose objective coefficient is not exactly 1, e.g. the toy model EX_A
%         ( -> A, ub 10), R1 and R2 (A -> B), EX_B (B -> ) with model.c = [0; 0; 0; 2]:
%         rng(1); x0 = randomObjFBASol(model, {'max', 0.9}) repeated 20 times (the same with
%         a third entry minObjValue)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) 10 of the 20 solutions have EX_B below
%         0.9 * 10 = 9 (with model.c(4) = 1: 0 of 20); lines 32 and 34 bound only the
%         reactions with model.c == 1, so no reaction is bounded
%       EXPECTED: every returned solution reaches at least minObjFrac times the optimal
%         objective (or minObjValue), as the help text says, for any objective vector .c
%       LINES: 32, 34
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRandomObjFBASol'));
cd(fileDir);

% declare the requirements of this test; nothing that calls randomObjFBASol runs while it is
% quarantined, so no solver is required yet
prepareTest();

% change the directory
cd(currentDir)
