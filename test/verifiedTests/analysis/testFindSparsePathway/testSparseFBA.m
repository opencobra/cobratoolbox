% The COBRAToolbox: testSparseFBA.m
%
% Purpose:
%     - sparseFBA finds a flux vector with the fewest active reactions among those achieving
%       the optimal FBA objective (or with no objective, osenseStr 'none'), with optional
%       coupling constraints C*v <= d, and heuristically checks which active reactions are
%       essential and whether the set is minimal. A test would check S*v = b, bounds, the
%       objective and the cardinality on small hand-built models with an LP solver. The
%       function is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns):
%       a model with the documented coupling constraints C, d together with the documented
%       checkEssentialSet = false stops with an error (defect below), so this file makes no
%       assertion about the function.
%
% Function under test:
%     src/analysis/sparseFBA/sparseFBA.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - a test would solve LPs (FBA, sparseLP) on hand-built models with an LP solver.
%
% Coverage exemptions:
%     every line - sparseFBA is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A model with coupling constraints and checkEssentialSet = false stops with an error
%       SEVERITY: error
%       TRIGGER: sparseFBA(model, 'max', false, false, 'cappedL1', 0) with model.S =
%         sparse([1 -1 0; 0 1 -1]), b = [0; 0], c = [0; 0; 1], lb = zeros(3, 1),
%         ub = 10 * ones(3, 1), csense = ['E'; 'E'], C = sparse([1 0 0]), d = 5, dsense = 'L',
%         gurobi
%       OBSERVED: (R2025a, 2026-11-23) 'Index in position 1 exceeds array bounds.' at line 535:
%         line 452 sets essentialRxnBool = [] when the essential set is not checked, and line
%         535 then indexes it with (1:nRxns, 1); the same model with checkEssentialSet = true
%         returns v = [5 5 5]
%       EXPECTED: the sparse flux vector is returned (essentialRxnBool empty, as without C)
%       LINES: 452, 535
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSparseFBA'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file needs no
% solver, MATLAB toolbox or particular operating system; the call is the standard opening of
% a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
