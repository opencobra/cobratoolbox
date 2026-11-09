% The COBRAToolbox: testEfmEnrichmentAnalysis.m
%
% Purpose:
%     - script to test if any given set of EFMs are enriched with high/low expressed genes
%
% Function under test:
%     src/visualization/efmviz/efmEnrichmentAnalysis.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; stored model and EFM files.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Expression data without significance values stops with an error
%       SEVERITY: error
%       TRIGGER: exprData with the fields gene and value only, as the input description lists them
%       OBSERVED: mapExpressionToReactions does not assign its fourth output without the field
%         sig, so the call stops with 'Output argument "signifRxns" ... not assigned'
%       EXPECTED: the expression is written, without or with a default significance
%       LINES: 44
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

% set the tolerance
% tol = 1e-8;

% load the model
model = readCbModel('testModel.mat','modelName','model_irr'); %For all models which are part of this particular test.

%Load reference data
% load([testPath filesep 'testData_functionToBeTested.mat']);

efmFileName = 'testEFMs.txt';
fluxFileName = 'testFluxes.txt';

[EFMRxns_efmOnly] = efmImport([testPath filesep], efmFileName);
assert(isequal(EFMRxns_efmOnly,[1,2,3,4,5; 2,3,6,0,0]));

                                                                                                       
[EFMRxns, EFMFluxes] = efmImport([testPath filesep], efmFileName, [testPath filesep], fluxFileName);
assert(isequal(EFMRxns,[1,2,3,4,5; 2,3,6,0,0]));
assert(isequal(EFMFluxes,[1,1,1,1,1,0; 0,1,1,0,0,1]));

%% Expression data for efmEnrichmentAnalysis
nGenes = numel(model.genes);
exprData = struct();
exprData.gene = model.genes;
exprData.value = (1:nGenes)';
exprData.sig = (1:nGenes)' / (nGenes + 1);
gscFile = [tempname '.txt'];
gssFile = [tempname '.txt'];
gssFormat = {'Delimiter', ' ', 'Format', '%s%f%f'};

%% Gene set collection and gene set statistics files, with the default GPR rule mapping
efmEnrichmentAnalysis(EFMRxns, model, exprData, gscFile, gssFile);

% one line for each reaction of each EFM; the zeros that fill the second EFM are left out
gscLines = strsplit(strtrim(fileread(gscFile)), '\n')';
expectedGsc = [strcat(model.rxns(1:5), ' EFM1'); strcat(model.rxns([2; 3; 6]), ' EFM2')];
assert(isequal(strtrim(gscLines), expectedGsc));

% one row per reaction, with the mapped expression and significance; -1 is written as 0.
% Tolerance: the table is written with 15 significant digits.
tolGss = 1e-9;
[expressionMaxOr, ~, ~, significance] = mapExpressionToReactions(model, exprData, false);
expressionMaxOr(expressionMaxOr == -1) = 0;
gssTable = readtable(gssFile, gssFormat{:});
assert(isequal(gssTable{:, 1}, model.rxns));
assert(isequal(isnan(gssTable{:, 2}), isnan(expressionMaxOr)));
hasValue = ~isnan(expressionMaxOr);
assert(max(abs(gssTable{hasValue, 2} - expressionMaxOr(hasValue))) < tolGss);
assert(max(abs(gssTable{hasValue, 3} - significance(hasValue))) < tolGss);

%% The sum of OR alternatives is used when requested
efmEnrichmentAnalysis(EFMRxns, model, exprData, gscFile, gssFile, true);
expressionSumOr = mapExpressionToReactions(model, exprData, true);
expressionSumOr(expressionSumOr == -1) = 0;
gssTableSum = readtable(gssFile, gssFormat{:});
assert(max(abs(gssTableSum{hasValue, 2} - expressionSumOr(hasValue))) < tolGss);
assert(any(abs(gssTableSum{hasValue, 2} - gssTable{hasValue, 2}) > tolGss));

delete(gscFile);
delete(gssFile);

% change the directory
cd(currentDir)


