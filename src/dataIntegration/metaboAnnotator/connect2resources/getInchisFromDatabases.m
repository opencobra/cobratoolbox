function [TableInchiStrings,TableInchiKeys] = getInchisFromDatabases(model)

printInchis = 1;
%% convert model into metabolite_structure - this is needed as all
% subsequent functions require the metabolite structure as input
[metabolite_structure] = convert2metstructure(model);
metabolite_structure= addField2MetStructure(metabolite_structure);
[metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure);
removeErrors = 0; % is not removed. If set to 1 all errors listed in errorFlag will be removed. Attention, this would remove any entries containing lists.
[metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
metabolite_structureStart = metabolite_structure;


%% get inchiStrings and inchiKeys as in model

Mets = fieldnames(metabolite_structure);
fields = fieldnames(metabolite_structure.(Mets{1}));
a = 1;
b = 1;
for i = 1 : size(Mets,1)
    if ~isempty(metabolite_structure.(Mets{i}).inchiKey) && isempty(find(isnan(metabolite_structure.(Mets{i}).inchiKey),1))
        InchiKeyList_structure{a,1} = Mets{i}; % model/structure ID
        InchiKeyList_structure{a,2} = Mets{i};
        InchiKeyList_structure{a,3} = metabolite_structure.(Mets{i}).inchiKey;
        InchiKeyList_structure{a,4} = metabolite_structure.(Mets{i}).inchiKey_source;
        a = a +1;
    end
    if ~isempty(metabolite_structure.(Mets{i}).inchiString) && isempty(find(isnan(metabolite_structure.(Mets{i}).inchiString),1))
        InchiStringList_structure{a,1} = Mets{i}; % model/structure ID
        InchiStringList_structure{b,2} = Mets{i};
        InchiStringList_structure{b,3} = metabolite_structure.(Mets{i}).inchiString;
        InchiStringList_structure{b,4} = metabolite_structure.(Mets{i}).inchiString_source;
    end
end
%% HMBD
[metabolite_structure_HMDB,IDsAdded_HMDB,IDsMismatch_HMDB,InchiKeyList_HMDB,InchiStringList_HMDB ] = parseHmdbWebPage(metabolite_structure,printInchis);
%% Chebi
[metabolite_structure_ChebiId,IDsAdded_ChebiId,InchiKeyList_ChebiId,InchiStringList_ChebiId ] = parseChebiIdWebPage(metabolite_structure_HMDB,printInchis);

%% from collected mol files
if 0
    folder_Recon3D = 'FileDumps/molFiles/molInMassBalancedRxnExplicitH_Recon3D/';
    [metabolite_structure_Recon3D,IDsAdded_Recon3D,InchiKeyList_Recon3D,InchiStringList_Recon3D] = generateInchiFromMol(metabolite_structure,folder_Recon3D, 1, 0);
    folder_AGORA2 = 'FileDumps/molFiles/molFiles_AGORA2/';
    [metabolite_structure_AGORA2,IDsAdded_AGORA2,InchiKeyList_AGORA2,InchiStringList_AGORA2] = generateInchiFromMol(metabolite_structure,folder_AGORA2, 1, 0);
end
%% from Kegg
% first get mol files from Kegg
% they will be deposited in a folder
folder_Kegg = strcat('FileDumps/molFiles/molFiles_Kegg_',model.modelID,'/');
mkdir(folder_Kegg);
[metabolite_structure_Kegg] = getMolFromKegg(metabolite_structure,folder_Kegg);
[metabolite_structure_Kegg,IDsAdded_Kegg,InchiKeyList_Kegg,InchiStringList_Kegg] = generateInchiFromMol(metabolite_structure,folder_Kegg, 1, 0);

%% generate overview table
clear TableInchiStrings
TableInchiStrings(1,1) = {'MetID'};
TableInchiStrings(2:size(Mets,1)+1,1) = Mets;

clear TableStrKeys
TableInchiKeys(1,1) = {'MetID'};
TableInchiKeys(2:size(Mets,1)+1,1) = Mets;
a = 2;
for i = 2 : size(TableInchiKeys,1)
    %% InchiKey Table
    % first read the information from the model
    % find the right entry in the table
    i
    name = 'model';
    maxCol = 1;
    [TableInchiKeys] = fillTable(TableInchiKeys,i,InchiKeyList_structure,name,maxCol);
    
    % now from HMDB
    name = 'HMDB';
    maxCol = 10;
    [TableInchiKeys] = fillTable(TableInchiKeys,i,InchiKeyList_HMDB,name,maxCol);
    
    % chebi
    name = 'ChebIId';
    maxCol = 10;
    [TableInchiKeys] = fillTable(TableInchiKeys,i,InchiKeyList_ChebiId,name,maxCol);
    
    if 0
        %_Recon3D
        name = folder_Recon3D;
        maxCol = 1;
        [TableInchiKeys] = fillTable(TableInchiKeys,i,InchiKeyList_Recon3D,name,maxCol);
        %_AGORA2
        name = folder_AGORA2;
        maxCol = 1;
        [TableInchiKeys] = fillTable(TableInchiKeys,i,InchiKeyList_AGORA2,name,maxCol);
    end
    %_KEGG
    name = folder_Kegg;
    maxCol = 1;
    [TableInchiKeys] = fillTable(TableInchiKeys,i,InchiKeyList_Kegg,name,maxCol);
    
    %% InchiStrings
    if ~isempty(metabolite_structureStart.(Mets{1}).inchiString) && isempty(find(isnan(metabolite_structureStart.(Mets{1}).inchiString),1))
        name = 'model';
        maxCol = 1;
        [TableInchiStrings] = fillTable(TableInchiStrings,i,InchiStringList_structure,name,maxCol);
    end
    % now from HMDB
    name = 'HMDB';
    maxCol = 10;
    [TableInchiStrings] = fillTable(TableInchiStrings,i,InchiStringList_HMDB,name,maxCol);
    
    % chebi
    name = 'ChebIId';
    maxCol = 10;
    [TableInchiStrings] = fillTable(TableInchiStrings,i,InchiStringList_ChebiId,name,maxCol);
    
    if 0
        % mol files from _Recon3D
        name = folder_Recon3D;
        maxCol = 1;
        [TableInchiStrings] = fillTable(TableInchiStrings,i,InchiStringList_Recon3D,name,maxCol);
        
        %_AGORA2
        name = folder_AGORA2;
        maxCol = 1;
        [TableInchiStrings] = fillTable(TableInchiKeys,i,InchiStringList_AGORA2,name,maxCol);
    end
    
    %_KEGG
    name = folder_Kegg;
    maxCol = 1;
    [TableInchiStrings] = fillTable(TableInchiKeys,i,InchiStringList_Kegg,name,maxCol);
end
save Results

function [Table] = fillTable(Table,i,List,name,maxCol)
if ~exist('maxCol','var')
    maxCol = 1;
end
row = find(contains(List(:,1),Table(i,1)));
b = size(Table,2) + 1;
if i ==2
    % write header
    for j = 1 : maxCol% length(row)
        Table(1,b) = {strcat(name,'_',num2str(j))};
        b =b +1;
    end
end
for j = 1 : length(row)
    if j <= maxCol
        col = (strmatch(strcat(name,'_',num2str(j)),Table(1,:),'exact'));
        col
        Table(i,col) = List(row(j),3);
    end
end

