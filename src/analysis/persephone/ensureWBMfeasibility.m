function [dietInfo, dietGrowthStats] = ensureWBMfeasibility(mWBMPath, varargin)
% This function checks for the WBMs in the specified mWBMPath to grow on the
% given diet, finds a diet that makes all WBMs feasible and propagates this
% diet onto the models. The functions works as follows:
% 1) Load the WBMs from the directory and test which models are feasible on
% the diet.
% 2) If any WBM is not feasible, collect all infeasible WBMs, open all diet
% reactions, and test if the WBMs can grow on any diet. If one or more WBMs
% cannot grow when opening all diet reactions, the statistics are
% collected and the function stops. The user will need to debug the WBMs
% manually.
% 3) If all previously infeasible WBMs can grow when all diet reactions are
% opened,missing diet components are searched using getMissingDietModelHM.
% If getMissingDietModelHM cannot find a diet after one function call, this
% function is run again until a hard limit of 10 iterations is reached. If
% this limit is reached, no feasible diet can be found for all models and
% the user will need to manually debug the infeasible models. If missing
% diet components are found in one WBMs, these component are automatically propagated
% to the other WBMs infeasible on the original diet before searching for
% more missing diet components
% 4) If a new diet is found for which all previously infeasible WBMs can grow,
% the updated diet is propagated to all models in the mWBMPath.
% 5) The updated diet is stored as an output variable for this function and
% for each model, its feasibility on the original and updated diet is
% recorded.
%
% USAGE:
%       [dietInfo, dietGrowthStats] = ensureHMfeasibility(mWBMPath, Diet)
%
% INPUTS
% mWBMPath           Path to directory where the HM models are saved
% Diet                  Diet option: 'EUAverageDiet' (default)
%
% OUTPUTS
% dietInfo              Structured variable containing the missing diet
%                       components and the updated diet propagated to all models.
%                       This variable is empty if no updated diet could be found.
% dietGrowthStats       Table indicating which WBMs could initially not grow on
%                       the diet, which WBMs could not grow on any diet,
%                       and which WBMs could not grow on an updated diet.
%
% Authors:
%   - Tim Hensen, 2024
%   - Bram Nap, 07-2025 remove parfor functionality. Time save is not
%   massive and allows the function to be used for other purposes besides
%   Persephone.

% Define default parameters if not defined
parser = inputParser();
parser.addRequired('mWBMPath', @ischar);

parser.addParameter('Diet', 'EUAverageDiet', @ischar);
parser.addParameter('solver', '', @ischar);
% Not used but leave in as old code might still use this as an input
parser.addParameter('numWorkers', 1, @isnumeric);

% Parse required and optional inputs
parser.parse(mWBMPath, varargin{:});

% Declare variables
mWBMPath = parser.Results.mWBMPath;
Diet = parser.Results.Diet;
solver = parser.Results.solver;
numWorkers = parser.Results.numWorkers;

% Initialise cobratoolbox if needed
global CBT_LP_SOLVER
if isempty(CBT_LP_SOLVER)
    initCobraToolbox
elseif isempty(CBT_LP_SOLVER)&& isempty(solver) 
    solver = glpk;
else 
    solver = CBT_LP_SOLVER;
end

% Set solver
changeCobraSolver(solver,'LP');

% % Set parellel pool - Commented out to remove parfor functionality in the
% code.
% if numWorkers > 0
%     poolobj = gcp('nocreate');
%     if isempty(poolobj)
%         parpool(numWorkers)
%     else
%         delete(poolobj);
%         parpool(numWorkers);
%     end
% end

%% STEP 1: Test which models are feasible on the given diet
disp('EnsureGrowthOnDiet -- STEP 1: Test which models are feasible on the given diet')

% Get paths to WBMs
modDir = what(mWBMPath);
paths = string(strcat(modDir.path,filesep,modDir.mat));
modelNames = string(erase(modDir.mat,'.mat'));

