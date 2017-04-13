function [modelMin,AddedExchange] = findMinCardModel(model,Ex_Rxns)
% Function to find the minimal cardinality model.
%
% USAGE:
%    [modelMin, AddedExchange] = findMinCardModel(model, Ex_Rxns)
%
% INPUTS:
%     model:         Metabolic model
%     Ex_Rxns:       Vector of exchange reactions for FVA
%
% OUTPUTS:
%    modelMin:       Updated model with new reaction bounds
%    AddedExchange:  Vector of exchanged reactions
%
% .. Authors:
%       - Ines Thiele 2014
%       - Maike K. Aurich 27/05/15 change tolerance

tol = -1e-6;  % Default tolerance (limit for calling flux 0)

AddedExchange = '';
% convert to irrev model
[modelIrrev,matchRev,rev2irrev,irrev2rev] = convertToIrreversible(model);
%translate Ex_Rxns from rev model to irrev model
Ex_RxnsIrrev=[];
for w=1:length(Ex_Rxns)
    tmp = modelIrrev.rxns(strmatch(Ex_Rxns(w),modelIrrev.rxns));
    Ex_RxnsIrrev = [Ex_RxnsIrrev; tmp];
end

minNorm = zeros(length(modelIrrev.rxns),1);
minNorm(ismember(modelIrrev.rxns,Ex_RxnsIrrev))= 1;


modelIrrev.osense=1; %minimize linear objective


[solutionCard2]=solveCobraLPCPLEXcard(modelIrrev,0,0,[],[],minNorm,'zero');

% needs backward translation from irrev to rev
% update constraints in original model according to solution
RxnID = find(ismember(modelIrrev.rxns,Ex_RxnsIrrev));
unUsedRxns = find(solutionCard2.full<=abs(tol));
usedRxns = find(solutionCard2.full>abs(tol));
UnusedRxnID = intersect(unUsedRxns,RxnID);
UsedRxnID = intersect(usedRxns,RxnID);
modelMin = model;
for i = 1 :length(UnusedRxnID)
    if strcmp(modelIrrev.rxns{UnusedRxnID(i)}(end-1:end),'_r')
        OriModelName = modelIrrev.rxns{UnusedRxnID(i)}(1:end-2);
        modelMin = changeRxnBounds(modelMin,OriModelName,0,'b');
    elseif strcmp(modelIrrev.rxns{UnusedRxnID(i)}(end-1:end),'_b') % no uptake
        OriModelName = modelIrrev.rxns{UnusedRxnID(i)}(1:end-2);
        modelMin = changeRxnBounds(modelMin,OriModelName,0,'l');
    elseif strcmp(modelIrrev.rxns{UnusedRxnID(i)}(end-1:end),'_f') % no secretion
        OriModelName = modelIrrev.rxns{UnusedRxnID(i)}(1:end-2);
        modelMin = changeRxnBounds(modelMin,OriModelName,0,'u');
    else
        OriModelName = modelIrrev.rxns{UnusedRxnID(i)};
        modelMin = changeRxnBounds(modelMin,OriModelName,0,'b');
    end
end
cntR=1;
for i = 1 :length(UsedRxnID)
    if strcmp(modelIrrev.rxns{UsedRxnID(i)}(end-1:end),'_r')
        AddedExchange{cntR,1} = strcat(modelIrrev.rxns{UsedRxnID(i)}(1:end-2));
        cntR = cntR+1;
    elseif strcmp(modelIrrev.rxns{UsedRxnID(i)}(end-1:end),'_b') %  uptake
        AddedExchange{cntR,1}= strcat(modelIrrev.rxns{UsedRxnID(i)}(1:end-2));
        
        cntR = cntR+1;
    elseif strcmp(modelIrrev.rxns{UsedRxnID(i)}(end-1:end),'_f') %  uptake
        AddedExchange{cntR,1}= strcat(modelIrrev.rxns{UsedRxnID(i)}(1:end-2));
        
        cntR = cntR+1;
        
    else
        AddedExchange{cntR,1} = strcat(modelIrrev.rxns{UsedRxnID(i)});
        cntR = cntR+1;
    end
end
