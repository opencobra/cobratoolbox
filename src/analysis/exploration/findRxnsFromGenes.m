function [results, ListResults] = findRxnsFromGenes(model, genes, numericFlag, ListResultsFlag)
% Print every reaction associated with a gene of interest
%
% USAGE:
%
%    [results, ListResults] = findRxnsFromGenes(model, genes, numericFlag, ListResultsFlag)
%
% INPUTS:
%    model:              COBRA model structure
%    genes:              string of single gene or cell array of multiple
%                        genes for which `rxns` are desired.
%
% OPTIONAL INPUTS:
%    numericFlag:        1 if using Human Recon  (Default = 0)
%    ListResultsFlag:    1 if you want to output `ListResults` (Default = 0)
%
% OUTPUTS:
%    results:            structure containing cell arrays for each gene.
%                        Each cell array has one column of rxn abbreviations
%                        and one column containing the reaction formula
%    ListResults:        same as above, but in a cell array
%
% .. Author:
%       - Nathan Lewis 02/16/08
%       - edited 04/05/09 (MUCH faster now -- NL)
%       - edited 06/11/10 (yet even faster now -- NL)
%       - Ronan, Ines - edited interface for backward compatibility

if nargin==4
   warning('3rd argument is numericFlag, currently redundant, will be depreciated')
end

if nargin< 3
    numericFlag = 0;
    ListResultsFlag = 0;
end

if ~iscell(genes)
    genes = {genes};
else %check if any nested cells in array
    addGenes = {}; %fill if nested cells in array
    for i = 1:length(genes)
        if iscell(genes{i})
            if length(genes{i}) == 1
                genes(i) = genes{i};
            else %more than one gene listed in nested cell
                addGenes = union(addGenes, genes{i});
                delGenes = i;
            end
        end
    end
    if ~isempty(addGenes)
        genes(delGenes) = []; %delete nested cell
        genes = union(genes, addGenes); %add genes from nested cell to list
    end
end

if isfield(model, 'geneNames')
    model.geneNames = regexprep(model.geneNames,'-','_DASH_');
    model.geneNames = regexprep(model.geneNames,'\.','_POINT_');
else %to stay compatible with old style models
    model.geneNames = regexprep(model.genes,'-','_DASH_');
    model.geneNames = regexprep(model.geneNames,'\.','_POINT_');
end
genes = regexprep(genes,'-','_DASH_');
genes = regexprep(genes,'\.','_POINT_');

% find where the genes are located in the geneNames
GeneID = zeros(size(genes));
[~, geneIndModel, inModel] = intersect(model.geneNames, genes);
GeneID(inModel) = geneIndModel;%set location of genes in model

results = struct();
ListResults = {};
if any(GeneID == 0)
    notpresent = GeneID == 0;
    missingGenes = strjoin(genes(notpresent),',\n');
    warning('The following gene(s) were not fond in the model:\n%s',missingGenes)
    if any(GeneID > 0)
        Ind = find(GeneID == 0);
        GeneID(Ind) = [];
        genes(Ind) = [];
    else
        return
    end
end

for i = 1:length(GeneID)
    %Ensures that geneids can become field names for structures
    tempGene = regexprep(genes{i}, '[^a-zA-Z0-9_]', '_');
    
    %If gene starts with a digit it cannot be a field name, prepend gene_ to correct
    tempGene = cat(2, 'gene_', tempGene);
    
    %Reaction locations in model using rules field
    Ind_rxns = find(~cellfun(@isempty, strfind(model.rules, ...
        ['x(', num2str(GeneID(i)), ')'])));
    
    %Create gene field in results structure
    results.(tempGene) = cell(length(Ind_rxns), 4);
    
    %Fill in results
    results.(tempGene)(:, 1) = model.rxns(Ind_rxns);
    results.(tempGene)(:, 2) = printRxnFormula(model, model.rxns(Ind_rxns), 0);
    if isfield(model,'subSystems')
        results.(tempGene)(:, 3) = model.subSystems(Ind_rxns);
    end
    if isfield(model,'rxnNames')
        results.(tempGene)(:, 4) = model.rxnNames(Ind_rxns);
    end
        results.(tempGene)(:, 5) = model.grRules(Ind_rxns);

    if ListResultsFlag
        LR_RowCnt = size(ListResults, 1);
        ListResults(LR_RowCnt + 1 : LR_RowCnt + size(results.(tempGene), 1), 1:5) = results.(tempGene);
        ListResults(LR_RowCnt + 1 : LR_RowCnt + size(results.(tempGene), 1), 6) = {tempGene};
    end
end

if isempty(results)
    warning('Your gene was not associated with any reactions!')
end
