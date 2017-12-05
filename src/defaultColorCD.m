function newmap = defaultColorCD(map)

% Change all reaction lines to black and default width
%
% USAGE:
%
%   newmap = defaultColorCD(map);
%
% INPUTS:
%
%   map:        file from CD parsed to matlab format
%
% OUTPUT:
%
%   newmap:     Matlab structure of map with all rxn lines as default
%               color and width
%
% A.Danielsdottir 17/07/2017 LCSB. Belval. Luxembourg
% N.Sompairac - Institut Curie, Paris, 17/07/2017.

    newmap = map;
    color = 'ff000000';
    width = 1.0;

    for j = 1:length(newmap.rxnName)
        newmap.rxnColor{j,1} = color;
        newmap.rxnWidth{j,1} = width;
    end
    % Use the existence of reactant lines to check if the map has the
    % complete structure, and if so change also secondary lines.
    for j = 1:length(newmap.rxnName)
        if any(strcmp('rxnReactantLineColor',fieldnames(newmap))) == 1
            if ~isempty(newmap.rxnReactantLineColor{j})
                for k = 1:length(newmap.rxnReactantLineColor{j})
                    newmap.rxnReactantLineColor{j,1}{k,1} = Colors(color);
                    newmap.rxnReactantLineWidth{j,1}{k,1} = width;
                end
            end
            if ~isempty(newmap.rxnProductLineColor{j})
                for m = 1:1:length(newmap.rxnProductLineColor{j})
                    newmap.rxnProductLineColor{j,1}{m,1} = Colors(color);
                    newmap.rxnProductLineWidth{j,1}{m,1} = width;   
                end
            end
        end
    end
    
end