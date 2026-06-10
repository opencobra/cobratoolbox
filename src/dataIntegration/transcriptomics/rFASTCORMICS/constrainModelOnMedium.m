function [model] = constrainModelOnMedium(model, mediumMets, notMediumConstrained, biomassReaction, functionToKeep)
% The function constrains a metabolic model based on a defined medium by
% restricting exchange reactions, while preserving essential functions.
%
% USAGE:
%
%   [model] = constrainModelOnMedium(model, mediumMets, notMediumConstrained, biomassReaction, functionToKeep)
%
% INPUTS:
%   model:                  (the following fields are required - others can be supplied)
%                           * S   - m x n Stoichiometric matrix
%                           * lb  - n x 1 Lower bounds
%                           * ub  - n x 1 Upper bounds
%                           * rxns - n x 1 cell array of reaction identifiers
%   mediumMets:             cell array of metabolites defining the growth medium
%   notMediumConstrained:   optional list of reactions/metabolites that should not be constrained
%   biomassReaction:        string specifying the biomass reaction to preserve
%   functionToKeep:         list of reactions that must remain active
%
% OUTPUT:
%   model:                  constrained metabolic model
%
% .. Authors:
%       - Maria Pires Pacheco, University of Luxembourg, 2015

% Handle reactions that should not be constrained
if ~isempty(notMediumConstrained)
    % Identify indices of reactions to keep unconstrained
    notMediumConstrained = find(ismember(model.rxns, notMediumConstrained)); % exchange reactions that we don't want to constrain
    
    % Store their original bounds to restore later
    lb = model.lb(notMediumConstrained);
    ub = model.ub(notMediumConstrained);
end

% Identify exchange reactions and carbon sources to potentially constrain
[exRxns, ExOrgaInd] = findOrganicExRxns(model, biomassReaction, functionToKeep);

% Identify exchange reactions associated with medium metabolites (to keep open)
notConstrained = intersect(findRxnsFromMets(model, mediumMets), exRxns);
notConstrained = find(ismember(model.rxns, notConstrained));

% Store their original bounds
lb2 = model.lb(notConstrained);
ub2 = model.ub(notConstrained);

% Close uptake of carbon sources
[~, match] = find(model.S(:, ExOrgaInd) < 0);
if ~isempty(match)
    model.lb(ExOrgaInd(match)) = 0;
end

% Close secretion of carbon sources
[~, match]= find(model.S(:, ExOrgaInd) > 0);
if ~isempty(match)
    model.ub(ExOrgaInd(match)) = 0;
end

% Restore bounds for reactions explicitly excluded from constraints
if ~isempty(notMediumConstrained)
    model.lb(notMediumConstrained) = lb;
    model.ub(notMediumConstrained) = ub;
end

% Restore bounds for reactions supplied by the medium
if  ~isempty(notConstrained)
    model.lb(notConstrained) = lb2;
    model.ub(notConstrained) = ub2;
end
end
