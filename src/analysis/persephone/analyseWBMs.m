function [FBA_results, pathsToFilesForStatistics] = analyseWBMs(mWBMPath, fluxPath, rxnList, varargin)
% analyseWBMs predicts the optimal fluxes for a list of user-defined
% reactions (rxnList). All predicted are further described in
% analyseWBMsol.m.
%
% USAGE:
%       [FBA_results, pathsToFilesForStatistics] = analyseWBMs(mWBMPath, fluxPath, rxnList)
%
% INPUTS:
% mWBMPath      Path (character array) to WBMs
% fluxPath      Path to directory where the results will be stored
% rxnList       Cell array of VMH metabolites to investigate.
%               Example: rxnList = {'DM_trp_L[bc], DM_met_L[bc],'Brain_trp_L[c],
%               Heart_met_L[x]}. Note that demand reactions are
%               automatically added if they are not present in the models.
%
% OPTIONAL INPUTS
% rxnSense       Character array containing either 'max' or 'min'
%                to specify the sense of the objective. Option
%                to specify differently for each objective- to do so provide
%                character array the exact length of rxnList.
%                (OPTIONAL, Default = 'max').
% numWorkersOptimization    Number of workers that will perform FBA in parallel. Note
%               that more workers does not necessarily make the function
%               faster. It is generally not recommended to set numWorkersOptimization
%               equal to the number of available cores (see:
%               feature('numCores')) as linear solvers can already
%               support multi-core linear optimisation, thus resulting in
%               unnessessary overhead. On computers with 8 cores or less, it
%               is recommended to set numWorkersOptimization to 1. On a computer with
%               36 cores, an optimal configuration of numWorkersOptimization=6 was
%               found.
% saveFullRes   Boolean (true/false) indicating if all the complete .v, .y.
%               , and .w vectors are stored in the result. Default = true.
%               It is recommended to set saveFullRes
%
% paramFluxProcessing       Structured array with optional parameters:
%
%                     .NumericalRounding defines how much the predicted flux values are
%                     rounded. A defined value of 1e-6 means that a flux value of
%                     2 + 2.3e-8 is rounded to 2. A flux value of 0 + 1e-15 would be rounded to
%                     exactly zero. This rounding factor will also be applied to the shadow
%                     price values. If microbiome relative abundance data is provided, the same
%                     rounding factor will be applied to the relative abundance data.
%
%                     Default parameterisation:
%                     - paramFluxProcessing.NumericalRounding = 1e-6;
%
%                     Example:
%                     - paramFluxProcessing.NumericalRounding = 1e-6;
%
%                     paramFluxProcessing.NumericalRounding = 1e-6;
%
%                     .RxnRemovalCutoff defines the minimal number of samples for which a
%                     unique reaction flux could be obtained, before removing the reaction for
%                     further analysis. This parameter can be expressed as
%                     * fraction:  the fraction of samples with unique values,
%                     * SD: the standard deviation across samples, and
%                     * count: the counted number of unique values. If microbiome relative
%                     abundance data is provided, the same removal cutoff factor will be
%                     applied to the relative abundance data.
%
%                     Default parameterisation:
%                     - paramFluxProcessing.RxnRemovalCutoff = {'fraction',0.1};
%
%                     Examples:
%                     - paramFluxProcessing.RxnRemovalCutoff = {'fraction',0.1};
%                     - paramFluxProcessing.RxnRemovalCutoff = {'SD',1};
%                     - paramFluxProcessing.RxnRemovalCutoff = {'count',30};
%
%                     paramFluxProcessing.RxnRemovalCutoff = {'fraction',0.1};
%
%                     .RxnEquivalenceThreshold defines the minimal threshold of when
%                     functionally identical flux values are predicted, and are thus part of
%                     the same linear pathways. The threshold for functional equivalence is
%                     expressed as the R2 (r-squared) value after performing a simple linear
%                     regression between two reactions.
%
%                     Default parameterisation:
%                     - paramFluxProcessing.RxnEquivalenceThreshold = 0.999;
%
%                     Example:
%                     - paramFluxProcessing.RxnEquivalenceThreshold = 0.999;
%
%                     paramFluxProcessing.RxnEquivalenceThreshold = 0.999;
%
%                     .fluxMicrobeCorrelationType defines the method for correlating the
%                     predicted fluxes with microbial relative abundances. Note that this
%                     metric is not used if mWBMs are not present. The available correlation
%                     types are:
%                     * regression_r2:  the R2 (r-squared) value from pairwised linear regression on the
%                     predicted fluxes against microbial relative abundances.
%                     * spearman_rho: the correlation coefficient, rho obtained from pairwise
%                     Spearman nonparametric correlations between predicted fluxes and
%                     microbial relative abundances.
%
%                     Default parameterisation:
%                     - paramFluxProcessing.fluxMicrobeCorrelationMetric = 'regression_r2';
%
%                     Examples:
%                     - paramFluxProcessing.fluxMicrobeCorrelationMetric = 'regression_r2';
%                     - paramFluxProcessing.fluxMicrobeCorrelationMetric = 'spearman_rho';
%
% fluxAnalysisPath:     Character array with path to directory where all
%                       results will be saved (Default = pwd)
% Solver:               Validated solvers: 'cplex_direct','ibm_cplex'
%                       'tomlab_cplex', 'gurobi', 'mosek'
% analyseGF:            Boolean indiciating whether or not to investigate
%                       GF models. In the case of personalisation, a germ
%                       free iWBM will be created for every sample, this
%                       can results in long computation times as there are
%                       double the number of models to solve. If you are
%                       not interested in solving a germ-free iWBM for each
%                       sample, you can set to false. Default is true. When
%                       personalisation is skipped, only one germ-free
%                       model is made for each sex. 
%
% OUTPUT
% results       Structured array with FBA fluxes, solver statistics, and
%               paths to the flux table and raw flux results
%
% .. Author:
%       - Tim Hensen       May, 2024
%       - Bram Nap         May, 2024 - add functionalities for solving
%       existing reactions, optional filename argument for saving the
%       output, skipping results already computed when the code stopped mid
%       run
%       - Tim Hensen       July 2024. Added flux processing pipeline: hostMicrobiomeSolProcessingAndAnalysis

