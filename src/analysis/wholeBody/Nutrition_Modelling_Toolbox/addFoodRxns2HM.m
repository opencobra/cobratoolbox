function [model,entriesNotAdded] = addFoodRxns2HM(model,foodRxns)
% Takes a set of food reactions to a whole-body metabolic model
%
% USAGE
%
%   Format:    [model,entriesNotAdded] = addFoodRxns2HM(model,foodRxns)
%   Example 1: [model,entriesNotAdded] = addFoodRxns2HM(model,'All Food')
%   Example 2: [model,entriesNotAdded] = addFoodRxns2HM(model,{'Food_EX_AvocadoSalad[d]','Food_EX_BakerPotatoes[d]'})

% INPUTS
%
%   model:     a whole-body metabolic model
%   foodRxns:  a set of instructions to tell the function which food
%               reactions should be added to the model. Valid foodRxns
%               entries are as follows:
%                   - 'All' : adds all food reactions in the vmh database
%                   including food category reactions
%                   - 'All Food': adds all food reactions in the vmh
%                   database but does not include food category reactions
%                   - 'All Cat': adds all food category reactions to the
%                   model
%                   - A cellular array containing a list of food 
%                   reactions to include in the model.
%
% OUTPUTS
%
%   model:          returns an updated model with the desired food reactions 
%   entriesNotAdded:    a list of reactions that were not in the vmh database
%                       and therefore were not added to the model
%   
% AUTHORS
%   Bronson R. Weston 2022

% Set up foodItems array
load('fdTable.mat')
load('fdCategoriesTable.mat')
if ischar(foodRxns)
    if strcmp(foodRxns,'All')
        foodRxns=[fdTable.Properties.VariableNames(2:end),fdCategoriesTable.Properties.VariableNames(2:end)];
        foodRxns=strcat('Food_EX_',foodRxns);
        foodRxns=strcat(foodRxns,'[d]');
    elseif strcmp(foodRxns,'All Food')
        foodRxns=fdTable.Properties.VariableNames(2:end);
        foodRxns=strcat('Food_EX_',foodRxns);
        foodRxns=strcat(foodRxns,'[d]');
    elseif strcmp(foodRxns,'All Cat')
        foodRxns=fdCategoriesTable.Properties.VariableNames(2:end);
        foodRxns=strcat('Food_EX_',foodRxns);
        foodRxns=strcat(foodRxns,'[d]');
    else
        foodRxns={foodRxns};
    end
else
    foodRxns=foodRxns;
end
%Combine fdTable and fdCategoriesTable and make necessary adjustements
fdCategoriesTable.Var1=[];
foodTable=[fdTable,fdCategoriesTable];
pro_Dindex=find(contains(foodTable.Var1,'pro_D')); %for now, remove pro_D from table.
foodTable(pro_Dindex,:)=[];
EnergyIndex=find(contains(foodTable.Var1,'Energy in Kcal'));
foodTable.Var1(EnergyIndex)={'Energy_in_Kcal'};

% Remove food items that already have reactions present in model    
[~,~,ib] = intersect(model.rxns,foodRxns);
foodRxns(ib)= [];

%Add 'Energy_in_Kcal[d]' metabolite if not present
if ~any(strcmp(model.mets,'Energy_in_Kcal[d]'))
    model=addMetabolite(model, 'Energy_in_Kcal[d]');
    model = addMultipleReactions(model, {'EX_DietEnergy'}, {'Energy_in_Kcal[d]'}, [-1], 'lb', 0, 'ub', 100000);
end

% Identify food reactions to add
augFoodRxns=regexprep(foodRxns,'Food_EX_','');
augFoodRxns=regexprep(augFoodRxns,'\[d\]','');

[~,ia,ib] = intersect(foodTable.Properties.VariableNames,augFoodRxns);
entriesNotAdded=foodRxns(setdiff(1:length(foodRxns),ib));
foodRxns=foodRxns(ib);

%Add all food category reactions
foodMetabolites= foodTable.Var1.';
foodMetabolites= strcat(foodMetabolites,'[d]');
sMatrix=-1*table2array(foodTable(:,ia));
model = addMultipleReactions(model, foodRxns, foodMetabolites, sMatrix, 'lb', zeros(1,length(foodRxns)), 'ub', zeros(1,length(foodRxns)));
end

