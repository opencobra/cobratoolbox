function [FBA_results, pathsToFilesForStatistics] = analyseWBMsol(fluxPath,paramFluxProcessing, fluxAnalysisPath)
% analyseWBMsol loads the FBA solutions produced in 
% analyseWBMs.m, prepares the FBA results for further
% analyses, and produces summary statistics into the flux results. 
%
% The function contains six parts:
%       - PART 1: Loading the flux solutions and corresponding shadow prices
%       - PART 2: Converting the microbial  biomass shadow prices
%       associated with each optimised reaction flux to human readable
%       tables and producing statistics on microbial influences on the flux
%       results.
%       - PART 3: Isolate the microbial component of the fluxes by
%       subtracting the germ-free fluxes in a sex specific manner. In this
%       part, descriptive statistics are also obtained on the fluxes across
%       samples and metabolites are removed based on a user defined
%       threshold (see thresholds input)
%       - PART 4: In this part, microbe-flux associations defined by the
%       species biomass shadow prices (PART 2) are further quantified by
%       performing Spearman correlations on the fluxes and microbe relative
%       abundances. 
%       - PART 5: Reactions with identical or near identical fluxes across
%       samples (user defined) are grouped and collapsed into a single
%       result. 
%       - PART 6: Save all results
%
% USAGE:
%       [FBA_results, pathsToFilesForStatistics] = analyseWBMsol(fluxPath,paramFluxProcessing, fluxAnalysisPath)
%
% INPUTS:
% fluxPath         Character array with path to .mat files produced in
%                     optimiseRxnMultipleWBM.m
%
% paramFluxProcessing       Structured array with optional parameters:
%
%                     .numericalRounding defines how much the predicted flux values are
%                     rounded. A defined value of 1e-6 means that a flux value of
%                     2 + 2.3e-8 is rounded to 2. A flux value of 0 + 1e-15 would be rounded to
%                     exactly zero. This rounding factor will also be applied to the shadow 
%                     price values. If microbiome relative abundance data is provided, the same
%                     rounding factor will be applied to the relative abundance data.
%                     
%                     Default parameterisation: 
%                     - paramFluxProcessing.numericalRounding = 1e-6;
%                     
%                     Example: 
%                     - paramFluxProcessing.numericalRounding = 1e-6;
%                     
%                     paramFluxProcessing.numericalRounding = 1e-6;
%                     
%                     .rxnRemovalCutoff defines the minimal number of samples for which a
%                     unique reaction flux could be obtained, before removing the reaction for 
%                     further analysis. This parameter can be expressed as 
%                     * fraction:  the fraction of samples with unique values, 
%                     * SD: the standard deviation across samples, and
%                     * count: the counted number of unique values. If microbiome relative 
%                     abundance data is provided, the same removal cutoff factor will be 
%                     applied to the relative abundance data.
%                     
%                     Default parameterisation: 
%                     - paramFluxProcessing.rxnRemovalCutoff = {'fraction',0.1};
%                     
%                     Examples: 
%                     - paramFluxProcessing.rxnRemovalCutoff = {'fraction',0.1};
%                     - paramFluxProcessing.rxnRemovalCutoff = {'SD',1};
%                     - paramFluxProcessing.rxnRemovalCutoff = {'count',30};
%                     
%                     paramFluxProcessing.rxnRemovalCutoff = {'fraction',0.1};
%                     RxnEquivalenceThreshold
%                     .rxnEquivalenceThreshold defines the minimal threshold of when 
%                     functionally identical flux values are predicted, and are thus part of
%                     the same linear pathways. The threshold for functional equivalence is
%                     expressed as the R2 (r-squared) value after performing a simple linear 
%                     regression between two reactions.  
%                     
%                     Default parameterisation: 
%                     - paramFluxProcessing.rxnEquivalenceThreshold = 0.999;
%                     
%                     Example: 
%                     - paramFluxProcessing.rxnEquivalenceThreshold = 0.999;
%                     
%                     paramFluxProcessing.rxnEquivalenceThreshold = 0.999;
%                     
%                     .fluxMicrobeCorrelationMetric defines the method for correlating the 
%                     predicted fluxes with microbial relative abundances. Note that this
%                     metric is not used if mWBMs are not present. The available correlation
%                     types are: 
%                     * regression_r2:  the R2 (r-squared) value from pairwised linear regression on the 
%                     predicted fluxes against microbial relative abundances.
%                     * spearman_rho: the correlation coefficient, rho obtained from pairwise
%                     Spearman nonparametric correlations between predicted fluxes and 
%                     microbial relative abundances. 
%                     
%                     Default parameterisation: 
%                     - paramFluxProcessing.fluxMicrobeCorrelationMetric = 'regression_r2';
%                     
%                     Examples: 
%                     - paramFluxProcessing.fluxMicrobeCorrelationMetric = 'regression_r2';
%                     - paramFluxProcessing.fluxMicrobeCorrelationMetric = 'spearman_rho';
%
% fluxAnalysisPath             
%                     Character array with path to directory where all
%                     results will be saved.
%
% AUTHOR:
%   - Tim Hensen, July 2024
%   - Jonas Widder, 11/2024 (small bugfixes)

