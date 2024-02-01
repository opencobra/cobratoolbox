function [model, modelGenerationReport] = XomicsToModel(genericModel, specificData, param)
% Given a generic model, this funtion generates a specific model using constraints generated 
% from multi-omics data specific  to a particular cell type or context. 
% Specific data can be transcriptomics, proteomics,  metabolomics or literature-based 
% ("bibliomics") data, or combinations thereof.
%
% USAGE:
%
%    [model, modelGenerationReport] = XomicsToModel(genericModel, specificData, param)
%
% INPUT:
%   genericModel:     A generic COBRA model in standard format https://github.com/opencobra/cobratoolbox/blob/master/docs/source/notes/COBRAModelFields.md
%
%   * .S:    `m x n' stoichiometric matrix
%   * .b:     `m x 1` change in concentration with time
%   * .csense `m x 1` character array with entries in {L,E,G}
%   * .mets: `m x 1` cell array of metabolite identifiers
%   * .metNames: `m x 1` cell array of metabolite names
%   * .rxns: `n x 1` cell array of reaction identifiers
%   * .rxnNames: `n x 1` cell array of reaction names
%   * .lb:   `n x 1` double vector of lower bounds on reaction fluxes
%   * .ub:   `n x 1` double vector of upper bounds on reaction fluxes
%   * .genes: `g x 1` - cell array of Entrez ID
%   * .grRules `g x 1` - cell array of boolean gene-protein-reaction associations
%   * .rxnGeneMat `n x g` -  matrix with rows corresponding to reactions and columns corresponding to genes
%
% OPTIONAL INPUTS:
%%   genericModel:   A generic COBRA model in standard format with optional fields
%    * .metFormulas: `m x 1` cell array of metabolite formulae
%    * .c - `n x 1` linear objective coefficient vector
%    * .C - `k x n` Left hand side of C*v <= d
%    * .d - `k x 1` Right hand side of C*v <= d
%    * .dsense - `k x 1` character array with entries in {L,E,G}
%    * .beta - A scalar weight on minimisation of one-norm of internal fluxes. Default 1e-4. 
%              Larger values increase the incentive to find a flux vector to be thermodynamically feasibile in thermoKernel and decrease the incentive
%              to search the steady state solution space for a flux vector that results in certain reactions and metabolites to be active and present,
%              respectively.
%
%%  specificData:  A structure containing context-specific data:
%
%   * .activeGenes - cell array of Entrez ID of genes that are known to be active based on the bibliomic data (Default: empty).
%   * .inactiveGenes - cell array of Entrez ID of genes known to be inactive based on the bibliomics data (Default: empty).
%
%   * .activeReactions -cell array of reaction identifiers know to be active based on bibliomic data (Default: empty).
%   * .inactiveReactions - cell array of reaction identifiers know to be inactive based on bibliomic data (Default: empty).
%   * .coupledRxns -﻿Table containing information about the coupled reactions. This includes the coupled reaction identifier, the
%                    list of coupled reactions, the coefficients of those reactions, the constraint, the sense or the directionality of the constraint,
%                    and the reference (Default: empty).
%   * .essentialAA - cell array of reaction identifiers of exchange reactions denoting essential amino acids (Default: empty).
%
%   * .exoMet -﻿Table with the fluxes obtained from exometabolomics experiments. 
%   * .exoMet.mets: metabolite identifers
%   * .exoMet.rxns: reaction identifier
%   * .exoMet.rxnNames: reaction name
%   * .exoMet.mean: measured mean flux
%   * .exoMet.SD:  standard deviation of the measured flux,
%   * .exoMet.units: the flux units
%   * .exoMet.platform: platform used to measure it
%
%   * .mediaData -﻿Table containing information on metabolomic composition of fresh media (Default: empty)
%   * .mediaData.rxns: cell array of reaction identifiers
%   * .mediaData.mediumMaxUptake: maximum media uptake rate (same units as model.ub, e.g. umol/gDW/h))
%   * .mediaData.constraintDescription: description of each constraint
%
%   * .presentMetabolites.mets -﻿cell array of metabolites known to be present based on the bibliomics data (Default: empty).
%   * .presentMetabolites.weights -Weights on metabolites known to be present based on the bibliomics data (Default: empty).
%
%   * .absentMetabolites.mets -﻿cell array of metabolites known to be absent based on the bibliomics data (Default: empty).
%   * .absentMetabolites.weights -﻿Weights on metabolites known to be absent based on the bibliomics data (Default: empty).
%
%   * .rxns2add: table containing reactions to add to the generic model
%   * .rxns2add.rxns: cell array of reaction identifiers
%   * .rxns2add.rxnFormulas: cell array of reaction formulas
%   * .rxns2add.lb: vector of reaction lower bounds  
%   * .rxns2add.ub: vector of reaction upper bounds
%   * .rxns2add.geneRule: gene rules to which the reaction is subject
%
%   * .rxns2remove.rxns -﻿cell array of reaction identifiers to be removed from the generic model (Default: empty).
%
%   * .rxns2constrain -﻿Table where each row corresponds to a reaction to constrain (Default: empty).
%   * .rxns2constrain.rxns: reaction identifier
%   * .rxns2constrain.lb:
%   * .rxns2constrain.ub:
%   * .rxns2constrain.constraintDescription: description of each constraint
%   * .rxns2constrain.notes: notes such as references or special cases 
%
%   * .transcriptomicData -﻿Table with transcriptomic data, with one row per gene  (Default: empty)
%   * .transcriptomicData.genes - Entrez ID's of the gene corresponding to each transcript
%   * .transcriptomicData.expVal - Non-negative transcriptomic expression value i.e. linear scale.
%
%   * .proteomicData:﻿Table of proteomic data, with one row per protein (Default: empty)
%   * .proteomicData.genes: Entrez ID's of the gene corresponding to each protein
%   * .proteomicData.expVal: Non-negative abundance of each protein  i.e. linear scale.
%
%%  param: a structure containing the parameters for the function:
%   * .printLevel -﻿Level of verbose that should be printed (Default: 0).
%   * .debug -﻿Logical, should the function save its progress for debugging (Default: false).
%   * .addCoupledRxns -﻿Logical, determines if the flux of reactions specified in specificData.coupledRxns should be coupled (Default: true).
%   * .addSinksexoMet - Logical, should sink reactions be added for metabolites detected in exometabolomic data (if no exchange or sink is already present).
%   * .activeGenesApproach -﻿String with the name of the active genes approach will be used
%                           'oneRxnPerActiveGene' adds at least one reaction per active gene (Default)
%                           'deleteModelGenes' adds all reactions corresponding to an active gene (generates a larger model)
%
%   * .TolMaxBoundary -﻿The reaction boundary's maximum value (Default: 1000)
%   * .TolMinBoundary -﻿The reaction boundary's minimum value (Default: -1000)
%   * .boundPrecisionLimit -﻿Precision of flux estimate, if the absolute valueof the lower bound or the upper bound are lower
%                            than the boundPrecisionLimit but higher than 0 the value will be set to the boundPrecisionLimit 
%                            (Default: primal feasibility tolerance x 10).
%   * .closeIons -﻿Logical, it determines whether or not ion exchange reactions are closed. (Default: false).
%   * .closeUptakes -﻿Logical, decide whether or not all of the uptakes in the draft model will be closed (Default: false).
%   * .uptakeSign -﻿Sign for uptakes (Default: -1).
%
%
%   * .diaryFilename -﻿The location where a diary will be printed with the function output. (Default: 0).
%   * .fluxCCmethod -﻿String with thee name of the algorithm to be used for the flux consistency check (Possible options: 'swiftcc', 'fastcc' or 'dc', Default: 'fastcc').
%
%   * .modelExtractionAlgorithm - Model extraction algorithm to be used to extract the context-specific model 
%                           'thermoKernel' (Default)
%                           'fastCore'
%
%   * .fluxEpsilon -﻿Minimum non-zero flux value accepted for tolerance (Default: Primal feasibility tolerance X 10).
%   * .thermoFluxEpsilon -﻿Flux epsilon used in 'thermoKernel' (Default: Primal feasibility tolerance X 10).
%   * .findThermoConsistentFluxSubset - True to identify largest thermodynamically flux consistent set before extracting a subset with thermoKernel (Default: true)
%
%   * .weightsFromOmics - True to use weights derived from transcriptomic data when biasing inclusion of reactions with thermoKernel (Default: true)
%   * .curationOverOmics -﻿True to use literature curated data with priority over other omics data (Default: false).
%
%   * .inactiveGenesTranscriptomics - ﻿Logical, indicate if inactive genes in the transcriptomic analysis should be added to the list of inactive genes (Default: true).
%   * .transcriptomicThreshold - Logarithmic scale transcriptomic cutoff threshold for determining whether or not a gene is active (Default: 0).
%   * .thresholdP -﻿Logarithmic scale proteomic cutoff threshold for determining whether or not a gene is active (Default: 0).
%
%   * .growthMediaBeforeReactionRemoval - Logical, should the growth media data be added before the model extraction (Default: true).
%
%   * .metabolomicsBeforeExtraction - Logical, should the metabolomics data be added before the model extraction (Default: true).
%   * .boundsToRelaxExoMet - String indicating the type of bounds allowed to be relaxed when fitting metabolomic data
%                                'all'  - allow to relax bounds on all reactions
%                                'both'  - allow to relax both lower and upper bounds on reactions corresponding to specificData.exoMet.rxns (Default)
%                                'upper' - allow to relax both upper bounds on reactions corresponding to specificData.exoMet.rxns
%                                'lower' - allow to relax both lower bounds on reactions corresponding to specificData.exoMet.rxns
%   * .metabolomicWeights -﻿String indicating the type of weights to be applied for metabolomics fitting (Possible options: 'SD', 'mean' and 'RSD'; Default: 'SD')
%
%
%   * .nonCoreSinksDemands -﻿The type of sink or demand reaction to close is indicated by a string 
%                            (Possible options: 'closeReversible', 'closeForward', 'closeReverse', 'closeAll' and 'closeNone'; Default: 'closeNone').
%
%   * .relaxOptions -﻿A structure array with the relaxation options if the problem becomes infeasible, see relaxedFBA.m 
%   * .relaxOptions.steadyStateRelax (Default: param.relaxOptions.steadyStateRelax = 0).
%   * .relaxOptions.printLevel (Default: set to param.printLevel)
%           
%   * .setObjective - Linear objective function to optimise (Default: none).
%   * .biomassRxn -The biomass reaction that represents the growth capacity of cells 
%                  Possible options for Recon3: 'biomass_reaction' (Default: empty)
%   * .maintenanceRxn -The biomass maintenance reaction that represents the turnover and update capacity of cells 
%                      (Possible options for Recon3:'biomass_maintenance', 'biomass_maintenance_noTrTr') (Default: empty)
%
% OUTPUTS:
%    model:  A Context-specific COBRA model with the following fields (the
%            content of the variables specificData and param influences the
%            generation of new fields):
%
%        * .activeInactiveRxn - n x 1 vector indicating if a reaction is desigated
%           as present (1) absent (-1) or added by the XomicsToModel (0).
%        * .alpha1 - thermoKernel parameter (step 20).
%        * .beta - thermoKernel parameter (step 20).
%        * .C - The constraint matrix containing coefficients for coupled reactions (step 12).
%        * .coupledRxnIdxs - Vector containing the indexes of the coupled reactions (step 12).
%        * .coupledRxns - IDs of the coupled reactions (step 12).
%        * .ctrs - The constraint IDs for coupled reactions (step 12).
%        * .d - The constraint right hand side values for coupled reactions (step 12).
%        * .delta0 - thermoKernel parameter (step 20).
%        * .delta1 - thermoKernel parameter (step 20).
%        * .dsense - the constraint sense ('L': <= , 'G': >=, 'E': =), or a vector
%           for multiple constraints (default: ('L')) for coupled reactions
%           (step 12).
%        * .dummyMetBool - m x 1 boolean vector indicating dummy metabolites
%           i.e. contains(model.mets,'dummy_Met_'; step 19).
%        * .dummyRxnBool - n x 1 boolean vector indicating dummy reactions
%           i.e. contains(model.rxns,'dummy_Rxn_'; step 19).
%        * .exometRelaxation - Struct array identifying the reactions where the
%           bounds are relaxed (step 10/22)
%        * .exometRelaxationObj - Flux fitting used (step 10/22)
%        * .expressionRxns - n x 1 non-negative value for reaction expression,
%           corresponding to model.rxns. expressionRxns(j) is NaN when there
%           is no expression data for the genes corresponding to reaction
%           j (step 6).
%        * .fluxConsistentMetBool - m x 1 boolean vector indicating flux
%           consistent metabolites.
%        * .fluxConsistentRxnBool - n x 1 boolean vector indicating flux
%           consistent reactions.
%        * .fluxInConsistentMetBool - m x 1 boolean vector indicating flux
%           inconsistent metabolites.
%        * .fluxInConsistentRxnBool - n x 1 boolean vector indicating flux
%           inconsistent reactions.
%        * .forcedIntRxnBool - n x 1 boolean vector indicating the internal
%           reactions that are thermodynamically forced (step 20).
%        * .geneExpVal - Vector containing corresponding expression value for each gene
%           FPKM/RPKM; step 6).
%        * .lambda0 - thermoKernel parameter (step 20).
%        * .lambda1 - thermoKernel parameter (step 20).
%        * .lb_preconditioned - n x 1 vector containing the old lower bounds
%           prior to the media constraints (step 10/22).
%        * .ub_preconditioned - n x 1 vector containing the old upper bounds
%           prior to the media constraints (step 10/22).
%        * .lbpreSinkDemandOff - n x 1 vector with the original lower bounds
%           before colsing sink and demand reactions.
%        * .ubpreSinkDemandOff - n x 1 vector with the original upper bounds
%           before colsing sink and demand reactions.
%        * .metRemoveBool - m x 1 boolean vector of metabolites removed to form stoichConsistModel.
%        * .rxnRemoveBool - n x 1 boolean vector of reactions removed to form stoichConsistModel.
%        * .metUnknownInconsistentRemoveBool - m x 1 boolean vector indicating removed mets
%        * .rxnUnknownInconsistentRemoveBool - n x 1 boolean vector indicating removed rxns
%        * .presentAbsentMet - m x 1 vector indicating if a metabolite is desigated as present (1) absent (-1) or added by the XomicsToModel (0).
%        * .SInConsistentMetBool - m x 1 boolean vector indicating inconsistent mets.
%        * .SInConsistentRxnBool - n x 1 boolean vector indicating inconsistent rxns.
%        * .relaxationUsed - Logical value indicating if the model was relaxed during XomicsToModel.
%        * .rxnFormulas - n x 1 cell array containing the formulas of the reactions.
%        * .unknownSConsistencyMetBool - m x 1 boolean vector indicating unknown consistent mets (all zeros when algorithm converged perfectly!).
%        * .unknownSConsistencyRxnBool - n x 1 boolean vector indicating unknown consistent rxns (all zeros when algorithm converged perfectly!).
%        * .XomicsToModelParam - Parameters used to generate the model.
%        * .XomicsToModelSpecificData - Context-specific data used to generate the model.
%
% Requires The COBRA Toolbox and a linear optimisation solver (e.g. Gurobi) to be installed
%
% 2023 German Preciat, Agnieszka Wegrzyn, Xi Luo, Ronan Fleming

model = genericModel;

%% 1. Prepare data
feasTol = getCobraSolverParams('LP', 'feasTol');

% specificData default values
if ~exist('specificData','var')
    specificData = struct();
end
if ~isfield(specificData, 'essentialAA')
    %specificData.essentialAA = table({''});
    specificData.essentialAA = [];
end

% geneRules for rxns2add in correct format
if isfield(specificData, 'rxns2add')
    if ismember('geneRule', specificData.rxns2add.Properties.VariableNames)
        if isnumeric(specificData.rxns2add.geneRule)
            specificData.rxns2add.geneRule = num2cell(specificData.rxns2add.geneRule);
        else
            specificData.rxns2add.geneRule = regexprep(specificData.rxns2add.geneRule, '\.\d', '');
        end
    end
end
if ~isfield(specificData, 'rxns2remove')
    specificData.rxns2remove = [];
end

% param default values
if ~exist('param','var')
    param = struct();
end
if ~isfield(param, 'debug')
    param.debug = 0;
end
if ~isfield(param, 'inactiveReactions')
    param.inactiveReactions = []; %TODO needs cleanup
end
if ~isfield(param, 'metabolomicWeights')
    param.metabolomicWeights = 'SD';
end
if ~isfield(param, 'addCoupledRxns')
    param.addCoupledRxns = 1;
end
if ~isfield(param, 'transcriptomicThreshold')
    param.transcriptomicThreshold = 0;
end
if ~isfield(param, 'thresholdP')
    param.thresholdP = 0;
end
if ~isfield(param, 'TolMinBoundary')
    param.TolMinBoundary = -1e3;
end
if ~isfield(param, 'TolMaxBoundary')
    param.TolMaxBoundary = 1e3;
end
if ~isfield(param, 'closeUptakes')
    param.closeUptakes = 0;
end
if ~isfield(param, 'uptakeSign')
    param.uptakeSign = -1;
end
if ~isfield(param, 'fluxEpsilon')
    param.fluxEpsilon = feasTol*10;
end
if ~isfield(param, 'thermoFluxEpsilon')
    param.thermoFluxEpsilon = feasTol*10;
end
if ~isfield(param, 'printLevel')
    param.printLevel = 0;
end
if ~isfield(param, 'boundPrecisionLimit')
    param.boundPrecisionLimit = feasTol*10;
end
if ~isfield(param, 'weightsFromOmics')
    param.weightsFromOmics = 1;
end
if ~isfield(param, 'fluxCCmethod')
    param.fluxCCmethod = 'null_fastcc';
end
if ~isfield(param, 'curationOverOmics')
    param.curationOverOmics = 0;
end
if isfield(param, 'modelExtractionAlgorithm')
    if ~any(ismember(param.modelExtractionAlgorithm,{'thermoKernel','fastCore'}))
        error(['Unrecognised param.modelExtractionAlgorithm =' param.modelExtractionAlgorithm])
    end
else
    param.modelExtractionAlgorithm = 'thermoKernel';
end
if ~isfield(param, 'activeGenesApproach')
    param.activeGenesApproach = 'oneRxnPerActiveGene';
end
if ~isfield(param, 'diaryFilename')
    param.diaryFilename = 0;
end
if ~isfield(param, 'closeIons')
    param.closeIons = 0;
end
if ~isfield(param, 'nonCoreSinksDemands')
    param.nonCoreSinksDemands = 'closeNone';
end
if ~isfield(param, 'growthMediaBeforeReactionRemoval')
    param.growthMediaBeforeReactionRemoval = true;
end
if ~isfield(param, 'metabolomicsBeforeExtraction')
    param.metabolomicsBeforeExtraction = true;
end
if ~isfield(param, 'workingDirectory')
    param.workingDirectory = pwd;
end
if ~isfield(param, 'inactiveGenesTranscriptomics')
    param.inactiveGenesTranscriptomics = 1;
end
if ~isfield(param, 'findThermoConsistentFluxSubset')
    param.findThermoConsistentFluxSubset = 1;
end
if ~isfield(param,'plotThermoKernelStats')
    param.plotThermoKernelStats=0;
end
if ~isfield(param,'plotThermoKernelWeights')
    param.plotThermoKernelWeights=0;
end
if ~isfield(param, 'finalFluxConsistency')
    param.finalFluxConsistency = 0;
end

%relaxed FBA default options
if ~isfield(param, 'relaxOptions')
    param.relaxOptions = struct;
end
if ~isfield(param, 'relaxOptions')
    param.relaxOptions = struct;
end
if ~isfield(param.relaxOptions, 'steadyStateRelax')
    param.relaxOptions.steadyStateRelax = 0;
end
if ~isfield(param.relaxOptions, 'steadyStateRelax')
    param.relaxOptions.steadyStateRelax = 0;
end
if ~isfield(param.relaxOptions, 'printLevel')
    param.relaxOptions.printLevel = param.printLevel;
end
if ~isfield(param.relaxOptions, 'relaxedPrintLevel')
    param.relaxOptions.relaxedPrintLevel = 1;
end
if ~isfield(param, 'boundsToRelaxExoMet')
    param.boundsToRelaxExoMet = 'both';
end

% Start diary
if ischar(param.diaryFilename)
    diary(param.diaryFilename)
    fprintf('%s', 'XomicsToModel run, beginning at:')
    fprintf('%s\n',datetime)
    printDiary = true;
else
    printDiary = false;
end

%start with empty model generation report
modelGenerationReport = [];

% Record if constraint relaxation used at any stage of the process
relaxationUsed = 0;

% Remove transcriptomic information from the model
model.genes = regexprep(model.genes, '\.\d', '');
model.genes = unique(model.genes);
model.grRules = regexprep(model.grRules, '\.\d', '');
if isfield(model, 'rules')
    model = rmfield(model, 'rules');
end
if isfield(model, 'rxnGeneMat')
    model = rmfield(model, 'rxnGeneMat');
end

% activeGenes in correct format
if isfield(specificData, 'activeGenes')
    if isnumeric(specificData.activeGenes)
        %         warning('specificData.activeGenes should be a cell array')
        format long g
        tmp = cell(length(specificData.activeGenes), 1);
        for i = 1:length(specificData.activeGenes)
            tmp{i,1} = num2str(specificData.activeGenes(i));
        end
        specificData.activeGenes = tmp;
    end
    specificData.activeGenes = regexprep(specificData.activeGenes, '\.\d', '');
else
    specificData.activeGenes = [];
end

% inactiveGenes in correct format
if isfield(specificData, 'inactiveGenes')
    if isnumeric(specificData.inactiveGenes)
        %         warning('specificData.inactiveGenes should be a cell array')
        format long g
        tmp = cell(length(specificData.inactiveGenes),1);
        for i = 1:length(specificData.inactiveGenes)
            tmp{i,1} = num2str(specificData.inactiveGenes(i));
        end
        specificData.inactiveGenes = tmp;
    end
    specificData.inactiveGenes = regexprep(specificData.inactiveGenes, '\.\d', '');
else
    specificData.inactiveGenes = [];
end

% transcriptomicData in correct format
if isfield(specificData, 'transcriptomicData')
    if isnumeric(specificData.transcriptomicData.genes)
        %         warning('specificData.inactiveGenes should be a cell array')
        format long g
        tmp = cell(length(specificData.transcriptomicData.genes),1);
        for i = 1:length(specificData.transcriptomicData.genes)
            tmp{i,1} = num2str(specificData.transcriptomicData.genes(i));
        end
        specificData.transcriptomicData.genes = tmp;
    end
    specificData.transcriptomicData.genes = regexprep(specificData.transcriptomicData.genes, '\.\d', '');
end

% proteomicData in correct format
if isfield(specificData, 'proteomicData')
    if isnumeric(specificData.proteomicData.genes)
        %         warning('specificData.inactiveGenes should be a cell array')
        format long g
        tmp = cell(length(specificData.proteomicData.genes),1);
        for i = 1:length(specificData.proteomicData.genes)
            tmp{i,1} = num2str(specificData.proteomicData.genes(i));
        end
        specificData.proteomicData.genes = tmp;
    end
    specificData.proteomicData.genes = regexprep(specificData.proteomicData.genes, '\.\d', '');
end

%used if metabolomic data provided in terms of metabolite rather than
%reaction IDs otherwise report missing information/wrong format
if isfield(specificData, 'exoMet') && ~ismember('rxns', specificData.exoMet.Properties.VariableNames)
    if ismember('mets', specificData.exoMet.Properties.VariableNames)
        warning('no reaction IDs provided, they will be generated based on the metabolite IDs')
        allExRxns = model.rxns(findExcRxns(model));
        for i=1:length(specificData.exoMet.mets)
            if any(contains(allExRxns, strcat('_', specificData.exoMet.mets(i))))
                specificData.exoMet.rxns(i) = allExRxns(contains(allExRxns, strcat('_', specificData.exoMet.mets(i))));
            else
                specificData.exoMet.rxns(i) = {''};
            end
        end
    else
        warning('no reaction IDs or metabolite IDs provided, exoMet data will be discarded')
        rmfield(specificData, 'exoMet')
    end
    
    %this is not on by default, if not present remove rows with no rxns
    if isfield(param, 'addSinksexoMet') && param.addSinksexoMet
        modelGenerationReport.sinksAddedFromexoMet = [];
        if param.printLevel > 0
            disp('--------------------------------------------------------------')
            disp('Following sinks are added:')
        end
        for i = 1:length(specificData.exoMet.mets)
            if isempty(specificData.exoMet.rxns{i})
                model = addSinkReactions(model, specificData.exoMet.mets(i));
                specificData.exoMet.rxns(i) = strcat('sink_', specificData.exoMet.mets(i));
                modelGenerationReport.sinksAddedFromexoMet = [modelGenerationReport.sinksAddedFromexoMet; specificData.exoMet.rxns(i)];
                if specificData.printLevel > 1
                    specificData.exoMet.rxns(i)
                end
            end
        end
    else
        modelGenerationReport.exoMetNoRxnID = [];
        if param.printLevel > 0
            disp('--------------------------------------------------------------')
            disp('Following metabolites have no exchange reactions in the model (no rnxIDs):')
        end
        modelGenerationReport.exoMetNoRxnID = specificData.exoMet(find(cellfun(@isempty,specificData.exoMet.rxns')),:);
        if param.printLevel > 1
            specificData.exoMet.mets(find(cellfun(@isempty,specificData.exoMet.rxns')))
        end
        specificData.exoMet(find(cellfun(@isempty,specificData.exoMet.rxns')),:) = [];
    end
end

%metabolomicsTomodel requires rxnNames field to be present but it is not
%automatically generated, this part checks if it is present, and if not it
%is added to the specificData.exoMet from the model.rxnNames
if isfield(specificData, 'exoMet') && ~ismember('rxnNames', specificData.exoMet.Properties.VariableNames)
    [LIA,LOCB] = ismember(specificData.exoMet.rxns,model.rxns);
    specificData.exoMet.rxnNames(LIA,1)= model.rxnNames(LOCB(LOCB~=0));
end

%% 2. Generic model checks
if param.printLevel > 0
    disp('--------------------------------------------------------------')
    disp(' ')
    fprintf('%s\n','XomicsToModel input specificData:')
    disp(' ')
    disp(specificData)
    fprintf('%s\n','XomicsToModel input param:')
    disp(' ')
    disp(param)
end

% Remove fields that become inconsistent with addition/removal of reactions
if isfield(model, 'covf')
    model = rmfield(model, 'covf');
end
if isfield(model, 'SInConsistentRxnBool')
    model = rmfield(model, 'SInConsistentRxnBool');
end
if isfield(model, 'SInConsistentMetBool')
    model = rmfield(model, 'SInConsistentMetBool');
end

% Check original model's bounds
minBound = min(model.lb);
maxBound = max(model.ub);

% Properly name atp maintenance reaction
bool = contains(model.rxns,'DM_atp_c_');
if any(bool)
    model.rxns{bool} = 'ATPM';
    if param.printLevel > 0
        fprintf('%s\n','Replacing reaction name DM_atp_c_ with ATPM, because it is not strictly a demand reaction.')
        disp(' ')
    end
end

if ~isfield(model,'rxnNames')
    model.rxnNames=model.rxns;
end
% Fix demand reaction names
%DM_CE5026[c] -> Demand for 5-S-Glutathionyl-L-Dopa
rxnNamesToFixList = model.rxns(contains(model.rxns, {'DM_', 'EX_', '_'}) & strcmp(model.rxns, model.rxnNames));
for i = 1:length(rxnNamesToFixList)
    rxnBool = strcmp(model.rxns, rxnNamesToFixList{i});
    metBool = model.S(:, rxnBool) ~= 0;
    if nnz(metBool) == 1 && contains(rxnNamesToFixList{i}, 'DM_')
        model.rxnNames{rxnBool} = ['Demand for ' model.metNames{metBool}];
    elseif nnz(metBool) == 1 && contains(rxnNamesToFixList{i}, 'EX_')
        model.rxnNames{rxnBool} = ['Exchange for ' model.metNames{metBool}];
    elseif nnz(metBool) == 1 && contains(rxnNamesToFixList{i}, 'sink_')
        model.rxnNames{rxnBool} = ['Sink for ' model.metNames{metBool}];
    end
end

if ~isempty(model.rxns(model.S(contains(model.mets, 'h[i]'), :) ~= 0))
    if strcmp(param.modelExtractionAlgorithm, 'thermoKernel')
        [model, specificData, problemRxnList, fixedRxnList] = ...
            regulariseMitochondrialReactions(model, specificData, param.printLevel);
    end
end

% Check feasibility
sol = optimizeCbModel(model);
if param.printLevel > 0
    if  sol.stat ~= 1
        error('Infeasible generic input model.')
    else
        disp(' ')
        fprintf('%s\n', 'Feasible generic input model.')
        disp(' ')
    end
end

%% 2b. Set objective function (if provided) %TODO - check numbering
if isfield(param, 'setObjective')
    if ismember(param.setObjective, model.rxns) && ~isempty(param.setObjective) && sum(ismember(param.setObjective, model.rxns)) == 1
        if param.printLevel > 0
            disp('--------------------------------------------------------------')
            disp(' ')
            disp(['Setting objective function to ''' char(param.setObjective) ''])
            disp(' ')
        end
        model = changeObjective(model, param.setObjective);
    elseif isequal(param.setObjective, 'noObjective') || param.setObjective == "" || isempty(param.setObjective)
        if param.printLevel > 0
            disp('--------------------------------------------------------------')
            disp(' ')
            disp('Generating model without an objective function.')
            disp(' ')
        end
        model.c = zeros(size(model.c));
        param = rmfield(param, 'setObjective');
    end
else
    if param.printLevel > 0
        disp('--------------------------------------------------------------')
        disp(' ')
        disp('Generating model without an objective function.')
        disp(' ')
    end
    model.c = zeros(size(model.c));
end

%% 3. Add missing reactions - "bibliomics" (if provided)

% Add reactions (requires: rxns, mass balanced rxnFormulas
% optional:lb, ub, subSystems, grRules to add to the model)
if isfield(specificData, 'rxns2add') && ~isempty(specificData.rxns2add)
    
    if param.printLevel > 0
        disp(' ')
        disp('--------------------------------------------------------------')
        disp(['Adding ' num2str(numel(specificData.rxns2add.rxns)) ' reactions ...'])
        disp(' ')
    end
    
    % check if reaction formulas are provided and test if all reactions
    % have assigned a reaction formula
    if ~ismember('rxnFormulas', specificData.rxns2add.Properties.VariableNames)
        disp('No reaction formula provided. Reactions will not be added.');
    elseif any(cellfun('isempty',specificData.rxns2add.rxnFormulas))
        error(['Reaction(s): ' specificData.rxns2add.rxns{cellfun('isempty', specificData.rxns2add.rxnFormulas)} ...
            ' in specificData.rxns2add.rxns requires a reaction formula in specificData.rxns2add.rxnFormulas']);
    else
        
        % Check if lower and upper bounds were specified, if not, use
        % default for each boundary type
        if ~ismember('lb', specificData.rxns2add.Properties.VariableNames) || ~ismember('ub', specificData.rxns2add.Properties.VariableNames) || ...
             any(isnan(specificData.rxns2add.lb)) || any(isnan(specificData.rxns2add.ub))
            
            if param.printLevel > 0
                disp('Reaction boundaries not provided. Default (min and max) values will be used based on the reaction formula.');
            end
            
            if ismember('lb', specificData.rxns2add.Properties.VariableNames)
                missingLbBool = isnan(specificData.rxns2add.lb);
            else
                missingLbBool = true(size(specificData.rxns2add.rxnFormulas));
            end
                        
            if ismember('ub', specificData.rxns2add.Properties.VariableNames)
                missingUbBool = isnan(specificData.rxns2add.ub);
            else
                missingUbBool = true(size(specificData.rxns2add.rxnFormulas));
            end
            
            specificData.rxns2add.lb(missingLbBool & contains(specificData.rxns2add.rxnFormulas, '->')) = 0;
            specificData.rxns2add.ub(missingUbBool & contains(specificData.rxns2add.rxnFormulas, '->')) = param.TolMaxBoundary;
            
            specificData.rxns2add.lb(missingLbBool & contains(specificData.rxns2add.rxnFormulas, '<-')) = param.TolMinBoundary;
            specificData.rxns2add.ub(missingUbBool & contains(specificData.rxns2add.rxnFormulas, '<-')) = 0;
            
            specificData.rxns2add.lb(missingLbBool & contains(specificData.rxns2add.rxnFormulas, '<=>')) = param.TolMinBoundary;
            specificData.rxns2add.ub(missingUbBool & contains(specificData.rxns2add.rxnFormulas, '<=>')) = param.TolMaxBoundary;
        end
        
        % Assign subSystem if not provided
        if ~ismember('subSystem', specificData.rxns2add.Properties.VariableNames)
            specificData.rxns2add.subSystem = repelem({'Miscellaneous'}, numel(specificData.rxns2add.rxns), 1);
        end
        % Assign rxnNames (if there is not rxnNames data)
        if ~ismember('rxnNames', specificData.rxns2add.Properties.VariableNames)
            specificData.rxns2add.rxnNames = repelem({'Custom reaction'}, numel(specificData.rxns2add.rxns), 1);
        end
        % Assign grRules (if there is not grRules data)
        if ~ismember('geneRule', specificData.rxns2add.Properties.VariableNames)
            specificData.rxns2add.geneRule = repelem({''}, numel(specificData.rxns2add.rxns), 1);
        end
        % Check if the reactions are already in the model
        if any(ismember(specificData.rxns2add.rxns, model.rxns))
            
            if param.printLevel > 0
                disp([num2str(sum(ismember(specificData.rxns2add.rxns, model.rxns))) ...
                    ' reaction(s) is(are) already present in the model and will not be added:'])
                disp(specificData.rxns2add(ismember(specificData.rxns2add.rxns, model.rxns),:))
            end
            
            % Delete repeated reactions from the input data
            specificData.rxns2add(ismember(specificData.rxns2add.rxns, model.rxns),:) = [];
        end
        
        % Add reactions
        for i = 1:length(specificData.rxns2add.rxns)
            model = addReaction(model, specificData.rxns2add.rxns{i}, 'reactionFormula', ...
                specificData.rxns2add.rxnFormulas{i}, 'subSystem', specificData.rxns2add.subSystem{i},...
                'reactionName', specificData.rxns2add.rxnNames{i}, 'lowerBound', ...
                specificData.rxns2add.lb(i), 'upperBound', specificData.rxns2add.ub(i),...
                'geneRule', specificData.rxns2add.geneRule{i}, 'printLevel', param.printLevel);
        end
        %attempts to finds the reactions in the model which export/import from the model
        %boundary i.e. mass unbalanced reactions
        %e.g. Exchange reactions
        %     Demand reactions
        %     Sink reactions
        model = findSExRxnInd(model, [], param.printLevel - 1);
    end
    
end

%% 4. Identify core metabolites and reactions
% Based on bibliomic, metabolomic and cell culture data

%set core metabolites
if isfield(specificData, 'presentMetabolites')
    coreMetAbbr = specificData.presentMetabolites.mets;
else
    coreMetAbbr = [];
end

%remove duplicates
[coreMetAbbr, coreMetAbbr0] = deal(unique(coreMetAbbr));

% Set coreRxnAbbr
coreRxnAbbr = {};
if isfield(param, 'setObjective')
    coreRxnAbbr = cellstr(param.setObjective);
end
if isfield(param,'biomassRxn')
    coreRxnAbbr = [coreRxnAbbr; cellstr(param.biomassRxn)];
end
if isfield(param,'maintenanceRxn')
    coreRxnAbbr = [coreRxnAbbr; cellstr(param.maintenanceRxn)];
end
if isfield(specificData, 'rxns2add')
    coreRxnAbbr = [coreRxnAbbr; specificData.rxns2add.rxns];
end
if isfield(specificData, 'activeReactions')  && ~isempty(specificData.activeReactions)
    coreRxnAbbr = [coreRxnAbbr; specificData.activeReactions];
end
if isfield(specificData, 'rxns2constrain') && ~isempty(specificData.rxns2constrain)
    coreRxnAbbr = [coreRxnAbbr; specificData.rxns2constrain.rxns];
end
if isfield(specificData, 'coupledRxns') && ~isempty(specificData.coupledRxns)
    for i = 1:length(specificData.coupledRxns.coupledRxnsList)
        coreRxnAbbr = [coreRxnAbbr; split(specificData.coupledRxns.coupledRxnsList{i}, ', ')];
    end
end
if isfield(specificData, 'mediaData') && ~isempty(specificData.mediaData)
    coreRxnAbbr = [coreRxnAbbr; specificData.mediaData.rxns];
end

if isfield(specificData, 'exoMet') && ~isempty(specificData.exoMet) && ...
        ismember('rxns', specificData.exoMet.Properties.VariableNames)
    coreRxnAbbr = [coreRxnAbbr; model.rxns(ismember(model.rxns,specificData.exoMet.rxns))];
end

%remove duplicates
[coreRxnAbbr, coreRxnAbbr0] = deal(unique(coreRxnAbbr));

%compare core reactions
param.message = 'generic model';
[coreMetAbbrNew, coreRxnAbbrNew] = coreMetRxnAnalysis([],model, coreMetAbbr, ...
    coreRxnAbbr, [], [], param);

% Identify the stoichiometrically consistent subset of the model
massBalanceCheck = 0;
if param.printLevel > 0
    disp('--------------------------------------------------------------')
    disp(' ')
    disp('Identifying the stoichiometrically consistent subset...')
    disp(' ')
end
[~, ~, ~, ~, ~, ~, model, stoichConsistModel] = findStoichConsistentSubset(model, ...
    massBalanceCheck, param.printLevel, [], feasTol * 10);
% Example of how Recon3DModel reports, i.e. fully stoichiometrically
% consistent internal reactions
% --- Summary of stoichiometric consistency ----
%   5835	 10600	 totals.
%      0	  1809	 heuristically external.
%   5835	  8791	 heuristically internal:
%   5835	  8791	 ... of which are stoichiometrically consistent.
%      0	     0	 ... of which are stoichiometrically inconsistent.
%      0	     0	 ... of which are of unknown consistency.
% ---
%      0	     0	 heuristically internal and stoichiometrically inconsistent or unknown consistency.
%      0	     0	 ... of which are elementally imbalanced (inclusively involved metabolite).
%      0	     0	 ... of which are elementally imbalanced (exclusively involved metabolite).
%   5835	  8791	 Confirmed stoichiometrically consistent by leak/siphon testing.
% --- END ----

%compare core reactions
param.message = 'stoichiometric inconsistency';
[coreMetAbbr, coreRxnAbbr] = coreMetRxnAnalysis(model,stoichConsistModel, coreMetAbbr, coreRxnAbbr, [], [], param);

% Use the stoichiometrically consistent submodel henceforth
if isfield(model, 'metRemoveBool') || isfield(model, 'rxnRemoveBool')
    if any(model.metRemoveBool) || any(model.rxnRemoveBool)
        if param.printLevel > 0
            disp(' ')
            fprintf('%u%s\n',nnz(model.metRemoveBool), ' stoichiometrically inconsistent metabolites removed.')
            fprintf('%u%s\n',nnz(model.rxnRemoveBool), ' stoichiometrically inconsistent reactions removed.')
        end
        if param.printLevel > 1
            disp(' ')
            fprintf('%s\n','Table of removed reactions:')
            disp(' ')
            printConstraints(model, -inf, inf, model.rxnRemoveBool)
        end
        model = stoichConsistModel;
    else
        model = buildRxnGeneMat(model);
    end
end

% Feasibility check
sol = optimizeCbModel(model);
if  sol.stat ~= 1
    error('Infeasible stoichiometrically consistent model after adding new reactions.')
else
    if param.printLevel>0
        disp(' ')
        fprintf('%s\n\n','Feasible stoichiometrically consistent model with new reactions.')
    end
end

if param.debug
    save([param.workingDirectory filesep '4.debug_prior_to_setting_default_min_and_max_bounds.mat'])
end

%% 5. Set limit bounds

% Change default bounds to new default bounds
model.lb(model.lb == minBound) = param.TolMinBoundary;
model.ub(model.ub == maxBound) = param.TolMaxBoundary;

if min(model.lb) ~= param.TolMinBoundary
    model = changeRxnBounds(model, model.rxns(model.lb < param.TolMinBoundary), param.TolMinBoundary, 'l');
    model = changeRxnBounds(model, model.rxns(model.ub < param.TolMinBoundary), param.TolMinBoundary, 'u');
end
if max(model.ub) ~= param.TolMaxBoundary
    model = changeRxnBounds(model, model.rxns(model.lb > param.TolMaxBoundary), param.TolMaxBoundary, 'l');
    model = changeRxnBounds(model, model.rxns(model.ub > param.TolMaxBoundary), param.TolMaxBoundary, 'u');
end

if any(model.lb > model.ub)
    error('lower bounds greater than upper bounds')
end

if param.printLevel > 2
    printConstraints(model, param.TolMinBoundary, param.TolMaxBoundary)
end

sol = optimizeCbModel(model);
switch sol.stat
    case 0
        disp(sol.origStat)
        disp(sol)
        error('Infeasible model with default bounds.')
    case 1
        if param.printLevel > 0
            fprintf('%s\n', 'Feasible model with default bounds.')
        end
    case 2
        if param.printLevel > 0
            fprintf('%s\n', 'Unbounded model with default bounds.')
        end
    otherwise
        disp(sol.origStat)
        disp(sol)
        error('Infeasible model with default bounds.')
end

%% 6. Identify active genes
% Based on bibliomic, transcriptomic and proteomic data

% Include transcriptomic data
% Remove quasi transcript info from the model so model.genes is a list of
% entrezid
activeModelGeneBool = [];
if isfield(specificData, 'transcriptomicData') && ~isempty(specificData.transcriptomicData)
    
    if min(specificData.transcriptomicData.expVal) < 0
        warning('transcriptomic expression in specificData.transcriptomicData.expVal must be non-negative')
        specificData.transcriptomicData.expVal = specificData.transcriptomicData.expVal + ...
            min(specificData.transcriptomicData.expVal);
    end
    
    %identify genes without transcriptomic data using transcript info
    geneMissingTranscriptomicDataBool = ~ismember(model.genes, specificData.transcriptomicData.genes);
    
    if 1
        if param.printLevel > 0
            disp(' ')
            disp('--------------------------------------------------------------')
            disp(' ')
            fprintf('%s\n',['Assuming gene expression is NaN for ' ...
                int2str(nnz(geneMissingTranscriptomicDataBool)) ...
                ' genes where no transcriptomic data is provided.'])
        end
        model.geneExpVal = NaN * ones(size(model.genes, 1), 1);
    else
        if param.printLevel > 0
            disp(' ')
            disp('--------------------------------------------------------------')
            disp(' ')
            fprintf('%s\n',['Assuming gene expression is zero for ' ...
                int2str(nnz(geneMissingTranscriptomicDataBool)) ...
                ' genes where no transcriptomic data is provided.'])
        end
        model.geneExpVal = zeros(size(model.genes));
    end
    
    % Map transcriptomic genes onto model.genes
    [bool, locb] = ismember(specificData.transcriptomicData.genes, model.genes);
    
    if param.debug > 2
        genes1 = model.genes(locb(bool));
        genes2 = specificData.transcriptomicData.genes(bool);
        if ~isequal(genes1, genes2)
            error('section 5. wrong assignment of transcriptomics data to model genes (ismember)!')
        elseif param.printLevel > 0 && isequal(genes1, genes2)
            disp(' ')
            disp('--------------------------------------------------------------')
            disp(' ')
            fprintf('section 5. correct assignment of transcriptomics data to model genes (ismember)')
        end
    end
    
    if param.printLevel>=2
        histogram(log(specificData.transcriptomicData.expVal))
        title('Transcriptomic data log(expression) values')
    end
    
    model.geneExpVal(locb(bool)) = specificData.transcriptomicData.expVal(bool);
    activeModelGeneBool = model.geneExpVal >= exp(param.transcriptomicThreshold);
    
    if param.inactiveGenesTranscriptomics
        %append inactive genes to inactive genes list
        specificData.inactiveGenes = [specificData.inactiveGenes; model.genes(model.geneExpVal < exp(param.transcriptomicThreshold))];
    end
    
    if param.printLevel > 2
        var1 = log(model.geneExpVal(isfinite(model.geneExpVal)));
        figure()
        histogram(var1)
        ylim = get(gca, 'ylim');
        hold on
        line([param.transcriptomicThreshold param.transcriptomicThreshold], [ylim(1) ylim(2)], 'color', 'r', 'LineWidth', 2);
        t = text(param.transcriptomicThreshold, ylim(2) - [ylim(2) * 0.05], 'Threshold');
        t.FontSize = 14;
        hold off
        title('Expression threshold')
        ylabel('Number of genes')
        xlabel('Logarithmic mean expression value')
    end
    
    % Prepare data for mapExpressionToReactions
    expression.gene = specificData.transcriptomicData.genes;
    expression.value = specificData.transcriptomicData.expVal;
    
    if 0
        figure
        hist(log(expression.value))
        title('log(expression.value)')
    end
    
    % Calculate reaction expression based on transcriptomic data, where
    % data is not available NaN is propagated
    [model.expressionRxns, ~] = mapExpressionToReactions(model, expression);
    
    if param.printLevel > 2
        figure
        histogram(log(model.expressionRxns(isfinite(model.expressionRxns))))
        title('log(model.expressionRxns)')
        ylabel('Number of reactions')
    end
else
    model.geneExpVal = zeros(size(model.genes));
end

% Include proteomic data
if  isfield(specificData, 'proteomicData') && ~isempty(specificData.proteomicData)
    specificData.proteomicData.Properties.VariableNames = {'genes' 'expVal'};
    proteomics_data = specificData.proteomicData;
    proteomics_data.Properties.VariableNames = {'genes' 'expVal'};
    temp = {};
    if isnumeric(proteomics_data.genes)
        for i=1:length(proteomics_data.genes)
            temp(end + 1, 1) = {num2str(proteomics_data.genes(i))};
        end
        proteomics_data.geneId = temp;
    else
        proteomics_data.geneId = proteomics_data.genes;
    end
    modelProtein = false(length(proteomics_data.genes), 1);
    for i=1:length(proteomics_data.geneId)
        if ismember(proteomics_data.geneId(i), model.genes)
            modelProtein(i) = 1;
        end
    end
    modelProtein_Entrez = proteomics_data.genes(modelProtein);
    modelProtein_Value = proteomics_data.expVal(modelProtein);
    [activeProteins, inactiveProteins] = activeProteinList(modelProtein_Value, ...
        modelProtein_Entrez, param.thresholdP, param.printLevel - 1);
    if isnumeric(activeProteins)
        for i=1:length(activeProteins)
            temp(i) = {num2str(activeProteins(i))};
        end
        activeProteins = temp;
    end
    for i=1:length(model.genes)
        if ismember(model.genes(i), activeProteins)
            activeModelGeneBool(i) = 1;
        end
    end
end

% Active genes from transcriptomic and proteomic data
if ~any(activeModelGeneBool)
    activeEntrezGeneID = [];
else
    try
        activeEntrezGeneID = model.genes(activeModelGeneBool);
    catch
        activeEntrezGeneID = model.genes(find(activeModelGeneBool));
    end
end

% Active genes from manual curation
if isfield(specificData, 'activeGenes')
    activeEntrezGeneID = [activeEntrezGeneID; specificData.activeGenes];
end

%unique genes
[activeEntrezGeneID, activeEntrezGeneID0] = deal(unique(activeEntrezGeneID));

%% 7. Close ions
if param.closeIons && isfield(model,'metFormulas')
    %extracellular metabolites
    exMet = contains(model.mets, '[e]');
    % Look for metabolites of which their formulas are a single upper case
    ions = isstrprop(model.metFormulas, 'upper');
    ionsBool = cellfun(@(x) sum(x) == 1, ions);
    exIonsBool = exMet & ionsBool;
    exIonsBool(strcmp('O2', model.metFormulas)) = 0;
    exIonsBool(strcmp('X', model.metFormulas)) = 0;
    exIonsBool(strcmp('H', model.metFormulas)) = 0;
    %     {'na1[e]'}
    %     {'k[e]'  }
    %     {'ca2[e]'}
    %     {'cl[e]' }
    %     {'fe2[e]'}
    %     {'fe3[e]'}
    
    exIonsRxnBool  = getCorrespondingCols(model.S, exIonsBool, true(size(model.S, 2), 1), 'exclusive');
    %     {'EX_fe2[e]'}
    %     {'EX_fe3[e]'}
    model.lb(exIonsRxnBool) = 0;
    model.ub(exIonsRxnBool) = 0;
    
else
    exIonsRxnBool = zeros(size(model.rxns));
end

if param.debug
    save([param.workingDirectory filesep '7.debug_prior_to_exchange_constraints.mat'])
end

%% 8. Close exchange reactions
%attempts to finds the reactions in the model which export/import from the model
%boundary i.e. mass unbalanced reactions
%e.g. Exchange reactions
%     Demand reactions
%     Sink reactions

model = findSExRxnInd(model,[], param.printLevel - 1);
if param.closeUptakes && isfield(specificData, 'mediaData')
    coreRxnBool = ismember(model.rxns, coreRxnAbbr);
    
    if isfield(specificData, 'rxns2constrain')
        rxns2ConstrainBool = ismember(model.rxns, specificData.rxns2constrain.rxns);
    end
    
    if param.printLevel > 0
        disp(' ')
        fprintf('%s\n\n', 'Model statistics:')
        [nMet, nRxn] = size(model.S);
        fprintf('%u%s%u%s\n', nMet, ' x ', nRxn, ' stoichiometric matrix.')
        fprintf('%u%s\n', nnz(model.ExchRxnBool), ' exchange reactions.')
        fprintf('%u%s\n', nnz(model.ExchRxnBool & coreRxnBool), ' exchange reactions in the core reaction set.')
        if isfield(specificData, 'rxns2constrain')
            fprintf('%u%s\n', nnz(model.ExchRxnBool & rxns2ConstrainBool), ' exchange reactions in the rxns2Constrain set.')
        end
        disp(' ')
    end
    
    % Close all uptake by exchange reactions, except those with custom constraints
    if isfield(specificData, 'rxns2constrain')
        uptakesToCloseBool = model.ExchRxnBool & ~rxns2ConstrainBool & ~exIonsRxnBool & ~coreRxnBool & ~model.c~=0;
    else
        uptakesToCloseBool = model.ExchRxnBool & ~exIonsRxnBool & ~coreRxnBool & ~model.c~=0;
    end
    model = changeRxnBounds(model, model.rxns(uptakesToCloseBool), 0, 'l');
    if param.printLevel > 0
        fprintf('%u%s\n', nnz(uptakesToCloseBool), ' exchange reactions with uptake closed')
        disp(' ')
        if param.printLevel > 1
            disp(' ')
            printConstraints(model, -inf, inf, uptakesToCloseBool)
        end
    end
    if any(model.lb > model.ub)
        error('lower bounds greater than upper bounds')
    end
end

%% 9. Close sink and demand reactions - Set non-core sinks and demands to inactive
coreRxnBool = ismember(model.rxns, coreRxnAbbr);

model.model = model.lb;
model.ubpreSinkDemandOff = model.ub;

% Identify reaction type
sinkDemandBool = ~model.ExchRxnBool & ~model.SIntRxnBool;
reversibleBool = model.lb < 0 & model.ub > 0;
forwardBool = model.lb >= 0 & model.ub > 0;
reverseBool = model.lb < 0 & model.ub <= 0;

switch param.nonCoreSinksDemands
    case 'closeReversible'
        closeRxnBool = sinkDemandBool & reversibleBool & ~coreRxnBool;
    case 'closeForward'
        closeRxnBool = sinkDemandBool & forwardBool & ~coreRxnBool;
    case 'closeReverse'
        closeRxnBool = sinkDemandBool &  reverseBool & ~coreRxnBool;
    case 'closeAll'
        closeRxnBool = sinkDemandBool & ~coreRxnBool;
    case 'closeNone'
        closeRxnBool = false(size(model.S,2),1);
    otherwise
        error(['param.nonCoreSinksDemands = ' param.nonCoreSinksDemands ' is not a recognised option'])
end

if any(closeRxnBool)
    model.lb(closeRxnBool) = 0;
    model.ub(closeRxnBool) = 0;
    if param.printLevel > 0
        fprintf('%u%s\n',nnz(closeRxnBool), [' closed non-core sink/demand reactions via param.nonCoreSinksDemands = ' param.nonCoreSinksDemands])
    end
else
    disp(' ')
    fprintf('%s\n','Table of open non-core sink/demand reactions:')
    printConstraints(model, -inf, inf, ~model.ExchRxnBool & ~model.SIntRxnBool & ~coreRxnBool)
    fprintf('%u%s\n',nnz(~model.ExchRxnBool & ~model.SIntRxnBool & ~coreRxnBool), ' non-core sink/demand reaction bounds unchanged from generic model, see param.nonCoreSinksDemands.')
end

if param.printLevel > 0
    fprintf('%u%s\n', nnz(~model.ExchRxnBool & ~model.SIntRxnBool & coreRxnBool), ' core sink/demand reactions.')
    bool = ~model.ExchRxnBool & ~model.SIntRxnBool & coreRxnBool & (model.lb ~= 0 | model.ub ~= 0);
    fprintf('%u%s\n', nnz(bool), ' open core sink/demand reactions.')
    if any(bool)
        if param.printLevel > 1
            fprintf('%s\n','Table of open core sink/demand reactions:')
            printConstraints(model, -inf, inf, bool)
        end
    end
end

sol = optimizeCbModel(model);
if  sol.stat ~= 1
    relaxationUsed = 1;
    if param.printLevel > 0
        fprintf('%s\n', 'Infeasible after closing non-core sink/demand reactions. Trying relaxation...')
    end
    if 0
        % Try to unblock the core reactions
        relaxedFBAparam = param.relaxOptions;
        relaxedFBAparam.internalRelax = 0;
        relaxedFBAparam.exchangeRelax = 2;
        relaxedFBAparam.steadyStateRelax = 0;
        %                      * toBeUnblockedReactions - nRxns x 1 vector indicating the reactions to be unblocked
        %
        %                        * toBeUnblockedReactions(i) = 1 : impose v(i) to be positive
        %                        * toBeUnblockedReactions(i) = -1 : impose v(i) to be negative
        %                        * toBeUnblockedReactions(i) = 0 : do not add any constraint (default)
        bool = ismember(model.rxns,coreRxnAbbr);
        relaxedFBAparam.toBeUnblockedReactions = zeros(size(model.S, 2), 1);
        relaxedFBAparam.toBeUnblockedReactions(bool & model.lbpreSinkDemandOff >= 0 & model.ubpreSinkDemandOff > 0) = 1; % Forward
        relaxedFBAparam.toBeUnblockedReactions(bool & model.lbpreSinkDemandOff < 0 & model.ubpreSinkDemandOff <= 0) = -1; % Reverse
        [solution, modelTemp] = relaxedFBA(model, relaxedFBAparam);
    end
    [solution, modelTemp] = relaxedFBA(model, param.relaxOptions);
    if solution.stat == 1
        if param.printLevel > 0
            fprintf('%s\n', '.. relaxation worked.')
        end
        model = modelTemp;
    else
        error('Infeasible after closing non-core sink/demand reactions and relaxation failed.')
    end
elseif sol.stat == 1
    if param.printLevel > 0
        disp(' ')
        fprintf('%s\n\n', 'Feasible after closing non-core sink/demand reactions.')
    end
end

%% 
if param.metabolomicsBeforeExtraction && param.debug
    save([param.workingDirectory filesep '10.a.debug_prior_to_metabolomicsBeforeExtraction.mat'])
end

%% 10. Set growth media constraints, before model extraction
if param.metabolomicsBeforeExtraction
    % Growth media constraints, before any other constraint applied to model
    [model, specificData, coreRxnAbbr, modelGenerationReport] = ...
        growthMediaToModel(model, specificData, param, coreRxnAbbr, modelGenerationReport);
end

%% 
if param.metabolomicsBeforeExtraction && param.debug
    save([param.workingDirectory filesep '10.b.debug_prior_to_metabolomic_constraints.mat'])
end

%% 10. Set metabolic constraints, before model extraction
if param.metabolomicsBeforeExtraction
    % Metabolomic data constraints, before any other constraint applied to model
    [model, specificData, coreRxnAbbr, ~, modelGenerationReport] = ...
        metabolomicsTomodel(model, specificData, param, coreRxnAbbr, modelGenerationReport);
end

%%
if param.debug
    save([param.workingDirectory filesep '10.debug_prior_to_custom_constraints.mat'])
end

%% 11. Add custom constraints
modelBefore = model;
if isfield(specificData, 'rxns2constrain') && ~isempty(specificData.rxns2constrain)
    
    if param.printLevel > 0
        disp('--------------------------------------------------------------')
        disp(' ')
        disp('Adding custom constraints ...')
        disp(' ')
    end
    
    if strcmp(param.modelExtractionAlgorithm, 'thermoKernel') || strcmp(param.modelExtractionAlgorithm, 'fastCore')
        bool = strncmp(specificData.rxns2constrain.rxns, 'DM_', 3);
        if param.printLevel > 0
            fprintf('%s\n', ['modelExtractionAlgorithm = ' param.modelExtractionAlgorithm ...
                '. Ignoring specificData.rxns2constrain for demand reactions, i.e. with prefix DM_'])
            if param.printLevel > 1
                disp(specificData.rxns2constrain(bool, :))
            end
        end
        specificData.rxns2constrain(bool, :) = [];
    end
    [model, rxnsConstrained, rxnBoundsCorrected] = constrainRxns(model, specificData, param, 'customConstraints', param.printLevel);
    
    if param.printLevel > 1
        fprintf('%s\n','Table of custom constraints with non-default bounds:')
        rxnBool = ismember(model.rxns, specificData.rxns2constrain.rxns);
        printConstraints(modelBefore, param.TolMinBoundary, param.TolMaxBoundary, rxnBool, model, 0)
    end
    
    % Test feasibility
    sol = optimizeCbModel(model);
    if  sol.stat ~= 1
        relaxationUsed = 1;
        if param.printLevel > 0
            fprintf('%s\n', 'Infeasible after application of custom constraints. Trying relaxation...')
        end
        
        if 0
            customRelaxOptions = param.relaxOptions;
            customRelaxOptions.internalRelax = 1;
            customRelaxOptions.exchangeRelax = 1;
            customRelaxOptions.excludedReactions=ismember(model.rxns,'biomass_maintenance');
        else
            customRelaxOptions = param.relaxOptions;
            customRelaxOptions.steadyStateRelax = 1;
            customRelaxOptions.internalRelax = 0;
            customRelaxOptions.exchangeRelax = 0;
            customRelaxOptions.excludedReactions=ismember(model.rxns,{'biomass_maintenance','EX_thrthrarg[e]','EX_asntyrthr[e]','EX_thrasntyr[e]'});
        end
        
        [solution, modelTemp] = relaxedFBA(model, customRelaxOptions);
        if solution.stat == 1
            if param.printLevel > 0
                fprintf('%s\n', '.. relaxation worked.')
            end
            model = modelTemp;
        else
            error('Infeasible after application of custom constraints and relaxation failed.')
        end
    elseif sol.stat == 1
        if param.printLevel > 0
            disp(' ')
            fprintf('%s\n\n', 'Feasible after application of custom constraints.')
            disp(' ')
        end
    end
end

if param.debug
    save([param.workingDirectory filesep '11.debug_prior_to_setting_coupled_reactions.mat'])
end

%% 12. Set coupled reactions (if provided)
if param.addCoupledRxns == 1 && isfield(specificData, 'coupledRxns') && ~isempty(specificData.coupledRxns)
    
    if param.printLevel > 0
        disp('--------------------------------------------------------------')
        disp(' ')
        disp(['Adding ' num2str(numel(specificData.coupledRxns.couplingConstraintID)) ...
            ' sets of coupled reactions ...'])
        disp(' ')
    end
    
    % Check data
    assert(ismember('c', specificData.coupledRxns.Properties.VariableNames) && ...
        ~any(cellfun(@isempty, specificData.coupledRxns.c)), ...
        'Coefficients ''specificData.coupledRxns.c'' for coupledRxns are missing.');
    if ismember('d', specificData.coupledRxns.Properties.VariableNames) && isa(specificData.coupledRxns.d, 'double')
        assert(ismember('d', specificData.coupledRxns.Properties.VariableNames) && ...
            ~any(arrayfun(@isempty, specificData.coupledRxns.d)), ...
            'The right hand side of the C*v <= d constraint in ''specificData.coupledRxns.d'' is missing for at least 1 reaction');
    elseif ismember('d', specificData.coupledRxns.Properties.VariableNames) && isa(specificData.coupledRxns.d, 'cell')
        assert(ismember('d', specificData.coupledRxns.Properties.VariableNames) && ...
            ~any(cellfun(@isempty, specificData.coupledRxns.d)), ...
            'The right hand side of the C*v <= d constraint in ''specificData.coupledRxns.d'' is missing for at least 1 reaction');
    end
    
    assert(ismember('csence', specificData.coupledRxns.Properties.VariableNames) ...
        && ~any(cellfun(@isempty, specificData.coupledRxns.csence)), ...
        'The sense constraint in ''specificData.coupledRxns.csence'' (''L'': <= , ''G'': >=, ''E'': =), is missing for for at least 1 reaction');
    for i = 1:length(specificData.coupledRxns.coupledRxnsList)
        
        assert(~any(0 == findRxnIDs(model, split(specificData.coupledRxns.coupledRxnsList{i}, ', '))), 'A coupledRxn is missing in the model')
        % Add coupled reactions
        if isa(specificData.coupledRxns.d, 'double')
            model = addCOBRAConstraints(model, split(specificData.coupledRxns.coupledRxnsList{i}, ', '), ...
                specificData.coupledRxns.d(i), 'c', str2num(specificData.coupledRxns.c{i}), ...
                'dsense', specificData.coupledRxns.csence{i}, 'ConstraintID', specificData.coupledRxns.couplingConstraintID{i});
        elseif isa(specificData.coupledRxns.d, 'cell')
            model = addCOBRAConstraints(model, split(specificData.coupledRxns.coupledRxnsList{i}, ', '), ...
                specificData.coupledRxns.d{i}, 'c', str2num(specificData.coupledRxns.c{i}), ...
                'dsense', specificData.coupledRxns.csence{i}, 'ConstraintID', specificData.coupledRxns.couplingConstraintID{i});
        end
        
        coupledRxns(i, 1) = {split(specificData.coupledRxns.coupledRxnsList{i}, ', ')};
        if isa(specificData.coupledRxns.d, 'double')
            coupledRxns(i, 2) = num2cell(specificData.coupledRxns.d(i));
        elseif isa(specificData.coupledRxns.d, 'cell')
            coupledRxns(i, 2) = num2cell(specificData.coupledRxns.d{i});
        end
        
    end
    
    %TODO replace this with boolean vector
    model.coupledRxns = vertcat(coupledRxns{:, 1});
    model.coupledRxnIdxs = findRxnIDs(model, model.coupledRxns);
    
    if param.printLevel > 0
        disp(' ')
        disp(printCouplingConstraints(model, param.printLevel))
    end
    
    sol = optimizeCbModel(model);
    if  sol.stat ~= 1
        relaxationUsed = 1;
        if param.printLevel > 0
            fprintf('%s\n', 'Infeasible after adding coupling constraints. Trying relaxation...')
        end
        
        if 0
            customRelaxOptions = param.relaxOptions;
            customRelaxOptions.internalRelax = 1;
            customRelaxOptions.exchangeRelax = 1;
            customRelaxOptions.excludedReactions=ismember(model.rxns,'biomass_maintenance');
        else
            customRelaxOptions = param.relaxOptions;
            customRelaxOptions.steadyStateRelax = 1;
            customRelaxOptions.internalRelax = 0;
            customRelaxOptions.exchangeRelax = 0;
            customRelaxOptions.excludedReactions=ismember(model.rxns,{'biomass_maintenance','EX_thrthrarg[e]','EX_asntyrthr[e]','EX_thrasntyr[e]'});
        end
        
        [solution, modelTemp] = relaxedFBA(model, customRelaxOptions);
        if solution.stat == 1
            if param.printLevel > 0
                fprintf('%s\n', '.. relaxation worked.')
            end
            model = modelTemp;
        else
            error('Infeasible after application of adding coupling constraints and relaxation failed.')
        end
    else
        if param.printLevel > 0
            disp(' ')
            fprintf('%s\n\n','Feasible model after adding coupling constraints.')
        end
    end
end

if param.debug
    save([param.workingDirectory filesep '12.debug_prior_to_removing_inactive_reactions.mat'])
end

%% 13. Remove inactive reactions - "bibliomics" (if provided)
if (isfield(specificData, 'rxns2remove') && ~isempty(specificData.rxns2remove)) || isfield(specificData, 'inactiveReactions')
    %save old model
    oldModel = model;
    
    [nMet,nRxn] = size(model.S);
    if param.printLevel > 0
        disp('--------------------------------------------------------------')
        disp(' ')
    end
    
    if isfield(specificData, 'inactiveReactions')
        specificData.rxns2remove.rxns = unique([specificData.rxns2remove.rxns; specificData.inactiveReactions]);
    end
    
    % Check if the rxns2remove are present in coreRxnAbbr
    if any(ismember(specificData.rxns2remove.rxns, coreRxnAbbr)) && ~param.curationOverOmics
        rxnsIgnored = specificData.rxns2remove.rxns(ismember(specificData.rxns2remove.rxns, coreRxnAbbr));
        if param.printLevel > 0
            disp([num2str(numel(rxnsIgnored)), ...
                ' manually selected inactive reactions have been marked as active by omics data and will be discarded:'])
            disp(rxnsIgnored)
        end
        bool = ismember(specificData.rxns2remove.rxns, coreRxnAbbr);
        specificData.rxns2remove(bool,:) = [];
    elseif any(ismember(specificData.rxns2remove.rxns, coreRxnAbbr)) && param.curationOverOmics
        rxnsIgnored = coreRxnAbbr(ismember(coreRxnAbbr, specificData.rxns2remove.rxns));
        if param.printLevel > 0
            disp([num2str(numel(rxnsIgnored)), ...
                ' manually selected inactive reactions have been marked as active by omics data and will be discarded in omics data:'])
            disp(rxnsIgnored)
        end
        coreRxnAbbr(ismember(coreRxnAbbr, specificData.rxns2remove.rxns)) = [];
    end
    
    if param.printLevel > 0
        disp(['Removing ' num2str(numel(specificData.rxns2remove.rxns)) ' reactions ...'])
        disp(' ')
        if any(~ismember(specificData.rxns2remove.rxns, model.rxns))
            disp('The following reaction(s) to be removed is(are) not in the model:')
            notInModel = specificData.rxns2remove.rxns(~ismember(specificData.rxns2remove.rxns, model.rxns));
            disp(notInModel)
        end
    end
    
    % Remove inactive reactions
    rxnInModelBool = ismember(specificData.rxns2remove.rxns, model.rxns);
    specificData.rxns2remove(~rxnInModelBool, :) = [];
    
    modelTemp = changeRxnBounds(model, specificData.rxns2remove.rxns, 0, 'b');
    
    % Check feasibility
    sol = optimizeCbModel(modelTemp);
    if  sol.stat ~= 1
        inactiveRelaxOptions=param.relaxOptions;
        inactiveRelaxOptions.internalRelax = 2;
        inactiveRelaxOptions.exchangeRelax = 1;
        %only allow to relax the bounds that have changed
        inactiveRelaxOptions.excludedReactionLB = true(nRxn, 1);
        inactiveRelaxOptions.excludedReactionLB(modelTemp.lb ~= model.lb) = 0;
        inactiveRelaxOptions.excludedReactionUB = true(nRxn, 1);
        inactiveRelaxOptions.excludedReactionUB(modelTemp.ub ~= model.ub) = 0;
        inactiveRelaxOptions.relaxedPrintLevel = 1;
        [~, modelTemp] = relaxedFBA(modelTemp, inactiveRelaxOptions);
        
        if isempty(modelTemp)
            error('removing inactive reaction causes the model to be infeasible, unable to relax')
        else
            model = modelTemp;
        end
    else
        model = removeRxns(model, specificData.rxns2remove.rxns, 'metRemoveMethod', ...
            'exclusive', 'ctrsRemoveMethod','infeasible');
    end
    
    sol = optimizeCbModel(model);
    if  sol.stat ~= 1
        error('Infeasible model after removing inactive reactions.')
    else
        if param.printLevel > 0
            disp(' ')
            fprintf('%s\n\n','Feasible model after removing inactive reactions.')
        end
    end
    
    %check if core metabolites or reactions have been removed
    param.message = 'bibliomic inactive reactions';
    [coreMetAbbr, coreRxnAbbr] = coreMetRxnAnalysis(oldModel,model, coreMetAbbr, coreRxnAbbr, [], [], param);
end

if param.debug
    save([param.workingDirectory filesep '13.debug_prior_to_removing_inactive_genes.mat'])
end

%% 14. Remove inactive genes - "bibliomics" (if provided) (not present in the coreRxns)
if isfield(specificData, 'inactiveGenes') && ~isempty(specificData.inactiveGenes)
    %save input model
    oldModel = model;
    
    [nMet,nRxn] = size(model.S);
    if param.printLevel > 0
        disp('--------------------------------------------------------------')
        disp(' ')
        fprintf('%s\n',['Removing ' int2str(length(specificData.inactiveGenes)) ' inactive genes...'])
    end
    
    % Check if the inactive genes are present in omics data
    if ~isempty(activeEntrezGeneID)
        if any(ismember(specificData.inactiveGenes, activeEntrezGeneID)) && param.curationOverOmics
            %manual curation takes precedence over omics
            genesIgnoredBool = ismember(activeEntrezGeneID, specificData.inactiveGenes);
            if param.printLevel > 0
                disp([num2str(sum(genesIgnoredBool)), ...
                    ' active genes from the omics data have been manually assigned as inactive genes and will be discarded from the omics data:'])
                disp(activeEntrezGeneID(genesIgnoredBool))
                %https://blogs.mathworks.com/community/2007/07/09/printing-hyperlinks-to-the-command-window/
                %disp('This is a link to <a href="http://www.google.com">Google</a>.')
            end
            specificData.inactiveGenes(ismember(specificData.inactiveGenes, activeEntrezGeneID)) = [];
        elseif any(ismember(specificData.inactiveGenes, activeEntrezGeneID)) && ~param.curationOverOmics
            %omics takes precedence over manual curation
            genesIgnoredBool = ismember(specificData.inactiveGenes, activeEntrezGeneID);
            if param.printLevel > 0
                disp([num2str(sum(genesIgnoredBool)), ' manually selected inactive genes have been marked as active by omics data and will be discarded:'])
                disp(specificData.inactiveGenes(genesIgnoredBool))
            end
            activeEntrezGeneID(ismember(activeEntrezGeneID, specificData.inactiveGenes)) = [];
        end
    else
        if param.printLevel > 0
            disp('no manually selected active genes and omics data')
        end
    end
    % Check if the inactive genes are present in the model
    inactiveGeneBool = ismember(model.genes, specificData.inactiveGenes);
    if ~any(inactiveGeneBool)
        warning('None of the inactive genes were present in the model')
    else
        %check if there are any inactive genes that are not present in the
        %model
        absentGeneBool = ~ismember(specificData.inactiveGenes, model.genes);
        if any(absentGeneBool)
            if param.printLevel > 0
                disp([num2str(nnz(absentGeneBool)) ' inactive genes are not in the model to be removed.'])
            end
        end
        
        % Bool inactive genes
        inactiveGenesBool = ismember(model.genes, specificData.inactiveGenes);
        coreRxnsBool = ismember(model.rxns, coreRxnAbbr);
        genesFromCoreBool = any(model.rxnGeneMat(coreRxnsBool, :))';
        inactiveGenesNonCoreBool = inactiveGenesBool & ~genesFromCoreBool;
        inactiveGenesNonCore = model.genes(inactiveGenesNonCoreBool);
        
        % Find the reactions that would be deleted in response to deletion
        %of a gene
        [~, ~, deletedReactions, ~] = deleteModelGenes(model, model.genes(inactiveGenesNonCoreBool));
        
        % Set bounds of inactive reactions to zero
        modelTemp = changeRxnBounds(model, deletedReactions, 0, 'b');
        
        % Check feasibility
        sol = optimizeCbModel(modelTemp);
        if  ~sol.stat == 1
            if param.printLevel > 0
                fprintf('%s\n\n','Infeasible model after temporarily closing reactions corresponding to inactive genes, relaxing...')
            end
            relaxationUsed = 1;
            inactiveGenes1RelaxOptions = param.relaxOptions;
            inactiveGenes1RelaxOptions.internalRelax = 2;
            inactiveGenes1RelaxOptions.exchangeRelax = 0;
            %only allow to relax the bounds that have changed
            inactiveGenes1RelaxOptions.internalRelax = 2;
            inactiveGenes1RelaxOptions.exchangeRelax = 1;
            %only allow to relax the bounds that have changed
            inactiveGenes1RelaxOptions.excludedReactionLB = true(nRxn,1);
            inactiveGenes1RelaxOptions.excludedReactionLB(modelTemp.lb ~= model.lb) = 0;
            inactiveGenes1RelaxOptions.excludedReactionUB = true(nRxn, 1);
            inactiveGenes1RelaxOptions.excludedReactionUB(modelTemp.ub ~= model.ub) = 0;
            [solution, model] = relaxedFBA(modelTemp, inactiveGenes1RelaxOptions);
            % If relaxFBA has been used, check if the result is feasible
            if solution.stat == 0
                error('Infeasible model after removing inactive genes (that do not affect core reactions) and relaxation failed.')
            end
            %identify reactions not to be removed
            relaxedReactionBool = solution.p > feasTol | solution.q > feasTol;
            %remove reactions necessary to be relaxed from reactions to be deleted
            deletedReactions = setdiff(deletedReactions, model.rxns(relaxedReactionBool));
            
            if param.printLevel > 0
                disp([num2str(nnz(relaxedReactionBool))...
                    ' reaction(s) were not deleted based on inactive genes as their removal would cause the model to be infeasible.)'])
                if param.printLevel > 1
                    fprintf('%s\n','Table of reactions not removed based on inactive genes (that do not affect core reactions):')
                    printConstraints(model, -inf, inf, relaxedReactionBool);
                end
            end
            %add reaction to core reactions
            coreRxnAbbr = [coreRxnAbbr; model.rxns(relaxedReactionBool)];
        end
        
        [model, deletedMetabolites] = removeRxns(model, deletedReactions, 'metRemoveMethod', 'exclusive', 'ctrsRemoveMethod', 'infeasible');
        
        % Remove unused genes
        [model, inactiveGenes] = removeUnusedGenes(model);
        
        notInactiveGenes = setdiff(inactiveGenesNonCore,inactiveGenes);
        if param.printLevel > 0
            nNotInactiveGenes = numel(notInactiveGenes);
            fprintf('%s\n',[num2str(nNotInactiveGenes) ...
                ' genes were specified as inactive but not removed as they are' ...
                ' involved in reactions that may be catalysed by other gene products, or are essential.'])
        end
        if param.printLevel > 2
            disp(notInactiveGenes)
        end
        
    end
    
    % Check if core metabolites or reactions have been removed
    param.message = 'inactive genes';
    [coreMetAbbr, coreRxnAbbr] = coreMetRxnAnalysis(oldModel, model, coreMetAbbr, coreRxnAbbr, [], [], param);
    
    sol = optimizeCbModel(model);
    if  sol.stat == 1
        if param.printLevel > 0
            disp(' ')
            fprintf('%s\n\n', 'Feasible model after removing inactive genes (that do not affect core reactions).')
        end
    end
end

% if specificData.metabolomicsBeforeModelExtraction  == 1
%     modelGenerationReport=[];
%     [model, specificData, coreRxnAbbr, modifiedFluxes, modelGenerationReport] = metabolomicsTomodel(model, specificData, coreRxnAbbr, modelGenerationReport);
% end

%% 16. Test feasibility
% Test feasability & relax bounds if needed (only exchange reactions)

sol = optimizeCbModel(model);
if  sol.stat ~= 1
    if param.printLevel > 0
        fprintf('%s\n\n', 'Infeasible model after removing inactive genes (that do not affect core reactions), relaxing ...')
    end
    relaxationUsed = 1;
    
    % Allow to relax only exchange rxns
    inactiveGenes2RelaxOptions = param.relaxOptions;
    inactiveGenes2RelaxOptions.internalRelax = 0;
    inactiveGenes2RelaxOptions.exchangeRelax = 2;
    inactiveGenes2RelaxOptions.steadyStateRelax = 0;
    % Realx bounds to make it feasible
    [solution, modelTemp] = relaxedFBA(model, inactiveGenes2RelaxOptions);   
    if solution.stat == 0
        error('Infeasible model after removing inactive genes (that do not affect core reactions) and relaxation failed.')
    end
    model = modelTemp;
end

if param.debug
    save([param.workingDirectory filesep '16.debug_prior_to_flux_consistency_check.mat'])
end

%% 17. Find flux consistent subset (Gene information)

if any((model.ub-model.lb)<feasTol*10 & model.lb~=model.ub)
    disp('Reactions with small difference between upper and lower bounds, may cause difficulty with flux consistency ...')
    printConstraints(model,-inf,inf,(model.ub-model.lb)<feasTol*10 & model.lb~=model.ub)
end


if param.printLevel > 0
    disp('--------------------------------------------------------------')
    disp(' ')
    disp('Identifying flux consistent reactions ...')
    disp(' ')
end

[nMet, nRxn] = size(model.S);
if param.printLevel > 0
    fprintf('%u%s%u%s\n', nMet, ' x ', nRxn, ' stoichiometric matrix, before flux consistency.')
end

% Identify the flux consistent set
if 1
    paramFluxConsistency.epsilon = param.fluxEpsilon;
    paramFluxConsistency.method = param.fluxCCmethod;
    paramFluxConsistency.printLevel = param.printLevel;
else
    paramFluxConsistency.printLevel=1;
    paramFluxConsistency.method = 'null_fastcc';
end

[fluxConsistentMetBool, fluxConsistentRxnBool, fluxInConsistentMetBool, fluxInConsistentRxnBool, model, fluxConsistModel] =...
    findFluxConsistentSubset(model, paramFluxConsistency);


if ~any(fluxConsistentRxnBool)
    error('Model is completely flux inconsistent prior to tissue specific model generation')
end
if any(~fluxConsistModel.fluxConsistentRxnBool)
    error('fluxConsistModel must be completely flux consistent prior to tissue specific model generation')
end

% Find the set of flux inconsistent metabolites
fluxInConsistentMetAbbr = model.mets(~fluxConsistentMetBool);
% Find the set of flux inconsistent reactions
fluxInConsistentRxnAbbr = model.rxns(~fluxConsistentRxnBool);

param.message = 'flux inconsistency';
[coreMetAbbr, coreRxnAbbr] = coreMetRxnAnalysis(model,fluxConsistModel, coreMetAbbr, coreRxnAbbr, fluxInConsistentMetAbbr, fluxInConsistentRxnAbbr, param);

% Proceed with flux consistent model
model = fluxConsistModel;
[nMet, nRxn] = size(model.S);
if param.printLevel > 0
    fprintf('%u%s%u%s\n', nMet, ' x ', nRxn, ' stoichiometric matrix, after flux consistency.')
    disp(' ')
end

% Remove any unused genes from the model
model = removeUnusedGenes(model);

% Regenerate model.rxnGeneMat to be sure it is correct
model = buildRxnGeneMat(model);

sol = optimizeCbModel(model);
if  sol.stat ~= 1
    if param.printLevel > 0
        fprintf('%s\n\n', 'Infeasible model after findFluxConsistentSubset, relaxing ...')
    end
    relaxationUsed = 1;
    
    % Allow to relax only exchange rxns
    findFluxConsistentSubsetRelaxOptions = param.relaxOptions;
    findFluxConsistentSubsetRelaxOptions.internalRelax = 0;
    findFluxConsistentSubsetRelaxOptions.exchangeRelax = 2;
    findFluxConsistentSubsetRelaxOptions.steadyStateRelax = 0;
    % Realx bounds to make it feasible
    [solution, modelTemp] = relaxedFBA(model,  findFluxConsistentSubsetRelaxOptions);   
    if solution.stat == 0
        error('Infeasible model after findFluxConsistentSubset and relaxation failed.')
    end
    model = modelTemp;
end

if strcmp(param.modelExtractionAlgorithm, 'thermoKernel') && param.debug
    save([param.workingDirectory filesep '17.debug_prior_to_thermo_flux_consistency_check.mat'])
end

%% 18. Find thermodynamically consistent subset
% Identify the largest thermodynamically flux consistent subset (if the 
% thermoKernel algorithm is selected as the model extraction algorithm for step 20)
if strcmp(param.modelExtractionAlgorithm, 'thermoKernel')
    if param.findThermoConsistentFluxSubset
        
        if param.printLevel > 0
            disp('--------------------------------------------------------------')
            disp(' ')
            disp('Identifying thermodynamically flux consistent subset ...')
            disp(' ')
        end
        
        %         % Any forced non-zero internal reactions are assigned to be external
        %         % reactions
        %         model.forcedIntRxnBool = model.SConsistentRxnBool & ((model.lb > 0 & model.ub > 0) ...
        %           | (model.lb < 0 & model.ub < 0));
        %         if any(model.forcedIntRxnBool)
        %             if param.printLevel > 0
        %                 fprintf('%u%s\n', nnz(model.forcedIntRxnBool), ...
        %                   ' forced internal reactions, assumed to be external reactions while testing for thermodynamic feasibility.')
        %                 if param.printLevel > 1
        %                     printConstraints(model, -Inf, Inf, model.forcedIntRxnBool)
        %                 end
        %             end
        %         end
        %         originalSConsistentRxn = model.rxns(model.SConsistentRxnBool);
        %         originalSConsistentMet = model.mets(model.SConsistentMetBool);
        %
        %         model.SConsistentRxnBool = model.SConsistentRxnBool & ~model.forcedIntRxnBool;
        %         model.SConsistentMetBool = getCorrespondingRows(model.S, true(size(model.S, 1), 1), model.SConsistentRxnBool, 'inclusive');
        
        if ~isfield(model, 'thermoFluxConsistentMetBool')  || ~isfield(model, 'thermoFluxConsistentRxnBool') || 1
            paramThermoFluxConsistency.formulation = 'pqzw';
            paramThermoFluxConsistency.epsilon = param.thermoFluxEpsilon;
            paramThermoFluxConsistency.printLevel = param.printLevel - 1;
            paramThermoFluxConsistency.nMax = 40;
            paramThermoFluxConsistency.relaxBounds = 1; % Relax internal bounds to admit forced reactions
            paramThermoFluxConsistency.debug = param.debug;
            paramThermoFluxConsistency.secondaryRemoval = 0; % Assuming stoich. and flux consistent input.
            if 0
                % Assumes new thermodynamically flux inconsistent reactions due to new bounds on model
                paramThermoFluxConsistency.acceptRepairedFlux = 0;
            else
                % Assumes all thermodynamically flux inconsistent reactions due
                % to inconsistent bounds have already been removed, prior to
                % xomics2model
                paramThermoFluxConsistency.acceptRepairedFlux = 1;
            end
            paramThermoFluxConsistency.iterationMethod = 'random';
            
            [thermoFluxConsistentMetBool, thermoFluxConsistentRxnBool, model, thermoConsistModel]...
                = findThermoConsistentFluxSubset(model, paramThermoFluxConsistency);
            if ~any(thermoFluxConsistentRxnBool)
                error('Model is completely thermodynamically flux inconsistent prior to tissue specific model generation')
            end
            
            % Find the set of thermo flux inconsistent metabolites
            thermoFluxInConsistentMetAbbr = model.mets(~thermoFluxConsistentMetBool);
            % Find the set of thermo flux inconsistent reactions
            thermoFluxInConsistentRxnAbbr = model.rxns(~thermoFluxConsistentRxnBool);
            
            param.message = 'thermodynamic flux inconsistency';
            [coreMetAbbr, coreRxnAbbr] = coreMetRxnAnalysis(model, thermoConsistModel,...
                coreMetAbbr, coreRxnAbbr, thermoFluxInConsistentMetAbbr, ...
                thermoFluxInConsistentRxnAbbr, param);
            
            %proceed with thermodynamically consistent model
            model = thermoConsistModel;
        end
        
        if isfield(model,'DrGtMax') && isfield(model,'DrGtMin') && 0 %TODO
            rev = zeros(length(model.rxns), 1);
            rev(model.lb >= 0 & model.ub > 0) = 1;
            rev(model.lb < 0 & model.ub <= 0)= - 1;
            DrGtError = (model.DrGtMax - model.DrGtMin) / 2;
            
            bool = ~model.thermoFluxConsistentRxnBool & model.SConsistentRxnBool & rev == 1 & model.DrGtMean > 0 & DrGtError < abs(model.DrGtMean);
            
            selectRxns = model.rxns(bool);
            
            if 0
                DrGtMean = model.DrGtMean(bool);
                DrGtMin = model.DrGtMin(bool);
                DrGtMax = model.DrGtMax(bool);
                rev2 = rev(bool);
                
                outlierBool = isoutlier(DrGtMean) | 0;
                DrGtMean = DrGtMean(~outlierBool);
                DrGtMin = DrGtMin(~outlierBool);
                DrGtMax = DrGtMax(~outlierBool);
                rev2 = rev2(~outlierBool);
                selectRxns = selectRxns(~outlierBool);
            end
            
            if param.printLevel > 0
                fprintf('%u%s\n', length(selectRxns), ' thermodynamically flux inconsistent forward reactions with  DrGtMean > 0 and DrGtError < abs(DrGtMean).')
            end
            
            if param.printLevel > 1
                printConstraints(model, param.TolMinBoundary, param.TolMaxBoundary, ismember(model.rxns, selectRxns), [], 1)
            end
        end
        
        if param.printLevel > 0
            [nMet, nRxn] = size(model.S);
            fprintf('%u%s%u%s\n', nMet, ' x ', nRxn, ' stoichiometric matrix, after thermodynamic flux consistency.')
        end
        
        %         %make sure to reassign stoichiometric consistency to reactions that are forced
        %         boolRxn = ismember(model.rxns,originalSConsistentRxn);
        %         model.SConsistentRxnBool = model.SConsistentRxnBool | boolRxn;
        %         boolMet = ismember(model.mets,originalSConsistentMet);
        %         model.SConsistentMetBool = model.SConsistentMetBool | boolMet;
        %         clear boolMet boolRxn;
        
        % Remove any unused genes from the model
        model = removeUnusedGenes(model);
        
        % Regenerate model.rxnGeneMat to be sure it is correct
        model = buildRxnGeneMat(model);
        
        activeEntrezGeneID = unique(activeEntrezGeneID);
        
        if 0
            %apply thermodynamic flux consistency bounds
            model.lb_old = model.lb;
            thermoForwardOnlyBool = model.thermoFwdFluxConsistentRxnBool & ~model.thermoRevFluxConsistentRxnBool & model.lb < 0;
            if any(thermoForwardOnlyBool)
                model.lb(thermoForwardOnlyBool) = 0;
            end
            
            model.ub_old = model.ub;
            thermoReverseOnlyBool = ~model.thermoFwdFluxConsistentRxnBool & model.thermoRevFluxConsistentRxnBool & model.ub > 0;
            if any(thermoReverseOnlyBool)
                model.ub(thermoReverseOnlyBool) = 0;
            end
        end
        
        sol = optimizeCbModel(model);
        if  sol.stat ~= 1
            fprintf('%s\n','Infeasible after extraction of thermodynamically feasible subset, relaxing...')
            relaxationUsed = 1;
            thermoFeasRelaxOptions = param.relaxOptions;
            % Allow to relax only exchange rxns
            thermoFeasRelaxOptions.internalRelax = 0;
            thermoFeasRelaxOptions.exchangeRelax = 2;
            thermoFeasRelaxOptions.steadyStateRelax = 0;
            % Realx bounds to make it feasible
            [solution, modelTemp] = relaxedFBA(model, thermoFeasRelaxOptions);
            %             if param.printLevel > 0
            %                 disp('--------------------------------------------------------------')
            %                 disp('Relaxed fluxes:')
            %                 [model.rxns(idx) num2cell(model.lb(idx)) ...
            %                   num2cell(model.ub(idx)) num2cell(modelTemp.lb(idx)) num2cell(modelTemp.ub(idx)) modelTemp.constraintDescription(idx)]
            %                 disp(' ')
            %             end
            if solution.stat == 0
                error('Infeasible model after removing inactive genes (that do not affect core reactions) and relaxation failed.')
            end
            model = modelTemp;
        end
    else
        fprintf('%s\n','Extraction of thermodynamically feasible subset skipped.')
    end
end

if strcmp(param.activeGenesApproach,'oneRxnPerActiveGene') && param.debug
    save([param.workingDirectory filesep '18.debug_prior_to_create_dummy_model.mat'])
end

%% 19. Identify active reactions from genes
if ~isempty(activeEntrezGeneID)
    
    bool = ismember(activeEntrezGeneID, model.genes);
    if any(~bool)
        if param.printLevel > 0
            fprintf('%u%s\n', nnz(~bool), ' active genes not present in model.genes, so they are ignored.')
            if param.printLevel > 1
                disp(activeEntrezGeneID(~bool))
            end
        end
        activeEntrezGeneID = activeEntrezGeneID(bool);
    end
    
    switch param.activeGenesApproach
        case 'oneRxnPerActiveGene'
            
%             metsOrig = model.mets;
%             rxnsOrig = model.rxns;
            % Create a createDummyModel for the active genes
            [model, coreRxnAbbr] = createDummyModel(model, activeEntrezGeneID, param.TolMaxBoundary, param.modelExtractionAlgorithm,coreRxnAbbr, param.fluxEpsilon);
            
        case 'deleteModelGenes'
            [~, ~, rxnInGenes, ~] = deleteModelGenes(model, activeEntrezGeneID);
            coreRxnAbbr = unique([coreRxnAbbr; rxnInGenes]);
            
        otherwise
            error([param.activeGenesApproach ' is not a recognised option'])
    end
    
    if 0 && param.debug && param.findThermoConsistentFluxSubset
      
        % Identify the flux consistent set
        paramFluxConsistency.epsilon = param.fluxEpsilon;
        paramFluxConsistency.method = param.fluxCCmethod;
        paramFluxConsistency.printLevel = param.printLevel;
        [fluxConsistentMetBool, fluxConsistentRxnBool, fluxInConsistentMetBool, fluxInConsistentRxnBool, model, fluxConsistModel] =...
            findFluxConsistentSubset(model, paramFluxConsistency);
        
        param.message = 'dummy model flux inconsistency';
        [coreMetAbbr, coreRxnAbbr] = coreMetRxnAnalysis(model, fluxConsistModel, coreMetAbbr, coreRxnAbbr, [], [], param);
        
        paramThermoFluxConsistency.formulation = 'pqzw';
        paramThermoFluxConsistency.epsilon = param.thermoFluxEpsilon;
        paramThermoFluxConsistency.printLevel = param.printLevel - 1;
        paramThermoFluxConsistency.nMax = 40;
        paramThermoFluxConsistency.relaxBounds=0;
        paramThermoFluxConsistency.secondaryRemoval = 0; % Don't test for stoich and flux consistency again
        if 0
            % Assumes new thermodynamically flux inconsistent reactions due to new bounds on model
            paramThermoFluxConsistency.acceptRepairedFlux = 0;
        else
            % Assumes all thermodynamically flux inconsistent reactions due
            % to inconsistent bounds have already been removed, prior to
            % xomics2model
            paramThermoFluxConsistency.acceptRepairedFlux = 1;
        end
        paramThermoFluxConsistency.iterationMethod = 'random';
        [thermoFluxConsistentMetBool, thermoFluxConsistentRxnBool, model, thermoConsistModel]...
            = findThermoConsistentFluxSubset(model, paramThermoFluxConsistency);
        if ~any(thermoFluxConsistentRxnBool)
            error('Model is completely thermodynamically flux inconsistent prior to tissue specific model generation')
        end
        
        param.message = 'dummy model thermodynamic flux inconsistency';
        [coreMetAbbr, coreRxnAbbr] = coreMetRxnAnalysis(model, thermoConsistModel, coreMetAbbr, coreRxnAbbr, [], [], param);
    end
end

if param.debug
    save([param.workingDirectory filesep '19.debug_prior_to_create_tissue_specific_model.mat'])
end

%% 20. Model extraction
% extract a context specific model. 
modelExtraction


%% x. Final flux consistency
if param.finalFluxConsistency
    if param.debug
        save([param.workingDirectory filesep '21.debug_prior_to_finalFluxConsistency.mat'])
    end
    if 1
        paramConsistency.epsilon = param.fluxEpsilon;
        paramConsistency.method = param.fluxCCmethod;
        [fluxConsistentMetBool, fluxConsistentRxnBool, fluxInConsistentMetBool, fluxInConsistentRxnBool, model, fluxConsistModel]...
            = findFluxConsistentSubset(model, paramConsistency);
        
        solution = optimizeCbModel(fluxConsistModel);
        if solution.stat == 1
            model = fluxConsistModel;
        else
            disp(solution)
            warning('fluxConsistModel is not solving normally')
        end
        [nMet,nRxn]=size(model.S);
        fprintf('%u%s%u%s\n', nMet, ' x ', nRxn, ' stoichiometric matrix, after final flux consistency.')
    else
        switch param.modelExtractionAlgorithm
            case 'fastCore'
                
                paramConsistency.epsilon = param.fluxEpsilon;
                paramConsistency.method = param.fluxCCmethod;
                [fluxConsistentMetBool, fluxConsistentRxnBool, fluxInConsistentMetBool, fluxInConsistentRxnBool, model, fluxConsistModel]...
                    = findFluxConsistentSubset(model, paramConsistency);
                
                solution = optimizeCbModel(fluxConsistModel);
                if solution.stat == 1
                    model = fluxConsistModel;
                else
                    disp(solution)
                    warning('fluxConsistModel is not solving normally')
                end
                [nMet,nRxn]=size(model.S);
                fprintf('%u%s%u%s\n', nMet, ' x ', nRxn, ' stoichiometric matrix, after final flux consistency.')
                
            case 'thermoKernel'
                paramConsistency.epsilon = param.fluxEpsilon;
                paramConsistency.method = param.fluxCCmethod;
                [fluxConsistentMetBool, fluxConsistentRxnBool, fluxInConsistentMetBool, fluxInConsistentRxnBool, model, fluxConsistModel]...
                    = findFluxConsistentSubset(model, paramConsistency);
                
                solution = optimizeCbModel(fluxConsistModel);
                if solution.stat == 1
                    model = fluxConsistModel;
                else
                    disp(solution)
                    warning('fluxConsistModel is not solving normally')
                end
                
                [nMet,nRxn]=size(model.S);
                fprintf('%u%s%u%s\n',nMet,' x ', nRxn, ' stoichiometric matrix, after final flux consistency.')
                
                paramThermoFluxConsistency.formulation = 'pqzw';
                paramThermoFluxConsistency.epsilon = param.thermoFluxEpsilon;
                paramThermoFluxConsistency.printLevel = 1;
                paramThermoFluxConsistency.nMax = 20;
                paramThermoFluxConsistency.relaxBounds = 0;
                if 0
                    %assumes new thermodynamically flux inconsistent reactions due to new bounds on model
                    paramThermoFluxConsistency.acceptRepairedFlux = 0;
                else
                    %assumes all thermodynamically flux inconsistent reactions due
                    %to inconsistent bounds have already been removed, prior to
                    %xomics2model
                    paramThermoFluxConsistency.acceptRepairedFlux = 1;
                end
                [thermoFluxConsistentMetBool, thermoFluxConsistentRxnBool, model, thermoConsistModel] = ...
                    findThermoConsistentFluxSubset(model, paramThermoFluxConsistency);
                
                solution = optimizeCbModel(thermoConsistModel);
                if solution.stat == 1
                    model = thermoConsistModel;
                else
                    disp(solution)
                    warning('thermoConsistModel is not solving normally')
                end
                if param.printLevel > 0
                    [nMet, nRxn] = size(model.S);
                    fprintf('%u%s%u%s\n', nMet, ' x ', nRxn, ' stoichiometric matrix, after final thermodynamic flux consistency')
                end
        end
    end
end

%% 21. Growth media integration after extraction
if ~param.metabolomicsBeforeExtraction && param.debug
    save([param.workingDirectory filesep '21a.debug_prior_to_growthMediaToModel.mat'])
end

%%
if ~param.metabolomicsBeforeExtraction
    [model, specificData, coreRxnAbbr, modelGenerationReport] = ...
        growthMediaToModel(model, specificData, param, coreRxnAbbr, modelGenerationReport);
end

%% Metabolomic data integration, after extraction
if ~param.metabolomicsBeforeExtraction && param.debug
    save([param.workingDirectory filesep '21b.debug_prior_to_metabolomicsTomodel.mat'])
end

%%
if ~param.metabolomicsBeforeExtraction
    [model, specificData, coreRxnAbbr, ~ ,modelGenerationReport] = ...
        metabolomicsTomodel(model, specificData, param, coreRxnAbbr, modelGenerationReport);
end

%%
sol = optimizeCbModel(model);
if  sol.stat ~= 1
    disp('--------------------------------------------------------------')
    disp(' ')
    fprintf('%s\n','Infeasible at end of XomicsToModel.')
elseif sol.stat == 1
    if param.printLevel > 0
        disp(' ')
        fprintf('%s\n\n','Feasible at end of XomicsToModel.')
        disp(' ')
        disp('--------------------------------------------------------------')
    end
end

%% 21. Final adjustments

% Save the used specificData
model.XomicsToModelSpecificData = specificData;
model.XomicsToModelParam = param;

% subSystems as string array
model.subSystems(cellfun(@iscell, model.subSystems)) = [model.subSystems{cellfun(@iscell, model.subSystems)}];

% Add reaction formula
if ~isfield(model, 'rxnFormulas')
    model.rxnFormulas = printRxnFormula(model, 'printFlag', false);
end

% activeInactiveRxn
if isfield(specificData, 'rxns2remove') && ~isempty(specificData.rxns2remove)
    activeInactiveRxn = unique([coreRxnAbbr; specificData.rxns2remove.rxns]);
    inactiveBool = ismember(model.rxns, specificData.rxns2remove.rxns);
else
    activeInactiveRxn = coreRxnAbbr;
    inactiveBool = false;
end
model.activeInactiveRxn = double(ismember(model.rxns, activeInactiveRxn));
if any(inactiveBool)
    model.activeInactiveRxn(inactiveBool) = -1;
end

% presentAbsentMet
if isfield(specificData, 'presentMetabolites') && ~isempty(specificData.presentMetabolites)
    totalMets = specificData.presentMetabolites.mets;
    model.presentAbsentMet = double(ismember(model.mets, totalMets));
else
    model.presentAbsentMet = zeros(size(model.mets));
    totalMets = [];
end

% Record if constraint relaxation used
model.relaxationUsed = relaxationUsed;

% Order the fields in the new model
model = orderModelFields(model);

if param.debug
    save([param.workingDirectory filesep '22.debug_prior_to_debugXomicsToModel.mat'])
end



modelGenerationReport.coreRxnAbbr=coreRxnAbbr;
modelGenerationReport.coreMetAbbr=coreMetAbbr;
modelGenerationReport.activeEntrezGeneID=activeEntrezGeneID;

modelGenerationReport.coreRxnAbbr0=coreRxnAbbr0;
modelGenerationReport.coreMetAbbr0=coreMetAbbr0;
modelGenerationReport.activeEntrezGeneID0=activeEntrezGeneID0;

% Debug XomicsToModel
if param.debug && param.printLevel > 0
    fprintf('%s\n','debugXomicsToModel:')
    disp(' ')
    coreData.rxns = coreRxnAbbr0;
    coreData.genes = str2double(activeEntrezGeneID0);
    coreData.mets = totalMets;
    %should give same result
    if 1
        debugXomicsToModel(genericModel, [param.workingDirectory filesep], [], coreData)
    else
        debugXomicsToModel(genericModel, [param.workingDirectory filesep], modelGenerationReport)
    end
    disp('--------------------------------------------------------------')
end

% Turn off the diary
if printDiary
    diary off
    if param.printLevel > 0
        fprintf('%s\n', ['Diary written to: ' param.diaryFilename])
        fprintf('%s', 'XomicsToModel run is complete at:')
        fprintf('%s\n', datetime)
    end
end
