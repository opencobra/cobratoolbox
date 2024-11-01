function directories = XomicsToMultipleModels(modelGenerationConditions, param)
% Variations of the xomicstomodel function can be generated using this
% function.
%
% USAGE:
%
%    directories = XomicsToMultipleModels(modelGenerationConditions, param)
%
% INPUT:
%    modelGenerationConditions: Options to vary or to save the data
%
%       * .activeGenesApproach -﻿The different approached to identify the active
%          genes (Possible options: 'allRxnPerActiveGene' and 'oneRxnPerActiveGene';
%          default: 'oneRxnPerActiveGene');
%       * .boundsToRelaxExoMet - The type of bounds that can be relaxed, upper bounds,
%          lower bounds or both ('b'; possible options: 'u', 'l' and 'b';
%          default: 'b');
%       * .closeIons - Indicate whether the ions are open or closed (Possible options:
%          true and false; default: false);
%       * .cobraSolver - Optimisation solvers supported by the function. Possible
%          options: 'glpk', 'gurobi', 'ibm_cplex', 'matlab'; default: 'gurobi';
%       * .curationOverOmics - indicates whether curated data should take priority
%          over omics data ; default: false;
%       *. genericModel: Generic COBRA model(s)
%       * .inactiveGenesTranscriptomics - Use inactive transcriptomic genes or not
%          (Possible options: true and false; default: false);
%       * .specificData - Specific data variations (Default: empty)
%       * .limitBounds - Boundary on the model (Default: 1000).
%       * .metabolomicsBeforeExtraction - Indicate whether the metabolomic
%          data is included before or after the extraction (Possible options:
%          true and false; default: true);
%       * .tissueSpecificSolver - Extraction solver (Possible options: 'fastCore' and
%          'thermoKernel'; default: 'thermoKernel')
%       * .outputDir - Directory where the models will be generated (Default: current
%          directory)
%       * .transcriptomicThreshold - Transcriptomic thresholds that are defined by the
%          user (Default: log2(2));
%
%   param:           Variable with fixed parameters (Default: empty struct array)
%
% OUTPUTS:
%
%	directories - Array with the name of the new directories

if nargin < 2 || isempty(param)
    param = struct;
end

% Directory to save the models
if isfield(modelGenerationConditions, 'outputDir')
    outputDir = modelGenerationConditions.outputDir;
    outputDir = [regexprep(char(outputDir),'(/|\\)$',''), filesep];
else
    outputDir = [pwd filesep];
end

directories = [];

%% Set conditions

% Cobra solver
if isfield(modelGenerationConditions, 'cobraSolver')
    cobraSolver = modelGenerationConditions.cobraSolver;
else
    cobraSolver = {'mosek'};
end

% genericModel
if isfield(modelGenerationConditions, 'genericModel')
    models = modelGenerationConditions.genericModel;
    modelsLabels = fieldnames(models);
else
    error('A generic model is needed in modelGenerationConditions.genericModel')
end

% Context-specific input data
if isfield(modelGenerationConditions, 'specificData')
    specificDataforXomics = modelGenerationConditions.specificData;
    specificDataLabels = fieldnames(specificDataforXomics);
else
    specificDataforXomics = struct;
end

% Tissue specific solver
if isfield(modelGenerationConditions, 'tissueSpecificSolver')
    tissueSpecificSolver = modelGenerationConditions.tissueSpecificSolver;
elseif ~isfield(modelGenerationConditions, 'tissueSpecificSolver') && isfield(param, 'tissueSpecificSolver')
    tissueSpecificSolver = {param.tissueSpecificSolver};
else
    tissueSpecificSolver = {'thermoKernel'};
end

% Active genes approach
if isfield(modelGenerationConditions, 'activeGenesApproach')
    activeGenesApproach = modelGenerationConditions.activeGenesApproach;
elseif ~isfield(modelGenerationConditions, 'activeGenesApproach') && isfield(param, 'activeGenesApproach')
    activeGenesApproach = {param.activeGenesApproach};
else
    activeGenesApproach = {'oneRxnPerActiveGene'};
