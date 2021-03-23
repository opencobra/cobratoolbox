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
%
%    model:    COBRA model with following fields:
%
%                  * .S - The m x n stoichiometric matrix for the
%                         metabolic network.
%                  * .rxns - An n x 1 array of reaction identifiers.
%                  * .mets - An m x 1 array of metabolite identifiers.
%                  * .metFormulas - An m x 1 array of metabolite chemical formulas.
%                  * .metinchi - An m x 1 array of metabolite identifiers.
%                  * .metsmiles - An m x 1 array of metabolite identifiers.
%                  * .metKEGG - An m x 1 array of metabolite identifiers.
%                  * .metHMDB - An m x 1 array of metabolite identifiers.
%                  * .metPubChem - An m x 1 array of metabolite identifiers.
%                  * .metCHEBI - An m x 1 array of metabolite identifiers.
%
%    options:  A structure containing all the arguments for the function:
%
%                  * .printlevel - name of objective function ('')
%                  * .standardisationApproach - list of reactions to remove ('')
%                  * .keepMolComparison - table containing: names, rxnFormulas, subSystems,
%                                rxnGrRules, and rxnReferences to add to the model
%                                ('')
%                  * .adjustToModelpH - a table containing mediaData constraints, with
%                  * .onlyUnmapped - Logic value indicating if the reactions
%                               will be atom maaped or not (default: true)
%                  * .outputDir - a table containing mediaData constraints, with
%
% OUTPUTS:
%
%    newModel:      A new model with the comparison and if onlyUnmapped =
%                   false, the informaton about the bonds broken and formed
%                   as well as the bond enthalpies for each metabolic
%                   reaction.
%    info:          A diary of the database generation process

%% 1. Initialise data and set default variables

if ~isfield(options, 'outputDir')
    outputDir = [pwd filesep];
else
    % Make sure input path ends with directory separator
    outputDir = [regexprep(options.outputDir,'(/|\\)$',''), filesep];
end
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
[marvinInstalled, ~] = system('cxcalc');
marvinInstalled = ~marvinInstalled;
if marvinInstalled == 0
    display('cxcalc is not installed, two features cannot be used: ')
    display('1 - jpeg files for molecular structures (obabel required)')
    display('2 - pH adjustment according to model.met Formulas')
end
[oBabelInstalled, ~] = system('obabel');
if ~oBabelInstalled
    options.standardisationApproach = 'basic';
    display('obabel is not installed, two features cannot be used: ')
    display('1 - Generation of SMILES, InChI and InChIkey')
    display('2 - MOL file standardisation')
end
[javaInstalled, ~] = system('java');
if ~javaInstalled  && ~options.onlyUnmapped
    display('java is not installed, atom mappings cannot be computed')
    options.onlyUnmapped = true;
end

% Start diary
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

comparisonDir = [metDir filesep 'molComparison' filesep];
source = [0 0 0 0 0 0 0];
for i = 1:6
    if any(~cellfun(@isempty, regexpi(modelFields, directories{i})))
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
emptySourceBool = info.sourcesCoverage.totalCoverage == 0;
info.sourcesCoverage.totalCoverage(emptySourceBool) = [];
directories(emptySourceBool) = [];
dirsToDeleteBool = ismember(options.dirNames, info.sourcesCoverage.source(emptySourceBool));
options.dirsToCompare(dirsToDeleteBool) = [];
options.dirNames(dirsToDeleteBool) = [];
info.sourcesCoverage.source(emptySourceBool) = [];

if options.debug
    save([outputDir '2.debug_afterDownloadMetabolicStructures.mat'])
end

%% 3. Compare MOL files downloaded and save the best match

if options.printlevel > 0
    fprintf('%s\n', 'Comparing information from sources ...')
