% The COBRAToolbox: testFindRxnsFromGenes.m
%
% Purpose:
%     - tests that reactions are found when providing a list of genes.
%
% Function under test:
%     src/analysis/exploration/findRxnsFromGenes.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model loaded through getDistributedModel.
%
% Coverage exemptions:
%     Line 130: unreachable, results is a 1 x 1 structure created by struct(), so isempty(results)
%       is always false (a gene without reactions gives an empty field, not an empty structure).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Calling with the optional numericFlag only stops with an error
%       SEVERITY: error
%       TRIGGER: three input arguments, for example findRxnsFromGenes(model, 'b0115', 0)
%       OBSERVED: ListResultsFlag is only given a default for fewer than three inputs, so the
%         call fails with "Not enough input arguments" where ListResultsFlag is read
%       EXPECTED: ListResultsFlag takes its documented default 0 and the call succeeds
%       LINES: 43, 122
%
% Authors:
%     - Original file: Stefania Magnusdottir August 2017
%                       Samira Ranjbar      -November 2023 (revise)
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.


global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindRxnsFromGenes'));
cd(fileDir);

% this test needs no solver, toolbox or particular operating system
prepareTest();

% load model
model = getDistributedModel('ecoli_core_model.mat');

% convert to new style model
model = convertOldStyleModel(model);

% get reactions for gene list, include gene not in model and nested cell
geneList = {'b0115'; {'b0722'; 'MadeUp'}};

[geneRxnsStruct, geneRxnsArray] = findRxnsFromGenes(model, geneList, 0, 1);

%Check warning message
warningmessage = lastwarn;
assert(strfind(warningmessage,'MadeUp')>0);
assert(isempty(strfind(warningmessage,'b0722')));
assert(isempty(strfind(warningmessage,'b0115')));


% find gene indeces of genes in model
geneInd = find(ismember(model.genes, {'b0115'; 'b0722'}));

% manually find reactions associated with gene
rxnInds = [];
for i = 1:length(geneInd)
    rxnInds = union(rxnInds, ...
        find(~cellfun(@isempty, strfind(model.rules, ['x(', num2str(geneInd(i)), ')']))));
end

% check that result array has correct size and rxns
assert(size(geneRxnsArray, 1) == length(rxnInds))
assert(size(geneRxnsArray, 2) == 6)
assert(isequal(geneRxnsArray(:, 1), model.rxns(rxnInds)))
assert(isequal(geneRxnsArray(:, 6), strcat('gene_', model.genes(geneInd))))

% check that result structure has correct size and rxns
for i = 1:length(geneInd)
    geneRxns = (geneRxnsStruct.(['gene_', model.genes{geneInd(i)}]));
    rxnInds = find(~cellfun(@isempty, strfind(model.rules, ['x(', num2str(geneInd(i)), ')'])));
    assert(size(geneRxns, 1) == length(rxnInds))
    assert(size(geneRxns, 2) == 5)
    assert(isequal(geneRxns(:, 1), model.rxns(rxnInds)))
end

%% one gene given as a string; without the list flag the list output stays empty
[geneRxnsStruct, geneRxnsArray] = findRxnsFromGenes(model, 'b0115');
assert(isfield(geneRxnsStruct, 'gene_b0115'))
assert(size(geneRxnsStruct.gene_b0115, 2) == 5)
assert(isempty(geneRxnsArray))

%% a nested cell that holds one gene is treated as that gene
geneRxnsStruct = findRxnsFromGenes(model, {{'b0115'}; 'b0722'});
assert(isempty(setxor(fieldnames(geneRxnsStruct), {'gene_b0115'; 'gene_b0722'})))

%% with a geneNames field the genes are looked up there, and dashes and points are replaced
modelWithNames = model;
modelWithNames.geneNames = modelWithNames.genes;
modelWithNames.geneNames{strcmp(model.genes, 'b0115')} = 'gene-1.5';
geneRxnsStruct = findRxnsFromGenes(modelWithNames, 'gene-1.5');
expectedRxns = findRxnsFromGenes(model, 'b0115');
assert(isequal(geneRxnsStruct.gene_gene_DASH_1_POINT_5(:, 1), expectedRxns.gene_b0115(:, 1)))

%% when no requested gene is in the model the outputs stay empty and a warning names the gene
lastwarn('');
[geneRxnsStruct, geneRxnsArray] = findRxnsFromGenes(model, {'MadeUp'});
assert(isempty(fieldnames(geneRxnsStruct)))
assert(isempty(geneRxnsArray))
assert(contains(lastwarn, 'MadeUp'))

% change the directory
cd(currentDir)
