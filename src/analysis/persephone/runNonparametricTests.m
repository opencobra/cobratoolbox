function resultTable = runNonparametricTests(data, metadata, predictor, response)
% Performs non-parametric statistical tests (Wilcoxon or Kruskal-Wallis) on metabolic data
%
% USAGE:
%    resultTable = runNonparametricTests(data, metadata, predictor, response)
%
% INPUTS:
%    data:          (table) m x n table containing:
%                   * m samples
%                   * n reactions/taxa with flux or abundance values
%                   * First column must contain sample IDs
%    metadata:      (table) Sample metadata containing:
%                   * Sample IDs in first column
%                   * Response variable in separate column
%    predictor:     (char) Name of predictor variable ('Flux' or 'relative_abundance')
%    response:      (char) Name of response variable in metadata
%
% OUTPUTS:
%    resultTable:   (table) Statistical results with columns:
%                   * name:      Reaction/Taxa identifier
%                   * groups:    Cell array of group names
%                   * n:         Array of group sizes
%                   * statistic: Test statistic (Wilcoxon or Kruskal-Wallis)
%                   * p-value:   Unadjusted p-value
%                   * FDR:       Benjamini-Hochberg adjusted p-value
%                   * effectSize: Effect size (r for Wilcoxon, η² for Kruskal-Wallis)
%                   * confidence: 95% confidence interval (only for binary comparisons)
%
% EXAMPLE:
%    % Binary comparison (Wilcoxon test)
%    resultTable = runNonparametricTests(fluxData, metadata, 'Flux', 'Disease')
%
%    % Multiple group comparison (Kruskal-Wallis test)
%    resultTable = runNonparametricTests(abundanceData, metadata, 'relative_abundance', 'Treatment')
%
% NOTE:
%    1. Automatically selects appropriate test based on number of groups
%    2. Data is automatically normalized before testing
%    3. Missing values (NaN) are removed before analysis
%    4. Multiple testing correction uses Benjamini-Hochberg FDR
%    5. Minimum group size of 3 samples is required for valid testing
%
% .. Author: Tim Hensen (07/2024)

% Input validation
validateattributes(data, {'table'}, {'nonempty'}, mfilename, 'data')
validateattributes(metadata, {'table'}, {'nonempty'}, mfilename, 'metadata')
validateattributes(predictor, {'char', 'string'}, {'nonempty'}, mfilename, 'predictor')
validateattributes(response, {'char', 'string','numeric'}, {'nonempty'}, mfilename, 'response')

% Test if the response variable is not numeric
responseMetadataVar = metadata.(string(response));
validateattributes(responseMetadataVar, {'cell', 'string'}, {'nonempty'}, mfilename, 'Response variable in the metadata')


% Ensure required columns exist
if ~ismember('ID', data.Properties.VariableNames)
    error('COBRA:BadInput', 'Data table must contain an ID column')
end
if ~ismember('ID', metadata.Properties.VariableNames)
    error('COBRA:BadInput', 'Metadata table must contain an ID column')
end
if ~ismember(string(response), metadata.Properties.VariableNames)
    error('COBRA:BadInput', 'Response variable %s not found in metadata', response)
end

% Remove empty values in metadata response
metadata(cellfun(@isempty,metadata.(string(response))),:)=[];

% Convert response to categorical
metadata.Response = categorical(metadata.(string(response)));

if ~isnumeric(metadata.Response)
% Convert response variable data to numerical data
    metadata.Response = grp2idx(metadata.Response)-1;
end

% Check number of groups in response variable
uniqueGroups = unique(metadata.Response);
numGroups = length(uniqueGroups);
if numGroups < 2
    error('COBRA:BadInput', 'Response must have at least 2 groups, found %d', numGroups)
end

% Validate and process predictor type
switch lower(predictor)
    case 'flux'
        value = 'Flux';
        name = 'Reaction';
    case 'relative_abundance'
        value = 'relative_abundance';
        name = 'Taxa';
    otherwise
        error('COBRA:BadInput', 'Predictor must be either ''Flux'' or ''relative_abundance''')
end

% Extract variable names (excluding ID column)
names = setdiff(data.Properties.VariableNames, {'ID'});
if isempty(names)
    error('COBRA:BadInput', 'No valid measurement columns found in data')
end

% Reshape data to long format and clean IDs
data = stack(data, names, 'NewDataVariableName', value, 'IndexVariableName', name);
data.ID = strrep(data.ID, 'HM_', '');

