function [newModel,AddedExchRxn] = addExchangeRxn(model,metList,lb,ub)
% Adds exchange reactions
%
% USAGE:
%
%    newModel = addExchangeRxn(model, metList, lb, ub)
%
% INPUTS:
%    model:         Cobra model structure
%    metList:       List of metabolites
%
% OPTIONAL INPUTS:
%    lb:            Array of lower bounds
%    ub:            Array of upper bounds
%
% OUTPUT:
%    newModel:      COBRA model with added exchange reactions
%
% .. Author: - Ines Thiele 02/2009

if nargin < 3
    lb = ones(length(metList),1)*min(model.lb);
end
if nargin < 4
    ub = ones(length(metList),1)*max(model.ub);
end
Revs = zeros(length(metList),1);
Revs(lb<0) = 1;

newModel = model;
AddedExchRxn = '';
for i = 1 : length(metList)
    [newModel,rxnIDexists] = addReaction(newModel,strcat('EX_',metList{i}),metList(i),-1,Revs(i),...
        lb(i),ub(i));
    AddedExchRxn=[AddedExchRxn;strcat('EX_',metList(i))];
end
