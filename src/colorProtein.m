function map = colorProtein(map, protList, color) 

% Color protein nodes base on a list of protein Names
%
% USAGE:
%
%   new_map = colorProtein(map, protList, color)
%
% INPUTS:
%
%   map:        xml file parsed to Matlab using the function
%               'transformFullXML2MatStruct'
%
%   protList:   List of protein names 
%   
% 
% OPTIONAL INPUTS:
%
%   color:      Color for the proteins in CAPITALS
%
% OUTPUTS:
%
%   new_map:     Map with proteins nodes coloured (default: 'RED')
%
% .. Authors:
% .. J.modamio  LCSB, Belval, Luxembourg, 10.08/2017
% .. N.Sompairac - Institut Curie, Paris, 11/10/2017. (Code checking)

    if nargin<3
    color = 'Red';
    end
     
    Colors = createColorsMap;

    id = find(ismember(map.specName,protList));
    ID = map.specMetaID(id,1); 
    id2 = find(ismember(map.specIncName,protList));
    ID2 = map.specIncID(id2,1); 
    general = [ID;ID2];
    
    for i = 1:length(general)
        IDmane = general(i);
        id3 = find(ismember(map.molID,IDmane));
        for j = 1:length(id3) 
            ID4 = id3(j); 
            map.molColor{ID4,1} = Colors(color); 
        end
    end
    
end 