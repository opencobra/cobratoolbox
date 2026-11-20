% The COBRAToolbox: testRate_function.m
%
% Purpose:
%     - Rate_function evaluates the rate function f(x) = FR_RF * exp(k + FR'*x) of a kinetic
%       model (FR = [F, R], FR_RF = [F - R, R - F]) used by the DC and derivative-free kinetic
%       solvers. The test checks the value against a hand derivation for a two-metabolite,
%       two-reaction model, with and without kinetic parameters, and the error for a wrong
%       number of input arguments.
%
% Function under test:
%     src/base/solvers/varKin/BDCAmethods/Rate_function.m
%     (a second, identical Rate_function.m in src/base/solvers/varKin/derFreeMethods is shadowed
%     by this one on the MATLAB path and has no test of its own)
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Line 28 (the error for two or more outputs) is not reached: the function declares one
%     output, so MATLAB itself rejects a call with more outputs before the body runs (checked
%     below).
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRate_function'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons: four exponentials and a 2 x 4 product of numbers of
% order one, so rounding is far below 1e-12
tol = 1e-12;

% hand-built model: two metabolites, reaction 1 converts metabolite 2 into 1 and reaction 2
% converts 1 into 2, F = eye(2) and R = [0 1; 1 0]. Then FR = [1 0 0 1; 0 1 1 0] and
% FR_RF = [1 -1 -1 1; -1 1 1 -1], so for x = [a; b] and k = 0
% f(x) = [2*(exp(a) - exp(b)); -2*(exp(a) - exp(b))]
F = [1 0; 0 1];
R = [0 1; 1 0];
opt.FR = [F, R];
opt.FR_RF = [F - R, R - F];
opt.k = zeros(4, 1);

%% value at a point with k = 0, against the hand derivation

% x = [log(2); 0]: exp(a) - exp(b) = 1, so f = [2; -2]
fx = Rate_function(opt, [log(2); 0]);
assert(isequal(size(fx), [2 1]));
assert(max(abs(fx - [2; -2])) < tol);

% x = 0: all exponentials are 1, so the rates cancel exactly
assert(isequal(Rate_function(opt, [0; 0]), [0; 0]));

%% value with non-zero kinetic parameters

% k = [log(3); 0; 0; 0] and x = 0: exp(k + FR'*x) = [3; 1; 1; 1], so
% f = [3 - 1 - 1 + 1; -3 + 1 + 1 - 1] = [2; -2]
opt.k = [log(3); 0; 0; 0];
fx = Rate_function(opt, [0; 0]);
assert(max(abs(fx - [2; -2])) < tol);

% a general point, compared with the formula written out per reaction
xPoint = [0.3; -0.7];
opt.k = [0.1; -0.2; 0.4; 0.05];
expTerms = exp(opt.k + [xPoint(1); xPoint(2); xPoint(2); xPoint(1)]);
expected = [expTerms(1) - expTerms(2) - expTerms(3) + expTerms(4);
            -expTerms(1) + expTerms(2) + expTerms(3) - expTerms(4)];
assert(max(abs(Rate_function(opt, xPoint) - expected)) < tol);

%% errors: wrong number of inputs; too many outputs is rejected by MATLAB itself

assert(verifyCobraFunctionError('Rate_function', 'inputs', {opt}, ...
    'testMessage', 'The number of input arguments is not valid'));
assert(verifyCobraFunctionError('Rate_function', 'inputs', {opt, xPoint, 1}, ...
    'testMessage', 'The number of input arguments is not valid'));
% the message comes from MATLAB, not from line 28 of Rate_function
assert(verifyCobraFunctionError('Rate_function', 'inputs', {opt, xPoint}, ...
    'outputArgCount', 2, 'testMessage', 'Too many output arguments.'));

% change the directory
cd(currentDir)
