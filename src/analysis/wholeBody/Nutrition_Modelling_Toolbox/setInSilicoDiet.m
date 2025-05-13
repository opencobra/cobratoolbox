function setInSilicoDiet(dietToSet, varargin)
% Code to set either the dietary flux vector as a diet or the food items
% themselves on WBMs. The WBMs can either be the default Harvey/Harvetta or
% custom ones. The models are saved in specific folders and there is
% possibility to test the feasibility on the given diets for these models.
%
% Usage:
%   setInSilicoDiet(dietToSet, varargin)
% Inputs:
%   dietToSet:          Path to the file with the diets that need to be
%                       created. consist of column "originalName" where the
%                       orignal food names are set. "foodName" the name of
%                       the database alternatives. "databaseID" the ID of
%                       the fooditem in their database. "databaseUsed"
%                       which database was used to find that database
%                       alternative. Each column after is a diet where the
%                       values in gram show the food items consumed for
%                       each diet.   
% Optional input:
%   metadataPath:       Path to the metadata file path. Should contain the
%                       columns "ID", "sex" and "Diet". Defaults to ''.
%   outputDir:          Path to the directory where the results should be
%                       stored. Defaults to ''.
%   constrainFoodWBM:   Boolean, indicates if food item exchange reactions
%                       and food item breakdown reactions should be added
%                       to the WBMs. The grams of food item consumed are
%                       then used as exchange flux of the food items. This
%                       should only be used to make queries on the
%                       composition of food items on the diet as the models
%                       become bulky. Works well with the nutrition
%                       algorithm. Defaults to false.
%   constrainFluxWBM:   Boolean, indicates if the the diet flux vector
%                       should be set on the WBMs.  Defaults to true.
%   checkFeasibility:   Boolean, indicates if WBMs should be checked for
%                       feasibility. Defaults to true.
%   wbmVersion:         The version of a specific WBM to use. Do not start
%                       with '_'. Defaults to '' and thus latest version is
%                       loaded.
%   pathToWbms:         If non standard Harvey Harvetta models are used
%                       indicate where they are stored. If there is a
%                       changed general female and male model ensure that
%                       _male and _female are present in the filename.
%                       Otherwise ensure that sample ID is present in the
%                       name that corresponds with the metadata.
%
% Example:
%   setInSilicoDiet(dietToSet, 'checkFeasibility', false)
% Note:
%   The tutorial folder on the COBRA toolbox provides various template
%   files with the structure of how the data should be formatted. Please
%   look there for guidance.
% .. Author - Bram Nap, 04-2025


% Parse the inputs
parser = inputParser();
parser.addRequired('dietToSet', @ischar);
parser.addParameter('metadataPath', '',@ischar);
parser.addParameter('outputDir', pwd, @ischar);
parser.addParameter('constrainFoodWBM', false,@islogical);
parser.addParameter('constrainFluxWBM', true,@islogical);
parser.addParameter('checkFeasibility', true,@islogical);
parser.addParameter('wbmVersion', '',@ischar);
parser.addParameter('pathToWbms', '', @ischar);
parser.addParameter('addStarch', false, @islogical);

parser.parse(dietToSet, varargin{:});

dietToSet = parser.Results.dietToSet;
metadataPath = parser.Results.metadataPath;
outputDir = parser.Results.outputDir;
constrainFoodWBM = parser.Results.constrainFoodWBM;
constrainFluxWBM = parser.Results.constrainFluxWBM;
checkFeasibility = parser.Results.checkFeasibility;
wbmVersion = parser.Results.wbmVersion;
pathToWbms = parser.Results.pathToWbms;
addStarch = parser.Results.addStarch;

%% Obtaining the metabolite dietary fluxes

