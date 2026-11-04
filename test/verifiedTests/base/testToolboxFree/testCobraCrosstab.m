% The COBRAToolbox: testCobraCrosstab.m
%
% Purpose:
%     - cobraCrosstab is the plain-MATLAB replacement for crosstab (Statistics and Machine
%       Learning Toolbox). This test checks every syntax used by the call sites in src/
%       ([tbl, ~, ~, labels] = crosstab(response, sex) with text variables), the rules of
%       mathworks-semantics.md section 8 (levels in grp2idx order, rows with a missing value
%       left out, labels padded with [], Pearson chi-square without continuity correction,
%       df = (r-1)(c-1), NaN when fewer than two variables have more than one level), the
%       errors for unsupported input, and parity with crosstab when the toolbox is installed.
%     - Reference values: (a) the MathWorks documentation examples at
%       https://www.mathworks.com/help/stats/crosstab.html (the x/y table; the unidrnd
%       table [1 6 7; 5 5 2; 11 7 6] with chi2 = 7.5449, p = 0.1097; hospital Sex x Smoker
%       [40 13; 26 21] with chi2 = 4.5083, p = 0.0337; 4 decimals shown, so compared with an
%       absolute tolerance of 5e-5); (b) SciPy 1.16.0
%       scipy.stats.chi2_contingency(correction=False) printed by
%       specs/20261103-120403-toolbox-free-replacements/references/tables.py (chi2 and p
%       compared with a relative tolerance of 1e-12: the same closed form for chi2, and two
%       double-precision implementations of the regularized upper incomplete gamma function
%       for p). Counts and labels are compared exactly.
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraCrosstab.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCobraCrosstab'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% call site performStatsPersephone: text response x sex, missing response left out

response = {'case'; 'control'; 'case'; ''; 'control'; 'case'; 'control'; 'case'; 'control'; 'case'};
sex = {'M'; 'F'; 'F'; 'M'; 'M'; 'M'; 'F'; 'F'; 'F'; 'M'};
[crosstabulationTable, chi2, p, labels] = cobraCrosstab(response, sex);
% tables.py: levels in order of first appearance, table [3 2; 1 3] (the row with '' is left out)
assert(isequal(crosstabulationTable, [3 2; 1 3]));
assert(isequal(labels, {'case', 'M'; 'control', 'F'}));
% SciPy 1.16.0 chi2_contingency(correction=False): chi2 1.1024999999999996, p 0.29371811275178894
assert(abs(chi2 - 1.1024999999999996) <= 1e-12 * 1.1024999999999996);
assert(abs(p - 0.29371811275178894) <= 1e-12 * 0.29371811275178894);
% the call site removes empty labels and builds a table with row and variable names
rowNames = labels(:, 1);
colNames = labels(:, 2);
rowNames(cellfun('isempty', rowNames)) = [];
colNames(cellfun('isempty', colNames)) = [];
callSiteTable = array2table(crosstabulationTable, 'RowNames', rowNames, 'VariableNames', colNames);
assert(isequal(callSiteTable{'case', 'F'}, 2));

%% documentation example: numeric levels are sorted, labels padded with []

[tbl, chi2, p, labels] = cobraCrosstab([1 1 2 3 1], [1 2 5 3 1]);
assert(isequal(tbl, [2 1 0 0; 0 0 0 1; 0 0 1 0]));
assert(isequal(labels, {'1', '1'; '2', '2'; '3', '3'; [], '5'}));
% SciPy 1.16.0: chi2 10.000000000000002, p 0.12465201948308108, 6 degrees of freedom
assert(abs(chi2 - 10.000000000000002) <= 1e-12 * 10);
assert(abs(p - 0.12465201948308108) <= 1e-12 * 0.12465201948308108);
% a table output alone also works
assert(isequal(cobraCrosstab([1 1 2 3 1], [1 2 5 3 1]), tbl));

%% documentation example: chi-square test on the 3 x 3 unidrnd table

counts = [1 6 7; 5 5 2; 11 7 6];
[rowLevel, colLevel] = ndgrid(1:3, 1:3);
x1 = repelem(rowLevel(:), counts(:));
x2 = repelem(colLevel(:), counts(:));
[tbl, chi2, p] = cobraCrosstab(x1, x2);
assert(isequal(tbl, counts));
% documentation chi2 = 7.5449, p = 0.1097; SciPy 1.16.0 7.5449346405228761 and 0.10974411051760433
assert(abs(chi2 - 7.5449) <= 5e-5 && abs(p - 0.1097) <= 5e-5);
assert(abs(chi2 - 7.5449346405228761) <= 1e-12 * 7.5449346405228761);
assert(abs(p - 0.10974411051760433) <= 1e-12 * 0.10974411051760433);

%% documentation example: hospital Sex (categorical) x Smoker (logical), no Yates correction

counts = [40 13; 26 21];
[rowLevel, colLevel] = ndgrid(1:2, 1:2);
sexNames = {'Female'; 'Male'};
sex = categorical(sexNames(repelem(rowLevel(:), counts(:))));
smoker = repelem(colLevel(:), counts(:)) == 2;
[conttbl, chi2, p, labels] = cobraCrosstab(sex, smoker);
assert(isequal(conttbl, counts));
assert(isequal(labels, {'Female', '0'; 'Male', '1'}));
% documentation chi2 = 4.5083, p = 0.0337 (a Yates-corrected chi2 would be 3.6549, SciPy correction=True)
assert(abs(chi2 - 4.5083) <= 5e-5 && abs(p - 0.0337) <= 5e-5);
% SciPy 1.16.0: 4.5082797178577279 and 0.033731149777532568, 1 degree of freedom
assert(abs(chi2 - 4.5082797178577279) <= 1e-12 * 4.5082797178577279);
assert(abs(p - 0.033731149777532568) <= 1e-12 * 0.033731149777532568);

