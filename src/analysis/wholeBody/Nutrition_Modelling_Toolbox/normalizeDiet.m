function [foodMenu] = normalizeDiet(foodMenu,calories,exceptions)
% This function normalizes a diet to meet caloric specifications.
%
% USAGE:
%
%   [foodMenu] = normalizeDiet(foodMenu,calories,exceptions)
%
% INPUTS
%   foodMenu:          An nx2 cell array containing the food items and the
%                      corresponding flux (n= number of food items)
%
%   calories           The number of calories the diet should be
%                      renormalized to
%
%   exceptions:        A cell array containing any specific food items that
%                      should be excluded from the renormalization step.
%                      This maintains the flux for the specefied food
%                      items.
%
% OUTPUT
%   foodMenu:          An re-normalized version of the original foodMenu 
%
% Authors:
%   Bronson R. Weston 2022

load fdTable.mat
foodRxns=fdTable.Properties.VariableNames(2:end);
foodMenuFoodItems=[];
for i=1:length(foodMenu(:,1))
    if any(strcmp(foodMenu{i,1},foodRxns))
        foodMenuFoodItems=[foodMenuFoodItems,i];
    end
end


eF1=getDietEnergy(foodMenu); %get energy of foodMenu (eF1)
foodMenu2=foodMenu;
indexes=1:length(foodMenu2(:,1));
if ~isempty(exceptions)
    for i=length(foodMenu2(:,1)):-1:1 %remove exceptions from food menu to create foodMenu2
        if any(strcmp(foodMenu2{i,1}, exceptions))
            indexes(i)=[];
            if any(foodMenuFoodItems==i)
                foodMenuFoodItems(foodMenuFoodItems==i)=[];
            end
        else
            foodMenu2(i,:)=[];
        end
    end
    eF2=getDietEnergy(foodMenu2); %get energy of exceptions (eF2)
else
    eF2=0;
end

if eF2>calories
    error('Specified exceptions have greater caloric value than specified total caloric input')
end

scale=(calories-eF2)/(eF1-eF2); % get scaling factor
foodMenu(foodMenuFoodItems,2)=num2cell(cell2mat(foodMenu(foodMenuFoodItems,2))*scale); %normalize foodMenu to meet energy demands 
end

