function rxnsOfInterest = plotEssentialRxns( essentialRxn4Models, dataStruct, essentialityThreshold, numModelsPresent)
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

allRxns = essentialRxn4Models.rxn(:);
field = fieldnames(dataStruct);

%% Build reaction essentiality matrix
for j=1:size(field,1)
    for i=1:size(allRxns,1)
        idx = find(strcmp(allRxns{i,1},dataStruct.(field{j}).rxnSubsystems(:,1)));
        if idx ~= 0
            essentialRxn4Models.(field{j}){i} = dataStruct.(field{j}).grRateKO(idx,1);
            if ~isnan(dataStruct.(field{j}).grRateKO(idx,1))
                essential(i,j) = dataStruct.(field{j}).grRateKO(idx,1);
            else 
                essential(i,j) = 0;
            end
        else
            essentialRxn4Models.(field{j}){i} = 'NotIncluded';
            essential(i,j) = -1;            
        end
    end
end

%%

condition = essential>= 0  & essential<=essentialityThreshold;
reactionsInterest = sum(condition,2)>=numModelsPresent;
rxnsOfInterest = essential(reactionsInterest,:);


modelNames = essentialRxn4Models.Properties.VariableNames(1,3:end);
for i=1:size(modelNames,2)
   modelNames2(i)  = strrep(modelNames(1,i), 'structure',{''});
end
rxnInterest = table2cell(essentialRxn4Models(reactionsInterest,1));
for i=1:size(rxnInterest,1)
   rxnInterest(i) = strrep(rxnInterest(i,1),'_','-');
end

mymap = [1 1 1; 1 0 0;  1 0.5 0;  1 0.5 0; 1 0.5 0; 1 0.5 0;1 1 0; 1 1 0;1 1 0;  1 1 0;  1 1 0; 0 0 0];
hm = HeatMap(rxnsOfInterest,'RowLabels',rxnInterest,'Colormap',redbluecmap, 'Symmetric', false, 'DisplayRange', 100); %'ColumnLabels', modelNames2,
colormap(hm,mymap);

% 
% cg = clustergram(essentialInterest,'ColumnLabels', modelNames2,'RowLabels',rxnInterest,'Colormap',redbluecmap);
% colormap(cg,mymap);


end