end

% Transcriptomic threshold
if isfield(modelGenerationConditions, 'transcriptomicThreshold')
    transcriptomicThreshold = modelGenerationConditions.transcriptomicThreshold;
elseif ~isfield(modelGenerationConditions, 'transcriptomicThreshold') && isfield(param, 'transcriptomicThreshold')
    transcriptomicThreshold = param.transcriptomicThreshold;
else
    transcriptomicThreshold = 2;
end

% Limit bounds
if isfield(modelGenerationConditions, 'limitBounds')
    limitBounds = modelGenerationConditions.limitBounds;
elseif ~isfield(modelGenerationConditions, 'limitBounds') && isfield(param, 'limitBounds')
    limitBounds = param.limitBounds;
else
    limitBounds = 10e4;
end

% Use inactive genes from transcriptomics
if isfield(modelGenerationConditions, 'inactiveGenesTranscriptomics')
    inactiveGenesTranscriptomics = modelGenerationConditions.inactiveGenesTranscriptomics;
elseif ~isfield(modelGenerationConditions, 'inactiveGenesTranscriptomics') && isfield(param, 'inactiveGenesTranscriptomics')
    inactiveGenesTranscriptomics = param.inactiveGenesTranscriptomics;
else
    inactiveGenesTranscriptomics = false;
end

% Ions exchange
if isfield(modelGenerationConditions, 'closeIons')
    closeIons = modelGenerationConditions.closeIons;
elseif ~isfield(modelGenerationConditions, 'closeIons') && isfield(param, 'closeIons')
    closeIons = param.closeIons;
else
    closeIons = false;
end

% boundsToRelaxExoMet
if isfield(modelGenerationConditions, 'boundsToRelaxExoMet')
    boundsToRelaxExoMet = modelGenerationConditions.boundsToRelaxExoMet;
else
    boundsToRelaxExoMet = {'b'};
end

% activeOverInactive
if isfield(modelGenerationConditions, 'activeOverInactive')
    activeOverInactive = modelGenerationConditions.activeOverInactive;
elseif ~isfield(modelGenerationConditions, 'activeOverInactive') && isfield(param, 'activeOverInactive')
    activeOverInactive = param.activeOverInactive;
else
    activeOverInactive = false;
end

% curationOverOmics
if isfield(modelGenerationConditions, 'curationOverOmics')
    curationOverOmics = modelGenerationConditions.curationOverOmics;
elseif ~isfield(modelGenerationConditions, 'curationOverOmics') && isfield(param, 'curationOverOmics')
    curationOverOmics = param.curationOverOmics;
else
    curationOverOmics = false;
end

% metabolomicsBeforeExtraction
if isfield(modelGenerationConditions, 'metabolomicsBeforeExtraction')
    metabolomicsBeforeExtraction = modelGenerationConditions.metabolomicsBeforeExtraction;
elseif ~isfield(modelGenerationConditions, 'metabolomicsBeforeExtraction') && ...
        isfield(param, 'metabolomicsBeforeExtraction')
    metabolomicsBeforeExtraction = param.metabolomicsBeforeExtraction;
else
    metabolomicsBeforeExtraction = true;
end

disp('Generating models ...');

% Data with more than one variation will be included in the folder name
conditionsBool = false(11, 1);
if length(cobraSolver) > 1
    conditionsBool(1) = true;
end
if length(modelsLabels) > 1
    conditionsBool(2) = true;
end
if length(specificDataLabels) > 1
    conditionsBool(3) = true;
end
if length(tissueSpecificSolver) > 1
    conditionsBool(4) = true;
end
if length(activeGenesApproach) > 1
    conditionsBool(5) = true;
end
if length(transcriptomicThreshold) > 1
    conditionsBool(6) = true;
end
if length(limitBounds)> 1
    conditionsBool(7) = true;
end
if length(inactiveGenesTranscriptomics) > 1
    conditionsBool(8) = true;
end
if length(closeIons) > 1
    conditionsBool(9) = true;
end
if length(activeOverInactive) > 1
    conditionsBool(10) = true;
