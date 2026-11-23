% The COBRAToolbox: testCore.m
%
% Purpose:
%     - core(model, blocked, weights, solver) solves the LP of swiftcore that finds a flux
%       distribution unblocking the reactions marked in blocked, penalising the flux of each
%       reaction with a nonzero weight by that weight. The function is quarantined for the
%       defect below: this file asserts nothing about it.
%
% Function under test:
%     src/dataIntegration/transcriptomics/SWIFTCORE/core.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - solves an LP (quarantined: no solver is used here).
%
% Coverage exemptions:
%     every line - core is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The weights of reversible and irreversible reactions are given to the wrong reactions
%       SEVERITY: wrong-result
%       TRIGGER: an irreversible weighted reaction placed before a reversible weighted one with
%         another weight; m.S = sparse([1 -1 -1]); m.rev = [0; 0; 1]; m.lb = [0; 0; -10];
%         m.ub = [10; 10; 10]; rng(0); flux = core(m, [0; 0; 0], [0; 10; 1], 'gurobi')
%       OBSERVED: (R2025a, 2026-11-23, gurobi) flux = [1 1 0]: the flux leaves through R2
%         (weight 10) instead of R3 (weight 1). Line 36 orders the penalty variables as
%         [reversible weighted; irreversible weighted], while lines 39-41 pair the i-th
%         penalty variable with the i-th weighted reaction in model order, so R2 is charged
%         the weight of R3 and R3 the weight of R2; with R2 reversible and R3 irreversible
%         (weights [0; 1; 10]) the flux correctly uses the cheaper R2
%       EXPECTED: each reaction penalised by its own weight: flux = [1 0 1] (cost 1 instead
%         of 10)
%       LINES: 36, 39-41
%     - DEFECT: An infeasible LP ends with MATLAB's unassigned-output error
%       SEVERITY: cosmetic
%       TRIGGER: m.S = speye(2); m.rev = [0; 0]; m.lb = [0; 0]; m.ub = [10; 10];
%         core(m, [0; 0], [0; 1], 'gurobi') (the core reaction 1 is forced to carry flux but
%         cannot)
%       OBSERVED: (R2025a, 2026-11-23, gurobi) the warning "Optimization was stopped with status
%         0" and then 'Output argument "flux" (and possibly others) not assigned a value'
%       EXPECTED: an error that names the cause (the LP status), or an output that marks the
%         failure
%       LINES: 71-75
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCore'));
cd(fileDir);

% core is quarantined: the standard opening only, no requirement is declared because nothing
% is solved
prepareTest();

% change the directory
cd(currentDir)
