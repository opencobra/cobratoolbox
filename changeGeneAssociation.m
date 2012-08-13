function model = changeGeneAssociation(model,rxnName,grRule,geneNameList,systNameList)
%changeGeneAssociation Change gene associations in a model
%
% model = changeGeneAssociation(model,rxnName,grRule,geneName,systName)
%
%INPUTS
% model             COBRA Toolbox model structure
% rxnName           Name of the new reaction
% grRule            Gene-reaction rule in boolean format (and/or allowed)
%
%OPTIONAL INPUTS
% geneNameList      List of gene names (used only for translation from
%                   common gene names to systematic gene names)
% systNameList      List of systematic names
%
%OUTPUT
% model             COBRA Toolbox model structure with new gene reaction
%                   associations
%
% Markus Herrgard 1/12/07

if (nargin < 4)
    translateNamesFlag = false;
else
    translateNamesFlag = true;
end

[isInModel,rxnID] = ismember(rxnName,model.rxns);

if (~isInModel)
    error(['Reaction ' rxnName ' not in the model']); 
end

if ~isfield(model,'genes')
    model.genes = {};
end
nGenes = length(model.genes);
model.rules{rxnID} = '';
% IT 01/2010 - this line caused problems for xls2model.m
    model.rxnGeneMat(rxnID,:) = zeros(1,nGenes);
% Remove extra white space
grRule = regexprep(grRule,'\s{2,}',' ');
grRule = regexprep(grRule,'( ','(');
grRule = regexprep(grRule,' )',')');

if (~isempty(grRule))
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
                warning(['Gene name ' genes{i} ' not in translation list']);
            end
        end
        geneID = find(strcmp(model.genes,genes{i}));
        if (isempty(geneID))
            warning(['New gene ' genes{i} ' added to model']);
            % Append gene
            model.genes = [model.genes; genes(i)];
            nGenes = length(model.genes);
            model.rxnGeneMat(rxnID,end+1) = 1;
            rule = strrep(rule,['x(' num2str(i) ')'],['x(' num2str(nGenes) ')']);
        else
            model.rxnGeneMat(rxnID,geneID) = 1;
            rule = strrep(rule,['x(' num2str(i) ')'],['x(' num2str(geneID) ')']);
        end
    end
    model.rules{rxnID} = rule;
end

model.grRules{rxnID} = grRule;

%make sure variables are column vectors
model.rules = columnVector(model.rules);
model.grRules = columnVector(model.grRules);