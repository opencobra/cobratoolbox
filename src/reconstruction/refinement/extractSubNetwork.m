function subModel = extractSubNetwork(model, rxnList, metList)
% Extract subnetwork model
% USAGE:
% USAGE:
%
%    subModel = extractSubNetwork(model, rxnList, metList)
%
% INPUTS:
%    model:       COBRA model structure
%    rxnList:     Reaction list for the subnetwork to be extracted
%                reactions)
% OPTIONAL INPUTS:
%    metNames:    Metabolite list for the subnetwork to be extracted
%
% OUTPUT:
%    subModel:    COBRA model of subnetwork
%
% .. Author:
%       - Markus Herrgard 12/11/06
%       - Srikiran C 7/15/14
%       - Replaced rxnNames with rxnList 
%       as model.rxnNames is different from model.rxns,
%       and model.rxns is used to select the subnetwork.
%             Replaced metNames with metList, to avoid similar confusion.
%             Added the fields - rxnNames, rules and metCharge to subModel.
%           - Thomas Pfau June 2017 - switched to use of
%             removeRxns/removeMetabolites

selRxns = ismember(model.rxns,rxnList);
subS = model.S(:,selRxns);
if (nargin < 3)
    selMets = ~all(subS == 0,2);
else
    selMets = ismember(model.mets,metList);
end

subS = subS(selMets,:);
%Remove all Metabolites not selected
subModel = removeMetabolites(model,model.mets(~selMets),0);
%Remove all Rxns not selected (not the mets). 
subModel = removeRxns(subModel,model.rxns(~selRxns),'metFlag', false);
