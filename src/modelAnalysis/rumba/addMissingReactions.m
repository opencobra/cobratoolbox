function model = addMissingReactions(SampledModel,completeModel)
model = completeModel;

% find all nonmissing reactions and make a new points matrix
NonMissingRxns = completeModel.rxns(ismember(completeModel.rxns,SampledModel.rxns));
model.points = zeros(length(model.rxns),length(SampledModel.points(1,:)));

% Move all sampled model points to the new model, and leave missing reaction points as zeros
SM_Ind = findRxnIDs(SampledModel,NonMissingRxns);
CM_Ind = findRxnIDs(model,NonMissingRxns);
model.points(CM_Ind,:) = SampledModel.points(SM_Ind,:);
end