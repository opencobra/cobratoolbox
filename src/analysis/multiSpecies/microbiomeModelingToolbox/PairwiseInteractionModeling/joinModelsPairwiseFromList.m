function [pairedModels, pairedModelInfo] = joinModelsPairwiseFromList(modelList, inputModels, varargin)
% This function joins a list of microbial genome-scale reconstructions in
% all combinations. Models are not paired with themselves and pairs are
% only created once (model1+model2 = model2+model1). The reactions in each
% joined reconstruction structure receive a suffix (entered as input
% parameter model list).
% Coupling constraints are created in which the flux through all reactions
% of each individual microbe is coupled to the flux through its own biomass
% objective function. By default, coupling constraints are implemented with
% a coupling factor c of 400 and a threshold u of 0. The coupling
% parameters can be changed by entering the input parameters c and u.
% By default, the gene-protein-reaction associations of the joined models
% are not merged as the gene associations are not needed for the simulation
% of pairwise interactions and significantly slow down pairwise model
% creation.  If merging of genes is desired, please set the input
% parameter mergeGenes to true.
%
% USAGE:
%     [pairedModels, pairedModelInfo] = joinModelsPairwiseFromList(modelList, inputModels, varargin)
%
% INPUTS:
%     modelList:          Cell array with names of reconstruction structures to be
%                         joined
%     inputModels:        Array with COBRA model structures to be joined (needs to
%                         have same length as modelList)
%
% OPTIONAL INPUTS:
%     c:                  Coupling factor by which reactions in each joined model are
%                         coupled to its biomass reaction (default: 400)
%     u:                  Threshold representing minimal flux allowed when flux
%                         through biomass reaction in zero (default: 0)
%     mergeGenes:         If true, genes in the joined models are merged and included
%                         in the joined model structure (default: false)
%     numWorkers:         Number of workers in parallel pool if desired
%
% OUTPUTS:
%     pairedModels:       Structue containing created pairwise models in all
%                         combinations
%     pairedModelInfo:    Table with information on created pairwise models
%
% .. Author:
%      - Almut Heinken, 02/2018

parser = inputParser();  % Define default input parameters if not specified
parser.addRequired('modelList', @iscell);
parser.addRequired('inputModels', @iscell);
parser.addParameter('c', 400, @(x) isnumeric(x))
parser.addParameter('u', 0, @(x) isnumeric(x))
parser.addParameter('numWorkers', 0, @(x) isnumeric(x))
parser.addParameter('mergeGenesFlag', false, @(x) isnumeric(x) || islogical(x))

parser.parse(modelList, inputModels, varargin{:})

modelList = parser.Results.modelList;
inputModels = parser.Results.inputModels;
c = parser.Results.c;
u = parser.Results.u;
numWorkers = parser.Results.numWorkers;
mergeGenesFlag = parser.Results.mergeGenesFlag;

pairedModelInfo = {};
cnt = 1;

% then join all models in modelList
for i = 1:size(modelList, 1)
    if numWorkers > 0
        % with parallelization
        poolobj = gcp('nocreate');
        if isempty(poolobj)
            parpool(numWorkers)
        end
        pairedModelsTemp = {};
        parfor k = i + 1:size(modelList, 1)
            model1 = inputModels{i};
            model2 = inputModels{k};
            models = {
                model1
                model2
            };
            nameTagsModels = {
                strcat(modelList{i}, '_')
                strcat(modelList{k}, '_')
            };
            [pairedModel] = createMultipleSpeciesModel(models, 'nameTagsModels', nameTagsModels);
            [pairedModel] = coupleRxnList2Rxn(pairedModel, pairedModel.rxns(strmatch(nameTagsModels{1, 1}, pairedModel.rxns)), strcat(nameTagsModels{1, 1}, model1.rxns(find(strncmp(model1.rxns, 'biomass', 7)))), c, u);
            [pairedModel] = coupleRxnList2Rxn(pairedModel, pairedModel.rxns(strmatch(nameTagsModels{2, 1}, pairedModel.rxns)), strcat(nameTagsModels{2, 1}, model2.rxns(find(strncmp(model2.rxns, 'biomass', 7)))), c, u);
            pairedModelsTemp{k} = pairedModel;
        end
        for k = i + 1:size(modelList, 1)
            % keep track of the generated models and populate the output file with
            % information on joined models
            model1 = inputModels{i};
            pairedModelInfo{cnt, 1} = strcat('pairedModel', '_', modelList{i}, '_', modelList{k}, '.mat');
            pairedModelInfo{cnt, 2} = modelList{i};
            pairedModelInfo{cnt, 3} = model1.rxns(find(strncmp(model1.rxns, 'biomass', 7)));
            model2 = inputModels{k};
            pairedModelInfo{cnt, 4} = modelList{k};
            pairedModelInfo{cnt, 5} = model2.rxns(find(strncmp(model2.rxns, 'biomass', 7)));
            pairedModels{cnt, 1} = pairedModelsTemp{k};
            cnt = cnt + 1;
        end
    else
        % without parallelization
        for j = i + 1:size(modelList, 1)
            model1 = inputModels{i};
            model2 = inputModels{j};
            models = {
                model1
                model2
            };
            nameTagsModels = {
                strcat(modelList{i}, '_')
                strcat(modelList{j}, '_')
            };
            [pairedModel] = createMultipleSpeciesModel(models, 'nameTagsModels', nameTagsModels);
            [pairedModel] = coupleRxnList2Rxn(pairedModel, pairedModel.rxns(strmatch(nameTagsModels{1, 1}, pairedModel.rxns)), strcat(nameTagsModels{1, 1}, model1.rxns(find(strncmp(model1.rxns, 'biomass', 7)))), c, u);
            [pairedModel] = coupleRxnList2Rxn(pairedModel, pairedModel.rxns(strmatch(nameTagsModels{2, 1}, pairedModel.rxns)), strcat(nameTagsModels{2, 1}, model2.rxns(find(strncmp(model2.rxns, 'biomass', 7)))), c, u);
            % keep track of the generated models and populate the output file with
            % information on joined models
            pairedModelInfo{cnt, 1} = strcat('pairedModel', '_', modelList{i}, '_', modelList{j}, '.mat');
            pairedModelInfo{cnt, 2} = modelList{i};
            pairedModelInfo{cnt, 3} = model1.rxns(find(strncmp(model1.rxns, 'biomass', 7)));
            pairedModelInfo{cnt, 4} = modelList{j};
            pairedModelInfo{cnt, 5} = model2.rxns(find(strncmp(model2.rxns, 'biomass', 7)));
            pairedModels{cnt, 1} = pairedModel;
            cnt = cnt + 1;
        end
    end
end
