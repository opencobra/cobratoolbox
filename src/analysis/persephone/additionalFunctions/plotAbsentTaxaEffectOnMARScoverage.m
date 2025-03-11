function plotAbsentTaxaEffectOnMARScoverage(mars_preprocessedInput, absentTaxa_abundanceMetrics, readCounts, results_path, varargin)
% Based on MARS mapping input, this function generates a plot which
% visualizes how much of an effect the addition of currently unmapped taxa
% to the microbiome community model would have in terms of read coverage, 
% starting from the most abundant taxa.
%
% INPUTS:
%   mars_preprocessedInput:         [table] MARS output "preprocessed_input" which
%                                   contains read counts per pre-mapped taxa.
%   absentTaxa_abundanceMetrics:    [table] MARS output listing all
%                                   unmapped taxa together with summary statistics on their relative
%                                   abundance across samples (mean relative abundance is of importance for
%                                   the function).
%   readCounts:                     [table] Original data table containing
%                                   read counts per taxa.
%   results_path:                   [string] Directory path, where results should be stored (figure).
%   numAbsentTaxaToInvestigate:     [numerical] Number of unmapped taxa
%                                   whose effect should be tested for & plotted. 
%                                   Optional, defaults to the full list of all unmapped taxa.
%
% Authors:
%   - Jonas Widder, 11/2024 & 01/2025

% Check input parameters if defined
parser = inputParser();
parser.addRequired('mars_preprocessedInput', @istable);
parser.addRequired('absentTaxa_abundanceMetrics', @istable);
parser.addRequired('readCounts', @istable);
parser.addRequired('results_path', @(x) ischar(x) | isstring(x));

% Define optional parameters if not defined
parser.addParameter('numAbsentTaxaToInvestigate', NaN, @isnumeric);

% Parse required inputs
parser.parse(mars_preprocessedInput, absentTaxa_abundanceMetrics, readCounts, results_path, varargin{:});

mars_preprocessedInput = parser.Results.mars_preprocessedInput;
absentTaxa_abundanceMetrics = parser.Results.absentTaxa_abundanceMetrics;
readCounts = parser.Results.readCounts;
results_path = parser.Results.results_path;

numAbsentTaxaToInvestigate = parser.Results.numAbsentTaxaToInvestigate;

% Get number of absent species & set numAbsentTaxaToInvestigate if not defined by user
if isnan(numAbsentTaxaToInvestigate)
    numAbsentTaxaToInvestigate = size(absentTaxa_abundanceMetrics, 1);
end

% Preprocess input data
absentTaxa_abundanceMetrics.Taxon = strrep(absentTaxa_abundanceMetrics.Taxon, '_', ' ');
sortedAbsentTaxa_abundanceMetrics = sortrows(absentTaxa_abundanceMetrics, 'mean', 'descend');

readCounts_postMapping = readCounts{2,2:end};
readCounts_preMapping = readCounts{1,2:end};

% Preallocate output arrays for coverage with absent species for all & only
% named taxa (which consist of "genus+epithet")
meanCov_readCounts = zeros(numAbsentTaxaToInvestigate, 1);
stdCov_readCounts = zeros(numAbsentTaxaToInvestigate, 1);

meanCov_readCounts_onlyNamedTaxa = zeros(numAbsentTaxaToInvestigate, 1);
stdCov_readCounts_onlyNamedTaxa = zeros(numAbsentTaxaToInvestigate, 1);

% Calculate base coverage (without absent taxa added)
base_cov_readCounts = readCounts_postMapping ./ readCounts_preMapping;
meanCov_readCounts(1) = mean(base_cov_readCounts);
stdCov_readCounts(1) = std(base_cov_readCounts);
meanCov_readCounts_onlyNamedTaxa(1) = meanCov_readCounts(1);
meanCov_readCounts_onlyNamedTaxa(1) = stdCov_readCounts(1);

