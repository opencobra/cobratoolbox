function newmap = colorSubsystemCD(map, model, subsystem, color, width)

% Color and increase width of every reaction in a specific subsystem
%
% USAGE:
%
%   newmap = colorSubsystemCD(map, model, subsystem, color, width);
%
% INPUTS:
%
%   map:            File from CD parsed to matlab format
%
%   model:          COBRA model structure
%
%   subsystem:      Name of a subsystem as a String
%
% OPTIONAL INPUTS:
%
%   color:          Color desired for reactions in CAPITALS
%
%   width:          Width desired for reactions
%
% OUTPUT:
%
%   newmap          Matlab structure of map with reaction modifications
%
% A.Danielsdottir 17/07/2017 LCSB. Belval. Luxembourg
% N.Sompairac - Institut Curie, Paris, 11/10/2017.

    if nargin<5
        width = 8; 
    end
    if nargin<4
       color = 'RED';
    end

    newmap = map;
    rxnList = model.rxns(ismember(model.subSystems,subsystem));
    Colors = createColorsMap;

    index = find(ismember(newmap.rxnName,rxnList));
    for j = index'
        newmap.rxnColor{j,1} = Colors(color);
        newmap.rxnWidth{j,1} = width;
    end
    
    % Use the existence of reactant lines to check if the map has the
    % complete structure, and if so change also secondary lines.
    if any(strcmp('rxnReactantLineColor',fieldnames(newmap))) == 1
        for j = index'
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