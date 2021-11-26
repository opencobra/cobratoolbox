
%% readin the various files

% I will set all random files from VHM to 0 bc I am afraid of error
% propagation. There seem to be quite some errors in the VMH (also online)
% - let's see how many IDs I get without it

if 0
    [NUM,TXT,RAW]=xlsread('MetabolitesAGORA2_1.xlsx');
    fields = fieldnames(metabolite_structure);
    % assign whether metabolite appears in AGORA2
    for i = 2 : size(RAW,1)
        Ori = RAW{i,1};
        RAW{i,1} = regexprep(RAW{i,1},'-','_minus_');
        RAW{i,1} = regexprep(RAW{i,1},'(','_parentO_');
        RAW{i,1} = regexprep(RAW{i,1},')','_parentC_');
        % metabolite exists in the original input file 'VMH_Metabolites.xlsx'
        if strmatch(strcat('VMH_',RAW{i,1}),fields,'exact')
            metabolite_structure.(strcat('VMH_',RAW{i,1})).Agora2 = 1;
        else
            % add all fields to this new compound that are also
            % there for D-glucose
            fieldsGlc = fieldnames(metabolite_structure.('M_glc_D'));
            for j = 1 : length(fieldsGlc)
                metabolite_structure.(strcat('VMH_',RAW{i,1})).(fieldsGlc{j}) = NaN;
                metabolite_structure.(strcat('VMH_',RAW{i,1})).VMHId = Ori;
            end
            metabolite_structure.(strcat('VMH_',RAW{i,1})).Agora2 = 1;
        end
    end
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
    
end
if 1
    [NUM,TXT,RAW]=xlsread('MetabolitesAGORA2.xlsx');
    fields = fieldnames(metabolite_structure);
    for i = 2 : size(RAW,1)
        Ori = RAW{i,1};
        RAW{i,1} = regexprep(RAW{i,1},'-','_minus_');
        RAW{i,1} = regexprep(RAW{i,1},'(','_parentO_');
        RAW{i,1} = regexprep(RAW{i,1},')','_parentC_');
        % metabolite exists in the original input file 'VMH_Metabolites.xlsx'
        if strmatch(strcat('VMH_',RAW{i,1}),fields,'exact')
            metabolite_structure.(strcat('VMH_',RAW{i,1})).Agora2 = 1;
        else
            % add all fields to this new compound that are also
            % there for D-glucose
            fieldsGlc = fieldnames(metabolite_structure.('M_glc_D'));
            for j = 1 : length(fieldsGlc)
                metabolite_structure.(strcat('VMH_',RAW{i,1})).(fieldsGlc{j}) = NaN;
                metabolite_structure.(strcat('VMH_',RAW{i,1})).VMHId = Ori;
            end
            metabolite_structure.(strcat('VMH_',RAW{i,1})).Agora2 = 1;
        end
    end
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end

if 1
    [NUM,TXT,RAW]=xlsread('Recon3Mets.xlsx');
    % assign whether metabolite appears in Recon3D
    fields = fieldnames(metabolite_structure);
    for i = 2 : size(RAW,1)
        Ori = RAW{i,1};
        RAW{i,1} = regexprep(RAW{i,1},'-','_minus_');
        RAW{i,1} = regexprep(RAW{i,1},'(','_parentO_');
        RAW{i,1} = regexprep(RAW{i,1},')','_parentC_');
        % metabolite exists in the original input file 'VMH_Metabolites.xlsx'
        if strmatch(strcat('VMH_',RAW{i,1}),fields,'exact')
            metabolite_structure.(strcat('VMH_',RAW{i,1})).Recon3D = 1;
        else
            % add all fields to this new compound that are also
            % there for D-glucose
            fieldsGlc = fieldnames(metabolite_structure.('M_glc_D'));
            for j = 1 : length(fieldsGlc)
                metabolite_structure.(strcat('VMH_',RAW{i,1})).(fieldsGlc{j}) = NaN;
                metabolite_structure.(strcat('VMH_',RAW{i,1})).VMHId = Ori;
            end
            metabolite_structure.(strcat('VMH_',RAW{i,1})).Recon3D = 1;
        end
    end
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end

