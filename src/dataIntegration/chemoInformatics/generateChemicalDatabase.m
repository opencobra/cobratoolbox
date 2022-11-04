function [report, modelOut] = generateChemicalDatabase(model, options)
% This function uses the metabolite identifiers in the model to compare
% them and save the identifiers with the best score in MDL MOL format
% and/or inchi and simles and jpeg if it's installed cxcalc and openBabel.
% The obtained MDL MOL files will serve as the basis for creating the MDL
% RXN files that represent a metabolic reaction and can only be written if
% there is a MDL MOL file for each metabolite in a metabolic reaction.
% If JAVA is installed, it also atom maps the metabolic reactions
% with an MDL RXN file.
%
% USAGE:
%
%    [info, modelOut] = generateChemicalDatabase(model, options)
%
% INPUTS:
%    model:	COBRA model with following fields:
%
%           * .S - The m x n stoichiometric matrix for the metabolic network.
%           * .rxns - An n x 1 array of reaction identifiers.
%           * .mets - An m x 1 array of metabolite identifiers.
%           * .metFormulas - An m x 1 array of metabolite chemical formulas.
%           * .metinchi - An m x 1 array of metabolite identifiers.
%           * .metsmiles - An m x 1 array of metabolite identifiers.
%           * .metKEGG - An m x 1 array of metabolite identifiers.
%           * .metHMDB - An m x 1 array of metabolite identifiers.
%           * .metPubChem - An m x 1 array of metabolite identifiers.
%           * .metCHEBI - An m x 1 array of metabolite identifiers.
%
%    options:  A structure containing all the arguments for the function:
%
%           * .resultsDir: The path to the directory containing the RXN files
%                   with atom mappings (default: current directory)
%           * .printlevel: Verbose level
%           * .standardisationApproach: String containing the type of standardisation
%                   for the molecules (default: 'explicitH' if openBabel is 
%                   installed, otherwise default: 'basic'):
%                    'explicitH' Normal chemical graphs;
%                    'implicitH' Hydrogen suppressed chemical graph;
%                    'basic' Update the header.
%           * .keepMolComparison: Logic value for comparing MDL MOL files
%                   from various sources (default: FALSE)
%           * .atomMapping: Logic value to decide on atom mapping. If false, it will generate only unmapped MDL RXN files (default: TRUE).
%           * .bonds: Logic value to decide on computing bond enthalpy and bonds broken and formed (default: TRUE) (only if atomMapping = 1);
%           * .adjustToModelpH: Logic value used to determine whether a molecule's
%                   pH must be adjusted in accordance with the COBRA model.  
%                   TRUE, requires MarvinSuite).
%           * .dirsToCompare: Cell(s) with the path to directory to an 
%                   existing database (default: empty).
%           * .dirNames: Cell(s) with the name of the directory(ies) (default: empty).
%           * .debug: Logical value used to determine whether or not the results 
%                   of different points in the function will be saved for 
%                   debugging (default: empty).
%
% OUTPUTS:
% modelOut: A new model with the following additional fields
%           * .metAtomMappedBool:  `m x 1` boolean vector indicating atom mapped metabolites
%           * .rxnAtomMappedBool:  `n x 1` boolean vector indicating atom mapped reactions
%           * .comparison:      
%           * .standardisation:
%           * .bondsBF: Number of bonds broken and formed in each reaction, if options.bonds = true.
%           * .bondsE:  Estimated bond enthalpies for each metabolic reaction, if options.bonds = true.      
%
%
% report:     A report of the database generation process
%
% .. Authors: - German Preciat, Ronan Fleming 2022.

if ~isfield(options, 'resultsDir')
    resultsDir = [pwd filesep];
else
    % Make sure results path ends with directory separator
    resultsDir = [regexprep(options.resultsDir,'(/|\\)$',''), filesep];
end

ctfPath = which('metaboliteIDcrossMapping.txt');
if contains(ctfPath,'not found')
    error('git clone https://github.com/opencobra/ctf /your/path/ctf \n Then addpath(/your/path/ctf) in matlab')
else
    ctfPath = strrep(ctfPath,[filesep 'metaboliteIDcrossMapping.txt'],'');
end

%% 1. Initialise data and set default variables
metResultsDir = [resultsDir 'mets'];
rxnResultsDir = [resultsDir 'rxns'];

if ~isfield(options, 'debug')
    options.debug = 0;
end
if ~isfield(options, 'printlevel')
    options.printlevel = 1;
end

% molecular identifiers options
if ~isfield(options, 'standardisationApproach')
    options.standardisationApproach = 'basic';
end
if ~isfield(options, 'keepMolComparison')
    options.keepMolComparison = 0;
end
if ~isfield(options, 'adjustToModelpH')
    options.adjustToModelpH = 0;
end

% atom mapping options
if ~isfield(options, 'atomMapping')
    options.atomMapping = 1;
end

if ~isfield(options, 'bonds')
    options.bonds = 1;
end
if ~isfield(options,'replaceExistingAtomMappings')
    options.replaceExistingAtomMappings = 0;
end

