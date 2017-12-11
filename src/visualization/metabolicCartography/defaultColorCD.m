function [newmap] = defaultColorCD(map)
% Change all reaction lines to black and default areaWidth
%
% USAGE:
%
%   [newmap] = defaultColorCD(map);
%
% INPUT:
%   map:        file from CellDesigner parsed to matlab format
%
% OUTPUT:
%   newmap:     MATLAB structure of map with all rxn lines as default
%               color and areaWidth
%
% .. Authors:
%       - A.Danielsdottir 17/07/2017 LCSB. Belval. Luxembourg
%       - N.Sompairac - Institut Curie, Paris, 17/07/2017.

    newmap = map;
    color = 'ff000000';
    areaWidth = 1.0;

    for j = 1:length(newmap.rxnName)
        newmap.rxnColor{j, 1} = color;
        newmap.rxnWidth{j, 1} = areaWidth;
    end
    % Use the existence of reactant lines to check if the map has the
    % complete structure, and if so change also secondary lines.
    for j = 1:length(newmap.rxnName)
        if any(strcmp('rxnReactantLineColor', fieldnames(newmap))) == 1
            if ~isempty(newmap.rxnReactantLineColor{j})
                for k = 1:length(newmap.rxnReactantLineColor{j})
                    newmap.rxnReactantLineColor{j, 1}{k, 1} = Colors(color);
                    newmap.rxnReactantLineWidth{j, 1}{k, 1} = areaWidth;
                end
            end
            if ~isempty(newmap.rxnProductLineColor{j})
                for m = 1:1:length(newmap.rxnProductLineColor{j})
                    newmap.rxnProductLineColor{j, 1}{m, 1} = Colors(color);
                    newmap.rxnProductLineWidth{j, 1}{m, 1} = areaWidth;
                end
            end
        end
    end

end
