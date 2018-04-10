function [model]  = addSubSystemsToReactions(model,reactions,subSystems)
% Adds the subSystems to the specified reactions
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
%                           array of strings to add multiple subSystems.
%                           An empty string will be filtered. All
%                           subSystems will be added to all identified
%                           reactions.
%
% OUTPUT:
%    model:                 The model with the subSystems added to the
%                           respective reactions (old, non empty, values are retained).
%
% EXAMPLE:
%
%    % Add TCA to a set of reactions   
%    [model]  = addSubSystemsToReactions(model,{'ACONTa';'ACONTb';'AKGDH';'CS';'FUM';'ICDHyr';'MDH';'SUCOAS'},'TCA')
%    % Add Glycolysis/Gluconeogenesis to a the reaction 18 of the model
%    [model]  = addSubSystemsToReactions(model,18,{'Glycolysis','Gluconeogenesis'})
%    
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

subSystems = setdiff(subSystems,{''}); % We don't add an empty string to existing subSystems.

if isempty(subSystems)
    return
end

model.subSystems(reactions) = cellfun(@(x) addSubSystem(x,subSystems),model.subSystems(reactions),'UniformOutput',0);



function newSubSystems = addSubSystem(subSystemVector,newSubSystems)
subSystemVector = setdiff(subSystemVector,{''});
newSubSystems = union(subSystemVector,newSubSystems);