end

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
                if ~ismember('metNames', groupedInChIs.Properties.VariableNames)
                    groupedInChIs.metNames{j} = regexprep(name, '.mol', '');
                    idx = 1;
                elseif ~ismember(regexprep(name, '.mol', ''), groupedInChIs.metNames)
                    idx = size(groupedInChIs.metNames, 1) + 1;
                    groupedInChIs.metNames{idx} = regexprep(name, '.mol', '');
                else
                    idx = find(ismember(groupedInChIs.metNames, regexprep(name, '.mol', '')));
                end
                % Save inchi in the table
                groupedInChIs.(directories{i}){idx} = result{~cellfun(@isempty, regexp(result, 'InChI=1S'))};
                
            else
                
                % Create SMILES table for molecules with R groups
                if ~exist('groupedSMILES','var')
                    groupedSMILES = table();
                end
                % Identify the correct index
                if ~ismember('metNames', groupedSMILES.Properties.VariableNames)
                    groupedSMILES.metNames{1} = regexprep(name, '.mol', '');
                    idx = 1;
                elseif ~ismember(regexprep(name, '.mol', ''), groupedSMILES.metNames)
                    idx = size(groupedSMILES.metNames, 1) + 1;
                    groupedSMILES.metNames{idx} = regexprep(name, '.mol', '');
                else
                    idx = find(ismember(groupedSMILES.metNames, regexprep(name, '.mol', '')));
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
            if ~ismember('metNames', groupedFormula.Properties.VariableNames)
                groupedFormula.metNames{1} = regexprep(name, '.mol', '');
                idx = 1;
            elseif ~ismember(regexprep(name, '.mol', ''), groupedFormula.metNames)
                idx = size(groupedFormula.metNames, 1) + 1;
                groupedFormula.metNames{idx} = regexprep(name, '.mol', '');
            else
                idx = find(ismember(groupedFormula.metNames, regexprep(name, '.mol', '')));
            end
            % Get formula from MOL
            molFile = regexp(fileread([sourceDir name]), '\n', 'split')';
            atomsString = [];
            for k = 1:str2num(molFile{4}(1:3))
                atomsString = [atomsString strtrim(molFile{4 + k}(32:33))];
            end
            groupedFormula.(directories{i}){idx} = editChemicalFormula(atomsString);
            
        end
    end
    warning('on')
end

if options.debug
    save([outputDir '3a.debug_beforeComparison.mat'])
end

