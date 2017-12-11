function [newMap] = changeRxnColorAndWidth(map, rxnList, color, areaWidth)
% Change color and areaWidth of reactions from a list of names
%
% USAGE:
%
%   [newMap] = changeRxnColorAndareaWidth(map, rxnList, color, areaWidth);
%
% INPUTS:
%   map:            File from CellDesigner parsed to MATLAB format
%   rxnList:        List of reactions
%
% OPTIONAL INPUTS:
%   color:          New color of reactions from list (default: 'RED')
%   areaWidth:      New areaWidth of reactions from list (default: 8)
%
% OUTPUT:
%   newMap:         Matlab structure of map with reaction modifications
%
% .. Authors:
%       - A.Danielsdottir 17/07/2017 LCSB. Belval. Luxembourg
%       - N.Sompairac - Institut Curie, Paris, 17/07/2017.

    if nargin < 4
        areaWidth = 8;
    end
    if nargin < 3
        color = 'RED';
    end

    newMap = map;
    colors = createColorsMap;

    index = find(ismember(newMap.rxnName, rxnList));
    for j = index'
        newMap.rxnColor{j, 1} = colors(color);
        newMap.rxnWidth{j, 1} = areaWidth;

        % Use the existence of reactant lines to check if the newMap has the
        % complete structure.
        if any(strcmp('rxnReactantLineColor', fieldnames(newMap))) == 1
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
