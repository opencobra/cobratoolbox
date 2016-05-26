function model = assignGPRA(model,gpraFile)
%assignGPRA Assign each reaction a Gene-protein-reaction association
%
% model = assignGPRA(model,gpraFile)
%
%INPUTS
% model         COBRA model structure
% gpraFile      SimPheny GPRA file
%
%OUTPUT
% model         COBRA model with gene-protein-reaction assoction
%
% 10/4/06 Markus Herrgard

[rxnList,genes,rxnGeneMat,subSystems] = parseSimPhenyGPRA(gpraFile);

[tmp,gpraRxnInd,modelRxnInd] = intersect(rxnList,model.rxns);

model.genes = genes;

model.rxnGeneMat = sparse(length(model.rxns),length(genes));
model.rxnGeneMat(modelRxnInd,:) = rxnGeneMat(gpraRxnInd,:);