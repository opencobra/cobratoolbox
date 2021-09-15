function molCollectionReport = obtainMetStructures(model, metList, outputDir, sources)
% Obtain MDL MOL files from various databases, including KEGG, HMDB, ChEBI,
% and PubChem. Alternatively, openBabel can be used to convert InChI
% strings or SMILES in MDL MOL files.
%
% USAGE:
%
% molCollectionReport = obtainMetStructures(model, mets, sources, standardisationApproach)
%
% INPUTS:
%    model: COBRA model with following fields:
%
%               * .S - The m x n stoichiometric matrix for the metabolic network.
%               * .mets - An m x 1 array of metabolite identifiers.
%               * .metInChIString - An m x 1 array of metabolite identifiers.
%               * .metSmiles - An m x 1 array of metabolite identifiers.
%               * .metVMHID - An m x 1 array of metabolite identifiers.
%               * .metCHEBIID - An m x 1 array of metabolite identifiers.
%               * .metKEGGID - An m x 1 array of metabolite identifiers.
%               * .metPubChemID - An m x 1 array of metabolite identifiers.
%               * .metHMDBID - An m x 1 array of metabolite identifiers.
%
% OPTIONAL INPUTS:
%    mets: List of metabolites to be download (Default: All)
%    outputDir: Directory that will contain the obtained metabolite structures.
%    sources: Sources where the MOL files will be obtained (Default: all).
%             The sources supported are:
%
%               1.- 'inchi' (requires openBabel)
%               2.- 'smiles' (requires openBabel)
%               3.- 'kegg' (https://www.genome.jp/)
%               4.- 'hmdb' (https://hmdb.ca/)
%               5.- 'pubchem' (https://pubchem.ncbi.nlm.nih.gov/)
%               6.- 'chebi' (https://www.ebi.ac.uk/)
%
% OUTPUTS:
%    molCollectionReport: Report of the obtained MDL MOL files
%

if nargin < 2 || isempty(metList)
    metList = unique(regexprep(model.mets, '(\[\w\])', ''));
else
    metList = unique(regexprep(metList, '(\[\w\])', ''));
end
if nargin < 3 || isempty(outputDir)
    outputDir = [pwd filesep];
else
    % Make sure input path ends with directory separator
    outputDir = [regexprep(outputDir,'(/|\\)$',''), filesep];
end
if nargin < 4 || isempty(sources)
    sources = {'VMH'; 'inchi'; 'smiles'; 'kegg'; 'hmdb'; 'pubchem'; 'chebi'};
end
[oBabelInstalled, ~] = system('obabel');

webTimeout = weboptions('Timeout', 60);

% Set directory
newMolFilesDir  = [outputDir 'metabolites' filesep];
if exist(newMolFilesDir, 'dir') == 0
    mkdir(newMolFilesDir)
end

%% Obtain met data

% Obtain ID's
fields = fieldnames(model);
% inchi
inchiFieldBool = ~cellfun(@isempty, regexpi(fields, 'inchi'));
if any(inchiFieldBool)
    inchis = model.(fields{inchiFieldBool});
end
% SMILES
smilesFieldBool = ~cellfun(@isempty, regexpi(fields, 'smiles'));
if any(smilesFieldBool)
    smiles = model.(fields{smilesFieldBool});
end
% HMDB
hmdbFieldBool = ~cellfun(@isempty, regexpi(fields, 'hmdb'));
if any(hmdbFieldBool)
    hmdbIDs = model.(fields{hmdbFieldBool});
end
% KEGG
keggFieldBool = ~cellfun(@isempty, regexpi(fields, 'kegg'));
if any(keggFieldBool)
    if sum(keggFieldBool) > 1
        metFieldBool = ~cellfun(@isempty, regexpi(fields, 'met'));
        keggFieldBool = keggFieldBool & metFieldBool;
    end
    keggIDs = model.(fields{keggFieldBool});
end
% PubChem
PubChemFieldBool = ~cellfun(@isempty, regexpi(fields, 'PubChem'));
if any(PubChemFieldBool)
    PubChemIDs = model.(fields{PubChemFieldBool});
end
% chebi
chebiFieldBool = ~cellfun(@isempty, regexpi(fields, 'chebi'));
if any(chebiFieldBool)
    chebiIDs = model.(fields{chebiFieldBool});
end

%% Obtain met structures

% Unique metabolites idexes
mets = regexprep(model.mets, '(\[\w\])', '');
% umets = model.mets;
% ia = 1:numel(model.mets);

missingMetBool = true(length(metList), 1);
% Obtain MDL MOL files
idsToCheck = {};
for i = 1:length(metList)
    
    % identify met in model
    idx = find(ismember(mets, metList{i}));
    
    % InChI
    if ~isempty(inchis{idx(1)}) && oBabelInstalled && ismember({'inchi'}, sources)
        try
            saveFileDir = [newMolFilesDir 'inchi' filesep];
            if exist(saveFileDir, 'dir') == 0
                mkdir(saveFileDir)
            end
            newFormat = openBabelConverter(inchis{idx(1)}, 'mol', [saveFileDir ...
                metList{i} '.mol']);
            missingMetBool(i) = false;
        catch ME
            disp(ME.message)
            idsToCheck{end + 1, 1} = ['inchi - ' keggIDs{idx(1)}];
        end
    end
    
    % SMILES
    if ~isempty(inchis{idx(1)}) && oBabelInstalled && ismember({'smiles'}, sources)
        try
            saveFileDir = [newMolFilesDir 'smiles' filesep];
            if exist(saveFileDir, 'dir') == 0
                mkdir(saveFileDir)
            end
            newFormat = openBabelConverter(smiles{idx(1)}, 'mol', [saveFileDir ...
                metList{i} '.mol']);
            missingMetBool(i) = false;
        catch ME
            disp(ME.message)
            idsToCheck{end + 1, 1} = ['inchi - ' keggIDs{idx(1)}];
        end
    end
    
    % KEGG
    if ~isempty(keggIDs{idx(1)})  && ismember({'kegg'}, sources)
        saveFileDir = [newMolFilesDir 'kegg' filesep];
        if exist(saveFileDir, 'dir') == 0
            mkdir(saveFileDir)
        end
        try
            switch keggIDs{idx(1)}(1)
                case 'C'
                    molFile = webread(['https://www.genome.jp/dbget-bin/www_bget?-f+m+compound+' keggIDs{idx}], webTimeout);
                case 'D'
                    molFile = webread(['https://www.kegg.jp/dbget-bin/www_bget?-f+m+drug+' keggIDs{idx}], webTimeout);
            end
            if ~isempty(regexp(molFile, 'M  END'))
                fid2 = fopen([newMolFilesDir 'kegg' filesep metList{i} '.mol'], 'w');
                fprintf(fid2, '%s\n', molFile);
                fclose(fid2);
                missingMetBool(i) = false;
            end
        catch ME
            disp(ME.message)
            idsToCheck{end + 1, 1} = ['kegg - ' keggIDs{idx(1)}];
        end
    end
    
    % HMDB
    if ~isempty(hmdbIDs{idx(1)})  && ismember({'hmdb'}, sources)
        saveFileDir = [newMolFilesDir 'hmdb' filesep];
        if exist(saveFileDir, 'dir') == 0
            mkdir(saveFileDir)
        end
        try
            numbersID = hmdbIDs{idx(1)}(5:end);
            if size(numbersID, 2) < 7
                numbersID = [repelem('0', 7 - size(numbersID, 2)) numbersID];
            end
            molFile = webread(['https://hmdb.ca/structures/metabolites/HMDB' numbersID '.mol'], webTimeout);
            if ~isempty(regexp(molFile, 'M  END'))
                fid2 = fopen([newMolFilesDir 'hmdb' filesep metList{i} '.mol'], 'w');
                fprintf(fid2, '%s\n', molFile);
                fclose(fid2);
                missingMetBool(i) = false;
            end
        catch ME
            disp(ME.message)
            idsToCheck{end + 1, 1} = ['hmdb - ' hmdbIDs{idx(1)}];
        end
    end
    %
    %
    %     % hmdb
    %     if ~isempty(hmdbIDs{ia(i)}) && ismember('hmdb', sources)
    %         saveFileDir = [newMolFilesDir 'hmdb' filesep];
    %         if exist(saveFileDir, 'dir') == 0
    %             mkdir(saveFileDir)
    %         end
    %         try
    %             numbersID = hmdbIDs{idx}(5:end);
    %             if size(numbersID, 2) < 7
    %                 numbersID = [repelem('0', 7 - size(numbersID, 2)) numbersID];
    %             end
    %             molFile = webread(['https://hmdb.ca/structures/metabolites/HMDB' numbersID '.mol'], webTimeout);
    %             if ~isempty(regexp(molFile, 'M  END'))
    %                 fid2 = fopen([newMolFilesDir idx '.mol'], 'w');
    %                 fprintf(fid2, '%s\n', molFile);
    %                 fclose(fid2);
    %                 missingMetBool(i) = false;
    %             end
    %         catch ME
    %             disp(ME.message)
    %             idsToCheck(end + 1, 1) = hmdbIDs(ia(i));
    %         end
    %     end
    
    
    % PubChem
    if ~isempty(PubChemIDs{idx(1)})  && ismember({'pubchem'}, sources)
        saveFileDir = [newMolFilesDir 'pubchem' filesep];
        if exist(saveFileDir, 'dir') == 0
            mkdir(saveFileDir)
        end
        try
            molFile = webread(['https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/CID/'...
                num2str(PubChemIDs{idx(1)}) ...
                '/record/SDF/?record_type=2d&response_type=display'], webTimeout);
            if ~isempty(regexp(molFile, 'M  END'))
                molFile(regexp(molFile, 'M  END') + 6:end) = [];
                fid2 = fopen([newMolFilesDir 'pubchem' filesep metList{i} '.mol'], 'w');
                fprintf(fid2, '%s\n', molFile);
                fclose(fid2);
                missingMetBool(i) = false;
            end
        catch ME
            disp(ME.message)
            idsToCheck{end + 1, 1} = ['pubchem - ' PubChemIDs{idx(1)}];
        end
    end
    %
    %
    %             case 6
    %                 if  prod(~isnan(PubChemIDs{ia(i)})) && ~isempty(PubChemIDs{ia(i)}) && missingMetBool(i)
    %                     try
    %                     molFile = webread(['https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/CID/'...
    %                         num2str(PubChemIDs{ia(i)}) ...
    %                         '/record/SDF/?record_type=2d&response_type=display'], webTimeout);
    %                     %         Delete all after 'M  END' from the SDF filte to
    %                     %         make it MOL file
    %                     if ~isempty(regexp(molFile, 'M  END'))
    %                         molFile(regexp(molFile, 'M  END') + 6:end) = [];
    %                         fid2 = fopen([newMolFilesDir umets{i} '.mol'], 'w');
    %                         fprintf(fid2, '%s\n', molFile);
    %                         fclose(fid2);
    %                         missingMetBool(i) = false;
    %                     end
    %                     catch ME
    %                         disp(ME.message)
    %                         idsToCheck(end + 1, 1) = PubChemIDs(ia(i));
    %                     end
    %                 end
    %
    
    % ChEBI
    if ~isempty(chebiIDs{idx(1)})  && ismember({'chebi'}, sources)
        saveFileDir = [newMolFilesDir 'chebi' filesep];
        if exist(saveFileDir, 'dir') == 0
            mkdir(saveFileDir)
        end
        try
            molFile = webread(['https://www.ebi.ac.uk/chebi/saveStructure.do?defaultImage=true&chebiId=' num2str(chebiIDs{idx}) '&imageId=0'], webTimeout);
            if ~isempty(regexp(molFile, 'M  END'))
                fid2 = fopen([newMolFilesDir 'chebi' filesep metList{i} '.mol'], 'w');
                fprintf(fid2, '%s\n', molFile);
                fclose(fid2);
                missingMetBool(i) = false;
            end
        catch ME
            disp(ME.message)
            idsToCheck{end + 1, 1} = ['chebi - ' chebiIDs{idx(1)}];
        end
    end
end

%% Report

% Make report
molCollectionReport.mets = metList;
molCollectionReport.metsWithMol = metList(~missingMetBool);
molCollectionReport.metsWithoutMol = metList(missingMetBool);
molCollectionReport.coverage = (numel(molCollectionReport.metsWithMol) * 100) / numel(molCollectionReport.mets);
molCollectionReport.idsToCheck = idsToCheck;

end