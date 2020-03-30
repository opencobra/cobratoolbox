function subModel = extractSubNetwork(model, rxnList, metList, updateGenes)
% Extract subnetwork model
% USAGE:
%
%    subModel = extractSubNetwork(model, rxnList, metList)
%
% INPUTS:
%    model:       COBRA model structure
%    rxnList:     Reaction list for the subnetwork to be extracted
%
% OPTIONAL INPUTS:
%    metNames:    Metabolite list for the subnetwork to be extracted
%    updateGenes: Also remove unused genes (can take some time on large
%                 networks)
%
% OUTPUT:
%    subModel:    COBRA model of subnetwork
%
% .. Author:
%       - Markus Herrgard 12/11/06
%       - Srikiran C 7/15/14
%       - Replaced rxnNames with rxnList 
%         as model.rxnNames is different from model.rxns,
%         and model.rxns is used to select the subnetwork.
%         Replaced metNames with metList, to avoid similar confusion.
%         Added the fields - rxnNames, rules and metCharge to subModel.
%       - Thomas Pfau June 2017 - switched to use of
%         removeRxns/removeMetabolites

selRxns = ismember(model.rxns,rxnList);
subS = model.S(:,selRxns);
if ~exist('selMets','var') || isempty(selMets)
    selMets = ~all(subS == 0,2);
else
    selMets = ismember(model.mets,metList);
end

if ~exist('updateGenes','var')
    updateGenes = false;
end

subS = subS(selMets,:);
%Remove all Metabolites not selected
subModel = removeMetabolites(model,model.mets(~selMets),0);
%Remove all Rxns not selected (not the mets). 
subModel = removeRxns(subModel,model.rxns(~selRxns),'metFlag', false);

if updateGenes
    if ~isfield(subModel,'rxnGeneMat')
        modelWRxnGeneMat = buildRxnGeneMat(subModel);
        rxnGeneMat = modelWRxnGeneMat.rxnGeneMat;
    else
        rxnGeneMat = sparse(subModel.rxnGeneMat);
    end
    genesToRemove = ~any(rxnGeneMat);
    subModel = removeFieldEntriesForType(subModel,genesToRemove,'genes',numel(model.genes));
end