% Validate function inputs
validateattributes(fluxPath, {'char', 'string'}, {'nonempty'}, mfilename, 'fluxPath',1)
validateattributes(paramFluxProcessing, {'struct'}, {'nonempty'}, mfilename, 'paramFluxProcessing',2)
validateattributes(fluxAnalysisPath, {'char', 'string'}, {'nonempty'}, mfilename, 'fluxPath',3)

% Set default parameter values for if fields in paramFluxProcessing are
% missing.
defaultParams=struct;
defaultParams.numericalRounding = 1e-6;
defaultParams.rxnRemovalCutoff = {'fraction', 0.1};
defaultParams.rxnEquivalenceThreshold = 0.999;
defaultParams.fluxMicrobeCorrelationMetric = 'spearman_rho';

% Check if all fields in paramFluxProcessing are present. Add fields with
% default values if one or more fields are not present. 
defaultFields = string(fieldnames(defaultParams));
fieldPresent = find(~isfield(paramFluxProcessing,defaultFields));
for i = 1:length(fieldPresent)
    paramFluxProcessing.(defaultFields(fieldPresent(i))) = defaultParams.(defaultFields(fieldPresent(i)));
end

% Find the number of digits right of the decimal point to round the flux
% values. 
fluxCutoff = paramFluxProcessing.numericalRounding;

% Convert the cutoff value to a string in scientific notation; then extract
% the last character and convert that character back to a numerical type. 
paramFluxProcessing.roundingFactor  = double(regexp(string(num2str(fluxCutoff,'%g')),'.$','match'));

%% PART 1: Load FBA solutions 
disp('PART 1: Load the flux solutions')

% Find paths to FBA solutions
solDir = what(fluxPath);
solPaths = string(append(solDir.path, filesep, solDir.mat));
modelNames = string(erase(solDir.mat,'.mat'));
analyseGF = false; 
if any(contains(modelNames, 'gfWBM')) || any(contains(modelNames, 'gfiWBM'))
    analyseGF = true;
end


% Get number of metabolites investigated
tmpSol = solPaths(~contains(solPaths,'Harv'));
reactions = load(tmpSol(1)).rxns;

% Find duplicate metabolites and remove where needed
[~,idx] = unique( reactions, 'stable' );
dupIDX = setdiff(1:numel(reactions),idx);
reactions(dupIDX)=[];

% Preallocate table for flux results
fluxes = array2table(nan(length(solPaths),length(reactions)),'VariableNames',reactions,'RowNames',modelNames);

% Preallocate table for solution metadata
metadata = array2table(string(nan(length(solPaths),2)),'VariableNames',{'ID','Sex'});

% Preallocate tables to store .stat values
fbaStats = array2table(nan(length(solPaths),length(reactions)),'VariableNames',reactions,'RowNames',modelNames);
fbaOrigStats = array2table(nan(length(solPaths),length(reactions)),'VariableNames',reactions,'RowNames',modelNames);

% Preallocate cell array to store microbes and shadow prices
modelSP = cell(length(solPaths),4);

