function [tissueModel, coreRxn, nonCoreRxn,	zeroExpRxns, pruneTime, cRes] = mCADRE(model, expressionRxns, threshold_high, protectedRxns, checkFunctionality, eta, tol, ubiquityScore, confidenceScores)
% Use the mCADRE algorithm (`Wang et al., 2012`) to extract a context
% specific model using data. mCADRE algorithm defines a set of core
% reactions and prunes all other reactions based on their expression,
% connectivity to core and confidence score. The removal of reactions is not
% necessary performed to support the core of defined functionalities. Core
% reactions are only removed if supported by a certain number of
% zero-expression reactions.
%
% USAGE:
%
%    [tissueModel, coreRxn, nonCoreRxn,	zeroExpRxns, pruneTime, cRes] = mCADRE(model, expressionRxns, threshold_high, protectedRxns, checkFunctionality, eta, tol, ubiquityScore, confidenceScores)
%
% INPUTS:
%    model:                 input model (COBRA model structure)
%    expressionRxns:        expression data, corresponding to `model.rxns` (see
%                           `mapGeneToRxn.m`)
%    threshold_high:        reactions with expression higher than this threshold will be in
%                           the core reaction set (expression threshold)
%    protectedRxns:         cell with reactions names that are manually added to
%                           the core reaction set (i.e. {'Biomass_reaction'})
%    checkFunctionality:    Boolean variable that determine if the model should be able
%                           to produce the metabolites associated with the `protectedRxns`
%                           0: don't use functionality check (default value),
%                           1: include functionality check
%    eta:                   tradeoff between removing core and zero-expression
%                           reactions (default value: 1/3)
%    tol:                   minimum flux threshold for "expressed" reactions
%                           (default 1e-8)
%    ubiquityScore:         ubiquity scores corresponding to genes
%                           in `gene_id` quantify how often a gene is expressed accross samples.
%                           (default values defined in function of `threshold_high` value)
%    confidenceScores:      literature-based evidence for generic model,
%                           (default value = 0)
%
% OUTPUTS:
%    tissueModel:           pruned, context-specific model
%    coreRxn:               core reactions in model
%  	 nonCoreRxn:            non-core reactions in model
%    zeroExpRxns:           reactions with zero expression (i.e., measured zero, not just missing from expression data)
%    pruneTime:             total reaction pruning time
%    cRes:                  result of model checks (consistency/function)
%                           - vs. + : reaction `r` removed from generic model or not
%                           1 vs. 2: reaction `r` had zero or non-zero expression evidence
%                           `-x.y`: removal of reaction `r` corresponded with removal of `y` (num.) total core reactions
%                           `+x.1` vs. `x.0`: precursor production possible after removal of reaction `r` or not
%                           3: removal of reaction r by itself prevented production of required
%                           metabolites (therefore was not removed)
%
%
% `Wang et al. (2012). Reconstruction of genome-scale metabolic models for
% 126 human tissues using mCADRE. BMC Syst. Biol. 6, 153.`
%
% This script is an adapted version of the implementation from
% https://github.com/jaeddy/mcadre.
%
% .. Author: - Modified and commented by S. Opdam and A. Richelle, May 2017.

    if nargin < 7
        protectedRxns = [];
    end
    if nargin < 8
        checkFunctionality=0; %don't use functionality check
    end
    if nargin < 9
        eta = 1/3;% default value for tradeoff
    end
    if nargin < 10
        tol = 1e-8;% default tolerance
    end

    % Determine expression-based evidence for ranking reactions
    if nargin < 11
        %Gene expression data [0,1], scaled w.r.t. upper threshold (threshold_high)
        ubiquityScore = expressionRxns/threshold_high;
        ubiquityScore(ubiquityScore >= 1) = 1;
        % Penalize genes with zero expression, such that corresponding reactions
        % will be ranked lower than non-gene associated reactions.
        ubiquityScore(ubiquityScore <= 0) = -1e-6;
    end

    % Determine confidence level-based evidence for ranking reactions
    if nargin < 12
        confidenceScores=zeros(length(model.rxns),1);
        for i = 1:length(model.rxns)
            if ~isempty(model.confidenceScores{i})
                confidenceScores(i) = str2num(model.confidenceScores{i});
            end
        end
    end

    display('Processing inputs and ranking reactions...')

    [coreRxn, nonCoreRxn, rankNonCore, zeroExpRxns] = rankReactions(model, ubiquityScore, confidenceScores, protectedRxns);

    % Precursor are defined as the metabolites involved in the
    % reactions defined in protected reactions
    if checkFunctionality == 1 && ~isempty(protectedRxns)
    	precursorMets={};
    	for i=1:numel(protectedRxns)
        	colS_obj = findRxnIDs(model,protectedRxns{i});
            precursorMets = [precursorMets; model.mets(model.S(:,colS_obj)<0)];
        end

        genericStatus = checkModelFunction(model, precursorMets);

    else
    	precursorMets={};
    	genericStatus=1;
    end

    if genericStatus
    	display('Generic model passed precursor metabolites test');

        display('Pruning reactions...')
        t0 = clock;

        [tissueModel, cRes] = pruneModel(model, rankNonCore, coreRxn, zeroExpRxns, precursorMets, eta, tol, method);
        pruneTime = etime(clock,t0);
    else
    	error('Generic model failed precursor metabolites test')
    end

    tissueModel = removeUnusedGenes(tissueModel);

end
