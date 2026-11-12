% The COBRAToolbox: testCobraFminunc.m
%
% Purpose:
%     - cobraFminunc is the plain-MATLAB replacement for fminunc with Algorithm 'trust-region'
%       and a user gradient and Hessian (Optimization Toolbox), as used by BDCA and DCA (varKin).
%       Correctness is reaching the known optimum (maintainer decision 2026-11-11: same algorithm
%       class, same optimum, not the same iterates). This test checks the Rosenbrock function
%       (n = 2 and the extended form with n = 10, optimum all ones), a strictly convex quadratic
%       (optimum A\b), a start with an indefinite Hessian (negative curvature; optimum from SciPy
%       trust-exact), the legacy option names of the call sites, an already optimal start, a
%       row-vector start (shape kept), the stopping tests and display levels, the errors for
%       unsupported options, and (only where the toolbox is installed) parity with fminunc.
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraFminunc.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCobraFminunc'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

newtonOptions = struct('Algorithm', 'trust-region', 'SpecifyObjectiveGradient', true, ...
    'HessianFcn', 'objective', 'Display', 'off', 'OptimalityTolerance', 1e-10, ...
    'FunctionTolerance', 1e-14, 'StepTolerance', 1e-14);

%% Rosenbrock function from the classical start: optimum [1; 1], f = 0

rosenbrock = @(x) deal(100 * (x(2) - x(1) ^ 2) ^ 2 + (1 - x(1)) ^ 2, ...
    [-400 * x(1) * (x(2) - x(1) ^ 2) - 2 * (1 - x(1)); 200 * (x(2) - x(1) ^ 2)], ...
    [1200 * x(1) ^ 2 - 400 * x(2) + 2, -400 * x(1); -400 * x(1), 200]);
[x, fval, exitflag, output, grad, hessian] = cobraFminunc(rosenbrock, [-1.2; 1], newtonOptions);
% the optimum is exact; a gradient tolerance of 1e-10 puts x within 1e-8 of it (Hessian at the
% optimum has eigenvalues 0.4 and 1002)
assert(max(abs(x - [1; 1])) < 1e-8 && fval < 1e-16 && exitflag == 1);
% the gradient at the start has infinity norm 215.6, so the relative test stops below 2.2e-8
assert(output.firstorderopt < 2.2e-8);
assert(strcmp(output.algorithm, 'trust-region') && output.iterations > 0 && output.cgiterations > 0);
assert(isequal(size(grad), [2 1]) && isequal(size(hessian), [2 2]));

%% extended Rosenbrock function, n = 10: optimum all ones

extendedRosenbrock = @(x) extendedRosenbrockFunction(x);
[x, fval, exitflag] = cobraFminunc(extendedRosenbrock, -ones(10, 1), newtonOptions);
assert(max(abs(x - 1)) < 1e-7 && fval < 1e-14 && exitflag > 0);

%% strictly convex quadratic: the optimum A\b, a row-vector start keeps its shape

