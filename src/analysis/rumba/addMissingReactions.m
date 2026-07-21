function model = addMissingReactions(SampledModel, completeModel)
% Verify the consistency between the sampled model and the complete
% reference model by checking that all reactions from the complete model
% are in the sampled model, then copy the sampled flux points onto the
% complete model reaction set (points of missing reactions are left as zeros)
%
% USAGE:
%
%    model = addMissingReactions(SampledModel, completeModel)
%
% INPUTS:
%    SampledModel:     Sampled model, with fields:
%
%                        * .rxns - reaction identifiers of the sampled model
%                        * .points - `nRxns x nPoints` matrix of sampled flux values
%    completeModel:    The complete reference model, with fields:
%
%                        * .rxns - reaction identifiers of the complete model
%
% OUTPUTS:
%    model:            Consistent sampled model wrt the complete model, with fields:
%
%                        * .points - `nRxns x nPoints` sampled flux values mapped
%                          onto the complete model reactions (missing reactions zero)
%
% .. Authors:
%       - Nathan E. Lewis, May 2010-May 2011
%       - Anne Richelle, May 2017

model = completeModel;

% find all nonmissing reactions and make a new points matrix
NonMissingRxns = completeModel.rxns(ismember(completeModel.rxns,SampledModel.rxns));
model.points = zeros(length(model.rxns),length(SampledModel.points(1,:)));

% Move all sampled model points to the new model, and leave missing reaction points as zeros
SM_Ind = findRxnIDs(SampledModel,NonMissingRxns);
CM_Ind = findRxnIDs(model,NonMissingRxns);
model.points(CM_Ind,:) = SampledModel.points(SM_Ind,:);
end