if oBabelInstalled
    
    % Obtain the most consistent molecules
    reportComparisonInChIs = consistentData(model, groupedInChIs, 'InChI');
    fields = fieldnames(reportComparisonInChIs);
    metsInStruct = regexprep(fields(contains(fields, 'met_')), 'met_', '');
    emptyBool = cellfun(@isempty, reportComparisonInChIs.sourcesToSave);
    source = reportComparisonInChIs.sourcesToSave(~emptyBool);
    
    % Obtain the most consistent for molecules with R groups
    if exist('groupedSMILES','var')
        reportComparisonSMILES = consistentData(model, groupedSMILES, 'SMILES');
        fields = fieldnames(reportComparisonSMILES);
        metNamesSmiles = regexprep(fields(contains(fields, 'met_')), 'met_', '');
        metsInStruct(end + 1: end + size(metNamesSmiles, 1)) = metNamesSmiles;
        emptyBool = cellfun(@isempty, reportComparisonSMILES.sourcesToSave);
        source(end + 1: end + size(metNamesSmiles, 1)) = reportComparisonSMILES.sourcesToSave(~emptyBool);
    end
    
    nRows = size(metsInStruct, 1);
    varTypes = {'string', 'string', 'string', 'string', 'string', 'double', 'double', 'string'};
    varNames = {'mets', 'sourceWithHighestScore', 'metNames', 'metFormulas', 'sourceFormula', 'layersInChI', 'socre', 'idUsed'};
    info.comparisonTable = table('Size', [nRows length(varTypes)], 'VariableTypes', varTypes, 'VariableNames', varNames);
    
    fields = fieldnames(reportComparisonInChIs);
    metFields = fields(contains(fields, 'met_'));
    for i = 1:size(metFields, 1)
        info.comparisonTable.mets(i) = metsInStruct(i);
        info.comparisonTable.sourceWithHighestScore(i) = source(i);
        info.comparisonTable.metNames(i) = reportComparisonInChIs.(metFields{i}).metNames;
        info.comparisonTable.metFormulas(i) = reportComparisonInChIs.(metFields{i}).metFormula;
        selectedIdIdx = find(reportComparisonInChIs.(metFields{i}).idsScore == max(reportComparisonInChIs.(metFields{i}).idsScore));
        info.comparisonTable.sourceFormula(i) = reportComparisonInChIs.(metFields{i}).sourceFormula(selectedIdIdx(1));
        info.comparisonTable.layersInChI(i) = reportComparisonInChIs.(metFields{i}).layersOfDataInChI(selectedIdIdx(1));
        info.comparisonTable.idUsed(i) = reportComparisonInChIs.(metFields{i}).ids(selectedIdIdx(1));
        info.comparisonTable.socre(i) = reportComparisonInChIs.(metFields{i}).idsScore(selectedIdIdx(1));
    end
    if exist('groupedSMILES','var')
        fields = fieldnames(reportComparisonSMILES);
        metFields = fields(contains(fields, 'met_'));
        startFrom = i;
        for i = 1:size(metFields, 1)
            info.comparisonTable.mets(i + startFrom) = metsInStruct(i + startFrom);
            info.comparisonTable.sourceWithHighestScore(i + startFrom) = source(i + startFrom);
            info.comparisonTable.metNames(i + startFrom, 1) = reportComparisonSMILES.(metFields{i}).metNames;
            info.comparisonTable.metFormulas(i + startFrom) = char(reportComparisonSMILES.(metFields{i}).metFormula);
            selectedIdIdx = find(reportComparisonSMILES.(metFields{i}).idsScore == max(reportComparisonSMILES.(metFields{i}).idsScore));
            info.comparisonTable.sourceFormula(i + startFrom) = reportComparisonSMILES.(metFields{i}).sourceFormula(selectedIdIdx(1));
            info.comparisonTable.layersInChI(i + startFrom) = NaN;
            info.comparisonTable.idUsed(i + startFrom) = reportComparisonSMILES.(metFields{i}).ids(selectedIdIdx(1));
            info.comparisonTable.socre(i + startFrom) = reportComparisonSMILES.(metFields{i}).idsScore(selectedIdIdx(1));
        end
    end
    
    % Print data
    if options.printlevel > 0
        display(info.comparisonTable)
        
        % heatMap comparison
        figure
        comparison = reportComparisonInChIs.comparison;
        if exist('groupedSMILES','var')
            rows = size(comparison, 1);
            comparison = [comparison; zeros(size(reportComparisonSMILES.comparison, 1),...
                size(comparison, 2))];
            bool = ismember(reportComparisonInChIs.sources, reportComparisonSMILES.sources);
            comparison(rows + 1:end, bool) = reportComparisonSMILES.comparison;
        end
        for i = 1:size(comparison, 2)
            for j = 1:size(comparison, 2)
                boolToCompare = ~isnan(comparison(:, i)) & ~isnan(comparison(:, j));
                group1 = comparison(boolToCompare, i);
                group2 = comparison(boolToCompare, j);
                comparisonMatrix(i, j) = sqrt(sum((group1 - group2).^2));
            end
        end
        h = heatmap(comparisonMatrix);
        h.YDisplayLabels = directories;
        h.XDisplayLabels = directories;
        h.FontSize = 16;
        title('Sources disimilarity comparison')
        
        % Sources comparison
        figure
        [db, ~, idx] = unique(split(strjoin(source, ' '), ' '));
        [~, ib1] = ismember(db, directories);
        yyaxis left
        bar(histcounts(idx, size(db, 1)))
        title({'Sources comparison', ...
            ['Metabolites collected: ' num2str(size(info.comparisonTable, 1))]}, 'FontSize', 20)
        ylabel('Times with highest score', 'FontSize', 18)
        set(gca, 'XTick', 1:size(db, 1), 'xticklabel', db, 'FontSize', 18)
        xtickangle(45)
        yyaxis right
        bar(info.sourcesCoverage.totalCoverage(ib1), 0.3)
        ylabel('IDs coverage', 'FontSize', 20)
        
        if options.printlevel > 1
            display(groupedInChIs)
        end
    end
    
