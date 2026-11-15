% The COBRAToolbox: testDirectionalityStatsFigures.m
%
% Purpose:
%     - directionalityStatsFigures(directions, resultsBaseFileName, saveFigures) draws pie
%       charts of the counts (nnz) of the boolean vectors of a directions structure:
%       qualitative directions, quantitative directions, changed directions, all
%       qualitative -> quantitative transitions, forward -> reversible by standard Gibbs
%       energy (only when one of those four vectors is non-empty) and forward -> reversible by
%       concentration; the last two are saved as .fig files when saveFigures is true. This
%       test builds a directions structure by hand for 10 reactions and checks the number of
%       figures, their titles (the percentages are computed by hand from the counts), the pie
%       labels and font size, and which .fig files are written.
%
% Function under test:
%     src/analysis/thermo/directionalityReport/directionalityStatsFigures.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built boolean vectors; figures are invisible and
%     closed, the .fig files are written in a tempname folder that is removed.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDirectionalityStatsFigures'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% figures are created invisible; the default is restored at the end
defaultVisibility = get(0, 'DefaultFigureVisible');
set(0, 'DefaultFigureVisible', 'off');
tmpDir = tempname;
mkdir(tmpDir);
resultsBaseFileName = fullfile(tmpDir, 'results');

% a directions structure for 10 reactions; each vector has the count given in the comment
nRxn = 10;
makeBool = @(k) [true(k, 1); false(nRxn - k, 1)];
directions = struct();
directions.forwardRecon = makeBool(5);
directions.reverseRecon = makeBool(1);
directions.reversibleRecon = makeBool(4);
directions.equilibriumRecon = makeBool(0);
directions.forwardThermo = makeBool(3);
directions.reverseThermo = makeBool(1);
directions.reversibleThermo = makeBool(4);
directions.uncertainThermo = makeBool(2);
directions.equilibriumThermo = makeBool(0);
directions.forward2Forward = makeBool(2);
directions.forward2Reverse = makeBool(1);
directions.forward2Reversible = makeBool(2);
directions.forward2Uncertain = makeBool(0);
directions.reversible2Forward = makeBool(1);
directions.reversible2Reverse = makeBool(0);
directions.reversible2Reversible = makeBool(3);
directions.reversible2Uncertain = makeBool(0);
directions.reverse2Forward = makeBool(0);
directions.reverse2Reverse = makeBool(1);
directions.reverse2Reversible = makeBool(0);
directions.reverse2Uncertain = makeBool(0);
directions.forward2Reversible_bydGt0 = makeBool(1);
directions.forward2Reversible_bydGt0LHS = makeBool(0);
directions.forward2Reversible_bydGt0Mid = makeBool(1);
directions.forward2Reversible_bydGt0RHS = makeBool(0);
directions.forward2Reversible_byConc_zero_fixed_DrG0 = makeBool(1);
directions.forward2Reversible_byConc_negative_fixed_DrG0 = makeBool(0);
directions.forward2Reversible_byConc_positive_fixed_DrG0 = makeBool(0);
directions.forward2Reversible_byConc_negative_uncertain_DrG0 = makeBool(0);
directions.forward2Reversible_byConc_positive_uncertain_DrG0 = makeBool(1);

% the expected title and pie labels of each figure, in creation order
expectedTitles = {
    {'Qualitatively assigned directionality'}
    {'Quantitatively assigned directionality'}
    % changed directions: 1 + 0 + 1 + 2 = 4 of 10 reactions
    {'Qualtiative -> quantiative changed reaction directions'; '(40 % of all reactions)'}
    {'Qualtiative -> quantiative reaction directions'}
    % by standard Gibbs energy: 1 + 0 + 1 + 0 = 2 of 10 reactions
    {'Forward -> Reversible (by \Delta_{f}G^{\primem}_0)'; '(20 % of all reactions)'}
    % by concentration: 1 + 0 + 0 + 1 + 0 = 2 of 10 reactions
    {'Forward -> Reversible (by reactant concentration)'; '(20 % of all reactions)'}};
