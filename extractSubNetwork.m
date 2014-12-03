function subModel = extractSubNetwork(model,rxnNames,metNames)
%extractSubNetwork Extract subnetwork model
%
% subModel = extractSubNetwork(model,rxnNames,metNames)
%
%INPUTS
% model     COBRA model structure
% rxnNames  Reaction list for the subnetwork to be extracted
%
%OPTIONAL INPUTS
% metNames  Metabolite list for the subnetwork to be extracted
%
%OUTPUT
% subModel  COBRA model of subnetwork
%
% Markus Herrgard 12/11/06

selRxns = ismember(model.rxns,rxnNames);
subS = model.S(:,selRxns);
if (nargin < 3)
    selMets = ~all(subS == 0,2);
else
    selMets = ismember(model.mets,metNames);
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
if (isfield(model,'genes'))
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