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

if ~isempty(modelSP) % Only run this section if microbiome personalised results are included
    disp('PART 2: Obtain the shadow prices of microbe biomass for each reaction')

    % Obtain the names of the optimised reactions
    rxnNames = fluxes.Properties.VariableNames;

    % Find the microbe biomass shadow prices for each optimised reaction
    % and produce summary statistics
    [microbesContributed, modelsInfluenced, microbeInfluenceStats, wbmRelativeAbundances] = extractMicrobeContributions(modelSP,rxnNames,fluxAnalysisPath,paramFluxProcessing.roundingFactor);

else 
    disp('SKIP PART 2: Obtain the shadow prices of microbe biomass for each reaction')
    disp('NO FBA solutions from microbiome personalised WBMs were detected.')
end


%% PART 3: Scale fluxes and produce summary statistics
disp('PART 3: Rescale flux results and produce summary statistics')

% Obtain summary statistics
fluxes = [metadata fluxes];

% Create statistics for fluxes and prune results
stats = describeFluxes(fluxes,paramFluxProcessing);

%% PART 4: Group reactions with identical or near identical flux results
disp('PART 4: Find reaction groups and group flux results')

fluxesPruned = stats.Fluxes_removed_reactions; % Host-microbiome fluxes with removed metabolites
[fluxesGrouped, reactionGroups] = groupFluxes(fluxesPruned, paramFluxProcessing.rxnEquivalenceThreshold,{});

%% PART 5: Find correlations between the fluxes and relative microbe abundances (Microbiome only)

if ~isempty(modelSP) % Only run this section if microbiome personalised results are included
    disp('PART 5: Correlate the predicted fluxes with the relative microbe abundances ')
    % Correlate fluxes with the relative abundances and the microbial
    % metabolic influence values
    fluxMicrobeCorr= correlateFluxesAgainstMicrobes(fluxes, modelSP, paramFluxProcessing);
else
    disp('Skipped PART 5: Correlate the predicted fluxes with the relative microbe abundances ')
end

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

% Add results from the flux summary analysis
FBA_results.(strcat("Table_",string(N))) = stats.Flux_summary_statistics; N = N+1; % Increment table number
FBA_results.(strcat("Table_",string(N))) = stats.Fluxes; N = N+1; % Increment table number
FBA_results.(strcat("Table_",string(N))) = stats.Fluxes_removed_reactions; N = N+1; % Increment table number
FBA_results.(strcat("Table_",string(N))) = stats.Scaled_flux_summary_statistics; N = N+1; % Increment table number
FBA_results.(strcat("Table_",string(N))) = stats.Scaled_fluxes; N = N+1; % Increment table number

% Add results from the flux grouping function
FBA_results.(strcat("Table_",string(N))) = reactionGroups; N = N+1; % Increment table number
FBA_results.(strcat("Table_",string(N))) = fluxesGrouped; N = N+1; % Increment table number

% Add results from the shadow price analysis (Microbiome only)
FBA_results.(strcat("Table_",string(N))) = microbesContributed; N = N+1; % Increment table number
FBA_results.(strcat("Table_",string(N))) = modelsInfluenced; N = N+1; % Increment table number
FBA_results.(strcat("Table_",string(N))) = microbeInfluenceStats; N = N+1; % Increment table number
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

% Save fluxes and flux-microbe correlations in separate files
pathToFluxResults = [fluxAnalysisPath filesep 'processed_fluxes.csv'];
writetable(fluxesPruned,pathToFluxResults)

% Save microbiome relative abundances
WBMmicrobiomePath = [fluxAnalysisPath filesep 'WBM_relative_abundances.csv'];
writetable(wbmRelativeAbundances,WBMmicrobiomePath,'WriteRowNames',true)

% Save flux-microbe correlations
fluxMicrobePath = [fluxAnalysisPath filesep 'microbe_metabolite_R2.csv'];
writetable(fluxMicrobeCorr,fluxMicrobePath,'WriteRowNames',true)

% Output paths
pathsToFilesForStatistics = [string(pathToFluxResults); string(WBMmicrobiomePath); string(fluxMicrobePath)];

end

