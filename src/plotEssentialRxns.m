function rxnInterest4Models = plotEssentialRxns( essentialRxn4Models, essentialityThreshold, numModelsPresent)
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

% Obtain rxn names
allRxnNames = essentialRxn4Models.rxn(:);

% Obtain model names
modelNames = essentialRxn4Models.Properties.VariableNames(2:end);

%% Build reaction essentiality matrix from essentialRxn4Models
for j=1:size(modelNames,2)
    for i=1:size(allRxnNames,1)
        value = essentialRxn4Models.(modelNames{j}){i};
        if strcmp(value,'NotIncluded')
            essential(i,j) = -1;
        elseif ~isnan(value)
            essential(i,j) = value;
        else
            essential(i,j) = 0;
        end
    end
end

%%

condition = essential>= 0  & essential<=essentialityThreshold;
reactionsInterest = sum(condition,2)>=numModelsPresent;
rxnsOfInterest = essential(reactionsInterest,:);

rxnInterest4Models = table2cell(essentialRxn4Models(reactionsInterest,1));
rxnInterestNames = allRxnNames(reactionsInterest,1);

%% Generate plot labels
for i=1:size(rxnInterestNames,1)
   rxnInterestNames(i,1) = strrep(rxnInterestNames(i,1),'_','-');
end
for i=1:size(modelNames,2)
   modelNames(1,i) = strrep(modelNames(1,i),'_','-');
end

%% Compare essential reaction in a heatmap
maxFluxUnits = max(max(rxnsOfInterest));
if maxFluxUnits ~= 0
mymap = [1 1 1; 1 0 0;  1 0.5 0;  1 0.5 0; 1 0.5 0; 1 0.5 0;1 1 0; 1 1 0;1 1 0;  1 1 0;  1 1 0; 0 0 0];
hm = HeatMap(rxnsOfInterest,'ColumnLabels', modelNames,'RowLabels',rxnInterestNames,'Colormap',redbluecmap, 'Symmetric', false, 'DisplayRange', maxFluxUnits); %
colormap(hm,mymap);
else
    fprintf('\n Attention: All non-essential reactions have flux above the threshold \n')
end


% cg = clustergram(essentialInterest,'ColumnLabels', modelNames2,'RowLabels',rxnInterest,'Colormap',redbluecmap);
% colormap(cg,mymap);


end