else
    
    % Obtain the most consistent molecules
    reportComparisonFormula = consistentData(model, groupedFormula, 'MOL');
    fields = fieldnames(reportComparisonFormula);
    metsInStruct = regexprep(fields(contains(fields, 'met_')), 'met_', '');
    emptyBool = cellfun(@isempty, reportComparisonFormula.sourcesToSave);
    source = reportComparisonFormula.sourcesToSave(~emptyBool);
    
    nRows = size(metsInStruct, 1);
    varTypes = {'string', 'string', 'string', 'string', 'string', 'double', 'double', 'string'};
    varNames = {'mets', 'sourceWithHighestScore', 'metNames', 'metFormulas', 'sourceFormula', 'layersInChI', 'socre', 'idUsed'};
    info.comparisonTable = table('Size', [nRows length(varTypes)], 'VariableTypes', varTypes, 'VariableNames', varNames);
    
    fields = fieldnames(reportComparisonFormula);
    metFields = fields(contains(fields, 'met_'));
    for i = 1:size(metFields, 1)
        info.comparisonTable.mets(i) = metsInStruct(i);
        info.comparisonTable.sourceWithHighestScore(i) = source(i);
        info.comparisonTable.metNames(i) = reportComparisonFormula.(metFields{i}).metNames;
        info.comparisonTable.metFormulas(i) = char(reportComparisonFormula.(metFields{i}).metFormula);
        selectedIdIdx = find(reportComparisonFormula.(metFields{i}).idsScore == max(reportComparisonFormula.(metFields{i}).idsScore));
        info.comparisonTable.sourceFormula(i) = reportComparisonFormula.(metFields{i}).sourceFormula(selectedIdIdx(1));
        info.comparisonTable.idUsed(i) = reportComparisonFormula.(metFields{i}).ids(selectedIdIdx(1));
        info.comparisonTable.socre(i) = reportComparisonFormula.(metFields{i}).idsScore(selectedIdIdx(1));
    end
    
    if options.printlevel > 0
        display(info.comparisonTable)
        
        % heatMap comparison
        figure
        comparison = reportComparisonFormula.comparison;
        for i = 1:size(comparison, 2)
            for j = 1:size(comparison, 2)
                % Ignore NaN data
                boolToCompare = ~isnan(comparison(:, i)) & ~isnan(comparison(:, j));
                group1 = comparison(boolToCompare, i);
                group2 = comparison(boolToCompare, j);
                comparisonMatrix(i, j) = sqrt(sum((group1 - group2).^2));
            end
        end
        h = heatmap(comparisonMatrix);
        h.YDisplayLabels = directories;
        h.XDisplayLabels = directories;
        title('Dissimilarity comparison')
        
        % Sources comparison
        figure
        [db, ~, idx] = unique(split(strjoin(source, ' '), ' '));
        bar(histcounts(idx, size(db, 1)))
        title({'Source of molecules with the highest score', ...
            ['Total ' num2str(size(info.comparisonTable, 1))]}, 'FontSize', 20)
        ylabel('Times ', 'FontSize', 18)
        set(gca, 'XTick', 1:size(db, 1), 'xticklabel', db, 'FontSize', 18)
        xtickangle(45)
        
        if options.printlevel > 1
            display(groupedFormula)
        end
    end
    
end

% Save the MOL files with highest score
tmpDir = [metDir filesep 'tmp'];
if ~isfolder(tmpDir)
    mkdir(tmpDir)