if 1
    [NUM,TXT,RAW]=xlsread('DrugMetabolites.xlsx');
    fields = fieldnames(metabolite_structure);
    for i = 2 : size(RAW,1)
        Ori = RAW{i,1};
        if isempty(find(isnan(RAW{i,1}),1))
            RAW{i,1} = regexprep(RAW{i,1},'-','_minus_');
            RAW{i,1} = regexprep(RAW{i,1},'(','_parentO_');
            RAW{i,1} = regexprep(RAW{i,1},')','_parentC_');
            % metabolite exists in the original input file 'VMH_Metabolites.xlsx'
            if strmatch(strcat('VMH_',RAW{i,1}),fields,'exact')
                metabolite_structure.(strcat('VMH_',RAW{i,1})).Recon3D = 2;
            else
                % add all fields to this new compound that are also
                % there for D-glucose
                fieldsGlc = fieldnames(metabolite_structure.('M_glc_D'));
                for j = 1 : length(fieldsGlc)
                    metabolite_structure.(strcat('VMH_',RAW{i,1})).(fieldsGlc{j}) = NaN;
                    metabolite_structure.(strcat('VMH_',RAW{i,1})).VMHId = Ori;
                    metabolite_structure.(strcat('VMH_',RAW{i,1})).Recon3D = 2;
                    
                end
            end
        end
    end
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end

if 1
    [NUM,TXT,RAW]=xlsread('Metabolites-Recon3D.xlsx');
    fields = fieldnames(metabolite_structure);
    for i = 2 : size(RAW,1)
        Ori = RAW{i,1};
        if isempty(find(isnan(RAW{i,1}),1))
            RAW{i,1} = regexprep(RAW{i,1},'-','_minus_');
            RAW{i,1} = regexprep(RAW{i,1},'(','_parentO_');
            RAW{i,1} = regexprep(RAW{i,1},')','_parentC_');
            % metabolite exists in the original input file 'VMH_Metabolites.xlsx'
            if strmatch(strcat('VMH_',RAW{i,1}),fields,'exact')
                metabolite_structure.(strcat('VMH_',RAW{i,1})).Recon3D = 3;
            else
                % add all fields to this new compound that are also
                % there for D-glucose
                fieldsGlc = fieldnames(metabolite_structure.('M_glc_D'));
                for j = 1 : length(fieldsGlc)
                    metabolite_structure.(strcat('VMH_',RAW{i,1})).(fieldsGlc{j}) = NaN;
                    metabolite_structure.(strcat('VMH_',RAW{i,1})).VMHId = Ori;
                    metabolite_structure.(strcat('VMH_',RAW{i,1})).Recon3D = 3;
                    
                end
            end
        end
    end
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end

