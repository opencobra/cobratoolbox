function [model,rxnNames] = addDemandReaction(model,metaboliteNameList, printLevel)
% Adds demand reactions for a set of metabolites
% The reaction names for the demand reactions will be `DM_[metaboliteName]``
%
% USAGE:
%
%    model = addDemandReaction(model, metaboliteNameList)
%
% INPUTS:
%    model:                 COBRA model structure
%    metaboliteNameList:    List of metabolite names (cell array)
%
% OPTIONAL INPUT:
%    printLevel:            If > 0 will print out the reaction formulas (Default: 1).
%
% OUTPUTS:
%    model:                 COBRA model structure with added demand reactions
%    rxnNames:              List of added reactions
%
% .. Authors:
%       - Markus Herrgard 5/8/07
%       - Ines Thiele 03/09 - Corrected reaction coefficient for demand reaction
%       - Thomas Pfau, June 2018 - Change to use addMultipleReactions and adding printLevel 

if (~iscell(metaboliteNameList))
    metaboliteNameList = {metaboliteNameList};
end

if nargin < 3 %No PrintLevel
    printLevel = 0;
end

missingMets = setdiff(metaboliteNameList,model.mets);
if ~isempty(missingMets)
    warning('The following Metabolites have been added to the model, as they were not in the model before:\n%s', strjoin(missingMets,'\n'));
    model = addMultipleMetabolites(model,missingMets);
end

rxnNames = rowvector(strcat('DM_',metaboliteNameList));    
nMets = length(metaboliteNameList);
stoich = -1 * speye(nMets);
subSystems = repmat({'Demand'},nMets,1);
ubs = repmat(1000,nMets,1);
lbs = zeros(nMets,1);
model = addMultipleReactions(model,rxnNames,metaboliteNameList,stoich,...
                             'lb',lbs,'ub',ubs,'subSystems',subSystems,...
                             'printLevel',printLevel);        
end
