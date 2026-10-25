% The COBRAToolbox: testInitialBDCA.m
%
% Purpose:
%     - InitialBDCA returns the parameters of the BDCA kinetic solver, taking each from the options structure when present and from a default otherwise; the kinetic parameter "kin" is mandatory.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/solvers/varKin/BDCAmethods/InitialBDCA.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found. (The error message contains the typo "provides"; it is asserted as it is.)
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testInitialBDCA'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for numeric comparisons: the defaults are exact decimal constants, rounding only
tol = 1e-15;

% outputs in the order of the function signature:
%   MaxNumIter, MaxNumMapEval, TimeLimit, epsilon, alpha, beta, lambda_bar, rho, kin, flag_line_search, flag_x_error, flag_psi_error, flag_time, Stopping_Crit
fieldNames = {'MaxNumIter', 'MaxNumMapEval', 'TimeLimit', 'epsilon', 'alpha', 'beta', 'lambda_bar', 'rho', 'kin', 'flag_line_search', 'flag_x_error', 'flag_psi_error', 'flag_time', 'Stopping_Crit'};
expectedDefaults = {5000, 10000, inf, 1e-5, 0.4, 0.5, 50, 100, [], 'Armijo', 0, 0, 0, 5};
customValues = {11, 22, 7, 3e-3, 0.1, 0.2, 5, 6, [1; 2], 'other', 1, 1, 1, 3};

%% defaults: an empty options structure gives the built-in values

% the kinetic parameter 'kin' has no default and must be given; an empty value is used here
defaults = cell(1, 14);
[defaults{1:14}] = InitialBDCA(struct('kin', []));
for k = 1:numel(fieldNames)
    assert(isequal(defaults{k}, expectedDefaults{k}) || abs(defaults{k} - expectedDefaults{k}) < tol, ...
        ['wrong default for ' fieldNames{k}]);
end

%% options: every field that is present in the options structure replaces its default

options = struct();
for k = 1:numel(fieldNames)
    options.(fieldNames{k}) = customValues{k};
end
custom = cell(1, 14);
[custom{1:14}] = InitialBDCA(options);
for k = 1:numel(fieldNames)
    assert(isequal(custom{k}, customValues{k}), ['option not used for ' fieldNames{k}]);
end

%% the kinetic parameter is required

assert(verifyCobraFunctionError('InitialBDCA', 'inputs', {struct()}, 'testMessage', 'The kinetic parameter should be provides.'));

% change the directory
cd(currentDir)
