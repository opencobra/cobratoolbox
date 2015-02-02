function modelOut = removeRxns(model,rxnRemoveList,irrevFlag,metFlag)
%removeRxns Remove reactions from a model
%
% model = removeRxns(model,rxnRemoveList,irrevFlag,metFlag)
%
%INPUTS
% model             COBRA model structure
% rxnRemoveList     Cell array of reaction names to be removed
%
%OPTIONAL INPUTS
% irrevFlag         Irreverseble (true) or reversible (false) reaction
%                   format (Default = false)
% metFlag           Remove unused metabolites (Default = true)
%
%OUTPUT
% model             COBRA model w/o selected reactions
%
% Markus Herrgard 7/22/05
% Uri David Akavia 2/01/14

if (nargin < 3)
  irrevFlag = false;
end
if (nargin < 4)
  metFlag = true;
end

[~,nRxns] = size(model.S);
modelOut = model;
% Find indices to rxns in the model
[isValidRxn,removeInd] = ismember(rxnRemoveList,model.rxns);
removeInd = removeInd(isValidRxn);

% Remove reversible tag from the reverse reaction if the reaction to be
% deleted is reversible
if (irrevFlag)
  for i = 1:length(removeInd)
    remRxnID = removeInd(i);
    if (model.match(remRxnID) > 0)
      revRxnID = model.match(remRxnID);
      model.rev(revRxnID) = 0;
      model.rxns{revRxnID} = model.rxns{revRxnID}(1:end-2);
    end
  end
end

% Construct vector to select rxns to be included in the model rapidly
selectRxns = (ones(nRxns,1) == 1);
selectRxns(removeInd) = false;

% Construct new model
if isfield(model,'description')
    modelOut.description = model.description;
end

modelOut.S = model.S(:,selectRxns);
modelOut.rxns = model.rxns(selectRxns);
modelOut.lb = model.lb(selectRxns);
modelOut.ub = model.ub(selectRxns);
modelOut.rev = model.rev(selectRxns);
if (isfield(model,'c'))
    modelOut.c = model.c(selectRxns);
end
if (isfield(model,'genes'))
    modelOut.rxnGeneMat = model.rxnGeneMat(selectRxns,:);
    modelOut.rules = model.rules(selectRxns);
    modelOut.genes = model.genes;
    modelOut.grRules = model.grRules(selectRxns);
end
reactionFields = {'subSystems', 'rxnNames', 'rxnReferences', 'rxnECNumbers', 'ecNumbers', 'rxnNotes', 'confidenceScores', 'citations', 'rxnKeggID', 'comments'};
reactionFields = intersect(reactionFields, fieldnames(model));

for i=1:length(reactionFields)
	modelOut.(reactionFields{i}) = model.(reactionFields{i})(selectRxns);
end

% Reconstruct the match list
if (irrevFlag)
  modelOut.match = reassignFwBwMatch(model.match,selectRxns);
  modelOut.rev(modelOut.match == 0) = false;
end

% Remove metabolites that are not used anymore
% Identify metabolite fields (that start with 'met')
foo = strncmp('met', fields(model), 3);
metabolicFields = fieldnames(model);
metabolicFields = metabolicFields(foo);
clear foo;

if (metFlag)
  selMets = any(modelOut.S ~= 0,2);
  modelOut.S = modelOut.S(selMets,:);
  for i = 1:length(metabolicFields) 
	  modelOut.(metabolicFields{i}) = model.(metabolicFields{i})(selMets);
  end
  if (isfield(model,'b'))
      modelOut.b = model.b(selMets);
  else
      modelOut.b = zeros(length(modelOut.mets),1);
  end
% This seems unnecessary (because of line 28, but modified it to be consistent  
else
  modelOut.b = model.b;
  for i = 1:length(metabolicFields)
	  modelOut.(metabolicFields{i}) = model.(metabolicFields{i});
  end
end
