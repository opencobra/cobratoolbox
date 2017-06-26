function model = flipRxnOrientation(model, rxnList)
% flips the directionality of the given reactions and adjusts the bounds
% and objective coefficients accordingly.
%
% USAGE:
%
%    model = flipRxnDirectionality(model, rxnList)
%
% INPUTS:
%
%    model:         A COBRA Style model structure
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
