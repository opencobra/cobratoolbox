function [missingMets, presentMets,coupledMets, missingCofs, presentCofs] = biomassPrecursorCheck(model,checkCoupling)
% Checks if biomass precursors are able to be synthesized.
%
% [missingMets, presentMets, coupledMets] = biomassPrecursorCheck(model, checkCoupling)
%
% INPUT:
%    model:             COBRA model structure
%
% OPTIONAL INPUT:
%    checkCoupling:     Test, whether some compounds can only be produced
%                       if there is a sink for other biomass precursors
%                       (Default: false)
%
% OUTPUTS:
%    missingMets:    List of biomass precursors that are not able to be synthesized
%    presentMets:    List of biomass precursors that are able to be synthesized
%    coupledMets:    List of metabolites which need an exchange reaction for at least one other
%                    biomass component because their production is coupled to it.
%    missingCofs:    List of cofactor pairs (defined by the network conserved moieties) 
%                    that are not able to be synthesized
%    presentCofs:    List of cofactor pairs that are able to be synthesized
%
% .. Authors: - Pep Charusanti & Richard Que (July 2010)
% May identify metabolites that are typically recycled within the network 
% such as ATP, NAD, NADPH, ACCOA. Turn on checkCoupling to check them.
if ~exist('checkCoupling','var')
    checkCoupling = 0;
end

if ~checkCoupling && nargout >= 3
    error('coupledMets, missingCofs and presentCofs are not being calculated if checkCoupling is not set to true!');
end

% Find column in s-matrix that corresponds to biomass equation
colS_biomass = model.c ~= 0;

% List all metabolites in the biomass function
biomassMetabs = model.mets(any(model.S(:, colS_biomass) < 0, 2));

% Add demand reaction, set objective function to maximize its production,
% and optimize.  Note: a critical assumption is that the added demand
% reaction is appended to the far right of the s-matrix.  The code needs to
% be revised if this is not the case.
m = 1; % position in the missing metabolies vector
p = 1; % position in the present metabolies vector
c = 1; % position in the coupled metabolies vector
% Add demand reactions
[model_newDemand, addedRxns] = addDemandReaction(model, biomassMetabs);

if checkCoupling
    % Close the precursors
    model_newDemand = changeRxnBounds(model_newDemand,addedRxns,zeros(numel(addedRxns,1)),repmat('b',numel(addedRxns,1)));
    coupledMets = {};
end

[missingMets, presentMets] = deal({});
for i = 1:length(biomassMetabs)
    if checkCoupling
        model_newDemand = changeRxnBounds(model_newDemand, addedRxns{i}, 1000, 'u');
    end
    model_newDemand = changeObjective(model_newDemand, addedRxns{i});
    solution = optimizeCbModel(model_newDemand);                                % OPTIMIZE
    if solution.f == 0                                                          % MAKE LIST OF WHICH BIOMASS PRECURSORS ARE ...
        if checkCoupling
            model_newDemand = changeRxnBounds(model_newDemand, addedRxns, 1000, 'u');
            solution = optimizeCbModel(model_newDemand);
            if solution.f > 0
                coupledMets(c) = biomassMetabs(i);                              % NEED ANOTHER SINK
                c = c + 1;
            else
                missingMets(m) = biomassMetabs(i);                              %  SYNTHESIZED AND WHICH ARE NOT
                m = m + 1;
            end
            model_newDemand = changeRxnBounds(model_newDemand, addedRxns, 0, 'u');
        else
            missingMets(m) = biomassMetabs(i);                                  %  SYNTHESIZED AND WHICH ARE NOT
            m = m + 1;
        end
    else
        presentMets(p) = biomassMetabs(i);
        p = p + 1;
    end
end
missingMets = columnVector(missingMets);
presentMets = columnVector(presentMets);

if checkCoupling && ~isempty(missingMets)
    % Detect cofactor pairs in the biomass reaction. They contain conserved moieties.
    EMV = findElementaryMoietyVectors(model);
    % Biomass metabolites that contain conserved moieties
    mCofactor = any(model.S(:, colS_biomass) ~= 0, 2) & any(EMV, 2);
    % Elementary moieties involved in biomass production
    cofactorPairMatrix = EMV(:, any(EMV(mCofactor, :), 1));
    % Each cell of cofactorPair stores the set of cofactor metabolites to be produced.
    % cofactorPairStr represents the set by a string for string comparison
    % cofactorStoich is the corresponding stoichiometry for cofactorPair
    [cofactorPair, cofactorPairStr, cofactorStoich] = deal({});
    % To accommodate possibly multiple objective reactions, first figure out
    % all different cofactor pairs to be produced among all objective reactions
    for i = 1:size(cofactorPairMatrix, 2)
        % Objective reactions involving the current elementary moiety
        rxnI = find(colS_biomass & any(model.S(cofactorPairMatrix(:, i) ~= 0, :), 1)');
        for j = 1:numel(rxnI)
            % Logical index for metabolite contain the current moiety and
            % involved in the current objective reactions
            cofactorPairLogic = cofactorPairMatrix(:, i) ~= 0 & model.S(:, rxnI(j)) ~= 0;
            % If this cofactor pair is not yet found, store it.
            if ~any(strcmp(strjoin(model.mets(cofactorPairLogic), '|'), cofactorPairStr))
                % The set of cofactor metabolites to be produced
                cofactorPair{end + 1, 1} = model.mets(cofactorPairLogic);
                % Expressed as a string joined by '|' for string comparison
                cofactorPairStr{end + 1, 1} = strjoin(model.mets(cofactorPairLogic), '|');
                % Stoichiometry
                cofactorStoichCur = model.S(cofactorPairLogic, rxnI(j));
                % The metabolite being consumed in this cofactor pair
                substrateCur = cofactorPairLogic & model.S(:, rxnI(j)) < 0;
                % Normalize the stoichiometry of the cofactor pair so that
                % the substrate has stoich = -1
                cofactorStoichCur = cofactorStoichCur / abs(model.S(substrateCur, rxnI(j)));
                cofactorStoich{end + 1, 1} = cofactorStoichCur;
            end
        end
    end
    % Store the cofactor production formula for printing the results
    cofactorFormula = cell(numel(cofactorPair), 1);
    % Cofactor pairs producible or not
    producible = false(size(cofactorFormula));
    for i = 1:numel(cofactorPair)
        % Add the corresponding reaction for cofactor production
        model_newDemand = addReaction(model, 'cofactor_prod', ...
            'metaboliteList', cofactorPair{i}, 'stoichCoeffList', cofactorStoich{i}, ...
            'reversible', false, 'lowerBound', 0, 'printLevel', 0);
        % Maximize its production
        model_newDemand = changeObjective(model_newDemand, 'cofactor_prod', 1);
        solution = optimizeCbModel(model_newDemand);
        producible(i) = ~isempty(solution.f) && solution.f > 0;
        % Store the reaction formula
        cofactorFormula(i) = printRxnFormula(model_newDemand, 'rxnAbbrList', 'cofactor_prod', 'printFlag', false);
    end
    % Sort the cofactor pairs with those producible coming first
    [producible, ind] = sort(producible, 'descend');
    [cofactorFormula, cofactorPair] = deal(cofactorFormula(ind), cofactorPair(ind));
    % Print the results
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
    % Exclude those metabolites in cofactor pairs from missingMets
    missingMets = missingMets(~ismember(missingMets, metCofs(:)));
end
