function [newMap] = colorRxnType(map, type, color, width)
% colors reactions based on their type and modifies their width.
%
% USAGE:
%
%   [newMap] = createColorsMap(map, type, color);
%
% INPUTS:
%   map:        Map from CellDesigner parsed to MATLAB format
%   type:       Type of reactions to be colored (as String)
%   color:      Color used to color reactions (see createColorsMap.m)
%   width:      Width size for reactions (default: 8)
%
% OUTPUT:
%   newMap:     MATLAB structure of new map with needed reactions type
%               colored and width modified
%
% .. Author: - N.Sompairac - Institut Curie, Paris, 20/10/2017

    newMap = map;

    % Setting the default width if not given in inputs
    if nargin < 4
        width = 8;
    end

    % Create a Color map with corresponding colors names and their HTML code
    colors = createColorsMap;

    % Getting reactions list based on the needed type
    rxnIndexList = find(ismember(newMap.rxnType, type));

    % Looping over needed reactions
    for index = rxnIndexList'
        % Modify reaction's base color and width
        newMap.rxnColor{index} = colors(color);
        newMap.rxnWidth{index} = width;
        % Check if reaction contains any reactants
        if ~isempty(newMap.rxnReactantID{index})
            if length(newMap.rxnReactantID{index}) == 1
                % Case where the reaction contains only 1 reactant
                newMap.rxnReactantLineColor{index, 1}{1, 1} = colors(color);
                newMap.rxnReactantLineWidth{index, 1}{1, 1} = width;
            else
                % Case where the reaction contains several reactants
                for react = 1:length(newMap.rxnReactantID{index})
                    newMap.rxnReactantLineColor{index, 1}{react, 1} = colors(color);
                    newMap.rxnReactantLineWidth{index, 1}{react, 1} = width;
                end
            end
        end
        % Check if reaction contains any products
        if ~isempty(newMap.rxnProductID{index})
            if length(newMap.rxnProductID{index}) == 1
                % Case where the reaction contains only 1 product
                newMap.rxnProductLineColor{index, 1}{1, 1} = colors(color);
                newMap.rxnProductLineWidth{index, 1}{1, 1} = width;
            else
                % Case where the reaction contains several products
                for react = 1:length(newMap.rxnProductID{index})
                    newMap.rxnProductLineColor{index, 1}{react, 1} = colors(color);
                    newMap.rxnProductLineWidth{index, 1}{react, 1} = width;
                end
            end
        end
    end

end
