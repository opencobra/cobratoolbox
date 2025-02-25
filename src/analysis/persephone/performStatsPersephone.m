function results = performStatsPersephone(statPath, pathToProcessedFluxes, metadataPath, response, varargin)
% The performStatistics function is part of the PSCM toolbox. This
% function performs regression analyses on processed fluxes and gut
% microbiome relative abundance data in large cohort studies. This function needs a 
% minimal sample size of 50 samples. This function performs different
% statistical analyses depending on the user defined inputs.
%
% If the response variable is binary and no confounders are given,
% wilcoxon tests will be performed for the fluxes and microbiome
% abundances.
% If the response variable is binary and confounders are given, multiple
% logistic regressions will be performed. 
% If the response variable is continuous and no confounders are given,
% simple linear regressions will be performed. 
% If the response variable is continuous and confounders are given,
% multiple linear regressions will be performed.  
% 
% The fluxes are z-transformed before statistical testing. The microbiome
% relative abundances are log transformed before testing. 
% If a moderator variable is given and a regression is
% performed, a moderation analysis on the moderator with the predictor will be performed. 
%
% USAGE:
%    performStatistics(statPath, pathToProcessedFluxes, pathToWbmRelAbundances, metadataPath, response, confounders, moderator, microbeCutoff,threshold)
% 
% INPUT
% statPath                          Path (character array) to working directory
% pathToProcessedFluxes                 Path to processed flux data
% pathToWbmRelAbundances                  Path to microbial relative abundances 
% metadataPath                      Path to metadata file
% response                          Name of response variables (char or string)
%
% OPTIONAL INPUTS
% confounders                       Cell array with the names of confounding variables to
%                                   be included. Default = empty.
% microbeCutoff                     Cutoff threshold for the number of samples a
%                                   microbe needs to present to be analysed. Default = 0.1. (10%)
%
% .. Author:
%       - Tim Hensen       July, 2024
%       - Jonas Widder     November, 2024 (integrated moderation analysis)
%       NOTE: To be finalised at a later stage.

% Define default parameters if not defined
parser = inputParser();
parser.addRequired('statPath', @ischar);
parser.addRequired('pathToProcessedFluxes',  @(x) ischar(x) | isstring(x));
parser.addRequired('metadataPath', @(x) ischar(x) | isstring(x));
parser.addRequired('response', @(x) ischar(x) | isstring(x));

parser.addParameter('pathToWbmRelAbundances', @(x) ischar(x) | isstring(x));
parser.addParameter('confounders', '', @iscell);
% Moderation analysis will be added back later
%parser.addParameter('moderator', '', @iscell); 
%parser.addParameter('moderationThreshold_usePValue', true, @islogical)
%parser.addParameter('moderationThreshold', 0.05, @isnumeric);
parser.addParameter('microbeCutoff', 0.1, @isnumeric);
parser.addParameter('alternativeVulcanoPlotTitle', '', @(x) ischar(x) | isstring(x));

% Parse required and optional inputs
parser.parse(statPath, pathToProcessedFluxes, metadataPath, response, varargin{:});

statPath = parser.Results.statPath;
pathToProcessedFluxes = parser.Results.pathToProcessedFluxes;
metadataPath = parser.Results.metadataPath;
response = parser.Results.response;

pathToWbmRelAbundances = parser.Results.pathToWbmRelAbundances;
confounders = parser.Results.confounders;
microbeCutoff = parser.Results.microbeCutoff;
alternativeVulcanoPlotTitle = parser.Results.alternativeVulcanoPlotTitle;

% Check if gut microbiota need to be tested
testMicrobiota = false;
if ~isempty(pathToWbmRelAbundances)
    testMicrobiota = true;
end


% Setup folder for results:
% Create directory where all results will be saved
statPathFull = fullfile(statPath,char(response));
if exist(statPathFull,'dir')~=7
    mkdir(statPathFull)
end

% Check if the statistics toolbox is installed
if matlab.addons.isAddonEnabled('Statistics and Machine Learning Toolbox') ==0
    error('No statistical analyses can be performed without the Statistics and Machine Learning Toolbox. Please install this toolbox or manually investigate the flux results.')
