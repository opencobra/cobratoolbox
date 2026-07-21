function model = assignGPRA(model, gpraFile)
% Assigns each reaction a Gene-protein-reaction association
%
% USAGE:
%
%    model = assignGPRA(model, gpraFile)
%
% INPUTS:
%    model:       COBRA model structure with fields:
%
%                   * .rxns - `n x 1` reaction identifiers, intersected
%                     with the reactions parsed from `gpraFile`
%                   * .genes - overwritten with the gene list parsed from
%                     `gpraFile`
%                   * .rxnGeneMat - `n x g` reaction-gene incidence matrix,
%                     rebuilt from the parsed GPRA file
%    gpraFile:    SimPheny GPRA file
%
% OUTPUT:
%    model:       COBRA model with gene-protein-reaction assoction
%
% .. Author: -  Markus Herrgard 10/4/06

[rxnList,genes,rxnGeneMat,subSystems] = parseSimPhenyGPRA(gpraFile);

[tmp,gpraRxnInd,modelRxnInd] = intersect(rxnList,model.rxns);

model.genes = genes;

model.rxnGeneMat = sparse(length(model.rxns),length(genes));
model.rxnGeneMat(modelRxnInd,:) = rxnGeneMat(gpraRxnInd,:);
model.rxnGeneMat=sparse(model.rxnGeneMat);