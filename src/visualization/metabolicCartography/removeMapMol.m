function [xmlStructOut,map,specNotInMap] = removeMapMol(xmlStruct,map,molRemoveList,printLevel)
%removes a list of molecules (species alias) from a cell designer map, also removes
%corresponding reaction if necessary
%
% INPUT
%   xmlStruct:      Structure obtained from the "xml2struct" function.
%                   To be kept for the conversion back to an XML file
%                   of the structure.
%
%   map:            Matlab structure of the map containing all the
%                   relevant fields usable for checking and correction.
%
%   molRemoveList:  Cell array of molecule abbreviation to be removed
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
% specNotInMap:    boolean vector the length of molRemoveList
%                  indicating species that could not be found in the map
%
% Ronan Fleming 2020

if ~exist('printLevel','var')
    printLevel = 1;
end

if isempty(molRemoveList)
    molRemoveList = {};
end

if ischar(molRemoveList)
    aChar = molRemoveList;
    clear molRemoveList
    molRemoveList{1}=aChar;
end

[mapMolsToRemove,LOCB]=ismember(map.molAlias,molRemoveList);

specNotInMap=~ismember((1:length(molRemoveList))',LOCB);
if any(specNotInMap)
    if printLevel>0
        ind = find(specNotInMap);
        for i=1:length(ind)
            fprintf('%s%s\n',molRemoveList{ind(i)}, ' not present in the map')
        end
    end
end


% Matrices			
% | `map.sID`     | `s x r` | logical | Stoichiometric matrix with rows = specID and columns = rxnID. In the same order as in the map structure. Contains `-1` if the molecule alias is a substrate, `+1` if the molecule alias is a product |
% | `map.sAlias`  | `a x r` | logical | Stoichiometric matrix with rows = molAlias and columns = rxnID. In the same order as in the map structure. Contains `-1` if the metabolite is a substrate, `+1` if the metabolite is a product |
% | `map.idAlias` | `s x a` | logical | Logical matrix with rows = speciesID and columns = speciesAlias. Contains `+1` if the map.speciesID match with the map.molID and `0` otherwise. |

[s,r]= size(map.sID);
[a,r2]=size(map.sAlias);
[s2,m2]=size(map.idAlias);

if 1
    % map.idAlias	s x a	rows = speciesID and columns = speciesAlias
    mapSpecToRemove = getCorrespondingRows(map.idAlias, true(s,1), mapMolsToRemove, 'exclusive');
else
    mapSpecToRemove = false(s,1);
end

if 1
    % | `map.sID` | `s x r` | logical | Stoichiometric matrix with rows = specID and columns = rxnID. In the same order as in the map structure. Contains `-1` if the molecule alias is a substrate, `+1` if the molecule alias is a product |
    mapRxnsToRemove = getCorrespondingCols(map.sID, mapSpecToRemove, true(r,1), 'inclusive');
else
    mapRxnsToRemove = false(r,1);
end

%                * idAlias - Logical matrix with `rows = MetabolitesID` and
%                  `columns = MetabolitesAlias`. Contains `+1` if the
%                  `MetaboliteID` match with the `MetaboliteAlias` and `0`
%                  if it doesn't.
mapMolsToRemove2 = getCorrespondingRows(map.sAlias, true(a,1), mapRxnsToRemove, 'inclusive');

%remove the species alias if it was exclusively involved in a reaction that
%was removed or if the species was removed
mapMolsToRemove = mapMolsToRemove | mapMolsToRemove2;

if any(mapRxnsToRemove)
    type = 'rxnName';
    fieldSize = length(map.rxnName);
    map = removeFieldEntriesForType(map, mapRxnsToRemove, type, fieldSize);
end

if any(mapSpecToRemove)
    type = 'specName';
    fieldSize = length(map.specName);
    map = removeFieldEntriesForType(map, mapSpecToRemove, type, fieldSize);
end

if any(mapMolsToRemove)
    type = 'molAlias';
    fieldSize = length(map.molAlias);
    map = removeFieldEntriesForType(map, mapMolsToRemove, type, fieldSize);
end

map = rmfield(map,'sID');
map = rmfield(map,'sAlias');
map = rmfield(map,'idAlias');

%regenerate map matrices
[map] = getMapMatrices(map);

xmlStructOut= xmlStruct;

%remove reactions
xmlStructOut.sbml.model.listOfReactions.reaction = xmlStructOut.sbml.model.listOfReactions.reaction(~mapRxnsToRemove);

%remove species
xmlStructOut.sbml.model.listOfSpecies.species = xmlStructOut.sbml.model.listOfSpecies.species(~mapSpecToRemove);

%remove species alias
%.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias
xmlStructOut.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias =...
    xmlStructOut.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias(~mapMolsToRemove);

end