% Define default parameters if not defined
parser = inputParser();
parser.addRequired('mWBMPath', @ischar);
parser.addRequired('fluxPath', @ischar);
parser.addRequired('rxnList', @iscell);

% Optional inputs
parser.addParameter('rxnSense', '', @iscell);
parser.addParameter('numWorkersOptimization', 1, @isnumeric);
parser.addParameter('saveFullRes', true, @islogical);
parser.addParameter('paramFluxProcessing', struct(), @isstruct);
parser.addParameter('fluxAnalysisPath', [fluxPath, filesep, 'fluxAnalysis'], @ischar);
parser.addParameter('solver', '', @ischar);
parser.addParameter('analyseGF', '', @islogical);

% Parse required and optional inputs
parser.parse(mWBMPath, fluxPath, rxnList, varargin{:});

rxnSense = parser.Results.rxnSense;
mWBMPath = parser.Results.mWBMPath;
fluxPath = parser.Results.fluxPath;
rxnList = parser.Results.rxnList;

numWorkersOptimization = parser.Results.numWorkersOptimization;
saveFullRes = parser.Results.saveFullRes;
paramFluxProcessing = parser.Results.paramFluxProcessing;
fluxAnalysisPath = parser.Results.fluxAnalysisPath;
solver = parser.Results.solver;
analyseGF = parser.Results.analyseGF;

%%% Step 1: Initialise the CobraToolbox and set solver %%%

% Initialise cobratoolbox if needed
global CBT_LP_SOLVER
if isempty(CBT_LP_SOLVER)
    initCobraToolbox
end

% Set solver
changeCobraSolver(solver,'LP'); % before running this function.


%%% Step 2: Find paths to WBMs %%%

% Find paths to the mWBMs/iWBMs/miWBMs
hmDir = what(mWBMPath);
hmPaths = string(append(hmDir.path, filesep, hmDir.mat));
modelNames = hmDir.mat;


%%% Step 3: Find paths to WBMs and find which WBMs are mWBMs and iWBMs %%%

% Check which WBMs are mWBMs
mWBMs = contains(modelNames,'mWBM');
microbiomePresent = any(mWBMs);

% Check which WBMs are iWBMs or miWBMs
iWBMs = contains(modelNames,'iWBM');

% If no iWBMs exist, add germ-free WBMs to investigate
if ~any(iWBMs) && all(mWBMs) && analyseGF

    % Find all male and female WBMs
    maleWBMs = modelNames(contains(modelNames,'_male'));
    femaleWBMs = modelNames(contains(modelNames,'_female'));

    if ~isempty(maleWBMs) % Add male germ-free model to investigate
        gfWBM = strrep(maleWBMs{1},'mWBM','gfWBM');
        modelNames{end+1} = gfWBM;
        hmPaths(end+1) = [hmDir.path filesep maleWBMs{1}];
    end

    if ~isempty(femaleWBMs) % Add male germ-free model to investigate
        gfWBM = strrep(femaleWBMs{1},'mWBM','gfWBM');
        modelNames{end+1} = gfWBM;
        hmPaths(end+1) = [hmDir.path filesep femaleWBMs{1}];
    end
end

