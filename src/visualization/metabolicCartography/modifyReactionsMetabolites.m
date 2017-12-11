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
%                   function "transformXML2Map".
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

    colors = createColorsMap;  % Create a Color map with corresponding colors names and their HTML code

    mapStruct = map;

    % Get the indexes of the needed reactions to color
    rxnIndexList = find(ismember(mapStruct.rxnName, rxnList));

    % Initialise a list that will contain aliases of molecules implicated in
    % all the needed reactions
    rxnAliasList = {};

    % Loop over reactions and change the corresponding values
    for rxn = rxnIndexList'

        % Change de color of the reaction
        mapStruct.rxnColor{rxn} = colors(newColor);

        % Change de areaWidth of the reaction
        mapStruct.rxnWidth{rxn} = newAreaWidth;

        % Get the list of aliases involved in this reaction
        % Loop over base reactants
        for x = 1:length(mapStruct.rxnBaseReactantID{rxn})
            rxnAliasList = [rxnAliasList, mapStruct.rxnBaseReactantAlias{rxn}{x}];
        end

        % Loop over reactants
        for x = 1:length(mapStruct.rxnReactantID{rxn})
            rxnAliasList = [rxnAliasList, mapStruct.rxnReactantAlias{rxn}{x}];
        end

        % Loop over base products
        for x = 1:length(mapStruct.rxnBaseProductID{rxn})
            rxnAliasList = [rxnAliasList, mapStruct.rxnBaseProductAlias{rxn}{x}];
        end

        % Loop over products
        for x = 1:length(mapStruct.rxnProductID{rxn})
            rxnAliasList = [rxnAliasList, mapStruct.rxnProductAlias{rxn}{x}];
        end
    end

    % Get the indexes of the needed molecules to color
    % Get the corresponding IDs of the species based on their Names
    specIdList = mapStruct.specID(ismember(mapStruct.specName, metList));
    % Get the correspoding Aliases of the molecules based on the species IDs
    mapAliasList = mapStruct.molAlias(ismember(mapStruct.molID, specIdList));
    % Get only the Aliases of the molecules implicated in the needed reactions
    neededAliasList = mapAliasList(ismember(mapAliasList, rxnAliasList));
    % Get the corresponding Indexes of the molecules in the needed reactions
    molIndexList = find(ismember(mapStruct.molAlias, neededAliasList));

    % Loop over molecules and change the color
    for x = molIndexList'
        mapStruct.molColor{x} = colors(newColor);
    end

end
