% The COBRAToolbox: testPlotConcVSdGft0GroupContUncertainty.m
%
% Purpose:
%     - plotConcVSdGft0GroupContUncertainty compares, for each metabolite, half the
%       concentration contribution to the Gibbs energy of formation range,
%       D = RT ln(concMax/concMin) / 2, with the group contribution uncertainty DGC; a
%       metabolite without uncertainty (NaN) gets NaN in both outputs. It prints the fraction
%       of metabolites where the uncertainty exceeds D/2 and draws a histogram of DGC with a
%       vertical line at RT ln(20/0.2) / 2. This test checks D and DGC against the formula
%       evaluated here, the NaN rule, the Keq source (which changes only an unused internal
%       fraction), and the histogram, line and axis limits of the figure.
%
% Function under test:
%     src/analysis/thermo/groupContribution/jankowski/plotConcVSdGft0GroupContUncertainty.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - hand-built thermodynamic model fields, an invisible figure, no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: An intermediate fraction is echoed to the command window
%       SEVERITY: cosmetic
%       TRIGGER: any call, e.g. the model of the first section below
%       OBSERVED: "fraction2q = 0.5000" printed before the documented message (MATLAB R2025a):
%       line 54 has no semicolon
%       EXPECTED: only the line "Fraction of metabolites where GC uncertainty is more
%       significant: ..."
%       LINES: 54
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPlotConcVSdGft0GroupContUncertainty'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% figures are drawn invisibly and closed at the end
defaultFigureVisible = get(0, 'DefaultFigureVisible');
set(0, 'DefaultFigureVisible', 'off');
figuresBefore = findall(0, 'Type', 'figure');

% hand-built model: four metabolites; a and d from group contribution, b from Keq, c without
% an uncertainty. The uncertainties are chosen around D and D/2 (D = 9.42 kJ/mol for a and
% d, 8.56 kJ/mol for b): a above D, d between D/2 and D, b below D/2
modelT = struct();
modelT.mets = {'a[c]'; 'b[c]'; 'c[c]'; 'd[c]'};
modelT.T = 298.15;
modelT.gasConstant = 8.314472 / 1000;
modelT.concMin = [1e-5; 1e-6; 1e-5; 1e-5];
modelT.concMax = [0.02; 1e-3; 0.02; 0.02];
modelT.dfGt0GroupContUncertainty = [20; 1; NaN; 6];
modelT.dfGt0Source = {'GC'; 'Keq'; 'GC'; 'GC'};

%% D is RT ln(concMax/concMin) / 2 and DGC the uncertainty; NaN uncertainty gives NaN

[D, DGC] = plotConcVSdGft0GroupContUncertainty(modelT);
RT = modelT.T * modelT.gasConstant;
expectedD = (RT * log(modelT.concMax ./ modelT.concMin)) / 2;
expectedD(3) = NaN;
% one value per metabolite
assert(isequal(size(D), [4, 1]) && isequal(size(DGC), [4, 1]));
% D: the same formula evaluated element-wise here; 1e-12 kJ/mol allows the last bits of the
% logarithm, far below the 0.01 kJ/mol resolution of thermodynamic data
assert(isequal(isnan(D), [false; false; true; false]));
assert(max(abs(D(~isnan(D)) - expectedD(~isnan(expectedD)))) < 1e-12);
% hand values: RT ln(2000) / 2 = 9.4212 and RT ln(1000) / 2 = 8.5620 kJ/mol (4 decimals)
assert(abs(D(1) - 9.4212) < 1e-4 && abs(D(2) - 8.5620) < 1e-4);
% DGC copies the uncertainty, NaN included (the Keq source of b does not change DGC)
assert(isequaln(DGC, [20; 1; NaN; 6]));

%% the figure: histogram of DGC, a line at RT ln(20/0.2) / 2, x limits [0, 100]

newFigures = setdiff(findall(0, 'Type', 'figure'), figuresBefore);
% exactly one figure is drawn
assert(numel(newFigures) == 1);
figureAxes = findobj(newFigures, 'Type', 'axes');
% the histogram is drawn as red patches with white edges
histogramPatch = findobj(figureAxes, 'Type', 'patch');
assert(~isempty(histogramPatch));
assert(isequal(get(histogramPatch(1), 'FaceColor'), [1 0 0]) && isequal(get(histogramPatch(1), 'EdgeColor'), [1 1 1]));
% the reference line: same expression as the function, compared within 1e-12 kJ/mol
referenceLine = findobj(figureAxes, 'Type', 'line');
assert(numel(referenceLine) == 1);
dReference = (RT * log(20 / 0.2)) / 2;
assert(max(abs(get(referenceLine, 'XData') - [dReference, dReference])) < 1e-12);
assert(isequal(get(referenceLine, 'YData'), [0 300]));
% axis limits and ticks are set exactly
assert(isequal(get(figureAxes, 'XLim'), [0 100]) && isequal(get(figureAxes, 'XTick'), 0:10:100));
assert(strcmp(get(get(figureAxes, 'YLabel'), 'String'), '# Reactants'));
close(newFigures);

%% a model where every uncertainty is NaN gives NaN outputs

modelNaN = modelT;
modelNaN.dfGt0GroupContUncertainty = NaN(4, 1);
[D, DGC] = plotConcVSdGft0GroupContUncertainty(modelNaN);
% every metabolite takes the NaN branch; the printed fraction is 0/0 (NaN)
assert(all(isnan(D)) && all(isnan(DGC)));
close(setdiff(findall(0, 'Type', 'figure'), figuresBefore));

% restore the figure default and change the directory
set(0, 'DefaultFigureVisible', defaultFigureVisible);
cd(currentDir)
