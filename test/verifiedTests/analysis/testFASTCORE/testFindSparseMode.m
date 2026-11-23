% The COBRAToolbox: testFindSparseMode.m
%
% Purpose:
%     - findSparseMode(J, P, singleton, model, LPproblem, epsilon, adaptiveScalingFlag, basis,
%       nonPen) is the inner step of FASTCORE: LP7 finds a flux vector that is active on as
%       many reactions of J (or of J(1) when singleton is true) as possible, and LP10 then
%       keeps the active reactions K of J active while minimising the flux through the
%       reactions P; the support of that flux vector is returned, or [] when no reaction of J
%       can carry a flux above epsilon. Quarantined: no behaviour of findSparseMode is asserted
%       until the defects below are fixed.
%
% Function under test:
%     src/dataIntegration/transcriptomics/FASTCORE/findSparseMode.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - solves LPs (LP7 and LP10) on a hand-built network.
%
% Coverage exemptions:
%     every line - findSparseMode is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Omitting the documented optional inputs stops with an error
%       SEVERITY: error
%       TRIGGER: chain R1 (-> A), R2 (A -> B), R3 (B ->): S = sparse([1 -1 0; 0 1 -1]);
%         model.S = S; LPproblem = struct('A', S, 'b', zeros(2, 1), 'csense', ['E'; 'E'], 'lb',
%         zeros(3, 1), 'ub', 10 * ones(3, 1)); findSparseMode([1 2], 3, false, model,
%         LPproblem, 1e-4) (also with 7 or 8 inputs)
%       OBSERVED: (R2025a, gurobi, 2026-11-23) error "Not enough input arguments." at line 43
%         with 6 inputs and at line 50 with 7 or 8 inputs: lines 43 and 50 call isempty on
%         adaptiveScalingFlag and nonPen without checking that they were passed, and the
%         defaults of epsilon (line 40) and basis (line 36) can therefore never be used
%       EXPECTED: the help text lists adaptiveScalingFlag, basis and nonPen as OPTIONAL INPUT
%         and gives epsilon a default, so the call with 6 inputs returns the support [1; 2; 3]
%         that the full call findSparseMode([1 2], 3, false, model, LPproblem, 1e-4, 0, [], [])
%         returns
%       LINES: 36, 40, 43, 50
%     - DEFECT: An empty set P returns no support although reactions of J carry flux
%       SEVERITY: wrong-result
%       TRIGGER: with model and LPproblem as above, findSparseMode([1 2], [], false, model,
%         LPproblem, 1e-4, 0, [], [])
%       OBSERVED: (R2025a, gurobi, 2026-11-23) Supp = [] (0 x 0): LP7 finds R1 and R2 active
%         (K = [1 2]), but LP10 returns [] at once for an empty P (LP10 lines 35-36) and line
%         71 takes the support of that empty vector. Through fastcore: fastcore(model, 1:3,
%         1e-4, 0) on the consistent chain R1 (-> A), R2 (A -> B), R3 (B ->) (every reaction
%         in the core, so P is empty) warns "Global network is not flux consistent, ignoring
%         the following irreversible core reactions" and lists R1, R2 and R3
%       EXPECTED: the help text says [] is returned only "if no reaction from J can get flux
%         above epsilon"; with nothing to minimise, the support of the LP7 flux vector (here
%         R1, R2, R3) is the sparse mode
%       LINES: 70-71
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindSparseMode'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so nothing calls it
% and no solver is declared; the call is the standard opening of a COBRA test and the place
% where the requirements are added when the defects are fixed
prepareTest();

% change the directory
cd(currentDir)