% Load in the table
dietToSet = readtable(dietToSet);
% Calculate the metabolite composition of the diets
for i = 4:size(dietToSet,2)
    % Obtain the diet specific values
    diet2Make = dietToSet(:, [1:3, i]);

    % Calculate the diet flux vector
    metFlux = getMetaboliteFlux(table2cell(diet2Make(:,[2 4])), 'databaseType',diet2Make.databaseUsed, "addStarch",addStarch);

    % If phosphate is 0 set to 10 mmol/human/day (cite) this is
    % required as without phosphate (pi) WBMs will not be feasible.
    % If phosphate is not in the diet, it will be added automatically by
    % setDietConstraints (Crook, Hally and Panteli, 2001. PMID:11448586)
    if ~isempty(metFlux(strcmpi(metFlux(:,1), 'diet_ex_pi[d]')))
        if metFlux{strcmpi(metFlux(:,1), 'diet_ex_pi[d]'),2} <= 0.1
            metFlux{strcmpi(metFlux(:,1), 'diet_ex_pi[d]'),2} = 10;
        end
    end

    % Convert the dietary flux vector to a table
    metFlux = cell2table(metFlux,"VariableNames", [{'VMHID'}; dietToSet.Properties.VariableNames(i)]);
    metFlux.(dietToSet.Properties.VariableNames{i}) = string(metFlux.(dietToSet.Properties.VariableNames{i}));

    % Merge tables togehter
    if i == 4
        dietFlux = metFlux;
    else
        dietFlux = outerjoin(dietFlux, metFlux, "MergeKeys", true, "Keys","VMHID");
    end
end
%% Setup and WBM loading

% Initialise the output directories
metConstrainedWBM = strcat(outputDir, filesep, 'fluxDietWBMs');
foodConstrainedWBM = strcat(outputDir, filesep, 'foodDietWBMs');


% If no custom WBMs are given
if isempty(pathToWbms)
    % Set variable indicating we have only 2 WBMs to work with
    only2Models = true;
    if isempty(wbmVersion)
        % If no version is given load the lastest available
        female = loadPSCMfile('Harvetta_1_04c');
        male = loadPSCMfile('Harvey_1_04c');
    else
        % If a version is given load the specific version
        female = loadPSCMfile(strcat('Harvetta_', wbmVersion));
        male = loadPSCMfile(strcat('Harvey_',wbmVersion));
    end
else
    % If a custom WBM path is given
    modelDir = what(pathToWbms).mat;
    if size(modelDir,1) == 2
        % Set variable indicating we have only 2 WBMs to work with
        only2Models = true;

        % If there are exactly two .mat files in the directory see if they
        % contain _female and _male
        femaleName = modelDir(contains(modelDir, '_female'));
        maleName = modelDir(contains(modelDir, '_male'));

        % Throw error if either no male or female .mat could be found
        if isempty(femaleName) || isempty(maleName)
            error('We could not find a male and a female model in the directory you give in pathToWbms. Please ensure both male and female WBM is present and are identified by _male and _female somewhere in the filename.')
        else
            % If male and female model could be found load them.
            female = loadPSCMfile(femaleName, modelDir);
            male = loadPSCMfile(maleName, modelDir);
        end
        % Error if only one .mat file was found.
    elseif size(modelDir,1) < 2
        error('Please have a female and male model in your directory set in pathToWbms');
    else
        % Set variable indicating we have more than 2 WBMs to work with
        only2Models = false;

        % If no metadata is provided throw error
        if isempty(metadataPath)
            error('There are more than 2 WBMs to be used in the indicated folder. Either decrease so only 2 remain (one female or one male) or provide metadata linking model ID to a specific diet')
        end
    end
end

% Load the metadata
if ~isempty(metadataPath)
    metadata = readtable(metadataPath);
