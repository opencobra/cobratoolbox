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

rebase=0;

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
%mapRxnsToRemove = getCorrespondingCols(map.sID, mapSpecToRemove, true(r,1), 'inclusive');

specIDToRemove = map.specID(mapSpecToRemove);
molIDToRemove = map.molAlias(mapMolsToRemove);

mapTest=map;
if any(mapSpecToRemove)
    type = 'specName';
    fieldSize = length(mapTest.specName);
    mapTest = removeFieldEntriesForType(mapTest, mapSpecToRemove, type, fieldSize);
end

if any(mapMolsToRemove)
    type = 'molAlias';
    fieldSize = length(mapTest.molAlias);
    mapTest = removeFieldEntriesForType(mapTest, mapMolsToRemove, type, fieldSize);
end

specIDToRetain={};
molIDToRetain={};
% Loop over reactions to fill the matrix
for rxn = 1:length(map.rxnID)
    substrateInd = find(mapTest.sID(:,rxn)<0);
    productInd   = find(mapTest.sID(:,rxn)>0);
    
    substrateAliasInd = find(mapTest.sAlias(:,rxn)<0);
    productAliasInd   = find(mapTest.sAlias(:,rxn)>0);
    
    if any(strcmp(map.rxnBaseReactantID{rxn}{1},specIDToRemove))
        if isempty(substrateInd)
            specIDToRetain{end+1,1} = map.rxnBaseReactantID{rxn}{1};
        else
            if rebase
                %base reactant deleted so replace with first substrate
                map.rxnBaseReactantID{rxn}{1} = mapTest.specID{substrateInd(1)};
                map.rxnReactantID{rxn}={};
                for i=2:length(substrateInd)
                    map.rxnReactantID{rxn}{i-1}= mapTest.specID{substrateInd(i)};
                end
            else
                specIDToRetain{end+1,1} = map.rxnBaseReactantID{rxn}{1};
            end
        end
        specIDToRemove=setdiff(specIDToRemove,specIDToRetain);
    else
        %base reactant invariant
        map.rxnReactantID{rxn} = setdiff(mapTest.specID(substrateInd),map.rxnBaseReactantID{rxn}{1});
    end
    if isempty(map.rxnReactantID{rxn})
        map.rxnReactantID{rxn}=[];
    else
        if any(ismember(map.rxnReactantID{rxn},specIDToRemove))
            warning('removed species still present')
        end
    end
    if isempty(map.rxnBaseReactantID{rxn})
        warning('Cannot leave a reaction without a base product')
    else
        if any(ismember(map.rxnBaseReactantID{rxn},specIDToRemove))
            warning('removed species still present')
        end
    end
        
    if any(strcmp(map.rxnBaseReactantAlias{rxn}{1},molIDToRemove))
        if isempty(substrateAliasInd)
            molIDToRetain{end+1,1} = map.rxnBaseReactantAlias{rxn}{1};
        else
            if rebase
                %base reactant deleted so replace with first substrate
                map.rxnBaseReactantAlias{rxn}{1} = mapTest.molAlias{substrateAliasInd(1)};
                map.rxnReactantAlias{rxn}={};
                for i=2:length(substrateAliasInd)
                    map.rxnReactantAlias{rxn}{i-1}= mapTest.molAlias{substrateAliasInd(i)};
                end
            else
                molIDToRetain{end+1,1} = map.rxnBaseReactantAlias{rxn}{1};
            end
        end
        molIDToRemove = setdiff(molIDToRemove,molIDToRetain);
    else
        %base reactant invariant
        map.rxnReactantAlias{rxn} = setdiff(mapTest.molAlias(substrateAliasInd),map.rxnBaseReactantAlias{rxn}{1});
    end
    if isempty(map.rxnReactantAlias{rxn})
        map.rxnReactantAlias{rxn}=[];
    else
        if any(ismember(map.rxnReactantAlias{rxn},molIDToRemove))
            warning('removed species still present')
        end
    end
    
    if any(ismember(map.rxnBaseReactantAlias{rxn},molIDToRemove))
        warning('removed species still present')
    end

    if isempty(map.rxnBaseReactantAlias{rxn})
        warning('Cannot leave a reaction without a base product')
    end
    
    bool = [isempty(map.rxnReactantAlias{rxn}), isempty(map.rxnReactantID{rxn})];
    if nnz(bool)==1
        warning('Inconsistent ID and Alias')
    end
    
    if any(strcmp(map.rxnBaseProductID{rxn}{1},specIDToRemove))
        if isempty(productInd)
            specIDToRetain{end+1,1} = map.rxnBaseProductID{rxn}{1};
        else
            if rebase
                %base reactant deleted so replace with first substrate
                map.rxnBaseProductID{rxn}{1} = mapTest.specID{productInd(1)};
                map.rxnProductID{rxn}={};
                for i=2:length(productInd)
                    if iscell(map.rxnProductID{rxn})
                        map.rxnProductID{rxn}{i-1}= mapTest.specID{productInd(i)};
                    else
                        map.rxnProductID{rxn} =  mapTest.specID(productInd(2:end));
                    end
                end
            else
                specIDToRetain{end+1,1} = map.rxnBaseProductID{rxn}{1};
            end
        end
        specIDToRemove=setdiff(specIDToRemove,specIDToRetain);
    else
        %base product invariant
        map.rxnProductID{rxn} = setdiff(mapTest.specID(productInd),map.rxnBaseProductID{rxn}{1});
    end
    if isempty(map.rxnProductID{rxn})
        map.rxnProductID{rxn}=[];
    else
        if any(ismember(map.rxnProductID{rxn},specIDToRemove))
            warning('removed species still present')
        end
    end
    
    if isempty(map.rxnBaseProductID{rxn})
        warning('Cannot leave a reaction without a base product')
    end
    
    if any(ismember(map.rxnBaseProductID{rxn},specIDToRemove))
        warning('removed species still present')
    end
    
    if any(strcmp(map.rxnBaseProductAlias{rxn}{1},molIDToRemove))
        if isempty(productAliasInd)
            molIDToRetain{end+1,1} = map.rxnBaseProductAlias{rxn}{1};
        else
            if rebase
                %base product deleted so replace with first substrate
                map.rxnBaseProductAlias{rxn}{1} = mapTest.molAlias{productAliasInd(1)};
                map.rxnProductAlias{rxn}={};
                for i=2:length(productAliasInd)
                    if iscell(map.rxnProductAlias{rxn})
                        map.rxnProductAlias{rxn}{i-1}= mapTest.molAlias{productAliasInd(i)};
                    else
                        map.rxnProductAlias{rxn} =  mapTest.molAlias(productAliasInd(2:end));
                    end
                end
            else
                molIDToRetain{end+1,1} = map.rxnBaseProductAlias{rxn}{1};
            end
        end
        molIDToRemove = setdiff(molIDToRemove,molIDToRetain);
    else
        %base product invariant
        map.rxnProductAlias{rxn} = setdiff(mapTest.molAlias(productAliasInd),map.rxnBaseProductAlias{rxn}{1});
    end
    bool = [isempty(map.rxnProductAlias{rxn}), isempty(map.rxnProductID{rxn})];
    if nnz(bool)==1
        warning('Inconsistent ID and Alias')
    end
    if isempty(map.rxnBaseProductAlias{rxn})
        warning('Cannot leave a reaction without a base product alias')
    else
        if any(ismember(map.rxnProductAlias{rxn},molIDToRemove))
            warning('removed species still present')
        end
    end
    
    if any(ismember(map.rxnBaseProductAlias{rxn},molIDToRemove))
        warning('removed species still present')
    end
    
