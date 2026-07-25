function [newMap] = changeMetColor(map, metList, color)
% Change color of every metabolite from a list of Names
%
% USAGE:
%
%    [newMap] = changeMetColor(map, metList, color)
%
% INPUTS:
%    map:            File from CellDesigner parsed to MATLAB format, with fields:
%
%                      * .specName - cell array of species (metabolite) names
%                      * .specID - cell array of species IDs (one per name)
%                      * .molID - cell array of molecule (node) IDs
%    metList:        List of metabolites names
%
% OPTIONAL INPUT:
%    color:          New color of metabolites from list (default: RED)
%
% OUTPUT:
%    newMap:         MATLAB structure of map with field updated:
%
%                      * .molColor - cell array of molecule colours
%
% .. Authors:
%       - A.Danielsdottir 17/07/2017 LCSB. Belval. Luxembourg
%       - N.Sompairac - Institut Curie, Paris, 17/07/2017.

    if nargin < 3
        color = 'RED';
    end

    newMap = map;

    colors = createColorsMap();
    % Index for specName is the same as for corresponding specID
    specID = newMap.specID(ismember(newMap.specName, metList));
    index = find(ismember(newMap.molID, specID));

    % Change color
    for i = index'
        newMap.molColor{i} = colors(color);
    end

end
