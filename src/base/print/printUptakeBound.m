function upInd = printUptakeBound(model)
% Returns the indices to the substrate uptake reactions and prints substrate uptake bounds
%
% USAGE:
%
%    uptakeInd = printUptakeBound(model)
%
% INPUTS:
%    model:     CORBRA model structure
%
% OUTPUTS:
%    upInd:     Vector containing indecies of uptake reactions
%
% .. Authors:
%       - Markus Herrgard 6/9/06

[selExc, selUptake] = findExcRxns(model, false, false);
printLabeledData(model.rxns(selUptake), model.lb(selUptake));

upInd = find(selUptake);
