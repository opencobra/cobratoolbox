function essentialInterest = plotEssentialRxns( essential, essentialRxn4Models, essentialityThreshold, numModelsPresent)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


% data = essentialRxn4Models;
% for j=1:size(data,2)
%     for i=1:size(data,1)
%         if strcmp('NotIncluded', data{i,j}) == 1
%         elseif 
%             strcmp(, data
%             'NaN'
%         end
%     end
% data = cell2mat(table2array(essentialRxn4Models(:,3:end)));

condition = essential>= 0  & essential<=essentialityThreshold;
reactionsInterest = sum(condition,2)>=numModelsPresent;
essentialInterest = essential(reactionsInterest,:);


modelNames = essentialRxn4Models.Properties.VariableNames(1,3:end);
for i=1:size(modelNames,2)
   modelNames2(i) = erase(modelNames(1,i),'structure');
end
rxnInterest = table2cell(essentialRxn4Models(reactionsInterest,1));
for i=1:size(rxnInterest,1)
   rxnInterest(i) = strrep(rxnInterest(i,1),'_','-');
end

mymap = [1 1 1; 1 0 0;  1 0.5 0;  1 0.5 0; 1 0.5 0; 1 0.5 0;1 1 0; 1 1 0;1 1 0;  1 1 0;  1 1 0; 0 0 0];
hm = HeatMap(essentialInterest,'RowLabels',rxnInterest,'Colormap',redbluecmap, 'Symmetric', false, 'DisplayRange', 100); %'ColumnLabels', modelNames2,
colormap(hm,mymap);

% 
% cg = clustergram(essentialInterest,'ColumnLabels', modelNames2,'RowLabels',rxnInterest,'Colormap',redbluecmap);
% colormap(cg,mymap);


end