% Check if WBMs are stored as structured .mat files and convert them to
% structured .mat files if not. Structured .mat files allow for partial
% loading, which drastically decreases the memory load and reduced loading
% times.
checkWbmFormat(paths);

% % Save environment to variable for parallel computing
% environment = getEnvironment();

% Load WBMs and record feasibility to grow on the given diet
feasibleOnDiet = zeros(length(paths),1);
solverStatus = zeros(length(paths),1);
for i=1:length(paths) % This used to be a parfor
    % restoreEnvironment(environment);
    changeCobraSolver(solver, 'LP', 0, -1);

    % Load model
    model = loadMinimalWBM(paths(i));

    % If model is already on a diet with adjustments made this overwrites
    % that diet and can render a model where feasibility has been found to
    % be infeasible again- this should be adjusted somehow
    % Set other parameters and test growth
    model = setupWbmOnDiet(model, Diet);

    % Test feasibility
    fba = optimizeWBModel(model);
    solverStatus(i) = fba.stat;
    feasible = fba.stat==1;
    feasibleOnDiet(i) = feasible;

    % Provide information on feasibility for the user
    if feasible
        disp(strcat("Model ",modelNames(i)," is feasible on the given diet"))
    else
        disp(strcat("Model ",modelNames(i)," is NOT feasible on the given diet"))
    end
end

% Remove feasible models from list
infeasibleModelPaths = paths(~feasibleOnDiet);

% Check the feasibility status of the models
allModelsFeasible = false;
if isempty(infeasibleModelPaths)
    disp('All models are feasible on the diet. No dietary alterations are needed.')
    allModelsFeasible = true;
    dietInfo = 'Not available as all models are feasible';
    dietGrowthStats = 'Not available as all models are feasible';
    return;
end

%% STEP 2: Test if all models are feasible when opening all diet reactions.
disp('EnsureGrowthOnDiet -- STEP 2: Test if all models are feasible when opening all diet reactions.')
modelsInfeasibleOnAnyDiet = false;
if allModelsFeasible == false

    % Test if the infeasible models would be feasible with all dietary inputs given
    feasibleOnAnyDiet = zeros(length(infeasibleModelPaths),1);
    for i = 1:length(infeasibleModelPaths) % This used to be parfor

        % % Load environment variables and set solver
        % restoreEnvironment(environment);
        changeCobraSolver(solver, 'LP', 0, -1);

        % Load WBM
        infeasModel = loadMinimalWBM(infeasibleModelPaths(i));

        % Set parameters and add diet
        infeasModelDiet = setupWbmOnDiet(infeasModel, Diet);

        % Find dietary reactions with a lower bound above -1 and set them
        % to -1, e.g,. a lower bound of -0.0001 will be set to -1.
        % infeasModelDiet.lb(contains(infeasModelDiet.rxns,'Diet_EX_') & infeasModelDiet.lb>-1) = -1;

        % Commented out above code as it is not all diet reactions. Below
        % we will open all dietary reactions to -1000000
        infeasModelDiet = changeRxnBounds(infeasModelDiet, infeasModelDiet.rxns(contains(infeasModelDiet.rxns, 'Diet_EX_')), -1000000, 'l');

        % Test feasibility again
        fba = optimizeWBModel(infeasModelDiet);
        feasible = fba.stat==1;
        feasibleOnAnyDiet(i) = feasible;
    end

    % Record when models are infeasible on any diet
    if any(feasibleOnAnyDiet == 0)
        disp(['WBMs are found that cannot grow on any diet. ' ...
            'Consider debugging these models or removing them from further analysis'])
    elseif sum(feasibleOnAnyDiet) == 0
        disp(['All WBMs cannot grow on any diet. ' ...
            'Consider debugging these models'])
        modelsInfeasibleOnAnyDiet = true;
    end
end

%% Step 3: Check if only opening existing dietary reactions makes the model feasible
disp('EnsureGrowthOnDiet -- STEP 3: Test if models are feasible when opening only dietary reactions that are already consumed and find updated diet reactions if possible')

