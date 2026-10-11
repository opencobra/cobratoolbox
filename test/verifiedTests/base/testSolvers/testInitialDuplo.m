% The COBRAToolbox: testInitialDuplo.m
%
% Purpose:
%     - InitialDuplo returns the parameters of the derivative-free (Duplo) kinetic solver, taking each from the options structure when present and from a default otherwise.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/solvers/varKin/derFreeMethods/InitialDuplo.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Line 122 of InitialDuplo.m (flag_x_error = options.flag_x_error) is uncovered because of the defect below.
%
% Known defects / quirks pinned (NOT fixed here):
%     The function tests the misspelled field name "flag_`x_error`" (with backticks), so the option flag_x_error can never be set from options: the 12th output (flag_x_error) is always 0. That output is documented here and NOT tested.
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testInitialDuplo'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for numeric comparisons: the defaults are exact decimal constants, rounding only
tol = 1e-15;

% outputs in the order of the function signature (15 outputs)
fieldNames = {'MaxNumIter', 'MaxNumMapEval', 'TimeLimit', 'epsilon', 'alpha', 'beta', 'sigma', 'l', ...
              'tauBar', 'lambda_min', 'lambda_max', 'flag_x_error', 'flag_psi_error', 'flag_time', 'Stopping_Crit'};
expectedDefaults = {5000, 10000, inf, 1e-5, 1e-1, 0.5, 1, 10, 0.6, 1e-4, 1, 0, 0, 0, 5};
customValues = {11, 22, 7, 3e-3, 0.3, 0.2, 2, 3, 0.9, 1e-3, 4, [], 1, 1, 3};
% the 12th output (flag_x_error) is skipped everywhere because of the defect in the header
checkedOutputs = [1:11, 13:15];

%% defaults: an empty options structure gives the built-in values

defaults = cell(1, 15);
[defaults{1:15}] = InitialDuplo(struct());
for k = checkedOutputs
    assert(isequal(defaults{k}, expectedDefaults{k}) || abs(defaults{k} - expectedDefaults{k}) < tol, ...
        ['wrong default for ' fieldNames{k}]);
end

%% options: every field that is present in the options structure replaces its default

options = struct();
for k = checkedOutputs
    options.(fieldNames{k}) = customValues{k};
end
custom = cell(1, 15);
[custom{1:15}] = InitialDuplo(options);
for k = checkedOutputs
    assert(isequal(custom{k}, customValues{k}), ['option not used for ' fieldNames{k}]);
end

% change the directory
cd(currentDir)
