function [transRxns,nonTransRxns] = findTransRxns(model,inclExc)
%findTransRxns identify all transport reactions in a model
%
% [transRxns,nonTransRxns] = findTransRxns(model,inclExc)
%
%INPUT
% model             COBRA model structure
%
%OPTIONAL INPUT
% inclExc           include exchange reactions as transport?
%                   (Default = false)
%
%OUTPUT
% transRxns         all transport reactions in the model
% nonTransRxns      all non-transport reactions in the model
%
% right now, this function only works with models the compartments [c],
% [p], and [e]
%
% Jeff Orth  8/31/07

if nargin < 2
    inclExc = false;
end

isTrans = zeros(1,length(model.rxns));

for i = 1:length(model.rxns)
    mets = model.mets(find(model.S(:,i)));
    cMets = regexp(mets,'\[c\]');
    hasCs = ~isempty([cMets{:}]);
    pMets = regexp(mets,'\[p\]');
    hasPs = ~isempty([pMets{:}]);
    eMets = regexp(mets,'\[e\]');
    hasEs = ~isempty([eMets{:}]);
    
    if (sum([hasCs,hasPs,hasEs]) > 1) || hasEs&&inclExc
        isTrans(i) = 1;
    end
end

transRxns = model.rxns(isTrans==1);
nonTransRxns = model.rxns(isTrans==0);



