function [model,rxnNames] = addDemandReaction(model,metaboliteNameList, rev, bound)
% addDemandReaction adds demand reactions for a set of metabolites
% The reaction names for the demand reactions will be DM_[metaboliteName]
%
% model = addDemandReaction(model,metaboliteNameList)
%
% INPUTS
% model                 COBRA model structure
% metaboliteNameList    List of metabolite names (cell array)
%
% OUTPUTS
% model                 COBRA model structure with added demand reactions
% rxnNames              List of added reactions
%
% Markus Herrgard 5/8/07
% Ines Thiele 03/09 - Corrected reaction coefficient for demand reaction

if (~iscell(metaboliteNameList))
    tmp = metaboliteNameList;
    clear metaboliteNameList;
    metaboliteNameList{1} = tmp;
end

if ~exist('rev', 'var')
    rev = 0;
end

if ~exist('bound', 'var')
    bound = 1000;
end

for i = 1:length(metaboliteNameList)
    rxnName = ['DM_' metaboliteNameList{i}];
    rxnNames{i, 1}=rxnName;
    metaboliteList = {metaboliteNameList{i}};
    if rev == 0
        model = addReaction(model,rxnName,metaboliteList,-1,false,0,bound,0,'Demand');
    else
        model = addReaction(model,rxnName,metaboliteList,-1,true,-bound,bound,0,'Demand');
    end
end
