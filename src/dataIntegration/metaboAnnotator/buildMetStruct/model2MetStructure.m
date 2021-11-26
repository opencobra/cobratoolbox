function [metabolite_structure,tableMappingOverview,TableIDs] = model2MetStructure(filename,filetype,outputFileName, metabolite_structure_rBioNet)
% This function populates metabolites present in a model structure with
% metabolite identifiers, using the MetaboAnnotator.
%
% INPUT
% filename                      Name of the metabolic reconstruction
% filetype                      Filetype of the metabolic reconstruction to be loaded. Valid
%                               input arguments are:'SBML', 'SimPheny','SimPhenyPlus', 'SimPhenyText',
%                               'Matlab', 'BiGG', 'BiGGSBML' or 'Excel' (Default = 'Matlab'), see
%                               readCbModel.m for more details.
% outputFileName                File name under which the metabolite structure
%                               and any other information will be saved.
% metabolite_structure_rBioNet 
%
% OUTPUT
% metabolite_structure          metabolite structure containing retrieved metabolite
%                               identifiers for each metabolite in the
%                               metabolic reconstruction
% tableMappingOverview          Table listing the IDs and their count
%                               before and after running the function
% TableIDs                      Table containing the individual IDs. Same
%                               content as in metabolite_structure
%
% Ines Thiele, 2020/2021

% load precomputed rBioNetStructure
if ~exist('metabolite_structure_rBioNet','var')
    load met_strc_rBioNet_new;
end
% load metabolite and reaction information from rBioNet (retrieved and downloaded from
% github)
load('data/metab.mat');
load('data/rxn.mat');

model=readCbModel(filename,'fileType',filetype);

[metabolite_structure] = convertModel2Metstructure(model);

[IDsStart,IDcountStart,TableStart] = getStatsMetStruct(metabolite_structure);


molFileDirectory = ('/molFiles');
F = fieldnames(metabolite_structure);
retrievePotHMDB1 = 0;
retrievePotHMDB2 = 0;
inchiKey = 1;
smiles = 1;
formula = 1;

% loop for each metabolite instead of each search for all metabolites at
% once to avoid too quick repinging of a single database
for i = 1: length(F)
    progress = i/length(F);
    fprintf([num2str(progress) '% ... Annotating metabolites from different resources ... \n']);
    
    startSearch =i;
    endSearch = i;
    %  fprintf('Collecting information from Multiple Unknown Met Online \n')
    % [metabolite_structure,hit] = searchMultipleUnknownMetOnline(metabolite_structure,metabolite_structure_rBioNet,metab,rxn,startSearch,endSearch);
    
    fprintf('Collecting Missing HMDB Mol Form \n')
    [metabolite_structure] = getMissingHMDBMolForm(metabolite_structure,molFileDirectory,retrievePotHMDB1,startSearch,endSearch);
    fprintf('Collecting Mol Files Multiple Sources\n')
    [metabolite_structure,molCollectionReport] = getMolFilesMultipleSources(metabolite_structure,molFileDirectory,startSearch,endSearch);
    
    fprintf('Generate database independent id from mol files \n');
    [metabolite_structure,IDsAdded,InchiKeyList,InchiStringList] = generateInchiFromMol(metabolite_structure,molFileDirectory, inchiKey, smiles,formula,startSearch,endSearch);
    [metabolite_structure] = parseDBCollection(metabolite_structure,startSearch,endSearch);
    % now repeat the seearch for mol files again
    
    fprintf('Collect more mol files - 2 \n');
    [metabolite_structure] = getMissingHMDBMolForm(metabolite_structure,molFileDirectory,retrievePotHMDB2,startSearch,endSearch);
    [metabolite_structure] = getMissingDrugMolForm(metabolite_structure,molFileDirectory,startSearch,endSearch);
    [metabolite_structure,molCollectionReport] = getMolFilesMultipleSources(metabolite_structure,molFileDirectory,startSearch,endSearch);
    
    fprintf('Generate database independent id from mol files \n');
    [metabolite_structure,IDsAdded,InchiKeyList,InchiStringList] = generateInchiFromMol(metabolite_structure,molFileDirectory, inchiKey, smiles,formula,startSearch,endSearch);
    fprintf('Assign metabolite classification \n');
    
    [metabolite_structure] = assignClassyFire(metabolite_structure,startSearch,endSearch);
    if mod(i,10)==1
        save([outputFileName '.mat']);
    end
end

