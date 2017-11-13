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
% USAGE:
%    %Obtain all reactions with Glycolysis in their respective subSystems
%     field.
%    [reactionNames,rxnPos]  = findRxnsFromSubSystem(model,'Glycolysis')
%
% .. Author: - Thomas Pfau Nov 2017

present = cellfun(@(x) any(ismember(x,subSystem)),model.subSystems);
reactionNames = model.rxns(present);
rxnPos = find(present);