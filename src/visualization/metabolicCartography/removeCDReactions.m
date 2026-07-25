function removeCDReactions(fileName, rxnRemoveList, printLevel)
% Removes a list of reactions from a CellDesigner map, also removing
% corresponding species and species aliases if necessary. The reduced
% map is written out as a new CellDesigner XML file.
%
% USAGE:
%
%    removeCDReactions(fileName, rxnRemoveList, printLevel)
%
% INPUTS:
%    fileName:          Path to the CellDesigner XML map file to read. The
%                       reduced map is written to a file with the same
%                       name suffixed `_subset.xml`
%    rxnRemoveList:     Cell array of reaction abbreviation to be removed
%
% OPTIONAL INPUTS:
%    printLevel:        {0,(1)}, whether to print a message for each entry
%                       of `rxnRemoveList` not present in the map (default: 1)
%
% .. Author: - Ronan Fleming, 2020

if ~exist('printLevel','var')
    printLevel = 1;
end

if 0
    xmlStruct = xml2struct(fileName);
    
    nMapReactions = length(xmlStruct.sbml.model.listOfReactions.reaction);
    
    mapRxns = cell(nMapReactions,1);
    for i=1:nMapReactions
        mapRxns{i}= xmlStruct.sbml.model.listOfReactions.reaction{i}.annotation.celldesigner_colon_extension.celldesigner_colon_name.Text;
    end

else
    %use the map structure to be able to delete isolated species and
    %species aliases
    [xmlStruct, map] = transformXML2Map(fileName);
    mapRxns = map.rxnName;
end
 

[mapRxnsToRemove,LOCB]=ismember(mapRxns,rxnRemoveList);

rxnNotInMap=~ismember((1:length(rxnRemoveList))',LOCB);
if any(rxnNotInMap)
    if printLevel>0
        ind = find(rxnNotInMap);
        for i=1:length(ind)
            fprintf('%s%s\n',rxnRemoveList{ind(i)}, ' not present in the map')
        end
    end
end

[s,~]= size(map.sID);
[m,~]=size(map.sAlias);

%use the map mapping matrices to determine which species and species
%aliases to remove
% map.sID	s x r	logical	Logical matrix with rows = speciesID and columns = reactionsID
mapSpeciesToRemove = getCorrespondingRows(map.sID, true(s,1), mapRxnsToRemove, 'exclusive');

% map.sAlias	m x r	logical	Logical matrix with rows = speciesAlias and columns = reactionsID
mapMolsToRemove = getCorrespondingRows(map.sAlias, true(m,1), mapRxnsToRemove, 'exclusive');

%remove reactions
xmlStruct.sbml.model.listOfReactions.reaction = xmlStruct.sbml.model.listOfReactions.reaction(~mapRxnsToRemove);

%remove species
xmlStruct.sbml.model.listOfSpecies.species = xmlStruct.sbml.model.listOfSpecies.species(~mapSpeciesToRemove);

%remove species alias
xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias =...
    xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias(~mapMolsToRemove);

%write out the reduced xml file
struct2xml(xmlStruct, [fileName(1:end-4) '_subset.xml']);