% Merge with metadata and handle missing data
metadata.ID = string(metadata.ID);
data.ID = string(data.ID);
data = innerjoin(data, metadata, 'Keys', 'ID');

% Group by reactions/taxa
[groups, groupnames] = findgroups(data.(name));
groupnames = string(groupnames);

% Initialize results table with appropriate columns based on test type
if numGroups == 2
    % Wilcoxon test columns
    varNames = {name,'method', 'group1', 'group2', 'n1', 'n2', 'statistic', 'p-value', ...
               'FDR', 'r_effectSize'};
    varTypes = [repmat({'string'}, 1,4), repmat({'double'}, 1, length(varNames)-4)];

else
    % Kruskal-Wallis test columns
    varNames = {name,'method', 'n', 'statistic', 'p-value', 'FDR', 'eta2_effectSize'};
    varTypes = [repmat({'string'}, 1,2), repmat({'double'}, 1, length(varNames)-2)];
end

% Create table
resultTable = table('Size', [length(groupnames), length(varNames)], ...
                   'VariableTypes', varTypes, ...
                   'VariableNames', varNames);

% Populate basic information
resultTable.(name) = groupnames;

% Perform statistical tests
for i = 1:length(groupnames)
    dataGroup = data(groups == i, :);

    % Get normalised data for the predictors
    normalizedData = dataGroup.(predictor);
    
    if numGroups == 2
        % Add test method information
        resultTable.method(i) = "Wilcoxon rank sum test";

        % Wilcoxon rank-sum test for binary comparison
        group1Data = normalizedData(dataGroup.Response == uniqueGroups(1));
        group2Data = normalizedData(dataGroup.Response == uniqueGroups(2));
        
        % Record group information
        resultTable.group1(i) = string(uniqueGroups(1));
        resultTable.group2(i) = string(uniqueGroups(2));
        resultTable.n1(i) = length(group1Data);
        resultTable.n2(i) = length(group2Data);

        % Do not perform ranksum test if there are not enough samples with
        % flux predictions
        nanFraction1 = sum(isnan(group1Data)) / numel(group1Data);
        nanFraction2 = sum(isnan(group2Data)) / numel(group2Data);
        
        if nanFraction1 < 0.3 && nanFraction2 < 0.3
            % Perform test
            [p, ~, stats] = ranksum(group1Data, group2Data);
            resultTable.("p-value")(i) = p;
            resultTable.statistic(i) = stats.ranksum;
        else
            p = nan;
            resultTable.statistic(i) = nan;
        end

        
        % Calculate the nonparametric effect size
        % Tomczak, M., & Tomczak, E. (2014). The need to report effect size estimates 
        % revisited. An overview of some recommended measures of effect size.
        % The non-parametric effect size for Mann-Whitney tests and Wilcoxon
        % ran sum tests be calculated by r = Z / sqrt(n). r, where r is the
        % rank correlation.

        Z =  norminv(p/2);  % Get z-value
        r = abs(Z) / sqrt(length(group1Data) + length(group2Data)); % Calculate effect size
        resultTable.r_effectSize(i) = r;

    else
        % Kruskal-Wallis test for multiple groups

        % Add test method information
        resultTable.method(i) = "Kruskall-Wallis test";

        % Perform test
        [p, tbl, stats] = kruskalwallis(normalizedData, dataGroup.Response, 'off');
        resultTable.("p-value")(i) = p; % Store p-value
        resultTable.n(i) = sum(stats.n); % Store sample size
        resultTable.statistic(i) = tbl{2,5}; % Get chi-square statistic
        
        % Calculate the eta-squared effect size (η² = (H-k+1)/(n-k)) for
        % the krusktal-wallis h-test statistic. η² indicates the percentage
        % of variance in the dependent variable explained
        % by the independent variable.
        H = tbl{2,5}; % Get chi-square statistic
        k = numGroups;
        n = sum(stats.n);
        eta_squared = (H - k + 1)/(n - k);
        resultTable.eta2_effectSize(i) = eta_squared;
    end
end

% Calculate FDR-adjusted p-values
% resultTable.FDR = mafdr(resultTable.("p-value"), 'BHFDR', true);
resultTable.FDR = fdrBHadjustment(resultTable.("p-value")); % Local alternative. 

% Sort results by FDR
resultTable = sortrows(resultTable, 'FDR', 'ascend');

end