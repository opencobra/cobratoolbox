function [info, newModel] = generateChemicalDatabase(model, options)
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
%    [info, newModel] = generateChemicalDatabase(model, options)
%
% INPUTS:
%    model:    COBRA model with following fields:
%
%               * .S - The m x n stoichiometric matrix for the metabolic network.
%               * .rxns - An n x 1 array of reaction identifiers.
%               * .mets - An m x 1 array of metabolite identifiers.
%               * .metFormulas - An m x 1 array of metabolite chemical formulas.
%               * .metinchi - An m x 1 array of metabolite identifiers.
%               * .metsmiles - An m x 1 array of metabolite identifiers.
%               * .metKEGG - An m x 1 array of metabolite identifiers.
%               * .metHMDB - An m x 1 array of metabolite identifiers.
%               * .metPubChem - An m x 1 array of metabolite identifiers.
%               * .metCHEBI - An m x 1 array of metabolite identifiers.
%
%    options:  A structure containing all the arguments for the function:
%
%               * .outputDir: The path to the directory containing the RXN
%                  files with atom mappings (default: current directory)
%               * .printlevel: Verbose level
%               * .standardisationApproach: String containing the type of
%                  standardisation for the molecules (default: 'explicitH'
%                  if openBabel is installed, otherwise default: 'basic'):
%                    - explicitH: Normal chemical graphs;
%                    - implicitH: Hydrogen suppressed chemical graph;
%                    - basic: Update the header.
%               * .keepMolComparison: Logic value for comparing MDL MOL
%                  files from various sources (default: FALSE)
%               * .onlyUnmapped: Logic value to select create only unmapped
%                  MDL RXN files (default: FALSE).
%               * .adjustToModelpH: Logic value used to determine whether a
%                  molecule's pH must be adjusted in accordance with the
%                  COBRA model. (default: TRUE, requires MarvinSuite).
%               * .addDirsToCompare: Cell(s) with the path to directory to
%                  an existing database (default: empty).
%               * .dirNames: Cell(s) with the name of the directory(ies)
%                  (default: empty).
%               * .debug: Logical value used to determine whether or not
%                  the results of different points in the function will be
%                  saved for debugging (default: empty).
%
% OUTPUTS:
%
%    newModel:  A new model with the comparison and if onlyUnmapped = false, 
%               the informaton about the bonds broken and formed as well as 
%               the bond enthalpies for each metabolic reaction.
%    info:      A diary of the database generation process

if ~isfield(options, 'outputDir')
    outputDir = [pwd filesep];
else
    % Make sure input path ends with directory separator
    outputDir = [regexprep(options.outputDir,'(/|\\)$',''), filesep];
end

%% 1. Initialise data and set default variables

metDir = [outputDir 'mets'];
rxnDir = [outputDir 'rxns'];

modelFields = fieldnames(model);

if ~isfield(options, 'debug')
    options.debug = false;
end
if ~isfield(options, 'printlevel')
    options.printlevel = 1;
end
if ~isfield(options, 'standardisationApproach')
    options.standardisationApproach = 'explicitH';
end
if ~isfield(options, 'keepMolComparison')
    options.keepMolComparison = false;
end
if ~isfield(options, 'onlyUnmapped')
    options.onlyUnmapped = false;
end
if ~isfield(options, 'adjustToModelpH')
    options.adjustToModelpH = true;
end
if isfield(options, 'dirsToCompare')
    dirsToCompare = true;
    for i = 1:length(options.dirsToCompare)
        options.dirsToCompare{i} = [regexprep(options.dirsToCompare{i},'(/|\\)$',''), filesep];
        if ~isfolder(options.dirsToCompare)
            display([options.dirsToCompare{i} ' is not a directory'])
            options.dirsToCompare{i} = [];
        end
    end
else
    options.dirsToCompare = [];
    dirsToCompare = false;
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

