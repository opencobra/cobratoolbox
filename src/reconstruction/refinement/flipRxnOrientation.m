function model = flipRxnOrientation(model, rxnList)
% flips the directionality of the given reactions and adjusts the bounds
% and objective coefficients accordingly.
%
% USAGE:
%
%    model = flipRxnOrientation(model, rxnList)
%
% INPUTS:
%
%    model:         A COBRA Style model structure with fields:
%
%                     * .rxns - `n x 1` cell array of reaction identifiers
%                     * .S - `m x n` stoichiometric matrix (rows for the
%                       flipped reactions are negated)
%                     * .c - `n x 1` objective coefficients (negated for
%                       the flipped reactions)
%                     * .lb - `n x 1` lower flux bounds (swapped/negated
%                       for the flipped reactions)
%                     * .ub - `n x 1` upper flux bounds (swapped/negated
%                       for the flipped reactions)
%    rxnList:       A List of reactions or a single reaction
%
% OUTPUTS:
%
%    model:         The model with the specified reactions flipped.
%

positionsToFlip = ismember(model.rxns, rxnList);

% Flip the stoichiometric coefficients
model.S(:, positionsToFlip) = -model.S(:, positionsToFlip);
model.c(positionsToFlip) = -model.c(positionsToFlip);
lbs = model.lb(positionsToFlip);
model.lb(positionsToFlip) = -model.ub(positionsToFlip);
model.ub(positionsToFlip) = -lbs;

% Check if we missed reactions.
notInModel = ~ismember(rxnList, model.rxns);
if any(notInModel)
    rxnsNotInModel = rxnList(notInModel);
    for i = 1:numel(rxnsNotInModel)
        fprintf('Reaction %s not present in model!', rxnsNotInModel{i});
    end
end
