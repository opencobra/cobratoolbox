function [map2] = unifyMetabolicMapCD(map)
% Unify colours in a metabolic map as a standard. Reactions will be grey
% and metabolites will be white.
%
% USAGE:
%
%    [map2] = unifyMetabolicMapCD(map)
%
% INPUT:
%    map:       MATLAB structure of a CellDesigner map (see `transformXML2Map`).
%               Fields used:
%
%                 * .rxnName - reaction names; length sets the reaction loop bound
%                 * .molColor - molecule colours; length sets the molecule loop bound
%
% OUTPUT:
%    map2:      `map` with every `.rxnColor` set to `'FFDCDCDC'` (grey), every
%               `.rxnWidth` set to `1`, and every `.molColor` set to `'FFFFFFFF'`
%               (white)
%
% .. Authors: - J.Modamio LCSB, Belval, Luxembourg. 19.08.2017

    map2 = map;

    for i = 1:length(map2.rxnName)
        map2.rxnColor{i, 1} = 'FFDCDCDC';
        map2.rxnWidth{i, 1} = 1;
    end
    for j = 1:length(map2.molColor)
        map2.molColor{j, 1} = 'FFFFFFFF';
    end

end
