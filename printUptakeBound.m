function upInd = printUptakeBound(model)
%printUptakeBound Print substrate uptake bounds
%
% uptakeInd = printUptakeBound(model)
%
%INPUTS
% model     CORBRA model structure
%
%OUTPUTS
% upInd     Vector containing indecies of uptake reactions
%
% Returns the indices to the substrate uptake reactions and prints the
% bounds
%
% Markus Herrgard 6/9/06

[selExc,selUptake] = findExcRxns(model,false,false);
printLabeledData(model.rxns(selUptake),model.lb(selUptake));

upInd = find(selUptake);
