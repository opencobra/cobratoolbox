function [ essentialRxn4Models, essential] = essentialRxn4MultipleModels(modelsDir, objFun, solver)

%essentialRxn4MultipleModels.m
%This funtion allows us to perform single reactions deletions to identify 
%essential ones that are required for ATP generation. This means that these essential
%reactions would carry a zero flux when optimising the ATP consumption
%reaction (ATPM).
%
%by Dr. Miguel A.P. Oliveira{1} & Diana C. El Assal-Jordan{1}

%{1} Luxembourg Centre for Systems Biomedicine, University of Luxembourg,
%7 avenue des Hauts-Fourneaux, Esch-sur-Alzette, Luxembourg.

% 13/11/2017
% #########################################################\

%% Example inputs:
% % Structure-specific models with sample-cutoff 50%:
% modelsDir = '/hdd/work/sbgCloud/programReconstruction/projects/brainMetabolism/results/modelGeneration/models/cutoff_50/';
% addpath(modelsDir);
% 
% % Objective function to be used:
% objFun = 'ATPM';

%% Locate COBRA models
initCobraToolbox
changeCobraSolver(solver)

allModels = dir(strcat(modelsDir,'*.mat'));
numModels = size(allModels,1); 
sumRxnSubsystems = {};

%% Load and perform singleRxnDeletion in all COBRA models

for j=1:numModels
    match = {'_','.mat'};
    filename = erase(allModels(j).name, match);
    loadedFile = load(allModels(j).name);
    fields = fieldnames(loadedFile);
    model = loadedFile.(fields{1,1});
    model = changeObjective(model, objFun);
    fprintf(strcat(filename,'\n'))
    [~ , grRateKO, ~ , ~ , delRxn, fluxSolution] = singleRxnDeletion(model);
    
    delRxnSubsystems(:,1) = model.rxns;
    delRxnSubsystems(:,2) = model.subSystems;
    test = setdiff(model.rxns,delRxn);
    if ~isempty(test)
        fprintf ('Warning: different list of reactions found')
        filename;
    end
    sumRxnSubsystems = vertcat(sumRxnSubsystems,delRxnSubsystems);
    dataStruct.(filename).rxnSubsystems = delRxnSubsystems;
    dataStruct.(filename).grRateKO = grRateKO;
    dataStruct.(filename).fluxSolution = fluxSolution;
    clear model
    clear delRxnSubsystems
end

% Identify unique reactions across models
uniqueRxns = unique(sumRxnSubsystems(:,1));
for i=1:size(uniqueRxns,1)
    allRxns(i,1:2) = sumRxnSubsystems(find(strcmp(uniqueRxns{i,1},sumRxnSubsystems(:,1)),1),:);
end

% Find essential reaction accross all models
essentialRxn4Models = cell2table(allRxns, 'VariableNames',{'rxn','subsystem'});
field = fieldnames(dataStruct);


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
            essential(i,j) = -100;            
        end
    end
end

end

