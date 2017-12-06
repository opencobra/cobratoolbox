function [mapStruct] = modifyReactionsMetabolites(map, rxnList, metList, newColor, newAreaWidth)
% Modifies the color and areaWidth of reactions from a given list as input
% and the color of the corresponding metabolites from a given list as
% input. The colors and areaWidth are given as inputs and only metabolites
% present in the given reactions list will be colored.
%
% USAGE:
%
%   [mapStruct] = modifyReactionsMetabolites(map, rxnList, metList, newColor, newAreaWidth)
%
% INPUTS:
%   map:            Matlab structure of the map obtained from the
%                   function "transformXML2MatStruct".
%   rxnList:        List of reaction names as a string array
%   metList:        List of metabolite names as a string array
%   newColor:       Color chosen for reaction lines and metabolites
%                   given as a string with the corresponding real name.
%                   Possible names can be found in the function
%                   "createColorsMap.m".
%   newAreaWidth:   Width size for the reaction lines. Can be given as
%                   a string or a double.
%
% OUTPUT:
%   mapStruct:      Updated map structure with the changed areaWidth and
%                   color of the reactions and their corresponding
%                   metabolites.
%                   
% .. Author: - N.Sompairac - Institut Curie, Paris, 25/07/2017 

    % Create a Color map with corresponding colors names and their HTML code
    Colors = createColorsMap;
    
    mapStruct = map;

    % Get the indexes of the needed reactions to color
    rxn_index_list = find(ismember(mapStruct.rxnName, rxnList));

    % Initialise a list that will contain aliases of molecules implicated in
    % all the needed reactions
    reaction_alias_list = {};

    % Loop over reactions and change the corresponding values
    for rxn = rxn_index_list'

        % Change de color of the reaction
        mapStruct.rxnColor{rxn} = Colors(newColor);

        % Change de areaWidth of the reaction
        mapStruct.rxnWidth{rxn} = newAreaWidth;

        % Get the list of aliases involved in this reaction
        % Loop over base reactants
        for x = 1:length(mapStruct.rxnBaseReactantID{rxn})
            reaction_alias_list = [reaction_alias_list, mapStruct.rxnBaseReactantAlias{rxn}{x}];
        end

        % Loop over reactants
        for x = 1:length(mapStruct.rxnReactantID{rxn})
            reaction_alias_list = [reaction_alias_list, mapStruct.rxnReactantAlias{rxn}{x}];
        end

        % Loop over base products
        for x = 1:length(mapStruct.rxnBaseProductID{rxn})
            reaction_alias_list = [reaction_alias_list, mapStruct.rxnBaseProductAlias{rxn}{x}];
        end

        % Loop over products
        for x = 1:length(mapStruct.rxnProductID{rxn})
            reaction_alias_list = [reaction_alias_list, mapStruct.rxnProductAlias{rxn}{x}];
        end
    end

    % Get the indexes of the needed molecules to color
    % Get the corresponding IDs of the species based on their Names
    spec_id_list = mapStruct.specID(ismember(mapStruct.specName, metList));
    % Get the correspoding Aliases of the molecules based on the species IDs
    map_alias_list = mapStruct.molAlias(ismember(mapStruct.molID, spec_id_list));
    % Get only the Aliases of the molecules implicated in the needed reactions
    needed_alias_list = map_alias_list(ismember(map_alias_list, reaction_alias_list));
    % Get the corresponding Indexes of the molecules in the needed reactions
    mol_index_list = find(ismember(mapStruct.molAlias, needed_alias_list));

    % Loop over molecules and change the color
    for x = mol_index_list'
        mapStruct.molColor{x} = Colors(newColor);
    end
    
end