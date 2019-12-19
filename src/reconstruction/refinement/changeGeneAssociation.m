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
if (~isfield(model, 'rules') && isfield(model, 'grRules'))
    model = generateRules(model);
elseif (~isfield(model, 'rules') && ~isfield(model, 'grRules'))
    model.rules = repmat({''}, size(model.rxns));
end
model.rules{rxnID,1} = '';
if addRxnGeneMat ==1 
    model.rxnGeneMat(rxnID,1:nGenes) = zeros(1,nGenes);
end  

[rule,~,newGenes] = parseGPR(grRule,model.genes);
if translateNamesFlag
    [pres,pos] = ismember(newGenes,geneNameList);
    newGenes = columnVector(systNameList(pres(pos)));
end
model.genes = [model.genes;newGenes];
model.rules{rxnID,1} = rule;

getGene = @(x) model.genes{str2num(x)};
if addRxnGeneMat
    res = regexp(model.rules{rxnID},'x\((?<ID>[0-9]+)\)','names');
    pos = cellfun(@str2num , {res.ID});
    model.rxnGeneMat(rxnID,pos) = true;
end

model = creategrRulesField(model,rxnID);

%make sure variables are column vectors
model.rules = columnVector(model.rules);
if nGenes > nGenesInit
    model = extendModelFieldsForType(model,'genes','originalSize', nGenesInit, 'targetSize',nGenes);
end


function geneID = convertGeneID(geneID, systNameList, geneNameList)
presence = ismember(geneNameList,geneID);
if any(presence)
    geneID = systNameList(presence);
end