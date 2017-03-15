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

[nMets, nRxns] = size(model.S);
if isfield(model, 'genes')
    nGenes = length(model.genes);
else
    nGenes = 0;
end

selMets = ~ismember(model.mets,metaboliteList);

% Construct new model
modelOut = model;

modelfields = fieldnames(model);
metfields = [];

if ~any([nMets nGenes] == nRxns)
    for i = 1:length(modelfields)
        if any(size(model.(modelfields{i})) == nMets) && ~strncmp('rxn',modelfields{i},3)
            metfields = [metfields; modelfields(i)];
        end
    end
else
    % Identify metabolite fields (that start with 'met')
    metfields = fieldnames(model);
    metfields = metfields(strncmp('met', fields(model), 3));
    %error('TODO: metfields')
%         'S'
%     'mets'
%     'metFormulas'
%     'metCharge'
%     'b'
%     'SIntMetBool'
%     'SOnlyExMetBool'
%     'SOnlyIntMetBool'
%     'SExMetBool'
%     'fluxConsistentMetBool'
%     'fluxInConsistentMetBool'
%     rxnfields = {'S', 'c', 'lb', 'ub', 'rxns', 'rules', 'grRules', 'rev', 'subSystems'}';
%     rxnfields = [rxnfields; modelfields(strncmp('rxn', modelfields, 3))];
%     rxnfields = intersect(rxnfields, modelfields);
end

%remove selected metabolites from metabolite fields
for i = 1:length(metfields)
   if size(model.(metfields{i}), 1) == nMets
       modelOut.(metfields{i}) = model.(metfields{i})(selMets, :);
   elseif size(model.(metfields{i}), 2) == nMets
       modelOut.(metfields{i}) = model.(metfields{i})(selMets, :);
   end
end

%model.S = model.S(selMets,:);
% clear foo;
% 
% for i = 1:length(metfields)
%     if length(model.(metfields{i})) == length(selMets)
%         model.(metfields{i}) = model.(metfields{i})(selMets);
%     else
%         warning('There are metabolic fields with different dimensions')
%     end
% end
% if (isfield(model,'b'))
%     model.b = model.b(selMets);
% else
%     model.b = zeros(length(model.mets),1);
% end

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
