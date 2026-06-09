function [contextSpecificModel, retainedRxns, indicesCompletedCoreOrig] = rFastcormics(model, discretized, rownames, dico, biomassReactionName, consensusProportion, epsilon, optionalSettings, fillingMediumFlag, adaptiveScalingFlag)
% The rFASTCORMICS is a context-specific building algorithm for
% reconstructing a tissue, a cell-specific, or any context-specific model from RNAseq data
% and a generic reconstruction (Pacheco et al. 2019)
%
% USAGE:
%
%   [contextSpecificModel, retainedRxns, indicesCompletedCoreOrig] = rFastcormics(model, discretized, rownames, dico, biomassReactionName, consensusProportion, epsilon, optionalSettings, fillingMediumFlag, adaptiveScalingFlag)
%
% REQUIREMENTS:
%                          * Statistics and Machine Learning Toolbox
%                          * Curve fitting toolbox
% INPUTS:
%   model:                 object - the following fields are required - (others can be supplied)
%                          * S  - `m x 1` Stoichiometric matrix
%                          * lb - `n x 1` Lower bounds
%                          * ub - `n x 1` Upper bounds
%                          * rxns   - `n x 1` cell array of reaction abbreviations
%                          * metFormulas m*1 metabolite Formulas
%   discretized:           double - discretized values for the samples, size(discretized, 1) =
%                          number of genes, size(discretized, 2) = number of
%                          samples
%   rownames:              cell array with the gene IDs
%   dico:                  table which contains corresponding gene identifier information. Needed
%                          to map the rownames to the genes in the model.
%   biomassReactionName:   character array with the name of the objective  
%
% OPTIONAL INPUTS: 
%   consensusProportion:   the rate of samples that have to express or not to express a gene for the
%                          gene to be considered expressed or not in the
%                          context of interest (default 0.9)
%   epsilon:               smallest flux that is considered nonzero (default = 1e-4)
%   optionalSettings:      structure
%                          * .func - cell array of reaction abbreviations that should carry a flux
%                          * .medium - cell array of metabolites abbreviations that defines metabolites
%                          in the growth medium of cells to constrain the model
%                          * .notMediumConstrained - reaction abbreviations not included in the medium that must be retained
%   fillingMediumFlag:     fill the medium with supplementary reactions in case the provided medium is not sufficient to fulfill the objective function. 
%                          1 for active (default), 0 for inactive
%   adaptiveScalingFlag:   adaptive scaling of the flux values (see LP10).
%                          0 for inactive (default), 1 for active
%
% OUTPUTS:
%   contextSpecificModel:        context-specific model, reduced to the retained reactions and associated genes
%   retainedRxns:                indices of the retained reactions in the input model
%   indicesCompletedCoreOrig:    indices of the core reactions in the input model
%
% EXAMPLE:
%
%   [contextSpecificModel, retainedRxns, indicesCompletedCoreOrig] = rFastcormics(model, discretized, rownames, dico, biomassReactionName)
%   
% .. Authors:
%       - Maria Pires Pacheco, Thomas Sauter, 2016, University of Luxembourg
%       - Maria Pires Pacheco, Thomas Sauter, 2023, adaptation of the code to the Cobra toolbox
%       - Vanille Lejal, 2025, University of Luxembourg, removing the transporters from the core, switching to one fastcore,
%       integration of an option to fill a missing medium
%       - Leonie Thomas, 2026, University of Luxembourg, including
%       arguments block and validateInputs check

arguments
    model (1,1) struct {mustBeCobraModel(model)}
    discretized (:,:) double
    rownames string
    dico
    biomassReactionName char
    consensusProportion (1,1) double {mustBeGreaterThan(consensusProportion,0), mustBeLessThanOrEqual(consensusProportion,1)} = 0.9
    epsilon (1,1) double = 1e-4
    optionalSettings (1,1) struct = struct()
    fillingMediumFlag (1,1) double {mustBeMember(fillingMediumFlag, [0 1])} = 1
    adaptiveScalingFlag (1,1) double {mustBeMember(adaptiveScalingFlag, [0 1])} = 0
end

% Function validates that number of genes in rownames is the same number as
% the rows in the discretized data, and checks that some of the gene names can
% be found in any of the columns in the dico. If not, that means that you
% don't have that type of gene id in your dico that is used in the dataset.
% Checks that the biomass reaction defined is in the input model.
validateInputs(model, biomassReactionName, discretized, rownames, dico);

if nargin < 6 || isempty(epsilon)
    epsilon = getCobraSolverParams('LP', 'feasTol')*100;
end

