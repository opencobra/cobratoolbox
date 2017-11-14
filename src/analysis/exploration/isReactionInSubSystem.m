function [present]  = isReactionInSubSystem(model,reactions,subSystem)
% Determine whether a reaction is in a given subSystem.
%
% USAGE:
%
%    [subSystems]  = getModelSubSystems(model)
%
% INPUT:
%    model:                 A COBRA model struct with at least rxns and
%                           subSystems fields
%    reactions:             Either a string identifying a reaction, or a
%                           cell array of strings identifying multiple
%                           reactions, or a double vector identifying the
%                           positions.
%    subSystem:             A String identifying a subsystem.
% OUTPUT:
%    present:               a boolean vector for each provided reaction.
%
% USAGE:
%    %Get all subSystems present in the model.
%    [subSystems]  = getModelSubSystems(model)
%
% .. Author: - Thomas Pfau Nov 2017

if ischar(reactions)
    reactions = {reactions};
end

if iscell(reactions)
    [~,reactions] = ismember(reactions,model.rxns);
end

if isfield(model, 'subSystems')
    present = cellfun(@(x) any(ismember(x,subSystem)),model.subSystems(reactions));    
else
    present = false(numel(reactions));
end