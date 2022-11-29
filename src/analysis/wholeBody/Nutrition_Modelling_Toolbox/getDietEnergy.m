function [calories] = getDietEnergy(diet)
%Given a nx2 cell array of diet components and serving sizes, computes how
%many Calories are in the diet. Does not consider calories of metabolites
load('fdTable.mat');
calIndex=find(contains(fdTable.Var1,'Energy_in_Kcal'));
for i=1:length(diet(:,1))
    try
        cals(i)=table2array(fdTable(calIndex,find(strcmp(fdTable.Properties.VariableNames,diet(i,1)))));
    catch
        cals(i)=0;
    end
end
calories=cals*cell2mat(diet(:,2));
end