end
source = source(ismember(metsInStruct, unique(regexprep(model.mets, '(\[\w\])', ''))));
metsInStruct = metsInStruct(ismember(metsInStruct, unique(regexprep(model.mets, '(\[\w\])', ''))));
for i = 1:size(metsInStruct, 1)
    dirToCopy = strsplit(source{i}, ' ');
    if dirsToCompare && ismember(dirToCopy{1}, options.dirNames)
        copyfile([options.dirsToCompare{ismember(options.dirNames, dirToCopy{1})} metsInStruct{i} '.mol'], tmpDir)
    else
        copyfile([comparisonDir dirToCopy{1} filesep metsInStruct{i} '.mol'], tmpDir)
    end
end
if ~options.keepMolComparison
    rmdir(comparisonDir, 's')
end
if ~options.adjustToModelpH || ~marvinInstalled
    model.comparison = info.comparisonTable;
end
if options.debug
    save([outputDir '3b.debug_afterComparison.mat'])
end

%% 4. Adjust pH based on the model's chemical formula

if options.adjustToModelpH && marvinInstalled
    
    info.adjustedpHTable = info.comparisonTable;
    
    if options.printlevel > 0
        fprintf('%s\n', 'Adjusting pH based on the model''s chemical formula ...')
        display(' ')
    end
    
    [needAdjustmentBool, differentFormula, loopError, pHRangePassed] = deal(false(size(info.comparisonTable, 1), 1));
    for i = 1:size(info.comparisonTable, 1)
        try
            
            name = [info.comparisonTable.mets{i} '.mol'];
            
            if isequal(regexprep(info.comparisonTable.metFormulas(i), 'H\d*', ''),...
                    regexprep(info.comparisonTable.sourceFormula(i), 'H\d*', '')) % pH different only
                
                %  Get number of hydrogens in the model's metabolite
                [elemetList, ~ , elemetEnd] = regexp(info.comparisonTable.metFormulas(i), ['[', 'A':'Z', '][', 'a':'z', ']?'], 'match');
                hBool = contains(elemetList, 'H');
                [num, numStart] = regexp(info.comparisonTable.metFormulas(i), '\d+', 'match');
                numList = ones(size(elemetList));
                numList(ismember(elemetEnd + 1, numStart)) = cellfun(@str2num, num);
                noOfH_model = numList(hBool);
                
                %  Get number of hydrogens in the source's metabolite
                [elemetList, ~ , elemetEnd] = regexp(info.comparisonTable.sourceFormula(i), ['[', 'A':'Z', '][', 'a':'z', ']?'], 'match');
                hBool = contains(elemetList, 'H');
                [num, numStart] = regexp(info.comparisonTable.sourceFormula(i), '\d+', 'match');
                numList = ones(size(elemetList));
                idx = ismember(elemetEnd + 1, numStart);
                numList(idx) = cellfun(@str2num, num);
                noOfH_source = numList(hBool);
                
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
                        info.adjustedpHTable.sourceFormula(i) = formula;
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
                % Get rinchis
                command = ['obabel -irxn ' rxnDir filesep 'atomMapped' filesep rxnsToAM{i} '.rxn -orinchi'];
                [~, result] = system(command);
                result = split(result);
                info.reactionsReport.rxnxIDsTable.rinchi(i) = result{~cellfun(@isempty, regexp(result, 'RInChI='))};
                model.rinchi{findRxnIDs(model, rxnsToAM{i})} = result{~cellfun(@isempty, regexp(result, 'RInChI='))};
                % Get reaction SMILES
                command = ['obabel -irxn ' rxnDir filesep 'atomMapped' filesep rxnsToAM{i} '.rxn -osmi'];
                [~, result] = system(command);
                result = splitlines(result);
                result = split(result{end - 2});
                info.reactionsReport.rxnxIDsTable.rsmi(i) = result{1};
                model.rsmi{findRxnIDs(model, rxnsToAM{i}), 1} = result{1};
            end
        end
    end
end

