function [transRxns,nonTransRxns] = findTransRxns(model, inclExc, rxnInds)
%findTransRxns identify all transport reactions in a model, which are
%defined as reactions involved with metabolites in more than 1 compartment
%
% [transRxns,nonTransRxns] = findTransRxns(model,inclExc,rxnInds)
%
%INPUT
% model             COBRA model structure
%
%OPTIONAL INPUT
% inclExc           include exchange reactions as transport?
%                   (Default = false)
% rxnInds           indices of reactions to test for transport activity.
%                   (default = test all columns of model.S)
%
%OUTPUT
% transRxns         all transport reactions in the model
% nonTransRxns      all non-transport reactions in the model
%
% Note that: rxnsInds = union(transRxns, nonTransRxns).
%
% right now, this function only works with models the compartments [c],
% [p], and [e]
%
% Jeff Orth  8/31/07
% 
% Jonathan Dreyfuss on 6/16/12
% modified the function to work with arbitrary compartments (rather than just
% with [c], [p], & [e]), to use arrayfun, & to use findExcRxns.

if nargin < 2
    inclExc = false;
end
if nargin < 3
    rxnInds = 1:size(model.S, 2);
end


if inclExc
    % findExcRxns returns boolean vector
    isExc = findExcRxns(model,inclObjFlag,irrevFlag);
else
    isExc=zeros(1, length(rxnInds));
end

isNonexchTrans = zeros(1,length(rxnInds));

% if there are few rxns to test (e.g. <25% of rxns), then could ID the
% indices of relevant mets, to save time downstream, but not done here.

[baseMetNames,compSymbols,uniqueMetNames,uniqueCompSymbols]=arrayfun(@parseMetNames, model.mets);

for i = rxnInds
    uniqueCompSymbolsTmp=uniqueCompSymbols(model.S(:,i)~=0);
    % if there's more than 1 compartment involved, it's a transport rxn
    if length(unique(uniqueCompSymbolsTmp))>1
        isNonexchTrans(i) = 1;
    end
end

rxnNames=model.rxns(rxnInds);
transRxns = rxnNames(isNonexchTrans==1 | isExc==1);
nonTransRxns = setdiff(rxnNames, transRxns);