if isfield(options, 'dirsToCompare')
    dirsToCompare = true;
    if ischar(options.dirsToCompare)
        options.dirsToCompare={options.dirsToCompare};
    end
    for i = 1:length(options.dirsToCompare)
        options.dirsToCompare{i} = [regexprep(options.dirsToCompare{i},'(/|\\)$',''), filesep];
        if ~isfolder(options.dirsToCompare)
            disp([options.dirsToCompare{i} ' is not a directory'])
            options.dirsToCompare{i} = [];
        end
    end
    if ~isfield(options, 'dirNames')
        for i = 1:length(options.dirsToCompare)
            options.dirNames{i, 1} = ['localDir' num2str(i)];
        end
    else
        if isrow(options.dirNames)
            options.dirNames = options.dirNames';
        end
    end
else
   options.dirsToCompare = [ctfPath filesep 'mets' filesep 'molFiles'];
   options.dirNames = {'VMH'};
end

[cxcalcInstalled,oBabelInstalled,javaInstalled ] = checkChemoinformaticDependencies;

if cxcalcInstalled == 0
    cxcalcInstalled = false;
    disp('cxcalc is not installed, two features cannot be used: ')
    disp('1 - jpeg files for molecular structures (obabel required)')
    disp('2 - pH adjustment according to model.met Formulas')
end

if oBabelInstalled ~= 1
    oBabelInstalled = false;
    options.standardisationApproach = 'basic';
    disp('obabel is not installed, two features cannot be used: ')
    disp('1 - Generation of SMILES, InChI and InChIkey')
    disp('2 - MOL file standardisation')
end

if javaInstalled ~= 1 && options.atomMapping
    disp('java is not installed, atom mappings cannot be computed')
    options.atomMapping = 0;
end

% Start diary
if ~isfolder(resultsDir)
    mkdir(resultsDir);
end
diaryFilename = [resultsDir datestr(now,30) '_DatabaseDiary.txt'];
diary(diaryFilename)

if options.printlevel > 0
    disp('--------------------------------------------------------------')
    disp('CHEMICAL DATABASE')
    disp('--------------------------------------------------------------')
    disp(' ')
    fprintf('%s\n', 'Generating a chemical database with the following options:')
    disp(' ')
    disp(options)
    disp('--------------------------------------------------------------')
end

directories = {'chebi'; 'drugbank'; 'hmdb'; 'inchi'; 'kegg'; 'lipidmaps'; 'pubchem'; 'smiles'};
if dirsToCompare
    directories = [directories; options.dirNames];
end

mets = regexprep(model.mets, '(\[\w\])', '');
umets = unique(mets);

%% 2. Obtain metabolite structures from different sources