% Check if ChemAxon and openBabel are installed
[cxcalcInstalled, ~] = system('cxcalc');
cxcalcInstalled = ~cxcalcInstalled;
if cxcalcInstalled == 0
    cxcalcInstalled = false;
    display('cxcalc is not installed, two features cannot be used: ')
    display('1 - jpeg files for molecular structures (obabel required)')
    display('2 - pH adjustment according to model.met Formulas')
end
[oBabelInstalled, ~] = system('obabel');
if oBabelInstalled ~= 1
    oBabelInstalled = false;
    options.standardisationApproach = 'basic';
    display('obabel is not installed, two features cannot be used: ')
    display('1 - Generation of SMILES, InChI and InChIkey')
    display('2 - MOL file standardisation')
end
[javaInstalled, ~] = system('java');
if javaInstalled ~= 1 && ~options.onlyUnmapped
    display('java is not installed, atom mappings cannot be computed')
    options.onlyUnmapped = true;
end

% Start diary
if ~isfolder(outputDir)
    mkdir(outputDir);
end
diaryFilename = [outputDir datestr(now,30) '_DatabaseDiary.txt'];
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

directories = {'inchi'; 'smiles'; 'KEGG'; 'HMDB'; 'PubChem'; 'CHEBI'};
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

if options.printlevel > 0
    fprintf('%s\n\n', 'Obtaining MOL files from chemical databases ...')
end

comparisonDir = [metDir filesep 'sourcesComparison' filesep];
source = [0 0 0 0 0 0 0];
for i = 1:6
    dirBool(i) = false;
    if any(~cellfun(@isempty, regexpi(modelFields, directories{i})))
        dirBool(i) = true;
        sourceData = source;
        sourceData(i + 1) = source(i + 1) + i + 1;
        molCollectionReport = obtainMetStructures(model, comparisonDir, false, [], sourceData);
        movefile([comparisonDir filesep 'newMol'], ...
            [comparisonDir filesep directories{i}])
        info.sourcesCoverage.(directories{i}) = molCollectionReport;
        info.sourcesCoverage.totalCoverage(i) = molCollectionReport.noOfMets;
        info.sourcesCoverage.source{i} = directories{i};
        if options.printlevel > 0
            disp([directories{i} ':'])
            display(molCollectionReport)
        end
    end
end
if ~isempty(dirsToCompare)
    for i = 1:length(options.dirsToCompare)
        % Get list of MOL files
        d = dir(options.dirsToCompare{i});
        d = d(~[d.isdir]);
        metList = {d.name}';
        metList = metList(~cellfun('isempty', regexp(metList,'(\.mol)$')));
        metList = regexprep(metList, '.mol', '');
        metList(~ismember(metList, umets)) = [];
        info.sourcesCoverage.totalCoverage(i + 6) = length(metList);
        info.sourcesCoverage.source{i + 6} = options.dirNames{i};
    end
end
% Remove sources without a single metabolite present the model
if dirsToCompare
    emptySourceBool = info.sourcesCoverage.totalCoverage == 0;
    info.sourcesCoverage.totalCoverage(emptySourceBool) = [];
    directories(emptySourceBool) = [];
    dirsToDeleteBool = ismember(options.dirNames, info.sourcesCoverage.source(emptySourceBool));
    options.dirsToCompare(dirsToDeleteBool) = [];
    options.dirNames(dirsToDeleteBool) = [];
    info.sourcesCoverage.source(emptySourceBool) = [];
else
    directories(~dirBool) = [];
end

if options.debug
    save([outputDir '2.debug_afterDownloadMetabolicStructures.mat'])
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
        sourceDir = [comparisonDir directories{i} filesep];
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
            
            % Get inchis of the original metabolites
            command = ['obabel -imol ' sourceDir name ' -oinchi '];
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
                command = ['obabel -imol ' sourceDir name ' -osmiles '];
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
    save([outputDir '3a.debug_beforeComparison.mat'])
end

