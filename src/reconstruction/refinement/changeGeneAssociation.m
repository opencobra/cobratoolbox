function model = changeGeneAssociation(model, rxnName, grRule, geneNameList, systNameList, addRxnGeneMat)
% Change gene associations in a model
%
% USAGE:
%
%    model = changeGeneAssociation(model, rxnName, grRule, geneNameList, systNameList, addRxnGeneMat)
%
% INPUTS:
%    model:            COBRA Toolbox model structure
%    rxnName:          Name of the new reaction
%    grRule:           Gene-reaction rule in boolean format (and/or allowed)
%
% OPTIONAL INPUTS:
%    geneNameList:     List of gene names (used only for translation from
%                      common gene names to systematic gene names)
%    systNameList:     List of systematic names
%    addRxnGeneMat:    adds rxnGeneMat to model structure (default = true)
%
% OUTPUT:
%    model:            COBRA Toolbox model structure with new gene reaction associations
%
% .. Authors:
%       - Markus Herrgard 1/12/07
%       - Ines Thiele 08/03/2015, made rxnGeneMat optional
%       - IT: updated the nargin statement to accommodate the additional option

if exist('geneNameList','var') && exist('systNameList','var')
    translateNamesFlag = true;
else
    translateNamesFlag = false;
end

if ~exist('addRxnGeneMat','var')
    if isfield(model,'rxnGeneMat')
        addRxnGeneMat = 1;
    else
        addRxnGeneMat = 0;
    end
end

[isInModel,rxnID] = ismember(rxnName,model.rxns);

if (~isInModel)
    error(['Reaction ' rxnName ' not in the model']);
end

if ~isfield(model,'genes')
    model.genes = {};
end

nGenes = length(model.genes);
nGenesInit = nGenes;
model.rules{rxnID} = '';
% IT 01/2010 - this line caused problems for xls2model.m
if addRxnGeneMat ==1 
    model.rxnGeneMat(rxnID,1:nGenes) = zeros(1,nGenes);
end

if (~isempty(grRule))
    % Ronan & Stefan 13/9/2011 - moved this inside check if empty
    % Remove extra white space
    grRule = regexprep(grRule,'\s{2,}',' ');
    grRule = regexprep(grRule,'( ','(');
    grRule = regexprep(grRule,' )',')');
    [genes,rule] = parseBoolean(grRule);

    for i = 1:length(genes)
        if (translateNamesFlag)
            % Translate gene names to systematic names
            [isInList,translID] = ismember(genes{i},geneNameList);
            if isInList
                newGene = systNameList{translID};
                grRule = regexprep(grRule,[genes{i} '$'],newGene);
                grRule = regexprep(grRule,[genes{i} '\s'],[newGene ' ']);
                grRule = regexprep(grRule,[genes{i} ')'],[newGene ')']);
                genes{i} = newGene;
            else
                fprintf(['Gene name ' genes{i} ' not in translation list\n']);
            end
        end
        geneID = find(strcmp(model.genes,genes{i}));
        if (isempty(geneID))
            fprintf(['New gene ' genes{i} ' added to model\n']);
            % Append gene
            model.genes = [model.genes; genes(i)];
            nGenes = length(model.genes);
            if addRxnGeneMat == 1
                model.rxnGeneMat(rxnID,end+1) = 1;
            end
            rule = strrep(rule,['x(#' num2str(i) ')'],['x(' num2str(nGenes) ')']);
        else
            if addRxnGeneMat == 1
                model.rxnGeneMat(rxnID,geneID) = 1;
            end
            rule = strrep(rule,['x(#' num2str(i) ')'],['x(' num2str(geneID) ')']);
        end
    end
    model.rules{rxnID} = rule;
end

model.grRules{rxnID} = grRule;

%make sure variables are column vectors
model.rules = columnVector(model.rules);
model.grRules = columnVector(model.grRules);
if nGenes > nGenesInit
    model = extendModelFieldsForType(model,'genes','originalSize', nGenesInit, 'targetSize',nGenes);
end