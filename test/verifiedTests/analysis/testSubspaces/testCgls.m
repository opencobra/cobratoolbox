% The COBRAToolbox: testCgls.m
%
% Purpose:
%     - cgls solves the (shifted) normal equations of a least-squares problem with the conjugate-
%     gradient method, using a function that applies the matrix and its transpose, and reports the
%     residual, the iteration count and a status code.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/subspaces/lsqr/cgls.m
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
fileDir = fileparts(which('testCgls'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons: the iteration converges to machine precision
tol = 1e-8;

% a small overdetermined system; the matrix is applied through a function handle
A = [1 0; 0 2; 1 1];
b = [1; 2; 3];
applyA = @(mode, x, m, n) multiply(A, mode, x);

%% least-squares solution (no shift)

[x, resNE, k, info] = cgls(applyA, 0, b, 3, 2, 50, 1e-10, 0);
assert(norm(x - A \ b) < tol);
% converged in two iterations, as many as unknowns
assert(k == 2 && info == 1 && resNE < 1e-10);

%% shifted normal equations

[x, ~, ~, info] = cgls(applyA, 0.5, b, 3, 2, 50, 1e-10, 0);
assert(norm(x - (A' * A + 0.5 * eye(2)) \ (A' * b)) < tol);
assert(info == 1);

%% iteration limit

[~, ~, k, info] = cgls(applyA, 0, b, 3, 2, 1, 1e-10, 0);
assert(k == 1 && info == 2);

%% an indefinite system

[~, ~, k, info] = cgls(applyA, -50, b, 3, 2, 50, 1e-10, 0);
assert(info == 3 && k >= 1);

%% a tolerance of 1 stops at once and is flagged as unstable

[~, ~, k, info] = cgls(applyA, 0, b, 3, 2, 50, 1, 0);
assert(k == 1 && info == 4);

%% a loose tolerance is satisfied after one step

[~, ~, k, info] = cgls(applyA, 0, b, 3, 2, 50, 0.9, 0);
assert(k == 1 && info == 1);

%% iteration log

text = evalc('cgls(applyA, 0, b, 3, 2, 50, 1e-10, 1);');
assert(contains(text, 'resNE'));
% one line for the start and one for each of the two iterations
assert(numel(strfind(text, newline)) >= 5);


function y = multiply(A, mode, x)
% Apply A (mode 1) or A' (mode 2); mode 0 only identifies the operator.
if mode == 0
    y = [];
elseif mode == 1
    y = A * x;
else
    y = A' * x;
end
end

% change the directory
cd(currentDir)
