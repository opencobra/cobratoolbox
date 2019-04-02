function [missingMets, presentMets, coupledMets, missingCofs, presentCofs] = biomassPrecursorCheck(model, checkCoupling, checkConservedQuantities, ATN)
% Checks if biomass precursors are able to be synthesized.
%
% USAGE:
%    [missingMets, presentMets, coupledMets, missingCofs, presentCofs] = biomassPrecursorCheck(model, checkCoupling, checkConservedQuantities)
%
% INPUT:
%    model:             COBRA model structure
%
% OPTIONAL INPUT:
%    checkCoupling:     Test, whether some compounds can only be produced
%                       if there is a sink for other biomass precursors
%                       (Default: false)
%    checkConservedQuantities:  true to check whether the cofactor pairs containing conserved moieties 
%                               (defined by the network structure) can be synthesized 
%                               (e.g., ATP, NAD, NADPH, ACCOA, AA-charged tRNA, fatty acyl-ACP). 
%                               They will otherwise be identified as missingMets (Default: false)
%    ATN:               atom transition network outputed by `buildAtomTransitionNetwork`
%                       If provided, true internal conserved moieties will be identified 
%                       and used for checking conserved quantities (default [])
%
% OUTPUTS:
%    missingMets:    List of biomass precursors that are not able to be synthesized
%    presentMets:    List of biomass precursors that are able to be synthesized
%    coupledMets:    List of metabolites which need an exchange reaction for at least one other
%                    biomass component because their production is coupled to it
%                    (returned only if checkCoupling = true)
%    missingCofs:    List of cofactor pairs (defined by the network conserved moieties) 
%                    that are not able to be synthesized
%                    (returned only if checkConservedQuantities = true)
%    presentCofs:    List of cofactor pairs that are able to be synthesized
%                    (returned only if checkConservedQuantities = true)
%
% .. Authors: - Pep Charusanti & Richard Que (July 2010)

if ~exist('checkCoupling','var') || isempty(checkCoupling)
    checkCoupling = 0;
end
if ~exist('checkConservedQuantities', 'var') || isempty(checkConservedQuantities)
    checkConservedQuantities = 0;
end
if ~exist('ATN', 'var')
    ATN = [];
end

if checkCoupling && ~checkConservedQuantities && nargout > 3
    error('missingCofs and presentCofs are not being calculated if checkConservedQuantities is not set to true!');
elseif ~checkCoupling && ~checkConservedQuantities && nargout > 2
    error('coupledMets are not being calculated if checkCoupling is not set to true!\n%s', ...
        'missingCofs and presentCofs are not being calculated if checkConservedQuantities is not set to true!');
end

% find column in s-matrix that corresponds to biomass equation
colS_biomass = model.c ~= 0;

% list all metabolites in the biomass function
biomassMetabs = model.mets(any(model.S(:, colS_biomass) < 0, 2));

% add demand reaction, set objective function to maximize its production,
% and optimize.  Note: a critical assumption is that the added demand
% reaction is appended to the far right of the s-matrix.  The code needs to
% be revised if this is not the case.
m = 1; % position in the missing metabolies vector
p = 1; % position in the present metabolies vector
c = 1; % position in the coupled metabolies vector
% add demand reactions
[model_newDemand, addedRxns] = addDemandReaction(model, biomassMetabs);

if checkCoupling
    % close the precursors
    model_newDemand = changeRxnBounds(model_newDemand,addedRxns,zeros(numel(addedRxns,1)),repmat('b',numel(addedRxns,1)));    
end

optTol = getCobraSolverParams('LP','optTol');
[missingMets, presentMets, coupledMets, missingCofs, presentCofs] = deal({});
for i = 1:length(biomassMetabs)
    if checkCoupling
        % allow only the current precursor to be synthesized
        model_newDemand = changeRxnBounds(model_newDemand, addedRxns{i}, 1000, 'u');
    end
    % find maximum production of the precursor
    model_newDemand = changeObjective(model_newDemand, addedRxns{i});
    solution = optimizeCbModel(model_newDemand);
    if abs(solution.f) < optTol
        % if it is not able to be synthesized
        if checkCoupling
            % allow other precursors to be synthesized to check coupling
            model_newDemand = changeRxnBounds(model_newDemand, addedRxns, 1000, 'u');
            solution = optimizeCbModel(model_newDemand);
            if solution.f > optTol
                % if it can be synthesized with other sinks unblocked, it is a coupled met
                coupledMets(c) = biomassMetabs(i);
                c = c + 1;
            else
                % unable to be synthesized
                missingMets(m) = biomassMetabs(i);
                m = m + 1;
            end
            model_newDemand = changeRxnBounds(model_newDemand, addedRxns, 0, 'u');
        else
            % unable to be synthesized
            missingMets(m) = biomassMetabs(i);
            m = m + 1;
        end
    else
        % able to be synthesized
        presentMets(p) = biomassMetabs(i);
        p = p + 1;
    end
