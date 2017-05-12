function [missingMets,presentMets] = biomassPrecursorCheck(model)
% Checks if biomass precursors are able to be
% synthesized.
%
% [missingMets, presentMets] = checkBiomassPrecursors(model)
%
% INPUT:
%    model:         COBRA model structure
%
% OUTPUTS:
%    missingMets:   List of biomass precursors that are not able to be synthesized
%    presentMets:   List of biomass precursors that are able to be synthesized
%
% .. Authors: - Pep Charusanti & Richard Que (July 2010)
% May identify metabolites that are typically recycled within the
% network such as ATP, NAD, NADPH, ACCOA.

colS_biomass = find(model.c);
% FIND COLUMN IN S-MATRIX THAT CORRESPONDS TO BIOMASS EQUATION

% LIST ALL METABOLITES IN THE BIOMASS FUNCTION
biomassMetabs = model.mets(model.S(:,colS_biomass)<0);

% ADD DEMAND REACTION, SET OBJECTIVE FUNCTION TO MAXIMIZE ITS PRODUCTION,
% AND OPTIMIZE.  NOTE: A CRITICAL ASSUMPTION IS THAT THE ADDED DEMAND
% REACTION IS APPENDED TO THE FAR RIGHT OF THE S-MATRIX.  THE CODE NEEDS TO
% BE REVISED IF THIS IS NOT THE CASE.
k=1;
m=1;
% ADD DEMAND REACTIONS
[model_newDemand,addedRxns] = addDemandReaction(model,biomassMetabs);
for i=1:length(biomassMetabs)
%     [model_newDemand,addedRxn] = addDemandReaction(model,biomassMetabs(i));   % ADD DEMAND REACTION
    model_newDemand.c = zeros(length(model_newDemand.c),1);                     % CHANGE OBJECTIVE FUNCTION TO NEW DEMAND RXN
    model_newDemand.c(strmatch(addedRxns{i},model_newDemand.rxns)) = 1;
    solution = optimizeCbModel(model_newDemand);                                % OPTIMIZE
    if solution.f == 0                                                          % MAKE LIST OF WHICH BIOMASS PRECURSORS ARE ...
        missingMets(k) = biomassMetabs(i);                                      %  SYNTHESIZED AND WHICH ARE NOT
        k = k+1;
    else
        presentMets(m) = biomassMetabs(i);
        m = m+1;
    end
end


missingMets = columnVector(missingMets);
presentMets = columnVector(presentMets);
