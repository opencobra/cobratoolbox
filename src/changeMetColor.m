function map = changeMetColor(map, metList, color)

% Change color of every metabolite from a list of Names
%
% USAGE:
%
%   new_map = changeMetColor(map, metList, color);
%
% INPUTS:
%
%   map:            file from CD parsed to matlab format
%   metList:        List of metabolites names
% 
% OPTIONAL INPUT:
%
%   color:          New color of metabolites from list(default: RED)
%
% OUTPUT:
%
%   new_map:        Matlab structure of map with reaction modifications
%
% .. Authors:
% A.Danielsdottir 17/07/2017 LCSB. Belval. Luxembourg
% N.Sompairac - Institut Curie, Paris, 17/07/2017.

    if nargin<3
       color = 'RED';
    end

    Colors = createColorsMap;
    % Index for specName is the same as for corresponding specID
    spec_ID = map.specID(ismember(map.specName,metList));
    index = find(ismember(map.molID,spec_ID));

    % Change color
    for i = index'
       map.molColor{i} = Colors(color); 
    end

end 