end

% Create empty variable for log file
logfile = {};

% Provide information to user
disp(strcat("Investigate variable: ",string(response)))


%%% PART 1: Load and process the flux results, metadata, and microbiome
%%% relative abundances.

% Load and investigate metadata
[metadata, logfile] = loadAndInvestigateMetadataForStats(metadataPath, response, statPath, logfile);

% Load flux data
fluxes = readDataForStats(pathToProcessedFluxes);
logfile{end+1} = 'Load flux data';

% Log2 transform the flux data and then normalise the fluxes using z-score
% transformation
fluxes = processDataForStats(fluxes);
logfile{end+1} = 'Normalise fluxes via z-score transformation';

if testMicrobiota == true
    % Load microbiome data
    microbiome = readDataForStats(pathToWbmRelAbundances);
    logfile{end+1} = 'Load the processing species relative abundances';
    
    % Filter on microbes present in at least microbeCutoff% of samples
    microbesToRemove = find( sum(~isnan(microbiome{:,2:end}),1) < (size(microbiome,1)*microbeCutoff) ) + 1;
    microbiome(:,microbesToRemove)=[];
    logfile{end+1} = ['Remove microbial species present in less than' char(string(microbeCutoff*100)) '% of samples'];
    
    % Log2 transform the microbiome data and then normalise the relative abundances using z-score
    % transformation
    microbiome = processDataForStats(microbiome);
    logfile{end+1} = 'Perform a log2 transformation on the microbial species abundances and then normalize the relative abundances via z-score transformation';
end

%%% PART 2: Obtain statistics for the fluxes and relative abundance data.
%%% For both types of data, the following analyses are performed:
%%% 1) Wilcoxon rank sum tests on sex
%%% 2) Wilcoxon rank sum tests on the user defined response variable, e.g,
%%% cases and controls.
%%% 3) Regressions on the user defined response variable against the
%%% fluxes/relative abundances, while controlling for sex.
%%% Only if confounders are given: 
%%% 4) Regressions on the user defined response variable against
%%% fluxes/relative abundances and the other user defined confounders, e.g.
%%% , age, bmi, and sex. 
%%% Only if moderators are given additionally to the confounders:
%%% 5) Regressions on the user defined response variable against
%%% fluxes/relative abundances and the other user defined confounders, e.g.
%%% , age, bmi, and sex, with interactions between fluxes/relative abundances
%%% and the moderator. Following are regressions on the moderator stratified fluxes. 
%%
disp('Perform statistical analyses on fluxes and gut microbiota abundances')

% Perform analyses on the fluxes
predictor = 'Flux';
[fluxStats, logfile] = runStatistics(fluxes, metadata, response, predictor, confounders, logfile, statPathFull);

if testMicrobiota == true
    % Perform analyses on the relative abundances
    predictor = 'relative_abundance';
    [microbiotaStats, logfile] = runStatistics(microbiome, metadata, response, predictor, confounders, logfile, statPathFull);
end

%%% PART 3: Annotate the investigated reactions by finding the the reaction
%%% descriptions or common metabolite names if a demand or sink reaction
%%% was investigated. Additionally, the reaction subsystems are added to
%%% the table. 
annotationTable = annotateInvestigatedRxns(fluxes);
annotationCell = {'Reaction annotation information', annotationTable};
logfile{end+1} = 'The investigated reactions are annotated by providing reaction descriptions and subsystem information';


%%% PART 4: Save results as an excel file with an index explaining each
%%% table.
results = saveStatisticalResults(logfile,testMicrobiota,annotationCell,fluxStats,microbiotaStats,statPath);
%%

%%% PART 5: Visualise the flux results
if 0 % TO BE DEBUGGED
    pathTofluxMicrobeCorr = '';
    visualisations(fluxStats,annotationTable,alternativeVulcanoPlotTitle,response,statPath,pathTofluxMicrobeCorr,microbeCutoff,microbiotaStats);
end

end

