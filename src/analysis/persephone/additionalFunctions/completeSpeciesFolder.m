function completeSpeciesFolder(agoraPath, panPath)
% Some strains in AGORA2 only have one strain. These strains are not moved to the 
% pan model folder, resulting in some soecies not being captured in the
% models. By converting the strain reconstructions with only a single
% strain to the species folder, you can solve this problem.
%
% USAGE:
%
%   completeSpeciesFolder(strainPath, panSpeciesPath)
%
% INPUTS:
%    strainPath     Path to folder with strain reconstructions
%    panSpeciesPath Path to folder with pan species models
%
% .. Author
%       - Tim Hensen: 03/2024

% Step 1: Remove all strain indications in the AGORA2 database

% Get strains
strains = what(agoraPath).mat;

% Find strains that are already written in species format
species = strains;
indices = cellfun(@(x) sum(x == '_') == 1, species);
species{indices} = append(species{indices},'_');

% Get species names
species = string(regexp(species, '^(.*?_).*?(?=_)', 'match'));

% Step 2: Find species for which a single strain is available
[counts, groups] = groupcounts(categorical(species));
singleStrainSpecies = string(groups(counts == 1));

% Step 3: Move these strains to the species folder
index = matches(species,singleStrainSpecies);

% Copy strains with one entry to the panSpecies folder and translate strain
% name to species name
source = strcat(agoraPath, filesep, string(strains(index)));
target = strcat(panPath, filesep, 'pan', string(species(index)),'.mat');
target = replace(target,'.mat_','.mat');
arrayfun(@(x,y) copyfile(x,y), source, target)

% Load example species model
panModelPath = what('panSpecies');
modelExample = readCbModel([panModelPath.path filesep char(panModelPath.mat(1))]);
fieldsToKeep = fieldnames(modelExample);

% Alter strains so that they have panBiomass function and ensure that they
% can be verified by the readCbModel function.

% Set up parallel pool
numWorkers = floor(feature('numcores')*0.9);
% initialize parallel pool
if numWorkers > 0
    % with parallelization
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(numWorkers)
    end
end

parfor i = 1:length(target)
    i
    model =load(target(i));
    model = model.(string(fieldnames(model)));
    fieldsModel = fieldnames(model);
    % Remove fields
    fieldsToRemove = setdiff(fieldsModel,fieldsToKeep);
    model = rmfield(model,fieldsToRemove);

    % Rename biomass reactions
    model.rxns(~cellfun(@isempty,(regexp(model.rxns,'^biomass*')))) = {'biomassPan'};

    % Set modelID
    model.description = struct()
    model.description.date = datetime;
    model.description.name = model.modelID;
    model.modelID = 'model';
    parsave(target(i), model)
end
end