function [metabolite_structure_rBioNet] = createrBioNetStructure(metabolite_structure_rBioNet,start,stop)
% for the moment rBioNet will serve as universal database, but I will
% update this
warning off;
mkdir('data/');
currentPath = pwd;

if ~exist('metabolite_structure_rBioNet','var')
    websave('data/MetaboliteDatabase.txt','https://raw.githubusercontent.com/opencobra/COBRA.papers/master/2021_demeter/input/MetaboliteDatabase.txt');
    websave('data/ReactionDatabase.txt','https://raw.githubusercontent.com/opencobra/COBRA.papers/master/2021_demeter/input/ReactionDatabase.txt');
   % websave('data/compartments.mat','https://raw.githubusercontent.com/opencobra/COBRA.papers/master/2021_demeter/input/compartments.mat');
   % cd data;
    createRBioNetDBFromVMHDB('rBioNetDBFolder','data');
    load('data/metab.mat');
    cd(currentPath);
end

molFileDirectory = 'C:\Users\0123322S\Documents\GitHub\chemTableFiles\ctf\mets\molFiles';

annotationType = 'automatic';

if ~exist('metabolite_structure_rBioNet','var')
    fprintf('Create metabolite structure \n');
    % create metabolite structure out of metab
    metab2={'VMHId' 'metNames' 'neutralFormula' 'chargedFormula' 'charge' 'keggId' 'pubChemID' 'cheBIId' 'inchiKey' 'smiles' 'hmdb','subsystem'};
    metab(:,end-1)=[];%remove date
    metab2 = [metab2;metab];
    [metabolite_structure_rBioNet] =createNewMetaboliteStructure(metab2,'rBioNet');
    
    
    %[metabolite_structure_rBioNet,hit] = searchMultipleUnknownMetOnline(metabolite_structure_rBioNet);
    
    % these files run at this point as they are all offline, loading files
    % deposited in /data/. It would take more time to open these files for each
    % metabolite.
    [IDsStart,IDcountStart,TableStart] = getStatsMetStruct(metabolite_structure_rBioNet);
end

F = fieldnames(metabolite_structure_rBioNet);
if ~exist('start','var')
    start = 1;
end
if ~exist('stop','var')
    stop = length(F);
end

if start == 1
% apparently rBioNet does not contain all recon metabolites, so I will add
% them here.
% However, I will retrieve VMH information on the metabolites at the next
% stage
% this function also assigns the presence/absence in AGORA/Recon to enable
% quick identification of currently human or microbe only metabolites
fprintf('Assign AGORA Recon Presence \n');
[metabolite_structure_rBioNet] = assignAGORAReconPresence(metabolite_structure_rBioNet);
fprintf('Metabolon mapping \n');
[metabolite_structure_rBioNet] = VMH2Metabolon(metabolite_structure_rBioNet);
fprintf('Add manually refined/corrected annotations \n');
[metabolite_structure_rBioNet] = replaceVMHIds(metabolite_structure_rBioNet);
fprintf('Assign Seed IDs \n');
[metabolite_structure_rBioNet] = VMH2Seed(metabolite_structure_rBioNet);
% offline file provided by seed/kbase
fprintf('Add Kegg IDs using Seed  \n');
[metabolite_structure_rBioNet] = getSeed2Kegg(metabolite_structure_rBioNet);
save met_strc_rBioNet_new_30_06_2022
end
inchiKey = 1;
smiles = 1;
formula = 1;

% do not query HMDB by name as it takes too much time right now.
retrievePotHMDB = 0;
retrievePotHMDB2 = 0;


for i = start:stop
    startSearch = i;
    endSearch = i;
    i
    progress = i/stop;
    fprintf([num2str(progress) '  ... Annotating metabolites from different resources ... \n']);
    
    % obtain info from the VMH api, this also fills the gaps from earlier
    % where recon only metabolites were added without additional
    % information
    fprintf('Connect to VMH \n');
    [metabolite_structure_rBioNet] = parseVMH4IDs(metabolite_structure_rBioNet,startSearch,endSearch);
    
    
    fprintf('Add information from mol files \n');
    [metabolite_structure_rBioNet] = addInfoFromMolFiles(metabolite_structure_rBioNet,molFileDirectory,startSearch,endSearch);
    
    
    fprintf('Find HMDB Ids \n');
    [metabolite_structure_rBioNet] = getMissingHMDBMolForm(metabolite_structure_rBioNet,molFileDirectory,retrievePotHMDB,startSearch,endSearch);
    
    fprintf('Collect information from different databases ... \n');
    [metabolite_structure_rBioNet] = parseDBCollection(metabolite_structure_rBioNet,startSearch,endSearch);
    
    fprintf('Collect more mol files \n');
    [metabolite_structure_rBioNet] = getMolFilesMultipleSources(metabolite_structure_rBioNet,molFileDirectory,startSearch,endSearch);
    
    fprintf('Generate database independent id from mol files \n');
    [metabolite_structure_rBioNet] = generateInchiFromMol(metabolite_structure_rBioNet,molFileDirectory, inchiKey, smiles,formula,startSearch,endSearch);
    
    
    fprintf('Collect more mol files - 2 \n');
    % now repeat the seearch for mol files again but skip the guessing of hmdb
    % ids from name
    
    [metabolite_structure_rBioNet] = getMissingHMDBMolForm(metabolite_structure_rBioNet,molFileDirectory,retrievePotHMDB2,startSearch,endSearch);
    [metabolite_structure_rBioNet] = getMissingDrugMolForm(metabolite_structure_rBioNet,molFileDirectory,startSearch,endSearch);
    [metabolite_structure_rBioNet] = getMolFilesMultipleSources(metabolite_structure_rBioNet,molFileDirectory,startSearch,endSearch);
    fprintf('Generate database independent id from mol files - 2 \n');
    
    [metabolite_structure_rBioNet] = generateInchiFromMol(metabolite_structure_rBioNet,molFileDirectory, inchiKey, smiles,formula,startSearch,endSearch);
    fprintf('Assign metabolite classification \n');
    
    [metabolite_structure_rBioNet] = assignClassyFire(metabolite_structure_rBioNet,startSearch,endSearch);
    %fprintf('Check that HMDB Ids are valid \n');
    % works only for HMDB right now
    % do it later, the last time only 16 out of 7900 were wrong - it takes
    % too much time
    % [metabolite_structure_rBioNet] = checkLinkValidity(metabolite_structure_rBioNet,startSearch,endSearch);
    if mod(i,10)==1
        save met_strc_rBioNet_new_30_06_2022
    end
end


% offline files
fprintf('Collecting information from Echa \n')
 [metabolite_structure_rBioNet] = getCas2Echa(metabolite_structure_rBioNet);
fprintf('Collecting information from CTD \n')
[metabolite_structure_rBioNet] = getCas2CTD(metabolite_structure_rBioNet);

% getIDsFromBIGG; --> I should use the online version --> neither one is
% accounted for in the last rBioNetX hence the final numbers are still
% lower


% sort the fields in the structure
F = fieldnames(metabolite_structure_rBioNet);
for i = 1 : length(F)
metabolite_structure_rBioNet.(F{i}) = orderfields(metabolite_structure_rBioNet.(F{i}));
end
[IDsEnd2,IDcountEnd2,TableEnd2] = getStatsMetStruct(metabolite_structure_rBioNet);
save met_strc_rBioNet_new_07_10_2021
writecell(TableEnd2,'rbionetMetStructure.xls');