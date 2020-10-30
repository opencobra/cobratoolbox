function removeCDReactions(fileName,rxnRemoveList,printLevel)
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

