function [xmlStructOut, mapOut, specNotInMap] = removeMapSpecies(xmlStruct, map, specRemoveList, specRemoveType, printLevel)
% Removes a list of species from a CellDesigner map, also removing the
% corresponding species aliases and reactions
%
% USAGE:
%
%    [xmlStructOut, mapOut, specNotInMap] = removeMapSpecies(xmlStruct, map, specRemoveList, specRemoveType, printLevel)
%
% INPUTS:
%    xmlStruct:         Structure obtained from the `xml2struct` function (see
%                       `transformXML2Map`), kept for the conversion back to an
%                       XML file of the structure
%    map:               MATLAB structure of the map (see `transformXML2Map`)
%                       containing all the relevant fields usable for checking
%                       and correction. Fields used:
%
%                         * .specName - species names, matched against `specRemoveList`
%                         * .specType - species types, matched against `specRemoveType`
%                         * .sID - stoichiometric matrix (`specID` x `rxnID`), used to
%                           find the reactions of the removed species
%                         * .sAlias - stoichiometric matrix (`molAlias` x `rxnID`), used
%                           to find the molecule aliases of the removed reactions
%                         * .idAlias - logical matrix (`specID` x `molAlias`), used to
%                           find the molecule aliases of the removed species
%                         * .rxnName - reaction names, used to size the reaction-removal pass
%    specRemoveList:    Cell array of species abbreviations to be removed (a
%                       single char is wrapped into a 1x1 cell array)
%
% OPTIONAL INPUTS:
%    specRemoveType:    Species type; if provided, species of this `map.specType`
%                       are also marked for removal in addition to `specRemoveList`
%    printLevel:        Verbosity level: `0` = silent, `1` (default) = print species
%                       from `specRemoveList` that could not be found in the map
%
% OUTPUTS:
%    xmlStructOut:      `xmlStruct` with the removed reactions, species, and species
%                       aliases stripped from `.sbml.model.listOfReactions.reaction`,
%                       `.sbml.model.listOfSpecies.species`, and the CellDesigner
%                       species-alias list nested under `.sbml.model.annotation...`
%    mapOut:            `map` with the entries of the removed reactions, species, and
%                       molecule aliases stripped from every associated field
%    specNotInMap:      Boolean vector the length of `specRemoveList` indicating
%                       species that could not be found in the map
%
% .. Author: - Ronan Fleming, 2020

if ~exist('printLevel','var')
    printLevel = 1;
end

if isempty(specRemoveList)
    specRemoveList = {};
end

if ischar(specRemoveList)
    aChar = specRemoveList;
    clear specRemoveList
    specRemoveList{1}=aChar;
end

[mapSpecToRemove,LOCB]=ismember(map.specName,specRemoveList);

