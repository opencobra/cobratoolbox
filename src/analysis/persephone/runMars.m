function runMars(readsTablePath, varargin)
% This function processes microbiome taxonomy and read abundance
% data and maps microbial species on a microbial reconstruction database,
% such as AGORA2 and APOLLO.
%
% INPUTS:
%   readsTablePath:         String; path to the reads abundance file. If
%                           taxonomic assignment is not present in this
%                           file, provide taxonomy in taxaTablePath.
%   cutoffMars:             Numeric; value under which individual taxa
%                           relative abundances are considered to be zero.
%                           Optional, defaults to 1e-6
%   flagLongSpecies:        Boolean; indicates if the genus name is in the 
%                           name of the species. E.g., if the species name
%                           is Prevotella copri, set to false. If the 
%                           species name is copri set to true. Optional,
%                           defaults to true.
%   taxaDelimiter:          String; delimiter used to separate taxonomic 
%                           levels. Optional, defaults to ;
%   removeClade:            Boolean; specifies to remove clade name 
%                           extensions from all taxonomic levels of 
%                           microbiome taxa. If set to false, MARS might 
%                           find significantly less models in 
%                           AGORA2 and APOLLO databases, as clade 
%                           extensions are not included there. Optional,
%                           defaults to true.
%   reconstructionDb:       String; defining if AGORA2, APOLLO, a 
%                           combination of both (full) or a user-defined database 
%                           should be used as the model database to check 
%                           presence in. Allowed Input (case-insensitive): 
%                           "AGORA2", "APOLLO", "full_db", "user_db".
%                           Optional, defaults to full_db.
%   userDbPath:             String; The path to the user database if
%                           reconstructionDb is set to user_db. Optional,
%                           defaults to ''.
%   sampleReadCountCutoff:  Numeric; value for total read counts per sample
%                           under which samples are excluded from analysis.
%                           If the reads table is already normalised, set 
%                           this value to 0 or 0.1 to ensure that samples 
%                           are not removed.
%   taxaTablePath:          String; path to the file where taxonomies are
%                           matched to taxonomic unit (OTU/ASV etc.) This
%                           requires that the taxonomic unit is present in
%                           the reads table as well in order to match the
%                           taxonomy with the reads. Ensure that the column
%                           with the taxonomic unit has the same header in 
%                           both the reads table and taxonomy table and 
%                           that the column with the taxonomies in the 
%                           taxonomy table is called 'taxon'. Optional,
%                           defaults to ''.
%   outputPathMars:         String; path to the directory where the output 
%                           of MARS is stored. Optional, defaults to
%                           [pwd, filesep, 'resultMars'].
%
% OUTPUTS:
%   The function does not return variables but writes processed results
%   to the specified output directory in the MARS pipeline.
%
% AUTHOR:   Tim Hensen, July 2025
%           Bram Nap, August 2025
% 

% Parse the inputs
parser = inputParser();

parser.addRequired('readsTablePath', @(x)ischar(x)||isstring(x));
parser.addParameter('cutoffMars', 1e-6, @isnumeric);
parser.addParameter('flagLoneSpecies', true, @islogical);
parser.addParameter('taxaDelimiter', ';', @(x)ischar(x)||isstring(x));
parser.addParameter('removeClade', true, @islogical);
parser.addParameter('reconstructionDb', 'full_db', @(x)ischar(x)||isstring(x));
parser.addParameter('userDbPath', '', @(x)ischar(x)||isstring(x));
parser.addParameter('sampleReadCountCutoff', 1, @isnumeric);
parser.addParameter('taxaTablePath', '', @(x)ischar(x)||isstring(x));
parser.addParameter('outputPathMars', [pwd, filesep, 'resultMars'], @(x)ischar(x)||isstring(x));

% Parse required and optional inputs
parser.parse(readsTablePath, varargin{:});

readsTablePath = parser.Results.readsTablePath;
cutoffMars = parser.Results.cutoffMars;
flagLoneSpecies = parser.Results.flagLoneSpecies;
taxaDelimiter = parser.Results.taxaDelimiter;
removeClade = parser.Results.removeClade;
reconstructionDb = parser.Results.reconstructionDb;
userDbPath = parser.Results.userDbPath;
sampleReadCountCutoff = parser.Results.sampleReadCountCutoff;
taxaTablePath = parser.Results.taxaTablePath;
outputPathMars = parser.Results.outputPathMars;

disp('> Starting MARS');

% If output directory doesnt exist, make it
if ~exist(outputPathMars,"dir")
    mkdir(outputPathMars);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% Process taxonomic names %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('> Loading database');

