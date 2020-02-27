function [model,rxnNames] = addDemandReactionOri(model,metaboliteNameList, addRxnGeneMat)
% addDemandReaction adds demand reactions for a set of metabolites
% The reaction names for the demand reactions will be DM_[metaboliteName]
%
% model = addDemandReaction(model,metaboliteNameList)
%
% INPUTS
% model                 COBRA model structure
% metaboliteNameList    List of metabolite names (cell array)
% addRxnGeneMat         Adds rxnGeneMat to model structure (default = true)
%
% OUTPUTS
% model                 COBRA model structure with added demand reactions
% rxnNames              List of added reactions
%
% Markus Herrgard 5/8/07
% Ines Thiele 03/09 - Corrected reaction coefficient for demand reaction
% Ines Thiele 08/03/2015, made rxnGeneMat optional
if ~exist('addRxnGeneMat','var')
    addRxnGeneMat = 1;
end

if (~iscell(metaboliteNameList))
    tmp = metaboliteNameList;
    clear metaboliteNameList;
    metaboliteNameList{1} = tmp;
end

for i = 1:length(metaboliteNameList)
    rxnName = ['DM_' metaboliteNameList{i}];
    rxnNames{i}=rxnName;
    metaboliteList = {metaboliteNameList{i}};
%     [model,rxnIDexists] = addReaction(model,rxnName,metaboliteList,stoichCoeffList,revFlag,lowerBound,upperBound,objCoeff,subSystem,grRule,geneNameList,systNameList,checkDuplicate, addRxnGeneMat)
    model = addReactionOri(model,rxnName,metaboliteList,-1,false,0,1000,0,'Demand','',[],[],0, addRxnGeneMat);
end
