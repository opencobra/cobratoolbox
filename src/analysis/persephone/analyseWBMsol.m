function processedFluxResPaths = analyseWBMsol(fluxPath,paramFluxProcessing, fluxAnalysisPath)
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
%       processedFluxResPaths = analyseWBMsol(fluxPath,paramFluxProcessing, fluxAnalysisPath)
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
fprintf("> Loading the FBA solutions... \n")

% Find paths to FBA solutions
solDir = what(fluxPath);
solPaths = string(append(solDir.path, filesep, solDir.mat));
modelNames = string(erase(solDir.mat,'.mat'));

% Get number of metabolites investigated
reactions = load(solPaths(1)).rxns;

% Find duplicate metabolites and remove where needed
[~,idx] = unique( reactions, 'stable' );
dupIDX = setdiff(1:numel(reactions),idx);
reactions(dupIDX)=[];

% Preallocate tables for FBA results
fluxes = array2table(nan(length(solPaths),length(reactions)),'VariableNames',reactions,'RowNames',modelNames); % Flux results
metadata = array2table(string(nan(length(solPaths),2)),'VariableNames',{'ID','Sex'}); % Sample metadata from FBA solution
fbaStats = array2table(nan(length(solPaths),length(reactions)),'VariableNames',reactions,'RowNames',modelNames); % .stat values

% Load results and produce tables for the fluxes
%warning('off')
for i = 1:length(solPaths)
    % Load relevant field names from FBA solution. 
    solution = load(solPaths(i),'ID','sex','f','stat');

    % Add solution to metadata table
    metadata.ID(i) = erase(string(solution.ID),'.mat');
    metadata.Sex(i) = string(solution.sex);

    % Set flux results to nan if .stat was not equal to one
    solution.f(solution.stat~=1)=nan;

    % Remove reaction if it is a duplicate
    solution.f(dupIDX)=[];

    % Round the fluxes and store them fluxes in table
    fluxes{i,:} = round(solution.f,paramFluxProcessing.roundingFactor);

    % Add FBA statistics to tables
    fbaStats{i,:} = solution.stat;
end

%warning('on')


%% PART 2: Scale fluxes and produce summary statistics
fprintf("> Processing and analysing the flux results... \n")

% Obtain summary statistics
fluxes = [metadata fluxes];

% Create statistics for fluxes and prune results
stats = describeFluxes(fluxes,paramFluxProcessing);

% Get fluxes for further analysis
fluxesPruned = stats.Fluxes_removed_reactions;

% Are the models personalised with gut microbiota?
microbiomePresent = false;
if any(contains(modelNames, 'mWBM')) || any(contains(modelNames, 'miWBM'))
    microbiomePresent = true;
end

if microbiomePresent == true
    %%% Correlate fluxes with microbial relative abundances 
    
    fprintf("> Extract metagenomic relative abundances from mWBMs... \n")
    
    % Redefine paths to the fba results
    solPathsHM = fullfile(what(solDir.path).path,what(solDir.path).mat);
    solPathsHM(~contains(solPathsHM,{'_mWBM_','miWBM'},'IgnoreCase',true))=[];
    
    % Load relative abundances and taxa from fba solutions
    relAbunSol = cellfun( @(x) load(x,'ID','taxonNames','relAbundances'), solPathsHM);
    modelSP = struct2cell(relAbunSol)';
    
    % Find all microbial species
    allSpecies = unique(vertcat(relAbunSol(:).taxonNames));
    
    % Find which species in the sample are present
    
    % Find the microbial relative abundances from the models
    relAbun = nan(size(modelSP,1),length(allSpecies));
    for i = 1:size(modelSP, 1)
        
        % Find which species in the sample are present
        [index1, index2] = ismember(allSpecies, modelSP{i, 2});
    
        % Remove zero indices for non-present species in index2
        index2 = index2(index2 > 0);
        
        if ~isempty(index2)
            % Get the shadow prices for valid species
            samp_ra = modelSP{i, 3};
            samp_ra = samp_ra(index2);
    
            % Rescale the relative abundances so that they sum up to one
            % instead of 100. 
            samp_ra = samp_ra / 100;
            
            % Assign the relative abundances to the result array
            relAbun(i, index1) = samp_ra;
        end
    end
    
    % Create a table with the microbial relative abundances
    taxa = erase(allSpecies,{'pan','_biomass[c]'});
    wbmRelativeAbundances = array2table(relAbun,'RowNames',string(modelSP(:,1)),'VariableNames',taxa);

    % Save microbiome relative abundances
    fprintf("> Write metagenomic relative abundances from mWBMs to file... \n")
    WBMmicrobiomePath = fullfile(fluxAnalysisPath,'WBM_relative_abundances.csv');
    writetable(wbmRelativeAbundances,WBMmicrobiomePath,'WriteRowNames',true)
    
    fprintf("> Perform spearman correlations on flux results and relative abundances... \n")
    % Extract relative abundances and process relative abundance ID names from samples
    
    % Process flux data from samples
    fluxesToCorrelate = stats.Fluxes;
    fluxesToCorrelate = removevars(fluxesToCorrelate,{'ID','Sex'});
    
    % run function on flux and relative abundance sample IDs
    processRowNames = @(x) erase(x,{'FBA_sol_','mWBM_','miWBM_','iWBM_','_female','_male'}); % Remove ID metadata
    fluxesToCorrelate.Properties.RowNames = processRowNames(fluxesToCorrelate.Properties.RowNames); 
    wbmRelativeAbundances.Properties.RowNames = processRowNames(wbmRelativeAbundances.Properties.RowNames);
    
    % Ensure identical sample order
    fluxesToCorrelate = fluxesToCorrelate(wbmRelativeAbundances.Properties.RowNames,:);
    wbmRelativeAbundances = wbmRelativeAbundances(fluxesToCorrelate.Properties.RowNames,:);
    
    RHO = corr(table2array(fluxesToCorrelate),table2array(wbmRelativeAbundances),'type','Spearman','rows','pairwise')'; % Create spearman correlations
    fluxMicrobeCorr = array2table(RHO,... % Transform correlation matrix to table
        'RowNames', wbmRelativeAbundances.Properties.VariableNames',...
        'VariableNames',fluxesToCorrelate.Properties.VariableNames...
        );
