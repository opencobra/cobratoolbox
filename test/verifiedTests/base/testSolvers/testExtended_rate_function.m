% The COBRAToolbox: testExtended_rate_function.m
%
% Purpose:
%     - Extended_rate_function evaluates the extended rate mapping of the kinetic-modelling
%     Levenberg-Marquardt solver (reaction rates and conservation residuals) and, on request, its
%     Jacobian.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/solvers/varKin/levMarMethods/Extended_rate_function.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines 26-27, the error for three requested outputs: MATLAB rejects a third output because the
%     function declares only two, before the check can run.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testExtended_rate_function'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons (relative)
tol = 1e-12;

% two metabolites, two reactions
opt.FR = [1 0; 0 1];
opt.AB_BA = [1 -1; 0 1];
opt.L = [1 1];
opt.l0 = 1.5;
opt.k = [0; 0];
x = [0; log(2)];

%% mapping value

hxk = Extended_rate_function(opt, x);
f = opt.AB_BA * exp(opt.k + opt.FR' * x);
l = opt.L * exp(x) - opt.l0;
assert(norm(hxk - [f; l]) < tol * norm([f; l]));
% explicit numbers: exp(x) = (1, 2), f = (1 - 2, 2) = (-1, 2), l = 3 - 1.5
assert(norm(hxk - [-1; 2; 1.5]) < tol);

%% Jacobian

[hxk, ghxk] = Extended_rate_function(opt, x);
gf = opt.FR * diag(exp(opt.k + opt.FR' * x)) * opt.AB_BA';
gl = diag(exp(x)) * opt.L';
assert(norm(ghxk - [gf, gl], 'fro') < tol * norm([gf, gl], 'fro'));
assert(isequal(size(ghxk), [2 3]));

%% finite-difference check of the Jacobian

[~, ghxk] = Extended_rate_function(opt, x);
step = 1e-6;
numeric = zeros(3, 2);
for i = 1:2
    e = zeros(2, 1); e(i) = step;
    numeric(:, i) = (Extended_rate_function(opt, x + e) - Extended_rate_function(opt, x - e)) / (2 * step);
end
assert(norm(ghxk - numeric', 'fro') < 1e-6);

%% wrong numbers of arguments are errors

verifyCobraFunctionError('Extended_rate_function', 'inputs', {opt}, 'testMessage', 'The number of input arguments is not valid');
try
    [~, ~, ~] = Extended_rate_function(opt, x);
    error('expected an error for three outputs');
catch err
    % raised by MATLAB itself because the function declares two outputs
    assert(~contains(err.message, 'expected an error for three outputs'));
end

% change the directory
cd(currentDir)
