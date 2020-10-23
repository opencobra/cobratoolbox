function [modelComp] = createModelNewCompartment(model,OldComp,NewComp,NewCompName,LB,UB,RemoveExch)
% This function converts a two compartment metabolic model into a three compartment metabolic model model
% 
% function [modelComp] = createModelNewCompartment(model,OldComp,NewComp,NewCompName,LB,UB,RemoveExch)
% 
% INPUT 
% model         Model structure
% OldComp       Name of the current (to be replicated) compartment to be
%               replicated and added
% NewCompName   Name of new compartment e.g., 'lumen'
% LB            Value for Lower bound on new exchange compartment (default:-1000)
% UB            Value for Upper bound on new exchange compartment (default:1000)
% 
% NewComp       Abrreviation for the new compartment,m e.g., 'lu'
% RemoveExch    Option (if set to 1) to remove the old compartment
%
% OUTPUT
% modelComp     Model with three compartments
%
% Ines Thiele 2016-2017

warning off
if ~exist('LB','var')
    LB = -1000;
end

if ~exist('UB','var')
    UB = 1000;
end

if ~exist('RemoveExch','var')
    RemoveExch = 0;
end
% find exchange reactions
cnt = 1;
for t=1:length(model.rxns)
    if  strfind(model.rxns{t}, 'EX_')
        Ex_RxnsAll(cnt,1) =model.rxns(t); %make exchange reaction list
        cnt=cnt+1;
    elseif  strfind(model.rxns{t}, 'Ex_')
        Ex_RxnsAll(cnt,1) =model.rxns(t); %make exchange reaction list
        cnt=cnt+1;
    end
end

% duplicate all ExtRxns in a new compartment [i] for the New Compartment and
% for new exchange reactions
%a = printRxnFormulaOri(model, Ex_RxnsAll,[],[],[],[],false);
a = printRxnFormula(model,'rxnAbbrList',Ex_RxnsAll,'printFlag',0,'lineChangeFlag',0,'metNameFlag',0,'fid',0,'directionFlag',0);

aOri = a;
modelComp = model;

for i = 1 : length(Ex_RxnsAll)
    b = find(ismember(model.rxns,Ex_RxnsAll(i)));
    if ~isempty(strfind(a{i},strcat('[',OldComp,']'))) && length(find(model.S(:,b))) ==1
        % add new reactions to model
        [metaboliteList,stoichCoeffList] = parseRxnFormula(a{i});
        metaboliteListA = regexprep(metaboliteList,strcat('\[',OldComp,'\]'),strcat('\[',NewComp,'\]'));
        if UB == 0
            UBO = -1*LB;
            LBO = 0;
            revFlag = 0;
            RxnName = strcat(model.rxnNames{b},' (from ',NewCompName,'to ',strcat('[',OldComp,']'));
            modelComp = addReaction(modelComp,{strcat(Ex_RxnsAll{i},'_[',NewComp,']'),RxnName},[metaboliteListA metaboliteList],...
                [-1 1], revFlag,LBO,UBO,0,strcat('Transport'),'',[],[],0,0);
        else
            metaboliteList = [metaboliteList metaboliteListA];
            stoichCoeffList = [-1 1];
            if LB < 0
                revFlag = 1;
            else
                revFlag = 0;
            end
            RxnName = strcat(model.rxnNames{b},' (from ',strcat('[',OldComp,']'),' to ',NewCompName,')');
            %replaced addReactionOri - Ronan
            modelComp = addReaction(modelComp,{strcat(Ex_RxnsAll{i},'_[',NewComp,']'),RxnName},metaboliteList,stoichCoeffList,...
                revFlag,LB,UB,0,strcat('Transport'),'',[],[],0,0);
            %modelComp = addReaction(modelComp,{strcat(Ex_RxnsAll{i},'_[',NewComp,']'),RxnName},'metaboliteList',metaboliteList,'stoichCoeffList',stoichCoeffList,...
             %'lowerBound',LB,'upperBound',UB,'objectiveCoef',0,'subSystem',{'Transport'},'geneRule','','geneNameList',[],'systNameList',[],'checkDuplicate',0,'printLevel',0);
        end
    end
end
a=aOri;
if RemoveExch == 1
    for i = 1 : length(Ex_RxnsAll)
        % remove original reactions
        b = find(ismember(modelComp.rxns,Ex_RxnsAll(i)));
        if ~isempty(strfind(a{i},strcat('[',OldComp,']'))) && length(find(modelComp.S(:,b))) ==1
            if isfield(modelComp,'rxnGeneMat')
            modelComp = rmfield(modelComp,'rxnGeneMat');
            end
            modelComp = removeRxns(modelComp,Ex_RxnsAll{i});
        end
    end
end
