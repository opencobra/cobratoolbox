function model = removeMetabolites(model,metaboliteList,removeRxnFlag)
%removeMetabolites Remove metabolites from a model
%
% model = removeMetabolites(model,metaboliteList,removeRxnFlag)
%
%INPUTS
% model             COBRA model structure
% metaboliteList    List of metabolites to be removed
%
%OPTIONAL INPUT
% removeRxnFlag     Remove reactions with no metabolites (Default = true)
%
%OUTPUT
% model             COBRA model with removed metabolites
%
% Markus Herrgard 6/5/07
% Uri David Akavia 1/18/14

if (nargin < 3)
    removeRxnFlag = true;
end

Nmets = size(model.S,1);

selMets = ~ismember(model.mets,metaboliteList);

% Avoid selecting too many metabolites in case of a coupled model
selMets = selMets(1:Nmets);

model.S = model.S(selMets,:);

% Identify metabolite fields (that start with 'met')
foo = strncmp('met', fields(model), 3);
metabolicFields = fieldnames(model);
metabolicFields = metabolicFields(foo);
clear foo;
for i = 1:length(metabolicFields)
  if length(model.(metabolicFields{i})) > Nmets
	   model.(metabolicFields{i}) = model.(metabolicFields{i})(selMets);
  else
     fprintf(' Warning: The number of metabolites does not correspond to the length of %s. Ignored.\n',metabolicFields{i});
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
