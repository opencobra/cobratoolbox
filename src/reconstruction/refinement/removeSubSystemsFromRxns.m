function [model]  = removeSubSystemsFromRxns(model,reactions,subSystems)
% Adds the subSystem to the specified reaction
%
% USAGE:
%
%    [model]  = addSubSystemToReaction(model,reaction,subSystem)
%
% INPUT:
%    model:                 A COBRA model struct with at least rxns and
%                           subSystems fields
%    reactions:             Either a string identifying a reaction, or a
%                           cell array of strings identifying multiple
%                           reactions, or a double vector or boolean vector
%                           identifying positions.
%    subSystems:            A String identifying a subsystem, or a cell
%                           array of strings to assign multiple subSystems.
%                           If multiple strings are present, an empty
%                           string will be removed
%
% OUTPUT:
%    model:                 The model with the subSystems set to the
%                           respective reactions (old values will be removed).
%
% EXAMPLE:
%    %Remove TCA as subSystem from a set of reactions
%    [model]  = removeSubSystemsFromRxns(model,{'ACONTa';'ACONTb';'AKGDH';'CS';'FUM';'ICDHyr';'MDH';'SUCOAS'},'TCA')
%    %Remove Glycolysis/Gluconeogenesis from reaction 18 of the model
%    [model]  = removeSubSystemsFromRxns(model,18,{'Glycolysis','Gluconeogenesis'})
%
% .. Author: - Thomas Pfau Nov 2017
if ischar(reactions) || iscell(reactions)
    [tempreactions] = ismember(model.rxns,reactions);
    if (iscell(reactions) && (sum(tempreactions) ~= length(reactions))) || (ischar(reactions) && sum(tempreactions) ~= 1)
        %If there are an unequal amount of reactions
        warning('There were reaction IDs not present in the model');
    end
    reactions = tempreactions;
end

if ~isfield(model,'subSystems')
    model.subSystems = cell(numel(model.rxns),1);
    model.subSystems(:) = {{''}};
end

if ischar(subSystems)
    subSystems = {subSystems};
end

if isempty(subSystems)
    return
end

model.subSystems(reactions) = cellfun(@(x) removeSubSystems(x,subSystems),model.subSystems(reactions),'UniformOutput',0);



function newSubSystems = removeSubSystems(subSystemVector,subSysToRemove)

newSubSystems = setdiff(subSystemVector,subSysToRemove);
if isempty(newSubSystems)
    newSubSystems = {''};
end

