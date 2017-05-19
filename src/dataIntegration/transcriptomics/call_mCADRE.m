function tissueModel = call_mCADRE(model, gene_names, gene_exp, GPRmat, GPRrxns, core, threshold_high, checkv, eta, tol)
%Use the mCADRE algorithm (Wang et al., 2012*) to extract a context
%specific model using data. mCADRE algorithm defines a set of core
%reactions and prunes all other reactions based on their expression,
%connectivity to core and confidence score. The removal of reactions is not
%necessary performed to support the core of defined functionalities. Core
%reactions are only removed if supported by a certain number of
%zero-expression reactions.
%
%INPUTS
%
%   model               input model (COBRA model structure)
%   gene_names          gene identifiers corresponding to gene_exp
%                       ("findUsedGeneLevels.m")
%   gene_exp            gene expression corresponding to gene_id
%                       ("findUsedGeneLevels.m")
%   GPRmat              GPR matrix as returned by "extractGPRS.m"
%                       (parsedGPR)
%   GPRrxns             reaction cell as returned by "extractGPRS.m"
%                       (corrRxn)
%   core                cell with reactions names that are manually added to
%                       the core reaction set (i.e. {'Biomass_reaction'})
%   threshold_high                  reactions with expression higher than this threshold will be in 
%                       the core reaction set (expression threshold)
%   checkv              Boolean variable:
%                           0: don't use salvage pathway and functionality check
%                           1: include salvage pathway and functionality
%                           check
%   eta                 tradeoff between removing core and zero-expression
%                       reactions (1/3)
%   tol                 tolerance by which reaction fluxes are defined inactive
%                       (recommended lowest value 1e-8 since solver tolerance is 1e-9)
%
%
%OUTPUTS
%
%   tissueModel         extracted model
%
%*Wang et al. (2012). Reconstrcution of genome-scale metabolic models for
%126 human tissues using mCADRE. BMC Syst. Biol. 6, 153.
%
%This script is an adapted version of the implementation from
%https://github.com/jaeddy/mcadre. Modified by S. Opdam and A. Richelle,
%May 2017.

%Note that "Biomass_reaction" reaction is hard-coded to be active



% Set parameters for mcadre
    %method = 1; % fastFVA
    method = 2; % fastcc
    salvageCheck = checkv;
    metaboliteCheck = checkv;
    
    %Confidence scores formatting
    confidenceScores=zeros(length(model.rxns),1);
    for i = 1:length(model.rxns)
        if ~isempty(model.confidenceScores{i})
            confidenceScores(i) = str2num(model.confidenceScores{i});
        else
            confidenceScores(i) = NaN; %confidence scores which are not given
        end
    end
    
    %Gene expression data [0,1], scaled w.r.t. upper threshold (threshold_high)
    expression = gene_exp/threshold_high;
    expression(expression >= 1) = 1;
    
    % Run mcadre
    [PM, GM, C, NC, Z, model_C, pruneTime, cRes] = mcadre(model, gene_names, expression, confidenceScores, salvageCheck, metaboliteCheck, core, method, GPRrxns, GPRmat, eta, tol);
    tissueModel = PM;
    tissueModel = removeNonUsedGenes(tissueModel);
    
    is_active = fastcc(tissueModel, tol);
    inactiveRxns = setdiff(tissueModel.rxns, tissueModel.rxns(is_active));
    if ~isempty(inactiveRxns)
        warning('Extracted model is not consistent, this might be caused by (numerical) issues in fastcc consistency checks')
    end
end

function [PM, GM, C, NC, Z, model_C, pruneTime, cRes] = mcadre(model, G, U, confidenceScores, salvageCheck, metaboliteCheck, core, method, GPRrxns, GPRmat, eta, tol)
%INPUTS
%	model               original generic model
%	G                   list of genes in expression data
%	U                   ubiquity scores corresponding to genes in G
%	confidenceScores    literature-based evidence for generic model reactions
%	salvageCheck        option flag for whether to perform functional check for the
%                       nucleotide salvage pathway (1) or not (0)
%	C_H_genes           predefined high confidence reactions (optional)
%	method              1 = use fastFVA (glpk) to check consistency; 
%                       2 = use fastcc & cplex
%
%OUTPUTS
%	PM                  pruned, context-specific model
%	GM                  generic model (after removing blocked reactions)
%	C                   core reactions in GM
%	NC                  non-core reactions in GM
%	Z                   reactions with zero expression (i.e., measured zero, not just
%                       missing from expression data)
%	model_C             core reactions in the original model (including blocked)
%	pruneTime           total reaction pruning time
%	cRes                result of model checks (consistency/function)
%                       - vs. +: reaction r removed from generic model or not
%                       1 vs. 2: reaction r had zero or non-zero expression evidence
%                       -x.y: removal of reaction r corresponded with removal of y (num.) total
%                       core reactions
%                       +x.1 vs. x.0: precursor production possible after removal of 
%                       reaction r or not
%                       3: removal of reaction r by itself prevented production of required
%                       metabolites (therefore was not removed)




