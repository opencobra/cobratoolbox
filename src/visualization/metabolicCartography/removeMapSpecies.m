function [xmlStructOut,mapOut,specNotInMap] = removeMapSpecies(xmlStruct,map,specRemoveList,specRemoveType,printLevel)
%removes a list of species from a cell designer map, also removes
%corresponding species aliases and reactions
%
% INPUT
%   xmlStruct:      Structure obtained from the "xml2struct" function.
%                   To be kept for the conversion back to an XML file
%                   of the structure.
%
%   map:            Matlab structure of the map containing all the
%                   relevant fields usable for checking and correction.
%
%   specRemoveList:  Cell array of species abbreviation to be removed
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
% specNotInMap:    boolean vector the length of specRemoveList
%                  indicating species that could not be found in the map
%
% Ronan Fleming 2020

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

