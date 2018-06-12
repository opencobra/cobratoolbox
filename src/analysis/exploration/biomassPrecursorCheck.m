function [missingMets, presentMets,coupledMets] = biomassPrecursorCheck(model,checkCoupling)
% Checks if biomass precursors are able to be synthesized.
%
% [missingMets, presentMets] = biomassPrecursorCheck(model)
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
%
% .. Authors: - Pep Charusanti & Richard Que (July 2010)
% May identify metabolites that are typically recycled within the
% network such as ATP, NAD, NADPH, ACCOA.
if nargin < 2
    checkCoupling = 0;
end

if ~checkCoupling && nargout == 3
    error('coupledMets are not being calculated if checkCoupling is not set to true!');
end

colS_biomass = model.c ~= 0;
% FIND COLUMN IN S-MATRIX THAT CORRESPONDS TO BIOMASS EQUATION

% LIST ALL METABOLITES IN THE BIOMASS FUNCTION
biomassMetabs = model.mets(any(model.S(:, colS_biomass) < 0, 2));

% ADD DEMAND REACTION, SET OBJECTIVE FUNCTION TO MAXIMIZE ITS PRODUCTION,
% AND OPTIMIZE.  NOTE: A CRITICAL ASSUMPTION IS THAT THE ADDED DEMAND
% REACTION IS APPENDED TO THE FAR RIGHT OF THE S-MATRIX.  THE CODE NEEDS TO
% BE REVISED IF THIS IS NOT THE CASE.
m = 1;
p = 1;
c = 1;
% ADD DEMAND REACTIONS
[model_newDemand, addedRxns] = addDemandReaction(model, biomassMetabs);

if checkCoupling
    %Close the precursors
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
