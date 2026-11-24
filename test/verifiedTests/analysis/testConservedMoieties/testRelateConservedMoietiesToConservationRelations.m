% The COBRAToolbox: testRelateConservedMoietiesToConservationRelations.m
%
% Purpose:
%     - relateConservedMoietiesToConservationRelations(C, R) computes X with C = X*R, each row
%       X(j, :) of minimal cardinality solving R'*x = C(j, :)', by one LP per row (method 'LP1':
%       objective ones, x >= 0). The function is QUARANTINED (Constitution III-Defects,
%       quarantine in back-fill campaigns): the LP is built without osense, so solveCobraLP
%       maximises the sum of x instead of minimising it, and a row with no non-negative solution
%       stops with an error; no assertion about the function is made.
%
% Function under test:
%     src/analysis/topology/conservedMoieties/relateConservedMoietiesToConservationRelations.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - hand-built conservation relations, an LP solver (solveCobraLP).
%
% Coverage exemptions:
%     every line - relateConservedMoietiesToConservationRelations is quarantined for the defects
%     below (feature 20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The LP maximises the sum of x, so X is not of minimal cardinality
%       SEVERITY: wrong-result
%       TRIGGER: r1 = [1 0 1 0]; r2 = [0 1 0 1]; relateConservedMoietiesToConservationRelations(r1 + r2,
%         [r1; r2; r1 + r2]) (rows of R are left null vectors of N = [-1; -1; 1; 1], A + B -> C + D)
%       OBSERVED: (R2025a, gurobi, 2026-11-23) X = [1 1 0], cardinality 2: the LP has no osense
%         field, so solveCobraLP uses its default -1 (maximise) and the objective ones(n, 1)
%         maximises sum(x)
%       EXPECTED: the help text promises rows of minimal cardinality; X = [0 0 1] (cardinality 1)
%         also solves R'*x = C', and minimising sum(x) (osense = 1) returns it
%       LINES: 39-42, 54-55
%     - DEFECT: A conserved moiety that needs a negative coefficient stops with an error
%       SEVERITY: error
%       TRIGGER: r1, r2 as above; relateConservedMoietiesToConservationRelations([r1 - r2; r1], [r1; r2])
%         or relateConservedMoietiesToConservationRelations([r1; r1], [r1; -r1])
%       OBSERVED: (R2025a, gurobi, 2026-11-23) "Unable to perform assignment because the indices on
%         the left side are not compatible with the size of the right side." at line 56: x >= 0
%         (line 40) makes the LP infeasible (or, for the second call, the maximisation unbounded)
%         and the empty solution.full is assigned to X(j, :)
%       EXPECTED: the help text asks only C*N = 0 and R*N = 0 and promises C = X*R, so X = [1 -1;
%         1 0] (first call), or a documented sign restriction and a defined result when no
%         solution exists
%       LINES: 40, 56
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRelateConservedMoietiesToConservationRelations'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined and not called, so no
% solver is needed; the call is the standard opening of a COBRA test and the place where the
% requirements (an LP solver) are added when the defects are fixed
prepareTest();

% change the directory
cd(currentDir)