end
missingMets = columnVector(missingMets);
presentMets = columnVector(presentMets);

if checkConservedQuantities && ~isempty(missingMets)
    % detect cofactor pairs in the biomass reaction. They contain conserved moieties.
    if isempty(ATN)
        % no atom transition network is supplied. Just find elementary modes of the left null space
        EMV = findElementaryMoietyVectors(model);
    else
        % atom transition network is supplied.
        EMV = identifyConservedMoieties(model, ATN);
        types = classifyMoieties(EMV, model.S);
        EMV = EMV(:, strcmp(types, 'Internal'));
    end
    % biomass metabolites that contain conserved moieties
    mCofactor = any(model.S(:, colS_biomass) ~= 0, 2) & any(EMV, 2);
    % elementary moieties involved in biomass production
    cofactorPairMatrix = EMV(:, any(EMV(mCofactor, :), 1));
    % each cell of cofactorPair stores the set of cofactor metabolites to be produced.
    % cofactorPairStr represents the set by a string for string comparison
    % cofactorStoich is the corresponding stoichiometry for cofactorPair
    [cofactorPair, cofactorPairStr, cofactorStoich] = deal({});
    % to accommodate possibly multiple objective reactions, first figure out
    % all different cofactor pairs to be produced among all objective reactions
    for i = 1:size(cofactorPairMatrix, 2)
        % objective reactions involving the current elementary moiety
        rxnI = find(colS_biomass & any(model.S(cofactorPairMatrix(:, i) ~= 0, :), 1)');
        for j = 1:numel(rxnI)
            % logical index for metabolite contain the current moiety and
            % involved in the current objective reactions
            cofactorPairLogic = cofactorPairMatrix(:, i) ~= 0 & model.S(:, rxnI(j)) ~= 0;
            % if this cofactor pair is not yet found, store it.
            if ~any(strcmp(strjoin(model.mets(cofactorPairLogic), '|'), cofactorPairStr))
                % the set of cofactor metabolites to be produced
                cofactorPair{end + 1, 1} = model.mets(cofactorPairLogic);
                % expressed as a string joined by '|' for string comparison
                cofactorPairStr{end + 1, 1} = strjoin(model.mets(cofactorPairLogic), '|');
                % stoichiometry
                cofactorStoichCur = model.S(cofactorPairLogic, rxnI(j));
                % the metabolite being consumed in this cofactor pair
                substrateCur = cofactorPairLogic & model.S(:, rxnI(j)) < 0;
                % normalize the stoichiometry of the cofactor pair so that
                % the substrate has stoich = -1
                cofactorStoichCur = cofactorStoichCur / abs(model.S(substrateCur, rxnI(j)));
                cofactorStoich{end + 1, 1} = cofactorStoichCur;
            end
        end
    end
    % store the cofactor production formula for printing the results
    cofactorFormula = cell(numel(cofactorPair), 1);
    % cofactor pairs producible or not
    producible = false(size(cofactorFormula));
    for i = 1:numel(cofactorPair)
        % add the corresponding reaction for cofactor production
        model_newDemand = addReaction(model, 'cofactor_prod', ...
            'metaboliteList', cofactorPair{i}, 'stoichCoeffList', cofactorStoich{i}, ...
            'reversible', false, 'lowerBound', 0, 'printLevel', 0);
        % maximize its production
        model_newDemand = changeObjective(model_newDemand, 'cofactor_prod', 1);
        solution = optimizeCbModel(model_newDemand);
        producible(i) = ~isempty(solution.f) && solution.f > optTol;
        % store the reaction formula
        cofactorFormula(i) = printRxnFormula(model_newDemand, 'rxnAbbrList', 'cofactor_prod', 'printFlag', false);
    end
    % sort the cofactor pairs with those producible coming first
    [producible, ind] = sort(producible, 'descend');
    [cofactorFormula, cofactorPair] = deal(cofactorFormula(ind), cofactorPair(ind));
    % print the results
    for i = 1:numel(cofactorPair)
        if i == 1 && producible(i)
            fprintf('Cofactors in the biomass reaction that CAN be synthesized:\n');
        elseif ~producible(i) && (i == 1 || producible(i - 1))
            fprintf('Cofactors in the biomass reaction that CANNOT be synthesized:\n');
        end
        fprintf('%s\n', cofactorFormula{i});
        
    end
    presentCofs = cofactorPair(producible);
    missingCofs = cofactorPair(~producible);
    metCofs = [cofactorPair{:}];
    % exclude those metabolites in cofactor pairs from missingMets
    if ~isempty(metCofs)
        missingMets = missingMets(~ismember(missingMets, metCofs(:)));
    end
end