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
%        * .S - The m x n stoichiometric matrix for the metabolic network.
%        * .mets - An m x 1 array of metabolite identifiers.
%        * .metInChIString - An m x 1 array of metabolite identifiers.
%        * .metSmiles - An m x 1 array of metabolite identifiers.
%        * .metVMHID - An m x 1 array of metabolite identifiers.
%        * .metCHEBIID - An m x 1 array of metabolite identifiers.
%        * .metKEGGID - An m x 1 array of metabolite identifiers.
%        * .metPubChemID - An m x 1 array of metabolite identifiers.
%        * .metHMDBID - An m x 1 array of metabolite identifiers.
%        * .metDrugbankID - An m x 1 array of metabolite identifiers.
%        * .metLipidmassID - An m x 1 array of metabolite identifiers.
%
% OPTIONAL INPUTS:
%    mets: List of metabolites to be download (Default: All)
%    outputDir: Directory that will contain the obtained metabolite structures.
%    sources: Sources where the MOL files will be obtained (Default: all).
%             The sources supported are:
%
%        1.- 'inchi' (requires openBabel)
%        2.- 'smiles' (requires openBabel)
%        3.- 'kegg' (https://www.genome.jp/)
%        4.- 'hmdb' (https://hmdb.ca/)
%        5.- 'pubchem' (https://pubchem.ncbi.nlm.nih.gov/)
%        6.- 'chebi' (https://www.ebi.ac.uk/)
%        7.- 'drugbank' (https://go.drugbank.com/)
%        8.- 'lipidmass' (https://www.lipidmaps.org/)
%
% OUTPUTS:
%    molCollectionReport: Report of the obtained MDL MOL files
% 
%        * .metList - List of metabolites to be download
%        * .sources -﻿list of sources of metabolite structures
%        * .structuresObtained -﻿Total of metabolite structures obtained.
%        * .structuresObtainedPerSource -﻿Boolean table with the metabolite 
%               structures obtained by source.
%        * .databaseCoverage -﻿Table indicating the coverage of metabolites 
%               obtained by each of the sources.
%        * .idsToCheck -﻿Id source from which no molecular structures could 
%               be obtained due to a webTimeout, conversion error, or 
%               inconsistent id.

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
    sources = {'chebi'; 'drugbank'; 'hmdb'; 'inchi'; 'kegg'; 'lipidmaps'; 'pubchem'; 'smiles'};
else
    sources = sort(sources);
end
allSources = {'chebi'; 'drugbank'; 'hmdb'; 'inchi'; 'kegg'; 'lipidmaps'; 'pubchem'; 'smiles'};


% Check openbabel installation
if ismac || ispc
    [oBabelInstalled, ~] = system('obabel');
else
    [oBabelInstalled, ~] = system('openbabel.obabel');
end
if oBabelInstalled == 127
    oBabelInstalled = 0;
end

webTimeout = weboptions('Timeout', 60);

% Set directory
newMolFilesDir  = [outputDir 'metabolites' filesep];
if exist(newMolFilesDir, 'dir') == 0
    mkdir(newMolFilesDir)
end

%% Obtain met data

% Obtain ID's
fields = fieldnames(model);

% chebi
chebiFieldBool = ~cellfun(@isempty, regexpi(fields, 'chebi'));
if any(chebiFieldBool)
    chebiIDs = model.(fields{chebiFieldBool});
else
    chebiIDs = cell(size(model.mets));
end

% drugbank
drugbankFieldBool = ~cellfun(@isempty, regexpi(fields, 'drugbank'));
if any(drugbankFieldBool)
    drugbankIDs = model.(fields{drugbankFieldBool});
else
    drugbankIDs = cell(size(model.mets));
end

% HMDB
hmdbFieldBool = ~cellfun(@isempty, regexpi(fields, 'hmdb'));
if any(hmdbFieldBool)
    hmdbIDs = model.(fields{hmdbFieldBool});
end

% inchi
inchiFieldBool = ~cellfun(@isempty, regexpi(fields, 'inchi'));
if any(inchiFieldBool)
    inchis = model.(fields{inchiFieldBool});
else
    inchis = cell(size(model.mets));
end

% KEGG
keggFieldBool = ~cellfun(@isempty, regexpi(fields, 'kegg'));
if any(keggFieldBool)
    if sum(keggFieldBool) > 1
        metFieldBool = ~cellfun(@isempty, regexpi(fields, 'met'));
        keggFieldBool = keggFieldBool & metFieldBool;
    end
    keggIDs = model.(fields{keggFieldBool});
else
    keggIDs = cell(size(model.mets));
end

% lipidmaps
lipidmapsFieldBool = ~cellfun(@isempty, regexpi(fields, 'lipidmaps'));
if any(lipidmapsFieldBool)
    lipidmapsIDs = model.(fields{lipidmapsFieldBool});
else
    lipidmapsIDs = cell(size(model.mets));
end

% PubChem
PubChemFieldBool = ~cellfun(@isempty, regexpi(fields, 'PubChem'));
if any(PubChemFieldBool)
    PubChemIDs = model.(fields{PubChemFieldBool});
else
    PubChemIDs = cell(size(model.mets));
end

% SMILES
smilesFieldBool = ~cellfun(@isempty, regexpi(fields, 'smiles'));
if any(smilesFieldBool)
    smiles = model.(fields{smilesFieldBool});
else
    smiles = cell(size(model.mets));
end

%% Obtain met structures

% Unique metabolites idexes
mets = regexprep(model.mets, '(\[\w\])', '');

% Obtain MDL MOL files
idsToCheck = {};
[inchiMsg, smilesMsg] = deal(true);
idMatrix = false(length(metList), length(allSources));
for i = 1:length(metList)
    
    % identify met in model and start matrix counter
    idx = find(ismember(mets, metList{i}));
    matrixCounter = 0;
    
    % ChEBI
    if ~isempty(chebiIDs{idx(1)})  && ismember({'chebi'}, sources)
        saveFileDir = [newMolFilesDir 'chebi' filesep];
        try
            molFile = webread(['https://www.ebi.ac.uk/chebi/saveStructure.do?defaultImage=true&chebiId=' num2str(chebiIDs{idx(1)}) '&imageId=0'], webTimeout);
            if ~isempty(regexp(molFile, 'M  END'))
                if exist(saveFileDir, 'dir') == 0
                    mkdir(saveFileDir)
                end
                fid2 = fopen([newMolFilesDir 'chebi' filesep metList{i} '.mol'], 'w');
                fprintf(fid2, '%s\n', molFile);
                fclose(fid2);
                idMatrix(i, 1) = true;
            end
        catch ME
            disp(ME.message)
            idsToCheck{end + 1, 1} = ['chebi - ' chebiIDs{idx(1)}];
        end
    end
    
    % drugbank
    if ~isempty(drugbankIDs{idx(1)})  && ismember({'drugbank'}, sources)
        saveFileDir = [newMolFilesDir 'drugbank' filesep];
        try
            if contains(drugbankIDs{idx(1)}, 'MET')
                molFile = webread(['https://go.drugbank.com/structures/metabolites/' num2str(drugbankIDs{idx(1)}) '.mol'], webTimeout);
            else
                molFile = webread(['https://go.drugbank.com/structures/small_molecule_drugs/' num2str(drugbankIDs{idx(1)}) '.mol'], webTimeout);
            end
            if ~isempty(regexp(molFile, 'M  END'))
                if exist(saveFileDir, 'dir') == 0
                    mkdir(saveFileDir)
                end
                fid2 = fopen([newMolFilesDir 'drugbank' filesep metList{i} '.mol'], 'w');
                fprintf(fid2, '%s\n', molFile);
                fclose(fid2);
                idMatrix(i, 2) = true;
            end
        catch ME
            disp(ME.message)
            idsToCheck{end + 1, 1} = ['drugbank - ' drugbankIDs{idx(1)}];
        end
    end
    
    % HMDB
    if ~isempty(hmdbIDs{idx(1)})  && ismember({'hmdb'}, sources)
        saveFileDir = [newMolFilesDir 'hmdb' filesep];
        try
            numbersID = hmdbIDs{idx(1)}(5:end);
            if size(numbersID, 2) < 7
                numbersID = [repelem('0', 7 - size(numbersID, 2)) numbersID];
            end
            molFile = webread(['https://hmdb.ca/structures/metabolites/HMDB' numbersID '.mol'], webTimeout);
            if ~isempty(regexp(molFile, 'M  END'))
                if exist(saveFileDir, 'dir') == 0
                    mkdir(saveFileDir)
                end
                fid2 = fopen([newMolFilesDir 'hmdb' filesep metList{i} '.mol'], 'w');
                fprintf(fid2, '%s\n', molFile);
                fclose(fid2);
                idMatrix(i, 3) = true;
            end
        catch ME
            disp(ME.message)
            idsToCheck{end + 1, 1} = ['hmdb - ' hmdbIDs{idx(1)}];
        end
    end
    
    % InChI
    if ~isempty(inchis{idx(1)}) && ismember({'inchi'}, sources)
        if oBabelInstalled
            try
                saveFileDir = [newMolFilesDir 'inchi' filesep];
                if exist(saveFileDir, 'dir') == 0
                    mkdir(saveFileDir)
                end
                newFormat = openBabelConverter(inchis{idx(1)}, 'mol', [saveFileDir ...
                    metList{i} '.mol']);
                idMatrix(i, 4) = true;
            catch ME
                disp(ME.message)
                idsToCheck{end + 1, 1} = ['inchi - ' keggIDs{idx(1)}];
            end
        elseif inchiMsg && ~oBabelInstalled
            inchiMsg = false;
            display('OpenBabel is not isntalled to convert InChIs')
        end
    end
    
    % KEGG
    if ~isempty(keggIDs{idx(1)})  && ismember({'kegg'}, sources)
        saveFileDir = [newMolFilesDir 'kegg' filesep];
        try
            switch keggIDs{idx(1)}(1)
                case 'C'
                    molFile = webread(['https://www.genome.jp/dbget-bin/www_bget?-f+m+compound+' keggIDs{idx(1)}], webTimeout);
                case 'D'
                    molFile = webread(['https://www.kegg.jp/dbget-bin/www_bget?-f+m+drug+' keggIDs{idx(1)}], webTimeout);
            end
            if ~isempty(regexp(molFile, 'M  END'))
                if exist(saveFileDir, 'dir') == 0
                    mkdir(saveFileDir)
                end
                fid2 = fopen([newMolFilesDir 'kegg' filesep metList{i} '.mol'], 'w');
                fprintf(fid2, '%s\n', molFile);
                fclose(fid2);
                idMatrix(i, 5) = true;
            end
        catch ME
            disp(ME.message)
            idsToCheck{end + 1, 1} = ['kegg - ' keggIDs{idx(1)}];
        end
    end
    
    % lipidmaps
    if ~isempty(lipidmapsIDs{idx(1)})  && ismember({'lipidmaps'}, sources)
        saveFileDir = [newMolFilesDir 'lipidmaps' filesep];
        try
            molFile = webread(['https://www.lipidmaps.org/databases/lmsd/' num2str(lipidmapsIDs{idx(1)}) '?format=mdlmol'], webTimeout);
            if ~isempty(regexp(molFile, 'M  END'))
                if exist(saveFileDir, 'dir') == 0
                    mkdir(saveFileDir)
                end
                fid2 = fopen([newMolFilesDir 'lipidmaps' filesep metList{i} '.mol'], 'w');
                fprintf(fid2, '%s\n', molFile);
                fclose(fid2);
                idMatrix(i, 6) = true;
            end
        catch ME
            disp(ME.message)
            idsToCheck{end + 1, 1} = ['lipidmaps - ' lipidmapsIDs{idx(1)}];
        end
    end
    
    % PubChem
    if ~isempty(PubChemIDs{idx(1)})  && ismember({'pubchem'}, sources)
        saveFileDir = [newMolFilesDir 'pubchem' filesep];
        try
            molFile = webread(['https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/CID/'...
                num2str(PubChemIDs{idx(1)}) ...
                '/record/SDF/?record_type=2d&response_type=display'], webTimeout);
            if ~isempty(regexp(molFile, 'M  END'))
                if exist(saveFileDir, 'dir') == 0
                    mkdir(saveFileDir)
                end
                molFile(regexp(molFile, 'M  END') + 6:end) = [];
                fid2 = fopen([newMolFilesDir 'pubchem' filesep metList{i} '.mol'], 'w');
                fprintf(fid2, '%s\n', molFile);
                fclose(fid2);
                idMatrix(i, 7) = true;
            end
        catch ME
            disp(ME.message)
            idsToCheck{end + 1, 1} = ['pubchem - ' PubChemIDs{idx(1)}];
        end
    end
    
    % SMILES
    if ~isempty(inchis{idx(1)}) && ismember({'smiles'}, sources)
        if oBabelInstalled
            try
                saveFileDir = [newMolFilesDir 'smiles' filesep];
                if exist(saveFileDir, 'dir') == 0
                    mkdir(saveFileDir)
                end
                newFormat = openBabelConverter(smiles{idx(1)}, 'mol', [saveFileDir ...
                    metList{i} '.mol']);
                idMatrix(i, 8) = true;
            catch ME
                disp(ME.message)
                idsToCheck{end + 1, 1} = ['inchi - ' keggIDs{idx(1)}];
            end
        elseif smilesMsg && ~oBabelInstalled
            smilesMsg = false;
            display('OpenBabel is not isntalled to convert SMILES')
        end
    end
end

%% Report

% Delete databases not included
idMatrix(:, ~ismember(allSources, sources)) = [];

% molCollectionReport
molCollectionReport.metList = metList;
molCollectionReport.sources = sources;
molCollectionReport.structuresObtained = sum(any(idMatrix'));

% Structures obtained
nRows = size(idMatrix, 1);
varTypes = ['string', repmat({'logical'}, 1, size(idMatrix, 2))];
varNames = ['mets'; sources];
structuresObtainedPerSource = table('Size', [nRows length(varTypes)], 'VariableTypes', varTypes, 'VariableNames', varNames);
structuresObtainedPerSource.mets = metList;
for i = 1:length(sources)
    structuresObtainedPerSource.(sources{i}) = idMatrix(:, i);
end
molCollectionReport.structuresObtainedPerSource = structuresObtainedPerSource;

% Database coverage table
[nCols nRows] = size(idMatrix);
varTypes = {'string', 'double', 'double', 'double'};
varNames = {'sources', 'coverage', 'metsWithStructure', 'metsWithoutStructure'};
databaseCoverage = table('Size', [nRows length(varTypes)], 'VariableTypes', varTypes, 'VariableNames', varNames);
databaseCoverage.sources = sources;

%if size(idMatrix, 2)> 0
%    databaseCoverage.metsWithStructure = sum(idMatrix)';
%    databaseCoverage.metsWithoutStructure = sum(~idMatrix)';
%    databaseCoverage.coverage = round((databaseCoverage.metsWithStructure * 100) / size(idMatrix, 1), 2);
%    molCollectionReport.databaseCoverage = databaseCoverage;
%end

if nCols > 1
    databaseCoverage.metsWithStructure = sum(idMatrix)';
    databaseCoverage.metsWithoutStructure = sum(~idMatrix)';
else
    databaseCoverage.metsWithStructure = double(idMatrix)';
    databaseCoverage.metsWithoutStructure = double(~idMatrix)';
end
databaseCoverage.coverage = round((databaseCoverage.metsWithStructure * 100) / size(idMatrix, 1), 2);
molCollectionReport.databaseCoverage = databaseCoverage;

molCollectionReport.idsToCheck = idsToCheck;
if ~isempty(idsToCheck)
    disp('The following structures could not be obtained')
    disp(idsToCheck)
end
end