if all(iWBMs) && analyseGF % Add a germfree model for each miWBM

    extraModelNames = strrep(modelNames, 'miWBM', 'gfiWBM');
    modelNames = [modelNames;extraModelNames];

    % Duplicate the number of models to investigate to account for the
    % gfiWBMs
    hmPaths = [hmPaths;hmPaths];
end

if ~all(mWBMs) && ~all(iWBMs)
    error('The mWBMPath contains no mWBMs and does not solely consist of iWBMs. Please make sure that all WBMs are mWBMs or that all WBMs are iWBMs')
end

if ~all(iWBMs) && any(iWBMs)
    error('The mWBMPath contains both iWBM and non-iWBMs. Please make sure that all or none of the WBMs in mWBMPath are iWBMs')
end

% create sense for each onjective
if isempty(rxnSense) || isempty(rxnSense{1,1})
    % Use default if empty or empty cell content
    sense = "max";
    rxnSense = repmat({sense}, numel(rxnList), 1);
elseif size(rxnSense, 1) == 1
    % Repeat the single entry
    rxnSense = repmat(rxnSense(1,1), numel(rxnList), 1);
end

% Check if all DM reactions are set to max
for m = 1:numel(rxnList)
    rxn = rxnList{m};
    % Determine sense
    sense = rxnSense{m};
    % Check for invalid sense on demand reactions
    if contains(rxn, 'DM') && strcmp(sense, 'min')
        warning('Sense for all demand reactions must be MAX. Objective: %s sense changed to MAX ', rxn);
        rxnSense{m, 1} = 'max';  % correct it in the list
    end
end

% Set parellel pool
% Check if numWorkersOptimization is not a negative number are calls no workers.
if numWorkersOptimization > 0
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(numWorkersOptimization)
    else
        delete(poolobj);
        parpool(numWorkersOptimization);
    end
end

% Check if there are already results that can be skipped
if isfolder(fluxPath)
    disp('analyseWBMs -- Check for previous flux predictions and skip those that were already calculated.')
    % Find paths to already investigated models
    solvedModel = what(fluxPath).mat;
    solvedModel = strrep(solvedModel, 'FBA_sol_', '');

    % Find models that are already investigated and remove these models
    [~,~,idx] = intersect(solvedModel, modelNames);
    hmPaths(idx) = [];
    modelNames(idx) = [];
end

% Store environment variables and paths
environment = getEnvironment();
disp('analyseWBMs -- Perform FBA on WBMs.')

parfor i = 1:length(hmPaths)
    restoreEnvironment(environment);
    changeCobraSolver(solver, 'LP', 0, -1);

    % Load model
    disp(strcat("Load model ",string(i)))

    % Load model
    model = loadMinimalWBM(hmPaths(i));

    % Create germ-free WBMs if modelnames(i) contains "gf".
    makeGF = false;
    if contains(modelNames(i),'gfWBM') || contains(modelNames(i),'gfiWBM')&& analyseGF
        makeGF = true;
    end

    % Enforce a user defined diet if the diet has not already been set.
    % Note that the original diet of the loaded models should not be
    % overwritten as it might contain diet components that are essential
    % for the model feasibility.
    % if ~any(contains(fieldnames(model),'SetupInfo'))
    %     if ~isempty(Diet)
    %         model = setDietConstraints(model, Diet, 1);
    %     end
    % end
    
    model = prepareModel(model, rxnList, makeGF);

    % Preallocate solution
    solution = struct();

    % Add reactions
    solution.rxns = rxnList;

    % Add model names
    solution.ID = erase(modelNames(i),'.mat');

    % Add model sex
    solution.sex = cellstr(model.sex);

    % Preallocate v, y, and w
    solution.v = nan(length(model.rxns),length(rxnList));
    solution.y = nan(length(model.mets),length(rxnList));
    solution.w = nan(length(model.rxns),length(rxnList));

    if any(contains(model.rxns,'Micro_EX_'))
        % Find metabolite coefficients of the community biomass reaction
        communityCoef = full(model.S(:, contains(model.rxns,'communityBiomass')));

        % Find the negative coefficients, i.e., the pan taxon biomass
        % metabolites [c] and obtain taxa names.
        solution.taxonNames = erase(model.mets(communityCoef < 0),'_biomass[c]');

        % Find their relative abundance in percentages
        solution.relAbundances = -(communityCoef(communityCoef < 0));

        % Preallocate matrix for species biomass shadow prices
        solution.shadowPriceBIO = zeros(length(solution.taxonNames),length(solution.rxns));
    end

    % solve reactions
    for j = 1 : length(rxnList)
        % Set reaction objective
        model = changeObjective(model,rxnList{j});
        
         % Set objective function to user defined sense for the reaction
         model.osenseStr = rxnSense{j}

        % Open the reaction if it is a demand reaction
        if contains(rxnList(j),'DM_')
            model = changeRxnBounds(model,rxnList{j},100000,'u');
        end

       
        disp(strcat("Investigate reaction ", string(rxnList{j})))
        FBA = optimizeWBModel(model);

        % save solution
        if isempty(FBA.f)
            solution.f(1,j)=NaN;
        else
            solution.f(1,j)=FBA.f;
        end

        % Add LP and solver statistics
        solution.solver = FBA.solver;
        solution.osenseStr{1,j} = model.osenseStr;
        solution.stat(1,j)=FBA.stat;
        if isfield(solution, "origStat")
            solution.origStat(1,j)=FBA.origStat;
        else
            solution.OrigStat(1,j) = "Not available due to solver type";
        end


        if FBA.stat==1
            % Save the entire flux vector, all shadow prices, and reduced costs
            solution.v(:,j) = FBA.v;
            solution.y(:,j) = FBA.y;
            solution.w(:,j) = FBA.w;

            if any(contains(model.rxns,'Micro_EX_'))
                % Set the names of the biomass metabolites of the
                % panSpecies models so they can be found
                pantaxonNamesmassMet = strcat(solution.taxonNames, '_biomass[c]');
                % Save species biomass shadow prices
                solution.shadowPriceBIO(:,j) = FBA.y(matches(model.mets,pantaxonNamesmassMet));
            end
        end
    end

    if saveFullRes
        % Save names and indices of reactions and metabolites
        solution.modelRxns = model.rxns;
        solution.modelMets = model.mets;

        % Save model flux bounds
        solution.modelLB = sparse(model.lb);
        solution.modelUB = sparse(model.ub);

        % Reduce size of vectors
        solution.v = sparse(solution.v);
        solution.y = sparse(solution.y);
        solution.w = sparse(solution.w);
    else
        solution = rmfield(solution,{'v','y','w'});
    end

    % Save solution
    fbaPath = [fluxPath filesep 'FBA_sol_' char(solution.ID)];
    parsave(fbaPath, solution)
