function rxnInterest4Models = plotEssentialRxns( essentialRxn4Models, essentialityRange, numModelsPresent)

%plotEssentialRxns.m
%This funtion plots an heatmap using as inputs variables that allow a 
%conditional search of reactions of interest
%
%by Dr. Miguel A.P. Oliveira{1}

%{1} Luxembourg Centre for Systems Biomedicine, University of Luxembourg,
%7 avenue des Hauts-Fourneaux, Esch-sur-Alzette, Luxembourg.

% 08/12/2017
%% #########################################################\

% Obtain rxn names
allRxnNames = essentialRxn4Models.rxn(:);

% Obtain model names
modelNames = essentialRxn4Models.Properties.VariableNames(2:end);

%% Build reaction essentiality matrix from essentialRxn4Models
for j=1:size(modelNames,2)
    for i=1:size(allRxnNames,1)
        value = essentialRxn4Models.(modelNames{j}){i};
        if strcmp(value,'NotIncluded')
            essential(i,j) = -10;
        elseif ~isnan(value)
            essential(i,j) = value;
        else
            essential(i,j) = 0;
        end
    end
end

%% Conditional search

condition = essential>=essentialityRange(1) & essential>= 0  & essential<=essentialityRange(2);
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
minFluxUnits = min(min(rxnsOfInterest));

if maxFluxUnits ~= 0 && minFluxUnits==0
    mymap = [ 1 0 0;  1 0.5 0;  1 0.5 0; 1 0.5 0; 1 0.5 0;1 1 0; 1 1 0;1 1 0;  1 1 0;  1 1 0; 0 0 0];
    hm = HeatMap(rxnsOfInterest,'ColumnLabels', modelNames,'RowLabels',rxnInterestNames,'Colormap',redbluecmap, 'Symmetric', false, 'DisplayRange', 100); %maxFluxUnits/3
    colormap(hm,mymap);
elseif maxFluxUnits ~= 0 && minFluxUnits<0 && essentialityRange(1)<=0 
    mymap = [1 1 1; 1 0 0;  1 0.5 0;  1 0.5 0; 1 0.5 0; 1 0.5 0;1 1 0; 1 1 0;1 1 0;  1 1 0;  1 1 0; 0 0 0];
    hm = HeatMap(rxnsOfInterest,'ColumnLabels', modelNames,'RowLabels',rxnInterestNames,'Colormap',redbluecmap, 'Symmetric', false, 'DisplayRange', 100); %maxFluxUnits/3
    colormap(hm,mymap);    
elseif maxFluxUnits ~= 0 && minFluxUnits==0 && essentialityRange(1)==0
    mymap = [1 0 0;  1 0.5 0;  1 0.5 0; 1 0.5 0; 1 0.5 0;1 1 0; 1 1 0;1 1 0;  1 1 0;  1 1 0; 0 0 0];
    hm = HeatMap(rxnsOfInterest,'ColumnLabels', modelNames,'RowLabels',rxnInterestNames,'Colormap',redbluecmap, 'Symmetric', false, 'DisplayRange', 100); %maxFluxUnits/3
    colormap(hm,mymap);
elseif maxFluxUnits ~= 0 && essentialityRange(1)>=0
    mymap = [ 1 0.5 0;  1 0.5 0; 1 0.5 0; 1 0.5 0;1 1 0; 1 1 0;1 1 0;  1 1 0;  1 1 0; 0 0 0];
    hm = HeatMap(rxnsOfInterest,'ColumnLabels', modelNames,'RowLabels',rxnInterestNames,'Colormap',redbluecmap, 'Symmetric', false, 'DisplayRange', 100); %maxFluxUnits/3
    colormap(hm,mymap);
else
    fprintf('\n Attention: All non-essential reactions have flux above the threshold \n')
end


% cg = clustergram(essentialInterest,'ColumnLabels', modelNames2,'RowLabels',rxnInterest,'Colormap',redbluecmap);
% colormap(cg,mymap);


end

