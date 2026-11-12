% The COBRAToolbox: This is a test function for calculatePercentile.m
%
% Purpose:
%     - For testing the IgemRNA preprocessing function for calculating
%     percentiles
%
% Function under test:
%     src/analysis/percentileCalc/calculatePercentile.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - expression values read from a small test file and hand-built vectors.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Kristina Grausa 05/16/2022 - created 
%     - Kristina Grausa 08/22/2022 - standard header and formatting
%     - Farid Zare 27 Feb 2024, Standard formatting and name
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

global CBTDIR

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% require the specified toolboxes and solvers, along with a UNIX OS
solvers = prepareTest('needsLP', true);

% load reference data
trData = readtable('testData_transcriptomics.xlsx','Sheet','SRR8994357_WT');
expressionValues = trData.Data;

for k = 1:length(solvers.LP)
    fprintf(' -- Running testCalculatePercentile.m using the solver interface: %s ... ', solvers.LP{k});
    
    solverLPOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);

    if solverLPOK
       value = calculatePercentile(expressionValues, k);
       assert(value == 4)
       
       % output a success message
       fprintf('Done.\n');
    end
end

%% the position locator falls exactly on a value

% (n + 1) * k / 100 is an integer: the value at that position of the sorted unique values
values = [10; 20; 30; 40; 50; 60; 70];
assert(calculatePercentile(values, 25) == 20);
assert(calculatePercentile(values, 50) == 40);
assert(calculatePercentile(values, 75) == 60);

% the order of the input and repeated values do not matter
assert(calculatePercentile([70; 10; 10; 40; 20; 30; 60; 50; 50], 50) == 40);

%% the position locator falls between two values

% position 2.4 lies 40% of the way from 20 to 30; the interpolated value is rounded to an integer
assert(calculatePercentile(values, 30) == 24);

%% a NaN percentile is returned unchanged

assert(isnan(calculatePercentile(values, NaN)));

% change the directory
cd(currentDir)
