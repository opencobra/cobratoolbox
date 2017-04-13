function [modelUpdated,modelPruned,Ex_Rxns] = pruneModel(model,minGrowth, biomassRxn)
% This function prunes a model to its most compact subnetwork given some model
% constraints and a minimal growth rate by identifying and removing all blocked reactions.
%
% USAGE:
%
%    [modelUpdated, modelPruned, Ex_Rxns] = pruneModel(model, minGrowth, biomassRxn)
%
% INPUTS:
%    model:         model structure
%    minGrowth:     minimal Growth rate to be set on biomass reaction
%    biomassRxn:    biomass reaction name (default: 'biomass_reaction2')
%
% OUTPUTS: 
%    modelUpdated:  same as input model but constraints on blocked reactions
%                   are set to be 0
%    modelPruned:   pruned model, where all blocked reactions are removed
%                   (attention this seems to cause issues with GPRs)
%    Ex_Rxns:       List of exchange reactions in pruned model
%
% .. Author: - Ines Thiele, 02/2014

if ~exist('biomassRxn','var')
    biomassRxn = 'biomass_reaction2';
end

modelUpdated = model;
modelForPruning = model;
modelForPruning.lb(modelForPruning.lb < 0) = -1000;
modelForPruning.ub(modelForPruning.ub < 0) = 0; % in case  uptake is enforced
modelForPruning.ub(modelForPruning.ub > 0) = 1000;
modelForPruning.lb(modelForPruning.lb > 0) = 0; % in case  secretion is enforced
modelForPruning.rev = zeros(length(modelForPruning.rxns),1);
modelForPruning.rev(find(modelForPruning.lb<0))=1;
%set back biomass constraint
modelForPruning.lb(find(ismember(modelForPruning.rxns,biomassRxn)))=minGrowth;
epsilon =1e-4;
[modelForPruningPruned, BlockedRxns] = identifyBlockedRxns(modelForPruning,epsilon);
cnt =1;
for t=1:length(modelForPruningPruned.rxns)
    if  strfind(modelForPruningPruned.rxns{t}, 'EX_')
        Ex_Rxns(cnt,1) =modelForPruningPruned.rxns(t); %make exchange reaction list
        cnt=cnt+1;
    elseif  strfind(modelForPruningPruned.rxns{t}, 'Ex_')
        Ex_Rxns(cnt,1) =modelForPruningPruned.rxns(t); %make exchange reaction list
        cnt=cnt+1;
    end
end

modelUpdated.lb(ismember(model.rxns,BlockedRxns.allRxns))=0;
modelUpdated.ub(ismember(model.rxns,BlockedRxns.allRxns))=0;

RxnsInModelMin = setdiff(model.rxns,BlockedRxns.allRxns); % all reactions that are not blocked
modelPruned = extractSubNetwork(model,RxnsInModelMin);