% Load database info containing taxonomic information for microbial
% reconstructions
if strcmpi(reconstructionDb, 'full_db') || strcmpi(reconstructionDb, 'agora2') || strcmpi(reconstructionDb, 'apollo') 
    % If the AGORA2 or APOLLO databases are used, load in the full agora2
    % and apollo information
    database = parquetread('AGORA2_APOLLO_28112024.parquet');
    % If only agora2 or apollo has to be used, remove the other from the
    % full database
    if strcmpi(reconstructionDb, 'agora2')
        database(strcmp(database.Resource, 'APOLLO'),:) = [];
    elseif strcmpi(reconstructionDb, 'apollo')
        database(strcmp(database.Resource, 'AGORA2'),:) = [];
    end
% If user defined database, load that
elseif strcmpi(reconstructionDb, 'user_db')
    if isempty(userDbPath)
        error('You have put user_db in reconstructionDb variable, however the userDbPath is empty and no file was defined. Please choose different database type or provide the proper path to your own database infofile.')
    else
        if contains(userDbPath, '.parquet')
            database = parquetread(userDbPath);
        else
            database = readtable(userDbPath);
        end
    end
else
    error('Wrong database type chosen in reconstrucionDb, choose full_db, agora2, apollo, or user_db')
end

% Load full dataset
microbiome = readtable(readsTablePath);

% Extract the column headers from the reads table
readTableColumn = microbiome.Properties.VariableNames;

% Read taxonomic names
if ~isempty(taxaTablePath)
    % If taxonomy table is given
    taxaTable = readtable(taxaTablePath);

    % Extract the column headers from the taxa table
    taxaTableColumn = taxaTable.Properties.VariableNames;

    % Check if there is a column called taxon in the taxonomy table
    if ~any(strcmpi(taxaTableColumn, 'taxon'))
        error('There does not seems to be a column called Taxon in your taxonomy table. Please check and adjust.')
    end

    % Check if there are any matching column headers between the taxonomy
    % and read tables
    [~,idx, idy] = intersect(readTableColumn, taxaTableColumn, 'stable');

    % Check if there is indeed only one unique column header in both
    % taxonomy and reads tables.
    if length(idx) ~= 1
        error('There seems to be multiple instances of the same column header your reads table, we cannot merge the taxonomy from the taxonomy table to your reads table. Please ensure you have unique column headers in the reads table.')
    elseif length(idy) ~= 1
        error('There seems to be multiple instances of the same column header your taxonomy table, we cannot merge the taxonomy from the taxonomy table to your reads table. Please ensure you have unique column headers in the taxonomy table.')
    end

    % Check if there are no duplicate entries in the taxonomic unit
    % classification column (OTU or ASV or similar)
    if length(unique(table2cell(microbiome(:,idx)))) ~= size(microbiome,1)
        error('It seems like you have duplicate values in the taxonomic unit (OTU/ASV or similar) column in your reads table. Please check and adjust')
    end

    if length(unique(table2cell(taxaTable(:,idy)))) ~= size(taxaTable,1)
        error('It seems like you have duplicate values in the taxonomic unit (OTU/ASV or similar) column in your taxonomy table. Please check and adjust')
    end

    % Find the matching indexes between the taxonomic units
    [~, idxReads, idxTaxa] = intersect(table2cell(microbiome(:,idx)), table2cell(taxaTable(:,idy)), 'stable');

    if length(idxReads) < size(taxaTable,1)
        error('It seems not all of the taxonomic unit classifications could be found in the taxonomy table. Please check and correct or remove. This will lead to that entry not having a proper taxonomic assignemtn and will not be able to processed through MARS')
    end

    % Set the correct taxonomic assignments to the reads
    microbiome.Taxon = table2cell(taxaTable(idxTaxa,strcmpi(taxaTableColumn, 'taxon')));
    % Remove the taxonomic unit assignment column
    microbiome.(string((readTableColumn(idx)))) = [];

    % Set the taxon column as the first column
    microbiome = movevars(microbiome, 'Taxon', 'Before', 1);
else
    % Check if taxon colum exists in the reads table
    if ~any(strcmpi(readTableColumn, 'taxon'))
        error('There is no column called Taxon in your reads table. Please adjust the column header or give a file with taxonomy in the taxaTable variable');
    else
        microbiome.Properties.VariableNames(strcmpi(readTableColumn, 'taxon')) = {'Taxon'};
    end

end

disp('> Renaming and cleaning up of taxonomic assignments');
% Read the taxonomic names
taxonomyInfo = microbiome.Taxon;
taxonomyInfo = append(taxonomyInfo, taxaDelimiter);
taxonomyInfo = string(taxonomyInfo);

% If taxonomic assignments are not in the

% Add species epithet if needed
% TO ADD. TiH

% Rename taxonomic names based on renaming file

% Load the json file into memory
jsonText = fileread('renamingMars.json');
renamingDict = jsondecode(jsonText); % Convert character array to structured array

% TODO: Update json file with additional regular expressions for renaming
% taxon names
renamingDict{1} = expandRenamingDict(renamingDict{1});

