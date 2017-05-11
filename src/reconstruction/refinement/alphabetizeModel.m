function abcModel = alphabetizeModel(model)
% Sorts the rxns, metabolites, and genes in a model into alphabetical
% order, useful after adding new reactions to a model. This function needs
% to be modified to work on models with different fields than these
% (currently set for `iAF1260c`)
%
% USAGE:
%
%    abcModel = alphabetizeModel(model)
%
% INPUT:
%     model:         COBRA model structure
%
% OUTPUT:
%    abcModel:       the alphabetized model
%
% .. Authors:
%       - Jeff Orth  11/21/07
%       - Modified to work on basic COBRA model. Richard Que (2/1/10)

abcModel = model;

[abcModel.rxns,iRxns] = sort(abcModel.rxns);
[abcModel.mets,iMets] = sort(abcModel.mets);
S = abcModel.S(:,iRxns);
abcModel.S = S(iMets,:);
abcModel.lb = abcModel.lb(iRxns);
abcModel.ub = abcModel.ub(iRxns);
abcModel.c = abcModel.c(iRxns);
abcModel.b = abcModel.b(iMets);

if isfield(model,'rev'), abcModel.rev = abcModel.rev(iRxns); end
if isfield(model,'charges'), abcModel.charges = abcModel.charges(iMets); end
if isfield(model,'metCharge'), abcModel.metCharge = abcModel.metCharge(iMets); end
if isfield(model,'subSystems'), abcModel.subSystems = abcModel.subSystems(iRxns); end
if isfield(model,'rxnNames'), abcModel.rxnNames = abcModel.rxnNames(iRxns); end
if isfield(model,'metNames'), abcModel.metNames = abcModel.metNames(iMets); end
if isfield(model,'metFormulas'), abcModel.metFormulas = abcModel.metFormulas(iMets); end
if isfield(model,'genes')
    [abcModel.genes,iGenes] = sort(abcModel.genes);
    if isfield(model,'rxnGeneMat')
        rxnGeneMat = abcModel.rxnGeneMat(:,iGenes);
        abcModel.rxnGeneMat = rxnGeneMat(iRxns,:);
    end
end
if isfield(model,'grRules')
    abcModel.grRules = abcModel.grRules(iRxns);
    if isfield(model,'rules')
        for i=1:length(model.grRules)
            [genes, rules] = parseBoolean(abcModel.grRules{i});
            [tmp geneInd] = ismember(genes,abcModel.genes);
            if ~isempty(geneInd)
                for j = 1:length(geneInd)
                    rules = strrep(rules,['x(' num2str(j) ')'],['x(' num2str(geneInd(j)) '_TMP_)']);
                end
                abcModel.rules{i} = strrep(rules,'_TMP_','');
            else
                abcModel.rules{i} = '';
            end
        end
    end
end
