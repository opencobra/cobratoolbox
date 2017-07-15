function [LeakMets,modelClosed,FluxExV] = fastLeakTest(model, testRxns,demandTest)
% [LeakMets,modelClosed,FluxExV] = fastLeakTest(model, testRxns,test)
% Tests if any metabolites in a model are leaking. A metabolite is leaking 
% if the exchange reaction can carry secretion flux in the closed model (no
% uptake flux through any exchange reactions is permitted).
% INPUT 
% model             Model structure
% testRxns          List of exchange reactions to be testetd for leaks
% demandTest        Optional: if 'true' is entered, demand reactions
%                   for all metabolites in the model are created
% OUTPUT
% LeakMets          List of exchange reactions for leaking metabolites 
% modelClosed       Model strucutre that has been tested for leaks
% FluxExV           Flux vector for computed exchange reactions in the
% closed model
%%
% IT Jan 2015
% description added by AH July 2017
if nargin<3
    demandTest = 'true';
end
tol = 1e-06;
modelClosed = model;
% find all reactions that have only one entry in S
clear count ExR
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
ExR = modelClosed.rxns(find(count));

modelexchangesAbbr = unique([testRxns;ExR]);
FluxEx = [];
cnt =1;
%% test for all demand reactions is an option
if strcmp(demandTest,'true')
% add demand reactions for all metabolites in model to check for those too
% [modelClosed,rxnNames] = addDemandReaction(modelClosed,modelClosed.mets,0);
[modelClosed,rxnNames] = addDemandReaction(modelClosed,modelClosed.mets);
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