end
%% Constraining with the flux values directly
% If WBMs need to be saved that are constrained with dietary flux bounds
if constrainFluxWBM
    % Make the storage directory if it does not exist yet
    if ~exist(metConstrainedWBM, "dir")
        mkdir(metConstrainedWBM);
    end

    for i = 2:size(dietFlux,2)
        disp(fprintf('Setting diet %s', string(dietFlux.Properties.VariableNames(i))))
        % Extract the diet name
        dietName = dietFlux.Properties.VariableNames(i);
        % Extract the diet with female WBM diet metabolites
        diet2Set = table2cell(dietFlux(:, [1, i]));

        % If no metadata is given make one female and one male model for each diet
        if isempty(metadataPath)
            % Initialise the filenames
            fileNameM = strcat(metConstrainedWBM, filesep, dietName, '_WBM_male.mat');
            fileNameF = strcat(metConstrainedWBM, filesep, dietName, '_WBM_female.mat');

            % Set the diet and save the model
            setFluxDietNSave(female, diet2Set,fileNameF, dietName);
            setFluxDietNSave(male, diet2Set, fileNameM, dietName);

        else
            % Obtain the sample ID
            sampleID = metadata{strcmpi(metadata{:,strcmpi(metadata.Properties.VariableNames, 'diet')},dietName), strcmpi(metadata.Properties.VariableNames, 'id')};

            for j = 1:size(sampleID)
                % Extract the sex associated with a diet
                sex = metadata{strcmpi(metadata{:,strcmpi(metadata.Properties.VariableNames, 'id')},sampleID(j)), strcmpi(metadata.Properties.VariableNames, 'sex')};
                if only2Models
                    % Set the diet on the appropriate WBMs
                    if strcmpi(sex, 'f') || strcmpi(sex, 'female')
                        % Set the filename
                        fileName = strcat(metConstrainedWBM, filesep, 'WBM_',sampleID(j), '_Diet_female.mat');
                        % Set the diet and save
                        setFluxDietNSave(female, diet2Set,fileName, dietName);

                    elseif strcmpi(sex, 'm') || strcmpi(sex, 'male')
                        % Initialise the filename
                        fileName = strcat(metConstrainedWBM, filesep, 'WBM_',sampleID(j), '_Diet_male.mat');
                        % Set the diet and save
                        setFluxDietNSave(male, diet2Set,fileName, dietName);
                    else
                        % Warning if diet was not found in the metadata
                        if isempty(sex)
                            warning("The diet name '%s' is not found in the metadata, please check", dietName)
                        else
                            % Warning if female/male or f/m notation for sex is not
                            % used
                            warning('The sex variable was not in the format female/male or f/m and is therefore not recognised. Please adjust')
                        end
                    end
                else
                    % If there are specific models for diets
                    model2Load = char(modelDir(contains(modelDir, strcat('_', sampleID(j), '_'))));
                    % Check if the model with the correct ID can be found
                    if isempty(model2Load)
                        warning('Sample ID %s is not found. Ensure that the filenames have underscores _ around the sample ID in the filename of the WBM');
                    else
                        % Load in the model
                        model2Alter = loadPSCMfile(model2Load, pathToWbms);

                        % Set the filename
                        fileName = strcat(metConstrainedWBM, filesep, strrep(model2Load, '.mat', 'fluxDiet.mat'));

                        % Set the diet and save the model
                        setFluxDietNSave(model2Alter, diet2Set, fileName, dietName);
                    end
                end
            end
        end
    end
