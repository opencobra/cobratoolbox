%% *Extraction of a submap from a Cell Designer map (PART 3)* 
%% Authors: Ronan M.T. Fleming, Leiden University
%% *Reviewer(s):* 
%% INTRODUCTION
% Given a generic map of metabolism, creat a derivative map by removing a subset 
% of the reactions.
%% EQUIPMENT SETUP 
% To visualise the metabolic maps it is necessary to obtain the version 4.4 
% of CellDesigner. This software can be freely downloaded from: 
% 
% <http://www.celldesigner.org/download.html http://www.celldesigner.org/download.html>
%% PROCEDURE
%% 1. Import a CellDesigner XML file to MATLAB environment
% The |transformXML2Map| function parses an XML file from Cell Designer (CD) 
% into a Matlab structure. This structure is organised similarly to the structure 
% found in the COnstraint-Base and Reconstruction Analysis (COBRA) models.
% 
% Read in a map

[GlyXml, GlyMap] = transformXML2Map('glycolysisAndTCA.xml');
%% 2. Remove some reactions from the map

if 1
    rxnRemoveList={'ENO';'PFK';'PGMT';'ABC'};
else
    rxnRemoveList={'PGMT'};
end
printLevel=1;
[GlyXmlStructSubset,GlyMapSubset,rxnNotInMap] = removeMapReactions(GlyXml,GlyMap,rxnRemoveList,printLevel);
%% 
% There is no reaction 'ABC' in the map, so the function alerts that it has 
% not been removed. 

rxnRemoveList(rxnNotInMap)
%% 3. Export the modified map

transformMap2XML(GlyXmlStructSubset,GlyMapSubset,'glycolysisAndTCA_subset.xml');
% 4. Import the modified map and compare it with the matlab structures

[GlyXmlStructSubset2,GlyMapSubset2] = transformXML2Map('glycolysisAndTCA_subset.xml');
%% 
% Compare xml structure

[resultXml, whyXml] = structeq(GlyXmlStructSubset, GlyXmlStructSubset2)
GlyXmlStructSubset.sbml(1).model(1).listOfReactions(1).reaction{2}(1).Attributes
GlyXmlStructSubset2.sbml(1).model(1).listOfReactions(1).reaction{2}(1).Attributes
%% 
% Compare map structure

[resultMap, whyMap] = structeq(GlyMapSubset, GlyMapSubset2)

return
%% 4. Remove reactions from the map directly

fileName = 'glycolysisAndTCA.xml';
printLevel=1;
removeCDReactions(fileName,rxnRemoveList,printLevel)
%% 
% 
% 
%