end
if length(curationOverOmics) > 1
    conditionsBool(11) = true;
end
if length(metabolomicsBeforeExtraction) > 1
    conditionsBool(12) = true;
end

%% Check if there are any fields in modelGenerationConditions that are not specified above
% Because these need to be added to param and cannot yet be used here.
unknownmodelGenerationConditions = setdiff(fieldnames(modelGenerationConditions), ...
    {'cobraSolver' 
    'genericModel'
    'specificData'
    'tissueSpecificSolver'
    'activeGenesApproach'
    'transcriptomicThreshold'
    'limitBounds'
    'inactiveGenesTranscriptomics'
    'closeIons'
    'activeOverInactive'
    'curationOverOmics'
    'metabolomicsBeforeExtraction'
    'outputDir'});

if ~isempty(unknownmodelGenerationConditions)
    msg = ['Unknown parameter(s) specified in modelGenerationConditions: ' strjoin(unknownmodelGenerationConditions) '. Specify these in param'];
    error(msg)
end

%% Generate models

% Select cobraSolver
dirIdx = 0;
for firstGruoup = 1:length(cobraSolver)
    switch cobraSolver{firstGruoup}
        case 'gurobi'
            solverLabel = 'gurobi';
            [solverOK, solverInstalled] = changeCobraSolver('gurobi','all');
        case 'ibm_cplex'
            solverLabel = 'ibmCplex';
            [solverOK, solverInstalled] = changeCobraSolver('ibm_cplex','all');
        case 'mosek'
            solverLabel = 'mosek';
            [solverOK, solverInstalled] = changeCobraSolver('mosek','LP');
            [solverOK, solverInstalled] = changeCobraSolver('mosek','QP');
    end
    
    % Input model
    for secondGroup = 1:length(modelsLabels)
        modelLabel = modelsLabels{secondGroup};
        genericModel = models.(modelsLabels{secondGroup});
        
        % specificDataInfo
        for thirdGruoup = 1:length(specificDataLabels)
            specificDataLabel = specificDataLabels{thirdGruoup};
            specificData = specificDataforXomics.(specificDataLabels{thirdGruoup});
            
            % Extraction algorithm
            for fourthGroup = 1:length(tissueSpecificSolver)
                param.tissueSpecificSolver = tissueSpecificSolver{fourthGroup};
                
                % Active genes approach
                for fifthGroup = 1:length(activeGenesApproach)
                    param.activeGenesApproach = activeGenesApproach{fifthGroup};
                    param.activeGenesApproach = regexprep(activeGenesApproach{fifthGroup}, 'oneRxnsPerActiveGene', 'oneRxnPerActiveGene');
                    
                    % Transcriptomic Threshold
                    for sixthGroup = 1:length(transcriptomicThreshold)
                        param.transcriptomicThreshold = transcriptomicThreshold(sixthGroup);
                        
                        % Load input data
                        for seventhGroup = 1:length(limitBounds)
                            param.TolMinBoundary = -limitBounds(seventhGroup);
                            param.TolMaxBoundary = limitBounds(seventhGroup);
                            
                            % Option to identify genes as inactive if
                            % expressed below transcriptomic threshold
                            for eigthGroup = 1:length(inactiveGenesTranscriptomics)
                                param.inactiveGenesTranscriptomics = inactiveGenesTranscriptomics(eigthGroup);
                                if inactiveGenesTranscriptomics(eigthGroup)
                                    inactiveGenesTLabel = 'inactiveGenesT';
                                else
                                    inactiveGenesTLabel = 'NoInactiveGenesT';
                                end
                                
                                % closeIons
                                for ninethGroup = 1:length(closeIons)
                                    param.closeIons = closeIons(ninethGroup);
                                    if closeIons(ninethGroup)
                                        ionsLabel = 'closedIons';
                                    else
                                        ionsLabel = 'openIons';
                                    end
                                    
                                    % Active data over inactive
                                    for tenthGroup = 1:length(activeOverInactive)
                                        param.activeOverInactive = activeOverInactive(tenthGroup);
                                        if activeOverInactive(tenthGroup)
                                            activationLabel = 'activeOverInactive';
                                        else
                                            activationLabel = 'inactiveOverActive';
                                        end

                                        for eleventhGroup = 1:length(curationOverOmics)
                                            param.curationOverOmics = curationOverOmics(eleventhGroup);
                                            if curationOverOmics(eleventhGroup)
                                                priorityLabel = 'curationOverOmics';
                                            else
                                                priorityLabel = 'omicsOverCuration';
                                            end
                                            
                                            for twelfthGroup = 1:length(metabolomicsBeforeExtraction)
                                                param.metabolomicsBeforeExtraction = metabolomicsBeforeExtraction(twelfthGroup);
                                                if metabolomicsBeforeExtraction(twelfthGroup)
                                                    exoMetLabel = 'exoMetBeforeExtraction';
                                                else
                                                    exoMetLabel = 'exoMetAfterExtraction';
                                                end
                                                
                                                % Establish the working directory
                                                conditions = [solverLabel; ...
                                                    modelLabel; ...
                                                    specificDataLabel; ...
                                                    tissueSpecificSolver{fourthGroup}; ...
                                                    activeGenesApproach{fifthGroup}; ...
                                                    {['transcriptomicsT' num2str(transcriptomicThreshold(sixthGroup))]}; ...
                                                    {['limitBoundary.' num2str(limitBounds(seventhGroup))]}; ...
                                                    inactiveGenesTLabel; ...
                                                    ionsLabel; ...
                                                    activationLabel;
                                                    priorityLabel;
                                                    exoMetLabel];
                                                
                                                workingDirectory = [outputDir ...
                                                    strjoin(conditions(conditionsBool), '_')];
                                                param.workingDirectory = workingDirectory;
                                                
                                                dirContent = dir(workingDirectory);
                                                if ~isfolder(workingDirectory)
                                                    mkdir(workingDirectory)
