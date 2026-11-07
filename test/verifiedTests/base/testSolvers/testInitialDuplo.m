% The COBRAToolbox: testInitialDuplo.m
%
% Purpose:
%     - InitialDuplo returns the parameters of the derivative-free (Duplo) kinetic solver, taking each from the options structure when present and from a default otherwise.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%       Defect(s) fixed by feature 20261102-140321-tier1-safe-defect-fixes: Option flag_x_error
%       can never be set.
%
% Function under test:
%     src/base/solvers/varKin/derFreeMethods/InitialDuplo.m
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
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.
%     - Updated for feature 20261102-140321-tier1-safe-defect-fixes, 2026-11-02.

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
customValues = {11, 22, 7, 3e-3, 0.3, 0.2, 2, 3, 0.9, 1e-3, 4, 1, 1, 1, 3};
checkedOutputs = 1:15;

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

%% flag_x_error: the given value is returned, the other outputs keep their defaults

outputs = cell(1, 15);
[outputs{1:15}] = InitialDuplo(struct('flag_x_error', 1));
assert(outputs{12} == 1);
for k = [1:11, 13:15]
    assert(isequal(outputs{k}, defaults{k}), ['default changed for ' fieldNames{k}]);
end

% change the directory
cd(currentDir)