% Iterate over absent taxa, starting from most abundand taxa across samples
for idx = 2:numAbsentTaxaToInvestigate
    % Get all absent taxa until the current taxa is reached
    absentTaxa_mostAbundant = sortedAbsentTaxa_abundanceMetrics(1:idx-1,:);
    
    % Filter the mars_preprocessedInput for all these absent taxa & sum their read counts
    mars_preprocessedInput_filtered = mars_preprocessedInput(contains(mars_preprocessedInput.Taxon,absentTaxa_mostAbundant.Taxon),:);
    readCountsPerSample_mostAbundantAbsentTaxa = sum(mars_preprocessedInput_filtered{:,2:end}, 1);
    
    % Get the post mapping read counts if these absent taxa were added
    sum_readCountsTaxa_wAbsentTaxa = sum([readCounts_postMapping; readCountsPerSample_mostAbundantAbsentTaxa], 1);
    
    % Calculate read counts coverage mean across samples from there & store
    cov_readCounts = sum_readCountsTaxa_wAbsentTaxa ./ readCounts_preMapping;
    temp_meanCov_readCounts = mean(cov_readCounts);
    temp_stdCov_readCounts = std(cov_readCounts);

    meanCov_readCounts(idx) = temp_meanCov_readCounts;
    stdCov_readCounts(idx) = temp_stdCov_readCounts;

    % Repeat the same procedure only for those taxa with "genus+epithet" naming convention
    contains_no_dash = ~contains(absentTaxa_mostAbundant.Taxon, '-');
    contains_noMultiple_uppercases = cellfun(@isempty, regexp(absentTaxa_mostAbundant.Taxon, '[A-Z]{2,}'));
    absentTaxa_mostAbundant_wStandardName = absentTaxa_mostAbundant(contains_no_dash & contains_noMultiple_uppercases, :);

    mars_preprocessedInput_filtered_onlyNamedTaxa = mars_preprocessedInput(contains(mars_preprocessedInput.Taxon,absentTaxa_mostAbundant_wStandardName.Taxon),:);
    readCountsPerSample_mostAbundantAbsentTaxa_onlyNamedTaxa = sum(mars_preprocessedInput_filtered_onlyNamedTaxa{:,2:end}, 1);
        
    sum_readCountsTaxa_wAbsentTaxa_onlyNamedTaxa = sum([readCounts_postMapping; readCountsPerSample_mostAbundantAbsentTaxa_onlyNamedTaxa], 1);
        
    cov_readCounts_onlyNamedTaxa = sum_readCountsTaxa_wAbsentTaxa_onlyNamedTaxa ./ readCounts_preMapping;
    temp_meanCov_readCounts_onlyNamedTaxa = mean(cov_readCounts_onlyNamedTaxa);
    temp_stdCov_readCounts_onlyNamedTaxa = std(cov_readCounts_onlyNamedTaxa);

    meanCov_readCounts_onlyNamedTaxa(idx) = temp_meanCov_readCounts_onlyNamedTaxa;
    stdCov_readCounts_onlyNamedTaxa(idx) = temp_stdCov_readCounts_onlyNamedTaxa;
end

x = 0:numAbsentTaxaToInvestigate-1;
f1 = figure;
plot(x, meanCov_readCounts, 'b-', x, meanCov_readCounts_onlyNamedTaxa, 'r-', 'LineWidth', 1)
legend('All absent taxa', 'Absent taxa with standard nomenclature (genus+epithet)', 'Location', 'best')
xlabel({'Number of absent taxa added to present taxa,', 'from most abundant  to least abundant across samples'}, 'FontName', 'Arial', 'FontSize', 12)
ylabel({'Mean MARS mapping coverage', 'against model database (%)'}, 'FontName', 'Arial', 'FontSize', 12)
ylim([meanCov_readCounts(1) 1]);
set(gca, 'FontName', 'Arial', 'FontSize', 10);
set(f1, 'Color', 'white');
exportgraphics(f1, results_path + "effectOfAbsentTaxaOnReadCoverageMARS.png", "Resolution", 300)
close(f1)

end