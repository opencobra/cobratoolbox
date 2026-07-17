function [bray, pielous, taxonSummary] = calculateMetrics(data, calculateBrayCurtis)
% Calculate diversity and descriptive metrics for a microbiome abundance table
%
% Calculates Pielou's evenness, the Bray-Curtis dissimilarity, and
% descriptive statistics for the taxa in a reads or relative-abundance table
% of a microbiome sample. Developed for MARS for MATLAB and used in runMars.
%
% USAGE:
%
%    [bray, pielous, taxonSummary] = calculateMetrics(data, calculateBrayCurtis)
%
% INPUTS:
%    data:                   m x n table with taxa in rows and samples in
%                            columns. The first column must be called `Taxon`
%                            and hold (non-duplicated) taxonomic identifiers;
%                            the remaining columns hold the per-sample
%                            abundances. Fields used:
%
%                              * .Properties - table properties; the sample
%                                names in `.VariableNames` label the outputs
%                              * .Taxon - column of taxonomic identifiers,
%                                used as the row names of taxonSummary
%    calculateBrayCurtis:    logical, true to calculate the Bray-Curtis
%                            dissimilarity. Large sample sizes (n > 200) have
%                            high computation times
%
% OUTPUTS:
%    bray:            table with the Bray-Curtis dissimilarity index; rows and
%                     columns are samples and the diagonal is 0
%    pielous:         array with the Pielou evenness (alpha diversity) score
%    taxonSummary:    table with descriptive statistics on the abundance of
%                     the different taxa in the input table

bray = zeros(size(data,2), size(data,2));

% Sum all columns for faster caclulation times
if size(data,1) == 1
    dataSummed = [0, data{:,2:end}];
else
    dataSummed = [0, sum(data{:, 2:end})];
end

if calculateBrayCurtis
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