if exist('groupedSMILES', 'var')
    
    % Replace R groups to hydrogens to convert them to inchis
    groupedInChIs2 = groupedSMILES;
    sourcesSmiles = groupedSMILES.Properties.VariableNames(2:end);
    for i = 1:length(groupedSMILES.mets)
        for j = 1:length(sourcesSmiles)
            if ~isempty(groupedSMILES.(sourcesSmiles{j}){i})
                fid2 = fopen([outputDir 'tmp'], 'w');
                fprintf(fid2, '%s\n', groupedSMILES.(sourcesSmiles{j}){i});
                fclose(fid2);
                command = 'obabel -ismi tmp -O tmp.mol mol -h';
                [~, ~] = system(command);
                molFile = regexp(fileread([outputDir 'tmp.mol']), '\n', 'split')';
                molFile = regexprep(molFile, 'X|Y|*|R|A', 'H');
                fid2 = fopen([outputDir filesep 'tmp.mol'], 'w');
                fprintf(fid2, '%s\n', molFile{:});
                fclose(fid2);
                % Get inchis of the original metabolites
                command = ['obabel -imol ' outputDir 'tmp.mol -oinchi'];
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
info.sourcesComparison.sources(:, 1) = groupedInChIs.Properties.VariableNames(2:end);
for i = 1:length(groupedInChIs.mets)
    comparisonTable = compareInchis(model, groupedInChIs{i, 2:end}, ...
        groupedInChIs.mets{i});
    info.sourcesComparison.mets{i, 1} = groupedInChIs.mets{i};
    info.sourcesComparison.comparisonMatrix(i, :) = comparisonTable.scores;
    chagreAccuracy = unique( comparisonTable.chargeOkBool(comparisonTable.scores == ...
        max(comparisonTable.scores)));
    info.sourcesComparison.chargeOkBool(i, 1) = chagreAccuracy(1);
    metFormula = comparisonTable.metFormula(comparisonTable.scores == max(comparisonTable.scores));
    if any(ismissing(metFormula))
        metFormula = '';
    else
        metFormula = unique(metFormula);
    end
    info.sourcesComparison.metFormula(i, 1) = metFormula(1);
    info.sourcesComparison.(['met_' groupedInChIs.mets{i}]) = comparisonTable;
end

