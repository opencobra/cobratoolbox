function [essentialRxn4Models, dataStruct] = essentialRxn4MultipleModels(allModels, objFun)
% Performs single reactions deletions across multiple models and identifies which reactions
% have variable essentiality across all models for the chosen objective function
% (eg. it identifies reactions whos deletion would result in a zero flux through ATP
% consumption reaction - ATPM).
%
% USAGE:
%
%    [essentialRxn4Models, dataStruct] = essentialRxn4MultipleModels(allModels, objFun)
%
% INPUTS:
%    allModels:    directory of the structure with multiple COBRA model structures
%    objFun:       string with objective function reaction (e.g. 'ATPM')
%
% OUTPUT:
%    essentialRxn4Models:    Table with reaction fluxes (within the objective function reaction)
%                            after single deletion of model reaction (rows) across models (columns)
%    dataStruct:             Structure with all models
%
% EXAMPLE:
%
%    [essentialRxn4Models, dataStruct] = essentialRxn4MultipleModels(allModels, 'ATPM')
%
% .. Authors:
%	    - Dr. Miguel A.P. Oliveira, 13/11/2017, Luxembourg Centre for Systems Biomedicine, University of Luxembourg
%   	- Diana C. El Assal-Jordan, 13/11/2017, Luxembourg Centre for Systems Biomedicine, University of Luxembourg

if isstr(allModels)  % Locate COBRA models in a directory and load them into a structure:
    modelsDir = allModels;
    clear allModels
    allModelFilenames = dir(strcat(modelsDir, '/', '*.mat'));
    for i = 1:size(allModelFilenames, 1)
        % Extract model name from filenames
        match = {'.mat', '.'};
        str = allModelFilenames(i).name;
        for j = 1:size(match, 2)
            str = strrep(str, match{j}, {''});
        end
        newFilename{1, i} = horzcat(str{1}, '_model');

        loadedFile = load(strcat(modelsDir, '/', allModelFilenames(i).name));
        fields = fieldnames(loadedFile);
        model = loadedFile.(fields{1, 1});
        allModels.(newFilename{1, i}) = model;
    end
end

% Load structure with models and perform singleRxnDeletion in all COBRA models
modelNames = fieldnames(allModels);
numModels = size(modelNames, 1);
sumRxnSubsystems = {};

for j = 1:numModels
    model = changeObjective(allModels.(modelNames{j}), objFun);
    fprintf(strcat(' \nAnalysing model: \n', modelNames{j}, '\n'))

    [~, grRateKO, ~, ~, delRxn, fluxSolution] = singleRxnDeletion(model);

    delRxnSubsystems(:, 1) = model.rxns;
    % delRxnSubsystems(:,2) = model.subSystems;
    test = setdiff(model.rxns, delRxn);
    if ~isempty(test)
        fprintf('Warning: different list of reactions found for:')
        modelNames{j};
    end
    sumRxnSubsystems = vertcat(sumRxnSubsystems, delRxnSubsystems);
    dataStruct.(modelNames{j}).rxnSubsystems = delRxnSubsystems;
    dataStruct.(modelNames{j}).grRateKO = grRateKO;
    dataStruct.(modelNames{j}).fluxSolution = fluxSolution;
    clear model
    clear delRxnSubsystems
end

% Identify unique reactions across all models
uniqueRxns = unique(sumRxnSubsystems(:, 1));
allRxns = {};
for i = 1:size(uniqueRxns, 1)
    allRxns(i, 1) = sumRxnSubsystems(find(strcmp(uniqueRxns{i, 1}, sumRxnSubsystems(:, 1)), 1), :);
end

% Build essential reaction table for all models
essentialRxn4Models = cell2table(allRxns, 'VariableNames', {'rxn'});  % ,'subsystem'

for j = 1:size(modelNames, 1)
    for i = 1:size(allRxns, 1)
        idx = find(strcmp(allRxns{i, 1}, dataStruct.(modelNames{j}).rxnSubsystems(:, 1)));
        if idx ~= 0
            essentialRxn4Models.(modelNames{j}){i} = dataStruct.(modelNames{j}).grRateKO(idx, 1);
        else
            essentialRxn4Models.(modelNames{j}){i} = 'NotIncluded';
        end
    end
end

end