function [microbesContributed, modelsInfluenced, microbeInfluenceStats, relativeAbundances] = extractMicrobeContributions(modelSP,rxnNames,fluxAnalysisPath,roundingFactor)
% Function for processing and saving the species biomass[c] shadow prices.
% M x n tables of the species biomass shadow prices are generated for each
% m samples and n microbial species. These tables are generated for each
% optimised reaction. After obtaining these tables, statistics are
% generated on 1) the number of samples where each microbial species
% influences a given reaction, 2) the number of microbial species that influence a
% reaction in each sample, and summary statistics for the number of
% microbes that influence each reaction flux.
%
% USAGE:
%       [microbiomeContributions, microbesContributed, modelsInfluenced, microbeInfluenceStats, relativeAbundances] = extractMicrobeContributions(modelSP,rxnNames,fluxAnalysisPath,roundingFactor)
% INPUTS:
%    modelSP:               Cell array with three columns. The first column
%                                   contains the sample IDs. The second column contains cell arrays of the
%                                   microbial species present in the samples. 
%                                   The third column contains for each cell a m x n numerical matrix with the
%                                   shadow prices for m microbial species and for each reaction n. 
%    rxnNames:              Cell array with reaction names. Note that the reaction names need to 
%                                   correspond with each column in each cell in modelSP(:,3).
%    fluxAnalysisPath                   Character array with path and name of file from which to retrieve abundance information
%
% OUTPUTS:
%   nInflMicrobes               Table that contains the number of samples where each microbial species
%                                        influences a given reaction.
% sampSpeciesInfluence  Table containing the number of microbial species that influence a
%                                        reaction in each sample.
% microbeInfluenceStats   Table containing summary statistics for the number of microbes 
%                                        that influence each reaction flux.
%
% .. Author:
%       - Tim Hensen       July, 2024

if nargin<4
    roundingFactor = 6;
end


%%% Obtain the pan species biomass shadow prices and their relative abundances. %%% 

% Find the pan species names
allSpecies = unique(vertcat(modelSP{:,2}));

% Extract shadow price and relative abundance info from the FBA solutions
% (modelSP). The biomShadowPrices array contains shadow prices in a 3 dimensional 
% array with samples in the x dimension, the pan species in the y dimension, and the 
% reaction names in the z dimension.
[biomShadowPrices, relativeAbundances] = extractMicroWbmSpAndRa(allSpecies, modelSP);

% Set all microbe biomass shadow prices below threshold to zero
biomShadowPrices = round(biomShadowPrices,roundingFactor);

% Set all zeros to nan 
biomShadowPrices(biomShadowPrices==0) = nan;

%%% Find the contributing taxa %%% 

% Obtain the contributing microbes
contributed = ~isnan(biomShadowPrices);

% Find the number of microbes that contributed to the predicted flux
microbesContributed = reshape(sum(contributed,2,'omitnan'),size(biomShadowPrices,[1 3])); 
microbesContributed = array2table(microbesContributed,'RowNames',relativeAbundances.Properties.RowNames,'VariableNames',rxnNames);

% Find the number of samples in which each microbe contributed to the flux
modelsInfluenced = reshape(sum(contributed,1,'omitnan'),size(biomShadowPrices,[2 3]));
modelsInfluenced = array2table(modelsInfluenced,'RowNames',relativeAbundances.Properties.VariableNames,'VariableNames',rxnNames);

% Find the total number of microbes that contributed to the fluxes across
% the cohort.
totalMicrobes = reshape(sum(any(contributed,1)),[size(biomShadowPrices,3) 1]);


%%% Prepare summary statistics table %%% 

% Obtain summary statistics for gut microbial influences
microbeCounts = table2array(microbesContributed);
contributionStats = [mean(microbeCounts)' std(microbeCounts)' totalMicrobes];

% Prepare table with summary statistics
microbeInfluenceStats=array2table(contributionStats);
microbeInfluenceStats.Properties.VariableNames = {'Mean microbe count','SD microbe count','Total microbes'};
microbeInfluenceStats.Reaction = rxnNames';
microbeInfluenceStats = movevars(microbeInfluenceStats,"Reaction","Before",1);


%%% Save individual microbe influences %%% 