if exist('metabolite_structure_rBioNet','var') && exist('metab','var') && exist('rxn','var')
    [VMH_existance,rBioNet_existance,metab_rBioNet_online,rxn_rBioNet_online,metabolite_structure_rBioNet] = checkAbbrExists(metabolite_structure,metab,rxn,metabolite_structure_rBioNet);
else
    [VMH_existance,rBioNet_existance,metab_rBioNet_online,rxn_rBioNet_online,metabolite_structure_rBioNet] = checkAbbrExists(metabolite_structure);
end
% if a hit was found, leave VMH Id otw remove it - this is a difference to
% the other scripts that replace initial collections with VMH pages
[VMH2IDmappingAll,VMH2IDmappingPresent,VMH2IDmappingMissing]=getIDfromMetStructure(metabolite_structure,'VMHId');

% As most reconstructions do not follow VMH nomenclature, I will remove the
% VMH tag from the fieldname and add those VMH IDs identified in
% rBioNet_existance to the metabolite field VMH_ID. Note that not all VMH
% IDs may have been identified as only inchiKeys and inchiStrings were used
% as comparison terms. For E. coli core for example, glc_D and lac_D etc
% were not mapped.

annotationSource = 'rBioNet (matching based on inchiString or inchiKey)';
annotationType = 'automatic';

for i = 1 : size(rBioNet_existance,1)
    if ~isempty(rBioNet_existance{i,4})
        % set it as VMH ID
        metabolite_structure.(['VMH_' rBioNet_existance{i,1}]).VMHId = rBioNet_existance{i,4};
        metabolite_structure.(['VMH_' rBioNet_existance{i,1}]).VMHId_source = [annotationSource,':',annotationType,':',datestr(now)];
    else
        % remove temporary VMH IDs used during the scripts
        metabolite_structure.(['VMH_' rBioNet_existance{i,1}]).VMHId = NaN;
        metabolite_structure.(['VMH_' rBioNet_existance{i,1}]).VMHId_source = NaN;
    end
end

% VMH_existance reports those IDs that are overlapping with the VMH.life
% if the entry in the 3rd column is 1, this means that the abbreviation
% between the input metabolite abbr and the VMH. This could lead to false
% positives
annotationSource = 'VMH.life (matching based on input abbr)';
annotationType = 'automatic';
for i = 1 : size(VMH_existance,1)
    if str2num(VMH_existance{i,3}) == 1 % mapping is positive
        if length(find(isnan(metabolite_structure.(['VMH_' VMH_existance{i,1}]).VMHId))) % has no VMHId yet
        metabolite_structure.(['VMH_' VMH_existance{i,1}]).VMHId = VMH_existance{i,1};
        metabolite_structure.(['VMH_' VMH_existance{i,1}]).VMHId_source = [annotationSource,':',annotationType,':',datestr(now)];
        end
    end
end
% parse the VMH.life again for the newly found VMH IDs
[metabolite_structure] = parseVMH4IDs(metabolite_structure);

% rename fields in the metabolite structure
F = fieldnames(metabolite_structure);
metabolite_structureNew =struct();
for i = 1 : length(F)
    newF = regexprep(F{i},'VMH_','M_');
    metabolite_structureNew.(newF) = metabolite_structure.(F{i});
end
metabolite_structure = metabolite_structureNew;
% map onto AGORA and Recon3D
fprintf('Collecting information from AGORA/Recon \n')
[metabolite_structure] = assignAGORAReconPresence(metabolite_structure);

% sort the fields in the structure
F = fieldnames(metabolite_structure);
for i = 1 : length(F)
    metabolite_structure.(F{i}) = orderfields(metabolite_structure.(F{i}));
end
% add SBO term to each metabolite

% Get the statistics of metabolite identifiers
[IDsEnd,IDcountEnd,TableEnd] = getStatsMetStruct(metabolite_structure);

tableStartOverview = table(IDsStart,IDcountStart,'VariableNames',{'ID', 'Count Before'});
tableEndOverview = table(IDsEnd,IDcountEnd,'VariableNames',{'ID', 'Count After'});
tableMappingOverview = outerjoin(tableStartOverview,tableEndOverview,'MergeKeys',true);
TableIDs = TableEnd;
clear IDs* i inchi* mol* progress smiles start* TableS* tableE* retrieve* Inchi* annota* F endSearch IDc* stop 
clear VMH2IDmappingMissing VMH2IDmappingPresent tableStartOverview tableEndOverview TableEnd
save([outputFileName '.mat']);

