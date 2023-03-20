function [metFlux] = getMetaboliteFlux(diet)
% This function takes a diet consisting of food items and returns the
% associated flux of metabolites.
%
% USAGE:
%   [metFlux] = getMetaboliteFlux(diet)
%
% INPUT:
%   diet:   an nx2 cell array consisting of n dietary/food components and
%           their corresponding flux in grams (for food items) or mmol (for
%           individual metabolites) per day.
%
% OUTPUT:
%   metFlux: returns an nx2 cell array containing a list of all n metabolites
%            within the diet and the corresponding flux.
%
% AUTHORS:
%   Bronson R. Weston 2022

%Remove any duplicate entries in diet
[~, uniqueIdx] =unique(diet(:,1)); 
diet=diet(uniqueIdx,:);


%Set up food Table
load('fdTable.mat');
load('fdCategoriesTable.mat')
fdCategoriesTable.Var1=[];
foodTable=[fdTable,fdCategoriesTable];
clear fdTable
foodTable(contains(foodTable.Var1,'pro_D'),:)=[];
foodTable(contains(foodTable.Var1,'Energy_in_Kcal'),:)=[];
foodMetabolites= foodTable.Var1;

%Convert Table into Numerical Matrix
sMatrix=table2array(foodTable(1:length(foodMetabolites),2:end));

%Get Column Index in Matrix for each diet item
foodItems=find(contains(diet(:,1),'Food_EX_'));
foodTableItems=foodTable.Properties.VariableNames(2:end);
foodTableItems=strcat('Food_EX_',foodTableItems);
foodTableItems=strcat(foodTableItems,'[d]');

%Convert Diet flux values from string to numeric if necessary
for i=1:length(diet(:,2))
    if ischar(diet{i,2})
        diet{i,2}=str2num(diet{i,2});
    elseif double(diet{i,2})==0
        error(['diet position' num2str(i) 'has invalid flux input'])
    end
end


%If no food items are present, return 
if isempty(foodItems)
    metFlux=diet;
    return
end

ind=zeros(1,length(foodItems));
for i=1:length(foodItems)
    ind(i)=find(strcmp(foodTableItems,diet{foodItems(i),1}));
end

%Calculate flux for each metabolite
metFlux=[foodTable.Var1,num2cell(sMatrix(:,ind)*cell2mat(diet(foodItems,2)))];

metFlux(:,1)=strcat('Diet_EX_',metFlux(:,1));
metFlux(:,1)=strcat(metFlux(:,1),'[d]');

metItems=find(contains(diet(:,1),'Diet_EX_'));
if ~isempty(metItems)
    for i=1:length(metItems)
        ind=find(strcmp(metFlux(:,1),diet(metItems(i),1)));
        if ~isempty(ind)
            metFlux{ind,2}=metFlux{ind,2}+diet{metItems(i),2};
        else
            metFlux=[metFlux; diet(metItems(i),:)];
        end
    end
end

end
