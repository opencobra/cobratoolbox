% The COBRAToolbox: testFuncGradHessSub.m
%
% Purpose:
%     - FuncGradHessSub returns the value, the gradient and the Hessian of the sub-problem objective
%     of the BDCA kinetic solver at x for a fixed y.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/solvers/varKin/BDCAmethods/FuncGradHessSub.m
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
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFuncGradHessSub'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% small example: 2 equations (rows of F and R), 3 reactions (columns), so 6 columns in [F, R]
F = [1 0 1; 0 1 1];
R = [0 1 0; 1 0 0];
kin = zeros(6, 1);
rho = 0.5;
x = [0.1; -0.2];
y = [0.05; 0.1];

% The gradient and Hessian are verified against central finite differences of the value and
% of the gradient. With step h = 1e-6 the truncation error is O(h^2) and the rounding error is
% about 1e-10, so 1e-6 is a safe tolerance.
step = 1e-6;
tol = 1e-6;

%% value, gradient and Hessian

[value, gradient, hessian] = FuncGradHessSub(x, y, F, R, kin, rho);
assert(isscalar(value) && isequal(size(gradient), [2 1]) && isequal(size(hessian), [2 2]));

%% the gradient is the derivative of the value with respect to x

[~, gradient] = FuncGradHessSub(x, y, F, R, kin, rho);
numericalGradient = zeros(2, 1);
for k = 1:2
    direction = zeros(2, 1);
    direction(k) = step;
    numericalGradient(k) = (FuncGradHessSub(x + direction, y, F, R, kin, rho) - ...
                            FuncGradHessSub(x - direction, y, F, R, kin, rho)) / (2 * step);
end
assert(norm(gradient - numericalGradient) < tol);

%% the Hessian is the derivative of the gradient, and is symmetric and positive definite

[~, ~, hessian] = FuncGradHessSub(x, y, F, R, kin, rho);
numericalHessian = zeros(2, 2);
for k = 1:2
    direction = zeros(2, 1);
    direction(k) = step;
    [~, gradientPlus] = FuncGradHessSub(x + direction, y, F, R, kin, rho);
    [~, gradientMinus] = FuncGradHessSub(x - direction, y, F, R, kin, rho);
    numericalHessian(:, k) = (gradientPlus - gradientMinus) / (2 * step);
end
assert(norm(hessian - numericalHessian, 'fro') < tol);
assert(norm(hessian - hessian', 'fro') < 1e-10);
assert(all(eig(hessian) > 0));     % rho * identity is added, so the Hessian is positive definite

% change the directory
cd(currentDir)