% Preallocate variable for missing diet components
updatedDietComponents = {};
% Preallocate array for models that are feasible on an updated diet
feasibleOnUpdatedDiet = zeros(length(infeasibleModelPaths),1);
if any(feasibleOnAnyDiet)
    for i = 1:length(infeasibleModelPaths)
        if feasibleOnAnyDiet(i)

            % Initialise variables
            feasible = false;
            skipFindingDiet = false;
            % Load infeasible model
            infeasModel = loadMinimalWBM(infeasibleModelPaths(i));

            % Set parameters and add diet
            infeasModelDiet = setupWbmOnDiet(infeasModel, Diet);

            % Check if previously found solutions make the model feasible
            if ~isempty(updatedDietComponents)
                modelTmp = changeRxnBounds(infeasModelDiet, updatedDietComponents(:,1), cell2mat(updatedDietComponents(:,2)), 'l');
                fba = optimizeWBModel(modelTmp);
                feasible = fba.stat==1;
                if feasible
                    feasibleOnUpdatedDiet(i) = true;
                    skipFindingDiet = true;
                end
            end

            % Set previously found solution to see if that works
            % Obtain the dietary metabolites exchange reactions
            dietaryMets = [infeasModelDiet.rxns(contains(infeasModelDiet.rxns, 'Diet_EX_')), num2cell(infeasModelDiet.lb(contains(infeasModelDiet.rxns, 'Diet_EX_')))];
            % Extract all dietary reactions with a lower bound < 0 (they are
            % capable of being consumed)
            dietaryMetsConsumed = dietaryMets(cell2mat(dietaryMets(:,2))<0,:);
            if ~skipFindingDiet
                % If previusly found solution does not make the model feasible, check
                % if opening dietary reaction bounds make the model feasible
                if ~feasible
                    % Set the dietary reaction of the existing diet to -1000000
                    infeasModelDietOpen = changeRxnBounds(infeasModelDiet, dietaryMetsConsumed(:,1), -1000000, 'l');

                    % Test feasibility again
                    fba = optimizeWBModel(infeasModelDietOpen);
                    feasible = fba.stat==1;
                end

                if feasible
                    % iteravily reset the original lower bound of each dietary exchange
                    % reaction to see which causes the infeasibility
                    disp('Testing increasing consumption of exisiting dietary metabolites')
                    for j = 1:length(dietaryMetsConsumed)
                        modelTmp = changeRxnBounds(infeasModelDietOpen, dietaryMetsConsumed(j,1), cell2mat(dietaryMetsConsumed(j,2)), 'l');
                        fba = optimizeWBModel(modelTmp);

                        if ~fba.stat==1
                            updatedDietComponents(end+1,1:2) = dietaryMetsConsumed(j,:);
                        end
                    end

                    if cell2mat(updatedDietComponents(end,2)) > -0.1
                        updatedDietComponents(end,2) = {-0.1};
                    end
                    % Make a copy of missingDietComponents to adjust values in
                    % without adjusting the original in case models are still
                    % infeasbile after adjustment
                    updatedDietComponentsTmp = updatedDietComponents;

                    % Reset feasiblity to false as we are working with original
                    % model again
                    feasible = false;
                    % Find what the new lower bound value should of the identified
                    % dietary exchange reactions. Do not allow the updated bounds to
                    % decrease below -10 mmol/person/day
                    while ~feasible && all(cell2mat(updatedDietComponentsTmp(:,2)) <= -10)

                        % multiply the lower bounds of the identified reactions to see
                        % if that makes the model feasible
                        updatedDietComponentsTmp(:,2) = num2cell(cell2mat(updatedDietComponentsTmp(:,2))*10);
                        
                        % If there are any fluxes smaller than -10 set them
                        % to -10. This allows for testing of -1 through -9
                        % and allows for robust testing if one metabolite
                        % has a flux of -0.1 and the other of 1. 
                        if any(cell2mat(updatedDietComponentsTmp(:,2)) < -10)
                            updatedDietComponentsTmp(cell2mat(updatedDietComponentsTmp(:,2)) < -10,2) = {-10};
                        end

                        % Update bounds
                        modelTmp = changeRxnBounds(infeasModelDiet, updatedDietComponentsTmp(:,1), cell2mat(updatedDietComponentsTmp(:,2)), 'l');
                        % Solve model
                        fba = optimizeWBModel(modelTmp);

                        % If not feasible repeat loop
                        feasible = fba.stat==1;
                        if feasible
                            % Update the missingDietComponents with the feasible
                            % variable
                            updatedDietComponents = updatedDietComponentsTmp;
                            feasibleOnUpdatedDiet(i) = true;
                        end
                    end
                end
            end
        end
    end