%         if nargin < 7
%             method = 1; % fastFVA
%         end
% 
%         if nargin < 6
%             core = [];
%         end
% 
%         if nargin < 5
%             salvageCheck = 1;
%         end

        % Generate order for reaction removal

        % Gene ubiquity scores are converted to reaction expression evidence to
        % define the core (C) and non-core (NC) reaction sets. Inactive reactions
        % are identified and removed from the global model to produce the generic
        % model (GM) for subsequent pruning. Non-core reactions are ordered first
        % by expression and then by connectivity evidence to give the list P. Any
        % reactions with zero expression (i.e., associated, but non-expressed
        % genes) are also listed in the vector Z.

        %display('Processing inputs and ranking reactions...')

        [GM, C, NC, P, Z, model_C] = rank_reactions(model, G, U, confidenceScores, core, method, GPRrxns, GPRmat);

        % Define inputs to the model pruning step

        % Define core vs. non-core ratio threshold for removing reactions
        %eta = 1/3;

        % Check functionality of generic model
        %changeCobraSolver('glpk');
        %load('precursorMets');
        
        %FIX: added option to skip metabolite check
        if metaboliteCheck == 1
            precursorMets = {'3pg[c]';'accoa[m]';'akg[m]';'e4p[c]';'f6p[c]';'g3p[c]';'g6p[c]';'oaa[m]';'pep[c]';'pyr[c]';'r5p[c]';'succoa[m]'};
            nonEssentialAA = {'ala-L[c]';'arg-L[c]';'asn-L[c]';'asp-L[c]';'gln-L[c]';'glu-L[c]';'gly[c]';'pro-L[c]';'ser-L[c]'};
            nucleotide = {'ctp[c]';'utp[c]'};
            lipid = {'pmtcoa[c]';'chsterol[c]';'tag_hs[c]';'dag_hs[c]';'mag_hs[c]';'crm_hs[c]';'pa_hs[c]';'pe_hs[c]';'ps_hs[c]'};
            precursorMets=[precursorMets;nonEssentialAA;nucleotide;lipid];
        else
            precursorMets={};
        end

        genericStatus = check_model_function(GM, 'requiredMets', precursorMets);

        if genericStatus
            %display('Generic model passed precursor metabolites test');
            if check_salvage_path(GM)
                %display('Generic model passed salvage path test');
            else
                %warning('Generic model passed precursor metabolites test');
            end
        
        % If generic functionality test is passed, prune reactions
            %display('Pruning reactions...')
            t0 = clock;

            [PM, cRes] = prune_model(GM, P, C, Z, eta, precursorMets, salvageCheck, method, tol);

            pruneTime = etime(clock,t0);
        else
            error('Generic model failed precursor metabolites test')
        end
end

function [GM, C, NC, P, Z, model_C] = rank_reactions(model, G, U, confidenceScores, core, method, GPRrxns, GPRmat)
%INPUTS
%	model
%	gene IDs from expression data
%	gene ubiquity scores (i.e., from mas5callToExpression)
%	C_H_genes	high confidence genes (optional)
%
%OUTPUTS
%	GM              generic model with inactive reactions removed
%	C               core reactions
%	NC              non-core reactions
%	P               removal order of non-core reactions

    if nargin < 6
        method = 1; % fastFVA
    end

    % Parse GPRs
    if nargin < 7
        %disp('No GPRs as input, calculate GPRs')
        [GPRrxns, GPRmat] = parse_gprs(model);
    end

    % Map high confidence genes to reactions
    % FIX: Modified to work with core reactions instead of core genes
    if nargin > 4
        is_C_H = false(size(model.rxns));
        for i = 1:length(core)
            ind = find(ismember(model.rxns,core{i}));
            is_C_H(ind) = true;
            %disp(['Reaction: ',model.rxns{ind},' was added to core'])
        end
    else is_C_H = false(size(model.rxns));
    end


    % Map gene ubiqiuty scores to reactions
    U_GPR = map_gene_scores_to_rxns(model, G, U, GPRmat);


    % Determine confidence level-based evidence
    E_L = confidenceScores;
    % Reactions with no confidence information should not be ranked higher than
    % those with non-zero confidence
    E_L(isnan(E_L)) = 0;


    % Calculate expression-based evidence
    E_X = calc_expr_evidence(model, GPRrxns, U_GPR, is_C_H);

    % FIX: In preprocessing it was decided which reactions go into core,
    % therefore core is only expression evidence of 1. (core = expression > threshold_high)
    C = model.rxns(E_X >= 1);
    model_C = C;


    % Initialize the consistent generic model & update evidence vectors
    % I'm not 100% convinced that we should do this before calculating the
    % connectivity-based evidence, but I'll look into this more later.

    % FIX: This step is skipped, since the model input was already
    % consistent
    %[GM, C, E_X, E_L] = initialize_generic_model(model, C, ...
    %    E_X, confidenceScores, method);
    GM = model;

    R_G = GM.rxns; 
    [NC, NC_idx] = setdiff(R_G, C);


    % Calculate connectivity-based evidence
    E_C = calc_conn_evidence(GM, E_X);


    % Rank non-core reactions
    E_X_NC = E_X(NC_idx); % expression-based evidence for non-core reactions
    E_C_NC = E_C(NC_idx); % connectivity-based evidence for non-core reactions
    E_L_NC = E_L(NC_idx); % literature-based evidence for non-core reactions
    [E_NC, NC_order] = sortrows([E_X_NC, E_C_NC, E_L_NC], [1, 2, 3]);
    P = NC(NC_order); % ordered (ranked) non-core reactions


    % Identify zero-expression reactions
    Z = P(E_NC(:, 1) == -1e-6);