% Create directory for writing csv files with shadow prices
shadowPriceDirectory = [fluxAnalysisPath filesep 'biomass_shadow_prices' filesep];
if ~exist(shadowPriceDirectory,'dir')
    mkdir(shadowPriceDirectory)
end

% Save tables with biomass shadow prices to directory
for i=1:size(biomShadowPrices,3)
    shadowPriceTable = array2table(biomShadowPrices(:,:,i),'RowNames',string(modelSP(:,1)),'VariableNames',allSpecies');
    shadowPricePath = [shadowPriceDirectory filesep strcat(rxnNames{i},'.csv')];
    writetable(shadowPriceTable,shadowPricePath,'WriteRowNames',true);
end

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

if any(mWBMs) && ~any(iWBMs)

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

function [fluxesGrouped, reactionGroups] = groupFluxes(fluxes, threshold,fluxAnalysisPath)
% This function performs pairwise correlations between the reaction flux results and finds 
% groups of identical fluxes within the data. 
%
% USAGE:
%       [fluxesGrouped, reactionGroups] = groupFluxes(fluxes, threshold,saveFilePath)
%
% INPUTS:
%       fluxes:                 M x n table with flux values for each reaction n and each sample m. 
%       threshold             Scalar value between 0 and 1 indicating the
%                                   Spearman correlation strength when two flux distributions are
%                                   grouped and handled as one result. Default =
%                                   0.999
%
% OPTIONAL INPUTS
% fluxAnalysisPath                      Filename and path to excel file (.xlsx) with
% grouping results. Default is empty {}. Nothing is saved to file.
%
% OUTPUTS
%    fluxesGrouped        M x n table with flux values for each reaction n and
%                                   each sample m. The grouped reactions are appended as columns at the
%                                   end while the reactions in these groups are removed from the input
%                                   fluxes table.
%    reactionGroups      Table with one column for the grouped reactions
%                                   and one column for the new names of the reaction groups. 
% .. Author:
%       - Tim Hensen       July, 2024

% Remove ID and Sex
ID = fluxes(:,'ID');
fluxes(:,matches(fluxes.Properties.VariableNames,{'ID','Sex'}))=[];
rxnNames = fluxes.Properties.VariableNames;

% Obtain Pearson correlations
adjMatrix=corr(table2array(fluxes),'Type','Pearson','Rows','pairwise');

% Set the diagonal to zero
adjMatrix(1:size(adjMatrix,1) + 1:end) = 0;

% Find identical distributions
adjMatrix(adjMatrix<threshold | isnan(adjMatrix)) = 0;
adjMatrix(adjMatrix>threshold) = 1;

% Create graph and get all with a degreee of nonzero
G = graph(adjMatrix,rxnNames);
G.Nodes.degree = degree(G);
G.Nodes.Name(G.Nodes.degree~=0);

% Find subnetworks
subnetworks = conncomp(G);

% Extract the subnetworks as a list
subnetwork_list = table(G.Nodes.Name, subnetworks',G.Nodes.degree);

subnetwork_list_dup = subnetwork_list(subnetwork_list.Var3~=0,:);

% Get groups
groups = findgroups(subnetwork_list_dup.Var2);
subNets = cell(length(unique(groups)),2);
for i = 1:length(unique(groups))
    subNets{i,1} = strjoin(string(subnetwork_list_dup.Var1(groups==i)), '/');
    subNets{i,2} = subnetwork_list_dup.Var1(groups==i);
end

% Replace duplicate flux results with group
fluxesGrouped = fluxes;
for i=1:size(subNets,1)
    dupFluxes = find(matches(fluxesGrouped.Properties.VariableNames,subNets{i,2}'));
    try
        fluxesGrouped.(subNets{i,1}) = table2array(fluxesGrouped(:,dupFluxes(1)));
    catch % Catch names with length more than 64
        shortened = char(subNets{i,1});
        shortened(64:end)=[];
        shortened=string(shortened);
        fluxesGrouped.(shortened) = table2array(fluxesGrouped(:,dupFluxes(1)));
    end
    fluxesGrouped(:,dupFluxes)=[];
end
% Add back sample names
fluxesGrouped = [ID fluxesGrouped];

% Prepare flux groups for saving
subNets1 = subNets;
for i = 1:size(subNets1,1)
    identicalMets = string(subNets1{i,2}');
    subNets1(i,3) = cellstr(strjoin(identicalMets,';'));
end
subNets1(:,2)=[];

if ~isempty(subNets1)
% Convert subNets1 to table
subNets2 = cell2table(subNets1,'VariableNames',{'Metabolite group name','Included metabolites'});
subNets2.("Spearman rho") = repmat(threshold,height(subNets2),1);
else
    subNets2 = table();
end
reactionGroups = subNets2;

if ~isempty(fluxAnalysisPath)
    % Generate paths
    thresholdName = replace(string(threshold),'.','_');
    fluxesXlsxPath = [fluxAnalysisPath filesep 'flux_results.xlsx'];
    fluxProcessedPath = [fluxAnalysisPath filesep 'processed_fluxes_Thr_' char(thresholdName) '.csv'];
    sheetGroupedFluxes = ['Table 5 grouped_flux_Thr_' char(thresholdName)];
    sheetGroupedNames = 'Table 6 Reaction groups';
    
    disp('Save grouped fluxes')
    writetable(fluxesGrouped, fluxesXlsxPath,'Sheet',sheetGroupedFluxes,'WriteRowNames',false)
    writetable(reactionGroups,fluxesXlsxPath,'Sheet',sheetGroupedNames)
    writetable(fluxesGrouped, fluxProcessedPath)
end
end

function [fluxMicrobeCorr,fluxMicrobeInfluenceCorr] = correlateFluxesAgainstMicrobes(fluxes, modelSP, paramFluxProcessing)
% Function for assessing Spearman correlations between the predicted fluxes and
% relative microbe abundances. The r-squared values are obtained by
% performing simple Spearman correlations between the flux (response) and the
% relative abundance (predictor). Correlations are only performed for
% microbe-reaction combinations where the species biomass metabolite has a
% nonzero (tol=1e-6) shadow price for the optimised reaction. These microbe-flux associations are
% mapped in the sampSpeciesInfluence variable. Microbes are also only
% regressed if they are present in at least a certain percentage of
% samples, defined by the microbeCutoff variable. 
%
% USAGE:
%       [fluxMicrobeCorr,fluxMicrobeInfluenceCorr] = correlateFluxesAgainstMicrobes(fluxes, microbiomeDir, modelSP, paramFluxProcessing)
% 
% INPUTS:
% fluxes:                       M x n table with flux values for each reaction n and each sample m. 
% microbiomeDir                 Character array with path to the merged taxa-read
%                               MARS output file.
% modelSP:                      Cell array with three columns. The first column
%                               contains the sample IDs. The second column contains cell arrays of the
%                               microbial species present in the samples. 
%                               The third column contains for each cell a m x n numerical matrix with the
%                               shadow prices for m microbial species and for each reaction n. 
% microbeCutoff                 Cutoff for the percentage of samples where a
%                               microbe can be absent in the samples to be included in the correlations. Default
%                               limit is 90%
% OPTIONAL INPUT
%           fluxAnalysisPath             Path to directory where the fluxMicrobeCorr
%                               variable is saved. Default is empty and
%                               nothing is saved.
%           paramFluxProcessing TODO
%
% OUTPUTS:
% fluxMicrobeCorr               M x n table of m microbial species and n
%                               reactions with r-squared values for the associated microbe-flux
%                               connections.
%
% .. Author:
%       - Tim Hensen       July, 2024

% Remove GF samples
fluxes(contains(fluxes.Properties.RowNames,{'Harv','gf'}),:) = [];

% Remove ID and sex columns. Note that the sample IDs are still in the
% table rows.
fluxes(:,matches(fluxes.Properties.VariableNames,{'ID','Sex'}))=[];


%%% Create species relative abundance table from model coefficients %%%

% Find the pan species names
allSpecies = unique(vertcat(modelSP{:,2}));

% Extract shadow price and relative abundance info from the FBA solutions
% (modelSP). The biomShadowPrices array contains shadow prices in a 3 dimensional 
% array with samples in the x dimension, the pan species in the y dimension, and the 
% reaction names in the z dimension.
%%
[biomShadowPrices, relativeAbundances] = extractMicroWbmSpAndRa(allSpecies, modelSP);
%%
% Preallocate array with relative abundances
% relAbun = table2array(relativeAbundances);

% Calculate flux contributions (See extractMicrobeContributions for
% explanation)
contributions = biomShadowPrices;%(-1* biomShadowPrices) .* relAbun;

% Set all flux contributions below threshol to zero
contributions = round(contributions, paramFluxProcessing.roundingFactor);

% Set all zeros to nan 
contributions(contributions==0) = nan;

% Add the sum of microbe contributions and the sum of relative abundances
% to the datasets

% Find the total microbial component of the fluxes
microbiomeContributions = reshape(sum(contributions,2,'omitnan'),size(biomShadowPrices,[1 3]));

% Add the sum of microbial influences to contributions
contributions(:,end+1,:) = microbiomeContributions;

% Find the species richness in the contributions
speciesRichness = reshape(sum(isnan(contributions),2,'omitnan'),size(biomShadowPrices,[1 3]));

% Add the species Richness to the contributions
contributions(:,end+1,:) = speciesRichness;

% Calculate the sum of relative abundances and add to the relative
% abundance table
relativeAbundances.("Sum of taxa") = sum(table2array(relativeAbundances),2,'omitnan');

% Add species richness (alpha diversity)
relativeAbundances.("Species richness") = sum(isnan(table2array(relativeAbundances)),2);

% Correlate fluxes with microbiome flux contributions

% Obtain reaction and taxon names
rxnNames = fluxes.Properties.VariableNames;
Taxa = relativeAbundances.Properties.VariableNames';

% Preallocate correlation table
fluxMicrobeCorr = array2table(nan(size(relativeAbundances,2),size(fluxes,2)),'RowNames',Taxa','VariableNames',rxnNames);
fluxMicrobeInfluenceCorr = array2table(nan(size(relativeAbundances,2),size(fluxes,2)),'RowNames',Taxa','VariableNames',rxnNames);

% Declare the type of correlation to be tested
correlationType = paramFluxProcessing.fluxMicrobeCorrelationMetric;

% Declare which reaction-microbe correlations are tested based on the
% user defined cutoff value and the type of cutoff. 
typeCutoff = paramFluxProcessing.rxnRemovalCutoff{1}; % Either 'fraction', 'SD', or 'count'
cutoffValue = paramFluxProcessing.rxnRemovalCutoff{2}; 

switch correlationType

    case 'regression_r2'

        disp('Perform linear regressions on the relative abundances against the fluxes')
        % Obtain correlations from r-squared values using simple linear regressions
    
        tic
        warning('off')
        for i=1:length(Taxa)
            for j=1:length(rxnNames)
        
                % Obtain flux value for rxn i
                flux = fluxes.(rxnNames{j});
        
                % Obtain microbiome contribution for taxon j and reaction i
                influence = contributions(:,i,j);
        
                % Obtain relative abundances for taxon j
                microbe = relativeAbundances.(Taxa{i});
        
                % Check if enough values are available in the microbe and influence
                % variable and only perform regression correlations if possible            
                testComparison = false;
                switch typeCutoff
                    case 'fraction'
                        if sum(~isnan(influence)) > size(influence,1)*cutoffValue
                            testComparison = true;
                        end
                    case 'SD'
                        if std(influence,'omitnan') > cutoffValue
                            testComparison = true;
                        end
                    case 'count'
                        if sum(~isnan(influence)) > cutoffValue
                            testComparison = true;
                        end
                end
        
                if testComparison == true
        
                    % Perform linear regression on flux-microbial influences
                    fit_influence = fitlm(flux, influence);
                    
                    % Perform linear regression on flux and relative abundances
                    fit_microbe = fitlm(flux, microbe);
        
                    % Add R2 values to table
                    fluxMicrobeInfluenceCorr{i,j} = fit_influence.Rsquared.Ordinary;            
                    fluxMicrobeCorr{i,j} = fit_microbe.Rsquared.Ordinary;
                end
            end
        end
        warning('on')
        toc

    case 'spearman_rho'

        disp('Perform pairwise Spearman correlations on the relative abundances against the fluxes')
        % Obtain correlations from Spearman correlation coefficients
        
        % Create arrays with the flux and relative abundance data
        fluxArray = table2array(fluxes);
        relativeAbundanceArray = table2array(relativeAbundances);
    
        % Remove microbes not present in enough samples
        totalInfluences = sum(~isnan(relativeAbundanceArray));
        reactionsToKeep = totalInfluences > size(relativeAbundanceArray,1)*0.1;
    
        % Prune relative abundance array
        relativeAbundanceArrayPruned = relativeAbundanceArray(:,reactionsToKeep);
    
        % Correlated fluxes with relative abundances
        rho_RA = corr(fluxArray,relativeAbundanceArrayPruned,'type','Spearman','rows','pairwise');
    
        % Transpose correlation coefficients so that rows = taxa and columns =
        % reaction fluxes.
        rho_RA = rho_RA';
    
        % Add correlations to the fluxMicrobeCorr table
        fluxMicrobeCorr{reactionsToKeep',:} = rho_RA;
    
        % Now perform the same correlations on the metabolic contribution data
        rho_MI = nan(size(contributions,2),size(fluxes,2));
        for j=1:size(contributions,3)
            influenceArray = contributions(:,:,j);
        
            % Again remove microbes not present in enough samples
            totalInfluences = sum(~isnan(influenceArray));
            
            % Define which reactions should be removed
            switch typeCutoff
                case 'fraction'
                    reactionsToKeep = totalInfluences > size(influenceArray,1)*cutoffValue;
                case 'SD'
                    reactionsToKeep = std(influenceArray,'omitnan') > cutoffValue;
                case 'count'
                    reactionsToKeep = totalInfluences > cutoffValue;
            end
        
            % Prune metabolic contribution array
            influenceArrayPruned = influenceArray(:,reactionsToKeep);
        
            % Correlated fluxes with relative abundances
            rho_MI(reactionsToKeep',j) = corr(fluxArray(:,j),influenceArrayPruned,'type','Spearman','rows','pairwise')';
        end
    
        % Add results to fluxMicrobeInfluenceCorr
        fluxMicrobeInfluenceCorr{:,:} = rho_MI; 
end

% Erase pan biomass metabolite names
fluxMicrobeCorr.Properties.RowNames = erase(fluxMicrobeCorr.Properties.RowNames,{'pan','_biomass[c]'});
fluxMicrobeInfluenceCorr.Properties.RowNames = erase(fluxMicrobeInfluenceCorr.Properties.RowNames,{'pan','_biomass[c]'});

end

% This function is used in correlateFluxesAgainstMicrobes and extractMicrobeContributions
function [biomShadowPrices, relativeAbundances] = extractMicroWbmSpAndRa(allSpecies, modelSP)
% This function extracts the shadow price values of each triplet of
% predicted flux, pan model biomass shadow prices, and sample IDs. If a 
% second output argument is given, the function also extracts the relative 
% abundances of the pan models from modelSP. 
%
% INPUT:
% allSpecies            Cell array of pan species biomass metabolite names 
% modelSP               Cell array with sample IDs (column 1), present pan
%                       species models for each sample (column 2), biomass metabolite shadow
%                       prices for each maximised reactions (column 3), and the pan model
%                       relative abundances (column 4). 
%
% OUTPUT
% biomShadowPrices      Three dimension array with shadow price values.   
% relativeAbundances    Table with microbe relative abundances from WBMs.
%
% Authors: Tim Hensen and Mohammadreza Moghimi.

% Preallocate biomShadowPrices array for shadow prices
numRxns = size(modelSP{1,3},2);
biomShadowPrices = nan(length(allSpecies), numRxns, size(modelSP, 1));
for i = 1:size(modelSP, 1)
    
    % Find which species in the sample are present
    [index1, index2] = ismember(allSpecies, modelSP{i, 2});

    % Remove zero indices for non-present species in index2
    index2 = index2(index2 > 0);
    
    if ~isempty(index2)
        % Get the shadow prices for valid species
        samp_SP = modelSP{i, 3};
        samp_SP = samp_SP(index2, :);
        
        % Assign the shadow prices to the result array
        biomShadowPrices(index1, :, i) = samp_SP;
    end
end

% Swap the tensor z and x axis for easy data accessing
biomShadowPrices = permute(biomShadowPrices,[3 1 2]);

if nargout>1
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

end