end

%% STEP 4: Find missing diet components for models infeasible on the original diet,
%% but feasible on any diet.
disp('EnsureGrowthOnDiet -- STEP 4: Find missing diet components for models infeasible on the original diet, but feasible on any diet.')
allModelsFeasibleOnUpdatedDiet = false;
if allModelsFeasible == false && modelsInfeasibleOnAnyDiet == false

    % Preallocate variable for missing diet components
    missingDietComponents = {};

    % Find the diet for which all WBMs can grow
    for i = 1:length(infeasibleModelPaths)
        if ~feasibleOnUpdatedDiet(i)
            % Load infeasible model
            infeasModel = loadMinimalWBM(infeasibleModelPaths(i));

            % Set parameters and add diet
            infeasModelDiet = setupWbmOnDiet(infeasModel, Diet);

            feasible = false;
            iteration = 1;
            while feasible == false
                % Find missing diet components for the infeasible model and
                % update the list of missingDietComponents.
                if isempty(missingDietComponents)
                    % Do not check first for feasibility if no
                    % missingDietComponents have been found.
                    tic
                    missingDietComponents = getMissingDietModelHM(infeasModelDiet,missingDietComponents,0);
                    toc
                else
                    % Check for feasibility first if
                    % missingDietComponents have been found before.
                    tic
                    missingDietComponents = getMissingDietModelHM(infeasModelDiet,missingDietComponents,1);
                    toc
                end

                % Add diet components and check if the model is feasible
                modelUpdatedDiet = infeasModelDiet;
                modelUpdatedDiet.lb(matches(modelUpdatedDiet.rxns,missingDietComponents))=-1;

                % Test feasibility again
                fba = optimizeWBModel(modelUpdatedDiet);

                % Update variable
                feasible = fba.stat==1;

                % Exit while loop after 10 iterations
                iteration = iteration+1;
                if iteration>9
                    break
                end
            end
            % Update information on model feasibility with added diet
            % components.
            if iteration>9
                % No feasible diet can be found after 10 iterations
                feasibleOnUpdatedDiet(i) = 0;
            else
                % Model is feasible on the updated diet
                feasibleOnUpdatedDiet(i) = 1;
            end
        end
    end

    % Update if all models are feasible on the updated diet
    if all(feasibleOnUpdatedDiet==1)
        allModelsFeasibleOnUpdatedDiet = true;
    end
end

if all(feasibleOnUpdatedDiet==1)
    allModelsFeasibleOnUpdatedDiet = true;
end
%% STEP 5: If a new diet is found for which all models are feasible, propagate
%% the updated diet to all models.
disp('EnsureGrowthOnDiet -- STEP 5: If a new diet is found for which all models are feasible, propagate the updated diet to all models.')

