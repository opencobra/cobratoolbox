function map = ChangeRxnColorAndWidth(map,rxnList,color,width)

    % Change color and width of reactions from a list of names
    %
    % USAGE:
    %
    %   new_map = ChangeRxnColorAndWidth(map,rxnList,color,width);
    %
    % INPUTS:
    %
    %   map:            File from CD parsed to matlab format
    %   rxnList:        List of reactions
    % 
    % OPTIONAL INPUT:
    %
    %   color:          New color of reactions from list (default: 'RED')
    %   width:          New width of reactions from list (default: 8)
    %
    % OUTPUT:
    %
    %   new_map:        Matlab structure of map with reaction modifications
    %
    % .. Authors:
    % A.Danielsdottir 17/07/2017 LCSB. Belval. Luxembourg
    % N.Sompairac - Institut Curie, Paris, 17/07/2017.

    if nargin<4

        width = 8;

    end
    if nargin<3

       color = 'RED';

    end

    Colors = Create_colors_map;

    index = find(ismember(map.rxnName,rxnList));
    for j = index'
        
        map.rxnColor{j,1} = Colors(color);

        map.rxnWidth{j,1} = width;
        %use the existence of reactant lines to check if the map has the
        %complete structure.
        if any(strcmp('rxnReactantLineColor',fieldnames(map))) == 1
            
            if ~isempty(map.rxnReactantLineColor{j})
                
                for k = 1:length(map.rxnReactantLineColor{j})
                    
                    map.rxnReactantLineColor{j,1}{k,1} = Colors(color);
                    map.rxnReactantLineWidth{j,1}{k,1} = width;
                    
                end
            end
            
            if ~isempty(map.rxnProductLineColor{j})
                
                for m = 1:1:length(map.rxnProductLineColor{j})
                    
                    map.rxnProductLineColor{j,1}{m,1} = Colors(color);
                    map.rxnProductLineWidth{j,1}{m,1} = width;
                    
                end
            end
        end
    end
    
end
