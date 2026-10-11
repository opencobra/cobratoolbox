% The COBRAToolbox: testCalculateMetrics.m
%
% Purpose:
%     - calculateMetrics computes Bray-Curtis dissimilarities between samples, Pielou evenness per sample and a per-taxon read summary from a taxon-by-sample table.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/persephone/calculateMetrics.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Line 38 of calculateMetrics.m (the single-taxon branch computing dataSummed) is
%     not tested because of the defect below, so that line is uncovered.
%
% Known defects documented (NOT tested, NOT fixed here):
%     With a single taxon (one table row) the Bray-Curtis values are wrong:
%     sum(comparisonData) sums along the row instead of down the column, so the
%     result differs from 1 - 2*min/(a+b) (observed 0 and 1/3 where 1/2 and 2/3 are
%     expected). That input is therefore skipped here.
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCalculateMetrics'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons: sums, logs and a standard deviation of a few
% small numbers, so rounding is far below 1e-12
tol = 1e-12;

% taxon-by-sample table: first column is the taxon name, the other columns are samples
readCounts = table({'t1'; 't2'; 't3'}, [1; 2; 0], [3; 0; 4], [5; 6; 7], ...
                   'VariableNames', {'Taxon', 'S1', 'S2', 'S3'});
sampleNames = {'S1', 'S2', 'S3'};

%% Bray-Curtis dissimilarity (calculateBrayCurtis = true)

[bray, pielou, taxonSummary] = calculateMetrics(readCounts, true);

% Bray-Curtis = 1 - 2 * sum(min(a, b)) / (sum(a) + sum(b)), computed here from the counts
sampleSums = [3, 7, 18];   % total reads of S1, S2, S3
expectedS1S2 = 1 - 2 * (min(1, 3) + min(2, 0) + min(0, 4)) / (sampleSums(1) + sampleSums(2));
expectedS1S3 = 1 - 2 * (min(1, 5) + min(2, 6) + min(0, 7)) / (sampleSums(1) + sampleSums(3));
expectedS2S3 = 1 - 2 * (min(3, 5) + min(0, 6) + min(4, 7)) / (sampleSums(2) + sampleSums(3));
expectedBray = [0, expectedS1S2, expectedS1S3; expectedS1S2, 0, expectedS2S3; expectedS1S3, expectedS2S3, 0];

% the result is a table labelled by sample, symmetric, with a zero diagonal
assert(istable(bray));
assert(isequal(bray.Properties.RowNames', sampleNames));
assert(isequal(bray.Properties.VariableNames, sampleNames));
assert(norm(table2array(bray) - expectedBray, 'fro') < tol);

%% Bray-Curtis switched off: a table of zeros of the same shape

[brayOff, pielouOff] = calculateMetrics(readCounts, false);
[~, pielouOn] = calculateMetrics(readCounts, true);
assert(isequal(table2array(brayOff), zeros(3, 3)));
assert(isequal(brayOff.Properties.VariableNames, sampleNames));
% the other outputs do not depend on this switch
assert(norm(pielouOff - pielouOn) < tol);

%% Pielou evenness per sample: -sum(p .* log(p)) / log(number of taxa present)

[~, pielou] = calculateMetrics(readCounts, true);
expectedPielou = zeros(1, 3);
presentCounts = {[1; 2], [3; 4], [5; 6; 7]};   % non-zero counts of S1, S2, S3
for sampleIndex = 1:3
    proportions = presentCounts{sampleIndex} / sum(presentCounts{sampleIndex});
    expectedPielou(sampleIndex) = -sum(proportions .* log(proportions)) / log(numel(proportions));
end
assert(norm(pielou - expectedPielou) < tol);

%% per-taxon summary: mean, standard deviation, minimum, maximum, number of samples present

[~, ~, taxonSummary] = calculateMetrics(readCounts, true);
assert(isequal(taxonSummary.Properties.VariableNames, ...
               {'Mean reads', 'St. dev.', 'Min. Reads', 'Max. Reads', 'Samples with non zero value'}));
assert(isequal(taxonSummary.Properties.RowNames', {'t1', 't2', 't3'}));
perTaxonCounts = [1 3 5; 2 0 6; 0 4 7];
expectedSummary = [mean(perTaxonCounts, 2), std(perTaxonCounts, 0, 2), min(perTaxonCounts, [], 2), ...
                   max(perTaxonCounts, [], 2), sum(perTaxonCounts > 0, 2)];
assert(norm(table2array(taxonSummary) - expectedSummary, 'fro') < tol);

% change the directory
cd(currentDir)
