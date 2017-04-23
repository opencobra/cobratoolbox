function model = assignGPRA(model,gpraFile)
% Assigns each reaction a Gene-protein-reaction association
%
% USAGE:
%
%    model = assignGPRA(model, gpraFile)
%
% INPUTS:
%    model:         COBRA model structure
%    gpraFile:      SimPheny GPRA file
%
% OUTPUT:
%    model:         COBRA model with gene-protein-reaction assoction
%
% .. Author: -  Markus Herrgard 10/4/06

[rxnList,genes,rxnGeneMat,subSystems] = parseSimPhenyGPRA(gpraFile);

[tmp,gpraRxnInd,modelRxnInd] = intersect(rxnList,model.rxns);

model.genes = genes;

model.rxnGeneMat = sparse(length(model.rxns),length(genes));
model.rxnGeneMat(modelRxnInd,:) = rxnGeneMat(gpraRxnInd,:);