% Load results and produce tables for the fluxes
warning('off')
for i = 1:length(solPaths)
    % Load relevant field names from FBA solution. Note that the fields:
    % taxonNames, shadowPriceBIO, and relAbundances are not loaded if the
    % FBA solution is from a germfree model. 
    solution = load(solPaths(i),'ID','sex','f','stat','origStat','taxonNames','shadowPriceBIO','relAbundances');

    % Add solution to metadata table
    metadata.ID(i) = erase(string(solution.ID),'.mat');
    metadata.Sex(i) = string(solution.sex);

    % Set flux results to nan if .stat was not equal to one
    solution.f(solution.stat~=1)=nan;

    % Add flux data to table
    solution.f(dupIDX)=[];

    % Round the fluxes bases on the user defined 
    solution.f = round(solution.f,paramFluxProcessing.roundingFactor);

    % Store fluxes in table
    fluxes{i,:} = solution.f;

    % Add FBA statistics to tables
    fbaStats{i,:} = solution.stat;
    if any(matches(fieldnames(solution),'origStat'))
        fbaOrigStats{i,:} = solution.origStat;
    end
    
    % Check if microbiome data is inlcuded in the solution fields
    if ~contains(solution.ID,'gf')
       % Add ID for shadow prices
        modelSP{i,1} = solution.ID;

        % Store species names
        modelSP{i,2} = solution.taxonNames;

        % Set all shadow prices with absolute values lower than the cutoff to zero.
        solution.shadowPriceBIO(abs(solution.shadowPriceBIO)<fluxCutoff)=0;

        % Store metabolite species biomass shadow prices
        modelSP{i,3} = solution.shadowPriceBIO;

        % Add species relative abundances
        modelSP{i,4} = solution.relAbundances;
    end
end

warning('on')

% Remove empty rows for the germfree results. Note that this line does not
% do anything if the FBA solutions did not include microbiome personalised
% WBMs. 
modelSP(cellfun(@isempty,modelSP(:,2)),:)=[];

%% PART 2: Obtain and process species biomass shadow prices (Microbiome only)
% 
% if ~isempty(modelSP) % Only run this section if microbiome personalised results are included
%     disp('PART 2: Obtain the shadow prices of microbe biomass for each reaction')
% 
%     % Obtain the names of the optimised reactions
%     rxnNames = fluxes.Properties.VariableNames;
% 
%     % Find the microbe biomass shadow prices for each optimised reaction
%     % and produce summary statistics
%     [microbesContributed, modelsInfluenced, microbeInfluenceStats, wbmRelativeAbundances] = extractMicrobeContributions(modelSP,rxnNames,fluxAnalysisPath,paramFluxProcessing.roundingFactor);
% 
% else 
%     disp('SKIP PART 2: Obtain the shadow prices of microbe biomass for each reaction')
%     disp('NO FBA solutions from microbiome personalised WBMs were detected.')
% end

%% PART 2: Correlate fluxes with microbial relative abundances
% Process flux and relative abundances data 
% Extract relative abundances
wbmRelativeAbundances = extractWbmRelativeAbundances(modelSP);

fluxNames  = string(fluxes.Properties.RowNames);
abundNames = string(wbmRelativeAbundances.Properties.RowNames);

% Extract everything between the first and last underscore
fluxIDs  = regexprep(fluxNames,  '^.*_(.*?)_.*$', '$1');
abundIDs = regexprep(abundNames, '^.*_(.*?)_.*$', '$1');

% Now match
[~, ia, ib] = intersect(fluxIDs, abundIDs, 'stable');
fluxesToCorrelate = fluxes(ia,:); 
relAbunToCorrelate = wbmRelativeAbundances(ib,:);

makeAr = @(x) table2array(x(:,2:end)); % Transform table to array
RHO = corr(makeAr(fluxesToCorrelate),makeAr(relAbunToCorrelate),'type','Spearman','rows','pairwise')'; % Create spearman correlations
fluxMicrobeCorr = array2table(RHO,... % Transform correlation matrix to table
    'RowNames', relAbunToCorrelate.Properties.VariableNames(2:end)',...
    'VariableNames',fluxesToCorrelate.Properties.VariableNames(2:end)...
    );

%% PART 3: Scale fluxes and produce summary statistics
disp('PART 3: Rescale flux results and produce summary statistics')

% Obtain summary statistics
fluxes = [metadata fluxes];

% Create statistics for fluxes and prune results
if analyseGF
    stats = describeFluxes(fluxes,paramFluxProcessing);
else
    stats = [];
    
end

%% PART 4: Group reactions with identical or near identical flux results
% disp('PART 4: Find reaction groups and group flux results')
% 
% if analyseGF
%     fluxesPruned = stats.Fluxes_removed_reactions; % Host-microbiome fluxes with removed metabolites
%     [fluxesGrouped, reactionGroups] = groupFluxes(fluxesPruned, paramFluxProcessing.rxnEquivalenceThreshold,{});
% end
% 
%% PART 5: Find correlations between the fluxes and relative microbe abundances (Microbiome only)
% 
% if ~isempty(modelSP) % Only run this section if microbiome personalised results are included
%     disp('PART 5: Correlate the predicted fluxes with the relative microbe abundances ')
%     % Correlate fluxes with the relative abundances and the microbial
%     % metabolic influence values
%     fluxMicrobeCorr= correlateFluxesAgainstMicrobes(fluxes, modelSP, paramFluxProcessing);
% else
%     disp('Skipped PART 5: Correlate the predicted fluxes with the relative microbe abundances ')
% end

