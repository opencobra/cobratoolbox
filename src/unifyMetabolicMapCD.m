function map2 = unifyMetabolicMapCD(map)

% Unify colours in a metabolic map as a standard. Reaction will be Gray
% and Metabolites will be White.
%
% USAGE:
%
%   map2 = unifyMetabolicMapCD(map)
%
% INPUTS:
%
%   map:    MATLAB structure of CD map
%
% OUTPUT:
%
%   map2:   Map with grey reactions colour, width 1 and white nodes colour.
%
% J.Modamio LCSB, Belval, Luxembourg. 19.08.2017
    
    map2 = map;
    
    for i = 1:length(map2.rxnName)   
        map2.rxnColor{i,1} = 'FFDCDCDC';
        map2.rxnWidth{i,1} = 1; 
    end
    for j = 1:length(map2.molColor)
        map2.molColor{j,1} = 'FFFFFFFF';
    end
    
end