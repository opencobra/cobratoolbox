function [rxnList, rxnFormulaList] = findRxnsFromMets(model, metList, verbFlag)
%findRxnsFromMets returns a list of reactions in which at least one
%metabolite listed in metList participates.
%
% [rxnList, rxnFormulaList] = findRxnsFromMets(model, metList, verbFlag)
%
%INPUTS
% model             COBRA model structure
% metList           Metabolite list
%
%OPTIONAL INPUT
% verbFlag          Print reaction formulas to screen (Default = false)
%
%OUTPUTS
% rxnList           List of reactions
% rxnFormulaList    Reaction formulas coresponding to rxnList
%
%Richard Que (08/12/2010)

if nargin < 3 || isempty(verbFlag), verbFlag = false; end

%Find met indicies
[isMet index] = ismember(metList,model.mets);
index = index(isMet);
%expand rxns list for logical indexing
rxns = repmat(model.rxns,1,length(index));
%find reactions
rxnList = unique(rxns(model.S(index,:)'~=0));
if nargout > 1
    rxnFormulaList = printRxnFormula(model,rxnList,verbFlag);
end