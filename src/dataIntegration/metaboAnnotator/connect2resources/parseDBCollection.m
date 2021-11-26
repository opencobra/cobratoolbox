function [metabolite_structure] = parseDBCollection(metabolite_structure,startSearch,endSearch)
% This function takes substantial time. Also note that order matters,
% hence, some resources are parsed twice
%
% INPUT
% metabolite_structure  metabolite structure
% startSearch           specify where the search should start in the
%                       metabolite structure. Must be numeric (optional, default: all metabolites
%                       in the structure will be search for)
% endSearch             specify where the search should end in the
%                       metabolite structure. Must be numeric (optional, default: all metabolites
%                       in the structure will be search for)
%
% OUTPUT
% metabolite_structure  Updated metabolite structure
%
%
% Ines Thiele, 09/2021

if ~exist('startSearch','var')
    startSearch = 1;
end
if ~exist('endSearch','var')
    endSearch = length(F);
end


fprintf('Collecting information from BridgeDB \n')
[metabolite_structure,IDsAddedBridge,IdsMismatch] = parseBridgeDb(metabolite_structure,startSearch,endSearch);
fprintf('Collecting information from HMDB - 1 \n')
tic;[metabolite_structure,IDsAddedHMDB,IDsMismatch,InchiKeyList,InchiStringList ] = parseHmdbWebPage(metabolite_structure,startSearch,endSearch);toc
% the problem is that by chance Bigg and VMH could have the same ID but for
% different metabolites -- I do not do any additional checks right now
% which is dangerous (hence I do not greb more ID's by default)
fprintf('Collecting information from Wikipedia \n')
[metabolite_structure,IDsAddedWikiP] = parseWikipediaWebpage(metabolite_structure,startSearch,endSearch);
fprintf('Collecting information from Kegg \n')
[metabolite_structure,IDsAddedKegg] = parseKeggWebpage(metabolite_structure,startSearch,endSearch);
fprintf('Collecting information from CheBI \n')
[metabolite_structure,IDsAddedChebi,InchiKeyList,InchiStringList ] = parseChebiIdWebPage(metabolite_structure,startSearch,endSearch);
fprintf('Collecting information from Drugbank \n')
[metabolite_structure,IDsAddedDrugBank] = parseDrugBankWebpage(metabolite_structure,startSearch,endSearch);
fprintf('Collecting information from UniChem \n')
[metabolite_structure,IDsAddedUniChem] = getMetIdsFromUniChem(metabolite_structure,startSearch,endSearch); % look into this script - there are many options that I am currently not using

fprintf('Collecting information from MetaNetX \n')
[metabolite_structure,IDsAddedMetaNetX,IDsSuggested] = parseMetaNetXWebpage(metabolite_structure,startSearch,endSearch);

fprintf('Collecting information from Fiehn Lab - 1 \n')
source = 'inchiKey';
target = 'bindingdb';
[metabolite_structure,IDsAdded] = getIDsfromFiehnLab(metabolite_structure, source,target,startSearch,endSearch);

fprintf('Collecting information from Fiehn Lab - 2 \n')
source = 'hmdb';
target = 'bindingdb';
[metabolite_structure,IDsAdded] = getIDsfromFiehnLab(metabolite_structure, source,target,startSearch,endSearch);

fprintf('Collecting information from Fiehn Lab - 3 \n')
source = 'keggId';
target = 'bindingdb';
[metabolite_structure,IDsAdded] = getIDsfromFiehnLab(metabolite_structure, source,target,startSearch,endSearch);

fprintf('Collecting information from BiGG \n')
[metabolite_structure,IDsAddedBigg] = parseBiggID4VMH(metabolite_structure,startSearch,endSearch);
fprintf('Collecting information from CHOmine \n')
[metabolite_structure,IDsAddedCHO] = parseCHOmineWebpage(metabolite_structure,startSearch,endSearch);
fprintf('Collecting information from EPA \n')
[metabolite_structure,IDsAddedEPA] = parseEPA4VMH(metabolite_structure,startSearch,endSearch);
fprintf('Collecting information from FDAsis \n')
[metabolite_structure,IDsAddedFDAsis] = parseFDAsisWebpage(metabolite_structure,startSearch,endSearch);
% fprintf('Collecting information from HMDB - 3 \n')
% [metabolite_structure,IDsAddedHMDB,IDsMismatch,InchiKeyList,InchiStringList ] = parseHmdbWebPage(metabolite_structure);
fprintf('Collecting information from ChemIDPlusWebpage \n')
[metabolite_structure,IDsAddedChemIDPlus] = parseChemIDPlusWebpage(metabolite_structure,startSearch,endSearch);

fprintf('Collecting information from HMDB - 2 \n')
tic;[metabolite_structure,IDsAddedHMDB2,IDsMismatch,InchiKeyList,InchiStringList ] = parseHmdbWebPage(metabolite_structure,startSearch,endSearch);toc
fprintf('Collecting information from BridgeDB \n')
[metabolite_structure,IDsAddedBridge2,IdsMismatch] = parseBridgeDb(metabolite_structure,startSearch,endSearch);

% for the next round
%fprintf('Find Lipid Maps IDs \n')
%[metabolite_structure] = queryLipidMaps(metabolite_structure,startSearch,endSearch);

%fprintf('Find Exposome Explorer IDs \n')
%[metabolite_structure] = queryExposomeExplorer(metabolite_structure)
