% The COBRAToolbox: testRate_function1.m
%
% Purpose:
%     - Rate_function1 evaluates the reaction-rate function f(x) = FR_RF * exp(k + FR*x) of the
%     Levenberg-Marquardt kinetic solver and the transpose of its Jacobian.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/solvers/varKin/levMarMethods/Rate_function1.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Line 25 of Rate_function1.m (the error for more than two outputs) is not reached: MATLAB
%     itself rejects a call with more outputs than the function declares.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRate_function1'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons: a few exponentials and products of small numbers, so
% rounding is far below 1e-12
tol = 1e-12;

options.FR = [1 0 1 2; 0 1 1 0];
options.FR_RF = [1 1 0 1; 0 1 2 1];
options.k = [0.1; 0; -0.1; 0.2];
x = [0.3; -0.2];

%% value and Jacobian transpose (reference values computed independently from the formula)

[value, jacobianTranspose] = Rate_function1(options, x);
assert(norm(value - [4.53609637921172; 5.04427168157045]) < tol);
assert(norm(jacobianTranspose - [5.942906554626206 6.451081856984936; 0.8187307530779818 2.8187307530779817]) < tol);

%% the second output is the transpose of the Jacobian of the first (central differences)

[~, jacobianTranspose] = Rate_function1(options, x);
step = 1e-6;
numericalJacobian = zeros(2, 2);
for k = 1:2
    direction = zeros(2, 1);
    direction(k) = step;
    numericalJacobian(:, k) = (Rate_function1(options, x + direction) - Rate_function1(options, x - direction)) / (2 * step);
end
assert(norm(jacobianTranspose' - numericalJacobian, 'fro') < 1e-6);

%% a call without the point is rejected

assert(verifyCobraFunctionError('Rate_function1', 'inputs', {options}, 'testMessage', 'The number of input arguments is not valid'));

% change the directory
cd(currentDir)
