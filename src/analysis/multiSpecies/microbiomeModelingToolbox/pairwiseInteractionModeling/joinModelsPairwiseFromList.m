function joinModelsPairwiseFromList(modelList, modelFolder, varargin)
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
% creation.  If merging of genes is desired, please set the input parameter
% mergeGenes to true. If you are not using AGORA/AGORA2 reconstructions,
% you may need to define the biomass objective functions manually.
%
% Please note: the function takes a cell array with the names of the 
% COBRA models to join as well as the name of the folder where they are 
% located at as the inputs, e.g.:
% joinModelsPairwiseFromList(modelList,'/Users/almut.heinken/Documents/AGORA');
%
% USAGE:
%    joinModelsPairwiseFromList(modelList,  modelFolder, varargin)
%
% INPUTS:
%    modelList:           Cell array with names of reconstruction structures to be
%                         joined
%    modelFolder:         Path to folder with COBRA model structures to be joined
%
% OPTIONAL INPUTS:
%    biomasses:           Cell array containing names of biomass objective
%                         functions of models to join. Needs to be the same
%                         length as modelList.
%    c:                   Coupling factor by which reactions in each joined model are
%                         coupled to its biomass reaction (default: 400)
%    u:                   Threshold representing minimal flux allowed when flux
%                         through biomass reaction in zero (default: 0)
%    mergeGenes:          If true, genes in the joined models are merged and included
%                         in the joined model structure (default: false)
%    remCyclesFlag:       If true, futile cycles that may arise from joining the 
%                         models are removed (default: false). Recommended
%                         if AGORA/AGORA2 reconstructions are used, does not work 
%                         with other namespaces.
%    numWorkers:          Number of workers in parallel pool if desired
%    pairwiseModelFolder: Folder where pairwise models will be saved
%
% .. Author:
%      - Almut Heinken, 02/2018
%      - Almut Heinken, 02/2020: Inputs and outputs changed for more efficient computation
%      - Almut Heinken, 12/2022: Added an optional input to manually define biomass
%                                objective functions for non-AGORA reconstructions     

parser = inputParser();  % Define default input parameters if not specified
parser.addRequired('modelList', @iscell);
parser.addRequired('modelFolder', @ischar);
parser.addParameter('biomasses', {}, @(x) iscell(x))
parser.addParameter('c', 400, @(x) isnumeric(x))
parser.addParameter('u', 0, @(x) isnumeric(x))
parser.addParameter('numWorkers', 0, @(x) isnumeric(x))
parser.addParameter('pairwiseModelFolder', pwd, @(x) ischar(x))
parser.addParameter('mergeGenesFlag', false, @(x) isnumeric(x) || islogical(x))
parser.addParameter('remCyclesFlag', false, @(x) isnumeric(x) || islogical(x))
parser.parse(modelList, modelFolder, varargin{:})

modelList = parser.Results.modelList;
modelFolder = parser.Results.modelFolder;
biomasses = parser.Results.biomasses;
c = parser.Results.c;
u = parser.Results.u;
numWorkers = parser.Results.numWorkers;
mergeGenesFlag = parser.Results.mergeGenesFlag;
remCyclesFlag = parser.Results.remCyclesFlag;
pairwiseModelFolder = parser.Results.pairwiseModelFolder;

% initialize COBRA Toolbox and parallel pool
global CBT_LP_SOLVER
if isempty(CBT_LP_SOLVER)
    initCobraToolbox
end
solver = CBT_LP_SOLVER;

if numWorkers>0 && ~isempty(ver('parallel'))
    % with parallelization
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(numWorkers)
    end
end
environment = getEnvironment();

pairedModelInfo = {};
cnt = 1;

% check if any pairwise models already exist in output folder
dInfo = dir(pairwiseModelFolder);
existingModels={dInfo.name};
existingModels=existingModels';
existingModels(find(strcmp(existingModels(:,1),'.')),:)=[];
existingModels(find(strcmp(existingModels(:,1),'..')),:)=[];

% then join all models in modelList
dInfo = dir(modelFolder);
models={dInfo.name};
models=models';

