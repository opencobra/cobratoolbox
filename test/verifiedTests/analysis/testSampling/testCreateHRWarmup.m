% The COBRAToolbox: testCreateHRWarmup.m
%
% Purpose:
%     - createHRWarmup builds the warmup points of the ACHR sampler: for each pair of points it
%       maximises and minimises one reaction (then a random objective) with solveCobraLP,
%       clips the solution to the bounds and finally moves all points towards their centre;
%       an optional bias structure first fixes the biased reactions to values drawn from a
%       uniform or normal distribution. The function is quarantined for the defect below (any
%       bias structure stops with an error). This file only opens the test; it asserts nothing
%       about the function.
%
% Function under test:
%     src/analysis/sampling/ACHR/createHRWarmup.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - one LP per warmup point on a hand-built model (createModel).
%
% Coverage exemptions:
%     every line - createHRWarmup is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Any bias structure stops with an error at the loop over the biased reactions
%       SEVERITY: error
%       TRIGGER: m = createModel({'EX_a','R1','R2','R3','R4','EX_b'}, {'','','','','',''},
%         {' -> a[c]','a[c] -> b[c]','b[c] <=> c[c]','c[c] <=> d[c]','d[c] <=> b[c]','b[c] -> '},
%         'printLevel', 0); m.lb(1) = 0; m.ub(1) = 10; m = changeObjective(m, 'EX_b');
%         bias = struct('method', 'uniform', 'index', [3 4], 'param', [100 200; 300 400]);
%         createHRWarmup(m, 12, false, bias) (the same with 'index', [3; 4] or a scalar index)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) error "Colon operands must be real scalars." at
%         line 54, "for k = 1:size(bias.index)": size returns a vector, which the colon operator
%         of R2025a rejects (older releases silently used its first element, so a row vector of
%         indices biased only the first reaction). Line 98 has the same loop. In addition, a
%         biased value below zero fixes the reaction to [0.99999999*v, 1.00000001*v], an empty
%         interval: with v = -500 gurobi reports the LP infeasible (stat 0, empty full), which
%         lines 128-151 do not handle (they clip and store the empty solution vector)
%       EXPECTED: the documented bias option fixes each of the nBias reactions to a value drawn
%         from its distribution, as the help text states
%       LINES: 54, 98, 113-114
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCreateHRWarmup'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file runs no
% solver; the call is the standard opening of a COBRA test and the place where a requirement
% (an LP solver) is added when the test is written
prepareTest();

% change the directory
cd(currentDir)
