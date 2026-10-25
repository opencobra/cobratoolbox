% The COBRAToolbox: testCalcSampleDifference.m
%
% Purpose:
%     - calcSampleDifference selects random flux vectors from two samples and returns their
%     difference and ratio.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
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
%     - DEFECT: Default number of difference profiles does not match the documentation
%       SEVERITY: cosmetic
%       TRIGGER: calcSampleDifference called without nPts
%       OBSERVED: the number of profiles is 25 times the number of samples in the first sample set
%       EXPECTED: the header states that the default is 10% of the samples
%       LINES: 30-32
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

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

% change the directory
cd(currentDir)
