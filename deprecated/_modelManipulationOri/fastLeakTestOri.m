function [LeakMets,modelClosed,FluxExV] = fastLeakTest(model, testRxns,test)
% This function performs a leak test, i.e., it tests whether the model can produce mass from nothing (i.e., when all lower bound on boundary reactions are set to be 0 corresponding to no uptake).
%
% [LeakMets,modelClosed,FluxExV] = fastLeakTest(model, testRxns,test)
%
% INPUT
% model         Model structure
% testRxns      Reactiosn to be tested 
% test          If empty (''), the input model structure will be tested as is.
%               If 'demand' is provided as input or no entry is provided, then demand
%               reactions for each internal metabolite will be added and the function
%               will test whether any of the internal metabolites can be produced from
%               nothing.
%
% OUTPUT
% LeakMets      List of metabolites that can be produced from nothing. If
%               empty the model is leak free.
% modelClosed   Model structure with closed boundary reactions (lower bound
%               = 0.
% FluxExV       List of boundary reactions that produce metabolites from
%               nothing.
% 
% Ines Thiele Jan 2015

if nargin<3
    test = 'demands';
end
tol = 1e-06;
modelClosed = model;
% find all reactions that have only one entry in S
clear count ExR
count=false(size(modelClosed.S,2),1);
for i = 1 :size(modelClosed.S,2)
    if length(find(modelClosed.S(:,i))<0)==1
        count(i,1)=1;
        modelClosed.lb(i)=0;
        % modelClosed.ub(i)=0;
    elseif length(find(modelClosed.S(:,i))>0)==1
        count(i,1)=1;
        %   modelClosed.ub(i)=0;
        modelClosed.lb(i)=0;
    end
end
ExR = modelClosed.rxns(count);

modelexchangesAbbr = unique([testRxns;ExR]);
FluxEx = [];
cnt =1;
%% test for all demand reactions is an option
if strcmp(test,'demands')
    % add demand reactions for all metabolites in model to check for those too
    [modelClosed,rxnNames] = addDemandReaction(modelClosed,modelClosed.mets,0);
else
    rxnNames = '';
end
modelexchangesAbbr = unique([modelexchangesAbbr;rxnNames']);
TestRxnNum = length(modelexchangesAbbr)
FluxExV =[];
while cnt == 1
    modelClosed = changeObjective(modelClosed,modelexchangesAbbr);
    FF2=optimizeCbModel(modelClosed,'max');
    ObjValue = FF2.f
    if FF2.f >= tol
        FluxR = modelClosed.rxns(find(abs(FF2.x)>tol));
        FluxEx = [FluxEx;intersect(modelexchangesAbbr,FluxR)];
        FluxExV = [FluxExV;FF2.x(find(ismember( modelClosed.rxns,intersect(modelexchangesAbbr,FluxR))))];
        modelexchangesAbbr = setdiff(modelexchangesAbbr, FluxEx);
        length(unique(FluxEx))
    else
        cnt = 2;
    end
end

LeakMets = FluxEx;