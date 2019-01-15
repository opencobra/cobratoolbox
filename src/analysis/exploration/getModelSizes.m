function [nMets, nRxns, nCtrs, nVars, nGenes, nComps] = getModelSizes(model)
% Get the sizes of the basic fields of the model structure
%
% USAGE:
%    [nMets, nRxns, nCtrs, nVars, nGenes, nComps] = getModelSizes(model)
%
% INPUT:
%    model:     A COBRA model structure
%
% OUTPUTS:
%    nMets:     The number of metabolites in the model
%    nRxns:     The number of reactions in the model
%    nCtrs:     The number of constraints in the model
%    nVars:     The number of variables in the model
%    nGenes:    The number of genes in the model
%    nComps:    The number of compartments in the model

[nMets,nRxns] = size(model.S);

nCtrs = 0;
nVars = 0;
nComps = 0;
nGenes = 0;
if isfield(model,'C')
    nCtrs = size(model.C,1);
end
if isfield(model,'E')
    nVars = size(model.E,2);
end

if isfield(model,'comps')
    nComps = size(model.comps,1);
end

if isfield(model,'genes')
    nGenes = size(model.genes,1);
end
