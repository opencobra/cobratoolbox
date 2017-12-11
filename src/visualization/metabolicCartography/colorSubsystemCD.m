function [newMap] = colorSubsystemCD(map, model, subsystem, color, areaWidth)
% Color and increase areaWidth of every reaction in a specific subsystem
%
% USAGE:
%
%   [newMap] = colorSubsystemCD(map, model, subsystem, color, areaWidth);
%
% INPUTS:
%   map:            File from CellDesigner parsed to MATLAB format
%   model:          COBRA model structure
%   subsystem:      Name of a subsystem as a String
%
% OPTIONAL INPUTS:
%   color:          Color desired for reactions in CAPITALS
%   areaWidth:          Width desired for reactions
%
% OUTPUT:
%   newMap          MATLAB structure of map with reaction modifications
%
% .. Authors:
%       - A.Danielsdottir 17/07/2017 LCSB. Belval. Luxembourg
%       - N.Sompairac - Institut Curie, Paris, 11/10/2017.

    if nargin < 5
        areaWidth = 8;
    end
    if nargin < 4
        color = 'RED';
    end

    newMap = map;
    rxnList = model.rxns(ismember([model.subSystems{:}]', subsystem));
    colors = createColorsMap;

    index = find(ismember(newMap.rxnName, rxnList));
    for j = index'
        newMap.rxnColor{j, 1} = colors(color);
        newMap.rxnWidth{j, 1} = areaWidth;
    end

    % Use the existence of reactant lines to check if the map has the
    % complete structure, and if so change also secondary lines.
    if any(strcmp('rxnReactantLineColor', fieldnames(newMap))) == 1
        for j = index'
            if ~isempty(newMap.rxnReactantLineColor{j})
                for k = 1:length(newMap.rxnReactantLineColor{j})
                    newMap.rxnReactantLineColor{j, 1}{k, 1} = colors(color);
                    newMap.rxnReactantLineWidth{j, 1}{k, 1} = areaWidth;
                end
            end
            if ~isempty(newMap.rxnProductLineColor{j})
                for m = 1:1:length(newMap.rxnProductLineColor{j})
                    newMap.rxnProductLineColor{j, 1}{m, 1} = colors(color);
                    newMap.rxnProductLineWidth{j, 1}{m, 1} = areaWidth;
                end
            end
        end
    end

end
