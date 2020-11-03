function [xmlStruct,map,specNotInMap] = removeMapSpeciesOnly(xmlStruct,map,specRemoveList,specRemoveType,printLevel)
%removes a list of species from a cell designer map, also removes
%corresponding species aliases and but does not remove reactions
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
%   xmlStruct:   Structure for the conversion back to an XML file
%                   of the structure.
%
%   map:         Matlab structure of the smaller map containing all the
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

specIDToRemove = map.specID(mapSpecToRemove);
molIDToRemove = map.molAlias(mapMolsToRemove);
% Loop over reactions to fill the matrix
for rxn = 1:length(map.rxnID)
    substrateInd = find(map.sID(:,rxn)<0);
    productInd   = find(map.sID(:,rxn)>0);
    
    substrateAliasInd = find(map.sAlias(:,rxn)<0);
    productAliasInd   = find(map.sAlias(:,rxn)>0);
    
    if any(strcmp(map.rxnBaseReactantID{rxn}{1},specIDToRemove))
        %base reactant deleted so replace with first substrate
        map.rxnBaseReactantID{rxn}{1} = map.specID{substrateInd(1)};
        for i=2:length(substrateInd)
            map.rxnReactantID{rxn}{i-1}= map.specID{substrateInd(i)};
        end
    else
        %base reactant invariant
        map.rxnReactantID{rxn} = setdiff(map.specID(substrateInd),map.rxnBaseReactantID{rxn}{1});
    end
    if isempty(map.rxnReactantID{rxn})
        map.rxnReactantID{rxn}=[];
    end
    if isempty(map.rxnBaseReactantID{rxn})
        error('Cannot leave a reaction without a base product')
    end
        
    if any(strcmp(map.rxnBaseReactantAlias{rxn}{1},molIDToRemove))
        %base reactant deleted so replace with first substrate
        map.rxnBaseReactantAlias{rxn}{1} = map.molAlias{substrateAliasInd(1)};
        for i=2:length(substrateAliasInd)
            map.rxnReactantAlias{rxn}{i-1}= map.molAlias{substrateAliasInd(i)};
        end
    else
        %base reactant invariant
        map.rxnReactantAlias{rxn} = setdiff(map.molAlias(substrateAliasInd),map.rxnBaseReactantAlias{rxn}{1});
    end
%     if isempty(map.rxnReactantAlias{rxn})
%         map.rxnReactantAlias{rxn}='';
%     end
    if isempty(map.rxnBaseReactantAlias{rxn})
        error('Cannot leave a reaction without a base product')
    end
        bool = [isempty(map.rxnReactantAlias{rxn}), isempty(map.rxnReactantID{rxn})];
        if nnz(bool)==1
            error('Inconsistent ID and Alias')
        end
    
    if any(strcmp(map.rxnBaseProductID{rxn}{1},specIDToRemove))
        %base reactant deleted so replace with first substrate
        map.rxnBaseProductID{rxn}{1} = map.specID{productInd(1)};
        for i=2:length(productInd)
            %map.rxnProductID{rxn}{i-1}= map.specID{productInd(i)};
            if iscell(map.rxnProductID{rxn})
                map.rxnProductID{rxn}{i-1}= map.specID{productInd(i)};
            else
                map.rxnProductID{rxn} =  map.specID(productInd(2:end));   
            end
        end
    else
        %base product invariant
        map.rxnProductID{rxn} = setdiff(map.specID(productInd),map.rxnBaseProductID{rxn}{1});
    end
    if isempty(map.rxnProductID{rxn})
        map.rxnProductID{rxn}=[];
    end
    
    if isempty(map.rxnBaseProductID{rxn})
        error('Cannot leave a reaction without a base product')
    end
    
    if any(strcmp(map.rxnBaseProductAlias{rxn}{1},molIDToRemove))
        %base reactant deleted so replace with first substrate
        map.rxnBaseProductAlias{rxn}{1} = map.molAlias{productAliasInd(1)};
        for i=2:length(productAliasInd)
            if iscell(map.rxnProductAlias{rxn})
                map.rxnProductAlias{rxn}{i-1}= map.molAlias{productAliasInd(i)};
            else
                map.rxnProductAlias{rxn} =  map.molAlias(productAliasInd(2:end));
            end
        end
    else
        %base product invariant
        map.rxnProductAlias{rxn} = setdiff(map.molAlias(productAliasInd),map.rxnBaseProductAlias{rxn}{1});
    end
        bool = [isempty(map.rxnProductAlias{rxn}), isempty(map.rxnProductID{rxn})];
        if nnz(bool)==1
            error('Inconsistent ID and Alias')
        end
    if isempty(map.rxnBaseProductAlias{rxn})
        error('Cannot leave a reaction without a base product alias')
    end
end

if 0
    mapOut = rmfield(mapOut,'sID');
    mapOut = rmfield(mapOut,'sAlias');
    mapOut = rmfield(mapOut,'idAlias');
    
    %regenerate map matrices
    [mapOut] = getMapMatrices(mapOut);
end

%remove reactions
xmlStruct.sbml.model.listOfReactions.reaction = xmlStruct.sbml.model.listOfReactions.reaction(~mapRxnsToRemove);

%remove species
xmlStruct.sbml.model.listOfSpecies.species = xmlStruct.sbml.model.listOfSpecies.species(~mapSpecToRemove);

%remove species alias
%.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias
xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias =...
    xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias(~mapMolsToRemove);

end

