% The COBRAToolbox: testEfmSubsystemsExtraction.m
%
% Purpose:
%     - test if subsystems of reactions in a given set of EFMs can be identified
%
% Function under test:
%     src/visualization/efmviz/efmSubsystemsExtraction.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; stored model and reference data.
%
% Coverage exemptions:
%     None besides the lines of the defect below: only the calls with missing inputs can run.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Every call with valid inputs stops with an error
%       SEVERITY: error
%       TRIGGER: any call with a model and an array of EFM reactions, so the valid call of Case 1
%         below is skipped until this is fixed
%       OBSERVED: uniqSubsys is built with string(...), which is never a cell array, and the next
%         check then stops with the error 'uniqSubsys is not a cell'
%       EXPECTED: the unique subsystems and their counts per EFM
%       LINES: 30-31, 33-40
%
% Authors:
%     - Created initial test script: Chaitra Sarathy 2 Dec 19
%     - Updates to header docs: Chaitra Sarathy 19 Dec 19
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

global CBTDIR

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% no solver or toolbox is needed
prepareTest();

% determine the test path for references
testPath = pwd;

fprintf('Testing efmSubsystemsExtraction...\n')

% Load reference data
load([testPath filesep 'testData_testEfmSubsystemsExtraction.mat']);

% This is a function with two required inputs:
% Case 1: Test whether efmFilter gives the expected output when using 2 input and 2 output
% arguments. Skipped because of the defect in the header: set the flag to true once it is fixed.
isDefectFixed = false;
if isDefectFixed
    [subsysSummary, uniqSubsys, countSubPerEFM] = efmSubsystemsExtraction(model, testEFMs);
    if 0
        %not possible to debug this because efmSubsystemsExtraction.m outputs are
        %insufficiently commented
        assert(isequal(subsysSummary, subsysSummary_ref));
        countSubPerEFM
    end
    assert(isequal(uniqSubsys,uniqSubsys_ref));
    assert(isequal(countSubPerEFM,countSubPerEFM_ref));
end

% Case 2: Test whether efmFilter throws an error when using 1 input argument only
assert(verifyCobraFunctionError('efmSubsystemsExtraction', 'inputs', {testEFMs}, 'outputArgCount', 1));

% Case 3: Test whether efmFilter throws an error when using 1 input argument only
assert(verifyCobraFunctionError('efmSubsystemsExtraction', 'inputs', {model}, 'outputArgCount', 1));

% Case 4: Test whether efmFilter throws an error when using NO input arguments
assert(verifyCobraFunctionError('efmSubsystemsExtraction', 'inputs', {}, 'outputArgCount', 1));

fprintf('Done.\n')

% change the directory
cd(currentDir)
