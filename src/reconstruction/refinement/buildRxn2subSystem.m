function [modelOut, rxn2subSystem, subSystemNames, nestedCells] = buildRxn2subSystem(model, removeSubSystems)
% Generates reaction-subSystem matrix for a COBRA model
% This function adds two fields to the COBRA model: 1) rxnSubsystemMat and
% 2)subSystemsNames and removes the old subSystems field(optional and can
% be set to false)
%
% USAGE:
%
%    [modelOut, rxn2subSystem, subSystemNames, nestedCells] = buildRxn2subSystem(model, removeSubSystems)
%
% INPUTS:
%    model:               COBRA model structure
%
% OPTIONAL INPUTS:
%    removeSubSystems:    Binary variable, if equals to 1 (or true) subSystems 
%                         field will be removed from the model default:true
%
% OUTPUTS:
%    modelOut:            COBRA model structure containing two added fields of
%                         "rxn2subSystem" and "subSystemsNames"
%    rxn2subSystem:       Matrix of reactions vs subSystems
%    subSystemNames:      Unique sub-system names in the model with order
%                         corrosponding to the matrix
%    nestedCells:         logical variable, True if sub-system field is a  
%                         nested cell vector and False if it's not
%
% .. Authors:
%     - Farid Zare 25 March 2024
%

% set optional input
if nargin < 2
    removeSubSystems = true;
elseif ~islogical(removeSubSystems) & removeSubSystems ~= 1 && removeSubSystems ~= 0
    error('removeSubSystem input should be logical variable true/false or 1/0')
end

% Check to see if model already has these fields
if isfield(model, 'rxn2subSystem')
    warning('rxn2subSystem matrix already exists in the model')
end

if isfield(model, 'subSystemNames')
    warning('subSystemNames field already exists in the model')
end

% Error if there is no subSystems field in the model
if ~isfield(model, 'subSystems')
    error('subSystems field should exist in the model')
end

% Error if there is no rxns field in the model
if ~isfield(model, 'rxns')
    error('rxns field should exist in the model')
end

% Check if the sub-system cell is a nested cell variable
nestedCells = false;
nlt = numel(model.subSystems);
for i = 1:nlt
    if iscell(model.subSystems{i})
        nestedCells = true;
    end
end

% Get model sub-system names
subSystemNames = getModelSubSystems(model); 

subsystemNum = numel(subSystemNames);
rxnNum = numel(model.rxns);

% construct the matrix
rxn2subSystem = zeros(rxnNum, subsystemNum);

for i = 1:rxnNum
    % This line would work for char, cells and nested cell formats
    if ischar(model.subSystems{i})
        subList = model.subSystems(i);
    else
        subList = model.subSystems{i};
    end
    row = ismember(subSystemNames, subList);
    rxn2subSystem(i,:) = row;
end

% Assign two fields to the output model
modelOut = model;

% Remove the subSystem field if it was set
if removeSubSystems
    modelOut = rmfield(modelOut, 'subSystems');
end

modelOut.subSystemNames = subSystemNames;
modelOut.rxn2subSystem = rxn2subSystem;
