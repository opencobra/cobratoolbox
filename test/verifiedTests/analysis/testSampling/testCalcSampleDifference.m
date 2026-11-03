% The COBRAToolbox: testCalcSampleDifference.m
%
% Purpose:
%     - calcSampleDifference selects random flux vectors from two samples and returns their
%     difference and ratio.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Defect(s) fixed by feature 20261102-140321-tier1-safe-defect-fixes: Default number of
%       difference profiles does not match the documentation.
%
% Function under test:
%     src/analysis/sampling/calcSampleDifference.m
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
%     - Updated for feature 20261102-140321-tier1-safe-defect-fixes, 2026-11-02.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCalcSampleDifference'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% every column of a sample is the same vector, so the random selection of columns does not
% change the result
sample1 = repmat([1; 2; 3], 1, 4);
sample2 = repmat([2; 4; 6], 1, 5);

%% difference and ratio of the selected profiles

[sampleDiff, sampleRatio] = calcSampleDifference(sample1, sample2, 7);
assert(isequal(size(sampleDiff), [3 7]) && isequal(size(sampleRatio), [3 7]));
assert(all(all(sampleDiff == repmat([1; 2; 3], 1, 7))));
assert(all(all(sampleRatio == 2)));

%% an empty number of profiles uses the default

[sampleDiff, sampleRatio] = calcSampleDifference(sample1, sample2, []);
assert(size(sampleDiff, 1) == 3 && size(sampleRatio, 1) == 3);
assert(size(sampleDiff, 2) == size(sampleRatio, 2));

%% samples with different numbers of reactions are rejected

verifyCobraFunctionError('calcSampleDifference', 'inputs', {sample1, sample2(1:2, :)}, ...
    'testMessage', 'Samples have different numbers of rxns.');

%% without nPts the default is 25 times the number of samples in sample1 (as documented)

% sample1 has 4 samples, so 100 profiles are returned
[sampleDiff, sampleRatio] = calcSampleDifference(sample1, sample2);
assert(isequal(size(sampleDiff), [3 100]) && isequal(size(sampleRatio), [3 100]));

% change the directory
cd(currentDir)
