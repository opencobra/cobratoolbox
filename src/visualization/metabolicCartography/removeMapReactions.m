function [xmlStructOut,mapOut,rxnNotInMap] = removeMapReactions(xmlStruct,map,rxnRemoveList,printLevel)
%removes a list of reactions from a cell designer map, also removes
%correspinding species and species aliases if necessary
%
% INPUT
%   xmlStruct:      Structure obtained from the "xml2struct" function.
%                   To be kept for the conversion back to an XML file
%                   of the structure.
%
%   map:            Matlab structure of the map containing all the
%                   relevant fields usable for checking and correction.
%
%   rxnRemoveList:  Cell array of reaction abbreviation to be removed
%
%   printLevel:     {0,(1)}
%
% OUTPUT
%   xmlStructOut:   Structure for the conversion back to an XML file
%                   of the structure.
%
%   mapOut:         Matlab structure of the smaller map containing all the
%                   relevant fields usable for checking and correction.
%
% rxnNotInMap: boolean vector the length of rxnRemoveList
%                        indicating reactions that could not be found in the map
%
% Ronan Fleming 2020

if ~exist('printLevel','var')
    printLevel = 1;
end

[mapRxnsToRemove,LOCB]=ismember(map.rxnName,rxnRemoveList);

rxnNotInMap=~ismember((1:length(rxnRemoveList))',LOCB);
if any(rxnNotInMap)
    if printLevel>0
        ind = find(rxnNotInMap);
        for i=1:length(ind)
            fprintf('%s%s\n',rxnRemoveList{ind(i)}, ' not present in the map')
        end
    end
end

% model = removeFieldEntriesForType(model, indicesToRemove, type, fieldSize, varargin)
% Remove field entries at the specified indices from all fields associated
% with the given type
% USAGE:
%    model = removeFieldEntriesForType(model, indicesToRemove, type, varargin)
%
% INPUTS:
%    model:              the model to update
%    indicesToRemove:    indices which should be removed (either a logical array or double indices)
%    type:               the Type of field to update. one of
%                        ('rxns','mets','comps','genes')
%    fieldSize:          The size of the original field before
%                        modification. This is necessary to identify fields
%                        from which entries have to be removed.
%
% OPTIONAL INPUTS:
%    varargin:           Additional Options as 'ParameterName', Value pairs. Options are:
%                         - 'excludeFields', fields which should not be
%                           adjusted but kept how they are.
%
% OUTPUT:
%    modelNew:           the model in which all fields associated with the
%                        given type have the entries indicated removed. The
%                        initial check is for the size of the field, if
%                        multiple base fields have the same size, it is
%                        assumed, that fields named e.g. rxnXYZ are
%                        associated with rxns, and only those fields are
%                        adapted along with fields which are specified in the
%                        Model FieldDefinitions.


% Matrices			
% map.sID	s x r	logical	Logical matrix with rows = speciesID and columns = reactionsID
% map.sAlias	m x r	logical	Logical matrix with rows = speciesAlias and columns = reactionsID
% map.idAlias	s x m	logical	Logical matrix widh rows = speciesID and columns = speciesAlias
[s,r]= size(map.sID);
[m,r2]=size(map.sAlias);
[s2,m2]=size(map.idAlias);


%                * sID -  Stoichiometric matrix with `rows = MetabolitesID` and
%                  `columns = ReactionsID` in the same order as in the map
%                  structure. Contains `-1` if the metabolite is a
%                  reactant/substract, `+1` if the metabolite is a product
%                  and `0` if it does not participate in the reaction.
mapSpeciesToRemove = getCorrespondingRows(map.sID, true(s,1), mapRxnsToRemove, 'exclusive');

%                * sAlias - Stoichiometric matrix with `rows = MetabolitesAlias` and
%                  `columns = ReactionsID` in the same order as in the map
%                  structure. Contains `-1` if the metabolite is a
%                  reactant/substract, `+1` if the metabolite is a product
%                  and `0` if it does not participate in the reaction.
mapMolsToRemove1 = getCorrespondingRows(map.sAlias, true(m,1), mapRxnsToRemove, 'exclusive');

%                * idAlias - Logical matrix with `rows = MetabolitesID` and
%                  `columns = MetabolitesAlias`. Contains `+1` if the
%                  `MetaboliteID` match with the `MetaboliteAlias` and `0`
%                  if it doesn't.
mapMolsToRemove2 = getCorrespondingCols(map.idAlias, mapSpeciesToRemove, true(m,1), 'inclusive');

%remove the species alias if it was exclusively involved in a reaction that
%was removed or if the species was removed
mapMolsToRemove = mapMolsToRemove1 | mapMolsToRemove2;

type = 'rxnName';
fieldSize = length(map.rxnName);
mapOut = removeFieldEntriesForType(map, mapRxnsToRemove, type, fieldSize);

if any(mapSpeciesToRemove)
    type = 'specName';
    fieldSize = length(mapOut.specName);
    mapOut = removeFieldEntriesForType(mapOut, mapSpeciesToRemove, type, fieldSize);
end

if any(mapMolsToRemove)
    type = 'molAlias';
    fieldSize = length(mapOut.molAlias);
    mapOut = removeFieldEntriesForType(mapOut, mapMolsToRemove, type, fieldSize);
end





mapOut = rmfield(mapOut,'sID');
mapOut = rmfield(mapOut,'sAlias');
mapOut = rmfield(mapOut,'idAlias');

%regenerate map matrices
[mapOut] = getMapMatrices(mapOut);

xmlStructOut= xmlStruct;

%remove reactions
xmlStructOut.sbml.model.listOfReactions.reaction = xmlStructOut.sbml.model.listOfReactions.reaction(~mapRxnsToRemove);

%remove species
xmlStructOut.sbml.model.listOfSpecies.species = xmlStructOut.sbml.model.listOfSpecies.species(~mapSpeciesToRemove);

%remove species alias
           %.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias
xmlStructOut.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias =...
    xmlStructOut.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias(~mapMolsToRemove);

end

