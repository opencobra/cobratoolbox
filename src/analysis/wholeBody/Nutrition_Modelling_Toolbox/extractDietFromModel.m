function [foodMenu] = extractDietFromModel(model)
% Analyse a VMH whole-body model and extract the diet based on the lower
% bound constraints of the food and dietary exchange reactions
%
% USAGE:
%
%    [foodMenu] = extractDietFromModel(model)
%
% INPUT:
%    model:       A human whole-body model (WBM), with fields:
%
%                   * .rxns - reaction identifiers
%                   * .lb - lower flux bounds
%
% OUTPUT:
%    foodMenu:    An n x 2 cell array containing n dietary metabolites and
%                 their corresponding flux
%
% .. Author: - Bronson R. Weston, 2022

% Identify food reactions
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

