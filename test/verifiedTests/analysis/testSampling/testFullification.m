% The COBRAToolbox: testFullification.m
%
% Purpose:
%     - fullification converts a polytope in equality form with bounds into the full-dimensional
%     inequality form obtained by moving to the null space of the equality constraints, and returns
%     the affine map back to the original space.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/sampling/BarrierRound/fullification.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFullification'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons
tol = 1e-12;

% polytope: x1 + x2 + x3 = 1 with 0 <= x <= 1 and the interior point (1/3, 1/3, 1/3)
o.P.A = [1 1 1];
o.P.lb = [0; 0; 0];
o.P.ub = [1; 1; 1];
o.P.x = [1; 1; 1] / 3;
o.T.scale = [2; 2; 2];
o.T.x0 = [0.5; 0.5; 0.5];
o.T.idx = [1; 2; 3];

%% null-space form

fullP = fullification(o);
N = null(o.P.A);
% the null-space basis may differ in sign between releases, so compare up to its sign
assert(isequal(size(fullP.A), [6 2]));
A = fullP.A(1:3, :);
assert(norm(o.P.A * A, 'fro') < tol);
assert(norm(fullP.A(4:6, :) + A, 'fro') < tol);
assert(abs(norm(A(:, 1)) - 1) < tol && abs(norm(A(:, 2)) - 1) < tol && abs(A(:, 1)' * A(:, 2)) < tol);
assert(norm(A * A' - N * N', 'fro') < tol);

%% right-hand side, interior point and map back to the original space

fullP = fullification(o);
A = fullP.A(1:3, :);
assert(norm(fullP.b - [1 - 1/3 * ones(3, 1); 1/3 * ones(3, 1)]) < tol);
assert(isequal(fullP.x, zeros(2, 1)));
% the map back is x0(idx) + scale .* samples, with the scaled null space and shift
assert(norm(fullP.N - o.T.scale .* A) < tol || norm(fullP.N + o.T.scale .* A) < tol);
assert(norm(fullP.p_shift - [2; 2; 2] / 3) < tol);
assert(isequal(fullP.x0, o.T.x0) && isequal(fullP.idx, o.T.idx));

% change the directory
cd(currentDir)
