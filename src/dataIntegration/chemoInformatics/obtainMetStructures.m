function molCollectionReport = obtainMetStructures(model, outputDir, updateDB, standardisationApproach, orderOfPreference)
% Obtain MDL MOL files from different database databases such as: KEGG,
% HMDB, ChEBI and PubChem. Or by converting from InChI strings or SMILES
% using openBabel
%
% USAGE:
%
% missingMolFiles = obtainMetStructures(model, outputDir, updateDB, standardisationApproach, orderOfPreference)
%
% INPUTS:
%    model:         COBRA model with following fields:
%
%                       * .S - The m x n stoichiometric matrix for the
%                              metabolic network.
%                       * .mets - An m x 1 array of metabolite identifiers.
%                       * .metInChIString - An m x 1 array of metabolite identifiers.
%                       * .metSmiles - An m x 1 array of metabolite identifiers.
%                       * .metVMHID - An m x 1 array of metabolite identifiers.
%                       * .metCHEBIID - An m x 1 array of metabolite identifiers.
%                       * .metKEGGID - An m x 1 array of metabolite identifiers.
%                       * .metPubChemID - An m x 1 array of metabolite identifiers.
%                       * .metHMDBID - An m x 1 array of metabolite identifiers.
%
% OPTIONAL INPUTS:
%    outputDir:            Path to directory that will contain the MOL files
%                          (default: current directory).
%    updateDB:             Logical value idicating if the database will be
%                          updated or not. If it's true, "outputDir" should
%                          contain an existing database (default: false).
%    standardisationApproach:  String contianing the type of standarization for
%                          the moldecules (default: empty)
%                             * explicitH - Normal chemical graphs.
%                             * implicitH - Hydrogen suppressed chemical
%                                           graphs.
%                             * Neutral   - Chemical graphs with protonated
%                                           molecules.
%                             * basic     - Adding the header.
%    orderOfPreference:    Vector indicating the source of preference
%                          (default: 1:7)
%                          1.- VMH (http://vmh.life/)
%                          2.- InChI (requires openBabel)
%                          3.- Smiles (requires openBabel)
%                          4.- KEGG (https://www.genome.jp/)
%                          5.- HMDB (https://hmdb.ca/)
%                          6.- PubChem (https://pubchem.ncbi.nlm.nih.gov/)
%                          7.- CHEBI (https://www.ebi.ac.uk/)
%
% OUTPUTS:
%    missingMolFiles:      List of missing MOL files
%    nonStandardised:      List of non-standardised MDL MOL file.

if nargin < 2 || isempty(outputDir)
    outputDir = [pwd filesep];
else
    % Make sure input path ends with directory separator
    outputDir = [regexprep(outputDir,'(/|\\)$',''), filesep];
end
if nargin < 3
    updateDB = false;
end
if nargin < 4
    standardisationApproach = [];
end
if nargin < 5
    orderOfPreference = 1:7;
end

[oBabelInstalled, ~] = system('obabel');
webTimeout = weboptions('Timeout', 30);

% Set directories
if exist([outputDir 'newMol'], 'dir') == 0
    mkdir([outputDir 'newMol'])
end
newMolFilesDir  = [outputDir 'newMol' filesep];
if updateDB
    if exist([outputDir 'met' filesep standardisationApproach filesep], 'dir') ~= 0
        modelMets = regexprep(model.mets,'(\[\w\])','');
        fnames = dir([newMolFilesDir '*.mol']);
        model = removeMetabolites(model, model.mets(~ismember(modelMets, setdiff(modelMets, split([fnames(:).name], '.mol')))));
    else
        display('Directory with MOL files was not found to be updated in:')
        display([outputDir 'met' filesep standardisationApproach filesep])
        display('A new database will be created')
    end
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
[umets, ia] = unique(regexprep(model.mets, '(\[\w\])', ''));
% umets = model.mets;
% ia = 1:numel(model.mets);

missingMetBool = true(length(umets), 1);
% Obtain MDL MOL files
idsToCheck = {};
for i = 1:length(umets)
    for j = 1:7
        switch orderOfPreference(j)
            
            case 1
                % VMH
                %                     if prod(~isnan(VMH{metIdxs(i)})) && ~isempty(VMH{metIdxs(i)}) && exist('VMH', 'var') && missing
                %
                %                     end
                
            case 2 % inchi
                if prod(~isnan(inchis{ia(i)})) && ~isempty(inchis{ia(i)}) && oBabelInstalled && missingMetBool(i)
                    try
                        fid2 = fopen([outputDir 'tmp'], 'w');
                        fprintf(fid2, '%s\n', inchis{ia(i)});
                        fclose(fid2);
                        command = ['obabel -iinchi ' outputDir 'tmp -O ' newMolFilesDir umets{i} '.mol mol'];
                        [status, cmdout] = system(command);
                        if contains(cmdout, '1 molecule converted')
                            missingMetBool(i) = false;
                        end
                        delete([outputDir 'tmp'])
                    catch ME
                        disp(ME.message)
                        idsToCheck(end + 1, 1) = inchis(ia(i));
                    end
                end
                
            case 3 % Smiles
                if prod(~isnan(smiles{ia(i)})) && ~isempty(smiles{ia(i)}) && oBabelInstalled && missingMetBool(i)
                    try
                    fid2 = fopen([outputDir 'tmp'], 'w');
                    fprintf(fid2, '%s\n', smiles{ia(i)});
                    fclose(fid2);
                    command = ['obabel -ismi ' outputDir 'tmp -O ' newMolFilesDir umets{i} '.mol mol'];
                    [status,cmdout] = system(command);
                    if status == 0
                        missingMetBool(i) = false;
                    end
                    delete([outputDir 'tmp'])
                    catch ME
                        disp(ME.message)
                        idsToCheck(end + 1, 1) = smiles(ia(i));
                    end
                end
                
            case 4 % KEGG
                if  prod(~isnan(keggIDs{ia(i)})) && ~isempty(keggIDs{ia(i)}) && missingMetBool(i)
                    try
                        switch keggIDs{ia(i)}(1)
                            case 'C'
                                molFile = webread(['https://www.genome.jp/dbget-bin/www_bget?-f+m+compound+' keggIDs{ia(i)}], webTimeout);
                            case 'D'
                                molFile = webread(['https://www.kegg.jp/dbget-bin/www_bget?-f+m+drug+' keggIDs{ia(i)}], webTimeout);
                        end
                        if ~isempty(regexp(molFile, 'M  END'))
                            fid2 = fopen([newMolFilesDir umets{i} '.mol'], 'w');
                            fprintf(fid2, '%s\n', molFile);
                            fclose(fid2);
                            missingMetBool(i) = false;
                        end
                    catch ME
                        disp(ME.message)
                        idsToCheck(end + 1, 1) = keggIDs(ia(i));
                    end
                end
                
            case 5 % HMDB
                if  prod(~isnan(hmdbIDs{ia(i)})) && ~isempty(hmdbIDs{ia(i)}) && missingMetBool(i)
                    try
                        numbersID = hmdbIDs{ia(i)}(5:end);
                        if size(numbersID, 2) < 7
                            numbersID = [repelem('0', 7 - size(numbersID, 2)) numbersID];
                        end
                        molFile = webread(['https://hmdb.ca/structures/metabolites/HMDB' numbersID '.mol'], webTimeout);
                        if ~isempty(regexp(molFile, 'M  END'))
                            fid2 = fopen([newMolFilesDir umets{i} '.mol'], 'w');
                            fprintf(fid2, '%s\n', molFile);
                            fclose(fid2);
                            missingMetBool(i) = false;
                        end
                    catch ME
                        disp(ME.message)
                        idsToCheck(end + 1, 1) = hmdbIDs(ia(i));
                    end
                end
                
            case 6 % PubChem
                if  prod(~isnan(PubChemIDs{ia(i)})) && ~isempty(PubChemIDs{ia(i)}) && missingMetBool(i)
                    try
                    molFile = webread(['https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/CID/'...
                        num2str(PubChemIDs{ia(i)}) ...
                        '/record/SDF/?record_type=2d&response_type=display'], webTimeout);
                    %         Delete all after 'M  END' from the SDF filte to
                    %         make it MOL file
                    if ~isempty(regexp(molFile, 'M  END'))
                        molFile(regexp(molFile, 'M  END') + 6:end) = [];
                        fid2 = fopen([newMolFilesDir umets{i} '.mol'], 'w');
                        fprintf(fid2, '%s\n', molFile);
                        fclose(fid2);
                        missingMetBool(i) = false;
                    end
                    catch ME
                        disp(ME.message)
                        idsToCheck(end + 1, 1) = PubChemIDs(ia(i));
                    end
                end
                
            case 7 % ChEBI
                if  prod(~isnan(chebiIDs{ia(i)})) && ~isempty(chebiIDs{ia(i)}) && missingMetBool(i)
                    try
                    molFile = webread(['https://www.ebi.ac.uk/chebi/saveStructure.do?defaultImage=true&chebiId=' num2str(chebiIDs{ia(i)}) '&imageId=0'], webTimeout);
                    if ~isempty(regexp(molFile, 'M  END'))
                        fid2 = fopen([newMolFilesDir umets{i} '.mol'], 'w');
                        fprintf(fid2, '%s\n', molFile);
                        fclose(fid2);
                        missingMetBool(i) = false;
                    end
                    catch ME
                        disp(ME.message)
                        idsToCheck(end + 1, 1) = chebiIDs(ia(i));
                    end
                end
        end
    end
end

%% Standardise Mol Files

if ~isempty(standardisationApproach)
    
    % Set up directories
    switch standardisationApproach
        case 'explicitH'
            standardisedDir = [outputDir 'explicitH' filesep];
        case 'implicitH'
            standardisedDir = [outputDir 'implicitH' filesep];
        case 'protonated'
            standardisedDir = [outputDir 'protonated' filesep];
        otherwise
            standardisationApproach = 'basic';
            standardisedDir = molDir;
    end
    
    % Standardise files
    umets(missingMetBool) = [];
    standardisationReport = standardiseMolDatabase(tmpDir, umets, standardisedDir, standardisationApproach);
    
    % Get SMILES and InChIs
    if isfield(standardisationReport, 'SMILES')
        SMILES = standardisationReport.SMILES;
    else
        SMILES = '';
    end
    if isfield(standardisationReport, 'InChIs')
        InChIs = standardisationReport.InChIs;
    else
        InChIs = '';
    end
    % Delete empty cells
    InChIs(cellfun(@isempty, InChIs)) = [];
    SMILES(cellfun(@isempty, SMILES)) = [];
    
    if updateDB && ~isempty(InChIs) && ~isempty(SMILES)
        
        % For InChIs
        if isfile([standardisedDir 'InChIs'])
            % Merge old and new InChIs
            InChIsFile = regexp( fileread([standardisedDir 'InChIs']), '\n', 'split')';
            InChIsFile(cellfun(@isempty, InChIsFile)) = [];
            InChIsFileSp = split(InChIsFile, ' - ');
            smilesSp = split(InChIs, ' - ');
            mergedSmiles(:, 2) = unique([InChIsFileSp(:, 2); smilesSp(:, 2)]);
            mergedSmiles(ismember(mergedSmiles(:, 2), smilesSp(:, 2)), 1) = smilesSp(:, 2);
            mergedSmiles(ismember(mergedSmiles(:, 2), InChIsFileSp(:, 2)), 1) = InChIsFileSp(:, 2);
            mergedSmiles = strcat(mergedSmiles(:, 1), {' - '}, mergedSmiles(:, 2));
            % Write InChIs
            fid2 = fopen([standardisedDir 'InChIs'], 'w');
            fprintf(fid2, '%s\n', mergedSmiles{:});
            fclose(fid2);
        else
            % Write InChIs
            fid2 = fopen([standardisedDir 'InChIs'], 'w');
            fprintf(fid2, '%s\n', InChIs{:});
            fclose(fid2);
        end
        
        % For SMILES
        if isfile([standardisedDir 'SMILES'])
            % Merge old and new InChIs
            smilesFile = regexp( fileread([standardisedDir 'SMILES']), '\n', 'split')';
            smilesFile(cellfun(@isempty, smilesFile)) = [];
            smilesFileSp = split(smilesFile, ' - ');
            smilesSp = split(SMILES, ' - ');
            mergedSmiles(:, 2) = unique([smilesFileSp(:, 2); smilesSp(:, 2)]);
            mergedSmiles(ismember(mergedSmiles(:, 2), smilesSp(:, 2)), 1) = smilesSp(:, 2);
            mergedSmiles(ismember(mergedSmiles(:, 2), smilesFileSp(:, 2)), 1) = smilesFileSp(:, 2);
            mergedSmiles = strcat(mergedSmiles(:, 1), {' - '}, mergedSmiles(:, 2));
            % Write InChIs
            fid2 = fopen([standardisedDir 'SMILES'], 'w');
            fprintf(fid2, '%s\n', mergedSmiles{:});
            fclose(fid2);
        else
            % Write InChIs
            fid2 = fopen([standardisedDir 'SMILES'], 'w');
            fprintf(fid2, '%s\n', SMILES{:});
            fclose(fid2);
        end
        
    else
        % Write InChIs
        fid2 = fopen([standardisedDir 'InChIs'], 'w');
        fprintf(fid2, '%s\n', InChIs{:});
        fclose(fid2);
        % Write SMILES
        fid2 = fopen([standardisedDir 'SMILES'], 'w');
        fprintf(fid2, '%s\n', SMILES{:});
        fclose(fid2);
    end
end

%% Report

% Make report
molCollectionReport.noOfMets = size(umets, 1);
molCollectionReport.noOfMetsWithMol = sum(~missingMetBool);
molCollectionReport.noOfMetsWithoutMol = sum(missingMetBool);
molCollectionReport.coverage = (molCollectionReport.noOfMetsWithMol * 100) / molCollectionReport.noOfMets;

% Check standardised data
if ~isempty(standardisationApproach)
    nRows = size(standardisationReport.SMILES, 1);
    varTypes = {'string', 'string', 'string', 'string'};
    varNames = {'mets', 'InChIKeys', 'InChIs', 'SMILES'};
    molCollectionReport.standardisationReport = table('Size', [nRows length(varTypes)], 'VariableTypes', varTypes, 'VariableNames', varNames);
    molCollectionReport.standardisationApproach = standardisationApproach;
    molCollectionReport.standardisationReport(1:end) = standardisationReport.standardised;
    molCollectionReport.standardisationReport.InChIKeys(1:size(standardisationReport.InChIKeys, 1)) = standardisationReport.InChIKeys;
    molCollectionReport.standardisationReport.InChIs(1:size(standardisationReport.InChIs, 1)) = standardisationReport.InChIs;
    molCollectionReport.standardisationReport.SMILES(1:size(standardisationReport.SMILES, 1)) = standardisationReport.SMILES;
end

end