function [modelMin, modelPruned, Ex_Rxns] = generateCompactExchModel(model,minGrowth,biomassRxn,prune,fastFVA)
% This function identifies a subnetwork with the least number of possible exchange
% reactions given the model and the applied constraints. It returns the resulting pruned model.
%
% USAGE:
%
%    [modelMin, modelPruned, Ex_Rxns] = generateCompactExchModel(model, minGrowth, biomassRxn, prune, fastFVA)
%
% INPUTS:
%    model:         model structure
%    minGrowth:     minimal Growth rate to be set on biomass reaction
%    biomassRxn:    biomass reaction name (default: 'biomass_reaction2')
%    prune:         optional: to prune the model based on exchange reactions
%                   (default: 1)
%    fastFVA:       optional: to use fastFVA instead of fluxvariability for
%                   computing FVA results (default: 0)
%    medium:        (default: {})
%
% OUTPUTS:
%    modelUpdated:  same as input model but constraints on blocked reactions
%                   are set to be 0
%    modelPruned:   pruned model, where all blocked reactions are removed
%                   (attention this seems to cause issues with GPRs)
%    Ex_Rxns:       List of exchange reactions in pruned model
% 
% .. Author: - Ines Thiele, 02/2014

medium={};

if ~exist('biomassRxn','var')
    biomassRxn = 'biomass_reaction2';
end
if ~exist('prune','var')
    prune = 1;
end
if ~exist('fastFVA','var')
    fastFVA = 0;
end

% find exchange reactions
cnt=1;
for t=1:length(model.rxns)
    if  strfind(model.rxns{t}, 'EX_')
        Ex_Rxns1All(cnt,1) =model.rxns(t); %make exchange reaction list
        cnt=cnt+1;
    elseif  strfind(model.rxns{t}, 'Ex_')
        Ex_Rxns1All(cnt,1) =model.rxns(t); %make exchange reaction list
        cnt=cnt+1;
    end
end
% exclude all exchanges that have been set
Ex_Rxns2Min = Ex_Rxns1All;

model.rev = zeros(length(model.rxns),1);
model.rev(find(model.lb<0))=1;
model.lb(find(ismember(model.rxns,biomassRxn)))=minGrowth;% based on slowlest cell line in data


% exclude ions
Ex_Rxns2Min(ismember(Ex_Rxns2Min,medium))=[];

% identify iteratively the minimal exchange reaction network
OptExchRxns = Ex_Rxns2Min;
LO = length(OptExchRxns);
OptExchRxnsLast = OptExchRxns;
modelMin = model;
first = 1;
while LO>0
    if length(OptExchRxns)>0
        [modelMin,AddedExchange] = findMinCardModel(modelMin,OptExchRxns);
        if first == 0
            [OptExchRxns] = findOptExchRxns(modelMin,OptExchRxns);
        elseif first == 1
           [OptExchRxns] = findOptExchRxns(modelMin,AddedExchange);
            first =1;
        end
        LO = length(OptExchRxnsLast) - length(OptExchRxns)
        OptExchRxnsLast = OptExchRxns;
    else
        LO = 0;
    end
end

if prune == 1
    % prune the model. modelMin has same dimension but all blockedRxns
    % have bounds set to 0
    [modelMin,modelPruned, Ex_Rxns] = pruneModel(modelMin,minGrowth,biomassRxn);
else
    modelPruned = struct();
    Ex_Rxns = '';
end

