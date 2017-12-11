function [map2] = unifyMetabolicPPImapCD(map)
% Unify a metabolic and protein-protein interaction map as a standard.
% Reaction will be grey and Metabolites/Complexes will be White.
%
% USAGE:
%
%   [map2] = unifyMetabolicPPImapCD(map)
%
% INPUT:
%   map:    MATLAB structure of CellDesigner map
%
% OUTPUT:
%   map2:   Map with grey reactions colour, width 1 and white nodes colour.
%           Change colour complex to white
%
% .. Authors:
%       - J.Modamio LCSB, Belval, Luxembourg. 19.08.2017 LCSB. Belval. Luxembourg
%       - N.Sompairac - Institut Curie, Paris, 20/10/2017

    map2 = map;

    % Change reaction colour to ligth grey and and width to 1.0
    for i = 1:length(map2.rxnName)
        map2.rxnColor{i, 1} = 'FFDCDCDC';
        map2.rxnWidth{i, 1} = 1;
    end
    % Change molecules color to white
    for j = 1:length(map2.molColor)
        map2.molColor{j, 1} = 'FFFFFFFF';
    end
    % Change complex colour to white
    for c = 1:length(map2.complexColor)
        map2.complexColor{c, 1} = 'FFFFFFFF';
    end

    % Change reactions secondary links to light grey (products)
    % and width to 1
    index = find(~cellfun(@isempty, map2.rxnProductLineColor));
    for t = 1:length(index)
        if length(map2.rxnProductLineColor{t, 1}) > 1
            for d = 1:length(map2.rxnProductLineColor{t, 1})
                map2.rxnProductLineColor{t, 1}{d, 1} = 'FFDCDCDC';
                map2.rxnProductLineWidth{t, 1}{d, 1} = 1;
            end
        elseif length(map2.rxnProductLineColor{t, 1}) == 1
            map2.rxnProductLineColor{t, 1}{1, 1} = 'FFDCDCDC';
            map2.rxnProductLineWidth{t, 1}{1, 1} = 1;
        end
    end
    clear id index

    % Change reactions secondary links to light grey (reactants)
    % and width to 1
    index = find(~cellfun(@isempty, map2.rxnReactantLineColor));
    for r = 1:length(index)
        if length(map2.rxnReactantLineColor{r, 1}) > 1
            for p = 1:length(map2.rxnReactantLineColor{r, 1})
                map2.rxnReactantLineColor{r, 1}{p, 1} = 'FFDCDCDC';
                map2.rxnReactantLineWidth{r, 1}{p, 1} = 1;
            end
        elseif length(map2.rxnReactantLineColor{r, 1}) == 1
            map2.rxnReactantLineColor{r, 1}{1, 1} = 'FFDCDCDC';
            map2.rxnReactantLineWidth{r, 1}{1, 1} = 1;
        end
    end
    clear id index

end
