function [reactionNames,rxnPos]  = findRxnsFromSubSystem(model,subSystem)
% Find all reactions which are part of a given subsystem.
%
% USAGE:
%
%    [reactionNames,rxnPos]  = findRxnsFromSubSystem(model,subSystem)
%
% INPUT:
%    model:                 A COBRA model struct with at least rxns and
%                           subSystems fields
%    subSystem:             A String identifying a subsystem
%
% OUTPUT:
%    reactionNames:         A Cell array of reaction names 
%    rxnPos:                A double array of positions of the reactions in
%                           reactionNames in the model (same order).
%
% EXAMPLE:
%
%    Obtain all reactions with Glycolysis in their respective subSystems
%    field.
%    [reactionNames,rxnPos]  = findRxnsFromSubSystem(model,'Glycolysis')
%
% .. Author: - Thomas Pfau Nov 2017, 
%            - Ronan MT. Fleming, 2022
%            - Farid Zare, 2024/08/14     updated the code to support rxn2subSystem field
%

% Check to see if model already has these fields
if ~isfield(model, 'rxn2subSystem')
    warning('The "rxn2subSystem" field has been generated because it was not in the model.')
    model = buildRxn2subSystem(model);
end

% Get subSystem ids
subSystemID = ismember(model.subSystemNames, subSystem);

% Get corresponding reactions
rxn2subSystemMat = model.rxn2subSystem(:, subSystemID);
rxnID = logical(sum(rxn2subSystemMat, 2));

reactionNames = model.rxns(rxnID);
rxnPos = find(rxnID);
