function [model, rxnRemoveList] = removeMetabolites(model, metRemoveList, removeRxnFlag, rxnRemoveMethod)
% Removes metabolites from a model
%
% USAGE:
%
%    [model, rxnRemoveList] = removeMetabolites(model, metRemoveList, removeRxnFlag)
%
% INPUTS:
%    model:             COBRA model structure
%    metRemoveList:    List of metabolites to be removed
%
% OPTIONAL INPUT:
%    removeRxnFlag:     Remove reactions with no metabolites (Default = true)
%    rxnRemoveMethod:   {('inclusive'),'exclusive','legacy'}, to remove reactions in a
%                       stoichiometrically consistent manner, or possibly
%                       not consistently if either of the last options are
%                       chosen.
% OUTPUT:
%    model:             COBRA model with removed metabolites
%
% .. Authors:
%       - Markus Herrgard 6/5/07
%       - Uri David Akavia 1/18/14
%       - Fatima Liliana Monteiro 17/11/16 add an if condition to remove metabolites just from fields with same length
%       - Thomas Pfau, added automatic Field Update.

if (nargin < 3)
    removeRxnFlag = true;
end
if (nargin < 4)
    rxnRemoveMethod = 'inclusive';
else
    if any(contains(metRemoveList,'dummy'))
        removeRxnFlag = false;
        warning('Detected the removal of dummy metabolites, not removing reactions')
    end
end

[nMets, nRxns] = size(model.S);
if isfield(model, 'genes')
    nGenes = length(model.genes);
else
    nGenes = 0;
end

removeMetBool = ismember(model.mets,metRemoveList);

% Construct new model
modelOut = removeFieldEntriesForType(model, removeMetBool, 'mets', numel(model.mets));


if removeRxnFlag
    %if S is empty..
    if(isempty(modelOut.S))
        return
    end
    if strcmp(rxnRemoveMethod,'legacy')
        %removes any reaction corresponding to an empty column
        %danger of stoichiometric inconsistency of other reactions
        removeRxnBool = ~any(modelOut.S ~= 0);
        rxnRemoveList = modelOut.rxns(removeRxnBool);
    elseif strcmp(rxnRemoveMethod,'exclusive')
        %removes any reaction exclusively involving the removed
        %metabolites, i.e. empty column
        %danger of stoichiometric inconsistency of other reactions
        removeRxnBool = getCorrespondingCols(model.S,removeMetBool,true(nRxns,1),'exclusive');
        rxnRemoveList = model.rxns(removeRxnBool);
    elseif strcmp(rxnRemoveMethod,'inclusive')
        %removes any reaction involving at least one of the removed metabolites 
        removeRxnBool = getCorrespondingCols(model.S,removeMetBool,true(nRxns,1),'inclusive');
        rxnRemoveList = model.rxns(removeRxnBool);
    else
        error('rxnRemoveMethod not recognised')
    end
    
    if (~isempty(rxnRemoveList))
        modelOut = removeRxns(modelOut,rxnRemoveList,false,false);
    end
else
    rxnRemoveList=[];
end
%return the modified model
model = modelOut;