if 1
    % contains mapping of VMH IDs and HMDB
    [NUM,TXT,RAW]=xlsread('MetIDs.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end


if 1
    % contains VMH to HMDB mapping
    [NUM,TXT,RAW]=xlsread('hmdb.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end

if 0 % I am not sure about origin
    [NUM,TXT,RAW]=xlsread('InchiKeys.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end

if 0% I am not sure about origin
    [NUM,TXT,RAW]=xlsread('InchiStrings.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end



if 0 % do not use - unknown source
    [NUM,TXT,RAW]=xlsread('Book19.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end

if  0% I am not sure about origin
    [NUM,TXT,RAW]=xlsread('Book20.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end
if 1
    [NUM,TXT,RAW]=xlsread('duplicate_HMDB_from_stefania.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end
if  0% I am not sure about origin
    [NUM,TXT,RAW]=xlsread('metabolites_VMH_2.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end
if 1
    [NUM,TXT,RAW]=xlsread('ForHMRMets.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end
if  0
    [NUM,TXT,RAW]=xlsread('metabolites.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end

if  0% I am not sure about origin
    [NUM,TXT,RAW]=xlsread('metInChiKeys.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end
if  0% I am not sure about origin
    [NUM,TXT,RAW]=xlsread('metInChis.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end
if  0
    [NUM,TXT,RAW]=xlsread('parsed_hmdbX.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end
if 1 % contains HMDB and Chebii mapping
    [NUM,TXT,RAW]=xlsread('Mets_further.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end
if 0% I am not sure about origin
    [NUM,TXT,RAW]=xlsread('vmh_inchi.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end

if 0
    [NUM,TXT,RAW]=xlsread('recon-store-metabolites-1.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end
if 1 % contains HMDB mapping
    [NUM,TXT,RAW]=xlsread('Book22.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end
if 0
    [NUM,TXT,RAW]=xlsread('VMH_Met_all.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end

if 0
    [NUM,TXT,RAW]=xlsread('metabolites_externalLinks_filtre_null.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end

if 0
    [NUM,TXT,RAW]=xlsread('Copy of metabolites_externalLinks_filtre_null_IT.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end
if 0
    [NUM,TXT,RAW]=xlsread('out_external_links_metabolites.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end

if 0
    [NUM,TXT,RAW]=xlsread('recon-store-metabolites-2.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end
if 0
    [NUM,TXT,RAW]=xlsread('recon-store-metabolites-1a.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end
if 1
    [NUM,TXT,RAW]=xlsread('VMH2MNX_met.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end

if 1
    [NUM,TXT,RAW]=xlsread('SeedVMHmetMapping.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end
if 0
    [NUM,TXT,RAW]=xlsread('metInchis_all.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end
if 0
    [NUM,TXT,RAW]=xlsread('mets_AGORARelease.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end
if 0
    [NUM,TXT,RAW]=xlsread('mets_recondbtest20181217.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end
if 0
    [NUM,TXT,RAW]=xlsread('mets_20171117dump.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end
if 0
    [NUM,TXT,RAW]=xlsread('mets_JuneRelease.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end

if 0
    [NUM,TXT,RAW]=xlsread('mets_before.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end

if 0
    [NUM,TXT,RAW]=xlsread('mets_recondbtest_20181002.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end

if 0
    [NUM,TXT,RAW]=xlsread('mets_recondbtest_20181005.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end

if 0
    [NUM,TXT,RAW]=xlsread('mets_recondbtest_20181129.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end

if 0
    [NUM,TXT,RAW]=xlsread('mets_recondbtest_20190101.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end

if 0
    [NUM,TXT,RAW]=xlsread('mets_recondbtest_JuneReleaseb.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2] = getStats(metabolite_structure);
end

%% the scripts from here on could be used for scheduled updates
if 1
    [metabolite_structure,IDsAdded ] = parseChebiId(metabolite_structure);
end
if 1
    % expand annotation based on bigg database
    % file was obtained June 2020 from http://bigg.ucsd.edu/static/namespace/bigg_models_reactions.txt
    [NUM,TXT,RAW]=xlsread('bigg_models_metabolites.xlsx');
    [metabolite_structure] = addAnnotations(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount2,Table] = getStats(metabolite_structure);
    getIDsFromBIGG;
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount3,Table] = getStats(metabolite_structure);
end
if 1
    % HMDB switch from a 5 digit code to a 7 digit code
    % so the current ID's are a mixture
    HMDBOri = 1; % use ID's as in VMH
    HMDBFive = 0; % convert 7 digit ID's into 5 digit IDs
    HMDBSeven = 0;% convert 5 digit ID's into 7 digit IDs
    getAnnoFromHMDB;
    HMDBOri = 0; % use ID's as in VMH
    HMDBFive = 1; % convert 7 digit ID's into 5 digit IDs
    HMDBSeven = 0;% convert 5 digit ID's into 7 digit IDs
    getAnnoFromHMDB;
    HMDBOri = 0; % use ID's as in VMH
    HMDBFive = 0; % convert 7 digit ID's into 5 digit IDs
    HMDBSeven = 1;% convert 5 digit ID's into 7 digit IDs
    getAnnoFromHMDB;
    % the underlying perl script requires the metabolite database from HMDB
    % which can be obtained here:
    % https://hmdb.ca/system/downloads/current/hmdb_metabolites.zip
    % (downloaded June 2020, version 2019-01-16)
    [IDs,IDcount4,Table] = getStats(metabolite_structure);
end

% links to GNPS database
if 0
    [NUM,TXT,RAW]=xlsread('GNPSMetabolites.xlsx','Extract');
    [metabolite_structure] = map2GNPS(metabolite_structure,Table,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    [IDs,IDcount4,Table] = getStats(metabolite_structure);
end

metabolite_structureOri = metabolite_structure;
if 1
    % I can get more annotations from Chebi
    % using the files:
    % ftp://ftp.ebi.ac.uk/pub/databases/chebi/Flat_file_tab_delimited/chebiId_inchi.tsv
    % which maps Chebi IDs to inchi
    % and
    % ftp://ftp.ebi.ac.uk/pub/databases/chebi/Flat_file_tab_delimited/database_accession.tsv
    % which maps chebi id (2nd col) to other dbs
    [NUM,TXT,RAW]=xlsread('chebiId_inchi.xlsx'); % downloaded
    [metabolite_structure] = mapChebiid(metabolite_structure,RAW);
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
end

% newly added
% latest translation table between seed and vmh gut microbes
[NUM,TXT,RAW]=xlsread('MetaboliteTranslationTable.xlsx');
[metabolite_structure] = addAnnotations(metabolite_structure,RAW);
[metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
removeErrors = 1;
[metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);

[metabolite_structure,IDsAdded] = findBiggID4VMH(metabolite_structure);
[metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
removeErrors = 1;
[metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);

[NUM,TXT,RAW]=xlsread('bigg2metanetx.xlsx');
[metabolite_structure] = addAnnotations(metabolite_structure,RAW);
[metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
removeErrors = 1;
[metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