% optionalSettings.func needs to be a column vector 1xn and not a row
% vector - turn it around otherwise
if isfield(optionalSettings, 'func')
    if size(optionalSettings.func, 2) == 1 & size(optionalSettings.func, 1) > 1
        optionalSettings.func = optionalSettings.func';
    end
    functionKeep = optionalSettings.func;
else
    functionKeep = biomassReactionName;
end

%% Saving the original model
origModel = model;

%% Checking the format of the discretized values
if numel(rownames) ~= size(discretized, 1)
    disp('The number of gene IDs between the discretized data and the given IDs ("rownames") do not correspond.')
    return
end

%% Correcting the format of the model

% checking model.subSystems format 
if ~ischar(model.subSystems{1})
    model.subSystems = vertcat(model.subSystems{:});
end

% fixing rules
if ~isfield(model, 'rules')
    disp('Creating model.rules as it was missing')
    model = generateRules(model);
end

% fixing reversibilities
model = fixIrr(model); 

% creating a consistent model
[consistentRxns, ~, ~] = fastcc(model, epsilon, 0, 0, 'original'); % indexes of the consistent reactions
consistentModel = removeRxns(model, model.rxns(setdiff(1:numel(model.rxns), consistentRxns))); % removing the non consistent reactions

%% Optionally constrain the model using a defined medium
% Check whether optional settings exist and include a 'medium' field
if ~isempty(optionalSettings) && isfield(optionalSettings, 'medium')
    
    % Retrieve reactions/metabolites that should NOT be constrained by the medium (if provided)
    if isfield(optionalSettings, 'notMediumConstrained')
        notMediumConstrained = optionalSettings.notMediumConstrained;
    else
        notMediumConstrained = [];
    end
    
    % Get list of metabolites defining the medium
    mediumMets = optionalSettings.medium;
    
    % Identify uptake (exchange) reactions associated with the medium metabolites in the model
    [~, uptRxnsBool] = findExcRxns(consistentModel);
    uptRxns = consistentModel.rxns(uptRxnsBool);
    [mediumRxns, ~] = findRxnsFromMets(consistentModel, mediumMets);
    uptMediumRxns = intersect(uptRxns, mediumRxns);
    
    % Display number of uptake reactions affected by the medium
    fprintf("Number of uptake reactions associated with medium metabolites: %d.\n", numel(uptMediumRxns));

    % Apply medium constraints to the model (may lead to inconsistencies)
    mediumConstrainedModel = constrainModelOnMedium(consistentModel, mediumMets, notMediumConstrained, biomassReactionName, functionKeep);

% Case where no optional settings are provided
elseif isempty(optionalSettings)
    mediumConstrainedModel = consistentModel; 
    warning('No optional settings detected.')

% Case where optional settings exist but no medium is defined
else
    mediumConstrainedModel = consistentModel;
    warning('No given medium.')
end

%% Mapping the reactions to the model
mapping = mapExpressionToModel(mediumConstrainedModel, discretized, dico, rownames, 1);
mapping = sparse(mapping);

if sum(mapping) == 0
    disp('No expressed genes were mapped, check again.') % no gene expressed according to the RNAseq data
    return
end

%% Defining the core
% The discretized values will be discretized into expressed, not expressed, and unknown expression status.
% Core is defined as the reactions that are under the control of expressed genes.
numberOfSamples = size(discretized,2);
initialCore = find(sum(mapping == 1, 2) >= (consensusProportion * numberOfSamples)); 

% Finding transporters in the Core
modelTransRxns = findTransRxns(mediumConstrainedModel);
[~, TransIDs] = ismember(modelTransRxns, mediumConstrainedModel.rxns);
% Removing transporters from the core
coreWithoutTrans = setdiff(initialCore, TransIDs); % we remove transporters from the core
fprintf("Number of core reactions (after mapping, transporters removed, without .func reactions): %d\n", numel(coreWithoutTrans));

if ~isempty(functionKeep)
    foundFunctionKeep = find(ismember(mediumConstrainedModel.rxns, functionKeep)); %reactions to keep
    if isempty(foundFunctionKeep)
        warning('No reactions from .func set were found in the model.')
    elseif numel(foundFunctionKeep) ~= numel(functionKeep)
        warning('Part of the reactions from .func set were not found in the model.')
    end
    % Adding .func reactions to the core
    completedCore = union(coreWithoutTrans, foundFunctionKeep);
else
    completedCore = coreWithoutTrans;
end

% Get the names of the core reactions
rxnNamesCompletedCore = mediumConstrainedModel.rxns(completedCore);
% Get the indices of the core reactions in the original model
indicesCompletedCoreOrig = find(ismember(origModel.rxns, rxnNamesCompletedCore));