end
%%

% Run flux processing pipeline
% Make an if statement here for GF/personalised testing
[FBA_results, pathsToFilesForStatistics] = analyseWBMsol(fluxPath,paramFluxProcessing, fluxAnalysisPath);

% slimDownFBAresults prunes FBA solution results obtained in
% analyseWBMs.m and saves the slimmed down solution results in a
% new folder. Running this function can save up to 1000X of storage.
smallFBAsolutionPaths = slimDownFBAresults(fluxPath);
end

function parsave(fname, data)
% Saves a data variable (e.g., model) from a parfor loop - might not work in R2105b
%
% USAGE:
%
%    parsave(fname, data)
%
% INPUTS:
%   fname:   name of file
%   data:    name of variable
% Adapted from Heinken 2019
% Author: TiH

% need to use v7.3 switch for very large variables
if isstruct(data)
    if isfield(data,'rxns')
        model = data;
        if length(model.rxns) < 300000
            save(fname,'-struct', 'model')
        else
            save(fname,'-struct', 'model','-v7.3')
        end
    end
else
    save(fname, 'data')
end

end

function model = prepareModel(model, rxnList, makeGF)

% Find demand reactions not yet in the model
dmReactions = setdiff(rxnList, model.rxns);

% Add demand reactions
if any(contains(dmReactions,'DM_'))

    % Obtain metabolites to add
    dm_mets = erase(dmReactions(contains(dmReactions,'DM_')),'DM_');

    % Add demand reactions
    [model,demandRxns] = addDemandReaction(model,dm_mets);
    
    % Close all demand reactions for no possible artifacts during
    % modelling
    model = changeRxnBounds(model,demandRxns,0,'b');
    
    % Check again if reactions are missing
    missingRxns = setdiff(rxnList,model.rxns);
    if ~isempty(missingRxns)
        disp(missingRxns')
        warning('The above reactions are not in the model')
    end  
else
    disp(dmReactions')
    warning('The above reactions are not in the model')
end

% Set the additional constraints

model = changeRxnBounds(model, 'Whole_body_objective_rxn', 1, 'b');

if contains(model.ID, 'mWBM')
    % enforce microbial growth (i.e., microbal fecal excretion) if the
    % microbiome is present
    model = changeRxnBounds(model, 'Excretion_EX_microbiota_LI_biomass[fe]', 1, 'b');
end

% If the model is supposed to be GF make it GF
if makeGF
    model = changeRxnBounds(model, 'Excretion_EX_microbiota_LI_biomass[fe]', 0, 'b');
    % Set the Micro_EX_ reaction to 0 as well as that was required to
    % have no microbiome influence.
    microbiomeTransportReactions = model.rxns(contains(model.rxns, 'Micro_EX_'));
    model = changeRxnBounds(model, microbiomeTransportReactions, 0, 'b');
end
end