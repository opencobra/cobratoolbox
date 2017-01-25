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
% Fatima Liliana Monteiro and Hulda Haraldsdóttir, November 2016


if (nargin < 3)
  irrevFlag = false;
end
if (nargin < 4)
  metFlag = true;
end

[nMets,nRxns] = size(model.S);
nGenes = length(model.genes);

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
selectRxns = true(nRxns,1);
selectRxns(removeInd) = false;

% Construct new model
modelOut = model;

mfields = fieldnames(model);
rfields = {};

if ~any([nMets nGenes] == nRxns)
    for i = 1:length(mfields)
        if any(size(model.(mfields{i})) == nRxns)
            rfields = [rfields mfields(i)];
        end
    end
else
    rfields = {'S' 'c' 'lb' 'ub' 'rxns' 'rules' 'grRules' 'rev' 'subSystems'}';
    rfields = [rfields; mfields(strncmp('rxn', mfileds, 3))];
    rfields = intersect(rfields,mfields);
end

for i = 1:length(rfields)
   if size(model.(rfields{i}),1) == nRxns
       modelOut.(rfields{i}) = modelOut.(rfields{i})(selectRxns,:);
   else size(model.(rfields{i}),2) == nRxns
       modelOut.(rfields{i}) = modelOut.(rfields{i})(:,selectRxns);
   end
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