specNotInMap=~ismember((1:length(specRemoveList))',LOCB);
if any(specNotInMap)
    if printLevel>0
        ind = find(specNotInMap);
        for i=1:length(ind)
            fprintf('%s%s\n',specRemoveList{ind(i)}, ' not present in the map')
        end
    end
end

if exist('specRemoveType','var')
    mapSpecToRemove2 = strcmp(specRemoveType,map.specType);
    mapSpecToRemove = mapSpecToRemove | mapSpecToRemove2;
end

% Matrices			
% | `map.sID`     | `s x r` | logical | Stoichiometric matrix with rows = specID and columns = rxnID. In the same order as in the map structure. Contains `-1` if the molecule alias is a substrate, `+1` if the molecule alias is a product |
% | `map.sAlias`  | `a x r` | logical | Stoichiometric matrix with rows = molAlias and columns = rxnID. In the same order as in the map structure. Contains `-1` if the metabolite is a substrate, `+1` if the metabolite is a product |
% | `map.idAlias` | `s x a` | logical | Logical matrix with rows = speciesID and columns = speciesAlias. Contains `+1` if the map.speciesID match with the map.molID and `0` otherwise. |

[s,r]= size(map.sID);
[a,r2]=size(map.sAlias);
[s2,m2]=size(map.idAlias);

% map.idAlias	s x a	rows = speciesID and columns = speciesAlias
mapMolsToRemove = getCorrespondingCols(map.idAlias, mapSpecToRemove, true(a,1), 'inclusive');

% | `map.sID` | `s x r` | logical | Stoichiometric matrix with rows = specID and columns = rxnID. In the same order as in the map structure. Contains `-1` if the molecule alias is a substrate, `+1` if the molecule alias is a product |
mapRxnsToRemove = getCorrespondingCols(map.sID, mapSpecToRemove, true(r,1), 'inclusive');

% map.idAlias	s x a	rows = speciesID and columns = speciesAlias
mapMolsToRemove2 = getCorrespondingRows(map.sAlias, true(a,1), mapRxnsToRemove, 'exclusive');

mapMolsToRemove = mapMolsToRemove | mapMolsToRemove2;

type = 'rxnName';
fieldSize = length(map.rxnName);
mapOut = removeFieldEntriesForType(map, mapRxnsToRemove, type, fieldSize);


if any(mapSpecToRemove)
    type = 'specName';
    fieldSize = length(mapOut.specName);
    mapOut = removeFieldEntriesForType(mapOut, mapSpecToRemove, type, fieldSize);
end

if any(mapMolsToRemove)
    type = 'molAlias';
    fieldSize = length(mapOut.molAlias);
    mapOut = removeFieldEntriesForType(mapOut, mapMolsToRemove, type, fieldSize);
end

% specIDToRemove = map.specID(mapSpecToRemove);
% molIDToRemove = map.molAlias(mapMolsToRemove);
% % Loop over reactions to fill the matrix
% for rxn = 1:length(map.rxnID)
%     substrateInd = find(map.sID(:,rxn)<0);
%     productInd   = find(map.sID(:,rxn)>0);
%     
%     substrateAliasInd = find(map.sAlias(:,rxn)<0);
%     productAliasInd   = find(map.sAlias(:,rxn)>0);
%     
%     if any(strcmp(map.rxnBaseReactantID{rxn},specIDToRemove))
%         %base reactant deleted so replace with first substrate
%         map.rxnBaseReactantID{rxn}{1} = map.specID{substrateInd(1)};
%         for i=2:length(substrateInd)
%             map.rxnReactantID{rxn}{i-1}= map.specID{substrateInd(i)};
%         end
%     else
%         %secondary reactant deleted, so base reactant invariant
%         for i=1:length(substrateInd)
%             if ~strcmp(map.rxnBaseReactantID{rxn}{1},map.specID{substrateInd(i)})
%                 map.rxnReactantID{rxn}{i}= map.specID{substrateInd(i)};
%             end
%         end
%     end
%     
%     if any(strcmp(map.rxnBaseReactantAlias{rxn},molIDToRemove))
%         %base reactant deleted so replace with first substrate
%         map.rxnBaseReactantAlias{rxn}{1} = map.specID{substrateAliasInd(1)};
%         for i=2:length(substrateAliasInd)
%             map.rxnReactantAlias{rxn}{i-1}= map.specID{substrateAliasInd(i)};
%         end
%     else
%         %secondary reactant deleted, so base reactant invariant
%         for i=1:length(substrateAliasInd)
%             if ~strcmp(map.rxnBaseReactantAlias{rxn}{1},map.specID{substrateAliasInd(i)})
%                 map.rxnReactantAlias{rxn}{i}= map.specID{substrateAliasInd(i)};
%             end
%         end
%     end
%         
%     if any(strcmp(map.rxnBaseProductID{rxn},specIDToRemove))
%         %base reactant deleted so replace with first substrate
%         map.rxnBaseProductID{rxn}{1} = map.specID{productInd(1)};
%         for i=2:length(productInd)
%             map.rxnProductID{rxn}{i-1}= map.specID{productInd(i)};
%         end
%     else
%         %secondary reactant deleted, so base reactant invariant
%         for i=1:length(productInd)
%             if ~strcmp(map.rxnBaseProductID{rxn}{1},map.specID{productInd(i)})
%                 map.rxnProductID{rxn}{i}= map.specID{productInd(i)};
%             end
%         end
%     end
%     
%     if any(strcmp(map.rxnBaseProductAlias{rxn},molIDToRemove))
%         %base reactant deleted so replace with first substrate
%         map.rxnBaseProductAlias{rxn}{1} = map.specID{productAliasInd(1)};
%         for i=2:length(productAliasInd)
%             map.rxnReactantAlias{rxn}{i-1}= map.specID{productAliasInd(i)};
%         end
%     else
%         %secondary reactant deleted, so base reactant invariant
%         for i=1:length(productAliasInd)
%             if ~strcmp(map.rxnBaseProductAlias{rxn}{1},map.specID{productAliasInd(i)})
%                 map.rxnProductAlias{rxn}{i}= map.specID{productAliasInd(i)};
%             end
%         end
%     end
% end

if 0
    mapOut = rmfield(mapOut,'sID');
    mapOut = rmfield(mapOut,'sAlias');
    mapOut = rmfield(mapOut,'idAlias');
    
    %regenerate map matrices
    [mapOut] = getMapMatrices(mapOut);
end

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