% Find unbalanced RXN files
% Get list of RXN files to check
d = dir(rxnsFilesDir);
d = d(~[d.isdir]);
rxnList = {d.name}';
rxnList = rxnList(~cellfun('isempty', regexp(rxnList,'(\.rxn)$')));
rxnList = regexprep(rxnList, '.rxn', '');
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

info.reactionsReport.balancedReactions = rxnList(~unbalancedBool);
info.reactionsReport.unbalancedReactions = rxnList(unbalancedBool);
model = findSExRxnInd(model);
info.reactionsReport.rxnMissing = setdiff(model.rxns(model.SIntRxnBool), info.reactionsReport.rxnFilesWritten);

metsInBalanced = unique(regexprep(findMetsFromRxns(model, rxnList(~unbalancedBool)), '(\[\w\])', ''));
metsInUnbalanced = unique(regexprep(findMetsFromRxns(model, rxnList(unbalancedBool)), '(\[\w\])', ''));
info.reactionsReport.metsAllwaysInBalancedRxns = umets(ismember(umets, setdiff(metsInBalanced, metsInUnbalanced)));
info.reactionsReport.metsSometimesInUnbalancedRxns = umets(ismember(umets, intersect(metsInBalanced, metsInUnbalanced)));
info.reactionsReport.metsAllwaysInUnbalancedRxns = umets(ismember(umets, setdiff(metsInUnbalanced, metsInBalanced)));
info.reactionsReport.missingMets = setdiff(umets, [metsInBalanced; metsInUnbalanced]);

info.reactionsReport.table = table([...
    size(info.reactionsReport.rxnFilesWritten, 1);...
    size(info.reactionsReport.mappedRxns, 1);...
    size(info.reactionsReport.balancedReactions, 1);...
    size(info.reactionsReport.unbalancedReactions, 1);...
    size(info.reactionsReport.rxnMissing, 1);...
    size(info.reactionsReport.metsAllwaysInBalancedRxns, 1) + ...
    size(info.reactionsReport.metsSometimesInUnbalancedRxns, 1) + ...
    size(info.reactionsReport.metsAllwaysInUnbalancedRxns, 1);...
    size(info.reactionsReport.metsAllwaysInBalancedRxns, 1) + ...
    size(info.reactionsReport.metsSometimesInUnbalancedRxns, 1);...
    size(info.reactionsReport.metsAllwaysInUnbalancedRxns, 1);...
    size(info.reactionsReport.missingMets, 1)],...
    ...
    'VariableNames', ...
    {'Var'},...
    'RowNames',...
    {'RXN files written'; ...
    'Atom mapped reactions';...
    'Balanced reactions';...
    'Unbalanced reactions';...
    'Missing reactions';...
    'Metabolites obtained'; ...
    'Metabolites in balanced rxns'; ...
    'Metabolites allways in unbalanced rxns'; ...
    'Missing metabolites'});

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
    pieChart = pie(X(find(X)));
    title({'RXN coverage', ['From ' num2str(sum(X)) ' internal rxns in the model']}, 'FontSize', 20)
    legend(labelsToAdd(find(X)), 'FontSize', 16)
    set(findobj(pieChart,'type','text'),'fontsize',18)
    
    % Metabolites
    figure
    labelsToAdd = {'In balanced rxn', 'Ocassionally in unbalanced rxn', 'In unbalanced rxn', 'Missing'};
    X = [size(info.reactionsReport.metsAllwaysInBalancedRxns, 1);...
        size(info.reactionsReport.metsSometimesInUnbalancedRxns, 1);...
        size(info.reactionsReport.metsAllwaysInUnbalancedRxns, 1);...
        size(info.reactionsReport.missingMets, 1)];
    pieChart = pie(X(find(X)));
    title({'Met percentage coverage', ['From ' num2str(size(umets, 1)) ' unique mets in the model']}, 'FontSize', 20)
    legend(labelsToAdd(find(X)), 'FontSize', 16)
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
    save([outputDir '6.debug_endOfreactionDatabase.mat'])
end