end
%% Constraining with Food items
% Create WBMs that have the food items converting into metabolites in the
% WBM instead of setting the flux vectors. Mostly for diet modelling not
% other types of WBM modelling.
if constrainFoodWBM

    % If the output directory does not exist yet - make it
    if ~exist(foodConstrainedWBM, "dir")
        mkdir(foodConstrainedWBM);
    end

    % If no custom WBMs are to be used, alter the previously loaded gener
    if only2Models
        maleFood = setFoodRxnsWbm(male, dietToSet.databaseUsed);
        femaleFood = setFoodRxnsWbm(female, dietToSet.databaseUsed);
    end

    % Create the WBMs that have food item reactions added
    for i = 4:size(dietToSet,2)
        disp(fprintf('Setting diet %s', string(foodItemsUsed.Properties.VariableNames(end))))
        % Obtain the diet of food items that needs to be set
        foodItemsUsed = dietToSet(:, [2:3 i]);
        % Transfort the database ID and database name into the reaction ID
        % format used in the WBMs
        foodRxns = strcat('Food_EX_', foodItemsUsed.databaseID, '_', foodItemsUsed.databaseUsed);

        % Obtain the diet name
        dietName = foodItemsUsed.Properties.VariableNames(end);

        % Obtain the flux based diet
        fluxDiet = dietFlux{:,[1, i-2]};

        if isempty(metadataPath)
            % Find metabolites that should be added
            mets2AddF = findMet2Add2FoodDiet(female, fluxDiet);
            mets2AddM = findMet2Add2FoodDiet(male, fluxDiet);

            % once for male and once for female
            fileNameF = strcat(foodConstrainedWBM, filesep, dietName, '_fWBM_female.mat');
            fileNameM = strcat(foodConstrainedWBM, filesep, dietName, '_fWBM_male.mat');

            % Set diet for female model
            setFoodItemNSave(femaleFood, foodRxns, foodItemsUsed, mets2AddF, fileNameF)
            % Set diet for male model
            setFoodItemNSave(maleFood, foodRxns, foodItemsUsed, mets2AddM, fileNameM)

        else
            % Obtain sample ID
            sampleID = metadata{strcmpi(metadata{:,strcmpi(metadata.Properties.VariableNames, 'diet')},dietName), strcmpi(metadata.Properties.VariableNames, 'id')};
            % If there is one general male or female model to use
            for j = 1:size(sampleID)
                if only2Models
                    % Obtain the sex associated with the diet
                    sex = metadata{strcmpi(metadata{:,strcmpi(metadata.Properties.VariableNames, 'id')},sampleID(j)), strcmpi(metadata.Properties.VariableNames, 'sex')};
    
                    % Set the diet on the appropriate WBMs
                    if strcmpi(sex, 'f') || strcmpi(sex, 'female')
                        % Find metabolites that should be added
                        mets2AddF = findMet2Add2FoodDiet(female, fluxDiet);
    
                        % Set the filename
                        fileName = strcat(foodConstrainedWBM, filesep, 'fWBM_',sampleID(j), '_', dietName, '_female.mat');
    
                        % Set the food items and save
                        setFoodItemNSave(femaleFood, foodRxns, foodItemsUsed, mets2AddF, fileName)
                    elseif strcmpi(sex, 'm') || strcmpi(sex, 'male')
                        % Save the model
                        % Find metabolites that should be added
                        mets2AddM = findMet2Add2FoodDiet(male, fluxDiet);
    
                        fileName = strcat(foodConstrainedWBM, filesep, 'fWBM_',sampleID(j),'_', dietName,'_male.mat');
                        setFoodItemNSave(maleFood, foodRxns, foodItemsUsed, mets2AddM, fileName)
                    else
                        % Warning if diet was not found in the metadata
                        if isempty(sex)
                            warning("The diet name '%s' is not found in the metadata, please check", dietName)
                        else
                            % Warning if female/male or f/m notation for sex is not
                            % used
                            warning('The sex variable was not in the format female/male or f/m and is therefore not recognised. Please adjust')
                        end
                    end
                else
                    % If there are specific models for diets
                    model2Load = modelDir(contains(modelDir, strcat('_', sampleID(j), '_')));
                    % Check if the model with the correct ID can be found
                    if isempty(model2Load)
                        warning('Sample ID %s is not found. Ensure that the filenames have underscores _ around the sample ID in the filename of the WBM');
                    else
                        % Load in the model
                        model2Alter = loadPSCMfile(model2Load, pathToWbms);
    
                        % Find metabolites that should be added
                        mets2Add = findMet2Add2FoodDiet(model2Alter, fluxDiet);
    
                        % Prepare the WBM for food items
                        foodModel = setFoodRxnsWbm(model2Alter, dietToSet.databaseUsed);
    
                        % Set the filename
                        fileName = strcat(foodConstrainedWBM, filesep,strrep(model2Load, '.mat', 'foodItem.mat'));
                        % Set the diet and save
                        setFoodItemNSave(foodModel, foodRxns, foodItemsUsed, mets2Add, fileName)
                    end
                end
            end
        end
    end
end
%% Feasibility checks
% If the feasibility of the models needs to be checked
if checkFeasibility
    if constrainFoodWBM
        ensureWBMfeasibility(foodConstrainedWBM);
    end

    if constrainFluxWBM
        ensureWBMfeasibility(metConstrainedWBM);
    end
end
end

function mets2Add = findMet2Add2FoodDiet(model, diet)
% Code that finds the metabolites that are added additionally by
% setDietConstraints.m. This is needed for the food item diet as it does
% not have these required but uncaptured metabolites required for model
% feasibility.
%
% Usage:
%   mets2Add = findMet2Add2FoodDiet(model, diet)
% Inputs:
%   model:          a WBM model
%   diet:           The dietary flux vector (dietary metabolites) that are
%                   used to set the diet. It is the same a total of the 
%                   breakdown of the the food items in the food item set
%                   WBMs
% Output:
%   mets2Add:       A cell array of dietary metabolites exchange reactions 
%                   and their lower bounds that are missing from the diet.
% Example:
%   mets2Add = findMet2Add2FoodDiet(model, diet)
% .. Author - Bram Nap, 04-2025