%                                                 elseif any(~cellfun(@isempty, regexp({dirContent.name}, '.txt')))
%                                                     continue
                                                end
                                                
                                                % Start the diary
                                                if isunix()
                                                    name = getenv('USER');
                                                else
                                                    name = getenv('username');
                                                end
                                                param.diaryFilename = [workingDirectory filesep datestr(now,30) '_' name '_diary.txt'];
                                                
                                                % Model generation only if no model already present in folder
                                                fileNames = what(workingDirectory);
                                                
                                                if any(ismember(fileNames.mat,'Model.mat'))
                                                    load([workingDirectory filesep 'Model.mat'])
                                                    %test properties of previously computed model to decide if recomputation is necessary
                                                    if size(Model.S,2)==length(Model.expressionRxns)
                                                        recompute = 0;
                                                    else
                                                        fprintf('%s\n', ['Recomputing because prexisting inconsistent model in ' workingDirectory ])
                                                        recompute = 1;
                                                    end
                                                else
                                                    recompute = 1;
                                                end
                                                
                                                if ~recompute && any(ismember(fileNames.mat,'Model.mat'))
                                                    fprintf('%s\n', ['Prexisting model in ' workingDirectory ])
                                                else
                                                    fprintf('%s\n', ['Computing new model in ' workingDirectory ])
%                                                     try
                                                        [omicsModel, modelGenerationReport] = XomicsToModel(genericModel, specificData, param);
                                                        % Save the model with the correct name
                                                        Model = omicsModel;
                                                        save([workingDirectory filesep 'Model.mat'], 'Model', 'modelGenerationReport')
%                                                     catch ME
%                                                         warning('XomicsToModel failed to run')
%                                                         disp(param)
%                                                         disp(ME)
%                                                         msgText = getReport(ME)
%                                                         % Close the diary if the run crashed
%                                                         fprintf('%s\n', ['Diary written to: ' param.diaryFilename])
%                                                         diary off
%                                                     end
                                                end
                                               
                                                if any(conditionsBool)
                                                    dirIdx = dirIdx + 1;
                                                    directories{dirIdx} = strjoin(conditions(conditionsBool), '_');
                                                else
                                                    directories = pwd;
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
