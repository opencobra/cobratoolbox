function dimensionalityReductionAndMultivariateAnalysis(measuresTable, metadataTable, varOfInterest, results_path, varargin)
% Dimensionality reduction of high-dimensional measures (e.g. microbiome relative abundances
% or reaction relative abundances) by RPCA following data preprocessing OR beta-diversity measures by PCoA, 
% with the aim to:
%   1. Find whether there are general differences between groups of a metadata variable of interest 
%   (e.g. disease vs ctrl status), in case variable is categorical.
%   2. Identify variables from the measures (e.g. microbial taxa, reactions)
%   which contribute the most to the first principle component (PC1) of RPCA &
%   therefore its explained variance.
%   3. Perform linear regression on PC1 ~ metadata variable (e.g. Sex, disease vs Ctrl status)
%   to find metadata variables which might be important confounders in
%   follow-up analysis in case they are significantly correlated &
%   explain a lot of the variance of PC1 from RPCA/PCoA.
%
% INPUTS:
%   measuresTable:  [table] Contains high-dimensional measures (e.g. microbiome relative abundances
%                   or reaction relative abundances), with columns = samples & 
%                   rows = measured groups (e.g. taxa/reactions).
%   metadataTable:  [table] Contains metadata information for samples (e.g.
%                   sex), with columns = variables (e.g. Sex) & rows = samples.
%   varOfInterest:  [string] Variable (e.g. Sex or disease status)
%                   contained in metadata.
%   results_path:   [string] Directory path, where results should be stored
%                   (figures & statistical results in spreadsheet format).
%   varargin:
%   numLoadings:    [numeric] Number of PC loadings which shall be
%                   displayed in plot of PC strongest feature
%                   contributions.
%                   Defaults to 15 loadings.
%   inputDataType:  [chars/string] Specify whether data input is of type "abundance" or
%                   "betaDiversityMatrix", which results in alternative processing routes
%                   (the input is treated case-insensitive).
%                   Defaults to "abundance".
%   PCofInterest:   [numeric] Principle component/principle coordinate of
%                   interest, which analysis will be performed on.
%                   Defaults to PC 1.
% OUTPUTS:
%   In form of tables & plots into dir at results_path location.
%
% Authors:
%   - Jonas Widder, 12/2024 & 01/2025

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 1: Load input parameters, format input tables & 
% create results dir in case it doesn't exit already.
% Parse inputs
p = inputParser();
p.addRequired('measuresTable', @istable);
p.addRequired('metadataTable', @istable);
p.addRequired('varOfInterest', @(x) ischar(x) | isstring(x));
p.addRequired('results_path', @(x) ischar(x) | isstring(x));
p.addParameter('numLoadings', 15, @isnumeric);
p.addParameter('inputDataType', "abundance", @(x) ischar(x) | isstring(x));
p.addParameter('PCofInterest', 1, @isnumeric);
p.parse(measuresTable, metadataTable, varOfInterest, results_path, varargin{:});

% Extract parsed results
numLoadings = p.Results.numLoadings;
inputDataType = lower(p.Results.inputDataType);
PCofInterest = p.Results.PCofInterest;

% Reorder samples in metadata table
samples = measuresTable.Properties.VariableNames;
metadataTable = metadataTable(samples,:);

% Convert measures table to array
measuresMatrix = table2array(measuresTable);

% Generate results dir at location of results_path if not existant already
if ~exist(results_path, 'dir')
    mkdir(results_path);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 2: Dimensionality reduction via RPCA/PCoA with data preprocessing