%% 7. Bond enthalpies and bonds broken and formed

if ~options.onlyUnmapped    
    
    % Get bond enthalpies and bonds broken and formed
    if options.printlevel  > 0
        display('Obtaining RInChIes and reaction SMILES ...')
        [bondsBF, bondsE, meanBBF, meanBE] = findBEandBBF(model, [rxnDir filesep 'atomMapped'], 1);
        info.bondsData.bondsDataTable = table(model.rxns, model.rxnNames, bondsBF, bondsE, ...
            'VariableNames', {'rxns', 'rxnNames', 'bondsBF', 'bondsE'});
        info.bondsData.meanBBF = meanBBF;
        info.bondsData.meanBE = meanBE;
        display(info.bondsData.bondsDataTable)
    else
        [bondsBF, bondsE, meanBBF, meanBE] = findBEandBBF(model, [rxnDir filesep 'atomMapped']);
        info.bondsData = table(model.rxns, model.rxnNames, bondsBF, bondsE);
        info.bondsData.meanBBF = meanBBF;
        info.bondsData.meanBE = meanBE;
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

function reportComparison = consistentData(model, groupedIDs, typeID)
% The most cross-validated ID is saved. It's compared molecular formula of
% the model, the charge and the similarity with other IDs

% Compare and sort results based on prime numbers. The smallest prime
% number represent the most similar inchis between databases
IDsArray = table2cell(groupedIDs);

% Start report
reportComparison.groupedID = groupedIDs;
reportComparison.sources = groupedIDs.Properties.VariableNames(2:end)';
reportComparison.sourcesToSave = cell(size(IDsArray, 1), 1);

