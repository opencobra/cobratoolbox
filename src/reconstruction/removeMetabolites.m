function model = removeMetabolites(model,metaboliteList,removeRxnFlag)
% Removes metabolites from a model
%
% USAGE:
%
%    model = removeMetabolites(model, metaboliteList, removeRxnFlag)
%
% INPUTS:
%    model:             COBRA model structure
%    metaboliteList:    List of metabolites to be removed
%
% OPTIONAL INPUT:
%    removeRxnFlag:     Remove reactions with no metabolites (Default = true)
%
% OUTPUT:
%    model:             COBRA model with removed metabolites
%
% .. Authors:
%       - Markus Herrgard 6/5/07
%       - Uri David Akavia 1/18/14
%       - Fatima Liliana Monteiro 17/11/16 add an if condition to remove metabolites just from fields with same length

if (nargin < 3)
    removeRxnFlag = true;
end

selMets = ~ismember(model.mets,metaboliteList);

model.S = model.S(selMets,:);
% Identify metabolite fields (that start with 'met')
foo = strncmp('met', fields(model), 3);
metabolicFields = fieldnames(model);
metabolicFields = metabolicFields(foo);
clear foo;

for i = 1:length(metabolicFields)
    if length(model.(metabolicFields{i})) == length(selMets)
        model.(metabolicFields{i}) = model.(metabolicFields{i})(selMets);
    else
        warning('There are metabolic fields with different dimensions')
    end
end
if (isfield(model,'b'))
    model.b = model.b(selMets);
else
    model.b = zeros(length(model.mets),1);
end

if removeRxnFlag
    %if S is empty..
    if(isempty(model.S))
        return
    end
    rxnRemoveList = model.rxns(~any(model.S ~= 0));
    if (~isempty(rxnRemoveList))
        model = removeRxns(model,rxnRemoveList,false,false);
    end
end
