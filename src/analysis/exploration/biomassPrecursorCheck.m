function [missingMets, presentMets,coupledMets] = biomassPrecursorCheck(model,checkCoupling)
% Checks if biomass precursors are able to be synthesized.
%
% [missingMets, presentMets, coupledMets] = biomassPrecursorCheck(model)
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
%                    
%
% .. Authors: - Pep Charusanti & Richard Que (July 2010)
% May identify metabolites that are typically recycled within the
% network such as ATP, NAD, NADPH, ACCOA.
if ~exist('checkCoupling','var')
    checkCoupling = 0;
end

if ~checkCoupling && nargout == 3
    error('coupledMets are not being calculated if checkCoupling is not set to true!');
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