function [metadata, logfile] = loadAndInvestigateMetadataForStats(metadataPath, response, statPath, logfile)
% PROCESSMETADATA Loads and processes metadata for statistical analysis.
%
% Inputs:
%   metadataPath - Path to the metadata file
%   response - Response variable name (string)
%   statPath - Path to save statistical outputs
%   logfile - Cell array to store log messages
%
% Outputs:
%   Processed metadata file
%   Updated logfile with processing steps

% Load metadata
metadata = readMetadataForPersephone(metadataPath);
metadata.Properties.VariableNames(1) = {'ID'};
metadata.Sex = string(metadata.Sex);
logfile{end+1} = 'Load metadata file';

% Remove rows without information on the response variable
responseVar = string(metadata.(string(response)));
metadata(ismissing(responseVar) | matches(responseVar, ""), :) = [];
logfile{end+1} = 'Remove rows from metadata without information on the response variable';

% Check sample size
if height(metadata) < 40
    warning('The sample size might be too low to produce reliable statistics.');
    logfile{end+1} = lastwarn;
end

% Ensure at least two categories exist in the response variable
if isscalar(unique(metadata.(string(response))))
    error('Only one category is present in the response. Please provide two or more categories.');
end

% Process categorical response variables
if ~isnumeric(metadata.(response))
    [crosstabulationTable, ~, ~, labels] = crosstab(metadata.(response), metadata.Sex);
    
    % Remove empty labels
    rowNames = labels(:,1);
    colNames = labels(:,2);
    rowNames(cellfun('isempty', rowNames)) = [];
    colNames(cellfun('isempty', colNames)) = [];
    
    % Convert to table format
    crosstabulationTable = array2table(crosstabulationTable, 'RowNames', rowNames, 'VariableNames', colNames);
    logfile{end+1} = 'Calculate the number of cases and controls for male and female samples';
    
    % Generate heatmap
    fig = figure;
    heatmap(metadata, 'Sex', response);
    
    % Save figure
    heatmapPath = fullfile(statPath, 'Case_control_sample_counts.fig');
    savefig(fig, heatmapPath);
    close(fig);
    logfile{end+1} = ['Heatmap saved at: ' heatmapPath];
end
end

function data = readDataForStats(pathToData)

% Read data from file
data = readtable(pathToData,'VariableNamingRule','preserve');

% Rename the Row column to ID
if any(matches(data.Properties.VariableNames,'Row','IgnoreCase',true))
    data = renamevars(data,'Row','ID');
end

% Remove sex information if present
if any(matches(data.Properties.VariableNames,'sex','IgnoreCase',true))
    data.Sex = [];
end

% Process the sample ID names to align with the metadata IDs
data.ID = erase(data.ID,{'mWBM_','miWBM_','muWBM_','_female','_male'});
end

function dataProcessed = processDataForStats(data)

% Select all numerical informations
dataToProcess = table2array(data(:,2:end));

% Set all zeros to nan
dataToProcess(dataToProcess <= 0) = nan;

% Log transform the data
dataLog2 = log2(dataToProcess);

% Normalise the data using z-transformation
dataNorm = normalize(dataLog2);

% Add data back to table
dataProcessed = data;
dataProcessed{:,2:end} = dataNorm;
end

function [annotationTable,dmSinkRxns] = annotateInvestigatedRxns(fluxes)
% Add metabolite and subystem information to the investigated VMH reaction
% IDs

disp('Annotate investigated reactions')

% Get reaction VMH names
reactions = fluxes.Properties.VariableNames;

% Remove ID index
reactions(matches(reactions,'ID')) = [];