%% Removing the reactions under the control of unexpressed genes
notExpressed = find(sum(mapping == -1, 2) >= (consensusProportion * numberOfSamples));
fprintf("Number of non expressed reactions (after mapping): %d.\n", numel(notExpressed));
mediumConstrainedModel.lb(notExpressed) = 0;
mediumConstrainedModel.ub(notExpressed) = 0;

% Building of a consistent model
[consistentRxnsAfterMedium, ~, ~] = fastcc(mediumConstrainedModel, epsilon, 0, 0, 'original');
consistentMediumConstrainedModel = removeRxns(mediumConstrainedModel, mediumConstrainedModel.rxns(setdiff(1:numel(mediumConstrainedModel.rxns), consistentRxnsAfterMedium)));

%% Checking medium sufficiency
% Check if biomass reaction is still present after applying medium constraints
if any(strcmp(consistentMediumConstrainedModel.rxns, biomassReactionName))
    
    % Set biomassReactionName as objective and run FBA
    consistentMediumConstrainedModel = changeObjective(consistentMediumConstrainedModel, biomassReactionName);
    fbaResults = optimizeCbModel(consistentMediumConstrainedModel, 'max', 'zero');

    % If FBA returns a valid value, the medium supports growth
    if ~isempty(fbaResults.f) && ~isnan(fbaResults.f)
        disp(['Model still contains ' biomassReactionName ' after application of medium constraints, and FBA result is not null.' newline 'Medium is sufficient. Continuing with fastcore.']);
        needMediumFilling = false;
    else
        % Biomass present but no flux, medium is insufficient
        disp(['Model still contains ' biomassReactionName ' after application of medium constraints, but FBA result is ' num2str(fbaResults.f) '. Medium is not sufficient.']);
        needMediumFilling = true;
    end
else
    % Biomass reaction missing, model cannot grow
    disp(['Model lost ' biomassReactionName ' after application of medium constraints.']);
    needMediumFilling = true;
end

%% In case medium if not sufficient
% Checking if all the uptake rxns associated with the medium are in.
if needMediumFilling
    [~, uptRxnsAfterMediumBool] = findExcRxns(consistentMediumConstrainedModel);
    uptRxnsAfterMedium = consistentMediumConstrainedModel.rxns(uptRxnsAfterMediumBool);
    notPresentUptMediumRxns = setdiff(uptMediumRxns, uptRxnsAfterMedium);
    if ~isempty(notPresentUptMediumRxns)
        disp(['The following uptake reactions: ' newline strjoin(notPresentUptMediumRxns, newline) newline 'were initially not included in the consistent medium constraint model, even though they were associated with medium metabolites.' newline 'In the case of medium filling, their inclusion in the model will not be penalized.']);
    end
end

%% Get the indices of the core reactions in the consistent constrained model
correctIndicesCompletedCore = find(ismember(consistentMediumConstrainedModel.rxns, rxnNamesCompletedCore));

%% Building of the context-specific model
[contextSpecificModel, retainedRxnsBool] = fastcore(consistentMediumConstrainedModel, correctIndicesCompletedCore, 1e-4, 0, adaptiveScalingFlag);
indices = 1:numel(consistentMediumConstrainedModel.rxns);
keepRxns = indices(retainedRxnsBool == 1);
retainedRxns = find(ismember(origModel.rxns, consistentMediumConstrainedModel.rxns(keepRxns)));

%% Check if all the .func reactions are included in the model
missingFunctionKeep = functionKeep(~ismember(functionKeep, contextSpecificModel.rxns));
if ~isempty(missingFunctionKeep)
    disp(['The following .func reactions are missing:' newline strjoin(missingFunctionKeep, newline) newline ' and will be added to the context-specific model through a second fastcore run.']);
    functionKeepFlag = true; % missing .func reactions will be added later
else
    functionKeepFlag = false;
end