end

function U_GPR = map_gene_scores_to_rxns(model, G, U, GPRmat)
    if ~iscellstr(model.genes)
        genes = strtrim(cellstr(num2str(model.genes)));
    else genes = model.genes;
    end
    
    % FIX: gene id's and model gene id's already match
    %genes = regexprep(genes, '\.[0-9]', '');
    U_GPR = nan(size(GPRmat));
    [geneInt, G_idx] = intersect(G, genes);
    for i = 1:numel(geneInt)
        gene_GPR = strcmp(GPRmat, geneInt{i});
        U_GPR(gene_GPR) = U(G_idx(i));
    end

    % Penalize genes with zero expression, such that corresponding reactions
    % will be ranked lower than non-gene associated reactions.
    U_GPR(U_GPR == 0) = -1e-6;
end

function [GPRrxns, GPRmat] = parse_gprs(model)
    warning('parse_gprs function was not validated!')
    numGPRs = cellfun('length', regexp(model.grRules, 'or'));

    noRules = cellfun('isempty', model.grRules);
    numGPRs(~noRules) = numGPRs(~noRules) + 1;

    numRows = sum(numGPRs); numCols = max(numGPRs);

    GPRmat = repmat({''}, numRows, numCols);
    GPRrxns = repmat({''}, numRows, 1);

    count = 1;
    for i = 1:numel(model.grRules)
        if numel(model.grRules{i})
            ruleGPRs = regexp(model.grRules{i}, 'or', 'split');
            ruleGPRs = regexprep(ruleGPRs, '[\s\(\)]', '');
            for j = 1:numel(ruleGPRs)
                GPR = regexp(ruleGPRs{j}, 'and', 'split');
                GPRmat(count,1:numel(GPR)) = GPR;
                GPRrxns(count) = model.rxns(i);
                count = count + 1;
            end
        end
    end

    GPRmat(:,sum(~cellfun('isempty', GPRmat), 1) == 0) = [];
    GPRmat = regexprep(GPRmat, '\.[0-9]', '');
end

function E_X = calc_expr_evidence(model, GPRrxns, U_GPR, is_C_H)
    E_X = zeros(size(model.rxns));
    U_GPR_min = min(U_GPR, [], 2);
    for i = 1:numel(model.rxns)
        rxn_GPRs = strmatch(model.rxns{i}, GPRrxns, 'exact');
        if numel(rxn_GPRs)
            E_X(i) = max(U_GPR_min(rxn_GPRs));
        end
    end
    % For reactions with no corresponding probe in expression data
    E_X(isnan(E_X)) = 0;
    E_X(is_C_H) = 1;
end

