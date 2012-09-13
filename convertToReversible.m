function modelRev = convertToReversible(model)
%convertToReversible convert a model structure from irreversible format to
%reversible format
%
% modelRev = convertToReversible(model)
%
%INPUT
% model     COBRA model in irreversible format (forward/backward reactions
%           separated)
%
%OUTPUT
% modelRev  Model in reversible format
%
% Greg Hannum 7/22/05

% Initialize
modelRev.rxns = {};
modelRev.S = [];
modelRev.lb = [];
modelRev.ub = [];
modelRev.rev = [];
modelRev.c = [];

% Has this rxn been processed
rxnProcessed = false*ones(length(model.rxns),1);

cnt = 0;
for i = 1:length(model.rxns)
  if (model.match(i) == 0)
    % Non-reversible reaction
    cnt = cnt + 1;
    if (strcmp(model.rxns{i}(end-1:end),'_r') | strcmp(model.rxns{i}(end-1:end),'_b'))
      modelRev.rxns{end+1} = model.rxns{i}(1:end-2);
      modelRev.S(:,end+1) = -model.S(:,i);
      modelRev.ub(end+1) = -model.lb(i);
      modelRev.lb(end+1) = -model.ub(i);
      modelRev.c(end+1) = -model.c(i);
    else
      if (strcmp(model.rxns{i}(end-1:end),'_f'))
        modelRev.rxns{end+1} = model.rxns{i}(1:end-2);
      else
        modelRev.rxns{end+1} = model.rxns{i};
      end
      modelRev.S(:,end+1) = model.S(:,i);
      modelRev.lb(end+1) = model.lb(i);
      modelRev.ub(end+1) = model.ub(i);
      modelRev.c(end+1) = model.c(i);
    end
    modelRev.rev(end+1) = false;
    map(cnt) = i;
  else
    % Reversible reaction
    if (~rxnProcessed(i)) % Don't bother if this has already been processed
      cnt = cnt + 1;
      map(cnt) = i;
      modelRev.rxns{end+1} = model.rxns{i}(1:end-2);
      modelRev.S(:,end+1) = model.S(:,i);
      modelRev.ub(end+1) = model.ub(i);
      modelRev.rev(end+1) = true;
      revRxnID = model.match(i);
      rxnProcessed(revRxnID) = true;
      % Get the correct ub for the reverse reaction
      modelRev.lb(end+1) = -model.ub(revRxnID);
      % Get correct objective coefficient
      if (model.c(i) ~= 0)
        modelRev.c(end+1) = model.c(i);
      elseif (model.c(revRxnID) ~= 0)
        modelRev.c(end+1) = -modelRev.c(revRxnID);
      else
        modelRev.c(end+1) = 0;
      end
    end
  end
end

modelRev.ub = columnVector(modelRev.ub);
modelRev.lb = columnVector(modelRev.lb);
modelRev.rxns = columnVector(modelRev.rxns);
modelRev.c = columnVector(modelRev.c);
modelRev.rev = columnVector(modelRev.rev);
modelRev.mets = columnVector(model.mets);
if (isfield(model,'b'))
    modelRev.b = model.b;
end
if isfield(model,'description')
    modelRev.description = [model.description ' reversible'];
end
if isfield(model,'subSystems')
    modelRev.subSystems = model.subSystems(map);
end
if isfield(model,'genes')
    modelRev.genes = model.genes;
    modelRev.rxnGeneMat = model.rxnGeneMat(map,:);
    modelRev.rules = model.rules(map);
end
modelRev.reversibleModel = true;