% If all previously infeasible models can grow on the updated diet,
% propagate the updated diet to all models.
if allModelsFeasible == false && modelsInfeasibleOnAnyDiet == false && allModelsFeasibleOnUpdatedDiet == true
    for i=1:length(paths)
        % Load all models and add updated diet
        model = loadMinimalWBM(paths(i));

        % Set parameters and add diet
        model = setupWbmOnDiet(model, Diet);
        
        % Find indices of open diet reactions
        dietRxnIdx = contains(model.rxns,'Diet_EX_') & model.lb<0;

        % Save diet information for function output
        originalDiet = table(...
            model.rxns(dietRxnIdx),model.lb(dietRxnIdx), model.ub(dietRxnIdx),...
            'VariableNames',{'Diet reactions','Lower flux bound','Upper flux bound'});

        % Save original diet in model
        model.SetupInfo.originalDiet = originalDiet;

        % If novel dietary metabolites were found that had to be added for
        % feasibility
        if ~isempty(missingDietComponents)
        % Propagate missing diet components to all models
        model.lb(matches(model.rxns,missingDietComponents))=-1;
        end
        
        % If existing dietary metabolites were found that had to be
        % increased
        if ~isempty(updatedDietComponents)
            model = changeRxnBounds(model, updatedDietComponents(:,1), cell2mat(updatedDietComponents(:,2)), 'l');
        end
        
        % Find indices of open diet reactions, again
        dietRxnIdx = contains(model.rxns,'Diet_EX_') & model.lb<0;

        % Set the upper bound of all diet reactions to zero
        model.ub(dietRxnIdx) = 0;

        % Get updated diet
        updatedDiet = table(...
            model.rxns(dietRxnIdx),model.lb(dietRxnIdx), model.ub(dietRxnIdx),...
            'VariableNames',{'Diet reactions','Lower flux bound','Upper flux bound'});

        % Update diet composition variable
        model.SetupInfo.DietComposition = updatedDiet;

        % Save updates to model
        SetupInfo = model.SetupInfo;
        ub = model.ub;
        lb = model.lb;
        save(paths(i),'ub','lb','SetupInfo','-append')
    end
else
    disp('No diet could be found for which all WBMs can grow')
end

%% STEP 5: Collect summary statistics
disp('EnsureGrowthOnDiet -- STEP 5: Collect statistics on WBM growth on diets and dietary changes.')

% Set empty variables that might not have been set
if allModelsFeasible == true || modelsInfeasibleOnAnyDiet == true || allModelsFeasibleOnUpdatedDiet == false
    % Set missing diet components as an empty cell array
    missingDietComponents = {};
    % Set updated diet components as an empty cell array
    updatedDiet = table();
end

% Add missingDietComponents and updatedDietComponents together
if ~isempty(missingDietComponents)
missingDietComponents(:,2) = {-1};
end

missingDietComponents = [missingDietComponents;updatedDietComponents]; 
missingDietComponents = [{'Diet reaction', 'New flux value'};missingDietComponents];
% Collect diet information and generate output variable
dietInfo = struct;
dietInfo.missingDietComponents = missingDietComponents;
dietInfo.updatedDiet = updatedDiet;

% Generate table with info on model infeasibilities

% Preallocate table
modelNames = string(erase(modDir.mat,'.mat'));
dietGrowthStats = table('Size',[length(modelNames),4],'VariableTypes',{'string','double','double','double'},...
    'VariableNames',{'Model',...
    'Feasible on given diet (true/false)',...
    'Feasible on any diet (true/false)', ...
    'Feasible on updated diet (true/false)'});

% Add model names
dietGrowthStats.Model = modelNames;

% Fill table if all models are feasible on the original diet
if allModelsFeasible == true
    dietGrowthStats.("Feasible on given diet (true/false)") = ones(length(dietGrowthStats.Model),1);
    dietGrowthStats.("Feasible on any diet (true/false)") = nan(length(dietGrowthStats.Model),1);
    dietGrowthStats.("Feasible on updated diet (true/false)") = nan(length(dietGrowthStats.Model),1);
end

