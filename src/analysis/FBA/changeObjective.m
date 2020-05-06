function model = changeObjective(model, rxns, objectiveCoeff)
% Changes the objective function of a constraint-based model
%
% USAGE:
%
%    model = changeObjective(model, rxns, objectiveCoeff)
%
% INPUTS:
%    model:         COBRA model structure
%    rxns:          a string or a cell array of strings matching some model.rxns{i}
%
% OPTIONAL INPUT:
%    objectiveCoeff:    Value of objective coefficient for each reaction (Default = 1)
%
% OUTPUT:
%    model:             COBRA model structure with new objective
%
% .. Author: - Monica Mo & Markus Herrgard - 8/21/06

if (nargin < 3)
    objectiveCoeff = 1;
end

rxnID = findRxnIDs(model,rxns);

model.c = zeros(size(model.c));

if iscell(rxns)
    missingRxns = rxns(rxnID == 0);
    for i = 1:length(missingRxns)
        fprintf('%s not in model\n',missingRxns{i});
    end
    rxnID = rxnID(rxnID ~= 0);
    if (length(objectiveCoeff) > 1)
        objectiveCoeff = objectiveCoeff(rxnID ~= 0);
    end
end

if (isempty(rxnID) | rxnID == 0)
    error('Objective reactions not found in model!');
else
    model.c(rxnID) = objectiveCoeff;
end
