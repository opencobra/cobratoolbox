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

if (nargin < 3)
  irrevFlag = false;
end
if (nargin < 4)
  metFlag = true;
end

[nMets,nRxns] = size(model.S);
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
    modelOut.genes = model.genes;
    modelOut.grRules = model.grRules(selectRxns);
end
if (isfield(model,'rxnGeneMat'))
    modelOut.rxnGeneMat = model.rxnGeneMat(selectRxns,:);
end
if (isfield(model,'rules'))
    modelOut.rules = model.rules(selectRxns);
end
if (isfield(model,'subSystems'))
    modelOut.subSystems = model.subSystems(selectRxns);
end
if (isfield(model,'rxnNames'))
    modelOut.rxnNames = model.rxnNames(selectRxns);
end
if (isfield(model, 'rxnReferences'))
  modelOut.rxnReferences = model.rxnReferences(selectRxns);
end
if (isfield(model, 'rxnECNumbers'))
  modelOut.rxnECNumbers = model.rxnECNumbers(selectRxns);
end
if (isfield(model, 'rxnNotes'))
  modelOut.rxnNotes = model.rxnNotes(selectRxns);
end
if (isfield(model, 'rxnsboTerm'))
  modelOut.rxnsboTerm = model.rxnsboTerm(selectRxns);
end
if (isfield(model, 'rxnKeggID'))
  modelOut.rxnKeggID = model.rxnKeggID(selectRxns);
end
if (isfield(model, 'rxnConfidenceEcoIDA'))
  modelOut.rxnConfidenceEcoIDA = model.rxnConfidenceEcoIDA(selectRxns);
end
if (isfield(model, 'rxnConfidenceScores'))
  modelOut.rxnConfidenceScores = model.rxnConfidenceScores(selectRxns);
end
% Reconstruct the match list
if (irrevFlag)
  modelOut.match = reassignFwBwMatch(model.match,selectRxns);
  modelOut.rev(modelOut.match == 0) = false;
end

% Remove metabolites that are not used anymore
if (metFlag)
  selMets = modelOut.mets(any(sum(abs(modelOut.S),2) == 0,2));
  if (~isempty(selMets))
    modelOut = removeMetabolites(modelOut, selMets, false);
  end
end