end

mapSpecToRemove = mapSpecToRemove & ~ismember(map.specID,specIDToRetain);

if any(mapSpecToRemove)
    type = 'specName';
    fieldSize = length(map.specName);
    map = removeFieldEntriesForType(map, mapSpecToRemove, type, fieldSize);
end

mapMolsToRemove = mapMolsToRemove & ~ismember(map.molAlias,molIDToRetain);

if any(mapMolsToRemove)
    type = 'molAlias';
    fieldSize = length(map.molAlias);
    map = removeFieldEntriesForType(map, mapMolsToRemove, type, fieldSize);
end

if 0
    mapOut = rmfield(mapOut,'sID');
    mapOut = rmfield(mapOut,'sAlias');
    mapOut = rmfield(mapOut,'idAlias');
    
    %regenerate map matrices
    [mapOut] = getMapMatrices(mapOut);
end

%remove reactions
%xmlStruct.sbml.model.listOfReactions.reaction = xmlStruct.sbml.model.listOfReactions.reaction(~mapRxnsToRemove);

%remove species
xmlStruct.sbml.model.listOfSpecies.species = xmlStruct.sbml.model.listOfSpecies.species(~mapSpecToRemove);

%remove species alias
%.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias
xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias =...
    xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias(~mapMolsToRemove);

end