%% PART 6: Create table with all results
disp('PART 6: Collect all results')

% Create index sheet for saved results
sheetNumbers = 13;
tableNames = append("Table ",string(1:sheetNumbers)');
indexTable = table(tableNames,string(zeros(sheetNumbers,1)),'VariableNames',{'Table','Descriptions'});

i=1;
indexTable.Descriptions(i) = 'FBA solver statistics'; i=i+1;
% indexTable.Descriptions(i) = 'FBA original solver statistics'; i=i+1;
indexTable.Descriptions(i) = 'Distribution statistics of fluxes across samples'; i=i+1;
indexTable.Descriptions(i) = 'Predicted fluxes'; i=i+1;
indexTable.Descriptions(i) = 'Predicted fluxes with removed reactions'; i=i+1;
indexTable.Descriptions(i) = 'Scaled fluxes summary statistics'; i=i+1;
indexTable.Descriptions(i) = 'Scaled fluxes with removed reactions'; i=i+1;
indexTable.Descriptions(i) = 'Linearly dependent groups of metabolic fluxes'; i=i+1;
indexTable.Descriptions(i) = 'Scaled fluxes with removed reactions and grouped metabolites'; i=i+1;

if ~isempty(modelSP) % Only produce these tables if HM models were investigated

    % shadow price analysis results
    indexTable.Descriptions(i) = 'Number of potential flux limiting taxa per sample'; i=i+1; % Microbiome only
    indexTable.Descriptions(i) = 'Number of samples containing potential flux limiting taxon'; i=i+1; % Microbiome only
    indexTable.Descriptions(i) = 'Summary statistics for potential flux limiting taxa'; i=i+1; % Microbiome only
    indexTable.Descriptions(i) = 'Microbial species relative abundances in WBMs'; i=i+1; % Microbiome only

    % Flux microbe correlation results
    indexTable.Descriptions(i) = 'Flux - taxon relative abundance correlations'; i=i+1;% Microbiome only
end

% Add index table to results structure
FBA_results = struct;
FBA_results.Index = indexTable;

% Add FBA statistics
N=1; 
FBA_results.(strcat("Table_",string(N))) = fbaStats; N = N+1; % Increment table number
% FBA_results.(strcat("Table_",string(N))) = fbaOrigStats; N = N+1; % Increment table number

if analyseGF
    % Add results from the flux summary analysis
    FBA_results.(strcat("Table_",string(N))) = stats.Flux_summary_statistics; N = N+1; % Increment table number
    FBA_results.(strcat("Table_",string(N))) = stats.Fluxes; N = N+1; % Increment table number
    FBA_results.(strcat("Table_",string(N))) = stats.Fluxes_removed_reactions; N = N+1; % Increment table number
    FBA_results.(strcat("Table_",string(N))) = stats.Scaled_flux_summary_statistics; N = N+1; % Increment table number
    FBA_results.(strcat("Table_",string(N))) = stats.Scaled_fluxes; N = N+1; % Increment table number
    
    % Add results from the flux grouping function
    %FBA_results.(strcat("Table_",string(N))) = reactionGroups; N = N+1; % Increment table number
    %FBA_results.(strcat("Table_",string(N))) = fluxesGrouped; N = N+1; % Increment table number

end


% Add results from the shadow price analysis (Microbiome only)
% FBA_results.(strcat("Table_",string(N))) = microbesContributed; N = N+1; % Increment table number
% FBA_results.(strcat("Table_",string(N))) = modelsInfluenced; N = N+1; % Increment table number
% FBA_results.(strcat("Table_",string(N))) = microbeInfluenceStats; N = N+1; % Increment table number
FBA_results.(strcat("Table_",string(N))) = wbmRelativeAbundances; N = N+1; % Increment table number

% Add results from the flux-microbe correlation function (Microbiome only)
FBA_results.(strcat("Table_",string(N))) = fluxMicrobeCorr; N = N+1; % Increment table number

%% PART 7: Save all results
disp('PART 7: Save all results to "flux_results.xlsx"')
sheetNames = string(fieldnames(FBA_results));

resultPath = [fluxAnalysisPath filesep 'flux_results.xlsx'];

% Remove excel file if it already exists to prevent partial overwriting.
if ~isempty(which(resultPath))
    delete(resultPath);
end

% Save results
for i = 1:length(sheetNames)
    % Get sheet
    sheet = FBA_results.(sheetNames(i));
    % Write to table
    writetable(sheet,resultPath,'Sheet',sheetNames(i),'WriteRowNames',true,'PreserveFormat',true)
end

%%% NOTE: This part will be removed once the pipeline is more mature
pathToFluxResults = [fluxAnalysisPath filesep 'processed_fluxes.csv'];
writetable(fluxes,pathToFluxResults) 

% Save microbiome relative abundances
WBMmicrobiomePath = [fluxAnalysisPath filesep 'WBM_relative_abundances.csv'];
% writetable(wbmRelativeAbundances,WBMmicrobiomePath,'WriteRowNames',true)

% Save flux-microbe correlations
fluxMicrobePath = [fluxAnalysisPath filesep 'microbe_metabolite_R2.csv'];
writetable(fluxMicrobeCorr,fluxMicrobePath,'WriteRowNames',true)

% Output paths
pathsToFilesForStatistics = [string(pathToFluxResults); string(WBMmicrobiomePath); string(fluxMicrobePath)];

end

function stats = describeFluxes(fluxes,paramFluxProcessing)
% This function produces summary statistics on the fluxes, isolates the microbial component of 
% the obtained fluxes, and saves the flux descriptions to a multi-sheet excel file. 
%
% The following statistics are obtained for each reaction
%  - The number of samples with microbial flux contribution (previously zeros)
%  - The number of samples with duplicate microbial contributions (M: unique)
%  - The fraction of duplicate fluxes
%  - The variance of the fluxes across all samples
%  - The standard deviation of the fluxes across all samples
%  - The distribution skewness of the fluxes across all samples
%  - The distribution kurtosis of the fluxes across all samples
%  - The one-sample Kolmogorov-Smirnov test p-value measured against the
%     normal distribution.
%
% USAGE:
%       stats = describeFluxes(fluxes, paramFluxProcessing)
% INPUTS:
%    fluxes:                    M x n table with flux values for each reaction n and each sample m. This table 
%                               must include flux results of male and female germfree models as well as
%                               as well as male and female host-microbiome models.
%                               shadow prices for m microbial species and for each reaction n. 
%
% OPTIONAL INPUTS
%    fluxAnalysisPath                    Character array with path to directory where the
%                               results are saved. Default = {}. Nothing is
%                               saved.
% rxnRemovalThreshold           "metabolite removal threshold"
%                               This threshold indicates the maximum allowable number
%                               of duplicate flux results between 
%                               samples expressed in the percentage
%                               of total samples. Reactions that exceed this threshold will be removed.
%                               Default value = 100.
% SD_threshold                  Minimal standard deviation of the fluxes across samples for
%                               metabolite removal.
% 
%
% OUTPUT
%   stats                   Cell array with 1) summary statistics, 2) table
%                              with flux values, and 3) a table with the flux values representing the
%                              microbial component of the original fluxes.
%   statsPath            Path to excel file with results
%
% .. Author:
%       - Tim Hensen       July, 2024