function E_C = calc_conn_evidence(model, E_X)
    % S matrix is binarized to indicate metabolite participation in each reaction
    Sbin = double(model.S ~= 0);

    % Adjacency matrix (i.e., binary reaction connectivity); the connection between
    % a reaction and itself is ignored by subtracting the identity matrix
    A = full(double(Sbin' * Sbin ~= 0));
    A = A - eye(size(A));

    % Influence matrix; describes the divided connectivity of reactions --
    % e.g., if R1 is connected to 4 reactions, its influence on each of those
    % reactions would be 0.25
    I = A ./ repmat(sum(A, 2), 1, size(A, 2));

    % Weighted influence matrix; each reaction's influence on others is
    % weighted by its expression score
    WI = repmat(E_X, 1, size(A, 2)) .* I;

    % Connectivity score; sum the influence of all connected reactions
    E_C = sum(WI)';
end

function [requiredMetsStatus, time] = check_model_function(model, varargin)
%INPUTS
%   model
% - optional inputs:
%       'requiredMets', metList
%       'biomass', biomassRxn
%       'media', mediaDef

    % FIX: for functionality checks do not constrain biomass
    model = changeRxnBounds(model,'Biomass_reaction',0,'l');
    
    % Parse input parameters
    if numel(varargin)
        if rem(numel(varargin), 2) == 0
            options = {'requiredMets', 'biomass', 'media'};
            for i = 1:2:numel(varargin)
                argname = varargin{i}; argval = varargin{i + 1};
                option = find(strncmpi(argname, options, numel(argname)));
                if ~isempty(option)
                    switch option
                        case 1
                            metList = argval;
                        case 2
                            error('%s option not yet implemented.', argname);
                            % biomassRxn = argval;
                        case 3
                            error('%s option not yet implemented.', argname);
                            % mediaDef = argval;
                    end
                else error('Unknown option %s.', argname)
                end
            end
        else error('Incorrect number of input arguments to function %s.', ...
                mfilename);
        end
    end

    %
    t0 = clock;
    
    %FIX: if metlist is empty, skip the step and always say the test is passed
    if isempty(metList)
        requiredMetsStatus = true;
        time = etime(clock, t0);
    else
        % Identify exchange reactions in the model
        exRxns = find_ex_rxns(model);

        % Turn off uptake of organic metabolites
        if exist('mediaDef', 'var')
            model = set_media_ex_bounds(model); % not implemented in this version
        else
            model = set_organic_met_bounds(model, exRxns);
        end

        % Allow uptake of glucose and CO2
        warning off all
        model = changeRxnBounds(model, 'EX_glc(e)', -5, 'l');
        model = changeRxnBounds(model, 'EX_co2(e)', -1000, 'l');
        warning on all

        % Add demand reactions for required metabolites
        if exist('metList', 'var')
            [model, requiredRxns] = specify_required_rxns(model, metList);
        else requiredRxns = {};
        end

        if exist('biomassRxn', 'var')
            requiredRxns = [requiredRxns, biomassRxn]; % not implemented in this version
        end

        inactiveRequired = check_rxn_flux(model, requiredRxns);

        requiredMetsStatus = ~numel(inactiveRequired);
        time = etime(clock, t0);
    end
end

function exRxns = find_ex_rxns(model)
    % Note: this function identifies all source or sink reactions, not just those
    % exchanging metabolites into and out of the extracellular space

    % Find indices of out-only reactions
    indOutRxns = sum(model.S > 0) > 0 & sum(model.S < 0) == 0;

    % Find indices of in-only reactions
    indInRxns = sum(model.S < 0) > 0 & sum(model.S > 0) == 0;

    % Define exchange reactions as the union of out- and in-only
    indExRxns = indOutRxns | indInRxns;

    exRxns = model.rxns(indExRxns);
end

function model = set_organic_met_bounds(model, exRxns)
    % Identify all exchange reactions that include organic metabolites
    organicExRxns = find_organic_ex_rxns(model, exRxns);

    % Reset all lower bounds for organic reactions to 0 to turn off uptake
    warning off all
    model = changeRxnBounds(model, organicExRxns, 0, 'l');
    warning on all
end

function organicExRxns = find_organic_ex_rxns(model, exRxns)
    % Note: should add a warning if the metFormulas field is empty
    % Organic metabolites are defined as those containing carbon (C) and hydrogen
    % (H); these are identified by checking molecular formulas
    if isempty(model.metFormulas); warning('metFormulas field is empty'); end
    carbonMets = ~cellfun('isempty', regexp(model.metFormulas, 'C'));
    hydrogenMets = ~cellfun('isempty', regexp(model.metFormulas, 'H'));
    is_organic = carbonMets & hydrogenMets;
    organicMets = model.mets(is_organic);

    organicRxns = findRxnsFromMets(model, organicMets);
    organicExRxns = intersect(organicRxns, exRxns);

    % The following reactions exchange organic metabolites (e.g., R-groups that
    % comprise lipid tails), but don't contain H in their specified formulas; OR,
    % as in the case of Tyr-ggn, include protein compounds
    organicExRxns = [organicExRxns; ...
        'EX_Rtotal(e)'; 'EX_Rtotal2(e)'; 'EX_Rtotal3(e)'; 'EX_Tyr_ggn(e)';'EX_peplys(e)']; % ; ...
        % 'UP_Tyr_ggn[c]']; % This rxn is not in Recon 1 - may be something specific
        % to Recon 2...
        % FIX: added PEPLYS
end

function [model, requiredRxns] = specify_required_rxns(model, metList)
    % note: the evalc() function is used to suppress printed outputs from Cobra
    % Toolbox functions addDemandReaction() and addReaction()

    coaMets = {'accoa[m]'; 'succoa[m]'; 'pmtcoa[c]'};
    [~, model, addedRxns] = evalc(['addDemandReaction(model,', ...
        'setdiff(metList, coaMets));']);

    % The following are not simple demand reactions, so must be added
    % separately as normal reactions.
    [~, model] = evalc(['addReaction(model, ''DM_accoa(m)'',', ...
        '{''accoa[m]''; ''coa[m]''},', ...
        '[-1; 1], 0, 0, 1000, 0);']);
    [~, model] = evalc(['addReaction(model, ''DM_succoa(m)'',', ...
        '{''succoa[m]''; ''coa[m]''},', ...
        '[-1; 1], 0, 0, 1000, 0);']);
    [~, model] = evalc(['addReaction(model, ''DM_pmtcoa(c)'',', ...
        '{''pmtcoa[c]''; ''coa[c]''},', ...
        '[-1; 1], 0, 0, 1000, 0);']);

    requiredRxns = [addedRxns, 'DM_accoa(m)', 'DM_succoa(m)', 'DM_pmtcoa(c)']';
end

function inactiveRequired = check_rxn_flux(model, requiredRxns)
    % This function uses the heuristic speed-up proposed by Jerby et al. in the MBA
    % paper for performing a pseudo-FVA calculation.
    rxnList = requiredRxns;
    inactiveRequired = [];
    while numel(rxnList)
        numRxnList = numel(rxnList);
        % model.rxns(strmatch('biomass_', model.rxns)); % not implemented
        model = changeObjective(model, rxnList);

        % Maximize all
        FBAsolution = optimizeCbModel(model, 'max');

        optMax = FBAsolution.x;
        % If no solution was achieved when trying to maximize all reactions, skip
        % the subsequent step of checking individual reactions
        if isempty(optMax)
            inactiveRequired = 1;
            break;
        end
        requiredFlux = optMax(ismember(model.rxns, requiredRxns));
        activeRequired = requiredRxns(abs(requiredFlux) >= 1e-8);
        rxnList = setdiff(rxnList, activeRequired);

        numRemoved = numRxnList - numel(rxnList);

        if ~numRemoved
            randInd = randperm(numel(rxnList));
            i = rxnList(randInd(1));
            model = changeObjective(model, i);

            % Maximize reaction i
            FBAsolution = optimizeCbModel(model, 'max');
            optMax = FBAsolution.f;
            if isempty(optMax)
                inactiveRequired = union(inactiveRequired, i);
                break;
            end
            if abs(optMax) < 1e-8
                inactiveRequired = union(inactiveRequired, i);
                break;
            end

            rxnList = setdiff(rxnList, i);
        end
    end
end

function [PM, cRes] = prune_model(GM, P, C, Z, eta, precursorMets, salvageCheck, method, tol)
    % Initialize variables
    R_G = GM.rxns;
    PM = GM;
    R_P = R_G;

    NC_removed = 0; C_removed = 0;
    cRes = zeros(3000, 1);
    count = 1;
    
    cutoff = Inf;

    %FIX: Biomass metabolite sinks do not have to be pruned
    nonBmsInd=cellfun(@isempty,strfind(P, 'BMS_'));
    P = P(nonBmsInd);
    
    while numel(P) && count < cutoff % for testing
        %display(['Reaction no. ', num2str(count)])
        r = P(1);
        %display(['Attempting to remove reaction ', r{:}, '...'])
        modelR = removeRxns(PM, r);

        % First check precursor production; if this test fails, no need to
        % check model consistency with FVA (time-saving step)
        rStatus = check_model_function(modelR, ...
            'requiredMets', precursorMets);

        % If specified, check the salvage pathway as well
        if salvageCheck
            rSalvage = check_salvage_path(modelR);
            rStatus = rStatus && rSalvage;
        end

        if rStatus

            % Check for inactive reactions after removal of r
            inactive_G = check_model_consistency(PM, method, r, tol);

            inactive_C = intersect(inactive_G, C);
            inactive_NC = setdiff(inactive_G, inactive_C);

            % Remove reactions with zero expression (previously penalized in
            % rank_reactions) and corresponding inactive core reactions, only if
            % sufficiently more non-core reactions are removed
            if ismember(r, Z) && ...
                ~any(ismember(inactive_C, 'Biomass_reaction'));
                %FIX: in rare cases mCADRE would remove all reactions, Biomass is hardcoded to always be active here
                %Comments "~any(is..)" out if this is not desired
                
                %display('Zero-expression evidence for reaction...')

                % Check model function with all inactive reactions removed
                modelTmp = removeRxns(PM, inactive_G);
                tmpStatus = check_model_function(modelTmp, ...
                    'requiredMets', precursorMets);

                % If specified, check the salvage pathway as well
                if salvageCheck
                    tmpSalvage = check_salvage_path(modelTmp);
                    tmpStatus = tmpStatus && tmpSalvage;
                end

                if (numel(inactive_C) / numel(inactive_NC) <= eta) && tmpStatus
                    R_P = setdiff(R_P, inactive_G);
                    PM = removeRxns(PM, inactive_G);
                    P(ismember(P, inactive_G)) = [];
                    NC_removed = NC_removed + numel(inactive_NC);
                    C_removed = C_removed + numel(inactive_C);
                    num_removed = NC_removed + C_removed;
                    %display('Removed all inactive reactions')

                    % result = -1.x indicates that reaction r had zero
                    % expression evidence and was removed along with any
                    % consequently inactivated reactions; x indicates the number of
                    % core reactions removed
                    if numel(inactive_C) > 100
                        removed_C_indicator = numel(inactive_C) / 100;
                    else removed_C_indicator = numel(inactive_C) / 10;
                    end
                    result = -1 - removed_C_indicator;
                else
                    % Note: no reactions (core or otherwise) are actually
                    % removed in this step, but it is necessary to update the
                    % total number of removed reactions to avoid errors below
                    num_removed = NC_removed + C_removed;
                    P(1) = [];
                    %display('No reactions removed')

                    % result = 1.x indicates that no reactions were removed
                    % because removal of r either led to a ratio of inactivated
                    % core vs. non-core reactions above the specified threshold
                    % eta (x = 1) or the removal of r and consequently
                    % inactivated reactions prevented production of required
                    % metabolites (x = 0)
                    result = 1 + tmpStatus / 10;
                end

            % If reaction has expression evidence, only attempt to remove
            % inactive non-core reactions
            else
                % Check model function with non-core inactive reactions removed
                modelTmp = removeRxns(PM, inactive_NC);
                tmpStatus = check_model_function(modelTmp, ...
                    'requiredMets', precursorMets);

                % If specified, check the salvage pathway as well
                if salvageCheck
                    tmpSalvage = check_salvage_path(modelTmp);
                    tmpStatus = tmpStatus && tmpSalvage;
                end

                if numel(inactive_C) == 0 && tmpStatus
                    R_P = setdiff(R_P, inactive_NC);
                    PM = removeRxns(PM, inactive_NC);
                    P(ismember(P, inactive_NC)) = [];
                    NC_removed = NC_removed + numel(inactive_NC);
                    num_removed = NC_removed + C_removed;
                    %display('Removed non-core inactive reactions')

                    % result = -2 indicates that reaction r had expression.
                    % evidence and was removed along with (only) non-core
                    % inactivated reactions; x indicates the number of
                    % core reactions removed (should be zero!)
                    if numel(inactive_C) > 100
                        removed_C_indicator = numel(inactive_C) / 100;
                    else removed_C_indicator = numel(inactive_C) / 10;
                    end
                    result = -2 - removed_C_indicator;
                else
                    num_removed = NC_removed + C_removed;
                    P(1) = [];
                    %display('No reactions removed')

                    % result = 2.x indicates that no reactions were removed
                    % because removal of r either led to inactivated core
                    % reactions (x = 1) or the removal of r and consequently
                    % inactivated reactions prevented production of required
                    % metabolites (x = 0)
                    result = 2 + tmpStatus / 10;
                end
            end
        else
            num_removed = NC_removed + C_removed;
            P(1) = [];

            % result = 3 indicates that no reactions were removed because
            % removal of r by itself prevented production of required
            % metabolites
            result = 3;
        end

        cRes(count) = result;
        count = count + 1;
        %display(sprintf(['Num. removed: ', num2str(num_removed), ...
            %' (', num2str(C_removed), ' core, ', ...
            %num2str(NC_removed), ' non-core); ', ...
            %'Num. remaining: ', num2str(numel(P)), '\n']))
    end
    cRes(count:end) = [];
end

function [salvageStatus, time] = check_salvage_path(model)
% When the model is allowed to use PRPP and guanine or hypoxanthine, test if it
% can make GMP or IMP. This is the salvage pathway that non-hepatic tissues use
% for purine synthesis. Not useful when the tissue is known to make purines de
% novo.

    t0 = clock;
    
    % FIX: for salvage checks do not constrain biomass
    model = changeRxnBounds(model,'Biomass_reaction',0,'l');
    
    % Identify exchange reactions in the model
    exRxns = find_ex_rxns(model);

    % Turn off uptake of organic metabolites
    if exist('mediaDef', 'var')
        model = set_media_ex_bounds(model); % not implemented in this version
    else
        model = set_organic_met_bounds(model, exRxns);
    end

    % Add PRPP sink reaction for subsequent checks
    [~, model] = evalc('addSinkReactions(model, {''prpp[c]''}, -5, 5);');

    % Check production of GMP:

    % Allow uptake of guanine
    warning off all
    model_gmp = changeRxnBounds(model, 'EX_gua(e)', -5, 'l');
    warning on all
    
    % Add demand reaction for GMP
    [~, model_gmp, gmp_dm] = evalc('addDemandReaction(model_gmp, ''gmp[c]'');');
    model_gmp = changeObjective(model_gmp, gmp_dm, 1);
    sol = optimizeCbModel(model_gmp);
    status_gmp = sol.f > 1e-8;

    % Check production of IMP:

    % Allow uptake of hypoxanthine
    warning off all
    model_imp = changeRxnBounds(model, 'EX_hxan(e)', -5, 'l');
    warning on all

    % Add demand reaction for IMP
    [~, model_imp, imp_dm] = evalc('addDemandReaction(model_imp, ''imp[c]'');');
    model_imp = changeObjective(model_imp, imp_dm, 1);
    sol = optimizeCbModel(model_imp);
    status_imp = sol.f > 1e-8;

    salvageStatus = status_gmp && status_imp;

    time = etime(clock, t0);
end

function [inactiveRxns, time, result] = check_model_consistency(model, method, r, tol)
% This function is designed to quickly identify dead-end reactions in a
% stoichiometric model. The algorithm is largely based on the heuristic
% speed-up to Flux Variability Analysis (FVA) proposed by Jerby et al. [1],
% with modifications to further reduce computation time in Matlab. The
% function can operate independently to report the inactive reactions for
% an entire model, or within a pruning algorithm (e.g., MBA) to examine the
% effect of removing reactions.
%
%INPUTS
%	model           COBRA model structure
% 
%OPTIONAL INPUTS
%	method          parameter specifying whether to use fastFVA (1) or fastcc (2)
%	r               name of reaction to be removed (for model pruning in mCADRE or MBA)
%	deCheck         check for core reactions containing dead end metabolites (only for
%                   use with model pruning in MBA)
%	C               list of core reaction names (only for model pruning in MBA)
%
%OUTPUTS
%	inactiveRxns    list of IDs corresponding to reactions with 0 mininum and
%                   0 maximum flux
%	time            CPU time required to complete function
%	result          summary indicator of dead-end effects on inactive reactions
%                   1:  removal of r did not create metabolite dead ends leading to
%                       inactivation of core reactions
%                   2:  removal of r created metabolite dead ends leading to
%                       inactivation of core reactions

    deCheck = 0;
    C = {};


    if numel(r)
       % Remove reaction r from the model
        model = removeRxns(model, r);
    end
    model.c(logical(model.c)) = 0;

    inactiveRxns = r;

    t0 = clock;
    result = 1; % Until proven otherwise, assume that removal of r does not
                % create any metabolite dead ends

    % First check whether any core reactions are blocked by the removal of r.

    % Checking for metabolite dead ends is accomplished entirely by matrix
    % operations, and is therefore very fast in Matlab. If any core reaction
    % contains a dead-end metabolite, the reaction itself will be a dead end.
    % This check potentially avoids sequential optimizations, as the function
    % can exit if any blocked core reactions are detected.
    if deCheck
        deadEnd_C = check_core_deadends(model, C);
    else
        deadEnd_C = [];
    end

    % If no core reactions were found to be blocked based on metabolite dead
    % ends, maximize and minimize reactions to identify those with zero flux
    % capacity.
    if numel(deadEnd_C)
        % Setting inactiveRxns to include dead-end containing reactions will
        % effectively cause the function to exit without checking non-core
        % reactions below; thus, the full list of inactive reactions will not
        % be enumerated
        inactiveRxns = union(deadEnd_C, inactiveRxns);

        % This updates the indicator to report that dead-end-containing
        % reactions were found in the core
        result = 2;

    % If the option is specified, fastFVA is used to quickly scan through all
    % reactions. **note: may want to include option to use fastFVA with GLPK
    else
        inactiveRxns = union(inactiveRxns, find_inactive_rxns(model, method, tol));
    end

    time = etime(clock,t0);
    %display(['check_model_consistency time: ',num2str(time, '%1.2f'), ' s'])
end

function inactiveRxns = find_inactive_rxns(model, method, tol)
% fastFVA is the default method
    if nargin < 2
        method = 1;
    end

    % Check for inactive reactions with either fastFVA or fastcc
    if method == 1
        %display('Checking all reactions (fastFVA)...')
        model.c(logical(model.c)) = 0;
        [optMin, optMax] = fastFVA(model, 0, 'max', 'glpk');
        is_inactive = (abs(optMax) < tol) & (abs(optMin) < tol);
        inactiveRxns = model.rxns(is_inactive);

    else % otherwise, use FASTCC
        %display('Checking all reactions (FASTCC)...')
        is_active = fastcc(model, tol);
        inactiveRxns = setdiff(model.rxns, model.rxns(is_active));
    end
end

function A = fastcc(model, epsilon) 
% The FASTCC algorithm for testing the consistency of an input model
% Output A is the consistent part of the model
% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg
    
    N = (1:numel(model.rxns));
    I = find(model.rev==0);

    A = [];

    % start with I
    J = intersect(N, I);
    V = LP7(J, model, epsilon); 
    Supp = find(abs(V) >= 0.99*epsilon);  
    A = Supp;
    incI = setdiff(J, A);    
    if ~isempty(incI)
        %fprintf('\n(inconsistent subset of I detected)\n');
    end
    J = setdiff(setdiff(N, A), incI);

    % reversible reactions
    flipped = false;
    singleton = false;        
    while ~isempty(J)
        if singleton
            Ji = J(1);
            V = LP3(Ji, model) ; 
        else
            Ji = J;
            V = LP7(Ji, model, epsilon) ; 
        end    
        Supp = find(abs(V) >= 0.99*epsilon);  
        A = union(A, Supp);
        if ~isempty(intersect(J, A))
            J = setdiff(J, A);
            flipped = false;
        else
            JiRev = setdiff(Ji, I);
            if flipped || isempty(JiRev)
                flipped = false;
                if singleton
                    J = setdiff(J, Ji);  
                    %fprintf('\n(inconsistent reversible reaction detected)\n');
                else
                    singleton = true;
                end
            else
                model.S(:,JiRev) = -model.S(:,JiRev);
                tmp = model.ub(JiRev);
                model.ub(JiRev) = -model.lb(JiRev);
                model.lb(JiRev) = -tmp;
                flipped = true;  %fprintf('(flip)  ');
            end
        end
    end

    if numel(A) == numel(N)
        %fprintf('\nThe input model is consistent.\n'); 
    end
    %toc
end

function V = LP3(J, model)
% CPLEX implementation of LP-3 for input set J (see FASTCORE paper)
% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg

    [m,n] = size(model.S);

    % objective
    f = zeros(1,n);
    f(J) = -1;

    % equalities
    Aeq = model.S;
    beq = zeros(m,1);

    % bounds
    lb = model.lb;
    ub = model.ub;
    
    % Set up problem
    LPproblem.A = Aeq;
    LPproblem.b = beq;
    LPproblem.c = f;
    LPproblem.lb = lb;
    LPproblem.ub = ub;
    LPproblem.osense = 1;
    LPproblem.csense(1:m,1) = 'E';

    %V = cplexlp(f,[],[],Aeq,beq,lb,ub);
    sol = solveCobraLP(LPproblem);
    V = sol.full;
end

function V = LP7(J, model, epsilon)
% CPLEX implementation of LP-7 for input set J (see FASTCORE paper)
% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg

    nj = numel(J);
    [m,n] = size(model.S);

    % x = [v;z]

    % objective
    f = -[zeros(1,n), ones(1,nj)];

    % equalities
    Aeq = [model.S, sparse(m,nj)];
    beq = zeros(m,1);

    % inequalities
    Ij = sparse(nj,n); 
    Ij(sub2ind(size(Ij),(1:nj)',J(:))) = -1;
    Aineq = sparse([Ij, speye(nj)]);
    bineq = zeros(nj,1);

    % bounds
    lb = [model.lb; zeros(nj,1)];
    ub = [model.ub; ones(nj,1)*epsilon];

    % Set up problem
    LPproblem.A = [Aeq;Aineq];
    LPproblem.b = [beq;bineq];
    LPproblem.c = f;
    LPproblem.lb = lb;
    LPproblem.ub = ub;
    LPproblem.osense = 1;
    LPproblem.csense(1:m,1) = 'E';
    LPproblem.csense(m+1:length(bineq)+m,1) = 'L';
    
    sol = solveCobraLP(LPproblem);
    if sol.stat == 1
        x = sol.full;    
        %x = cplexlp(f,Aineq,bineq,Aeq,beq,lb,ub);
        V = x(1:n);
    else
        V = zeros(n,1);
    end
end

%FIX: local copy that does not print warning is reaction has been removed
function model = changeRxnBounds(model,rxnNameList,value,boundType)
%changeRxnBounds Change upper or lower bounds of a reaction or a set of
%reactions
%
% model = changeRxnBounds(model,rxnNameList,value,boundType)
%
%INPUTS
% model         COBRA model structure
% rxnNameList   List of reactions (cell array or string)
% value         Bound values
%               Can either be a vector or a single scalar value if the same
%               bound value is to be assinged to all reactions
%
%OPTIONAL INPUT
% boundType     'u' - upper, 'l' - lower, 'b' - both (Default = 'b')
%               Bound type can either be a cell array of strings or a 
%               string with as many letters as there are reactions in 
%               rxnNameList
%
%OUTPUT
% model         COBRA model structure with modified reaction bounds
%
% Markus Herrgard 4/21/06

    if (nargin < 4)
        boundType = 'b';
    end

    if ((length(value) ~= length(rxnNameList) & length(value) > 1) | (length(boundType) ~= length(rxnNameList) & length(boundType) > 1))
       error('Inconsistent lenghts of arguments: rxnNameList, value & boundType'); 
    end

    rxnID = findRxnIDs(model,rxnNameList);

    % Remove reactions that are not in the model
    if (iscell(rxnNameList))
        missingRxns = rxnNameList(rxnID == 0);
        for i = 1:length(missingRxns)
            %fprintf('Reaction %s not in model\n',missingRxns{i}); 
        end
        if (length(boundType) > 1)
            boundType = boundType(rxnID ~= 0);
        end
        if (length(value) > 1)
            value = value(rxnID ~= 0);
        end
        rxnID = rxnID(rxnID ~= 0);    
    end

    if (isempty(rxnID) | sum(rxnID) == 0)
        %warning('No such reaction in model');
    else
        nRxns = length(rxnID);
        if (length(boundType) > 1)
            if (length(value) == 1)
                value = repmat(value,nRxns,1);
            end
            for i = 1:nRxns
                switch lower(boundType{i})
                    case 'u'
                        model.ub(rxnID(i)) = value(i);
                    case 'l'
                        model.lb(rxnID) = value(i);
                    case 'b'
                        model.lb(rxnID) = value(i);
                        model.ub(rxnID) = value(i);
                end
            end
        else
            switch lower(boundType)
                case 'u'
                    model.ub(rxnID) = value;
                case 'l'
                    model.lb(rxnID) = value;
                case 'b'
                    model.lb(rxnID) = value;
                    model.ub(rxnID) = value;
            end
        end
    end
end

