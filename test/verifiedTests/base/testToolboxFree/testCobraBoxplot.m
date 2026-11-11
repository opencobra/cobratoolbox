% The COBRAToolbox: testCobraBoxplot.m
%
% Purpose:
%     - cobraBoxplot is the plain-MATLAB replacement for boxplot(x) and boxplot(x, group)
%       (Statistics and Machine Learning Toolbox), as used by makeViolinPlots. This test draws
%       headless and checks the figure content that carries meaning: the number and order of
%       boxes, quartiles (hand-computed: base prctile places the sorted values at percentiles
%       100*(i - 0.5)/n), medians, whisker ends, outliers, tick labels in first-appearance
%       order, the tags used by makeViolinPlots (findobj 'Box' returns the last group first),
%       the patch colouring of the call site, matrix input, NaN, an all-NaN group, and the
%       errors for unsupported input; and (only where the toolbox is installed) parity with
%       boxplot for the box and median coordinates.
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraBoxplot.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs; figures are invisible and closed.
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
fileDir = fileparts(which('testCobraBoxplot'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

figureHandle = figure('Visible', 'off');

%% one vector: quartiles, median, whiskers and an outlier

% x = [1:9 30]: percentiles at 100*(i - 0.5)/10, so q1 = 3, median 5.5, q3 = 8; IQR 5, upper
% fence 15.5: 30 is an outlier and the upper adjacent value is 9; lower adjacent value 1
h = cobraBoxplot([1:9 30]');
assert(isequal(size(h), [7 1]) && strcmp(get(h(5), 'Tag'), 'Box'));
assert(isequal(get(h(5), 'YData'), [3 8 8 3 3]) && isequal(get(h(5), 'XData'), 1 + [-1 -1 1 1 -1] * 0.25));
assert(isequal(get(h(6), 'YData'), [5.5 5.5]) && strcmp(get(h(6), 'Tag'), 'Median'));
assert(isequal(get(h(1), 'YData'), [8 9]) && isequal(get(h(2), 'YData'), [1 3]));
assert(isequal(get(h(3), 'YData'), [9 9]) && isequal(get(h(4), 'YData'), [1 1]));
assert(isequal(get(h(7), 'YData'), 30) && strcmp(get(h(7), 'Tag'), 'Outliers'));
assert(isequal(get(gca, 'XTick'), 1) && isequal(get(gca, 'XTickLabel'), {'1'}));
clf(figureHandle);

%% grouped data (makeViolinPlots): first-appearance order, findobj order, patch colouring

values = [5 6 7 8 1 2 3 4 10 11 12 13 NaN];
groups = {'healthy', 'healthy', 'healthy', 'healthy', 'disease', 'disease', 'disease', 'disease', ...
    'control', 'control', 'control', 'control', 'control'};
hold on
h = cobraBoxplot(values, groups);
assert(isequal(size(h), [7 3]) && isequal(get(gca, 'XTickLabel'), {'healthy'; 'disease'; 'control'}));
% medians of the groups in that order (NaN ignored)
medians = arrayfun(@(k) mean(get(h(6, k), 'YData')), 1:3);
assert(isequal(medians, [6.5 2.5 11.5]));
boxes = findobj(gca, 'Tag', 'Box');
% newest first: the box of the last group ('control', at x = 3) comes first
assert(numel(boxes) == 3 && mean(get(boxes(1), 'XData')) > 2.5 && mean(get(boxes(3), 'XData')) < 1.5);
% the patch colouring of makeViolinPlots works on these boxes
cols = [1 0 0; 0 1 0; 0 0 1];
for j = 1:length(boxes)
    patch(get(boxes(j), 'XData'), get(boxes(j), 'YData'), cols(j, :), 'FaceAlpha', .5);
end
assert(numel(findobj(gca, 'Type', 'patch')) == 3 && ishold);
clf(figureHandle);

%% matrix input (one box per column) and an all-NaN column

h = cobraBoxplot([1 10; 2 20; 3 30; 4 NaN]);
assert(isequal(size(h), [7 2]) && isequal(get(gca, 'XTickLabel'), {'1'; '2'}) && isequal(get(h(6, 2), 'YData'), [20 20]));
h = cobraBoxplot([NaN; NaN]);
assert(all(isnan(get(h(5), 'YData'))));
clf(figureHandle);

%% errors: options, input types, group size

assert(verifyCobraFunctionError('cobraBoxplot', 'inputs', {[1 2 3], [1 1 2], 'Notch', 'on'}, ...
    'testMessage', 'cobraBoxplot: unsupported option ''Notch'' (only cobraBoxplot(x) and cobraBoxplot(x, group)).'));
assert(verifyCobraFunctionError('cobraBoxplot', 'inputs', {[1 2 3], [1 1 2], 5}, ...
    'testMessage', 'cobraBoxplot: unsupported option ''double'' (only cobraBoxplot(x) and cobraBoxplot(x, group)).'));
assert(verifyCobraFunctionError('cobraBoxplot', 'inputs', {{1, 2}}, ...
    'testMessage', 'cobraBoxplot: x must be a numeric vector or matrix.'));
assert(verifyCobraFunctionError('cobraBoxplot', 'inputs', {[1 2 3], [1 2]}, ...
    'testMessage', 'cobraBoxplot: group must have one entry per element of the vector x.'));

%% parity with boxplot (only where the Statistics and Machine Learning Toolbox is installed)

if exist('boxplot', 'file') == 2 && license('test', 'Statistics_Toolbox')
    rng(20261111);
    data = randn(25, 1);
    groupsRandom = repmat({'a'; 'b'; 'c'; 'd'; 'e'}, 5, 1);
    hToolbox = boxplot(data, groupsRandom);
    clf(figureHandle);
    hReplacement = cobraBoxplot(data, groupsRandom);
    for k = 1:5
        assert(max(abs(get(hReplacement(5, k), 'YData') - get(hToolbox(5, k), 'YData'))) < 1e-12);
        assert(max(abs(get(hReplacement(6, k), 'YData') - get(hToolbox(6, k), 'YData'))) < 1e-12);
    end
    fprintf('parity with boxplot: passed\n');
else
    fprintf('skipped: Statistics and Machine Learning Toolbox not installed\n');
end
close(figureHandle);

% change the directory
cd(currentDir)
