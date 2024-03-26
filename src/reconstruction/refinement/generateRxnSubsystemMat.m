function [modelOut, rxnSubSystemMat, subSystemNames, nestedCells] = generateRxnSubsystemMat(model)
% Generates reaction-subSystem matrix for a COBRA model
% This function adds two fields to the COBRA model: 1) rxnSubsystemMat and
% 2)subSystemsNames
%
% USAGE:
%
%    [modelOut, rxnSubSystemMat, subSystemNames] = generateRxnSubsystemMat(model)
%
% INPUTS:
%    model:          COBRA model structure
%
% OUTPUTS:
%    modelOut:            COBRA model structure containing two added fields of
%                         "rxnSubSystemMat" and "subSystemsNames"
%    rxnSubSystemMat:     Matrix of reactions vs subSystems
%    subsystemNames:      Unique sub-system names in the model with order
%                         corrosponding to the matrix
%    nestedCells:         logical variable, True if sub-system field is a  
%                         nested cell vector and False if it's not 
%
% .. Authors:
%     - Farid Zare 25 March 2024
%

% Check to see if model already has these fields
if isfield(model, 'rxnSubSystemMat')
    error('rxnSubsystemMat field already exists in the model')
end
if isfield(model, 'subSystemNames')
    error('subSystemNames field already exists in the model')
end

subSystems = model.subSystems;

% Check if the sub-system cell is a nested cell variable
nestedCells = false;
nlt = numel(subSystems);
for i = 1:nlt
    if iscell(subSystems{i})
        nestedCells = true;
    end
end

subSystemNames = {};
if ~nestedCells
    subSystemNames = unique(subSystems);
else
    for i = 1:nlt
        subList = subSystems{i};
        % turn it into a vertical vector if it is not
        subList = columnVector(subList);
        subSystemNames = [subSystemNames; subList];
    end
    subSystemNames = unique(subSystemNames);
end

% Remove empty elements from sub-system name list
nonEmptyIndices = ~cellfun('isempty', subSystemNames);
subSystemNames = subSystemNames(nonEmptyIndices);

subsystemNum = numel(subSystemNames);
rxnNum = numel(model.rxns);

% construct the matrix
rxnSubSystemMat = zeros(rxnNum,subsystemNum);

for i = 1:rxnNum
    row = ismember(subSystemNames, subSystems{i});
    rxnSubSystemMat(i,:) = row;
end

% Assign two fields to the output model
modelOut = model;
modelOut.subSystemNames = subSystemNames;
modelOut.rxnSubSystemMat = rxnSubSystemMat;