end

%% Create table with all results
disp('Collect all results')


% Save processed fluxes to file
fprintf("> Save processed flux results... \n")
pathToFluxResults = fullfile(fluxAnalysisPath,'processed_fluxes.csv');
writetable(fluxesPruned,pathToFluxResults)


% Check if the flux_results.xlsx already exists and remove if yes
resultPath = fullfile(fluxAnalysisPath,'flux_results.xlsx');
if isfile(resultPath); delete(resultPath); end % For script testing

% Save FBA solver statistics
description = cell(2,1); 
description{1} = 'FBA solver statistics'; % Header
description{2} = ''; % Details
fbaStats = addvars(fbaStats, fbaStats.Properties.RowNames, 'Before',1,'NewVariableNames','fileName');
writeSupplement(fbaStats, description, resultPath)

% Summary statistics of flux results
description = cell(2,1); description{1} = 'Summary statistics of predicted fluxes'; % Header
description{2} = ''; % Details
writeSupplement(stats.Flux_summary_statistics, description, resultPath)

% Predicted fluxes
description = cell(2,1); description{1} = 'Predicted reaction fluxes'; % Header
description{2} = ''; % Details
writeSupplement(stats.Fluxes, description, resultPath)

% Predicted reaction fluxes for analysis 
description = cell(2,1); description{1} = 'Predicted reaction fluxes for analysis'; % Header
description{2} = ''; % Details
writeSupplement(stats.Fluxes_removed_reactions, description, resultPath)

% Summary statistics of scaled flux results
description = cell(2,1); description{1} = 'Summary statistics of predicted scaled fluxes for analysis'; % Header
description{2} = ''; % Details
writeSupplement(stats.Scaled_flux_summary_statistics, description, resultPath)

% Predicted reaction fluxes for analysis 
description = cell(2,1); description{1} = 'Predicted scaled reaction fluxes for analysis'; % Header
description{2} = ''; % Details
writeSupplement(stats.Scaled_fluxes, description, resultPath)

if microbiomePresent == true

    % Predicted reaction fluxes for analysis 
    description = cell(2,1); description{1} = 'Flux-microbe spearman correlations'; % Header
    description{2} = ''; % Details
    fluxMicrobeCorr= addvars(fluxMicrobeCorr, fluxMicrobeCorr.Properties.RowNames, 'Before',1,'NewVariableNames','Microbe');
    writeSupplement(fluxMicrobeCorr, description, resultPath)
end

% Output paths
if microbiomePresent == true
    processedFluxResPaths = [string(pathToFluxResults); string(WBMmicrobiomePath);string(resultPath)];
else
    processedFluxResPaths = [string(pathToFluxResults); string(resultPath)];
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

function writeSupplement(suplTable, description, filePath, suplTable2)
% Helper function for populating the supplementary materials excel file

if nargin<4
    suplTable2 = '';
end

% Find the current sheets if the supplementary table file exists
SM = isfile(filePath);
if SM == true
    sheets = sheetnames(filePath); % Find the current sheet names
    maxSheetNum = max(str2double(erase(sheets,'Sheet_'))); % Find the largest sheet number
    if ~isnan(maxSheetNum) % Double check
        sheetNum = char(string(maxSheetNum+1)); % Define the current sheet number as the max + 1
    else
        sheetNum = '1'; % Set sheet number to 1
    end
else
    sheetNum = '1'; % Set sheet number to 1
end

% Create table header:
sheetName = append('Sheet_',sheetNum); % Process sheet name
tableHeader = append(sheetName,": ",string(description{1}));

% Add details to table header
if ~isempty(description{2}) % Only add extra line if a description is given
    details = append("Description: ",string(description{2}));
else
    details = string(description{2});
end

tableHeader = [tableHeader; details];


% Create of update index sheet
if SM == false
    tableHeader = ["INDEX"; tableHeader]; % Add Table header if not present already
end

% Write index table to file, but remove the table details
writematrix(tableHeader( 1:(end-1) ), filePath,'Sheet','Index','WriteMode','append') 

% Remove Index table header
tableHeader(matches(tableHeader,"INDEX"))=[];

% Create new sheet for current supplementary table and write table
% description
writematrix(tableHeader, filePath,'Sheet',sheetName,'WriteMode','overwritesheet')

% Append supplementary table to excel sheet
writetable(suplTable,filePath,'Sheet',sheetName,'Range','A3')

if ~isempty(suplTable2)
    % Place the second table after the second empty column in excel sheet after the main table:
    colNum = width(suplTable)+3;
    colLetter = char(colNum + 64); % Convert to letter in alphabet using ASCII codes
    rangeStart = [colLetter,'4']; % Find excel cell to start
    
    % Append the second supplementary table to excel sheet
    writetable(suplTable2,filePath,'Sheet',sheetName,'Range',rangeStart)
end
if 1
    disp(append('Saved ',sheetName, ' to flux_results.xlsx'))
end
end