% Process taxonomic names based on regular expressions defined in the first
% field of the dictionary.
combinedRegexRemovalExpression = strjoin(renamingDict{1}, '|');
taxonomyInfo_filter1 = regexprep(taxonomyInfo, combinedRegexRemovalExpression, '');

if removeClade
    % Next, remove left over clade information after removal of unnamed taxa
    taxonomyInfo_filter1 = regexprep(taxonomyInfo_filter1, '[a-z]__$', '');

    % Also remove potential clade extensions (e.g. "clade A"; " A")
    taxonomyInfo_filter1 = regexprep(taxonomyInfo_filter1, '_([A-Z]);', ';');
end

% Next, replace taxonomic names based on the defined names in AGORA2/APOLLO

% The json file contains two objects within {...} blocks. Extract them.
objTokens = regexp(jsonText, '\{([^}]*)\}', 'tokens');

% The first two cells relate to the main [] group and the regex expression
% list. Remove them here.
objTokens(1:2) = [];

% For each block, extract key/value pairs
for k = 1:numel(objTokens)
    blockText = objTokens{k}{1};

    % For each row, match the " key " : " value " pair in a cell array
    expression = '"\s*([^"]+?)"\s*:\s*"([^"]*?)"';
    kvTokens = regexp(blockText, expression,'tokens');

    % Concatenate " key " : " value " pairs in a cell array
    renamingDict{k+1} = vertcat(kvTokens{:});
end

% Apply renaming according to dictionary in
taxaNames = taxonomyInfo_filter1;
taxaNames = regexprep(taxaNames, renamingDict{2}(:,1),renamingDict{2}(:,2)); % Rename taxonomic groups
taxaNames = regexprep(taxaNames, renamingDict{3}(:,1),renamingDict{3}(:,2)); % Rename larger taxonomic groups
taxonomyInfo_filter2 = taxaNames;

% Paste updated taxonomic information
microbiome.Taxon = taxonomyInfo_filter2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% Process microbiome data %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If a taxononomic name is duplicated, create a new row with the sum of
% reads of the duplicated rows. Then, delete the duplicated rows.

% Sum the read counts in the duplicated variable names
microbiome = groupsummary(microbiome, "Taxon", "sum");

% Restore table to original format
microbiome = removevars(microbiome,'GroupCount');
% Remove the sum_ from the start of the variable names. Not erase all sum_
% instances as it could be part of the actual sample name
microbiome.Properties.VariableNames(2:end) = cellfun(@(x) x(5:end), microbiome.Properties.VariableNames(2:end), 'UniformOutput',false);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% Map microbiome data on database %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Split taxonomic data into multiple columns
taxaToSplit = microbiome.Taxon;
levels = {'Kingdom','Phylum','Class','Order','Family','Genus','Species'};
levelAbbreviations = ['k','p','c','o','f','g','s'];
expresFun = @(x) ['(?<=',x,'__)(.*?)(?=\',taxaDelimiter,')']; % Get the taxonomy information of interest
regexFun = @(x) regexp(taxaToSplit,expresFun(x),'match'); % Extract matches in regex
taxaInfo = arrayfun(regexFun, levelAbbreviations,'UniformOutput',false); % Run regex for all levels

% Fill cells with missing taxonomic information
% emptyCells = cellfun(@(x) cellfun(@isempty,x), taxaInfo,'UniformOutput',false);
for i = 1:numel(taxaInfo)
    taxaInfo{i}(cellfun(@isempty,taxaInfo{i})) = {""};
end

% Fill cells with missing information but caught the rest of the taxonomy
% names due to the regexpt. E.g. g__;s__bacterium will give ;s__bacterium
% in the taxaInfo on the genus level.
for i = 1:numel(taxaInfo)
    taxaInfo{i}(cellfun(@(x) startsWith(x, taxaDelimiter), taxaInfo{i})) = {""};
end

% Create table with split taxa
taxaInfo = array2table(cellstr(horzcat(taxaInfo{:})),'VariableNames',levels);
taxaInfo.Taxon = taxaToSplit; % Add original vector

% If the previous taxonomic level does not have any taxonomic information,
% the subsequent levels also should not have taxonomic information.
for i = 1:length(levels)-1
    col1 = cellfun(@isempty, (taxaInfo{:,i}));
    taxaInfo(col1,i+1) = {''};
end

x = cellfun(@isempty, table2array(taxaInfo(:, 2:end-1)));

ind = strcmp(taxaInfo.Kingdom, 'Bacteria') & sum(x,2) == 6;

compoundedDatabase = false;
if any(ind)
    kingdomValue = microbiome{ind,2:end};
    resValue = sum(microbiome{strcmp(taxaInfo.Kingdom, 'Bacteria'),2:end});
    compoundedValues = kingdomValue > resValue;
    if sum(compoundedValues) < 0.99*length(compoundedValues)
        compoundedDatabase = true;
    end
end

% Initialise structures to save results in
processedStruc = struct();
mappedStruc = struct();
unmappedStruc = struct();
allMetrics = struct();
forMgpipe = struct();

