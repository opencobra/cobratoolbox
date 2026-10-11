% The COBRAToolbox: testInitialization.m
%
% Purpose:
%     - Initialization returns the parameters of the Levenberg-Marquardt kinetic solver, taking each from the options structure when present and from a default otherwise.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/solvers/varKin/levMarMethods/Initialization.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects / quirks pinned (NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testInitialization'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for numeric comparisons: the defaults are exact decimal constants, rounding only
tol = 1e-15;

% outputs in the order of the function signature:
%   eta, epsilon, MaxNumIter, MaxNumMapEval, MaxNumGmapEval, adaptive, TimeLimit, flag_x_error, flag_psi_error, flag_time, Stopping_Crit
fieldNames = {'eta', 'epsilon', 'MaxNumIter', 'MaxNumMapEval', 'MaxNumGmapEval', 'adaptive', 'TimeLimit', 'flag_x_error', 'flag_psi_error', 'flag_time', 'Stopping_Crit'};
expectedDefaults = {1, 1e-5, 500, 1000, 500, 1, inf, 0, 0, 0, 9};
customValues = {2, 3e-3, 11, 22, 33, 0, 7, 1, 1, 1, 4};

%% defaults: an empty options structure gives the built-in values

defaults = cell(1, 11);
[defaults{1:11}] = Initialization(struct());
for k = 1:numel(fieldNames)
    assert(isequal(defaults{k}, expectedDefaults{k}) || abs(defaults{k} - expectedDefaults{k}) < tol, ...
        ['wrong default for ' fieldNames{k}]);
end

%% options: every field that is present in the options structure replaces its default

options = struct();
for k = 1:numel(fieldNames)
    options.(fieldNames{k}) = customValues{k};
end
custom = cell(1, 11);
[custom{1:11}] = Initialization(options);
for k = 1:numel(fieldNames)
    assert(isequal(custom{k}, customValues{k}), ['option not used for ' fieldNames{k}]);
end

% change the directory
cd(currentDir)