% Create table with reactions
annotationTable = array2table(reactions','VariableNames',{'Reaction'});
annotationTable.Description = cell(size(annotationTable,1),1);
annotationTable.Subsystem = cell(size(annotationTable,1),1);

% Load VMH database
database = loadVMHDatabase;

% If the investigated reactions are demand or sink reactions, annotate the
% associated metabolite

% Find the demand and sink reactions and filter out the investigated
% metabolite
dmSinkRxns = contains(annotationTable.Reaction,{'DM_','Sink_'});

% Filter out the metabolite vmh ids
if sum(dmSinkRxns)>0
    metabolites = erase(annotationTable.Reaction(dmSinkRxns),{'DM_','Sink_'});
    metabolites = extractBefore(metabolites,'[');

    % Find metabolite descriptions
    [~,~,ib] = intersect(metabolites,database.metabolites(:,1),'stable');

    % Add metabolite annotations to the table
    metAnnotations = database.metabolites(ib,[1 2 13]);
    annotationTable.Description(dmSinkRxns) = metAnnotations(:,2);
    annotationTable.Subsystem(dmSinkRxns) = metAnnotations(:,3);
end

if sum(~dmSinkRxns)>0
    % Annotate reactions
    reactionsToAnnotate = annotationTable.Reaction(~dmSinkRxns);
    reactionsToAnnotate = extractAfter(reactionsToAnnotate,'_');

    % Find reaction descriptions
    [~,~,ib] = intersect(reactionsToAnnotate,database.reactions(:,1),'stable');    

    % Add reaction annotations to the table
    rxnAnnotations = database.reactions(ib,[1 2 12]);
    annotationTable.Description(~dmSinkRxns) = rxnAnnotations(:,2);
    annotationTable.Subsystem(~dmSinkRxns) = rxnAnnotations(:,3);
end
end

function [statResults, logfile] = runStatistics(data, metadata, response, predictor, confounders, logfile, statPathFull)
% Performs step-wise statistical analysis of the fluxes
%
% Step 1: sex ~ flux
% Step 2: response ~ flux
% Step 3: response ~ flux + sex
% Step 4: response ~ flux + sex + ...
% Step 5: Save results in a single table
% Step 6, [TO BE ADDED LATER] if moderatorAnalysis needs to be performed: Run regressions on
% moderator stratified data as well and save results in single table.
%
% INPUTS:
%   data:                               [Table] Processed flux/relative abundances data.
%   metadata:                           [Table] Metadata containing ID & pot. additional variables 
%                                       (confounders, moderators)
%   formula:                            [String] Regression formula in Wilkinson notation.
%   response:                           [Character array | String] Response variable for regression.
%   predictor:                          [Character array | String] Predictor variable for regression.
%                                       Needs to be either 'Flux' or 'relative_abundance'.
%   regressionResults:                  [Struct] Structure containing tables for flux &
%                                       rel. abundances regression results.
%   moderationThreshold_usePValue:      [Boolean] Cutoff threshold being either
%                                       FDR or pValue.
%                                       Default = true.
%   moderationThreshold:                [Numerical] Cutoff threshold for maximal FDR value from
%                                       moderation analysis a metabolite needs to
%                                       pass that it will be included in subsequent 
%                                       analysis of stratified fluxes.
%                                       Default = 0.05 (5%).
%   statPath:                            [Character array] Path to working directory.
%
% OUTPUTS:
%   statResults:                        [Struct] Structure containing tables for flux & 
%                                       relative abundances regression results.
%   statResults_stratifiedModerator:    [Struct] Structure containing tables for flux
%                                       regression results for moderator stratified data
%                                       of significant hits from initial from moderation 
%                                       analysis regressions.
%                                       Will be empty, if regression does not contain Flux.
%
% AUTHORS:
%   - Tim Hensen
%   - Jonas Widder, 11/2024 (integrated moderation analysis)

% Logical flow on which statistical tests will be performed. 

% The types of analyses will be based on the data type of the variable of
% interest.
responseMetadataVar = metadata.(string(response));


% Preallocate all possible analysis types
wilcoxon = false;
kruskal = false;
simpleLinRegression = false;
linRegControlForSex = false;
linRegControlForSexAndOtherConfounders = false;
simplelogisticReg = false;
logisticRegControlForSex = false;
logisticRegControlForSexAndOtherConfounders = false;

% Decide which types of investigations are performed
switch length(unique(responseMetadataVar))
    case 1
        error('Please make sure that the response variable of interest has more than one categories')
    case 2
        if isempty(confounders)
            wilcoxon = true;
            simplelogisticReg = false;
            logisticRegControlForSex = true;
        else
            wilcoxon = true;
            simplelogisticReg = false;
            logisticRegControlForSex = true;
            logisticRegControlForSexAndOtherConfounders = true;
        end
    otherwise
        if ~isnumeric(responseMetadataVar)
            kruskal = true;
        else
            if isempty(confounders)
                simpleLinRegression = true;
                linRegControlForSex = true;
            else
                simpleLinRegression = true;
                linRegControlForSex = true;
                linRegControlForSexAndOtherConfounders = true;
            end

        end
end

% Preallocate structured variable for statistical results
statResults = cell(8,2);
statResults(1,:) = {'Description','Results'};

rowCount = 1;

if wilcoxon == true
    rowCount = rowCount + 1;
    % Description
    statResults{rowCount,1} = strcat('Two sided wilcoxon rank sum test results for sex ~ ', predictor);
    % Status
    logfile{end+1} = statResults{rowCount,1};
    % Result
    statResults{rowCount,2} =  runNonparametricTests(data, metadata, predictor, 'Sex');

    rowCount = rowCount + 1;
    % Description
    statResults{rowCount,1} = strcat('Two sided wilcoxon rank sum test results for', response ,' ~ ', predictor);
    % Status
    logfile{end+1} = statResults{rowCount,1};
    % Result
    statResults{rowCount,2} =  runNonparametricTests(data, metadata, predictor, response);    
end

if kruskal == true
    rowCount = rowCount + 1;
    % Description
    statResults{rowCount,1} = strcat('Kruskall wallis test results for sex ~ ', predictor);
    % Status
    logfile{end+1} = statResults{rowCount,1};
    % Result
    statResults{rowCount,2} =  runNonparametricTests(data, metadata, predictor, 'Sex');

    rowCount = rowCount + 1;
    % Description
    statResults{rowCount,1} = strcat('Two sided wilcoxon rank sum test results for', response ,' ~ ', predictor);
    % Status
    logfile{end+1} = statResults{rowCount,1};
    % Result
    statResults{rowCount,2} =  runNonparametricTests(data, metadata, predictor, response);   
end

if simpleLinRegression == true

    rowCount = rowCount + 1;
    % Description
    formula = char(append(response,'~',predictor));
    statResults{rowCount,1} = strcat('Simple linear regression results for', formula);
    % Status
    logfile{end+1} = statResults{rowCount,1};   
    % Result
    regRes = performRegressions(data,metadata,formula);
    % Visualise regressions and save result
    resultToVis = string(fieldnames(regRes));
    regressionResults = regRes.(resultToVis(1));
    fig = visualiseRegressionFit(regressionResults, response, formula, statPathFull); close(fig)
    % Add results to table
    statResults{rowCount,2} = regRes.(predictor); 
end

if linRegControlForSex == true

    rowCount = rowCount + 1;
    % Description
    formula = char(append(response,'~',predictor,'+Sex'));
    statResults{rowCount,1} = strcat('Linear regression results for',formula);
    % Status
    logfile{end+1} = statResults{rowCount,1};   
    % Result
    regRes = performRegressions(data,metadata,formula);
    % Visualise regressions and save result
    resultToVis = string(fieldnames(regRes));
    regressionResults = regRes.(resultToVis(1));    
    fig = visualiseRegressionFit(regressionResults, response, formula, statPathFull); close(fig)
    % Add results to table    
    statResults{rowCount,2} = regRes.(predictor); 
end

if linRegControlForSexAndOtherConfounders == true

    rowCount = rowCount + 1;
    % Description
    formula = append(response,'~',predictor,'+Sex+',strjoin(confounders,'+'));
    statResults{rowCount,1} = strcat('Linear regression results for',formula);
    % Status
    logfile{end+1} = statResults{rowCount,1};    
    % Result
    regRes = performRegressions(data,metadata,formula);
    % Visualise regressions and save result
    resultToVis = string(fieldnames(regRes));
    regressionResults = regRes.(resultToVis(1));    
    fig = visualiseRegressionFit(regressionResults, response, formula, statPathFull); close(fig)
    % Add results to table    
    statResults{rowCount,2} = regRes.(predictor); 
end

if simplelogisticReg == true

    rowCount = rowCount + 1;
    % Description
    formula = char(append(response,'~',predictor));
    statResults{rowCount,1} = strcat('Simple Logistic regression results for', formula);
    % Status
    logfile{end+1} = statResults{rowCount,1};
    % Result
    regRes = performRegressions(data,metadata,formula);
    % Visualise regressions and save result
    resultToVis = string(fieldnames(regRes));
    regressionResults = regRes.(resultToVis(1));    
    fig = visualiseRegressionFit(regressionResults, response, formula, statPathFull); close(fig)
    % Add results to table    
    statResults{rowCount,2} = regRes.(predictor); 
end

if logisticRegControlForSex == true

    rowCount = rowCount + 1;
    % Description
    formula = char(append(response,'~',predictor,'+Sex'));
    statResults{rowCount,1} = strcat('Logistic regression results for', formula);
    % Status
    logfile{end+1} = statResults{rowCount,1};
    % Result
    regRes = performRegressions(data,metadata,formula);
    % Visualise regressions and save result
    resultToVis = string(fieldnames(regRes));
    regressionResults = regRes.(resultToVis(1));    
    fig = visualiseRegressionFit(regressionResults, response, formula, statPathFull); close(fig)
    % Add results to table    
    statResults{rowCount,2} = regRes.(predictor); 
end

if logisticRegControlForSexAndOtherConfounders == true

    rowCount = rowCount + 1;
    % Description
    formula = append(response,'~',predictor,'+Sex+',strjoin(confounders,'+'));
    statResults{rowCount,1} = strcat('Logistic regression results for', formula);
    % Status
    logfile{end+1} = statResults{rowCount,1};
    % Result
    regRes = performRegressions(data,metadata,formula);
    % Visualise regressions and save result
    resultToVis = string(fieldnames(regRes));
    regressionResults = regRes.(resultToVis(1));    
    fig = visualiseRegressionFit(regressionResults, response, formula, statPathFull); close(fig)
    % Add results to table    
    statResults{rowCount,2} = regRes.(predictor); 
end

% Remove empty rows
statResults(cellfun(@isempty,statResults(:,1)),:)=[];

end

function fig = visualiseRegressionFit(regressionResults, response, formula, statPathFull)

% Collect input for vulcano plot
estimates = regressionResults.estimate;
pValues = regressionResults.pValue;
names = regressionResults{:,1};

% Set plot parameters
plotTitle= {['Metabolic flux associations with ' response ], ['Regression formula: ' formula]};

xTitle = 'Regression estimate';
yTitle = '-log10 p-value';

fig=figure('Position',[571,171,809,682]);

% Create vulcano plot
createVulcanoPlot(estimates,pValues,names,plotTitle,xTitle,yTitle);

% Save figure
exportgraphics(fig,[statPathFull, 'vulcanoPlot_' formula '.png'])
end


function allRes = saveStatisticalResults(logfile,testMicrobiota,annotationCell,fluxStats,microbiotaStats,statPath)
% Combine results
allResultsHeader = {'Description','Data'};
logFileTable = cell2table(logfile','VariableNames',{'Log'});
logFileCell = {'Log file', logFileTable};

if testMicrobiota == true
    % Combine all results
    allRes = [allResultsHeader ; annotationCell; fluxStats(2:end,:); microbiotaStats(2:end,:); logFileCell];
else
    % Combine all results
    allRes = [allResultsHeader ; annotationCell; fluxStats(2:end,:); logFileCell];
end

% Add table number to description
for i=2:height(allRes)
    allRes{i,1} = append('Table_', string(i-1),': ',allRes{i,1});
end

% Save results table to excel file
sheetNames = ["Index" append("Table_",string(1:height(allRes)-1))];
resultPath = [statPath filesep 'statistical_results.xlsx'];

% Remove excel file if it already exists to prevent partial overwriting.
if ~isempty(which(resultPath))
    delete(resultPath);
end

% Write index sheet
writematrix(string(allRes(:,1)),resultPath,'Sheet',sheetNames(1));

% Save all results
for i = 2:height(allRes)
    % Get result
    sheet = allRes{i,2};
    % Write to table
    writetable(sheet,resultPath,'Sheet',sheetNames(i),'WriteRowNames',true,'PreserveFormat',true)
end
end
