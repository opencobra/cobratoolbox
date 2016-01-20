function newModel = addExchangeRxn(model,metList,lb,ub)
%addExchangeRxn adds exchange reactions
%
% newModel = addExchangeRxn(model,metList,lb,ub)
%
%INPUTS
% model         Cobra model structure
% metList       List of metabolites
%
%OPTIONAL INPUTS
% lb            Array of lower bounds
% ub            Array of upper bounds
%
%OUTPUT
% newModel      COBRA model with added exchange reactions
%
% Ines Thiele 02/2009

if nargin < 3
    lb = ones(length(metList),1)*min(model.lb);
end
if nargin < 4
    ub = ones(length(metList),1)*max(model.ub);
end
Revs = zeros(length(metList),1);
Revs(lb<0) = 1;

newModel = model;
for i = 1 : length(metList)
    [newModel] = addReaction(newModel,strcat('Ex_',metList{i}),metList(i),-1,Revs(i),lb(i),ub(i));
end