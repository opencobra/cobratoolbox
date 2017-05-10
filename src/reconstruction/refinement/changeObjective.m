function model = changeObjective(model,rxnNameList,objectiveCoeff)
%changeObjective Changes the objective function of a constraint-based model
%
% model = changeObjective(model,rxnNameList,objectiveCoeff)
%
%INPUTS
% model             COBRA structure
% rxnNameList       List of reactions (cell array or string)
%
%OPTIONAL INPUT
% objectiveCoeff    Value of objective coefficient for each reaction
%                   (Default = 1)
%
%OUTPUT
% model             COBRA model structure with new objective
%
% Monica Mo & Markus Herrgard - 8/21/06

if (nargin < 3)
    objectiveCoeff = 1;
end

rxnID = findRxnIDs(model,rxnNameList);

model.c = zeros(size(model.c));

if iscell(rxnNameList)
    missingRxns = rxnNameList(rxnID == 0);
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
