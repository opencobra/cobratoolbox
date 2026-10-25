% The COBRAToolbox: testCompareXomicsModels.m
%
% Purpose:
%     - compareXomicsModels compares several models by their metabolites, reactions and genes: it
%     returns the overlap lists for every pair and for all models, the numbers of overlaps and the
%     overlaps as a percentage of the union.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/XomicsToModel/analysis/compareXomicsModels.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Line 94 of compareXomicsModels.m (the message for fewer than two models) is not tested
%     because of the defect below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Fewer than two models give no outputs
%       SEVERITY: error
%       TRIGGER: a structure with a single model, with outputs requested
%       OBSERVED: the function only prints "please check the input variable" and never assigns its
%         outputs, so the call errors (unassigned outputs)
%       EXPECTED: an empty result or a clear error message
%       LINES: 93-95
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCompareXomicsModels'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% three models described by their metabolites, reactions and genes only
models.m1 = struct('mets', {{'a'; 'b'; 'c'}}, 'rxns', {{'r1'; 'r2'}}, 'genes', {{'g1'}});
models.m2 = struct('mets', {{'b'; 'c'; 'd'}}, 'rxns', {{'r2'}}, 'genes', {{'g1'}});
models.m3 = struct('mets', {{'c'; 'e'}}, 'rxns', {{'r3'}}, 'genes', {{'g1'}});

[overlap, statistic] = compareXomicsModels(models);

%% overlap lists

assert(isequal(overlap.mets.m1.m2, {'b'; 'c'}));       % in the order of the first model
assert(isequal(overlap.mets.m2.m1, {'b'; 'c'}));
assert(isequal(overlap.mets.m1.m1, {'a'; 'b'; 'c'}));  % a model with itself
assert(isequal(overlap.rxns.m1.m2, {'r2'}) && isempty(overlap.rxns.m1.m3));
% overlap of all three models
assert(isequal(overlap.mets.alloverlap, {'c'}));
assert(isempty(overlap.rxns.alloverlap));
assert(isequal(overlap.genes.alloverlap, {'g1'}));

%% numbers of overlapping elements (rows and columns are the model names)

assert(isequal(statistic.overlapnumber_mets.Properties.RowNames', {'m1', 'm2', 'm3'}));
assert(isequal(statistic.overlapnumber_mets.Variables, [3 2 1; 2 3 1; 1 1 2]));
assert(isequal(statistic.overlapnumber_rxns.Variables, [2 1 0; 1 1 0; 0 0 1]));
assert(isequal(statistic.overlapnumber_genes.Variables, ones(3)));

%% overlap as a percentage of the union (rounded to 2 decimals)

% mets m1/m2: 2 shared of 4 in the union = 50; m1/m3: 1 of 4 = 25; m2/m3: 1 of 4 = 25; a model with itself: 100
assert(isequal(statistic.overlapproportion_mets.Variables, [100 50 25; 50 100 25; 25 25 100]));
% rxns m1/m2: 1 of 2 = 50; no shared reactions with m3: 0
assert(isequal(statistic.overlapproportion_rxns.Variables, [100 50 0; 50 100 0; 0 0 100]));
assert(isequal(statistic.overlapproportion_genes.Variables, 100 * ones(3)));

%% printing the numbers of overlaps

% captured with evalc (Constitution VII-A); the captured text uses the unique name printedText
printedText = evalc('compareXomicsModels(models, 1);');
assert(contains(printedText, 'Number of overlapping mets between models is:'));
assert(contains(printedText, 'Number of overlapping rxns between models is:'));
assert(contains(printedText, 'Number of overlapping genes between models is:'));

%% models without any element: the proportion is NaN (no division by zero)

emptyModels.m1 = struct('mets', {{'a'}}, 'rxns', {{}}, 'genes', {{}});
emptyModels.m2 = struct('mets', {{'a'}}, 'rxns', {{}}, 'genes', {{}});
[~, emptyStatistic] = compareXomicsModels(emptyModels);
emptyGeneProportions = emptyStatistic.overlapproportion_genes.Variables;
assert(all(isnan(emptyGeneProportions(:))));
assert(isequal(emptyStatistic.overlapproportion_mets.Variables, [100 100; 100 100]));

%% an invalid print flag is rejected

errorCaught = false;
try
    compareXomicsModels(models, 'yes');
catch exception
    errorCaught = strcmp(exception.message, 'printFlag should be a number or a bool');
end
assert(errorCaught);

% change the directory
cd(currentDir)
