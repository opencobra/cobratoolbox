function [present] = isReactionInSubSystem(model,reactions,subSystem)
% Determine whether a reaction is in a given subSystem.
%
% USAGE:
%
%    [present]  = isReactionInSubSystem(model,reactions,subSystem)
%
% INPUT:
%    model:                 A COBRA model struct with at least rxns and
%                           subSystems or rxn2subSystem(COBRA V4) fields
%    reactions:             Either a string identifying a reaction, or a
%                           cell array of strings identifying multiple
%                           reactions, or a double vector identifying the
%                           positions.
%    subSystem:             A String identifying a subsystem.
% OUTPUT:
%    present:               a boolean vector for each provided reaction.
%
%
% .. Author: - Thomas Pfau Nov 2017
%            - Farid Zare 2024/08/14 support COBRA model V4

if ischar(reactions)
    reactions = {reactions};
end

if ischar(subSystem)
    subSystem = {subSystem};
end

% Set defualt value
present = false(numel(reactions), 1);

if iscell(reactions)
    [rxnID] = ismember(model.rxns, reactions);
    [rxnExists] = ismember(reactions, model.rxns);
end

if isnumeric(reactions)
    if max(reactions) > numel(model.rxns)
        error('Index of reactions exceeds number of reactions in the model');
    end
    rxnID = reactions;
    rxnExists = true(size(reactions));
end

% Check to see if model already has "rxn2subSystem" fields
if ~isfield(model, 'rxn2subSystem') || ~isfield(model, 'subSystemNames')
    warning('"rxn2subSystem" or "subSystemNames" fields has been generated because they did not exist in the model.')
    model = buildRxn2subSystem(model);
end

% find subSystem from reactions
subSystemID = ismember(model.subSystemNames, subSystem);
rxn2subSystemMat = model.rxn2subSystem(rxnID, subSystemID);

% Find existing reaction IDs
present(rxnExists) = logical(sum(rxn2subSystemMat, 2));