rng(20261111);
[Q, ~] = qr(randn(50));
A = Q * diag(logspace(0, 4, 50)) * Q';
A = (A + A') / 2;
b = randn(50, 1);
quadratic = @(x) deal(0.5 * x(:)' * A * x(:) - b' * x(:), A * x(:) - b, A);
[x, ~, exitflag] = cobraFminunc(quadratic, zeros(1, 50), newtonOptions);
% condition number 1e4: a relative gradient tolerance of 1e-10 gives about 1e-6 relative error in x
assert(isequal(size(x), [1 50]) && norm(x' - A \ b) / norm(A \ b) < 1e-6 && exitflag > 0);

%% indefinite Hessian at the start: negative curvature is followed to the trust-region boundary

% f = x1^4 + x1*x2 + (1 + x2)^2; at [0; 0] the Hessian [0 1; 1 2] is indefinite.
% references/g2_fit_optim.py (section fminunc), SciPy 1.16.3 trust-exact: x = [0.6958843872130828;
% -1.3479421936065414], f = -0.5824451744436351 (Hessian positive definite there)
curved = @(x) deal(x(1) ^ 4 + x(1) * x(2) + (1 + x(2)) ^ 2, [4 * x(1) ^ 3 + x(2); x(1) + 2 * (1 + x(2))], ...
    [12 * x(1) ^ 2, 1; 1, 2]);
[x, fval] = cobraFminunc(curved, [0; 0], newtonOptions);
assert(max(abs(x - [0.6958843872130828; -1.3479421936065414])) < 1e-8 && abs(fval + 0.5824451744436351) < 1e-12);

%% legacy option names of BDCA and DCA (GradObj, Hessian, TolFun, TolX)

legacyOptions = struct('Algorithm', 'trust-region', 'GradObj', 'on', 'Hessian', 'on', 'Display', 'off', 'TolFun', 1e-8, 'TolX', 1e-8);
x = cobraFminunc(rosenbrock, [-1.2; 1], legacyOptions);
assert(max(abs(x - [1; 1])) < 1e-6);
x = cobraFminunc(rosenbrock, [-1.2; 1], struct('algorithm', 'trust-region', 'gradobj', 'on', 'hessian', 'on', ...
    'display', 'off', 'MaxIter', 500, 'MaxFunEvals', 1000));
assert(max(abs(x - [1; 1])) < 1e-3);

%% already optimal start: no iteration

[x, ~, exitflag, output] = cobraFminunc(rosenbrock, [1; 1], newtonOptions);
assert(isequal(x, [1; 1]) && exitflag == 1 && output.iterations == 0);

%% stopping tests: iteration limit, evaluation limit, step and function tolerances

[~, ~, exitflag, output] = cobraFminunc(rosenbrock, [-1.2; 1], setfield(newtonOptions, 'MaxIterations', 1));
assert(exitflag == 0 && output.iterations == 1 && contains(output.message, 'iterations'));
[~, ~, exitflag, output] = cobraFminunc(rosenbrock, [-1.2; 1], setfield(newtonOptions, 'MaxFunctionEvaluations', 3));
assert(exitflag == 0 && output.funcCount == 3 && contains(output.message, 'function evaluations'));
[~, ~, exitflag] = cobraFminunc(rosenbrock, [-1.2; 1], struct('HessianFcn', 'objective', 'SpecifyObjectiveGradient', true, ...
    'Display', 'off', 'OptimalityTolerance', 0, 'FunctionTolerance', 0, 'StepTolerance', 1e-3));
assert(exitflag == 2);
[~, ~, exitflag] = cobraFminunc(rosenbrock, [-1.2; 1], struct('HessianFcn', 'objective', 'SpecifyObjectiveGradient', true, ...
    'Display', 'off', 'OptimalityTolerance', 0, 'FunctionTolerance', 1e-2, 'StepTolerance', 0));
assert(exitflag == 3);
% a trust region that shrinks below the step tolerance after a rejected step
nonsmooth = @(x) deal(abs(x(1)) + x(1) ^ 2, sign(x(1)) + 2 * x(1), 2);
[x, ~, exitflag, output] = cobraFminunc(nonsmooth, 1e-3, struct('HessianFcn', 'objective', ...
    'SpecifyObjectiveGradient', true, 'Display', 'off', 'StepTolerance', 1e-6));
assert(exitflag == 2 && abs(x) < 1e-3 && contains(output.message, 'trust region'));

%% a NaN objective at trial points rejects the step and shrinks the region

% f = (x - 0.9)^2 with a small Hessian (long Newton steps), NaN for |x| >= 1
nanOutside = @(x) deal((x - 0.9) ^ 2 + 0 / (abs(x) < 1), 2 * (x - 0.9), 0.002);
[x, ~, exitflag] = cobraFminunc(nanOutside, 0.5, struct('HessianFcn', 'objective', 'SpecifyObjectiveGradient', true, 'Display', 'off'));
% before the fix the start point was returned unchanged; with the default function tolerance
% (1e-6 relative change of f) the iterate stops within 1e-3 of the minimizer
assert(abs(x - 0.9) < 1e-3 && exitflag > 0);

%% display levels (captured with evalc to check the printed text)

printedIter = evalc('cobraFminunc(rosenbrock, [-1.2; 1], setfield(newtonOptions, ''Display'', ''iter''));');
assert(contains(printedIter, 'iteration 1,') && contains(printedIter, 'Optimization completed'));
printedFinal = evalc('cobraFminunc(rosenbrock, [-1.2; 1], rmfield(newtonOptions, ''Display''));');
assert(contains(printedFinal, 'Optimization completed') && ~contains(printedFinal, 'iteration'));
printedNotify = evalc('cobraFminunc(rosenbrock, [-1.2; 1], setfield(setfield(newtonOptions, ''Display'', ''notify''), ''MaxIterations'', 1));');
assert(contains(printedNotify, 'stopped prematurely'));

%% errors: unsupported options and algorithm

assert(verifyCobraFunctionError('cobraFminunc', 'inputs', {rosenbrock, [0; 0], struct('Algorithm', 'quasi-newton')}, ...
    'testMessage', ['cobraFminunc: unsupported option ''Algorithm'' (only ''trust-region'' with ' ...
    'SpecifyObjectiveGradient = true and HessianFcn = ''objective'' is supported).']));
assert(verifyCobraFunctionError('cobraFminunc', 'inputs', {rosenbrock, [0; 0]}, ...
    'testMessage', ['cobraFminunc: unsupported option ''Algorithm'' (only ''trust-region'' with ' ...
    'SpecifyObjectiveGradient = true and HessianFcn = ''objective'' is supported).']));
assert(verifyCobraFunctionError('cobraFminunc', 'inputs', {rosenbrock, [0; 0], struct('PlotFcn', 'optimplotx')}, ...
    'testMessage', 'cobraFminunc: unsupported option ''PlotFcn''.'));
assert(verifyCobraFunctionError('cobraFminunc', 'inputs', {rosenbrock, [0; 0], setfield(newtonOptions, 'Display', 'loud')}, ...
    'testMessage', 'cobraFminunc: unsupported option ''Display'' value ''loud''.'));
assert(verifyCobraFunctionError('cobraFminunc', 'inputs', {rosenbrock, [0; 0], {'GradObj', 'on'}}, ...
    'testMessage', 'cobraFminunc: options must be a structure (optimoptions objects are not available without the Optimization Toolbox).'));

%% parity with fminunc (only where the Optimization Toolbox is installed)

if exist('fminunc', 'file') == 2 && license('test', 'Optimization_Toolbox')
    toolboxOptions = optimoptions('fminunc', 'Algorithm', 'trust-region', 'SpecifyObjectiveGradient', true, ...
        'HessianFcn', 'objective', 'Display', 'off', 'OptimalityTolerance', 1e-10, 'StepTolerance', 1e-14, 'FunctionTolerance', 1e-14);
    xToolbox = fminunc(extendedRosenbrock, -ones(10, 1), toolboxOptions);
    x = cobraFminunc(extendedRosenbrock, -ones(10, 1), newtonOptions);
    % the same optimum (all ones), not the same iterates
    assert(max(abs(x - xToolbox)) < 1e-6);
    fprintf('parity with fminunc: passed\n');
else
    fprintf('skipped: Optimization Toolbox not installed\n');
end

% change the directory
cd(currentDir)

function [f, g, H] = extendedRosenbrockFunction(x)
% Extended Rosenbrock function sum over odd i of 100*(x(i+1) - x(i)^2)^2 + (1 - x(i))^2
n = numel(x);
f = 0;
g = zeros(n, 1);
H = zeros(n);
for i = 1:2:n - 1
    f = f + 100 * (x(i + 1) - x(i) ^ 2) ^ 2 + (1 - x(i)) ^ 2;
    g(i) = -400 * x(i) * (x(i + 1) - x(i) ^ 2) - 2 * (1 - x(i));
    g(i + 1) = 200 * (x(i + 1) - x(i) ^ 2);
    H(i, i) = 1200 * x(i) ^ 2 - 400 * x(i + 1) + 2;
    H(i, i + 1) = -400 * x(i);
    H(i + 1, i) = -400 * x(i);
    H(i + 1, i + 1) = 200;
end
end
