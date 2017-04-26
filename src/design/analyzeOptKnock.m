function [type,maxGrowth,maxProd,minProd] = analyzeOptKnock(model,deletions,target,biomassRxn,geneDelFlag)
% Determines whether an optknock solution is growth coupled
% or not and what the maximum growth and production rates are
%
% USAGE:
%
%    [type, maxGrowth, maxProd, minProd] = analyzeOptKnock(model, deletions, target, biomassRxn, geneDelFlag)
%
% INPUTS:
%    model:         COBRA model structure
%    deletions:     list of reaction or gene deletions (empty if wild type)
%    target:        the exchange reaction for the `OptKnock` target metabolite
%
% OPTIONAL INPUTS:
%    biomassRxn:    the biomass reaction name (Default = whatever is defined in
%                   the model)
%    geneDelFlag:   perform gene and not reaction deletions (Default = false)
%
% OUTPUTS:
%    type:          the type of `OptKnock` solution (growth coupled or not)
%    maxGrowth:     the maximum growth rate of the knockout strain
%    maxProd:       the maximum production rate of the target compound at the
%                   maximum growth rate
%    minProd:       the minimum production rate of the target compound at the
%                   maximum growth rate
% .. Author: - Jeff Orth  6/25/08

if (nargin < 4)
    biomassRxn = model.rxns(model.c==1);
end
if (nargin < 5)
    geneDelFlag = false;
end

% Create model with deletions
if (length(deletions) > 0)
    if (geneDelFlag)
        modelKO = deleteModelGenes(model,deletions);
    else
        modelKO = changeRxnBounds(model,deletions,zeros(size(deletions)),'b');
    end
else
    modelKO = model;
end


FBAsol1 = optimizeCbModel(modelKO,'max',true); %find max growth rate of strain
modelKOfixed = changeRxnBounds(modelKO,biomassRxn,FBAsol1.f,'l'); %fix the growth rate to max
modelKOfixed = changeObjective(modelKOfixed,target); %set target as the objective
FBAsol2 = optimizeCbModel(modelKOfixed,'min',true); %find minimum target rate at this growth rate
FBAsol3 = optimizeCbModel(modelKOfixed,'max',true); %find maximum target rate at this growth rate

maxGrowth = FBAsol1.f;
minProd = FBAsol2.f;
maxProd = FBAsol3.f;

if maxProd < .1 %not growth coupled
    type = 'not growth coupled';
elseif minProd == 0 %non unique
    type = 'non unique';
elseif (maxProd - minProd) > .1 %growth coupled non unique
    type = 'growth coupled non unique';
else %growth coupled
    type = 'growth coupled';
end