expectedLabels = {
    {'Forward', 'Reverse', 'Reversible', 'Equilibrium'}
    {'Forward', 'Reverse', 'Reversible', 'Equilibrium', 'Uncertain'}
    {'Reversible -> Forward', 'Reversible -> Reverse', 'Forward -> Reverse', 'Forward -> Reversible'}
    {'reversible -> forward', 'reversible -> Reverse', 'reversible -> Reversible', ...
     'reversible -> Uncertain', 'forward -> Reverse', 'forward -> Reversible', ...
     'forward -> Forward', 'forward -> Uncertain', 'reverse -> Reverse', ...
     'reverse -> Forward', 'reverse -> Reversible', 'reverse -> Uncertain'}
    {'\Delta_{r}G^{\primem}_0 = 0', '0 << \Delta_{r}G^{\primem}_0 > 0', ...
     '0 << \Delta_{r}G^{\primem}_0 >> 0', '0 < \Delta_{r}G^{\primem}_0 >> 0'}
    {'\Delta_{r}G^{\primem}_0 = 0 (exact)', '\Delta_{r}G^{\primem}_0 < 0 (exact)', ...
     '0 << \Delta_{r}G^{\primem}_0 > 0 (variable)', '0 << \Delta_{r}G^{\primem}_0 >> 0 (variable)', ...
     '0 < \Delta_{r}G^{\primem}_0 >> 0 (exact)'}};

%% all six figures with saveFigures = 1: titles, labels, font size and both .fig files

figuresBefore = findall(0, 'Type', 'figure');
directionalityStatsFigures(directions, resultsBaseFileName, 1);
newFigures = setdiff(findall(0, 'Type', 'figure'), figuresBefore);
[~, order] = sort([newFigures.Number]);
newFigures = newFigures(order);
assert(numel(newFigures) == 6);
for k = 1:6
    axesHandle = findobj(newFigures(k), 'Type', 'axes');
    titleText = cellstr(get(axesHandle.Title, 'String'));
    assert(isequal(titleText(:), expectedTitles{k}(:)));
    textObjs = findobj(axesHandle, 'Type', 'text');
    % the labels are those given to pie (zero counts are drawn as eps slices, so every
    % category keeps its label), and every label has font size 16
    assert(isempty(setxor(get(textObjs, 'String'), expectedLabels{k})));
    assert(numel(textObjs) == numel(expectedLabels{k}));
    assert(all(cell2mat(get(textObjs, 'FontSize')) == 16));
end
close(newFigures);
assert(exist([resultsBaseFileName '_fwdReversible_byDrG0_pieChart.fig'], 'file') == 2);
assert(exist([resultsBaseFileName '_fwdReversible_byconc_pieChart.fig'], 'file') == 2);
delete([resultsBaseFileName '_fwdReversible_byDrG0_pieChart.fig']);
delete([resultsBaseFileName '_fwdReversible_byconc_pieChart.fig']);

%% no forward -> reversible by standard Gibbs energy: that figure is skipped

directions.forward2Reversible_bydGt0(:) = false;
directions.forward2Reversible_bydGt0Mid(:) = false;
figuresBefore = findall(0, 'Type', 'figure');
directionalityStatsFigures(directions, resultsBaseFileName, true);
newFigures = setdiff(findall(0, 'Type', 'figure'), figuresBefore);
[~, order] = sort([newFigures.Number]);
newFigures = newFigures(order);
assert(numel(newFigures) == 5);
axesHandle = findobj(newFigures(5), 'Type', 'axes');
titleText = cellstr(get(axesHandle.Title, 'String'));
assert(isequal(titleText(:), expectedTitles{6}(:)));
close(newFigures);
% only the concentration chart is saved
assert(exist([resultsBaseFileName '_fwdReversible_byDrG0_pieChart.fig'], 'file') == 0);
assert(exist([resultsBaseFileName '_fwdReversible_byconc_pieChart.fig'], 'file') == 2);
delete([resultsBaseFileName '_fwdReversible_byconc_pieChart.fig']);

%% saveFigures omitted (default 0): the figures are drawn and nothing is written

figuresBefore = findall(0, 'Type', 'figure');
directionalityStatsFigures(directions, resultsBaseFileName);
newFigures = setdiff(findall(0, 'Type', 'figure'), figuresBefore);
assert(numel(newFigures) == 5);
close(newFigures);
assert(isempty(dir(fullfile(tmpDir, '*.fig'))));

% remove the temporary folder, restore the figure default and the directory
rmdir(tmpDir, 's');
set(0, 'DefaultFigureVisible', defaultVisibility);
cd(currentDir)
