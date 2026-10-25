% The COBRAToolbox: testGetObjectiveSense.m
%
% Purpose:
%     - getObjectiveSense returns the objective sense of a model as text (min or max) and as a
%     number (1 or -1), taking osenseStr first, then osense, and defaulting to maximisation.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/exploration/getObjectiveSense.m
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
fileDir = fileparts(which('testGetObjectiveSense'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% osenseStr decides, case insensitively, and is returned unchanged

[osenseStr, osense] = getObjectiveSense(struct('osenseStr', 'MAX'));
assert(strcmp(osenseStr, 'MAX') && osense == -1);
[osenseStr, osense] = getObjectiveSense(struct('osenseStr', 'Min'));
assert(strcmp(osenseStr, 'Min') && osense == 1);

%% osenseStr wins over osense

[osenseStr, osense] = getObjectiveSense(struct('osenseStr', 'max', 'osense', 1));
assert(strcmp(osenseStr, 'max') && osense == -1);

%% an unrecognised osenseStr defaults to minimisation when there is no objective

% no objective field
[osenseStr, osense] = getObjectiveSense(struct('osenseStr', 'foo'));
assert(strcmp(osenseStr, 'min') && osense == 1);
% an all-zero objective
[osenseStr, osense] = getObjectiveSense(struct('osenseStr', 'foo', 'c', [0; 0]));
assert(strcmp(osenseStr, 'min') && osense == 1);

%% an unrecognised osenseStr with an objective is an error

verifyCobraFunctionError('getObjectiveSense', 'inputs', {struct('osenseStr', 'foo', 'c', [1; 0])}, ...
    'testMessage', 'Objective Sense must be either');

%% an empty osenseStr falls through to osense

[osenseStr, osense] = getObjectiveSense(struct('osenseStr', '', 'osense', 1));
assert(strcmp(osenseStr, 'min') && osense == 1);
[osenseStr, osense] = getObjectiveSense(struct('osense', -1));
assert(strcmp(osenseStr, 'max') && osense == -1);

%% an osense value other than 1 or -1 is an error

verifyCobraFunctionError('getObjectiveSense', 'inputs', {struct('osense', 2)}, ...
    'testMessage', 'Objective Sense must be either');

%% nothing given: maximise

[osenseStr, osense] = getObjectiveSense(struct());
assert(strcmp(osenseStr, 'max') && osense == -1);

% change the directory
cd(currentDir)