%% Proceed to medium filling if needed and required
if fillingMediumFlag == 1 && needMediumFilling || functionKeepFlag
    
    % We will use the consistent model as input as it still contains all the reactions of the original model
    % Copying the bounds of rxns in the context specific model in the consistent model to preserve the medium constraints
    [~, idxConsistentModel, idxContextSpecificModel] = intersect(consistentModel.rxns, contextSpecificModel.rxns);
    consistentModel.lb(idxConsistentModel) = contextSpecificModel.lb(idxContextSpecificModel);
    consistentModel.ub(idxConsistentModel) = contextSpecificModel.ub(idxContextSpecificModel);
    
    % Initializing a new core for a second fastcore run
    fillingCoreRxns = unique([contextSpecificModel.rxns; biomassReactionName]); % contains the reactions of the first contextSpecificModel and the biomassReactionName
    
    % Filling the medium if asked and necessary
    if fillingMediumFlag == 1 && needMediumFilling 
        disp('Proceeding to medium filling.');
        % finding the uptake reactions associated with the medium
        [~, uptRxnsCtxtSpeModelBool] = findExcRxns(contextSpecificModel);
        uptRxnsCtxtSpeModel = contextSpecificModel.rxns(uptRxnsCtxtSpeModelBool);
        notPresentUptMediumRxnsSpe = setdiff(uptMediumRxns, uptRxnsCtxtSpeModel); % missing uptake reactions associated with the medium
        if ~isempty(notPresentUptMediumRxnsSpe)
            disp(['The inclusion of the following uptake reactions: ' newline strjoin(notPresentUptMediumRxnsSpe, newline) newline 'will not be penalized to fill the model as they are initially associated with medium metabolites.']);
        end
    else
       notPresentUptMediumRxnsSpe = ''; 
    end 
    
    if functionKeepFlag
        disp('Proceeding to .func filling.');
        fillingCoreRxns = unique([fillingCoreRxns; missingFunctionKeep']); % completing the core with the missing .func reactions
    end

    indicesFillingCore = find(ismember(consistentModel.rxns, fillingCoreRxns));
    indicesNonPenMediumUptRxns = find(ismember(consistentModel.rxns, notPresentUptMediumRxnsSpe)); % completing the new core with the missing uptake reactions associated with the medium
    
    % Completing the model 
    [contextSpecificModel, retainedRxnsFilledModelBool] = fastcore(consistentModel, indicesFillingCore, 1e-4, 0, adaptiveScalingFlag, indicesNonPenMediumUptRxns);
    indices = 1:numel(consistentModel.rxns);
    keepRxns = indices(retainedRxnsFilledModelBool == 1);
    retainedRxnsFilledModel = find(ismember(origModel.rxns, consistentModel.rxns(keepRxns)));
    supplementaryRxns = setdiff(retainedRxnsFilledModel, retainedRxns); % reactions added during the second fastcore
    disp(['The following reactions have been added to the model during the second fastcore run in order to fill it: ' newline strjoin(origModel.rxns(supplementaryRxns), newline) newline]);
    retainedRxns = retainedRxnsFilledModel;
end

%% Uptakes that do not come from the medium
if isfield(optionalSettings, 'medium')
    [~, uptRxnsBoolSpe] = findExcRxns(contextSpecificModel);
    uptRxnsSpe = contextSpecificModel.rxns(uptRxnsBoolSpe);
    additionalMedium = setdiff(uptRxnsSpe, uptMediumRxns); % uptake reactions added to complete the medium
    disp(['Model additional uptakes (not provided by the medium): ' newline strjoin(additionalMedium, newline) newline]);
end
%%
disp('rFastcormics is done.');    
end


function mustBeCobraModel(model)
    required = {'S','rxns','mets','lb','ub'};
    missing = required(~isfield(model, required));
    if ~isempty(missing)
        error("Your model is not a valid Cobra model. Missing fields: " + strjoin(missing, ", "));
    end
end

function validateInputs(model, biomassReactionName, discretized, rownames, dico, minMatches)
arguments
    model 
    biomassReactionName 
    discretized 
    rownames 
    dico 
    minMatches = 3
end

    % 1. size check - check that the number of genes is the same in the
    % rownames and discretized
    if size(discretized, 1) ~= numel(rownames)
        error('Row mismatch: discretized (%d) vs rownames (%d).', ...
              size(discretized, 1), numel(rownames));
    end

    rownames = string(rownames);
    dicoVars = dico.Properties.VariableNames;

    % 2. compute best column coverage
    bestMatch = 0;
    bestCol = "";
    
    % check if any of the columns in the dico entails matches for the genes
    % specified in the rownames
    for i = 1:numel(dicoVars)
        col = string(dico.(dicoVars{i}));

        nMatch = sum(ismember(rownames, col));

        if nMatch > bestMatch
            bestMatch = nMatch;
            bestCol = dicoVars{i};
        end
    end

    % 3. enforce threshold
    if bestMatch < minMatches
        error('Insufficient gene mapping: best column "%s" only matches %d genes (minimum required: %d). Check that one of the columns in your dico entails the gene ids used in the model.genes field.', ...
              bestCol, bestMatch, minMatches);
    end


    if ~ismember(biomassReactionName, model.rxns)
        error('The objective function that you defined (%s) is not part of your input model, choose a different objective function.', biomassReactionName)
    end

end