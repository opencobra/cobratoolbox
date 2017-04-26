function [growthRate,minProd,maxProd] = testOptKnockSol(model,targetRxn,deletions)
% Tests an `OptKnock` knockout strain
%
% USAGE:
%
%    [growthRate, minProd, maxProd] = testOptKnockSol(model, targetRxn, deletions)
%
% INPUTS:
%    model:         COBRA model structure
%    targetRxn:     Target reaction (e.g. 'EX_etoh(e)')
%
% OPTIONAL INPUT:
%    deletions:     Set of reaction deletions (e.g. {'PGI','TPI'})
%                   (Default = [])
%
% OUTPUTS:
%    growthRate:    Maximim growth rate of the strain
%    minProd:       Minimum production rate at max growth rate
%    maxProd:       Maximum production rate at max growth rate
%
% .. Author - Markus Herrgard 5/23/07

if (nargin < 3)
    deletions = [];
end

tol = 1e-7;

% Number of deletions
nDel = length(deletions);

modelKO = model;
for i = 1:nDel
    modelKO = changeRxnBounds(modelKO,deletions{i},0,'b');
end
% Calculate optimal growth rate
solKO = optimizeCbModel(modelKO);
growthRate = solKO.f;
if (solKO.stat == 1)
    % Max & min production of the metabolite at the optimal growth rate
    grRounded = floor(solKO.f/tol)*tol;
    modelKO = changeRxnBounds(modelKO,modelKO.rxns(modelKO.c==1),grRounded,'l');
    modelKO = changeObjective(modelKO,targetRxn);
    solMax = optimizeCbModel(modelKO,'max');
    solMin = optimizeCbModel(modelKO,'min');
    maxProd = solMax.f;
    minProd = solMin.f;
else
    maxProd = 0;
    minProd = 0;
end
