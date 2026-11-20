% The COBRAToolbox: testCalcSampleStats.m
%
% Purpose:
%     - calcSampleStats returns, for each variable (row) of a sample matrix (variables x
%       sample points), the mean, standard deviation (n - 1 normalisation), mode, median,
%       skewness and kurtosis (both biased, as skewness(x) and kurtosis(x)); a cell array of
%       samples gives one column per sample. The test uses two hand-built samples whose
%       statistics are computed by hand below (central moments m2, m3, m4 of each row).
%
% Function under test:
%     src/analysis/sampling/calcSampleStats.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCalcSampleStats'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% hand calculation, first sample (2 variables x 4 points):
%   row [1 2 2 3]: mean 2, deviations (-1 0 0 1): m2 = 2/4, m3 = 0, m4 = 2/4,
%     std = sqrt(2/3), mode 2, median 2, skewness 0, kurtosis m4/m2^2 = 2
%   row [4 4 5 9]: mean 5.5, deviations (-1.5 -1.5 -0.5 3.5): sum of squares 17,
%     sum of cubes 36, sum of fourth powers 160.25; std = sqrt(17/3), mode 4,
%     median 4.5, skewness (36/4)/(17/4)^1.5, kurtosis (160.25/4)/(17/4)^2
sampleA = [1 2 2 3; 4 4 5 9];
expectedA.mean = [2; 5.5];
expectedA.std = [sqrt(2 / 3); sqrt(17 / 3)];
expectedA.mode = [2; 4];
expectedA.median = [2; 4.5];
expectedA.skew = [0; (36 / 4) / (17 / 4)^1.5];
expectedA.kurt = [2; (160.25 / 4) / (17 / 4)^2];
% second sample: row [0 0 1 7]: mean 2, deviations (-2 -2 -1 5): sums 34, 108, 658;
%   row [1 2 3 4]: mean 2.5, deviations (-1.5 -0.5 0.5 1.5): sums 5, 0, 10.25
sampleB = [0 0 1 7; 1 2 3 4];
expectedB.mean = [2; 2.5];
expectedB.std = [sqrt(34 / 3); sqrt(5 / 3)];
expectedB.mode = [0; 1];
expectedB.median = [0.5; 2.5];
expectedB.skew = [(108 / 4) / (34 / 4)^1.5; 0];
expectedB.kurt = [(658 / 4) / (34 / 4)^2; (10.25 / 4) / (5 / 4)^2];

% the values are computed in double precision from small integers; 1e-12 leaves room for
% rounding in the moment sums and powers
tol = 1e-12;
statNames = {'mean', 'std', 'mode', 'median', 'skew', 'kurt'};

%% one sample matrix: one column of statistics per variable set

sampleStats = calcSampleStats(sampleA);
assert(isequal(sort(fieldnames(sampleStats)), sort(statNames')));
for k = 1:numel(statNames)
    value = sampleStats.(statNames{k});
    assert(isequal(size(value), [2 1]));
    assert(max(abs(value - expectedA.(statNames{k}))) < tol);
end

%% a cell array of samples: one column per sample, in the given order

sampleStats = calcSampleStats({sampleA, sampleB});
for k = 1:numel(statNames)
    value = sampleStats.(statNames{k});
    assert(isequal(size(value), [2 2]));
    assert(max(abs(value(:, 1) - expectedA.(statNames{k}))) < tol);
    assert(max(abs(value(:, 2) - expectedB.(statNames{k}))) < tol);
end

% change the directory
cd(currentDir)