disp('> Mapping and collecting metrics');
for i = 1:size(levels,2)
    if strcmp(levels{i}, 'Species')
        % If the genus name is not in the species name add it. Otherwise there will
        % be no database matches
        if flagLoneSpecies
            taxaInfo.Species = strcat(taxaInfo.Genus, {' '}, taxaInfo.Species);
        end
    end
    % Adjust database and species names to ensure formatting issues do not
    % cause mismatches. Change (, ), ., _, [, ],- to whitespace
    taxaInfo.(levels{i}) = removePunctuation(taxaInfo.(levels{i}));
    database.(levels{i}) = removePunctuation(database.(levels{i}));
    
    if compoundedDatabase
        rows2Pick = ~cellfun(@isempty, taxaInfo{:, i:end-1});
        rows2Pick = sum(rows2Pick, 2) == 1;
        phylumInput = [taxaInfo.Phylum, taxaInfo.(levels{i})];
        
        [processed, mapped, unmapped, metrics, bray, taxonSummary, taxaSetToZero, summaryMetrics, phylaDistr] = mapTaxaCalcMetrics(phylumInput(rows2Pick,:), database.(levels{i}), microbiome(rows2Pick,:), cutoffMars);

    else
        % Map the taxa onto the database
        [processed, mapped, unmapped, metrics, bray, taxonSummary, taxaSetToZero, summaryMetrics, phylaDistr] = mapTaxaCalcMetrics([taxaInfo.Phylum, taxaInfo.(levels{i})], database.(levels{i}), microbiome, cutoffMars);
    end
    % Store the results in their respective structures
    mappedStruc.(levels{i}) = mapped;
    unmappedStruc.(levels{i}) = unmapped;
    processedStruc.(levels{i}) = processed;

    allMetrics.(levels{i}).metrics = metrics;
    allMetrics.(levels{i}).taxonSummary = taxonSummary;
    allMetrics.(levels{i}).removedTaxa = taxaSetToZero;
    allMetrics.(levels{i}).summaryMetrics = summaryMetrics;
    allMetrics.(levels{i}).brayCurtis = bray;
    allMetrics.(levels{i}).phylaDistr = phylaDistr;

    % Prepare MgPipe outputs
    [panNorm, samplesRemoved] = prepareMgpipe(mapped, sampleReadCountCutoff);
    forMgpipe.(levels{i}).relAbund = panNorm;
    forMgpipe.(levels{i}).removedSamples = samplesRemoved;
end

% Save results
marsSubDirs = {'metrics','mapped','processed','unmapped','mapped_forModelling'};

for i = 1:size(marsSubDirs, 2)
    subDir = strcat(outputPathMars, filesep, marsSubDirs{i});
    if ~exist(subDir, "dir")
        mkdir(subDir);
    end
end

% Save files for the metrics folders
for j = 1:size(levels,2)
    subDir = strcat(outputPathMars, filesep, 'metrics', filesep, levels{j});
    if ~exist(subDir, "dir")
        mkdir(subDir);
    end

    writetable(allMetrics.(levels{j}).metrics, strcat(subDir, filesep, 'generalMetrics.csv'), 'WriteRowNames',true);
    writecell(allMetrics.(levels{j}).removedTaxa, strcat(subDir, filesep, 'removedTaxaPerSample.csv'));
    writetable(allMetrics.(levels{j}).summaryMetrics, strcat(subDir, filesep, 'summaryGeneralMetrics.csv'))

    writetable(allMetrics.(levels{j}).taxonSummary.originalData, strcat(subDir, filesep, 'taxonSummary.xlsx'), "Sheet", 'originalData', 'WriteRowNames',true)
    writetable(allMetrics.(levels{j}).taxonSummary.originalData, strcat(subDir, filesep, 'taxonSummary.xlsx'), "Sheet", 'processedData', 'WriteRowNames',true)
    writetable(allMetrics.(levels{j}).taxonSummary.originalData, strcat(subDir, filesep, 'taxonSummary.xlsx'), "Sheet", 'mappedData', 'WriteRowNames',true)

    writetable(allMetrics.(levels{j}).brayCurtis.originalData, strcat(subDir, filesep, 'brayCurtisDissimilarity.xlsx'), "Sheet", 'originalData', 'WriteRowNames',true)
    writetable(allMetrics.(levels{j}).brayCurtis.originalData, strcat(subDir, filesep, 'brayCurtisDissimilarity.xlsx'), "Sheet", 'processedData', 'WriteRowNames',true)
    writetable(allMetrics.(levels{j}).brayCurtis.originalData, strcat(subDir, filesep, 'brayCurtisDissimilarity.xlsx'), "Sheet", 'mappedData', 'WriteRowNames',true)
    
    % Create and save histograms
    
    % generateStackedBarPlot_PhylumMARScoverage(allMetrics.(levels{j}).phylaDistr.originalData, allMetrics.(levels{j}).phylaDistr.processed, allMetrics.(levels{j}).phylaDistr.mapped)

    histoFig = createHistogram(allMetrics.(levels{j}).metrics, levels{j});
    savefig(histoFig, strcat(subDir, filesep, 'coverageHistograms.fig'))
    exportgraphics(histoFig, strcat(subDir, filesep, 'coverageHistograms.png'))
    close all
