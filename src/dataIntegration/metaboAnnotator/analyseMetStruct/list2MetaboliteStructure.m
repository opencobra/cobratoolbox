function [metabolite_structure,rBioNet_existance,VMH_existance] = list2MetaboliteStructure(fileName,molFileDirectory,metList,fileNameOutput,metabolite_structure_rBioNet,customMetAbbrList)
% This function reads in an xlsx file and converts it into a
% metabolite_structure. The minimum requirement is that the VMH ID are
% present in one column of the table.
%
% INPUT
% fileName              Name of the xlsx file
% molFileDirectoryIn    Location where to locate the mol files obtained from ctf and new mol files will be added.
% metList
% fileNameOutput
%
% OUTPUT
% metabolite_structure  metabolite structure containing the metabolites
%                       with VMH ID listed in the xlsx file
% rBioNet_existance     This array indicates whether the query abbr exist
%                       already in rBioNet (online and the growing internal
%                       database) (col 1: assigned initial VMHId, col 2: Id
%                       exists as rxn abbr, col 3: Id exists as met abbr,
%                       col 4: VMHId - if not empty this abbr was used in
%                       the metabolite structure instead of the one given
%                       in col 1.
% VMH_existance         This array indicates whether the query abbr exist
%                       already in the VMH (online) (col 1: assigned initial VMHId, col 2: Id
%                       exists as rxn abbr, col 3: Id exists as met abbr).
%
%
% Ines Thiele, 09/2021

if ~exist('fileNameOutput','var')
    fileNameOutput = ['collectedMetStruct' '.mat'];
end
warning off;
if ~exist('metabolite_structure_rBioNet','var')
    load met_strc_rBioNet_new;
end

%load rbionet data
rBioNetPath =  fileparts(which('tutorial_MetabAnnotator'));
if exist([rBioNetPath filesep 'cache' filesep 'metab.mat'],'file')
    load([rBioNetPath filesep 'cache' filesep 'metab.mat']);
elseif exist([rBioNetPath filesep 'data' filesep 'metab.mat'],'file')
    load([rBioNetPath filesep 'data' filesep 'metab.mat']);
else
    %TODO
end

if exist([rBioNetPath filesep 'cache' filesep 'rxn.mat'],'file')
    load([rBioNetPath filesep 'cache' filesep 'rxn.mat']);
elseif  exist([rBioNetPath filesep 'data' filesep 'rxn.mat'],'file')
    load([rBioNetPath filesep 'data' filesep 'rxn.mat']);
else
    %TODO
end

if exist('fileName','var') && ~isempty(fileName)
    if ispc || 1
        % read in xlsx file 
        [NUM,TXT,RAW]=xlsread(fileName);
    else
        [NUM,TXT,RAW] = xlsreadXLSX(fileName);
    end
    xlsProvided = 1;
elseif exist('metList','var') && ~isempty(metList)
    % gives the option to read in a metabolite list - must have a header
    % row and be tab delimited
    RAW= metList;
    fileName = 'metabolite_input';
    xlsProvided = 0;
end

%remove non finite entries, e.g., NaN
bool = false(size(RAW,1),1);
for i=1:size(RAW,1)
    bool(i)=isfinite(RAW{i,1}(1));
end

if any(~bool)
    RAW = RAW(bool,:);
end

retrievePotHMDB1 = 1;
retrievePotHMDB2 = 0;
inchiKey = 1;
smiles = 1;
formula = 1;

% find VMH ID in the input file
vmh_col = find(contains(lower(RAW(1,:)),'vmh'));
hmdb_col = find(contains(lower(RAW(1,:)),'hmdb'));
if ~isempty(vmh_col)
    % check existance
    [VMH_existance,rBioNet_existance,metab_rBioNet_online,rxn_rBioNet_online,metabolite_structure_rBioNet] = checkAbbrExists(RAW(:,vmh_col), metabolite_structure_rBioNet);
    
    % Check that all new met abbr are unique within the provided file (this error often happens when many metabolites are defined at the same time).
    [listDuplicates] = check4DuplicatesInList(RAW(:,vmh_col));
    %Only add to new metabolite structure if VMH IDs are unique
    %   if isempty(find(contains(VMH_existance(:,3),'1'))) &&  isempty(find(contains(rBioNet_existance(:,3),'1'))) && isempty(listDuplicates)
    [metabolite_structure] =createNewMetaboliteStructure(RAW,fileName, metabolite_structure_rBioNet);
    %   else
    %      metabolite_structure= struct();
    %  end
    
else
    cnt =1;
    % no VMH Id's are defined, so do that here
    % generate abbr
    % previously I encoded to generate random VMH numbers
    % [VMHnum] = generateRandomVMHnum;
    %abbr = [VMHnum];
    % we will now generate de novo VMH Id's based on defined
    % rules
    name_col = find(contains(lower(RAW(1,:)),'name'));
    load('data/rxn.mat')
    % this adaptation is needed for metabolon input file
    if length(name_col)>1
        name_col1 = name_col(1);
        clear name_col
        name_col = name_col1;
    end
    RAW(1,end+1) = {'VMHId'};
    [a,b] = size(RAW);
    vmh_col = b;
    
    for i = 2 : size(RAW,1)
        progress = i/(size(RAW,1)-1);
        fprintf([num2str(progress) '% ...Creating abbreviations ... \n']);
        fprintf('\t')
        disp(RAW{i,name_col})
        clear  VMHId
        if ~exist('customMetAbbrList','var')
           %[VMHId] = generateVMHMetAbbr(met, metabolite_structure_rBioNet,metab,rxnDB,customMetAbbrList)
            [VMHId] = generateVMHMetAbbr(RAW{i,name_col},metabolite_structure_rBioNet,metab,rxn);
            customMetAbbrList = convertCharsToStrings(VMHId);
        else
            [VMHId] = generateVMHMetAbbr(RAW{i,name_col},metabolite_structure_rBioNet,metab,rxn,customMetAbbrList);
            customMetAbbrList = [customMetAbbrList ; convertCharsToStrings(VMHId)];
        end
        RAW{i,vmh_col} = VMHId;
        save tmp
    end

    [metabolite_structure] =createNewMetaboliteStructure(RAW,fileName,metabolite_structure_rBioNet,metab,rxn);

    VMH_existance =[];
    rBioNet_existance = [];
    listDuplicates =[];
end

[metabolite_structure] = replaceVMHIds(metabolite_structure);
[metabolite_structure] = addInfoFromMolFiles(metabolite_structure,molFileDirectory);

F = fieldnames(metabolite_structure);
% loop for each metabolite instead of each search for all metabolites at
% once to avoid too quick repinging of a single database
for i = 1:length(F)
    progress = i/length(F);
    fprintf([num2str(progress*100) ' percent ... Annotating metabolites from different resources ... \n']);
    
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
        save(fileNameOutput)
    end
end
% these are offline files
fprintf('Collecting information from AGORA/Recon \n')
[metabolite_structure] = assignAGORAReconPresence(metabolite_structure);
fprintf('Collecting information from Echa \n')
[metabolite_structure,IDsAddedEcha] = getCas2Echa(metabolite_structure);
fprintf('Collecting information from CTD \n')
[metabolite_structure,IDsAddedCTD] = getCas2CTD(metabolite_structure);
try % does not work on linux due to the xlsx file that is loaded
    fprintf('Collecting information from GNPS \n')
    [NUM,TXT,RAW2]=xlsread('GNPSMetabolites.xlsx','Extract');
    [metabolite_structure] = map2GNPS(metabolite_structure,Table,RAW2);
end

% check again whether the VMHId's are novel and also whether the metabolite
% does not yet exists in the rBioNet structure database
fprintf('Checking again whether the metabolites are novel \n')
if exist('metabolite_structure_rBioNet','var') && exist('metab','var') && exist('rxn','var')
    [VMH_existance,rBioNet_existance,metab_rBioNet_online,rxn_rBioNet_online,metabolite_structure_rBioNet] = checkAbbrExists(metabolite_structure,metab,rxn,metabolite_structure_rBioNet);
else
    [VMH_existance,rBioNet_existance,metab_rBioNet_online,rxn_rBioNet_online,metabolite_structure_rBioNet] = checkAbbrExists(metabolite_structure);
end
% if a hit was found, replace the VMHId of the
match = find(contains(rBioNet_existance(:,3),'1'));

% new valid field names
F = fieldnames(metabolite_structure);

% the results from here (or better replacements should be manually checked
if ~isempty(match)
    for i = 1 : length(match)
        if ~isempty(rBioNet_existance{match(i),4})
            % remove field from metabolite structure and add field to
            % metabolite structure from metabolite_structure_rBioNet
            % rBioNet IDs contain ';' that might be not valid for matlab
            % fields. The new Fields are found in metabolite_structure

            metabolite_structure = rmfield(metabolite_structure,[F(match(i))]);
            
            % add field from metabolite_structure_rBioNet
            metabolite_structure.(['VMH_' rBioNet_existance{match(i),4}]) = metabolite_structure_rBioNet.(['VMH_' rBioNet_existance{match(i),4}]);
            % update info in RAW
            r = find(ismember(RAW(:,vmh_col),rBioNet_existance{match(i),1}));
            RAW(r,vmh_col) = repmat({rBioNet_existance{match(i),4}}, 1, length(r));
        end
    end
end

save(fileNameOutput);
% add any missing fields to structure
metabolite_structure= addField2MetStructure(metabolite_structure);

% sort the fields in the structure
F = fieldnames(metabolite_structure);
for i = 1 : length(F)
    metabolite_structure.(F{i}) = orderfields(metabolite_structure.(F{i}));
end

% write updated xls file
if xlsProvided == 1
    fileNameU = insertBefore(fileName,'.','_updated');
    writecell(RAW,fileNameU);
end
%  save collectedMetStruct metabolite_structure
save(fileNameOutput)
