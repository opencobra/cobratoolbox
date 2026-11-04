% The COBRAToolbox: testCobraTabulate.m
%
% Purpose:
%     - cobraTabulate is the plain-MATLAB replacement for tabulate (Statistics and Machine
%       Learning Toolbox). This test checks every syntax used by the call sites in src/
%       (tbl = tabulate(x) on positive integers, cellstr and string arrays, and tabulate(x)
%       with no output, which prints), the rules of mathworks-semantics.md section 6
%       (zero-count rows 1..max(x) for positive integers, ascending unique values otherwise,
%       NaN and missing values left out, cell output for non-numeric input including logical,
%       first-appearance order for text, categories order for categorical), the printed
%       layout, the error for matrix input, and parity with tabulate when the toolbox is
%       installed.
%     - Reference values: hand computation of the documented rules in
%       specs/20261103-120403-toolbox-free-replacements/references/tables.py (Python 3,
%       SciPy 1.16.0 environment; no SciPy equivalent exists); the printed layout of the
%       documentation example https://www.mathworks.com/help/stats/tabulate.html
%       ("    Male       47     47.00%"). Counts and orderings are compared exactly;
%       percentages, computed by the same 100*count/total, to 1e-12.
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraTabulate.m
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
fileDir = fileparts(which('testCobraTabulate'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% positive integers: rows 1..max(x) with zero counts, NaN left out

tbl = cobraTabulate([3 1 3 5 NaN 3]);
% tables.py: values 1..5, counts [1 0 3 0 1], percent [20 0 60 0 20] (of the 5 non-NaN values)
assert(isa(tbl, 'double') && isequal(size(tbl), [5 3]));
assert(isequal(tbl(:, 1)', 1:5) && isequal(tbl(:, 2)', [1 0 3 0 1]));
assert(max(abs(tbl(:, 3)' - [20 0 60 0 20])) <= 1e-12);
% a column input gives the same table; an integer class gives a double table
assert(isequal(cobraTabulate([3; 1; 3; 5; NaN; 3]), tbl));
assert(isequal(cobraTabulate(int8([3 1 3 5 3])), tbl));

%% call site efmBackboneExtraction: reaction indices sorted by occurrence

EFMRxns = [1 4 0; 4 2 0; 4 1 2];
allRxns = reshape(EFMRxns, [], 1);
rxnDistribution = sortrows(array2table(cobraTabulate(allRxns(allRxns ~= 0))), 2, 'descend');
rxnDistribution(rxnDistribution.Var2 == 0, :) = [];
% reaction 4 occurs 3 times, reactions 1 and 2 twice; reaction 3 (count 0) is removed
assert(isequal(rxnDistribution.Var1', [4 1 2]) && isequal(rxnDistribution.Var2', [3 2 2]));

%% other numeric values: only the values that occur, in ascending order

tbl = cobraTabulate([2.5 -1 2.5 0 NaN]);
% tables.py: values [-1 0 2.5], counts [1 1 2], percent [25 25 50]
assert(isequal(tbl(:, 1)', [-1 0 2.5]) && isequal(tbl(:, 2)', [1 1 2]));
assert(max(abs(tbl(:, 3)' - [25 25 50])) <= 1e-12);
% a single 0 switches off the 1..max(x) rows: tables.py values [0 2 3], counts [1 2 1]
tbl = cobraTabulate([0 2 2 3]);
assert(isequal(tbl(:, 1:2), [0 1; 2 2; 3 1]));
assert(max(abs(tbl(:, 3)' - [25 50 25])) <= 1e-12);

%% cell array of character vectors: cell output in order of first appearance

tbl = cobraTabulate({'C', 'H', 'C', 'O', 'H', 'C'});
% tables.py: C 3 50, H 2 33.333333333333336, O 1 16.666666666666668
assert(iscell(tbl) && isequal(size(tbl), [3 3]));
assert(isequal(tbl(:, 1), {'C'; 'H'; 'O'}) && isequal(cell2mat(tbl(:, 2))', [3 2 1]));
assert(max(abs(cell2mat(tbl(:, 3))' - [50 33.333333333333336 16.666666666666668])) <= 1e-12);
% call site GPR2models: genes with one transcript and with more than one
genesOneTranscript = tbl(cell2mat(tbl(:, 2)) == 1, 1);
assert(isequal(genesOneTranscript, {'O'}));
% call site identifyConservedMoieties: the moiety formula from the element table
formula = '';
for j = 1:size(tbl, 1)
    formula = [formula tbl{j, 1} num2str(tbl{j, 2})];
end
assert(strcmp(formula, 'C3H2O1'));
% an empty character vector is a missing value and is left out
tbl = cobraTabulate({'C', '', 'C', 'H'});
assert(isequal(tbl(:, 1), {'C'; 'H'}) && isequal(cell2mat(tbl(:, 2))', [2 1]));

%% string array (call site efmSubsystemsExtraction): cell output, missing values left out

tbl = cobraTabulate(["Glycolysis", "TCA", "Glycolysis", missing, "", "TCA", "TCA"]);
assert(iscell(tbl) && isequal(tbl(:, 1), {'Glycolysis'; 'TCA'}));
assert(isequal(cell2mat(tbl(:, 2))', [2 3]));
assert(max(abs(cell2mat(tbl(:, 3))' - [40 60])) <= 1e-12);

%% categorical, logical and char input

% categorical: the order of categories(x); a category that does not occur has count 0
tbl = cobraTabulate(categorical({'a', 'b', 'a'}, {'c', 'a', 'b'}));
assert(isequal(tbl(:, 1), {'c'; 'a'; 'b'}) && isequal(cell2mat(tbl(:, 2))', [0 2 1]));
% logical: cell output, sorted (false first), values as '0' and '1'
tbl = cobraTabulate([true false true true]);
assert(iscell(tbl) && isequal(tbl(:, 1), {'0'; '1'}) && isequal(cell2mat(tbl(:, 2))', [1 3]));
% char matrix: one value per row, first appearance
tbl = cobraTabulate(['ab'; 'cd'; 'ab']);
assert(isequal(tbl(:, 1), {'ab'; 'cd'}) && isequal(cell2mat(tbl(:, 2))', [2 1]));

%% empty input and all-NaN input give an empty table

assert(isequal(cobraTabulate([]), zeros(0, 3)));
assert(isequal(cobraTabulate([NaN NaN]), zeros(0, 3)));
tbl = cobraTabulate(cell(0, 1));
assert(iscell(tbl) && isequal(size(tbl), [0 3]));

%% no output argument: the table is printed in the MathWorks layout

% numeric rows: '  %5d    %5d    %6.2f%%' under the header '  Value    Count   Percent'
printedNumeric = evalc('cobraTabulate([3 1 3 5 NaN 3])');
expectedNumeric = sprintf(['  Value    Count   Percent\n' ...
    '      1        1     20.00%%\n' ...
    '      2        0      0.00%%\n' ...
    '      3        3     60.00%%\n' ...
    '      4        0      0.00%%\n' ...
    '      5        1     20.00%%\n']);
assert(strcmp(printedNumeric, expectedNumeric));
% text rows: the value column is as wide as the longest name (here 6); this reproduces the
% documentation example tabulate(Gender) with 47 Male and 53 Female patients
gender = [repmat({'Male'}, 47, 1); repmat({'Female'}, 53, 1)];
printedText = evalc('cobraTabulate(gender)');
expectedText = sprintf(['   Value    Count   Percent\n' ...
    '    Male       47     47.00%%\n' ...
    '  Female       53     53.00%%\n']);
assert(strcmp(printedText, expectedText));
% short names use a width of at least 5; names longer than 50 use a width of 50
printedShort = evalc('cobraTabulate({''C''})');
assert(strcmp(printedShort, sprintf('  Value    Count   Percent\n      C        1    100.00%%\n')));
longName = repmat('x', 1, 60);
printedLong = evalc('cobraTabulate({longName})');
assert(startsWith(printedLong, sprintf('  %50s    Count   Percent\n', 'Value')));
assert(contains(printedLong, sprintf('  %s        1    100.00%%\n', longName)));
% an empty input prints the header only
printedEmpty = evalc('cobraTabulate([])');
assert(strcmp(printedEmpty, sprintf('  Value    Count   Percent\n')));
% other numeric values print as their group names (num2str of the value column, as in
% cobraGrp2idx) in a column as wide as the longest name, at least 5
printedOther = evalc('cobraTabulate([2.5 -1 2.5 0 NaN])');
assert(strcmp(printedOther, sprintf(['  Value    Count   Percent\n' ...
    '     -1        1     25.00%%\n' ...
    '      0        1     25.00%%\n' ...
    '    2.5        2     50.00%%\n'])));
% num2str of [-2; 0.123456] gives 5 significant digits, '0.12346' (7 characters)
printedWide = evalc('cobraTabulate([0.123456 0.123456 -2])');
assert(strcmp(printedWide, sprintf(['    Value    Count   Percent\n' ...
    '       -2        1     33.33%%\n' ...
    '  0.12346        2     66.67%%\n'])));

%% sparse input is tabulated like full input; a numeric matrix and Inf are rejected

assert(isequal(cobraTabulate(sparse([3 1 3 5 3])), cobraTabulate([3 1 3 5 3])));
assert(isequal(cobraTabulate(sparse([0 2 2 3])), cobraTabulate([0 2 2 3])));
assert(verifyCobraFunctionError('cobraTabulate', 'inputs', {[1 2; 3 4]}, ...
    'testMessage', 'cobraTabulate: the input must be a vector.'));
assert(verifyCobraFunctionError('cobraTabulate', 'inputs', {[1 2 Inf]}, ...
    'testMessage', 'cobraTabulate: Inf and -Inf values are not supported.'));
assert(verifyCobraFunctionError('cobraTabulate', 'inputs', {[0.5 -Inf]}, ...
    'testMessage', 'cobraTabulate: Inf and -Inf values are not supported.'));

%% parity with tabulate when the Statistics and Machine Learning Toolbox is installed

if exist('tabulate', 'file') && license('test', 'Statistics_Toolbox')
    % numeric tables are equal; cell tables have the same values and counts
    x = [3 1 3 5 NaN 3];
    assert(max(abs(cobraTabulate(x) - tabulate(x)), [], 'all') <= 1e-12);
    x = [2.5 -1 2.5 0];
    assert(max(abs(cobraTabulate(x) - tabulate(x)), [], 'all') <= 1e-12);
    x = {'C', 'H', 'C', 'O', 'H', 'C'};
    expectedTbl = tabulate(x);
    tbl = cobraTabulate(x);
    assert(isequal(tbl(:, 1:2), expectedTbl(:, 1:2)));
    assert(strcmp(evalc('cobraTabulate(x)'), evalc('tabulate(x)')));
else
    fprintf('skipped: Statistics and Machine Learning Toolbox not installed\n');
end

% change the directory
cd(currentDir)
