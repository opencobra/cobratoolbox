function subModel = extractSubNetwork(model,rxnList,metList)
%extractSubNetwork Extract subnetwork model
%
% subModel = extractSubNetwork(model,rxnList,metList)
%
%INPUTS
% model     COBRA model structure
% rxnList  Reaction list for the subnetwork to be extracted
%
%OPTIONAL INPUTS
% metNames  Metabolite list for the subnetwork to be extracted
%
%OUTPUT
% subModel  COBRA model of subnetwork
%
% Markus Herrgard 12/11/06
%
% Srikiran C 7/15/14
% - Replaced rxnNames with rxnList as model.rxnNames is different from
% model.rxns, and model.rxns is used to select the subnetwork.
% - Replaced metNames with metList, to avoid similar confusion.
% - Added the fields - rxnNames, rules and metCharge to subModel.

selRxns = ismember(model.rxns,rxnList);
subS = model.S(:,selRxns);
if (nargin < 3)
    selMets = ~all(subS == 0,2);
else
    selMets = ismember(model.mets,metList);
end

subS = subS(selMets,:);

subModel.S = subS;
subModel.rxns = model.rxns(selRxns);
subModel.mets = model.mets(selMets);
if (isfield(model,'b'))
    subModel.b = model.b(selMets);
end
if (isfield(model,'metNames'))
    subModel.metNames = model.metNames(selMets);
end
if (isfield(model,'metFormulas'))
    subModel.metFormulas = model.metFormulas(selMets);
end
if (isfield(model,'description'))
    subModel.description = model.description;
end
if (isfield(model,'rev'))
    subModel.rev = model.rev(selRxns);
end
if (isfield(model,'lb'))
    subModel.lb = model.lb(selRxns);
end
if (isfield(model,'ub'))
    subModel.ub = model.ub(selRxns);
end
if (isfield(model,'c'))
    subModel.c = model.c(selRxns);
end
if (isfield(model,'genes') && isfield(model,'rxnGeneMat'))
   newRxnGeneMat = model.rxnGeneMat(selRxns,:);
   selGenes = sum(newRxnGeneMat)' > 0;
   subModel.rxnGeneMat = newRxnGeneMat(:,selGenes);
   subModel.genes = model.genes(selGenes);
   subModel.grRules = model.grRules(selRxns);
end
if (isfield(model,'geneNames'))
    subModel.geneNameRules = model.geneNameRules(selRxns);
    subModel.geneNames = model.geneNames(selGenes);
end
if (isfield(model,'subSystems'))
    subModel.subSystems = model.subSystems(selRxns);
end
if (isfield(model,'rxnNames'))
    subModel.rxnNames = model.rxnNames(selRxns);
end
if (isfield(model,'rules'))
    subModel.rules = model.rules(selRxns);
end
if (isfield(model,'metCharge'))
    subModel.metCharge = model.metCharge(selMets);
end
