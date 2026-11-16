% The COBRAToolbox: testLP10cvx.m
%
% Purpose:
%     - LP10cvx solves LP-10 of FASTCORE (minimise the L1 norm of the fluxes of the non-core
%       reactions P while the core reactions K carry at least epsilon) with the CVX modelling
%       package, scaled by 1e3. When K or P is empty it returns an empty vector without
%       building the problem. The test checks this early return; CVX is not installed on the
%       reference machine, so the CVX problem is not run.
%
% Function under test:
%     src/dataIntegration/transcriptomics/FASTCORE/LP10cvx.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - the documented input is a model structure (here a hand-built S, lb, ub); the
%     tested branch needs no solver.
%
% Coverage exemptions:
%     Lines 31-33, 36, 38-39, 41, 43-45, 47, 49, 51-52, 54, 56: the LP is written in the CVX
%     modelling language (cvx_begin, variable, minimize, cvx_end), and CVX is not installed and
%     not distributed with the toolbox.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLP10cvx'));
cd(fileDir);

% declare the requirements of this test. The tested branch needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% chain a -> b -> c with uptake and secretion: S is 3 x 4
model.S = sparse([1 -1 0 0; 0 1 -1 0; 0 0 1 -1]);
model.lb = zeros(4, 1);
model.ub = 10 * ones(4, 1);
epsilon = 1e-4;

%% an empty set of non-core reactions returns an empty flux vector

V = LP10cvx([1; 2], [], model, epsilon);
assert(isempty(V) && isnumeric(V));

%% an empty set of core reactions returns an empty flux vector

V = LP10cvx([], [3; 4], model, epsilon);
assert(isempty(V) && isnumeric(V));

% change the directory
cd(currentDir)
