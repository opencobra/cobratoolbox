function map = ChangeMetColor(map,metList,color)

    % Change color of every metabolite froma list of Names
    %
    % USAGE:
    %
    %   new_map = ChangeMetColor(map,metList,color);
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

    Colors = Create_colors_map;
    %index for specName is the same as for corresponding specID
    spec_ID = map.specID(ismember(map.specName,metList));
    index = find(ismember(map.molID,spec_ID));

    %change color
    for i = index'

       map.molColor{i} = Colors(color); 

    end
    %use the existence of reactant lines in structure to check if the map has the
    %complete structure or not.
    % if any(strcmp('rxnReactantLineColor',fieldnames(newmap))) == 1
    %     %if complete, check also included species for mets in the metList
    %     specInc_ID = newmap.specIncID(ismember(newmap.specIncName,metList));
    %     IncIndex = find(ismember(newmap.molID,specInc_ID));
    %     
    %     for j = IncIndex'
    %         
    %         newmap.molColor{j} = Colors(color);
    %         
    %     end
    % 
    % end

end 

