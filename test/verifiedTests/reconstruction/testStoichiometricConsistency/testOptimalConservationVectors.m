% The COBRAToolbox: testOptimalConservationVectors.m
%
% Purpose:
%     - optimalConservationVectors(S, lambda, delta) is meant to solve
%       min lambda*||x||_0 - delta*||y||_0 subject to x + S'*y = 0 and 0 <= y <= 1e4 with
%       optimizeCardinality. The function is QUARANTINED (Constitution III-Defects, quarantine
%       in back-fill campaigns): every call stops with an error; no assertion about the
%       function is made.
%
% Function under test:
%     src/reconstruction/modelGeneration/stoichConsistency/optimalConservationVectors.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - cardinality optimisation (LP sub-problems); a test would declare
%     prepareTest('needsLP', true) and use a hand-built 3 x 4 stoichiometric matrix.
%
% Coverage exemptions:
%     every line - optimalConservationVectors is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Every call stops with an error because delta is passed as a parameter
%       SEVERITY: error
%       TRIGGER: optimalConservationVectors(sparse([-1 0 1 -1; 1 -1 0 0; 0 1 -1 2])), and the
%         same with sparse([-1 0 1; 1 -1 0; 0 1 -1]) or any other S, lambda and delta
%       OBSERVED: (R2025a, gurobi, 2026-11-25) "param should not contain delta* field(s),
%         rather they are problem fields" from optimizeCardinality line 144: line 42 sets
%         params.delta, and optimizeCardinality rejects delta (and lambda) in its parameter
%         structure; lambda is also misspelt params.lamda (line 41), so neither weight would
%         reach the problem
%       EXPECTED: a solution structure of optimizeCardinality with lambda and delta set as
%         prob.lambda and prob.delta
%       LINES: 41-43
%     - DEFECT: The bounds of x and y are built with swapped lengths
%       SEVERITY: wrong-result
%       TRIGGER: any S with a different number of rows and columns, e.g. the 3 x 4 S above
%       OBSERVED: by reading (2026-11-25, not reachable while the first defect stands): with
%         [mlt, nlt] = size(S') (mlt reactions, nlt metabolites) line 39 builds
%         ub = [inf(nlt, 1); 1e4*ones(mlt, 1)], so for n > m reactions m+1..n of x get the
%         upper bound 1e4 and for n < m entries of y get no upper bound
%       EXPECTED: ub = [inf(mlt, 1); 1e4*ones(nlt, 1)] as the documented 0 <= y <= 1e4 and a
%         free x need (line 38 builds lb in that order)
%       LINES: 39
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOptimalConservationVectors'));
cd(fileDir);

% the function is quarantined: no requirement is declared and nothing calls it. When the
% defect is fixed, the test declares prepareTest('needsLP', true)
prepareTest();

% change the directory
cd(currentDir)