% for RPCA via robust centered-log-ratio transformation.
if strcmp(inputDataType, "abundance")
    % Preprocess measures for RPCA
    relMeasures = measuresMatrix ./ sum(measuresMatrix, 1);
    logMeasures = log(relMeasures);
    logMeasures(isinf(logMeasures)) = NaN;
    geomMean = exp(mean(logMeasures, 1, "omitnan"));
    measuresStandardized = logMeasures - log(geomMean);
    measuresStandardized(isnan(measuresStandardized)) = 0;
    
    % Perform RPCA
    [coeff, PCscores, ~, ~, explVar] = pca(measuresStandardized', 'Centered', false, 'Algorithm', 'als');
elseif strcmp(inputDataType, "betadiversitymatrix")
    % Perform PCoA for beta diversity matrix
    [PCscores, eigvals] = cmdscale(measuresMatrix);
    explVar = eigvals / sum(eigvals) * 100;
    coeff = [];
end

% Plot cumulative variance
plotCumulativeVariance(explVar, inputDataType, results_path);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 3: Analysis of metadata variable of interest, whether associated with
% variance in dimensionality reduced dataset + analysis of feature
% contribution to PC of interest.

% Plot PCA/PCoA results
plotPCAorPCoA(PCscores, metadataTable, varOfInterest, explVar, inputDataType, results_path);

% Perform statistical tests and create violin plot
PCofInterestScore = PCscores(:,PCofInterest);
performStatisticalTests(PCofInterestScore, PCofInterest, metadataTable, varOfInterest, results_path);

% Plot loadings for RPCA
if strcmp(inputDataType, "abundance")
    plotLoadings(coeff, measuresTable, numLoadings, PCofInterest, results_path);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 4: Explore which metadata variables are significantly correlated to PC1, 
% can explain the variance in PC1 & should therefore potentially be used 
% as confounders in subsequent analysis.
exploreMetadataCorrelations(metadataTable, PCofInterestScore, PCofInterest, results_path);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Local helper functions
function plotCumulativeVariance(explVar, inputDataType, results_path)
    % Plots cumulative variance from PCA/PCoA as a line plot.
    cumVar = cumsum(explVar);
    f1 = figure;
    plot(cumVar, 'LineWidth', 1, 'Color', 'black');
    xlabel(['Number of Principal ', ternary(strcmp(inputDataType, "abundance"), 'Components', 'Coordinates')], 'FontName', 'Arial', 'FontSize', 12);
    ylabel('Cumulative Variance Explained (%)', 'FontName', 'Arial', 'FontSize', 12);
    title(['Cumulative Variance Explained by Principal ', ternary(strcmp(inputDataType, "abundance"), 'Components', 'Coordinates')], 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold');
    ylim([0 100]);
    xlim([1 length(cumVar)]);
    set(gca, 'FontName', 'Arial', 'FontSize', 10);
    set(f1, 'Color', 'white');
    exportgraphics(f1, results_path + ternary(strcmp(inputDataType, "abundance"), "PCA_cumulativeVariance.png", "PCoA_cumulativeVariance.png"), "Resolution", 300)
    close(f1)
end

function plotPCAorPCoA(PCscores, metadataTable, varOfInterest, explVar, inputDataType, results_path)
    % Scatterplot of first two Principle Components/Principle Coordinates
    % of RPCA/PCoA, labeled by groups of metadata variable of interest.
    f2 = figure;
    uniqueCategories = unique(metadataTable.(varOfInterest));
    colorMap = lines(length(uniqueCategories));
    
    hold on;
    for i = 1:length(uniqueCategories)
        category = uniqueCategories(i);
        idx = metadataTable.(varOfInterest) == category;
        scatter(PCscores(idx,1), PCscores(idx,2), 20, colorMap(i,:), 'DisplayName', string(category));
    end
    hold off;
    
    xlabel([ternary(strcmp(inputDataType, "abundance"), 'Principle Component 1 (', 'Principle Coordinate 1 (') num2str(explVar(1), '%.1f') '%)'], 'FontName', 'Arial', 'FontSize', 12);
    ylabel([ternary(strcmp(inputDataType, "abundance"), 'Principle Component 2 (', 'Principle Coordinate 2 (') num2str(explVar(2), '%.1f') '%)'], 'FontName', 'Arial', 'FontSize', 12);
    title([ternary(strcmp(inputDataType, "abundance"), 'PCA', 'PCoA') ' of measures labeled by ', varOfInterest], 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold')
    
    if isnumeric(metadataTable.(varOfInterest))
        colorbar;
    else
        legend('Location', 'best');
    end
    
    set(gca, 'FontName', 'Arial', 'FontSize', 10);
    set(f2, 'Color', 'white');
    exportgraphics(f2, results_path + ternary(strcmp(inputDataType, "abundance"), "PCA_labeledBy", "PCoA_labeledBy") + varOfInterest + ".png", "Resolution", 300)
    close(f2);
end

function performStatisticalTests(PCofInterestScore, PCofInterest, metadataTable, varOfInterest, results_path)
    % Performs Mann-Whitney U test between PC of interest-scores from two groups of metadata variable
    % of interest, or Kruskal Wallis test in case there are more than two groups to compare.
    if ~isnumeric(metadataTable.(varOfInterest))    
        [categories, ~, ic] = unique(metadataTable.(varOfInterest));
        ic_namedByCategories = categories(ic);
        [p_kruskal, tbl_kruskal, ~] = kruskalwallis(PCofInterestScore, ic_namedByCategories);
        
        % Figure: Violinplot showing PC of interest scores distribution for all groups
        % of categorical metadata variable
        figure;
        violinplot(PCofInterestScore, ic_namedByCategories);
        
        title([ternary(numel(categories) > 2, 'Kruskal-Wallis Test', 'Mann-Whitney U Test') ' between categories of ' varOfInterest ...
       ' for PC' num2str(PCofInterest) ', with p = ' num2str(p_kruskal, '%.4g')], ...
       'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold', 'Interpreter', 'none');
        ylabel(['PC' num2str(PCofInterest) ' score'], 'FontName', 'Arial', 'FontSize', 12)
        xlabel(varOfInterest, 'FontName', 'Arial', 'FontSize', 12);
        set(gca, 'FontName', 'Arial', 'FontSize', 10);
        set(gca, 'Color', 'white');
        
        saveas(gcf, results_path + "kruskalwallisTest_violinPlot_CategoriesOf" + varOfInterest + ".png");
        writecell(tbl_kruskal, results_path + "kruskalwallisTest_StatResults_CategoriesOf" + varOfInterest + ".xlsx")
    end
end

function plotLoadings(coeff, measuresTable, numLoadings, PCofInterest, results_path)
    % Barplot displaying a certain number (numLoadings) of loadings from
    % Principle component of interest based on RPCA, in decending order beginning
    % with the highest loading.
    pcOfInterestLoadings = coeff(:, PCofInterest);
    [sortedLoadings, sortIdx] = sort(abs(pcOfInterestLoadings), 'descend');
    
    % Figure 3: Displays loadings for PC of interest
    f3 = figure;
    bar(sortedLoadings(1:numLoadings));
    ylabel(['PC' num2str(PCofInterest) ' Loading'], 'FontName', 'Arial', 'FontSize', 12);
    title(['The ' num2str(numLoadings) ' strongest Contributors to PC' num2str(PCofInterest) ' sorted in descending Order'], 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold')
    
    loadingNames = measuresTable.Properties.RowNames;
    loadingNames_reordered = loadingNames(sortIdx);
    xticks(1:length(loadingNames_reordered(1:numLoadings)));
    xticklabels(loadingNames_reordered(1:numLoadings));
    xtickangle(45);
    set(gca, 'FontName', 'Arial', 'FontSize', 10, 'TickLabelInterpreter', 'none');
    set(f3, 'Color', 'white');
    exportgraphics(f3, results_path + "Loadings_PC" + string(PCofInterest) + "1.png", "Resolution", 300)
    close(f3);
end

function exploreMetadataCorrelations(metadataTable, PCofInterestScore, PCofInterest, results_path)
    % Performs linear regression with Formula PC of interest ~ metadata variable (iterates over 
    % all metadata variables in metadataTable), and stores + plots results.
    metadataVars = metadataTable.Properties.VariableNames;
    numVars = length(metadataVars);
    regressions = struct;

    % Create empty table
    varNames = {'Formula','Predictor','Regression_type','N','estimate','SE','tStat','pValue','FDR','R2'};
    varTypes = [repmat({'string'},1,4),repmat({'double'},1,length(varNames)-4)];
    generalTable = table('Size',[numVars,length(varNames)],'VariableTypes',varTypes,'VariableNames',varNames);
    
    for i = 1:numVars
        lastwarn('')
        currentVar = metadataTable.(metadataVars{i});
        mdl = fitlm(currentVar, PCofInterestScore);

        % If no good fit could be found, do not save the result
        warnMsg = lastwarn;
        responseVar = strcat("PC", num2str(PCofInterest), "score ~ ");
        if ~isempty(warnMsg)
            regressions.(string(metadataVars(i))) = {};
            generalTable(i,:) = {strcat(responseVar, metadataVars{i}), metadataVars{i}, "linear_regression", NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN};
        else
            regressions.(string(metadataVars(i))) = mdl;
            
            % Fill in table with regression results
            generalTable.Formula(i) = strcat(responseVar, metadataVars(i));
            generalTable.Predictor(i) = metadataVars(i);
            generalTable.Regression_type(i) = "linear_regression";
            generalTable.N(i) = mdl.NumObservations;
            generalTable.estimate(i) = mdl.Coefficients.Estimate(2); % Slope estimate
            generalTable.SE(i) = mdl.Coefficients.SE(2); % Standard error for slope
            generalTable.tStat(i) = mdl.Coefficients.tStat(2); % t-statistic for slope
            generalTable.pValue(i) = mdl.Coefficients.pValue(2); % p-value for slope
            generalTable.R2(i) = mdl.Rsquared.Ordinary; % R-squared value
        end
    end
    
    % Calculate FDR (False Discovery Rate)
    pValues = generalTable.pValue;
    FDR = mafdr(pValues, 'BHFDR', true);
    generalTable.FDR = FDR;
    
    % Sort the table by p-value
    generalTable = sortrows(generalTable, 'pValue');
    
    % Save the results
    writetable(generalTable, fullfile(results_path, ['linearRegression_metadataCorrelationsWithPC' num2str(PCofInterest) '.csv']))


    % Filter for significant variables
    significantIdx = pValues < 0.05;
    significantVars = metadataVars(significantIdx);
    significantRSquared = generalTable.R2(significantIdx);
    significantCoefficients = generalTable.estimate(significantIdx);
    
    % Sort the significant variables
    [sorted_rSquared, rSquared_idx] = sort(significantRSquared, 'descend');
    sortedVars = significantVars(rSquared_idx);
    
    % Figure 4: R2 for significant variables
    f4 = figure;
    bar(sorted_rSquared);
    xticks(1:length(sortedVars));
    xticklabels(sortedVars);
    xtickangle(45);
    ylabel('R-squared (%)', 'FontName', 'Arial', 'FontSize', 12);
    title(['Explained Variance for PC' num2str(PCofInterest) ' by Significant Metadata Variables'], 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold');
    set(gca, 'FontName', 'Arial', 'FontSize', 10);
    set(f4, 'Color', 'white');
    exportgraphics(f4, results_path + "LinearRegressionOnPC" + PCofInterest + "_R2SignificantMetadataVars.png", "Resolution", 300)
    close(f4)
    
    % Figure 5: Regression coefficients for significant variables
    f5 = figure;
    h = bar(significantCoefficients);
    h.FaceColor = 'flat';
    h.CData(significantCoefficients < 0,:) = repmat([1 0 0], sum(significantCoefficients < 0), 1);
    h.CData(significantCoefficients >= 0,:) = repmat([0 114/255 189/255], sum(significantCoefficients >= 0), 1);
    
    xticks(1:length(significantVars));
    xticklabels(significantVars);
    xtickangle(45);
    ylabel('Regression coefficient', 'FontName', 'Arial', 'FontSize', 12);
    title(['Regression Coefficients of Significantly Correlated Metadata Variables with PC' num2str(PCofInterest) ' (pValue < 0.05)'], 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold');
    set(gca, 'FontName', 'Arial', 'FontSize', 10);
    set(f5, 'Color', 'white');
    exportgraphics(f5, results_path + "LinearRegressionOnPC" + num2str(PCofInterest) + "_coefficients_SignificantMetadataVars.png", "Resolution", 300)
    close(f5)

    % Figure 6: R2 versus Regression coefficients, labeled by their p-Value
    f6 = figure;
    scatter(generalTable.R2, generalTable.estimate, 50, pValues, 'filled');
    hold on;
    text(generalTable.R2, generalTable.estimate, metadataVars, 'FontSize', 10, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
    xlabel('R-squared (%)', 'FontName', 'Arial', 'FontSize', 12);
    ylabel('Regression coefficient', 'FontName', 'Arial', 'FontSize', 12);
    title(['R-squared vs Regression Coefficients for Metadata Variables for PC' num2str(PCofInterest)], 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold');
    c = colorbar;
    colormap(flipud(parula));
    clim([0, 0.05]);
    c.Label.String = 'p-value';
    c.Label.FontSize = 12;
    c.Label.FontName = 'Arial';
    c.Ticks = [0, 0.025, 0.05];
    c.TickLabels = {'0', '0.025', '≥0.05'};
    set(gca, 'FontName', 'Arial', 'FontSize', 10);
    set(f6, 'Color', 'white');
    set(f6, 'Position', [100, 100, 800, 600]);
    exportgraphics(f6, results_path + "LinearRegressionOnPC" + PCofInterest + "_RSquared_vs_Coefficients_MetadataVars.png", "Resolution", 300)
    close(f6)
end

function result = ternary(condition, if_true, if_false)
    if condition
        result = if_true;
    else
        result = if_false;
    end
end