end

%%%%%%%%%%%%% Additional descriptive statistics on MARS results %%%%%%%%%%%%%%%%%%%%%%
disp(' > Generate metrics visualizations.');

% 1) Generate stacked barplots comparing pre to post MARS-mapped Pyhlum mean relative abundances
input_stackedBarPlots_preMapping_path = string(fullfile(outputPathMARS, 'metrics', 'Phylum', sprintf('preMapping_abundanceMetrics_Phylum.%s', outputExtensionMARS)));
input_stackedBarPlots_postMapping_path = string(fullfile(outputPathMARS, 'metrics', 'Phylum', sprintf('mapped_abundanceMetrics_Phylum.%s', outputExtensionMARS)));
saveDir_stackedBarPlot_path = string(fullfile(outputPathMARS, 'metrics', 'Phylum'));

% In case the input paths exist run the visualization function on the inputs
% If an error arises in figure creation, skip the step & continue Persephone, but log a warning
if exist(input_stackedBarPlots_preMapping_path, 'file') == 2 && exist(input_stackedBarPlots_postMapping_path, 'file') == 2
    try
        generateStackedBarPlot_PhylumMARScoverage(input_stackedBarPlots_preMapping_path, ...
            input_stackedBarPlots_postMapping_path, saveDir_stackedBarPlot_path, 'mappingDatabase_name', whichModelDatabase)
    catch ME
        warning('Error occurred in generateStackedBarPlot_PhylumMARScoverage function:');
        disp(ME.message);
    end
else
    warning('One or both input files do not exist. Skipping generateStackedBarPlot_PhylumMARScoverage function.');
end

% Save files for the normalised_forModelling folder
removedSamples = levels;
for j = 1:size(levels,2)
    subDir = strcat(outputPathMars, filesep, 'mapped_forModelling');

    writetable(forMgpipe.(levels{j}).relAbund, strcat(subDir, filesep, 'normalised_forModelling', levels{j}, '.csv'));
    if ~isempty(forMgpipe.(levels{j}).removedSamples)
        removedSamples(2:size(forMgpipe.(levels{j}).removedSamples,1)+1, j) = forMgpipe.(levels{j}).removedSamples;
    end
end

% Store which samples were removed due to total reads cutoff
writecell(removedSamples, strcat(outputPathMars, filesep, 'mapped_forModelling', filesep, 'removedSamplesPerTaxa.csv'));

% Save the mapped, unmapped, and processed structures
saveBasicStruct(mappedStruc, strcat(outputPathMars, filesep, 'mapped'), 'mapped');
saveBasicStruct(unmappedStruc, strcat(outputPathMars, filesep, 'unmapped'), 'unmapped');
saveBasicStruct(processedStruc, strcat(outputPathMars, filesep, 'processed'), 'processed');

disp('> MARS finished sucessfully');
end

function saveBasicStruct(struct2Save, outputPath, type)
% Obtain the fields in a structure
fields = fieldnames(struct2Save);

% for each field, save the table to a csv file creating the filepath with
% the output path, type of data and the fieldname
for i = 1:size(fields,1)
    writetable(struct2Save.(fields{i}), strcat(outputPath, filesep, type, '_', fields{i}, '.csv'))
end

end

function [panNorm, samplesRemoved] = prepareMgpipe(data, sample_read_counts_cutoff)
% Store the data in a new variable
panNorm = data;

% Find which samples need to be removed as they are under the total reads
% cutoff
sample2Remove = [false, sum(table2array(panNorm(:, 2:end)))<sample_read_counts_cutoff];

% Remove samples
panNorm(:, sample2Remove) = [];

% Store which samples were removed
samplesRemoved = data.Properties.VariableNames(sample2Remove);

% Normalise the data
panNorm{:, 2:end} = table2array(panNorm(:, 2:end))./(sum(table2array(panNorm(:, 2:end))));

% Add pan in front of the taxa name and replace whitespaces with
% underscores
panNorm.Taxon = strcat('pan', panNorm.Taxon);
panNorm.Taxon = strrep(panNorm.Taxon, ' ', '_');
end

function regexListExpanded = expandRenamingDict(regexList)
% Define expansions
dict = {'CAG-';'RF16';'UPXZ01';'Bact-';'QXHL01';'SXTU01';'UBA[0-9]';'C-19';'VKM-'};
dict = append(dict,'.*$');

% Expand dictionary
regexList = [regexList; dict];
regexListExpanded = regexList;
end