% Remove sex information
sexInfo = fluxes(:,{'ID','Sex'});
fluxes(:,{'ID','Sex'})=[];

% Add _GF to harvey/harvetta samples if not already
% harvNoGf = contains(sexInfo.ID,'Harv') & ~contains(sexInfo.ID,'_GF');
% sexInfo.ID(harvNoGf) = append(sexInfo.ID(harvNoGf),"_GF");


%%% Obtain sample summary statistics %%%

% Create temporary variable for statistics
fluxesForStats = fluxes;

% Remove germfree samples
fluxesForStats(contains(fluxesForStats.Properties.RowNames,'sol_gf','IgnoreCase',true),:)=[];

% Preallocate table
fluxesForStatsArray = table2array(fluxesForStats);
% varNames = {'Reaction','No results','Duplicate fluxes','Duplicate fluxes (%)','Mean','Variance','Standard deviation','Skewness','Kurtosis','KS normality p-value','Removed'};
varNames = {'Reaction','No results','Unique results','Mean','Variance','Standard deviation','Removed'};

fluxStats = table('Size',[size(fluxesForStatsArray,2),length(varNames)],'VariableTypes',[{'string'},repmat({'double'},1,length(varNames)-1)],'VariableNames',varNames);

% Add reaction names
fluxStats.Reaction = fluxesForStats.Properties.VariableNames';

% Find the number of samples with microbial flux contribution (previously zeros)
fluxStats.("No results") = sum(isnan(fluxesForStatsArray))';