% Create a comparison table
bestScores = max(info.sourcesComparison.comparisonMatrix');
info.sourcesComparison.comparisonTable = table;
warning('off')
for i = 1:length(info.sourcesComparison.mets)
    info.sourcesComparison.comparisonTable.mets{i} = info.sourcesComparison.mets{i};
    bestDir = directories(find(info.sourcesComparison.comparisonMatrix(i, :) == bestScores(i)));
    info.sourcesComparison.comparisonTable.source{i} = strjoin(bestDir, ' ');
    info.sourcesComparison.comparisonTable.score(i) = bestScores(i);
    info.sourcesComparison.comparisonTable.inchi{i} = groupedInChIs.(bestDir{1}){i};
end
info.sourcesComparison.comparisonTable.chargeOkBool = info.sourcesComparison.chargeOkBool;
info.sourcesComparison.comparisonTable.metFormula = info.sourcesComparison.metFormula;
warning('on')

% Print data
if options.printlevel > 0
    
    display(info.sourcesComparison.comparisonTable)
    
    % heatMap comparison
    figure
    subplot(1, 2, 1)
    scoreMatrix = info.sourcesComparison.comparisonMatrix;
    for i = 1:size(scoreMatrix, 2)
        for j = 1:size(scoreMatrix, 2)
            boolToCompare = scoreMatrix(:, i) ~= 0 & scoreMatrix(:, j) ~= 0;
            group1 = scoreMatrix(boolToCompare, i);
            group2 = scoreMatrix(boolToCompare, j);
            comparisonMatrix(i, j) = sqrt(sum((group1 - group2).^2));
        end
    end
    h = heatmap(comparisonMatrix);
    h.YDisplayLabels = directories;
    h.XDisplayLabels = directories;
    h.FontSize = 16;
    title('Sources disimilarity comparison')
    
    % Sources comparison
    subplot(1, 2, 2)
    [db, ~, idx] = unique(split(strjoin(info.sourcesComparison.comparisonTable.source, ' '), ' '));
    [~, ib1] = ismember(db, directories);
    [timesMatched, ia] = sort(histcounts(idx, size(db, 1)), 'descend');
    bar([timesMatched; info.sourcesCoverage.totalCoverage(ib1)]')
    title({'Sources comparison', ...
        ['Metabolites collected: ' num2str(size(info.sourcesComparison.comparisonTable, 1))]}, 'FontSize', 20)
    legend({'Times with highest score', 'IDs coverage'})
    set(gca, 'XTick', 1:size(db, 1), 'xticklabel', db(ia), 'FontSize', 18)
    ylabel('Metabolites')
    xtickangle(45)
    
    if options.printlevel > 1
        display(groupedInChIs)
    end
    
end

% Save the MOL files with highest score
tmpDir = [metDir filesep 'tmp'];
if ~isfolder(tmpDir)
    mkdir(tmpDir)
end
for i = 1:length(info.sourcesComparison.comparisonTable.mets)
    metName = info.sourcesComparison.comparisonTable.mets{i};
    dirToCopy = split(info.sourcesComparison.comparisonTable.source{i});
    if isfield(options, 'dirNames') && ismember(dirToCopy{1}, options.dirNames)
        copyfile([options.dirsToCompare{ismember(options.dirNames, dirToCopy{1})} metName '.mol'], tmpDir)
    else
        copyfile([comparisonDir dirToCopy{1} filesep metName '.mol'], tmpDir)
    end
end
if isfile([outputDir 'tmp.mol'])
    delete([outputDir 'tmp.mol'])
end
if ~options.keepMolComparison
    rmdir(comparisonDir, 's')
end
if ~options.adjustToModelpH || ~cxcalcInstalled
    model.comparison = info.sourcesComparison.comparisonTable;
end
if options.debug
    save([outputDir '3b.debug_afterComparison.mat'])
end

%% 4. Adjust pH based on the model's chemical formula

if options.adjustToModelpH && cxcalcInstalled
    
    info.adjustedpHTable = info.sourcesComparison.comparisonTable;
    
    if options.printlevel > 0
        fprintf('%s\n', 'Adjusting pH based on the model''s chemical formula ...')
        display(' ')
    end
    
    [needAdjustmentBool, differentFormula, loopError, pHRangePassed] = ...
        deal(false(size(info.sourcesComparison.comparisonTable, 1), 1));
    for i = 1:length(info.adjustedpHTable.mets)
        try
            
            name = [info.adjustedpHTable.mets{i} '.mol'];
            
            %  Get number of hydrogens in the model's metabolite
            metFormula = model.metFormulas(ismember(mets , info.adjustedpHTable.mets{i}));
            metFormula = editChemicalFormula(metFormula{1});
            [elemetList, ~ , elemetEnd] = regexp(char(metFormula), ['[', ...
                'A':'Z', '][', 'a':'z', ']?'], 'match');
            hBool = contains(elemetList, 'H');
            [num, numStart] = regexp(char(metFormula), '\d+', 'match');
            numList = ones(size(elemetList));
            numList(ismember(elemetEnd + 1, numStart)) = cellfun(@str2num, num);
            noOfH_model = numList(hBool);
            
            % Source formula
            inchiLayersDetail = getInchiData(info.adjustedpHTable.inchi{i});
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
                    [~, formula] = system(command);
                    formula = split(formula);
                    formula = formula{end - 1};
                    %  Get number of hydrogens in the adjusted metabolite
                    [elemetList, ~ , elemetEnd] = regexp(formula, ['[', 'A':'Z', '][', 'a':'z', ']?'], 'match');
                    hBool = contains(elemetList, 'H');
                    [num, numStart] = regexp(formula, '\d+', 'match');
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
                        info.adjustedpHTable.metFormula(i) = formula;
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
    
    info.adjustedpHTable.needAdjustmentBool = needAdjustmentBool;
    info.adjustedpHTable.notPossible2AdjustBool = differentFormula | loopError | pHRangePassed;
    info.adjustedpHTable.differentFormula = differentFormula;
    info.adjustedpHTable.loopError = loopError;
    info.adjustedpHTable.pHRangePassed = pHRangePassed;
    
    if options.printlevel > 0
        display('adjustedpH:')
        display(info.adjustedpHTable)
    end
    
    model.comparison = info.adjustedpHTable;
    
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

% Standardise MOL files the most consitent MOL files
standardisationReport = standardiseMolDatabase(tmpDir, metList, metDir, standardisationApproach);
info.standardisationReport = standardisationReport;

if oBabelInstalled
    % Create table
    nRows = size(standardisationReport.SMILES, 1);
    varTypes = {'string', 'string', 'string', 'string'};
    varNames = {'mets', 'InChIKeys', 'InChIs', 'SMILES'};
    info.standardisationReport = table('Size', [nRows length(varTypes)], 'VariableTypes', varTypes, 'VariableNames', varNames);
    info.standardisationReport.mets(1:end) = standardisationReport.standardised;
    info.standardisationReport.InChIKeys(1:size(standardisationReport.InChIKeys, 1)) = standardisationReport.InChIKeys;
    info.standardisationReport.InChIs(1:size(standardisationReport.InChIs, 1)) = standardisationReport.InChIs;
    info.standardisationReport.SMILES(1:size(standardisationReport.SMILES, 1)) = standardisationReport.SMILES;
    % Write table
    writetable(info.standardisationReport, [metDir filesep 'standardisationReport'])
end

if options.printlevel > 0
    display(info.standardisationReport)
end
rmdir(tmpDir, 's')
model.standardisation = info.standardisationReport;

if options.debug
    save([outputDir '5.debug_afterStandardisation.mat'])
end

%% 6. Atom map data

% Set options

% MOL file directory
molFileDir = [metDir filesep 'molFiles'];

% Create the reaction data directory
if ~isfolder(rxnDir)
    mkdir(rxnDir)
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
    case 'basic'
        hMapping = true;
end

% Atom map metabolic reactions
reactionsReport = obtainAtomMappingsRDT(model, molFileDir, rxnDir, rxnsToAM, hMapping, options.onlyUnmapped);
info.reactionsReport = reactionsReport;

rxnsFilesDir = [rxnDir filesep 'unMapped'];
if ~options.onlyUnmapped
    
    % Atom map transport reactions
    mappedRxns = transportRxnAM(rxnsFilesDir, [rxnDir filesep 'atomMapped']);
    for i = 1:size(mappedRxns, 2)
        delete([rxnDir filesep 'images' filesep mappedRxns{i} '.png']);
    end
    
    % Generate rinchis and reaction SMILES
    if oBabelInstalled
        
        nRows = size(rxnsToAM, 1);
        varTypes = {'string', 'string', 'string'};
        varNames = {'rxns', 'rinchi', 'rsmi'};
        info.reactionsReport.rxnxIDsTable = table('Size', [nRows length(varTypes)], 'VariableTypes', varTypes, 'VariableNames', varNames);
        
        model.rinchi = repmat({''}, size(model.rxns));
        model.rsmi = repmat({''}, size(model.rxns));
        for i = 1:size(rxnsToAM, 1)
            info.reactionsReport.rxnxIDsTable.rxns(i) = rxnsToAM(i);
            if isfile([rxnDir filesep 'atomMapped' filesep rxnsToAM{i} '.rxn'])
                
                % Remove parenthesis for RDT
                if contains(rxnsToAM{i}, '(')
                    rxnFileName = regexprep(rxnsToAM{i}, '\(', '\_40');
                    rxnFileName = regexprep(rxnFileName, '\)', '\_41');
                    movefile([rxnDir filesep 'atomMapped' filesep rxnsToAM{i} '.rxn'], ...
                        [rxnDir filesep 'atomMapped' filesep rxnFileName '.rxn'])
                    reverseName = 1;
                else
                    rxnFileName = rxnsToAM{i};
                end
                
                % Get rinchis
                command = ['obabel -irxn ' rxnDir filesep 'atomMapped' filesep rxnFileName '.rxn -orinchi'];
                [~, result] = system(command);
                if ~any(contains(result, '0 molecules converted'))
                    result = split(result);
                    info.reactionsReport.rxnxIDsTable.rinchi(i) = result{~cellfun(@isempty, regexp(result, 'RInChI='))};
                    model.rinchi{findRxnIDs(model, rxnsToAM{i})} = result{~cellfun(@isempty, regexp(result, 'RInChI='))};
                end
                
                % Get reaction SMILES
                command = ['obabel -irxn ' rxnDir filesep 'atomMapped' filesep rxnFileName '.rxn -osmi'];
                [~, result] = system(command);
                if ~any(contains(result, '0 molecules converted'))
                    result = splitlines(result);
                    result = split(result{end - 2});
                    info.reactionsReport.rxnxIDsTable.rsmi(i) = result{1};
                    model.rsmi{findRxnIDs(model, rxnsToAM{i}), 1} = result{1};
                end
                
                if exist('reverseName', 'var')
                    movefile([rxnDir filesep 'atomMapped' filesep rxnFileName '.rxn'], ...
                        [rxnDir filesep 'atomMapped' filesep rxnsToAM{i} '.rxn'])
                    clear reverseName
                end
            end
        end
    end
end

% Find unbalanced RXN files
% Get list of RXN files to check
rxnList = dir([rxnDir filesep 'unMapped' filesep '*.rxn']);
rxnList = regexprep({rxnList.name}, '.rxn', '')';
rxnList(~ismember(rxnList, rxnsToAM)) = [];

[unbalancedBool, v3000] = deal(false(size(rxnList)));
for i = 1:size(rxnList, 1)
    
    name = [rxnList{i} '.rxn'];
    % Read the RXN file
    rxnFile = regexp(fileread([rxnsFilesDir filesep name]), '\n', 'split')';
    
    % Identify molecules
    substrates = str2double(rxnFile{5}(1:3));
    products = str2double(rxnFile{5}(4:6));
    begMol = strmatch('$MOL', rxnFile);
    
    if ~isnan(products)
        % Count atoms in substrates and products
        atomsS = 0;
        for j = 1:substrates
            atomsS = atomsS + str2double(rxnFile{begMol(j) + 4}(1:3));
        end
        atomsP = 0;
        for j = substrates + 1: substrates +products
            atomsP = atomsP + str2double(rxnFile{begMol(j) + 4}(1:3));
        end
        
        % Check if the file is unbalanced
        if atomsS ~= atomsP
            unbalancedBool(i) = true;
        end
    else
        v3000(i) = true;
    end
end

% Final database table

% Reactions in the database
info.reactionsReport.rxnInDatabase = rxnList;
% List atom mapped reactions
if isfolder([rxnDir filesep 'atomMapped' filesep '*.rxn'])
    atomMappedRxns = dir([rxnDir filesep 'unMapped' filesep '*.rxn']);
    atomMappedRxns = regexprep({atomMappedRxns.name}, '.rxn', '')';
    atomMappedRxns(~ismember(atomMappedRxns, rxnsToAM)) = [];
else
    atomMappedRxns = {};
end
info.reactionsReport.mappedRxns = atomMappedRxns;
% Balanced reactions
info.reactionsReport.balancedReactions = rxnList(~unbalancedBool);
% Unalanced reactions
info.reactionsReport.unbalancedReactions = rxnList(unbalancedBool);
% Missing reactions
model = findSExRxnInd(model);
info.reactionsReport.rxnMissing = setdiff(model.rxns(model.SIntRxnBool), info.reactionsReport.rxnFilesWritten);

% Find metabolites in balanced reactions
metsInBalanced = unique(regexprep(findMetsFromRxns(model, rxnList(~unbalancedBool)), '(\[\w\])', ''));
% Find metabolites in unbalanced reactions
metsInUnbalanced = unique(regexprep(findMetsFromRxns(model, rxnList(unbalancedBool)), '(\[\w\])', ''));
% Metabolites not used in reactions
metsNotUsed = info.sourcesComparison.comparisonTable.mets(~ismember(...
    info.sourcesComparison.comparisonTable.mets, [metsInBalanced; ...
    metsInUnbalanced]));
% Metabolite in the database
info.reactionsReport.metInDatabase = info.sourcesComparison.comparisonTable.mets;
% Metabolites allways in balanced reactions
info.reactionsReport.metsAllwaysInBalancedRxns = umets(ismember(umets, setdiff(metsInBalanced, metsInUnbalanced)));
% Metabolites ocassionally in unbalanced reactions
info.reactionsReport.metsSometimesInUnbalancedRxns = umets(ismember(umets, intersect(metsInBalanced, metsInUnbalanced)));
% Metabolites allways in unbalanced reactions
info.reactionsReport.metsAllwaysInUnbalancedRxns = umets(ismember(umets, setdiff(metsInUnbalanced, metsInBalanced)));
% Metabolites not used
info.reactionsReport.metsNotUsed = metsNotUsed;
% Mising metabolites
info.reactionsReport.missingMets = setdiff(umets, [metsInBalanced; metsInUnbalanced]);

info.reactionsReport.table = table([ ...
    size(info.reactionsReport.metInDatabase, 1); ...
    size(info.reactionsReport.metsAllwaysInBalancedRxns, 1); ...
    size(info.reactionsReport.metsSometimesInUnbalancedRxns, 1); ...
    size(info.reactionsReport.metsAllwaysInUnbalancedRxns, 1); ...
    size(info.reactionsReport.metsNotUsed, 1); ...
    size(info.reactionsReport.missingMets, 1); ...
    size(info.reactionsReport.rxnInDatabase, 1); ...
    size(info.reactionsReport.mappedRxns, 1); ...
    size(info.reactionsReport.balancedReactions, 1); ...
    size(info.reactionsReport.unbalancedReactions, 1); ...
    size(info.reactionsReport.missingMets, 1)],...
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
    
    if ~options.onlyUnmapped
        display(info.reactionsReport.rxnxIDsTable)
    end
    
    display(info.reactionsReport.table)
    
    % Reactions
    figure
    labelsToAdd = {'Balanced', 'Unbalanced', 'Missing'};
    X = [size(info.reactionsReport.balancedReactions, 1);...
        size(info.reactionsReport.unbalancedReactions, 1);...
        size(info.reactionsReport.rxnMissing, 1)];
    ax = gca();
    pieChart = pie(ax, X(find(X)));
    newColors = [...
        0.9608,    0.8353,    0.8353;
        0.7961,    0.8824,    0.9608;
        0.9137,    1.0000,    0.8392];
    ax.Colormap = newColors;
    title({'Reaction coverage', ['From ' num2str(sum(X)) ' internal rxns in the model']}, 'FontSize', 20)
    lh = legend(labelsToAdd(find(X)), 'FontSize', 16);
    lh.Position(1) = 0.5 - lh.Position(3)/2;
    lh.Position(2) = 0.5 - lh.Position(4)/2;
    set(findobj(pieChart,'type','text'),'fontsize',18)
    
    % Metabolites
    figure
    labelsToAdd = {'In balanced rxn', 'Ocassionally in unbalanced rxn', 'In unbalanced rxn', 'Missing'};
    X = [size(info.reactionsReport.metsAllwaysInBalancedRxns, 1);...
        size(info.reactionsReport.metsSometimesInUnbalancedRxns, 1);...
        size(info.reactionsReport.metsAllwaysInUnbalancedRxns, 1);...
        size(info.reactionsReport.missingMets, 1)];
    pieChart = pie(X(find(X)));
    ax = gca();
    pieChart = pie(ax, X(find(X)));
    newColors = [...
        0.7765,    0.9686,    0.9569;
        0.9804,    0.9216,    1.0000;
        0.9137,    1.0000,    0.8392;
        1.0000,    0.8706,    0.7216];
    ax.Colormap = newColors;
    lh = legend(labelsToAdd(find(X)), 'FontSize', 16);
    lh.Position(1) = 0.5 - lh.Position(3)/2;
    lh.Position(2) = 0.5 - lh.Position(4)/2;
    legend(labelsToAdd(find(X)), 'FontSize', 16)
    title({'Metabolite percentage coverage', ['From ' num2str(size(umets, 1)) ' unique mets in the model']}, 'FontSize', 20)
    set(findobj(pieChart,'type','text'),'fontsize',18)
    
end
if options.printlevel > 1
    disp('RXN files written')
    display(info.reactionsReport.rxnFilesWritten)
    disp('Atom mapped reactions')
    display(info.reactionsReport.mappedRxns)
    disp('Balanced reactions')
    display(info.reactionsReport.balancedReactions)
    disp('Unbalanced reactions')
    display(info.reactionsReport.unbalancedReactions)
    disp('Metabolites allways in balanced rxns')
    display(info.reactionsReport.metsAllwaysInBalancedRxns)
    disp('Metabolites ocasional in unbalanced rxns')
    display(info.reactionsReport.metsSometimesInUnbalancedRxns)
    disp('Metabolites allways in unbalanced rxns')
    display(info.reactionsReport.metsAllwaysInUnbalancedRxns)
    disp('Missing metabolites')
    display(info.reactionsReport.missingMets)
end

if options.debug
    save([outputDir '6.debug_endOfReactionDatabase.mat'])
end

%% 7. Bond enthalpies and bonds broken and formed

if ~options.onlyUnmapped
    
    % Get bond enthalpies and bonds broken and formed
    if options.printlevel  > 0
        display('Obtaining RInChIes and reaction SMILES ...')
        [bondsBF, bondsE, meanBBF, meanBE] = findBEandBBF(model, [rxnDir filesep 'atomMapped'], 1);
        info.bondsData.table = table(model.rxns, model.rxnNames, bondsBF, bondsE, ...
            'VariableNames', {'rxns', 'rxnNames', 'bondsBF', 'bondsE'});
        info.bondsData.table = sortrows(info.bondsData.table, {'bondsBF'}, {'descend'});
        display(info.bondsData.table)
    else
        [bondsBF, bondsE, meanBBF, meanBE] = findBEandBBF(model, [rxnDir filesep 'atomMapped']);
        info.bondsData.table = table(model.rxns, model.rxnNames, bondsBF, bondsE, ...
            'VariableNames', {'rxns','rxnNames','bondsBF','bondsE'});
        info.bondsData.table = sortrows(info.bondsData.table, {'bondsBF'}, {'descend'});
    end
        
    % Add data in the model
    model.bondsBF = bondsBF;
    model.bondsE = bondsE;
    model.meanBBF = meanBBF;
    model.meanBE = meanBE;
    
end

newModel = model;
if options.debug
    save([outputDir '7.debug_endOfGenerateChemicalDatabase.mat'])
end

diary off
if options.printlevel > 0 > 0
    fprintf('%s\n', ['Diary written to: ' options.outputDir])
    fprintf('%s\n', 'generateChemicalDatabase run is complete.')
end

end