% get biomass reactions for each microbe if not provided
if isempty(biomasses)
    for i = 1:length(modelList)
        findModID = find(strncmp(models,modelList{i},length(modelList{i})));
        if ~isempty(findModID)
            if any(contains(models{findModID,1},{'.mat','.sbml','.xml'}))
                model=readCbModel([modelFolder filesep models{findModID,1}]);
            else
                error('No model in correct format found in folder!')
            end
        else
            error('Model to load not found in folder!')
        end
        if ~isempty(find(strncmp(model.rxns, 'bio', 3)))
            biomasses{i} = model.rxns{find(strncmp(model.rxns, 'bio', 3)),1};
        else
            error('Please define the biomass objective functions for each model manually through the biomasses input parameter.')
        end
    end
end

% test if biomasses are correctly defined
if length(biomasses) ~= length(modelList)
    error('Length of biomasses input is not equal to modelList input!')
end

inputModels={};
for i = 1:length(modelList)
    
    % Load the reconstructions to be joined
    % workaround to also allow SBML files
    findModID = find(strncmp(models,modelList{i},length(modelList{i})));
    if ~isempty(findModID)
        if any(contains(models{findModID,1},{'.mat','.sbml','.xml'}))
            model=readCbModel([modelFolder filesep models{findModID,1}]);
        else
            error('No model in correct format found in folder!')
        end
    else
        error('Model to load not found in folder!')
    end

    % test if biomass is correctly defined
    if isempty(find(strcmp(model.rxns, biomasses{i})))
        error('Defined biomass objective functions are not correct!')
    end

    inputModels{i}=model;
    for k = i + 1:length(modelList)
        findModID = find(strncmp(models,modelList{k},length(modelList{k})));
        if ~isempty(findModID)
            if any(contains(models{findModID,1},{'.mat','.sbml','.xml'}))
                model=readCbModel([modelFolder filesep models{findModID,1}]);
            else
                error('No model in correct format found in folder!')
            end
        else
            error('Model to load not found in folder!')
        end

        % test if biomass is correctly defined
        if isempty(find(strcmp(model.rxns, biomasses{k})))
            error('Defined biomass objective functions are not correct!')
        end

        inputModels{k}=model;
    end
    
    pairedModelsTemp = {};
    
    parfor k = i + 1:length(modelList)
        restoreEnvironment(environment);
        changeCobraSolver(solver, 'LP', 0, -1);
        
        model1 = inputModels{i};
        model2 = inputModels{k};
        models = {
            model1
            model2
            };
        modelBiomasses = {
            biomasses{i}
            biomasses{k}
            };
        nameTagsModels = {
            strcat(modelList{i}, '_')
            strcat(modelList{k}, '_')
            };
        if isempty(find(contains(existingModels,['pairedModel', '_', modelList{i}, '_', modelList{k}, '.mat'])))
            [pairedModel] = createMultipleSpeciesModel(models, modelBiomasses, 'nameTagsModels', nameTagsModels,'mergeGenesFlag', mergeGenesFlag, 'remCyclesFlag', remCyclesFlag);
            [pairedModel] = coupleRxnList2Rxn(pairedModel, pairedModel.rxns(strmatch(nameTagsModels{1, 1}, pairedModel.rxns)), strcat(nameTagsModels{1, 1}, biomasses{i}), c, u);
            [pairedModel] = coupleRxnList2Rxn(pairedModel, pairedModel.rxns(strmatch(nameTagsModels{2, 1}, pairedModel.rxns)), strcat(nameTagsModels{2, 1}, biomasses{k}), c, u);
            pairedModelsTemp{k} = pairedModel;
        else
            pairedModelsTemp{k} = {};
        end
    end
    
    for k = i + 1:length(modelList)
        % keep track of the generated models and populate the output file with
        % information on joined models
        pairedModelInfo{cnt, 1} = ['pairedModel', '_', modelList{i}, '_', modelList{k}, '.mat'];
        pairedModelInfo{cnt, 2} = modelList{i};
        pairedModelInfo{cnt, 3} = biomasses{i};
        pairedModelInfo{cnt, 4} = modelList{k};
        pairedModelInfo{cnt, 5} = biomasses{k};
        % save file regularly
        if floor(cnt/1000) == cnt/1000
            save([pairwiseModelFolder filesep 'pairedModelInfo'],'pairedModelInfo');
        end
        
        if isempty(find(contains(existingModels,['pairedModel', '_', modelList{i}, '_', modelList{k}, '.mat'])))
            pairedModel=pairedModelsTemp{k};
            save([pairwiseModelFolder filesep pairedModelInfo{cnt,1}],'pairedModel');
        end
        cnt = cnt + 1;
    end
end

save([pairwiseModelFolder filesep 'pairedModelInfo'],'pairedModelInfo');

end