% Find the number of samples with duplicate microbial contributions (M: unique)
%fluxStats.("Duplicate fluxes") = arrayfun(@(x) size(fluxesForStatsArray,1) - length(unique(fluxesForStatsArray(:,x))), 1:size(fluxesForStatsArray,2))';

% Find the number of unique flux results per reaction
for ii = 1:size(fluxesForStatsArray,2)
    fluxResults = fluxesForStatsArray(:,ii);
    fluxResults = fluxResults(~isnan(fluxResults));
    fluxStats.("Unique results")(ii) = length(unique(fluxResults));
end

% Calculate the fraction of duplicate fluxes
% fluxStats.("Duplicate fluxes (%)") = (fluxStats.("Duplicate fluxes")./(size(fluxesForStatsArray,1)-1)) * 100;

% Calculate mean of fluxes
fluxStats.Mean = mean(fluxesForStatsArray,'omitnan')';

% Calculate reaction variance
fluxStats.Variance = var(fluxesForStatsArray,[],1,'omitnan')';

% Calculate the standard deviation
fluxStats.("Standard deviation") = std(fluxesForStatsArray,[],1,'omitnan')';

% Get distribution skewness
% fluxStats.Skewness = skewness(fluxesForStatsArray)';
% 
% % Get distribution kurtosis
% fluxStats.Kurtosis = kurtosis(fluxesForStatsArray)';

% Check normality using the ks-test
% pvals = nan(size(fluxesForStatsArray,2),1);
% for ii = 1:size(fluxesForStatsArray,2)
%     try % For some fluxes, there are not enough unique samples to perform the ks test. 
%         % If the ks test cannot be run, the next reaction will be
%         % investigated.
%         [~,pvals(ii)] = kstest(normalize(fluxesForStatsArray(:,ii)));
%     end
% end
% % Add p-values to the table
% fluxStats.("KS normality p-value") = pvals;


%%% Remove metabolites based on user defined threshold value %%%

% Add information on removed reactions to the fluxStats table based on the
% user defined paramFluxProcessing.rxnRemovalCutoff type and value

typeCutoff = paramFluxProcessing.rxnRemovalCutoff{1}; % Either 'fraction', 'SD', or 'count'
cutoffValue = paramFluxProcessing.rxnRemovalCutoff{2}; 

% Define which reactions should be removed
switch typeCutoff
    case 'fraction'
        fluxStats.Removed = fluxStats.("Unique results") ./ size(fluxesForStatsArray,1) < cutoffValue;
    case 'SD'
        fluxStats.Removed = fluxStats.("Standard deviation") < cutoffValue;
    case 'count'
        fluxStats.Removed = fluxStats.("Unique results") < cutoffValue;
end