% Fill table if any model is not feasible on any diet
if allModelsFeasible == false && modelsInfeasibleOnAnyDiet == true
    dietGrowthStats.("Feasible on given diet (true/false)") = feasibleOnDiet;
    % Assume if feasible on given diet, feasible on any
    dietGrowthStats.("Feasible on any diet (true/false)") = feasibleOnDiet;
    % Fill in tested model results for any diet
    dietGrowthStats.("Feasible on any diet (true/false)")(~feasibleOnDiet) = ~feasibleOnAnyDiet;
    % No updated diet found as all infeasible models were infeasible on any
    % diet
    dietGrowthStats.("Feasible on updated diet (true/false)") = nan(length(dietGrowthStats.Model),1);
end

% Fill table if (no) updated diet could be found
if allModelsFeasible == false && modelsInfeasibleOnAnyDiet == false
    dietGrowthStats.("Feasible on given diet (true/false)") = feasibleOnDiet;
    % Assume if feasible on given diet, feasible on any
    dietGrowthStats.("Feasible on any diet (true/false)") = feasibleOnDiet;
    % Fill in results of infeasible models on any diet
    dietGrowthStats.("Feasible on any diet (true/false)")(~feasibleOnDiet) = feasibleOnAnyDiet;
    
    % Assume if feasible on given diet, feasible on updated diet
    dietGrowthStats.("Feasible on updated diet (true/false)") = feasibleOnDiet;
    % Fill in results of infeasible models on updated diet
    dietGrowthStats.("Feasible on updated diet (true/false)")(~feasibleOnDiet) = feasibleOnUpdatedDiet;
end

% Write tables
writetable(dietGrowthStats,[mWBMPath filesep 'dietGrowthStats.xlsx'], 'Sheet','SummaryFeasibility');
writetable(dietInfo.updatedDiet,[mWBMPath filesep 'dietGrowthStats.xlsx'],'Sheet','Updated_diet');
writecell(missingDietComponents,[mWBMPath filesep 'dietGrowthStats.xlsx'],'Sheet','Added_diet_metabolites');


end

function convertedModels = checkWbmFormat(paths)
% This function checks if a WBM .mat file is saved as a structured array.
% Saving WBMs as structures can dramatically improve loading speed and
% reduce memory load. The function 1) checks which models are not stored as
% structures and 2) converts the .mat files not stored as structures to
% structured files.
%
% INPUT
% paths             Path to .mat files
%
% OUTPUT
% convertedModels   Paths of .mat files converted to structured .mat files
%
% AUTHOR: Tim Hensen

% Check which models are saved as structures and which are not
unStructuredMat = false(length(paths),1);
warning('off')
for i = 1:length(paths)
    % Load the model field with the lowest size in bytes
    osenseStr = load(paths(i),'osenseStr');
    % If the field does not exist, the HM model must be unstructured
    if isempty(fieldnames(osenseStr))
        unStructuredMat(i)=true;
    end
end
warning('on')

% Find models to convert
pathsConvert = paths(unStructuredMat);

% Load models and save them as structured .mat files
for i = 1:length(pathsConvert)
    % Load WBM
    model = load(pathsConvert(i));
    % Unnest variable
    if isscalar(fieldnames(model))
        model=model.(string(fieldnames(model)));
    end
    % Save as structured .mat file
    save(pathsConvert(i),"-struct","model")
end

convertedModels = pathsConvert;
end


function model_out = setupWbmOnDiet(model_in, Diet)
% Parameterise microbiome-WBMs and give user specified diet

% Set diet
if ~isfield(model_in.SetupInfo, 'dietName')
    disp('set default diet')
    model_in = setDietConstraints(model_in,Diet, 1);
end

% enforce microbial growth (i.e., microbal fecal excretion)
model_in = changeRxnBounds(model_in, 'Excretion_EX_microbiota_LI_biomass[fe]', 1, 'b');

% Enforce body weight maintenance
model_in = changeRxnBounds(model_in, 'Whole_body_objective_rxn', 1, 'b');

% Set whole-body objective reaction
model_in = changeObjective(model_in, {'Whole_body_objective_rxn'}, 1);

% Set direction of optimisation
model_in.osenseStr = 'max';

model_out = model_in;
end