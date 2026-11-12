% The COBRAToolbox: testCobraAnova1.m
%
% Purpose:
%     - cobraAnova1 is the plain-MATLAB replacement for anova1 (Statistics and Machine
%       Learning Toolbox). This test checks the MathWorks documentation example (beam strength),
%       unbalanced data with NaN and a missing group label against SciPy, the table layout and
%       stats fields read by performStatisticalAnalysis, the zero-error special cases, group
%       types (cell, string, numeric, categorical with an unused category), the errors for
%       unsupported input, and (only where the toolbox is installed) parity with anova1.
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraAnova1.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCobraAnova1'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% relative error helper
relativeError = @(value, reference) abs(value - reference) ./ abs(reference);

%% MathWorks documentation example: beam strength by alloy (anova1(strength, alloy, 'off'))

strength = [82 86 79 83 84 85 86 87 74 82 78 75 76 77 79 79 77 78 82 79];
alloy = [repmat({'st'}, 1, 8), repmat({'al1'}, 1, 6), repmat({'al2'}, 1, 6)];
[p, tbl, stats] = cobraAnova1(strength, alloy, 'off');
% published table: Groups SS 184.8, df 2, MS 92.4, F 15.4, p 1.5264e-04; Error SS 102, df 17,
% MS 6; Total SS 286.8, df 19. SciPy 1.16.3 f_oneway (references/g1_stats.py, section anova1)
% gives F = 15.399999999999991, p = 0.0001526436388304928; sums of squares are sums of a few
% exact products, so 1e-12 relative; p goes through the incomplete beta function, so 1e-10
assert(isequal(tbl(1, :), {'Source', 'SS', 'df', 'MS', 'F', 'Prob>F'}));
assert(isequal(tbl(:, 1)', {'Source', 'Groups', 'Error', 'Total'}));
assert(relativeError(tbl{2, 2}, 184.8) < 1e-12 && tbl{2, 3} == 2 && relativeError(tbl{2, 4}, 92.4) < 1e-12);
assert(relativeError(tbl{2, 5}, 15.4) < 1e-12 && relativeError(tbl{2, 6}, 0.0001526436388304928) < 1e-10);
assert(relativeError(tbl{3, 2}, 102) < 1e-12 && tbl{3, 3} == 17 && relativeError(tbl{3, 4}, 6) < 1e-12);
assert(relativeError(tbl{4, 2}, 286.8) < 1e-12 && tbl{4, 3} == 19);
% empty cells exactly where MathWorks leaves them empty
assert(isempty(tbl{3, 5}) && isempty(tbl{3, 6}) && isempty(tbl{4, 4}) && isempty(tbl{4, 5}) && isempty(tbl{4, 6}));
assert(p == tbl{2, 6});
% stats: group names in first-appearance order, sizes and means as rows
assert(isequal(stats.gnames, {'st'; 'al1'; 'al2'}) && isequal(stats.n, [8 6 6]));
assert(strcmp(stats.source, 'anova1') && stats.df == 17);
assert(max(relativeError(stats.means, [84 77 79])) < 1e-14 && relativeError(stats.s, 2.4494897427831788) < 1e-12);

%% unbalanced data with NaN and a missing group label (dropped with their observation)

% SciPy 1.16.3 (references/g1_stats.py, section anova1): groups b, a, c;
% SSg, SSe, SSt = 19.27083333333333, 12.072916666666671, 31.34375; F, p = 3.9905090595340824, 0.09207741547431504
y = [1.5 2.25 NaN 3.0 4.75 0.5 2.0 6.0 5.5 1.0];
labels = {'b', 'a', 'a', 'c', 'b', 'a', '', 'c', 'c', 'a'};
[p, tbl, stats] = cobraAnova1(y, labels, 'off');
assert(isequal(stats.gnames, {'b'; 'a'; 'c'}) && isequal(stats.n, [2 3 3]));
assert(relativeError(tbl{2, 2}, 19.27083333333333) < 1e-12 && relativeError(tbl{3, 2}, 12.072916666666671) < 1e-12);
assert(relativeError(tbl{2, 5}, 3.9905090595340824) < 1e-12 && relativeError(p, 0.09207741547431504) < 1e-10);
% the same data as a string array and as a column give the same result
[pString, tblString] = cobraAnova1(y', string(labels)', 'off');
assert(pString == p && isequal(tblString, tbl));

%% numeric groups (sorted order) and categorical groups (unused categories dropped)

[~, ~, stats] = cobraAnova1([1 2 3 4 5 6], [3 3 1 1 2 2]);
assert(isequal(stats.gnames, {'1'; '2'; '3'}) && max(abs(stats.means - [3.5 5.5 1.5])) < 1e-14);
categoricalGroup = categorical({'x', 'x', 'z', 'z'}, {'x', 'y', 'z'});
[~, tbl, stats] = cobraAnova1([1 2 4 6], categoricalGroup, 'off');
% the unused category 'y' has no observations and is not a group
assert(isequal(stats.gnames, {'x'; 'z'}) && tbl{2, 3} == 1 && tbl{3, 3} == 2);

%% special cases: zero error sum of squares, and as many groups as observations

% equal values within groups but different means: F = Inf, p = 0
[p, tbl] = cobraAnova1([1 1 2 2], {'a', 'a', 'b', 'b'}, 'off');
assert(tbl{2, 5} == Inf && p == 0);
% all values equal: F = 0, p = 1
[p, tbl] = cobraAnova1([3 3 3 3], {'a', 'a', 'b', 'b'}, 'off');
assert(tbl{2, 5} == 0 && p == 1);
% one observation per group: no error degrees of freedom, so the error mean square, F and p are NaN
[p, tbl, stats] = cobraAnova1([1 2 3], {'a', 'b', 'c'}, 'off');
assert(isnan(tbl{3, 4}) && isnan(tbl{2, 5}) && isnan(p) && isnan(stats.s));
% displayopt 'on' (the default) is accepted and draws nothing
figuresBefore = numel(findall(groot, 'Type', 'figure'));
pOn = cobraAnova1(strength, alloy);
assert(abs(pOn - 0.0001526436388304928) < 1e-12 && numel(findall(groot, 'Type', 'figure')) == figuresBefore);

%% errors: missing group, matrix y, unsupported display option, size mismatch

assert(verifyCobraFunctionError('cobraAnova1', 'inputs', {magic(3)}, ...
    'testMessage', 'cobraAnova1: a grouping variable is required (matrix input without group is not supported).'));
assert(verifyCobraFunctionError('cobraAnova1', 'inputs', {magic(3), {'a', 'b', 'c'}, 'off'}, ...
    'testMessage', 'cobraAnova1: unsupported option ''matrix y'' (y must be a real numeric vector).'));
assert(verifyCobraFunctionError('cobraAnova1', 'inputs', {[1 2], {'a', 'b'}, 'nodisplay'}, ...
    'testMessage', 'cobraAnova1: unsupported option ''nodisplay'' (displayopt must be ''on'' or ''off'').'));
assert(verifyCobraFunctionError('cobraAnova1', 'inputs', {[1 2], {'a', 'b'}, 1}, ...
    'testMessage', 'cobraAnova1: unsupported option ''double'' (displayopt must be ''on'' or ''off'').'));
assert(verifyCobraFunctionError('cobraAnova1', 'inputs', {[1 2 3], {'a', 'b'}}, ...
    'testMessage', 'cobraAnova1: group must have one entry per observation of y.'));

%% parity with anova1 (only where the Statistics and Machine Learning Toolbox is installed)

if exist('anova1', 'file') == 2 && license('test', 'Statistics_Toolbox')
    rng(20261111);
    yRandom = randn(1, 30) + repelem([0 0.5 1], 10);
    groupRandom = repelem({'g1', 'g2', 'g3'}, 10);
    [p, tbl, stats] = cobraAnova1(yRandom, groupRandom, 'off');
    [pToolbox, tblToolbox, statsToolbox] = anova1(yRandom, groupRandom, 'off');
    % same formulas; 1e-12 relative for rounding in the sums of squares and the F cdf
    assert(abs(p - pToolbox) <= 1e-12 * pToolbox);
    for row = 2:4
        for column = 2:6
            if isempty(tblToolbox{row, column})
                assert(isempty(tbl{row, column}));
            else
                assert(abs(tbl{row, column} - tblToolbox{row, column}) <= 1e-12 * abs(tblToolbox{row, column}));
            end
        end
    end
    assert(isequal(tbl(:, 1), tblToolbox(:, 1)) && isequal(stats.gnames, statsToolbox.gnames));
    fprintf('parity with anova1: passed\n');
else
    fprintf('skipped: Statistics and Machine Learning Toolbox not installed\n');
end

% change the directory
cd(currentDir)
