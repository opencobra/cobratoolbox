function [model]  = setRxnSubSystems(model,reactions,subSystems)
% Sets the subSystems of the specified reactions to the specified
% subSystems
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
%    % Set TCA as subSystem for a set of reactions
%    [model]  = setRxnSubSystems(model, {'ACONTa';'ACONTb';'AKGDH';'CS';'FUM';'ICDHyr';'MDH';'SUCOAS'}, 'TCA')
%    % Set Glycolysis/Gluconeogenesis to reaction 18 of the model
%    [model]  = setRxnSubSystems(model, 18, {'Glycolysis','Gluconeogenesis'})
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

if numel(subSystems) > 1
    subSystems = setdiff(subSystems,{''});
end

model.subSystems(reactions) = {subSystems};