function adjustedArray = removePunctuation(array)
% Replace various characters with a white space
adjustedArray = strrep(array, '_', ' ');
adjustedArray = strrep(adjustedArray, '-', ' ');
adjustedArray = strrep(adjustedArray, '.', ' ');
adjustedArray = strrep(adjustedArray, ',', ' ');
adjustedArray = strrep(adjustedArray, ':', ' ');
adjustedArray = strrep(adjustedArray, ';', ' ');
adjustedArray = strrep(adjustedArray, '(', ' ');
adjustedArray = strrep(adjustedArray, ')', ' ');
adjustedArray = strrep(adjustedArray, '[', ' ');
adjustedArray = strrep(adjustedArray, ']', ' ');

% If a double white space is made, replace with a single white space
adjustedArray = strrep(adjustedArray, '  ', ' ');

end

function [processed, mapped, unmapped, metrics, brayStruct, taxonSummary, taxaSetToZero, summaryMetrics, phylaDistr] = mapTaxaCalcMetrics(taxonomy, database, microbiome, cutoffMars)

% initialise structures to store results in
brayStruct = struct();
taxonSummary = struct();
phylaDistr = struct();

% Set the phylum information to be used later and extract to proper
% taxonomic level used for the call of the function
phylum = taxonomy;
taxonomy = taxonomy(:,2);

% Set the taxonomy with the single level assignemtn for improved
% readability
microbiome.Taxon = taxonomy;
% Make sure the Taxon column is the first column
microbiome = movevars(microbiome, 'Taxon', 'Before', 1);
% Sum all the same taxa together
microbiome = groupsummary(microbiome, "Taxon", "sum");
% Remove variable from groupsummary function
microbiome.GroupCount = [];
% Remove sum_ from sample names
microbiome.Properties.VariableNames(2:end) = cellfun(@(x) x(5:end), microbiome.Properties.VariableNames(2:end), 'UniformOutput',false);

% Replace any empty taxonomic assignemtns to NaN as empty, spaced entries
% can cause issues later
if any(strcmp(microbiome.Taxon, ' '))
    microbiome.Taxon{strcmp(microbiome.Taxon, ' ')} = 'NaN';
end

if any(strcmp(microbiome.Taxon, ''))
    microbiome.Taxon{strcmp(microbiome.Taxon, '')} = 'NaN';
end

% Calculate the unprocessed "raw" total reads present in each sample
if size(microbiome, 1) > 1
    totalReads = sum(table2array(microbiome(:, 2:end)));
else
    % If there is only one taxa, the data as is is already the summed data.
    % If we sum again we will only get 1 value which will cause issues.
    totalReads = table2array(microbiome(:, 2:end));
end

% Copy the microbiome data into the processed variable to process the
% microbiome data
processed = microbiome;
% Remove the row with NaN, removing the reads associated that do not have
% an assignment on that specific taxonomic level
processed(strcmp(processed.Taxon, 'NaN'),:) = [];

% Normalise the processed microbiome data
normalised = processed;
normalised{:, 2:end} = table2array(normalised(:, 2:end))./(sum(table2array(normalised(:, 2:end))));

% Identify any normalised values below the defined cutoff
taxaSetToZero = normalised.Properties.VariableNames(2:end);
for i = 2:size(normalised,2)
    % Find for each column which values to adjust
    toAdjust = normalised{:,i}<cutoffMars & normalised{:,i}>0;
    % Adjust to 0
    processed{toAdjust,i} = 0;
    % Save which taxa were adjusted to 0 for which samples
    taxaSetToZero(2:sum(toAdjust)+1,i-1) = normalised.Taxon(toAdjust);
end

% Calculate the total amount of reads of the processed microbiome data
if size(processed,1) > 1
    readsProcessed = sum(table2array(processed(:,2:end)));
else
    % If there is only one taxa, the data as is is already the summed data.
    % If we sum again we will only get 1 value which will cause issues.
    readsProcessed = table2array(processed(:,2:end));
end

% Check which taxa in the processed micriobme data are found in the
% database
inDatabase = matches(processed.Taxon, database);

% Split the processed microbiome data into mapped and unmapped tables
mapped = processed(inDatabase,:);
unmapped = processed(~inDatabase,:);

% Calculate the total amount of mapped reads
if size(mapped,1) > 1
    mappedReads = sum(table2array(mapped(:,2:end)));
else
    % If there is only one taxa, the data as is is already the summed data.
    % If we sum again we will only get 1 value which will cause issues.
    mappedReads = table2array(mapped(:,2:end));
end

% Calculate the coverages
coverageMappedVsTotal = mappedReads./totalReads;
coverageMappedVsProcessed = mappedReads ./readsProcessed;

% Caluclate the metrics
[brayTotal, pielousTotal, summaryTotal] = calculateMetrics(microbiome);
[brayProcessed, pielousProcessed, summaryProcessed] = calculateMetrics(processed);
[brayMapped, pielousMapped, summaryMapped] = calculateMetrics(mapped);