% Delete the Names
metNames = IDsArray(:, 1);
IDsArray(:, 1) = [];
for i = 1:size(IDsArray, 1)
    
    % 1st comparison - Similarity
    emptyBool = cellfun(@isempty, IDsArray(i, 1:end));
    IDsArray(i, emptyBool) = {'noData'};
    [~, ia, ic] = unique(IDsArray(i, 1:end));
    ic(emptyBool) = NaN;
    ia(contains(IDsArray(i, ia), 'noData')) = [];
    if ~isempty(ia)
        ia = sort(ia);
        % Acsending values
        c = 0;
        icAcsending = ic;
        for j = 1:size(ia, 1)
            if ~isnan(ic(ia(j)))
                c = c + 1;
                icAcsending(ic == ic(ia(j))) = c;
            end
        end
        comparison(i, :) = icAcsending';
        
        % 2nd comparison - cross-validation & chemical formulas comparison &
        % InChI data (if is inchi)
        
        % Cross-validation (assign score)
        idsScore = zeros(size(ia, 1), 1);
        for j = 1:size(ia, 1)
            idsScore(j) = idsScore(j)  + (sum(ic == ic(ia(j))) / size(ic, 1));
        end
        
        % Chemical formula comparison
        % Get model formula
        metIdx = find(ismember(regexprep(model.mets, '(\[\w\])', ''), groupedIDs.metNames{i}));
        rGroup = ["X", "Y", "*", "FULLR"];
        if contains(model.metFormulas(metIdx(1)), rGroup)
            modelFormula = editChemicalFormula(model.metFormulas{metIdx(1)});
        else
            modelFormula = model.metFormulas{metIdx(1)};
        end
        reportComparison.(['met_' groupedIDs.metNames{i}]).metNames = model.metNames(metIdx(1));
        reportComparison.(['met_' groupedIDs.metNames{i}]).metFormula = {modelFormula};
        % Get ID formula
        reportComparison.(['met_' groupedIDs.metNames{i}]).uniqueIdIdx = ia;
        for j = 1:size(ia, 1)
            consistentID = IDsArray{i, ia(j)};
            
            switch typeID
                case 'InChI'
                    [elemetList, ~ , ~] = regexp(consistentID, '/([^/]*)/', 'match');
                    if isempty(elemetList)
                        IDformula = '';
                    else
                        IDformula = regexprep(elemetList{1}, '/', '');
                    end
                    
                case 'SMILES'
                    
                    % Get formula from MOL
                    currentDir = pwd;
                    fid2 = fopen([currentDir filesep 'tmp'], 'w');
                    fprintf(fid2, '%s\n', consistentID);
                    fclose(fid2);
                    command = 'obabel -ismi tmp -O tmp.mol mol -h';
                    [~, ~] = system(command);
                    molFile = regexp(fileread([currentDir filesep 'tmp.mol']), '\n', 'split')';
                    if ~isempty(char(molFile))
                        atomsString = [];
                        for k = 1:str2num(molFile{4}(1:3))
                            atomsString = [atomsString strtrim(molFile{4 + k}(32:33))];
                        end
                        IDformula = editChemicalFormula(atomsString);
                    end
                    delete([currentDir filesep 'tmp.mol'])
                    
                case 'MOL'
                    IDformula = consistentID;
            end
            reportComparison.(['met_' groupedIDs.metNames{i}]).sourceFormula{j, 1} = IDformula;
            
            % Compare (assign score)
            if isequal(modelFormula, IDformula)
                idsScore(j) = idsScore(j) + 10; % ten times the scale in cross-validation
            elseif isequal(regexprep(modelFormula, 'H\d*', ''), regexprep(IDformula, 'H\d*', '')) % pH different
                idsScore(j) = idsScore(j)  + 8;
            end
            
            % InChI layers comparison
            switch typeID
                case 'InChI'
                    layersOfDataInChI(j, 1) = size(regexp(IDsArray{i, ia(j)}, '/'), 2);
                    idsScore(j) = idsScore(j) + 4 + layersOfDataInChI(j, 1); % scale in formula comparison
                    reportComparison.(['met_' groupedIDs.metNames{i}]).layersOfDataInChI(j, 1) = ...
                        layersOfDataInChI(j, 1);
                    
                case 'SMILES'
                    
                    fid2 = fopen([currentDir filesep 'tmp'], 'w');
                    fprintf(fid2, '%s\n', IDsArray{i, ia(j)});
                    fclose(fid2);
                    command = 'obabel -ismi tmp -O tmp.mol mol -h';
                    [~, ~] = system(command);
                    molFile = regexp(fileread([currentDir filesep 'tmp.mol']), '\n', 'split')';
                    molFile = regexprep(molFile, 'X|Y|*|R|A', 'H');
                    fid2 = fopen([currentDir filesep 'tmp.mol'], 'w');
                    fprintf(fid2, '%s\n', molFile{:});
                    fclose(fid2);
                    % Get inchis of the original metabolites
                    command = ['obabel -imol ' currentDir filesep 'tmp.mol -oinchi'];
                    [~, result] = system(command);
                    result = split(result);
                    InChINoRGroup = result{contains(result, 'InChI=1S')};
                    layersOfDataInChI(j, 1) = size(regexp(InChINoRGroup, '/'), 2);
                    idsScore(j) = idsScore(j) + 4 + layersOfDataInChI(j, 1); % scale in formula comparison
                    reportComparison.(['met_' groupedIDs.metNames{i}]).layersOfDataInChI(j, 1) = ...
                        layersOfDataInChI(j, 1);
                    delete([currentDir filesep 'tmp'])
                    delete([currentDir filesep 'tmp.mol'])
                    
            end
        end
        
        % Continue report
        reportComparison.(['met_' groupedIDs.metNames{i}]).ids(:, 1) = IDsArray(i, ia);
        reportComparison.(['met_' groupedIDs.metNames{i}]).idsScore = idsScore;
        toSaveidx = find(ismember(ic, ic(ia(idsScore == max(idsScore)))));
        reportComparison.sourcesToSave{i, :} = strjoin(reportComparison.sources(toSaveidx), ' ');
    else
        reportComparison.sourcesToSave{i, :} = '';
    end
end
reportComparison.comparison = comparison;
end
