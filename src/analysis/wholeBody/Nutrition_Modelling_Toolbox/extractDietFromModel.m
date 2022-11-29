function [foodMenu] = extractDietFromModel(model)
%This function analysis an VMH model and extracts the diet based on the
%lower bound constraints.
%
% USAGE:
%   [foodMenu] = extractDietFromModel(model)
% INPUT:
%   model:     A human model (WBM)
% OUTPUT:
%   foodMenu:   A nx2 cell array containing n dietary metabolites and their
%               corresponding flux
% Authors:
%       Bronson R. Weston, 2022


%Identify food reactions
foodRxns=find(contains(model.rxns,'Food_EX_'));
foodRxns=foodRxns(model.lb(foodRxns)<0);

%Identify dietary metabolite reactions
metRxns=find(contains(model.rxns,'Diet_EX_'));
metRxns=metRxns(model.lb(metRxns)<0);
foodFlux=[];
metFlux=[];
metItems={};
foodItems={};

%Excract lower bound constraints of food and diet reactions
if length(foodRxns)>0
    foodItems = model.rxns(foodRxns);
    foodFlux = -1*model.lb(foodRxns);
end
if length(metRxns)>0
    metItems = model.rxns(metRxns);
    metFlux = -1*model.lb(metRxns);
end

%Specify foodMenu
foodMenu=[foodItems,num2cell(foodFlux);metItems,num2cell(metFlux)];
end