% Calculate bacteroidetes / firmicutes ratio
[bacFirRatioTotal, phylaDistrTotal] = calcBacFirRatio(microbiome, phylum);
[bacFirRatioProcessed, phylaDistrProcessed] = calcBacFirRatio(processed, phylum);
[bacFirRatioMapped, phylaDistrMapped] = calcBacFirRatio(mapped, phylum);

% Put the various metrics together in one table
metrics = [totalReads
    readsProcessed
    mappedReads
    coverageMappedVsTotal
    coverageMappedVsProcessed
    pielousTotal
    pielousProcessed
    pielousMapped
    bacFirRatioTotal
    bacFirRatioProcessed
    bacFirRatioMapped];

% Create row names
rowNamesMetric = {'Reads original data'
    'Reads processed data'
    'Reads mapped data'
    'Coverage mapped / total'
    'Coverage mapped / Processed'
    'Pielous eveness origina data'
    'Pielous eveness processed data'
    'Pielous eveness mapped data'
    'Bacteroidetes / Firmicutes ratio original data'
    'Bacteroidetes / Firmicutes ratio processed data'
    'Bacteroidetes / Firmicutes ratio mapped data'
    };

% Transform into table
metrics = array2table(metrics, "VariableNames", microbiome.Properties.VariableNames(2:end), "RowNames", rowNamesMetric);

% Store the phylum distributions in a structure
phylaDistr.originalData = phylaDistrTotal;
phylaDistr.processed = phylaDistrProcessed;
phylaDistr.mapped = phylaDistrMapped;

% Store the bray-curtis tables in a structure
brayStruct.originalData = brayTotal;
brayStruct.processed = brayProcessed;
brayStruct.mapped = brayMapped;

% Store the taxon summaries in a structure
taxonSummary.originalData = summaryTotal;
taxonSummary.processed = summaryProcessed;
taxonSummary.mapped = summaryMapped;

% Create summary for metrics
summaryMetrics = [size(microbiome, 1), size(processed,1), size(mapped, 1) % Total number of taxa
    % estimated number of taxa,
    mean(sum(microbiome{:, 2:end} > 0)), mean(sum(processed{:, 2:end} > 0)),mean(sum(mapped{:, 2:end} > 0)) %mean taxa richness
    std(sum(microbiome{:, 2:end} > 0)), std(sum(processed{:, 2:end} > 0)),std(sum(mapped{:, 2:end} > 0)) %st. dev. taxa richness
    mean(pielousTotal), mean(pielousProcessed), mean(pielousMapped) % mean pielous eveness
    std(pielousTotal), std(pielousProcessed), std(pielousMapped) % std pielous eveness
    mean(sum(microbiome{:, 2:end})), mean(sum(processed{:, 2:end})),mean(sum(mapped{:, 2:end})) %mean taxa richness
    std(sum(microbiome{:, 2:end})), std(sum(processed{:, 2:end})),std(sum(mapped{:, 2:end})) %st. dev. taxa richness
    ];
% Add in explanations and coverages as in original MARS?

% Create table
summaryMetrics = array2table(summaryMetrics, 'VariableNames', {'Original data', 'Processed data', 'Mapped data'});

end

function fig = createHistogram(metrics, taxon)

% Set figure size
fig = figure('Position',[571,171,809,682]);
tiledlayout(2,1);
% Initialise figure 1
ax1 = nexttile;

% Plot the histogram
% Adjust coverage of 1 by removing 0.005 so it can be properly be displayed
% on the histogram
toplot = metrics{"Coverage mapped / total",:};
toplot(toplot==1) = toplot(toplot==1) - 0.005;
histogram(toplot, 'BinWidth',0.1);
% Set title and axis and change fonts
subtitle('Coverage of mapped reads over total reads')
ax1.XLim = [0 1];
ax1.FontSize = 12;
ylabel('Number of samples');
xlabel('Fraction')

% Store the axis
axes(1) = ax1;

% Initialise figure 2
ax2 = nexttile;
% Adjust coverage of 1 by removing 0.005 so it can be properly be displayed
% on the histogram
toplot = metrics{"Coverage mapped / Processed",:};
toplot(toplot==1) = toplot(toplot==1) - 0.005;
histogram(toplot, 'BinWidth',0.1);
% Set title and axis and change fonts
subtitle(sprintf('Coverage of mapped reads over total %s-associated reads', lower(taxon)))
ax2.XLim = [0 1];
ax2.FontSize = 12;
ylabel('Number of samples');
xlabel('Fraction');

% Store the axis
axes(2) = ax2;

% ensure figure 1 and figure 2 have the same y-axis
linkaxes(axes, 'y');

end

function [fBRatio, phylumDistr] = calcBacFirRatio(data, phylum)