% Find which reaction are not set with the diet
[~, idx] = setdiff(diet(:,1), model.rxns(contains(model.rxns, 'Diet_EX')));

% identify the metabolites that need to be added
diet(idx,:) = [];

% Set as diet
model = setDietConstraints(model, diet);

% Find the new bounds of the dietary reactions
newDietBounds = model.lb(findRxnIDs(model, diet(:,1)));

% Check which dietary reactions have a larger change than 1.2 as is
% implemented by setDietConstraints
bigMultFactorBounds = (newDietBounds./str2double(diet(:,2))) < -1.2;

% Extract dietary mets with a big change to add to the toAdd metabolite
% list
dietMets2Add = [diet(bigMultFactorBounds), newDietBounds(bigMultFactorBounds)];

% Extract all dietary reactions in the model
mets2Add = [model.rxns(contains(model.rxns, 'Diet_EX_')), num2cell(model.lb(contains(model.rxns, 'Diet_EX_')))];

% Find which reaction are not set with the diet
[~, idx] = setdiff(mets2Add(:,1), diet(:,1));

% identify the metabolites that need to be added
mets2Add = mets2Add(idx,:);

% Add the additional dietary mets to the mets2Add list
mets2Add = [mets2Add; dietMets2Add];

% If the value of phosphate in the diet is set to 10 mmol/day or almost
% only has traces
if str2double(diet(strcmp(diet(:,1),'Diet_EX_pi[d]'),2)) <= 0.1 || str2double(diet(strcmp(diet(:,1),'Diet_EX_pi[d]'),2)) == 10 
    % If not yet in the list of mets to add, add phosphate exchange
    mets2Add(end+1,:) = {'Diet_EX_pi[d]', 10};
end
end

function setFoodItemNSave(model, foodRxns, dietUsed, mets2Add, fileName)
% Code that sets the flux of the food item exchange reactions. Note that
% the flux value for these is in g/human/day and NOT in mmol/human/day. The
% models are then saved.
%
% Usage:
%   setFoodItemNSave(model, foodRxns, dietUsed, mets2Add, fileName)
% Inputs:
%   model:      A wbm model
%   foodRxns:   A cell array of the IDs food items that are consumed
%              
%   dietUsed:   A cell array of the consumed weight of food items in grams.
%   mets2Add:   A cell array of missing dietary components required for WBM
%               feasibility. obtained by findMet2Add2FoodDiet
%   fileName:   The name of how the model should be saved.
%
% Example:
%   setFoodItemNSave(model, foodRxns, dietUsed, mets2Add, fileName)
% .. Author - Bram Nap, 04-2025

% If there is no metadata, set the diet on both WBMs
model = changeRxnBounds(model, foodRxns, -1*dietUsed{:,end}, 'b');
% Update the setupInfo field
model.SetupInfo.dietName = string(fileName);
model.SetupInfo.diet = dietUsed;
model.SetupInfo.dietAddition = mets2Add;

% Set additional metabolite contraints needed for feasibility
model = changeRxnBounds(model, mets2Add(:,1), mets2Add(:,2), 'l');

% Save the diet constrained food WBMs
save(string(fileName), '-struct', 'model');
end

function setFluxDietNSave(model, diet, fileName, dietName)
% Code that sets the dietary flux vector on the WBMs and save them.
%
% Usage:
%   setFluxDietNSave(model, diet, fileName)
% Inputs:
%   model:      A WBM model        
%   diet:       A nx2 cell array with dietary reactions and their
%               corresponding flux values
%   fileName:   The name of how the WBM should be saved as.
% Example:
%   setFluxDietNSave(model, diet, fileName)
% .. Author - Bram Nap, 04-2025

% Remove metabolites in the diet that cannot be consumed by the WBMs
modelDietRxns = model.rxns(contains(model.rxns, 'Diet_EX_'));
[~, metIdx, ~] = intersect(diet(:,1), modelDietRxns);
diet = diet(metIdx, :);

% Convert the numeric values to a string
diet(str2double(string(diet(:,2))) == 0,:) = [];
% Set the diet
model = setDietConstraints(model, diet);
% Update the setupInfo field
model.SetupInfo.dietName = string(dietName);
% Save the model
save(string(fileName), '-struct', 'model');
end