% SOURCES
% 1.- InChI (requires openBabel to obtain MOL file)
% 2.- Smiles (requires openBabel to obtain MOL file)
% 3.- KEGG (https://www.genome.jp/)
% 4.- HMDB (https://hmdb.ca/)
% 5.- PubChem (https://pubchem.ncbi.nlm.nih.gov/)
% 6.- CHEBI (https://www.ebi.ac.uk/)
% 7.- DrugBank (https://go.drugbank.com/)
% 8.- LipidMass (https://www.lipidmaps.org/)

if options.printlevel > 0
    fprintf('%s\n\n', 'Obtaining MOL files from chemical databases ...')
end
%    model: COBRA model
%    mets: List of metabolites to be download (Default: All)
%    metResultsDir: Directory that will contain the obtained metabolite structures.

[molCollectionReport, newMolFilesDir] = obtainMetStructures(model, model.mets, metResultsDir);

if dirsToCompare
    molCollectionReport.sources = [molCollectionReport.sources; options.dirNames];
    newIdx = length(molCollectionReport.sources);
    for i = 1:length(options.dirsToCompare)
        d = dir([options.dirsToCompare{i} '*.mol']);
        molCollectionReport.structuresObtainedPerSource.(options.dirNames{i}) = ismember(umets, regexprep({d.name}, '.mol', ''));
        databaseCoverage = table;
        databaseCoverage.sources = options.dirNames{i};
        databaseCoverage.coverage = (sum(ismember(umets, regexprep({d.name}, '.mol', ''))) * 100) / length(umets);
        databaseCoverage.metsWithStructure = sum(ismember(umets, regexprep({d.name}, '.mol', '')));
        databaseCoverage.metsWithoutStructure = sum(~ismember(umets, regexprep({d.name}, '.mol', '')));
        molCollectionReport.databaseCoverage = [molCollectionReport.databaseCoverage; databaseCoverage];
        molCollectionReport.structuresObtained = max([molCollectionReport.structuresObtained; sum(ismember(umets, regexprep({d.name}, '.mol', '')))]);
    end
end
report.molCollectionReport = molCollectionReport;

if options.printlevel > 0
    disp(molCollectionReport.databaseCoverage)
end

% Remove sources without a single metabolite present the model
for i = length(directories):-1:1
    if molCollectionReport.databaseCoverage.coverage(i) == 0
        directories(i) = [];
    end
end

if options.debug
    save([resultsDir '2.debug_beforeGeneratingInChIandSMILES.mat'])
end

%% 3. Compare MOL files downloaded and save the best match

if options.printlevel > 0
    fprintf('%s\n', 'Comparing information from sources ...')
end

% Generate a table with Inchis
for i = 1:size(directories, 1)
    
    % Set dir
    if i > 6 && dirsToCompare
        sourceDir = options.dirsToCompare{i - 6};
    else
        sourceDir = [newMolFilesDir filesep directories{i} filesep];
    end
    
    % Get list of MOL files
    d = dir(sourceDir);
    d = d(~[d.isdir]);
    metList = {d.name}';
    metList = metList(~cellfun('isempty', regexp(metList,'(\.mol)$')));
    metList = regexprep(metList, '.mol', '');
    metList(~ismember(metList, mets)) = [];
    
    warning('off')
    for j = 1:size(metList, 1)
        name = [metList{j} '.mol'];
        
        if oBabelInstalled
            if isunix || ispc
                obabelCommand = 'obabel';
            else
                obabelCommand = 'openbabel.obabel';
            end
            % Get inchis of the original metabolites
            command = [obabelCommand ' -imol ' sourceDir name ' -oinchi '];
            [~, result] = system(command);
            result = split(result);
            
            % Group inchis in the correct group
            if any(~cellfun(@isempty, regexp(result, 'InChI=1S')))
                
                % Create InChI table
                if ~exist('groupedInChIs','var')
                    groupedInChIs = table();
                end
                % Identify the correct index
                if ~ismember('mets', groupedInChIs.Properties.VariableNames)
                    groupedInChIs.mets{j} = regexprep(name, '.mol', '');
                    idx = 1;
                elseif ~ismember(regexprep(name, '.mol', ''), groupedInChIs.mets)
                    idx = size(groupedInChIs.mets, 1) + 1;
                    groupedInChIs.mets{idx} = regexprep(name, '.mol', '');
                else
                    idx = find(ismember(groupedInChIs.mets, regexprep(name, '.mol', '')));
                end
                % Save inchi in the table
                groupedInChIs.(directories{i}){idx} = result{~cellfun(@isempty, regexp(result, 'InChI=1S'))};
                
            else
                
                % Create SMILES table for molecules with R groups
                if ~exist('groupedSMILES','var')
                    groupedSMILES = table();
                end
                % Identify the correct index
                if ~ismember('mets', groupedSMILES.Properties.VariableNames)
                    groupedSMILES.mets{1} = regexprep(name, '.mol', '');
                    idx = 1;
                elseif ~ismember(regexprep(name, '.mol', ''), groupedSMILES.mets)
                    idx = size(groupedSMILES.mets, 1) + 1;
                    groupedSMILES.mets{idx} = regexprep(name, '.mol', '');
                else
                    idx = find(ismember(groupedSMILES.mets, regexprep(name, '.mol', '')));
                end
                % Get SMILES
                command = [obabelCommand ' -imol ' sourceDir name ' -osmiles '];
                [~, result] = system(command);
                if contains(result, '0 molecules converted')
                    continue
                end
                result = splitlines(result);
                result = split(result{end - 2});
                % Save SMILES in the table
                groupedSMILES.(directories{i}){idx} = result{1};
                
            end
            
        else
            
            % Create SMILES table for molecules with R groups
            if ~exist('groupedFormula','var')
                groupedFormula = table();
            end
            % Identify the correct index
            if ~ismember('mets', groupedFormula.Properties.VariableNames)
                groupedFormula.mets{1} = regexprep(name, '.mol', '');
                idx = 1;
            elseif ~ismember(regexprep(name, '.mol', ''), groupedFormula.mets)
                idx = size(groupedFormula.mets, 1) + 1;
                groupedFormula.mets{idx} = regexprep(name, '.mol', '');
            else
                idx = find(ismember(groupedFormula.mets, regexprep(name, '.mol', '')));
            end
            % Get formula from MOL
            molFile = regexp(fileread([sourceDir name]), '\n', 'split')';
            atomsString = [];
            for k = 1:str2num(molFile{4}(1:3))
                atomsString = [atomsString strtrim(molFile{4 + k}(32:33))];
            end
            groupedFormula.(directories{i}){idx} = ['InChI=1/' editChemicalFormula(atomsString)];
            
        end
    end
    warning('on')
end

if options.debug
    save([resultsDir '3a.debug_beforeComparison.mat'])
end

if exist('groupedSMILES', 'var')
    
    % Replace R groups to hydrogens to convert them to inchis
    groupedInChIs2 = groupedSMILES;
    sourcesSmiles = groupedSMILES.Properties.VariableNames(2:end);
    for i = 1:length(groupedSMILES.mets)
        for j = 1:length(sourcesSmiles)
            if ~isempty(groupedSMILES.(sourcesSmiles{j}){i})
                fid2 = fopen([resultsDir 'tmp'], 'w');
                fprintf(fid2, '%s\n', groupedSMILES.(sourcesSmiles{j}){i});
                fclose(fid2);
                command = [obabelCommand ' -ismi tmp -O tmp.mol mol -h'];
                [~, ~] = system(command);
                molFile = regexp(fileread([resultsDir 'tmp.mol']), '\n', 'split')';
                molFile = regexprep(molFile, 'X|Y|*|R|A', 'H');
                fid2 = fopen([resultsDir filesep 'tmp.mol'], 'w');
                fprintf(fid2, '%s\n', molFile{:});
                fclose(fid2);
                % Get inchis of the original metabolites
                command = [obabelCommand ' -imol ' resultsDir 'tmp.mol -oinchi'];
                [~, result] = system(command);
                result = split(result);
                groupedInChIs2.(sourcesSmiles{j})(i) = result(contains(result, 'InChI=1S'));
            end
        end
    end
    
    % Merge groupedInChIs and groupedInChIs2; some sources use non-chemical
    % atoms (R grups in the SMILES) to represent metabolites and some sources
    % don't
    startFrom = length(groupedInChIs.mets);
    warning('off')
    for i = 1:length(groupedInChIs2.mets)
        metPresenceBool = ismember(groupedInChIs.mets, groupedInChIs2.mets(i));
        if any(metPresenceBool)
            idx = find(metPresenceBool);
        else
            idx = length(groupedInChIs.mets) + 1;
            groupedInChIs.mets(idx) = groupedInChIs2.mets(i);
        end
        for j = 1:length(sourcesSmiles)
            if ~isempty(groupedInChIs2.(sourcesSmiles{j}){i})
                groupedInChIs.(sourcesSmiles{j})(idx) = groupedInChIs2.(sourcesSmiles{j})(i);
            end
        end
    end
    warning('on')
end

if exist('groupedFormula', 'var')
    groupedInChIs = groupedFormula;
end

% Compare InChI data
report.sourcesComparison.sources(:, 1) = groupedInChIs.Properties.VariableNames(2:end);
for i = 1:length(groupedInChIs.mets)
    comparisonTable = compareInchis(model, groupedInChIs{i, 2:end}, ...
        groupedInChIs.mets{i});
    report.sourcesComparison.mets{i, 1} = groupedInChIs.mets{i};
    report.sourcesComparison.comparisonMatrix(i, :) = comparisonTable.scores;
    chagreAccuracy = unique( comparisonTable.chargeOkBool(comparisonTable.scores == ...
        max(comparisonTable.scores)));
    report.sourcesComparison.chargeOkBool(i, 1) = chagreAccuracy(1);
    metFormula = comparisonTable.metFormula(comparisonTable.scores == max(comparisonTable.scores));
    if any(ismissing(metFormula))
        metFormula = '';
    else
        metFormula = unique(metFormula);
    end
    report.sourcesComparison.metFormula(i, 1) = metFormula(1);
    report.sourcesComparison.(['met_' groupedInChIs.mets{i}]) = comparisonTable;
end

% Create a comparison table
bestScores = max(report.sourcesComparison.comparisonMatrix');
report.sourcesComparison.comparisonTable = table;
warning('off')
for i = 1:length(report.sourcesComparison.mets)
    report.sourcesComparison.comparisonTable.mets{i} = report.sourcesComparison.mets{i};
    bestDir = directories(find(report.sourcesComparison.comparisonMatrix(i, :) == bestScores(i)));
    report.sourcesComparison.comparisonTable.source{i} = strjoin(bestDir, ' ');
    report.sourcesComparison.comparisonTable.score(i) = bestScores(i);
    report.sourcesComparison.comparisonTable.inchi{i} = groupedInChIs.(bestDir{1}){i};
end
report.sourcesComparison.comparisonTable.chargeOkBool = report.sourcesComparison.chargeOkBool;
report.sourcesComparison.comparisonTable.metFormula = report.sourcesComparison.metFormula;
warning('on')

% Print data
if options.printlevel > 0
    
    disp(report.sourcesComparison.comparisonTable)
    
    % Sources comparison
    [db, ~, idx] = unique(split(strjoin(report.sourcesComparison.comparisonTable.source, ' '), ' '));
    [~, ib1] = ismember(directories, db);
    timesMatched = histcounts(idx, size(db, 1));
    bar(timesMatched(ib1)')
    title({'Sources comparison', ...
        ['Metabolites collected: ' num2str(size(report.sourcesComparison.comparisonTable, 1))]}, 'FontSize', 16)
    directoriesLabels = regexprep(db, 'chebi', 'ChEBI');
    directoriesLabels = regexprep(directoriesLabels, 'hmdb', 'HMDB');
    directoriesLabels = regexprep(directoriesLabels, 'inchi', 'InChIs');
    directoriesLabels = regexprep(directoriesLabels, 'kegg', 'KEGG');
    directoriesLabels = regexprep(directoriesLabels, 'pubchem', 'PubChem');
    directoriesLabels = regexprep(directoriesLabels, 'smiles','SMILES');
    set(gca, 'XTick', 1:size(db, 1), 'xticklabel', directoriesLabels(ib1), 'FontSize', 16)
    metsObtained = fieldnames(report.sourcesComparison);
    metsObtained = metsObtained(contains(metsObtained, 'met_'));
    [sterochemicalCounter, chargeCounter, formulaOk, noId] = deal(zeros(numel(directories), 1));
    for i = 1:length(metsObtained)
        formulaOk = formulaOk + report.sourcesComparison.(metsObtained{i}).formulaOkBool;
        chargeCounter = chargeCounter + report.sourcesComparison.(metsObtained{i}).chargeOkBool;
        sterochemicalCounter = sterochemicalCounter + report.sourcesComparison.(metsObtained{i}).stereochemicalSubLayers;
        noId = noId + cellfun(@isempty,report.sourcesComparison.(metsObtained{i}).InChI);
    end
    hold on
    plot(formulaOk, 'r', 'LineWidth', 3)
    plot(chargeCounter, 'g', 'LineWidth', 3)
    plot(sterochemicalCounter, 'm', 'LineWidth', 3)
    plot(noId, 'y', 'LineWidth', 3)
    hold off
    legend({'Highest score', 'Formula agree', 'Charge agree', 'Sterochemistry', 'No ids'}, 'Location', 'best')

    if options.printlevel > 1
        disp(groupedInChIs)
    end
    
end

% Save the MOL files with highest score
tmpDir = [metResultsDir filesep 'tmp'];
if ~isfolder(tmpDir)
    mkdir(tmpDir)
end
for i = 1:length(report.sourcesComparison.comparisonTable.mets)
    metName = report.sourcesComparison.comparisonTable.mets{i};
    dirToCopy = split(report.sourcesComparison.comparisonTable.source{i});
    if isfield(options, 'dirNames') && any(ismember(dirToCopy{1}, options.dirNames))
        copyfile([options.dirsToCompare{ismember(options.dirNames, dirToCopy{1})} metName '.mol'], tmpDir)
    else
        copyfile([newMolFilesDir filesep dirToCopy{1} filesep metName '.mol'], tmpDir)
    end
end
if ~options.keepMolComparison
    rmdir(newMolFilesDir, 's')
end
if ~options.adjustToModelpH || ~cxcalcInstalled
    model.comparison = report.sourcesComparison.comparisonTable;
end
if options.debug
    save([resultsDir '3b.debug_beforeaAjustToModelpH.mat'])
end

%% 4. Adjust pH based on the model's chemical formula

if options.adjustToModelpH && cxcalcInstalled
    
    report.adjustedpHTable = report.sourcesComparison.comparisonTable;
    
    if options.printlevel > 0
        fprintf('%s\n', 'Adjusting pH based on the model''s chemical formula ...')
        disp(' ')
    end
    
    [needAdjustmentBool, differentFormula, loopError, pHRangePassed] = ...
        deal(false(size(report.sourcesComparison.comparisonTable, 1), 1));
    for i = 1:length(report.adjustedpHTable.mets)
        try
            
            name = [report.adjustedpHTable.mets{i} '.mol'];
            
            %  Get number of hydrogens in the model's metabolite
            metFormula = model.metFormulas(ismember(mets , report.adjustedpHTable.mets{i}));
            metFormula = editChemicalFormula(metFormula{1});
            [elemetList, ~ , elemetEnd] = regexp(char(metFormula), ['[', ...
                'A':'Z', '][', 'a':'z', ']?'], 'match');
            hBool = contains(elemetList, 'H');
            [num, numStart] = regexp(char(metFormula), '\d+', 'match');
            numList = ones(size(elemetList));
            numList(ismember(elemetEnd + 1, numStart)) = cellfun(@str2num, num);
            noOfH_model = numList(hBool);
            
            % Source formula
            inchiLayersDetail = getInchiData(report.adjustedpHTable.inchi{i});
            molFormula = inchiLayersDetail.metFormula;
            %  Get number of hydrogens in the source's metabolite
            [elemetList, ~ , elemetEnd] = regexp(molFormula, ['[', 'A':'Z', '][', 'a':'z', ']?'], 'match');
            hBool = contains(elemetList, 'H');
            [num, numStart] = regexp(molFormula, '\d+', 'match');
            numList = ones(size(elemetList));
            idx = ismember(elemetEnd + 1, numStart);
            numList(idx) = cellfun(@str2num, num);
            noOfH_source = numList(hBool) + inchiLayersDetail.netCharge;
            
            sameFormula = isequal(regexprep(metFormula, 'H\d*', ''), ...
                regexprep(molFormula, 'H\d*', ''));
            wrongPh = ~isequal(metFormula, molFormula);
            
            if sameFormula && wrongPh
                
                % Start with a neutral pH
                pH = 7;
                while noOfH_model ~= noOfH_source
                    
                    if ~needAdjustmentBool(i)
                        needAdjustmentBool(i) = true;
                        if noOfH_model - noOfH_source > 0
                            pHDifference = -0.33;
                        else
                            pHDifference = 0.33;
                        end
                    end
                    
                    % Change pH
                    command = ['cxcalc majormicrospecies -H ' num2str(pH) ' -f mol ' tmpDir '' filesep name];
                    [~, result] = system(command);
                    molFile = regexp(result, '\n', 'split')';
                    fid2 = fopen([tmpDir filesep 'tmp.mol'], 'w');
                    fprintf(fid2, '%s\n', molFile{:});
                    fclose(fid2);
                    % Obtain the chemical formula
                    command = ['cxcalc elementalanalysistable -t "formula" ' tmpDir filesep 'tmp.mol'];
                    [~, formulaOk] = system(command);
                    formulaOk = split(formulaOk);
                    formulaOk = formulaOk{end - 1};
                    %  Get number of hydrogens in the adjusted metabolite
                    [elemetList, ~ , elemetEnd] = regexp(formulaOk, ['[', 'A':'Z', '][', 'a':'z', ']?'], 'match');
                    hBool = contains(elemetList, 'H');
                    [num, numStart] = regexp(formulaOk, '\d+', 'match');
                    numList = ones(size(elemetList));
                    idx = ismember(elemetEnd + 1, numStart);
                    numList(idx) = cellfun(@str2num, num);
                    noOfH_source = numList(hBool);
                    
                    if pH <= 0 || pH >= 14
                        pHRangePassed(i) = true;
                        break
                    end
                    pH = pH + pHDifference;
                    
                    if noOfH_model == noOfH_source
                        movefile([tmpDir filesep 'tmp.mol'], [tmpDir filesep name])
                        report.adjustedpHTable.metFormula(i) = formulaOk;
                    end
                end
            else
                differentFormula(i) = true;
            end
        catch
            loopError(i) = true;
        end
    end
    
    if isfile([tmpDir filesep 'tmp.mol'])
        delete([tmpDir filesep 'tmp.mol'])
    end
    
    report.adjustedpHTable.needAdjustmentBool = needAdjustmentBool;
    report.adjustedpHTable.notPossible2AdjustBool = differentFormula | loopError | pHRangePassed;
    report.adjustedpHTable.differentFormula = differentFormula;
    report.adjustedpHTable.loopError = loopError;
    report.adjustedpHTable.pHRangePassed = pHRangePassed;
    
    if options.printlevel > 0
        disp('adjustedpH:')
        disp(report.adjustedpHTable)
    end
    
    model.comparison = report.adjustedpHTable;
    
end

if options.debug
    save([resultsDir '4.debug_beforeaStandardiseMOLfiles.mat'])
end

%% 5. Standardise the MOL files according options

standardisationApproach = options.standardisationApproach;

% Get list of MOL files
d = dir(tmpDir);
d = d(~[d.isdir]);
metList = {d.name}';
metList = metList(~cellfun('isempty', regexp(metList,'(\.mol)$')));
metList = regexprep(metList, '.mol', '');
metList(~ismember(metList, regexprep(model.mets, '(\[\w\])', ''))) = [];

% Standardise MOL files the most consistent MOL files
standardisationReport = standardiseMolDatabase(tmpDir, metList, metResultsDir, standardisationApproach);
report.standardisationReport = standardisationReport;

if oBabelInstalled && isfield(standardisationReport,'SMILES')
    % Create table
    nRows = size(standardisationReport.SMILES, 1);
    varTypes = {'string', 'string', 'string', 'string'};
    varNames = {'mets', 'InChIKeys', 'InChIs', 'SMILES'};
    report.standardisationReport = table('Size', [nRows length(varTypes)], 'VariableTypes', varTypes, 'VariableNames', varNames);
    report.standardisationReport.mets(1:end) = standardisationReport.standardised;
    report.standardisationReport.InChIKeys(1:size(standardisationReport.InChIKeys, 1)) = standardisationReport.InChIKeys;
    report.standardisationReport.InChIs(1:size(standardisationReport.InChIs, 1)) = standardisationReport.InChIs;
    report.standardisationReport.SMILES(1:size(standardisationReport.SMILES, 1)) = standardisationReport.SMILES;
    % Write table
    writetable(report.standardisationReport, [metResultsDir filesep 'metaboliteStructures'])
end

if options.printlevel > 0
    disp(report.standardisationReport)
end
rmdir(tmpDir, 's')
model.standardisation = report.standardisationReport;

if options.debug
    save([resultsDir '5.debug_beforeAtomMapping.mat'])
end

%% 6. Atom map data

% Set options

% MOL file directory
molFileDir = [metResultsDir filesep 'molFiles'];

% Create the reaction data directory
if ~isfolder(rxnResultsDir)
    mkdir(rxnResultsDir)
end

% Reactions to atom map
rxnsToAM = model.rxns;

% Keep standardisation approach used with the molecular structures
switch options.standardisationApproach
    case 'explicitH'
        hMapping = true;
    case 'implicitH'
        hMapping = false;
    case 'neutral'
        hMapping = true;
    case 'basic'
        hMapping = true;
end

%% Atom map metabolic reactions
if options.atomMapping
    writeRXNonly=0;
    replaceExistingAtomMappings=options.replaceExistingAtomMappings;
    report.atomMappingReport = obtainAtomMappingsRDT(model, molFileDir, rxnResultsDir, rxnsToAM, hMapping, writeRXNonly,replaceExistingAtomMappings);
    %  A directory with standardised RXN files.
    rxnResultsDir_unMapped=report.atomMappingReport.rxnResultsDir_unMapped;
    %  A directory with atom mapped RXN files.
    rxnResultsDir_atomMapped=report.atomMappingReport.rxnResultsDir_atomMapped;
    % A directory images for atom mapped reactions.
    rxnResultsDir_images=report.atomMappingReport.rxnResultsDir_images;
    % A directory with txt files with data of the atom mappings
    rxnResultsDir_txtData=report.atomMappingReport.rxnResultsDir_txtData;
else
    modelOut=model;
    arm=[];
    return
end

if options.debug
    save([resultsDir '6.debug_beforeBuildReport.mat'])
end
%%

%% Final database table

% Reactions in the database
report.atomMappingReport.rxnInDatabase = report.atomMappingReport.rxnFilesWritten;
% List atom mapped reactions
if isfolder(rxnResultsDir_atomMapped)
    atomMappedRxns = dir([rxnResultsDir_unMapped filesep '*.rxn']);
    atomMappedRxns = regexprep({atomMappedRxns.name}, '.rxn', '')';
    atomMappedRxns(~ismember(atomMappedRxns, rxnsToAM)) = [];
else
    atomMappedRxns = {};
end
report.atomMappingReport.mappedRxns = atomMappedRxns;
% Balanced reactions
report.atomMappingReport.balancedReactions = report.atomMappingReport.balanced;
% Unalanced reactions
report.atomMappingReport.unbalancedReactions = report.atomMappingReport.unbalanced;
% Missing reactions
model = findSExRxnInd(model);
report.atomMappingReport.rxnMissing = setdiff(model.rxns(model.SIntRxnBool), report.atomMappingReport.rxnFilesWritten);

% Find metabolites in balanced reactions
metsInBalanced = unique(regexprep(findMetsFromRxns(model, report.atomMappingReport.balanced), '(\[\w\])', ''));
% Find metabolites in unbalanced reactions
metsInUnbalanced = unique(regexprep(findMetsFromRxns(model, report.atomMappingReport.unbalanced), '(\[\w\])', ''));
% Metabolites not used in reactions
metsNotUsed = report.sourcesComparison.comparisonTable.mets(~ismember(...
    report.sourcesComparison.comparisonTable.mets, [metsInBalanced; ...
    metsInUnbalanced]));
% Metabolite in the database
report.atomMappingReport.metInDatabase = report.sourcesComparison.comparisonTable.mets;
% Metabolites allways in balanced reactions
report.atomMappingReport.metsAllwaysInBalancedRxns = umets(ismember(umets, setdiff(metsInBalanced, metsInUnbalanced)));
% Metabolites ocassionally in unbalanced reactions
report.atomMappingReport.metsSometimesInUnbalancedRxns = umets(ismember(umets, intersect(metsInBalanced, metsInUnbalanced)));
% Metabolites allways in unbalanced reactions
report.atomMappingReport.metsAllwaysInUnbalancedRxns = umets(ismember(umets, setdiff(metsInUnbalanced, metsInBalanced)));
% Metabolites not used
report.atomMappingReport.metsNotUsed = metsNotUsed;
% Mising metabolites
report.atomMappingReport.missingMets = setdiff(umets, [metsInBalanced; metsInUnbalanced]);

report.atomMappingReport.table = table([ ...
    size(report.atomMappingReport.metInDatabase, 1); ...
    size(report.atomMappingReport.metsAllwaysInBalancedRxns, 1); ...
    size(report.atomMappingReport.metsSometimesInUnbalancedRxns, 1); ...
    size(report.atomMappingReport.metsAllwaysInUnbalancedRxns, 1); ...
    size(report.atomMappingReport.metsNotUsed, 1); ...
    size(report.atomMappingReport.missingMets, 1); ...
    size(report.atomMappingReport.rxnInDatabase, 1); ...
    size(report.atomMappingReport.mappedRxns, 1); ...
    size(report.atomMappingReport.balancedReactions, 1); ...
    size(report.atomMappingReport.unbalancedReactions, 1); ...
    size(report.atomMappingReport.rxnMissing, 1)],...
    ...
    'VariableNames', ...
    {'Var'},...
    'RowNames',...
    {'Metabolites in the database'; ...
    'Metabolites in balanced reactions';...
    'Metabolites ocassionally in unbalanced reactions';...
    'Metabolites allways in unbalanced reactions';...
    'Metabolites not used';...
    'Mising metabolites'; ...
    'Reactions in the database'; ...
    'Atom mapped reactions'; ...
    'Balanced reactions'; ...
    'Unalanced reactions'; ...
    'Missing reactions'});

if options.printlevel > 0
    
    if ~options.atomMapping
        disp(report.atomMappingReport.table)
    end
    
    % Metabolites
    figure
    subplot(1, 2, 1)
    labelsToAdd = {'In balanced rxn', 'Ocassionally in unbalanced rxn', 'In unbalanced rxn', 'Missing'};
    X = [size(report.atomMappingReport.metsAllwaysInBalancedRxns, 1);...
        size(report.atomMappingReport.metsSometimesInUnbalancedRxns, 1);...
        size(report.atomMappingReport.metsAllwaysInUnbalancedRxns, 1);...
        size(report.atomMappingReport.missingMets, 1)];
    pieChart = pie(X(find(X)));
    ax = gca();
    pieChart = pie(ax, X(find(X)));
    newColors = [...
        0.9608,    0.8353,    0.8353;
        0.9804,    0.9216,    1.0000;
        0.7961,    0.8824,    0.9608;
        0.9137,    1.0000,    0.8392];
    ax.Colormap = newColors;
    lh = legend(labelsToAdd(find(X)), 'FontSize', 16);
    lh.Position(1) = 0.5 - lh.Position(3)/2;
    lh.Position(2) = 0.5 - lh.Position(4)/2;
    legend(labelsToAdd(find(X)), 'FontSize', 16, 'Location', 'southoutside');
    title({'1. Metabolite percentage coverage', [num2str(size(umets, 1)) ' unique metabolites in the model']}, 'FontSize', 20)
    set(findobj(pieChart,'type','text'),'fontsize',18)
    
    % Reactions
    subplot(1, 2, 2)
    labelsToAdd = {'Balanced', 'Unbalanced', 'Missing'};
    X = [size(report.atomMappingReport.balancedReactions, 1);...
        size(report.atomMappingReport.unbalancedReactions, 1);...
        size(report.atomMappingReport.rxnMissing, 1)];
    ax = gca();
    pieChart = pie(ax, X(find(X)));
    newColors = [...
        0.9608,    0.8353,    0.8353;
        0.7961,    0.8824,    0.9608;
        0.9137,    1.0000,    0.8392];
    ax.Colormap = newColors;
    title({'2. Reaction coverage', [num2str(sum(X)) ' internal reactions in the model']}, 'FontSize', 20)
    lh = legend(labelsToAdd(find(X)), 'FontSize', 16, 'Location', 'southoutside');
    set(findobj(pieChart,'type','text'),'fontsize',18)
    
end
if options.printlevel > 1
    disp('RXN files written')
    disp(report.atomMappingReport.rxnFilesWritten)
    disp('Atom mapped reactions')
    disp(report.atomMappingReport.mappedRxns)
    disp('Balanced reactions')
    disp(report.atomMappingReport.balancedReactions)
    disp('Unbalanced reactions')
    disp(report.atomMappingReport.unbalancedReactions)
    disp('Metabolites allways in balanced rxns')
    disp(report.atomMappingReport.metsAllwaysInBalancedRxns)
    disp('Metabolites ocasional in unbalanced rxns')
    disp(report.atomMappingReport.metsSometimesInUnbalancedRxns)
    disp('Metabolites allways in unbalanced rxns')
    disp(report.atomMappingReport.metsAllwaysInUnbalancedRxns)
    disp('Missing metabolites')
    disp(report.atomMappingReport.missingMets)
end

if options.debug
    save([resultsDir '7.debug_before_bonds.mat'])
end

%% 7. Bond enthalpies and bonds broken and formed

if options.bonds
    
    % Get bond enthalpies and bonds broken and formed
    if options.printlevel  > 0
        disp('Calculating bonds broken and formed and enthalpy change...')
    end
    
    tmp = findSExRxnInd(model);
    [enthalpyChange, substrateMass] = findEnthalpyChange(model, model.rxns(tmp.SIntRxnBool), rxnResultsDir_atomMapped, options.printlevel);
    [bondsBrokenAndFormed, ~] = findBondsBrokenAndFormed(model, model.rxns(tmp.SIntRxnBool), rxnResultsDir_atomMapped, options.printlevel);
    
    % Replace NaN values to 'Missing'
    missingRxns = isnan(bondsBrokenAndFormed);
    bondsBrokenAndFormed = cellstr(num2str(bondsBrokenAndFormed));
    bondsBrokenAndFormed(missingRxns) = {'Missing or unbalanced'};
    enthalpyChange = cellstr(num2str(enthalpyChange));
    enthalpyChange(missingRxns) = {'Missing or unbalanced'};
    
    % Create table & sort values
    if ~isfield(model, 'rxnNames')
        model.rxnNames = model.rxns;
    end
    report.bondsData.table = table(model.rxns(tmp.SIntRxnBool), model.rxnNames(tmp.SIntRxnBool), bondsBrokenAndFormed, enthalpyChange, substrateMass, ...
            'VariableNames', {'rxns', 'rxnNames', 'bondsBrokenAndFormed', 'enthalpyChange', 'substrateMass'});
    report.bondsData.table = [sortrows(report.bondsData.table(~missingRxns, :), ...
        {'bondsBrokenAndFormed'}, {'descend'}); report.bondsData.table(missingRxns, :)];   
        
    if options.printlevel  > 0
        disp(report.bondsData.table)
    end
        
    % Add data in the model
    model.bondsBF = bondsBrokenAndFormed;
    model.bondsE = enthalpyChange;
    
end

if isfile([resultsDir 'tmp.mol'])
    delete([resultsDir 'tmp.mol'])
end

modelOut = model;

diary off
if options.printlevel > 0 
    fprintf('%s\n', ['Diary written to: ' resultsDir diaryFilename])
    fprintf('%s\n', 'generateChemicalDatabase run is complete.')
end

end