% Add NaN to phylum as NaN can pop up as a Taxa and we need to account for
% that otherwise the assignment will not work
phylum = [phylum; {'NaN', 'NaN'}];
% Find the phyla associated with the current taxa
[~, ~, idy] = intersect(data.Taxon, phylum(:,2), "stable");
data.Taxon = phylum(idy,1);

% Sum all the same taxa together
data = groupsummary(data, "Taxon", "sum");
% Remove variable from groupsummary function
data.GroupCount = [];
% Remove sum_ from sample names
data.Properties.VariableNames(2:end) = cellfun(@(x) x(5:end), data.Properties.VariableNames(2:end), 'UniformOutput',false);

%Obtain firmicute and bacillota values (they are synonyms
bacillota = table2array(data(strcmp(data.Taxon, 'Bacillota'),2:end));
firmicutes = table2array(data(strcmp(data.Taxon, 'Firmicutes'),2:end));

% Add the bacillota and firmicutes together if possible and define the total
% value for firmicutes.
if ~isempty(firmicutes) && ~isempty(bacillota)
    totFirm = bacillota + firmicutes;
elseif ~isempty(firmicutes)
    totFirm = firmicutes;
elseif ~isempty(bacillota)
    totFirm = bacillota;
else
    totFirm = zeros(1,size(data,2)-1);
end

%Obtain firmicute and bacillota values (they are synonyms
bacteroidota = table2array(data(strcmp(data.Taxon, 'Bacteroidota'),2:end));
bacteroidetes = table2array(data(strcmp(data.Taxon, 'Bacteroidetes'),2:end));

% Add the bacillota and firmicutes together if possible and define the total
% value for firmicutes.
if ~isempty(bacteroidetes) && ~isempty(bacteroidota)
    totBact = bacteroidota + bacteroidetes;
elseif ~isempty(bacteroidetes)
    totBact = bacteroidetes;
elseif ~isempty(bacteroidota)
    totBact = bacteroidota;
else
    totBact = zeros(1,size(data,2)-1);
end

% Calculate the ratio
fBRatio = totFirm ./ totBact;

% Set the grouped phylum table to a new output varialbe
phylumDistr = data;
end

function [bray, pielous, taxonSummary]= calculateMetrics(data)
% Initialise array to store results
bray = zeros(size(data,2), size(data,2));

% Sum all columns for faster caclulation times
dataSummed = [0,sum(data{:, 2:end})];

% Skip first column as that contain taxonomy information
for i = 2:size(data,2)-1
    % Obtain the column of sample 1
    samp1 = table2array(data(:,i));
    % Sum the total reads of sample 1
    sumSamp1 = dataSummed(i);
    
    % Extract the all the other samples in a matrix
    % As pair wise calculation are done, we can move in a step wise
    % progression only comparing i against i+1:end.
    comparisonData = data{:, i+1:end};
    % Make a matrix of sample 1 for improved speed in calculations
    samp1Matrix = repmat(samp1,1,size(comparisonData,2));
    
    % Obtain logical array where sample 1 is smaller than the rest of the
    % samples
    smallestNumber = samp1Matrix < comparisonData;
    % Use the logical indexes to replace the larger values in the rest of
    % the samples with the smaller value from sample 1
    comparisonData(smallestNumber) = samp1Matrix(smallestNumber);
    
    % Calculate bray-curtis dissimilarity
    bray(i+1:end,i) = 1-(2*sum(comparisonData))./(sumSamp1 + dataSummed(i+1:end));
    bray(i,i+1:end) = 1-(2*sum(comparisonData))./(sumSamp1 + dataSummed(i+1:end));
end

% Convert to table
bray = array2table(bray(2:end, 2:end), 'RowNames', data.Properties.VariableNames(2:end)', 'VariableNames',data.Properties.VariableNames(2:end));

% Calculate pielous evenness
pielous = zeros(1,size(data,2)-1);

for i = 2:size(data,2)
    % Remove taxa with 0 reads from the column
    norm = table2array(data(data{:,i}>0,i));
    % Calculate the normalised values
    norm = norm./sum(norm);
    % Caluclate pielous eveness
    pielous(i-1) = -1*sum(norm.*log(norm))/log(size(norm,1));
end

arrayData = table2array(data(:,2:end));
% Calculate taxon abundance summaries
taxonSummary = [mean(arrayData,2),...% Mean amount of reads for a taxon
    std(arrayData,[],2),... % St. dev reads for a taxon
    min(arrayData, [], 2),...% Lowest amount of reads for a taxon
    max(arrayData, [], 2),...% Highest amoutn of reads for a taxon
    sum(arrayData>0,2)]; % Number of samples that have non zero reads for a taxon

% Convert to table
taxonSummary = array2table(taxonSummary, 'VariableNames', {'Mean reads', 'St. dev.', 'Min. Reads', 'Max. Reads', 'Samples with non zero value'}, ...
    'RowNames',data.Taxon);

end