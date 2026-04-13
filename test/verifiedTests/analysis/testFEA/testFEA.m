% The COBRAToolbox: testFEA.m
%
% Purpose:
%     - testFEA tests the Flux Enrichment Analysis
%     function
%
% Author:
%     - Marouen BEN GUEBILA 09/02/2017

global CBTDIR

% Test requirements
requiredToolboxes = {'bioinformatics_toolbox', 'statistics_toolbox'};
prepareTest('toolboxes', requiredToolboxes);

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFEA'));
cd(fileDir);

% load a model
model = getDistributedModel('ecoli_core_model.mat');

% run FEA
rxnSet = 1:10;
resultCellFtest = FEA(model, rxnSet, 'subSystems');

% --- Validate output structure ---
% Header row should be present
assert(isequal(resultCellFtest(1, :), {'P-value', 'Adjusted P-value', 'Group', 'Enriched set size', 'Total set size'}));

% Results should have rows (header + at least one enriched group)
assert(size(resultCellFtest, 1) > 1, 'FEA should return at least one enriched group');
assert(size(resultCellFtest, 2) == 5, 'FEA result should have 5 columns');

% --- Validate p-values ---
pvals = cell2mat(resultCellFtest(2:end, 1));
adjPvals = cell2mat(resultCellFtest(2:end, 2));

% P-values must be in [0, 1]
assert(all(pvals >= 0 & pvals <= 1), 'P-values must be between 0 and 1');
assert(all(adjPvals >= 0 & adjPvals <= 1), 'Adjusted p-values must be between 0 and 1');

% Adjusted p-values (BH-FDR) should be >= raw p-values
assert(all(adjPvals >= pvals - 1e-12), 'BH-adjusted p-values should be >= raw p-values');

% P-values should be sorted in ascending order
assert(all(diff(pvals) >= -1e-12), 'P-values should be in ascending order');

% --- Validate enriched set sizes ---
enrichedSizes = cell2mat(resultCellFtest(2:end, 4));
totalSizes = cell2mat(resultCellFtest(2:end, 5));

% Enriched set size should not exceed total set size
assert(all(enrichedSizes <= totalSizes), 'Enriched set size cannot exceed total set size');

% Enriched set sizes should be > 0 (zero-count subsystems are filtered out)
assert(all(enrichedSizes > 0), 'Enriched set sizes should be positive');

% --- Validate against manual hypergeometric calculation for one group ---
% Find a subsystem and verify the p-value manually
groups = model.subSystems(rxnSet);
allGroups = model.subSystems;
M = length(model.rxns);  % population size
N = length(rxnSet);       % sample size

% Pick the first result group
testGroup = resultCellFtest{2, 3};
% Count successes in sample (X)
X = sum(cellfun(@(x) any(strcmp(x, testGroup)), groups));
% Count successes in population (K)
Kpop = sum(cellfun(@(x) any(strcmp(x, testGroup)), allGroups));
% Manual upper-tail p-value: P(x >= X)
expectedPval = 1 - hygecdf(X - 1, M, Kpop, N);
assert(abs(resultCellFtest{2, 1} - expectedPval) < 1e-10, ...
    'P-value for first group does not match manual hypergeometric calculation');

% --- Error handling tests ---

% check when the groups argument is not a string
try
    resultCellFtest = FEA(1:10, model, 0);
catch ME
    assert(length(ME.message) > 0)
end

% check less than 3 input arguments
try
    resultCellFtest = FEA(model, 1:10);
catch ME
    assert(length(ME.message) > 0)
end

% check when the rxnSet is not a vector
try
    resultCellFtest = FEA(model, [1:10; 1:10], 'subSystems');
catch ME
    assert(length(ME.message) > 0)
end

% change the directory
cd(currentDir)
