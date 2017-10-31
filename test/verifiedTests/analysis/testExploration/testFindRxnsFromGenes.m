% The COBRAToolbox: testFindRxnsFromGenes.m
%
% Purpose:
%     - tests that reactions are found when providing a list of genes.
%
% Authors:
%     - Original file: Stefania Magnusdottir August 2017
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindRxnsFromGenes'));
cd(fileDir);

% load model
model = getDistributedModel('ecoli_core_model.mat');

% convert to new style model
model = convertOldStyleModel(model);

% get reactions for gene list, include gene not in model and nested cell
geneList = {'b0115'; {'b0722'; 'MadeUp'}};
[geneRxnsStruct, geneRxnsArray] = findRxnsFromGenes(model, geneList, 0, 1);

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
assert(size(geneRxnsArray, 2) == 5)
assert(isequal(geneRxnsArray(:, 1), model.rxns(rxnInds)))
assert(isequal(geneRxnsArray(:, 5), strcat('gene_', model.genes(geneInd))))

% check that result structure has correct size and rxns
for i = 1:length(geneInd)
    geneRxns = (geneRxnsStruct.(['gene_', model.genes{geneInd(i)}]));
    rxnInds = find(~cellfun(@isempty, strfind(model.rules, ['x(', num2str(geneInd(i)), ')'])));
    assert(size(geneRxns, 1) == length(rxnInds))
    assert(size(geneRxns, 2) == 4)
    assert(isequal(geneRxns(:, 1), model.rxns(rxnInds)))
end

% change the directory
cd(currentDir)
