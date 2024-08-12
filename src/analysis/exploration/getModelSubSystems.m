function [subSystems]  = getModelSubSystems(model)
% Get unique set of subSystems present in a model
%
% USAGE:
%
%    [subSystems]  = getModelSubSystems(model)
%
% INPUT:
%    model:                 A COBRA model struct with at least the
%                           subSystems fields
%
% OUTPUT:
%    subSystems:            A Cell Array of strings containing all
%                           subSystems in the model
%
% USAGE:
%    Get all subSystems present in the model.
%    [subSystems]  = getModelSubSystems(model)
%
% .. Author: - Thomas Pfau Nov 2017
%            - Farid Zare March 2024  nested cells compatibility

% Check to see if subSystem elements are characters or cells
if isfield(model, 'subSystems')
    cellBool = cellfun(@(x) iscell(x), model.subSystems);
    charBool = cellfun(@(x) ischar(x), model.subSystems);

    % Check to see if the subSystem cell is a nested cell
    nestedCells = false;
    for i = 1:numel(model.subSystems)
        if iscell(model.subSystems{i})
            nestedCells = true;
        end
    end

    if ~nestedCells
        if all(charBool)
            subSystems = unique(model.subSystems);
        elseif all(cellBool)
            orderedSubs = cellfun(@(x) columnVector(x),model.subSystems,'UniformOUtput',false);
            % Concatenate all sub-system names and exclude empty elements
            subSystems = setdiff(vertcat(orderedSubs{:}),'');
        else
            subSystems = unique(model.subSystems);
        end
        if isempty(subSystems)
            subSystems = {};
        end

    else
        % In the case of nested cell format of sub-systems
        subSystemVec = {};
        for i = 1:numel(model.subSystems)
            if ischar(model.subSystems{i})
                subList = model.subSystems(i);
            else
                subList = model.subSystems{i};
            end
            % turn it into a vertical vector if it is not
            subList = columnVector(subList);
            subSystemVec = [subSystemVec; subList];
        end
        subSystems = unique(subSystemVec);
    end
else
    subSystems = {};
end

% Remove empty elements from sub-system name list
nonEmptyIndices = ~cellfun('isempty', subSystems);
subSystems = subSystems(nonEmptyIndices);
