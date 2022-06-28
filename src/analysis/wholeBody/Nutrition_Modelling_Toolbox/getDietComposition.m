function [dietComposition] = getDietComposition(input,graphOnOff,Title)
% This function takes a diet (or a model) and identifies the food macros
%
% USAGE:
%   [Macros,Categories] = getDietComposition(input)
%
% INPUT:
%   input: either a whole-body metabolic model or a diet
%
% OPTIONAL INPUT
%   graphOnOff: set to 'on' if a pie chart figure is desired
%   Title:      set title of the pie chart
%
% OUTPUT:
%   dietComposition: A table containing the breakdown of the diet macros
%
% AUTHORS:
%   Bronson R. Weston 2021-2022

%To do:
% 1)Make compatible with metabolites in the diet (currently only accounts for
%  food items)
% 2) Change water from the "other" category to its own category
% 3) Add a calories breakdown, not just mass (optional)
% 4) Lets see if we can work with Tim to expand the list of metabolites that we can
% identify with a category. If so, we should update accordingly.

%Returns macros in grams
if isstruct(input) %If input is a model
    %Bram, when incorporating metabolites into this, I recommend replacing most of this code with getDietComposition
    model=input;
    foodRxns=find(contains(model.rxns,'Food_EX_'));
    foodRxns=foodRxns(model.lb(foodRxns)<0);
    foodFlux=[];
    foodItems={};
    if length(foodRxns)>0
        foodItems = regexprep(model.rxns(foodRxns),'Food_EX_','');
        foodItems = regexprep(foodItems,'\[d\]','');
        foodFlux = -1*(model.ub(foodRxns)+model.lb(foodRxns))/2;
    end
    diet=[foodItems,num2cell(foodFlux)];
else %If input is a diet
    diet=input;
end
load('fdTable.mat');
load('fdCategoriesTable.mat');
calIndex=find(contains(fdTable.Var1,'Energy_in_Kcal'));

totals=zeros(length(fdTable{:,1}),1); %totals will track the flux of each metabolite
%For each metabolite in fdTable, add the corresponding flux to totals
for i=1:length(diet(:,1)) 
    if ~isempty(find(strcmp(fdTable.Properties.VariableNames,diet(i,1))))
%         fdTable{:,find(strcmp(fdTable.Properties.VariableNames,diet(i,1)))}*cell2mat(diet(i,2))
        totals=totals+fdTable{:,find(strcmp(fdTable.Properties.VariableNames,diet(i,1)))}*cell2mat(diet(i,2));
    else
        totals=totals+fdTable{:,find(strcmp(fdCategoriesTable.Properties.VariableNames,diet(i,1)))}*cell2mat(diet(i,2));
    end
end

%convert flux from mmol to grams
load('molecularMassTable.mat','molecularMassTable')
molMass=molecularMassTable{:,2};
molMass=totals(1:end-1).*molMass/1000;

%Identify food item categories
load('metaboliteCategories.mat','metaboliteCategories')
Categories={'Vitamins/Minerals/Elements','Carbohydrates','Proteins','Lipids','Other'};
Macros=zeros(5,1);
mets=fdTable{:,1};
for i=1:length(fdTable{1:end-1,1})
    molMassInd=find(strcmp(metaboliteCategories{:,2},mets{i}));
    cat=metaboliteCategories{molMassInd,1};
    switch cat{1}
        case 'Lipids'
            Macros(4)=Macros(4)+molMass(i);
        case 'Carbohydrates'
            Macros(2)=Macros(2)+molMass(i);
        case 'Proteins'
            Macros(3)=Macros(3)+molMass(i);
        case 'Minerals and trace elements'
            Macros(1)=Macros(1)+molMass(i);
        case 'Vitamins'
            Macros(1)=Macros(1)+molMass(i);
        case 'Other'
            Macros(5)=Macros(5)+molMass(i);
    end
end
for i=1:4
    percent=round(100*Macros(i)/sum(Macros(1:4)),2);
    labels{i}=[Categories{i},' (', num2str(percent),'%)'];
end


if ~exist('graphOnOff','var')
    fig=figure();
    pie(Macros(1:4),labels)
    if exist('Title','var')
        title(Title)
    end
elseif strcmp(graphOnOff,'On')
    fig=figure();
    pie(Macros(1:4),labels)
    if exist('Title','var')
        title(Title)
    end
end
dietComposition=table(Categories.',Macros,'VariableNames',{'Category', 'Mass (g)'});
end