%% observations with NaN in any numeric variable are left out

[tbl, ~, ~, labels] = cobraCrosstab([1 2 NaN 2 1], [1 1 2 NaN 2]);
assert(isequal(tbl, [1 1; 1 0]) && isequal(labels, {'1', '1'; '2', '2'}));

%% a level with no observation gives a zero row: chi2 and p are NaN (0/0)

% level 3 of the first variable occurs only in an observation that is left out (NaN)
[tbl, chi2, p, labels] = cobraCrosstab([1 2 3 1 2], [1 2 NaN 2 1]);
assert(isequal(tbl, [1 1; 1 1; 0 0]) && isnan(chi2) && isnan(p));
assert(isequal(labels(:, 1), {'1'; '2'; '3'}));
% an unused category of a categorical variable
[tbl, chi2, p, labels] = cobraCrosstab(categorical({'a', 'b', 'a', 'b'}, {'a', 'b', 'z'}), [1 2 2 1]);
assert(isequal(tbl, [1 1; 1 1; 0 0]) && isnan(chi2) && isnan(p));
assert(isequal(labels(:, 1), {'a'; 'b'; 'z'}));

%% three variables: a three-way table and its chi-square test

x1 = [1 1 2 2 1 2 1 2 1 1 2 2];
x2 = [1 2 1 2 2 2 1 1 1 2 2 1];
x3 = [1 1 1 2 2 2 2 1 1 2 2 1];
[tbl, chi2, p, labels] = cobraCrosstab(x1, x2, x3);
% tables.py (column-major): [2 3 1 0 1 0 2 3]
assert(isequal(size(tbl), [2 2 2]) && isequal(tbl(:)', [2 3 1 0 1 0 2 3]));
assert(isequal(size(labels), [2 3]));
% SciPy 1.16.0: chi2 6.666666666666667, p 0.15458730450476041, 4 degrees of freedom
assert(abs(chi2 - 6.666666666666667) <= 1e-12 * 6.666666666666667);
assert(abs(p - 0.15458730450476041) <= 1e-12 * 0.15458730450476041);

%% fewer than two variables with more than one level: chi2 and p are NaN

[tbl, chi2, p, labels] = cobraCrosstab([1 1 1], [1 2 1]);
assert(isequal(tbl, [2 1]) && isnan(chi2) && isnan(p));
assert(isequal(labels, {'1', '1'; [], '2'}));
% one variable gives a column of counts
[tbl, chi2, p] = cobraCrosstab({'a', 'b', 'a'});
assert(isequal(tbl, [2; 1]) && isnan(chi2) && isnan(p));

%% unsupported input raises an error naming it

assert(verifyCobraFunctionError('cobraCrosstab', ...
    'testMessage', 'cobraCrosstab: at least one grouping variable is required.'));
assert(verifyCobraFunctionError('cobraCrosstab', 'inputs', {table([1; 2], [1; 2])}, ...
    'testMessage', 'cobraCrosstab: table input is not supported.'));
assert(verifyCobraFunctionError('cobraCrosstab', 'inputs', {[1 2], [1 2], 'IncludeMissingGroups', true}, ...
    'testMessage', 'cobraCrosstab: the option ''IncludeMissingGroups'' is not supported.'));
assert(verifyCobraFunctionError('cobraCrosstab', 'inputs', {[1 2], [1 2], "IncludeMissingGroups", true}, ...
    'testMessage', 'cobraCrosstab: the option ''IncludeMissingGroups'' is not supported.'));
assert(verifyCobraFunctionError('cobraCrosstab', 'inputs', {[1 2 3], [1 2]}, ...
    'testMessage', 'cobraCrosstab: all grouping variables must have the same length.'));
% a char row that is not an option name is an ordinary (one-row) grouping variable
[tbl, ~, ~, labels] = cobraCrosstab('abc');
assert(isequal(tbl, 1) && isequal(labels, {'abc'}));

%% parity with crosstab when the Statistics and Machine Learning Toolbox is installed

if exist('crosstab', 'file') && license('test', 'Statistics_Toolbox')
    response = {'case'; 'control'; 'case'; ''; 'control'; 'case'; 'control'; 'case'};
    sex = {'M'; 'F'; 'F'; 'M'; 'M'; 'M'; 'F'; 'F'};
    [tbl, chi2, p, labels] = cobraCrosstab(response, sex);
    [expectedTbl, expectedChi2, expectedP, expectedLabels] = crosstab(response, sex);
    assert(isequal(tbl, expectedTbl) && isequal(labels, expectedLabels));
    assert(abs(chi2 - expectedChi2) <= 1e-12 * expectedChi2 && abs(p - expectedP) <= 1e-12);
    [tbl, chi2, p] = cobraCrosstab([1 1 2 3 1 2], [1 2 5 3 1 1]);
    [expectedTbl, expectedChi2, expectedP] = crosstab([1 1 2 3 1 2], [1 2 5 3 1 1]);
    assert(isequal(tbl, expectedTbl));
    assert(abs(chi2 - expectedChi2) <= 1e-12 * expectedChi2 && abs(p - expectedP) <= 1e-12);
else
    fprintf('skipped: Statistics and Machine Learning Toolbox not installed\n');
end

% change the directory
cd(currentDir)
