function [map_struct] = Modify_reactions_and_metabolites(map, rxn_list, met_list, new_color, new_width)
    
    % Modifies the color and width of reactions from a given list as input
    % and the color of the corresponding metabolites from a given list as
    % input. The colors and width are given as inputs and only metabolites
    % present in the given reactions list will be colored.
    %
    % INPUTS:
    %
    %   map:            Matlab structure of the map obtained from the
    %                   function "Transform_XML_to_Matlab_structure".
    %
    %   rxn_list:       List of reaction names as a string array
    %
    %   met_list:       List of metabolite names as a string array
    %
    %   new_color:      Color chosen for reaction lines and metabolites
    %                   given as a string with the corresponding real name.
    %                   Possible names can be found in the function
    %                   "Create_colors_map.m".
    %
    %   new_width:      Width size for the reaction lines. Can be given as
    %                   a string or a double.
    % 
    % OPTIONAL INPUTS:
    %
    %   No optional inputs.
    %
    % OUTPUTS:
    %
    %   map_struct:     Updated map structure with the changed width and
    %                   color of the reactions and their corresponding
    %                   metabolites.
    %                   
    % .. Author: N.Sompairac - Institut Curie, Paris, 25/07/2017 


    % Create a Color map with corresponding colors names and their HTML code
    Colors = Create_colors_map;

    %rxn_list = {'DESAT18_5', 'DESAT18_3', 'DESAT18_8', 'RE0566C'};
    %met_list = {'h[c]', 'o2[c]', 'nadp[c]'};

    %new_color = 'Red';
    %new_width = 8;

    map_struct = map;

    % Get the indexes of the needed reactions to color
    rxn_index_list = find(ismember(map_struct.rxnName, rxn_list));

    % Initialise a list that will contain aliases of molecules implicated in
    % all the needed reactions
    reaction_alias_list = {};

    %%% Loop over reactions and change the corresponding values
    for rxn = rxn_index_list'

        % Change de color of the reaction
        map_struct.rxnColor{rxn} = Colors(new_color);

        % Change de width of the reaction
        map_struct.rxnWidth{rxn} = new_width;

        %%% Get the list of aliases involved in this reaction
        % Loop over base reactants
        for x = 1:length(map_struct.rxnBaseReactantID{rxn})

            reaction_alias_list = [reaction_alias_list, map_struct.rxnBaseReactantAlias{rxn}{x}];

        end
        clearvars x

        % Loop over reactants
        for x = 1:length(map_struct.rxnReactantID{rxn})

            reaction_alias_list = [reaction_alias_list, map_struct.rxnReactantAlias{rxn}{x}];
        end
        clearvars x

        % Loop over base products
        for x = 1:length(map_struct.rxnBaseProductID{rxn})

            reaction_alias_list = [reaction_alias_list, map_struct.rxnBaseProductAlias{rxn}{x}];

        end
        clearvars x

        % Loop over products
        for x = 1:length(map_struct.rxnProductID{rxn})

            reaction_alias_list = [reaction_alias_list, map_struct.rxnProductAlias{rxn}{x}];

        end
        clearvars x

    end

    %%% Get the indexes of the needed molecules to color
    % Get the corresponding IDs of the species based on their Names
    spec_id_list = map_struct.specID(ismember(map_struct.specName, met_list));
    % Get the correspoding Aliases of the molecules based on the species IDs
    map_alias_list = map_struct.molAlias(ismember(map_struct.molID, spec_id_list));
    % Get only the Aliases of the molecules implicated in the needed reactions
    needed_alias_list = map_alias_list(ismember(map_alias_list, reaction_alias_list));
    % Get the corresponding Indexes of the molecules in the needed reactions
    mol_index_list = find(ismember(map_struct.molAlias, needed_alias_list));

    %%% Loop over molecules and change the color
    for x = mol_index_list'

        map_struct.molColor{x} = Colors(new_color);

    end
end