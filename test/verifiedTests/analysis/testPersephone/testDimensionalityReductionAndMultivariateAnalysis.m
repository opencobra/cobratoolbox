% The COBRAToolbox: testDimensionalityReductionAndMultivariateAnalysis.m
%
% Purpose:
%     - dimensionalityReductionAndMultivariateAnalysis reduces a table of measures (rows =
%       features, columns = samples) by robust PCA after a centred log-ratio transform, or a
%       beta-diversity matrix by PCoA, plots the explained variance, the scores labelled by a
%       metadata variable and the loadings, tests the groups of a categorical variable
%       (Kruskal-Wallis), and regresses the chosen principal component on every metadata
%       variable, writing a CSV table and figures to results_path. The function is
%       QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): it errors
%       for a metadata variable whose regression is rank deficient, and its regression
%       figures pair values and names of different variables (defects below), so no
%       assertion about the function is made.
%
% Function under test:
%     src/analysis/persephone/additionalFunctions/dimensionalityReductionAndMultivariateAnalysis.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use hand-built tables, invisible figures
%     and a temporary results folder.
%
% Coverage exemptions:
%     every line - dimensionalityReductionAndMultivariateAnalysis is quarantined for the
%     defects below (feature 20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Errors when the regression of a metadata variable gives a warning
%       SEVERITY: error
%       TRIGGER: rng(1); s = arrayfun(@(k) sprintf('s%d', k), 1:10, 'UniformOutput', false);
%         M = array2table(rand(6, 10) + 0.1, 'VariableNames', s, 'RowNames',
%         {'t1', 't2', 't3', 't4', 't5', 't6'}); meta = table((1:10)', ones(10, 1),
%         'VariableNames', {'V2', 'Const'}, 'RowNames', s');
%         dimensionalityReductionAndMultivariateAnalysis(M, meta, 'V2', [tempname filesep],
%         'numLoadings', 3)
%       OBSERVED: warning 'Regression design matrix is rank deficient to within machine
%         precision.' from cobraFitlm (line 248) for the constant variable, then
%         MATLAB:table:VarDimensionMismatch, The number of table variables in an assignment
%         must match. (line 255 assigns 12 values to a row of the 10-column table)
%       EXPECTED: the row of that variable holds its formula, predictor, regression type and
%         NaN statistics (as the comment 'do not save the result' intends) and the analysis
%         continues
%       LINES: 255
%     - DEFECT: The regression figures pair the values of one variable with the name of another
%       SEVERITY: wrong-result
%       TRIGGER: M as above (rng(1), 6 x 10); pc1 = first score column of
%         cobraPca(clr(M)', 'Centered', false, 'Algorithm', 'als'); metadata V1 = rand,
%         V2 = pc1 + 0.01 * randn, V3 = -pc1 + 0.3 * std(pc1) * randn (10 x 1 each); call with
%         varOfInterest 'V2' and 'numLoadings', 3
%       OBSERVED: the CSV table (sorted by p-value) holds V2 R2 0.99989 estimate 1.0014,
%         V3 R2 0.91242 estimate -0.95694, V1 R2 0.0090745 estimate 0.37112; the R2 bar chart
%         shows [0.9124 0.0091] and the coefficient chart [-0.9569 0.3711], both labelled
%         {V2, V3}. significantIdx (line 285) comes from the unsorted p-values but indexes the
%         table sorted on line 278; line 328 labels the sorted points with the unsorted names.
%       EXPECTED: R2 [0.99989 0.91242] and coefficients [1.0014 -0.95694] labelled {V2, V3}
%       LINES: 285-288, 328
%     - DEFECT: A text (cell array) variable of interest is not supported
%       SEVERITY: error
%       TRIGGER: M and s as in the first entry; meta = table((1:10)', [repmat({'a'}, 5, 1);
%         repmat({'b'}, 5, 1)], 'VariableNames', {'V2', 'Group'}, 'RowNames', s'); (text as a
%         cellstr, as readtable returns it by default) called with varOfInterest 'Group'
%       OBSERVED: MATLAB:math:mustBeNumericCharOrLogical, Invalid data type. Argument must be
%         numeric, char, or logical. (line 162 compares cells with ==); string and
%         categorical variables pass this line
%       EXPECTED: groups of a text variable are plotted as those of a categorical one.
%         Severity audit 2026-11-15: metadataTable is documented as "metadata for the samples
%         (e.g. sex), with columns = variables (e.g. Sex)" and varOfInterest as a "variable
%         (e.g. Sex or disease status) contained in the metadata"; a text variable as
%         readtable returns it (cellstr) stops at line 162 - a documented input that fails
%         when used
%       LINES: 162
%     - DEFECT: The loadings figure of PC 1 is saved as Loadings_PC11.png
%       SEVERITY: cosmetic
%       TRIGGER: any call with inputDataType 'abundance' and PCofInterest 1
%       OBSERVED: file Loadings_PC11.png (a literal '1' follows the PC number)
%       EXPECTED: Loadings_PC1.png
%       LINES: 229
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDimensionalityReductionAndMultivariateAnalysis'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