% Remove reactions according to "fluxStats.Removed"
fluxes_rm =fluxes;
fluxes_rm(:,fluxStats.Removed') = [];


%%% Scale fluxes %%%

% Obtain HM-H fluxes by taking the germfree fluxes and subtracting them
% from the fluxes obtained in the microbiome-WBM models.

% Check which WBMs are mWBMs
mWBMs = contains(sexInfo.ID,{'mWBM','miWBM'});

% Check which WBMs are iWBMs or miWBMs
iWBMs = contains(sexInfo.ID,'iWBM');

analyseGF = false; 
if any(contains(fluxes.Properties.RowNames, 'gfWBM')) || any(contains(fluxes.Properties.RowNames, 'gfiWBM'))
    analyseGF = true;
end

if any(mWBMs) && ~any(iWBMs) && analyseGF

    % If only the microbiome is personalised - obtain the generic male and
    % female germ-free models and substract that from the male and female
    % flux values

    % Find germ free fluxes 
    maleGF = fluxes_rm(contains(sexInfo.ID, 'gf') & matches(sexInfo.Sex, 'male'),:);
    femaleGF = fluxes_rm(contains(sexInfo.ID, 'gf') & matches(sexInfo.Sex, 'female'),:);

    % Set scaled flux variable
    scaledFluxes = fluxes_rm;

    % Remove germ free model fluxes from the microbiome-WBM fluxes
    scaledFluxes{matches(sexInfo.Sex,'male'),:} = fluxes_rm{matches(sexInfo.Sex,'male'),:} - maleGF{:,:};
    scaledFluxes{matches(sexInfo.Sex,'female'),:} = fluxes_rm{matches(sexInfo.Sex,'female'),:} - femaleGF{:,:};
end

if ~any(mWBMs) && all(iWBMs)

    % If there is no microbiome and only human personalisation, substract
    % the values of Harvey and Harvetta from the respective flux values of
    % the personalised models

    % Find fluxes from the unpersonalised models
    iWBM_control_male = fluxes_rm(contains(sexInfo.ID,'_Control') & contains(sexInfo.Sex,'_male'),:);
    iWBM_control_female = fluxes_rm(contains(sexInfo.ID,'_Control') & contains(sexInfo.Sex,'_female'),:);

    % Set scaled flux variable
    scaledFluxes = fluxes_rm;

    % Remove fluxes from unpersonalised host from the fluxes from the
    % personalised hosts. 
    scaledFluxes{matches(sexInfo.Sex,'male'),:} = fluxes_rm{matches(sexInfo.Sex,'male'),:} - iWBM_control_male{:,:};
    scaledFluxes{matches(sexInfo.Sex,'female'),:} = fluxes_rm{matches(sexInfo.Sex,'female'),:} - iWBM_control_female{:,:};
end

if all(iWBMs) && any(mWBMs) 

    % If both the microbiome and human are personalised, substract the
    % germfree values from the respective sample flux values.

    % Find flux values from GF samples
    fluxesGF = fluxes_rm(contains(sexInfo.ID, 'gf'),:);

    % Create new variable
    fluxesGFDupl = fluxesGF;

    % Add _1 to the end of the GF sample names
    fluxesGFDupl.Properties.RowNames = strcat(fluxesGFDupl.Properties.RowNames, '_1');

    % Add new rows with duplicate samples to the fluxes
    fluxesGF = [fluxesGF; fluxesGFDupl];

    % Initialise a storage table for the scaled fluxed
    scaledFluxes = fluxes_rm;

    % Remove germ free fluxes from microbiome personalised fluxes
    scaledFluxes{:,:} = fluxes_rm{:,:} - fluxesGF{:,:};
end

% Only unpersonalised and germfree WBM hosts were found
if ~any(mWBMs) && ~any(iWBMs)
    scaledFluxes = fluxes_rm;
end

% Remove the unpersonalised GF samples
idH = ~contains(sexInfo.ID, 'gf');
scaledFluxes(~idH,:) = [];


%%% Obtain summary statistics for the unscaled and scaled fluxes %%%

% Preallocate table for flux contributions from the scaled
if any(mWBMs) && ~any(iWBMs) % host NOT personalised, microbiome personalised

    varNames = {'Reaction','Germ-free male','Germ-free female','Mean scaled flux','SD scaled flux','Mean scaled / WBM flux','SD scaled / WBM flux'};

elseif any(iWBMs) && ~any(mWBMs) % host personalised, microbiome NOT personalised

    varNames = {'Reaction','Male control','Female control','Mean scaled flux','SD scaled flux','Mean scaled / WBM flux','SD scaled / WBM flux'};

elseif any(iWBMs) && any(mWBMs) % host personalised, microbiome personalised

    varNames = {'Reaction','Average germ-free male', 'Average germ-free female','Mean scaled flux','SD scaled flux','Mean scaled / WBM flux','SD scaled / WBM flux'};

else % host NOTE personalised, microbiome NOT personalised
    varNames = {};
end

% Create table
if ~isempty(varNames)
    scaledFluxStats = table('Size',[size(scaledFluxes,2),length(varNames)],'VariableTypes',[{'string'},repmat({'double'},1,length(varNames)-1)],'VariableNames',varNames);
else
    scaledFluxStats = table();
end

% Populate table 
if any(mWBMs) && ~any(iWBMs) % host NOT personalised, microbiome personalised

    % Add GF fluxes to the table
    scaledFluxStats.("Germ-free male") = table2array(fluxes_rm(contains(sexInfo.ID, 'gf') & matches(sexInfo.Sex, 'male'),:))';
    scaledFluxStats.("Germ-free female") = table2array(fluxes_rm(contains(sexInfo.ID, 'gf') & matches(sexInfo.Sex, 'female'),:))';

elseif any(iWBMs) && ~any(mWBMs) % host NOT personalised, microbiome personalised

    % Add the germfree fluxes
    scaledFluxStats.("Male control") = table2array(fluxes_rm(contains(sexInfo.ID,'male') & contains(sexInfo.ID,'_Control'),:))';
    scaledFluxStats.("Female control") = table2array(fluxes_rm(contains(sexInfo.ID,'female') & contains(sexInfo.ID,'_Control'),:))';

elseif any(iWBMs) && any(mWBMs) % host personalised, microbiome personalised

    % Calculate the average germfree fluxes
    % Note that if no male or female values are found, i.e., mean([]) a nan
    % will be produced. If only one value is found, e.g., mean(5.1), that
    % number will be produced. 
    scaledFluxStats.("Average germ-free male") = mean(table2array(fluxes_rm(endsWith(sexInfo.ID, '_GF') & strcmp(sexInfo.Sex, 'male'),:)))';
    scaledFluxStats.("Average germ-free female") = mean(table2array(fluxes_rm(endsWith(sexInfo.ID, '_GF') & strcmp(sexInfo.Sex, 'female'),:)))';
else
    scaledFluxStats = table();
end

if ~isempty(scaledFluxStats) % If either the host, the microbiome, or both are personalised.

    % Create temprorary variable for the microbiome-isolated and the original HM fluxes
    mFluxes = scaledFluxes;
    hmFluxes = fluxes_rm;

    % Ensure the tables are in the same order
    [~,ia,ib] = intersect(mFluxes.Properties.RowNames, hmFluxes.Properties.RowNames,'stable');
    mFluxes = mFluxes(ia,:);
    hmFluxes = hmFluxes(ib,:);

    % Add reaction names to table
    scaledFluxStats.Reaction = mFluxes.Properties.VariableNames';

    % Translate tables to arrays
    mFluxes = table2array(mFluxes);
    hmFluxes = table2array(hmFluxes);

    % Calculate the mean and SD of the scaled fluxes
    scaledFluxStats.("Mean scaled flux") = mean(mFluxes,'omitnan')';
    scaledFluxStats.("SD scaled flux") = std(mFluxes,'omitnan')';

    % Calculate fractions flux contributed by the personalisation.
    % Convert table to array

    % Preallocate array
    relFluxDiff = nan(size(mFluxes));

    % Find the rows of male and female samples
    maleIDX = matches(sexInfo.Sex,'male');
    %maleIDX(contains(sexInfo.ID,'harve','IgnoreCase',true))=[];
    maleIDX(contains(sexInfo.ID,'gf','IgnoreCase',true))=[];

    % Calculate relative microbial contribution
    relFluxDiff(maleIDX,:) = mFluxes(maleIDX,:)./hmFluxes(maleIDX,:);
    relFluxDiff(~maleIDX,:) = mFluxes(~maleIDX,:)./hmFluxes(~maleIDX,:);

    % Nans are produced when the microbial component is zero. Set these results
    % to zero.
    relFluxDiff(isnan(relFluxDiff))=0;

    % Now add the mean and SD per reaction to the table
    scaledFluxStats.("Mean scaled / WBM flux") = mean(relFluxDiff,'omitnan')';
    scaledFluxStats.("SD scaled / WBM flux") = std(relFluxDiff,'omitnan')';
end

% Add sex information
fluxes = [sexInfo(idH,:) fluxes(idH,:)];
fluxes_rm = [sexInfo(idH,:) fluxes_rm(idH,:)];
scaledFluxes = [sexInfo(idH,:) scaledFluxes];

% Save processed fluxes and statistics
stats = struct;
stats.('Flux_summary_statistics') = fluxStats;
stats.("Fluxes") = fluxes;
stats.("Fluxes_removed_reactions") = fluxes_rm;
stats.("Scaled_flux_summary_statistics") = scaledFluxStats;
stats.("Scaled_fluxes") = scaledFluxes;

end

function relativeAbundances = extractWbmRelativeAbundances(modelSP)
% Author: Tim Hensen.
% TO DO TH: Add documentations!

% Find the pan species names
allSpecies = unique(vertcat(modelSP{:,2}));

% Find the microbial relative abundances from the models
relAbun = nan(size(modelSP,1),length(allSpecies));
for i = 1:size(modelSP, 1)
    
    % Find which species in the sample are present
    [index1, index2] = ismember(allSpecies, modelSP{i, 2});

    % Remove zero indices for non-present species in index2
    index2 = index2(index2 > 0);
    
    if ~isempty(index2)
        % Get the shadow prices for valid species
        samp_ra = modelSP{i, 4};
        samp_ra = samp_ra(index2);

        % Rescale the relative abundances so that they sum up to one
        % instead of 100. 
        samp_ra = samp_ra / 100;
        
        % Assign the shadow prices to the result array
        relAbun(i, index1) = samp_ra;
    end
end

% Create a table with the microbial relative abundances
taxa = erase(allSpecies,{'pan','_biomass[c]'});
relativeAbundances = array2table(relAbun,'RowNames',string(modelSP(:,1)),'VariableNames',taxa);
end