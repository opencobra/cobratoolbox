function [newMap] = colorProtein(map, protList, color)
% Color protein nodes base on a list of protein Names
%
% USAGE:
%
%   [newMap] = colorProtein(map, protList, color)
%
% INPUTS:
%   map:        xml file parsed to Matlab using the function
%               'transformFullXML2Map'
%   protList:   List of protein names
%
% OPTIONAL INPUT:
%   color:      Color for the proteins in CAPITALS
%
% OUTPUT:
%   newMap:     Map with proteins nodes coloured (default: 'RED')
%
% .. Authors:
%       - J.modamio  LCSB, Belval, Luxembourg, 10.08/2017
%       - N.Sompairac - Institut Curie, Paris, 11/10/2017. (Code checking)

    if nargin < 3
        color = 'Red';
    end

    newMap = map;
    colors = createColorsMap;

    id = find(ismember(newMap.specName, protList));
    ID = newMap.specMetaID(id, 1);
    id2 = find(ismember(newMap.specIncName, protList));
    ID2 = newMap.specIncID(id2, 1);
    general = [ID; ID2];

    for i = 1:length(general)
        IDmane = general(i);
        id3 = find(ismember(newMap.molID, IDmane));
        for j = 1:length(id3)
            ID4 = id3(j);
            newMap.molColor{ID4, 1} = colors(color);
        end
    end

end
