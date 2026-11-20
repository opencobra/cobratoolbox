% The COBRAToolbox: testLP10cvx.m
%
% Purpose:
%     - LP10cvx solves LP-10 of FASTCORE (minimise the L1 norm of the fluxes of the non-core
%       reactions P while the core reactions K carry at least epsilon) with the CVX modelling
%       package, scaled by 1e3. When K or P is empty it returns an empty vector without
%       building the problem. The test checks this early return and, only where CVX is
%       installed, the solution of the LP on a chain of four reactions against the optimum
%       derived by hand (the chain forces equal fluxes, so the optimum is unique). CVX is not
%       installed on the reference machine, where that section is skipped with a message.
%
% Function under test:
%     src/dataIntegration/transcriptomics/FASTCORE/LP10cvx.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - the documented input is a model structure (here a hand-built S, lb, ub); the
%     early-return branch needs no solver; the LP section runs only where CVX (with the
%     solver it bundles) is installed.
%
% Coverage exemptions:
%     Lines 31-33, 36, 38-39, 41, 43-45, 47, 49, 51-52, 54, 56: the LP is written in the CVX
%     modelling language (cvx_begin, variable, minimize, cvx_end), and CVX is not installed and
%     not distributed with the toolbox (the last section reaches these lines where CVX is
%     installed).
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.
%     - Extended after the independent review (T027/T028), 2026-11-17.
%     - Help text of LP10cvx corrected to match the code (feature 20261120-151023-doc-matches-code), 2026-11-20.

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

%% the LP with CVX (only where CVX is installed): K = reaction 1, P = reactions 3 and 4

if exist('cvx_begin', 'file') == 2
    % hand-derived optimum: S*v = 0 on the chain forces v1 = v2 = v3 = v4 = t; the core
    % reaction needs t >= 1e3 * epsilon = 0.1; the objective |v3| + |v4| = 2t is smallest at
    % t = 0.1, so V = 0.1 * ones(4, 1) (unique) with objective 0.2 = 2e3 * epsilon.
    % CVX's default precision is about 1.5e-8 (relative), so 1e-6 bounds the solver error
    previousQuiet = cvx_quiet(true);
    V = LP10cvx(1, [3; 4], model, epsilon);
    cvx_quiet(previousQuiet);
    tol = 1e-6;
    assert(isequal(size(V), [4, 1]));
    assert(norm(model.S * V, inf) < tol);
    assert(V(1) >= 1e3 * epsilon - tol);
    assert(all(V >= 1e3 * model.lb - tol) && all(V <= 1e3 * model.ub + tol));
    assert(abs(sum(abs(V([3; 4]))) - 2e3 * epsilon) < tol);
    assert(max(abs(V - 0.1)) < tol);
else
    fprintf('testLP10cvx: CVX is not installed, the LP section is skipped.\n');
end

% change the directory
cd(currentDir)
