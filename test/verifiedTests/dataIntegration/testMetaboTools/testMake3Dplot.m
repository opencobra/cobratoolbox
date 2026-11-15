% The COBRAToolbox: testMake3Dplot.m
%
% Purpose:
%     - make3Dplot groups the samples by the phenotype in column 2 of PHs (sorted unique
%       values), plots columns 4, 5 and 7 of maximum_contributing_flux (glycolysis, ATP
%       synthetase and succinate-CoA ligase) as one filled square scatter3 series per phenotype
%       with the phenotype as user data and legend entry, labels and titles the axes, saves
%       <path>/FS_3D.png and, with diff_view = 1, three further views as PDF files.
%     - The test checks the plotted coordinates against the rows of a hand-built flux matrix,
%       the legend, labels and limits, the files written, the default and explicit diff_view,
%       and the colour order the function sets as a MATLAB root default (restored afterwards).
%       Figures are invisible and closed; files go to temporary folders that are removed.
%
% Function under test:
%     src/dataIntegration/metabotools/make3Dplot.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built phenotypes and flux matrix.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Only the first two phenotypes are plotted
%       SEVERITY: limitation
%       TRIGGER: make3Dplot({'s1', 'A'; 's2', 'B'; 's3', 'C'}, rand(3, 7), 10, tempname-folder)
%       OBSERVED: the axes hold two scatter series (A and B); phenotype C is computed into x3,
%         y3, z3 but never plotted and not in the legend (R2025a, 2026-11-15). The input is
%         skipped below.
%       EXPECTED: one series per phenotype, as the commented-out loop of lines 48-55 intends
%       LINES: 60-64
%     - DEFECT: The coordinates of every phenotype are printed to the console
%       SEVERITY: cosmetic
%       TRIGGER: any call, e.g. the first section below
%       OBSERVED: x1 = ..., y1 = ..., z1 = ... are printed for every phenotype (the eval
%         strings have no semicolon; R2025a, 2026-11-15)
%       EXPECTED: no console output
%       LINES: 37-39
%     - DEFECT: The colour order is changed for every later figure of the session
%       SEVERITY: cosmetic
%       TRIGGER: any call, e.g. the first section below
%       OBSERVED: set(0, 'DefaultAxesColorOrder', ...) stays in force after the call
%         (R2025a, 2026-11-15); the test restores the previous root default
%       EXPECTED: the colour order applied to this figure only
%       LINES: 46
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMake3Dplot'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% save the root defaults the test and the function change: figure visibility and colour order
rootDefaults = get(0, 'Default');
hadColorOrder = isfield(rootDefaults, 'defaultAxesColorOrder');
if hadColorOrder
    savedColorOrder = rootDefaults.defaultAxesColorOrder;
end
hadVisibility = isfield(rootDefaults, 'defaultFigureVisible');
if hadVisibility
    savedVisibility = rootDefaults.defaultFigureVisible;
end
set(0, 'DefaultFigureVisible', 'off');

% three samples, two phenotypes; flux rows hold distinct values so that every coordinate
% identifies its sample and column
PHs = {'s1', 'B'; 's2', 'A'; 's3', 'B'};
fluxes = [11 12 13 14 15 16 17; 21 22 23 24 25 26 27; 31 32 33 34 35 36 37];
fontSize = 10;
expectedColorOrder = [0, 0.2, 0.8; 0, 0.6, 0.0; 0.2, 0.8, 1; 0, 0.6, 0.8; 0.8, 0, 0.2; 0.8, 0.4, 0.8; 1, 0.8, 0.2];

%% two phenotypes, diff_view not given: one series per phenotype and FS_3D.png

outputDir = tempname;
mkdir(outputDir);
make3Dplot(PHs, fluxes, fontSize, outputDir);
plotAxes = gca;
series = plotAxes.Children;
assert(numel(series) == 2);
% phenotypes in sorted order: A (sample 2) first, B (samples 1 and 3) second; the values are
% copied, so the comparison is exact
seriesA = series(strcmp(get(series, 'UserData'), 'A'));
seriesB = series(strcmp(get(series, 'UserData'), 'B'));
assert(isequal(seriesA.XData(:), 24) && isequal(seriesA.YData(:), 25) && isequal(seriesA.ZData(:), 27));
assert(isequal(seriesB.XData(:), [14; 34]) && isequal(seriesB.YData(:), [15; 35]) && isequal(seriesB.ZData(:), [17; 37]));
assert(strcmp(seriesA.Marker, 'square') && strcmp(seriesA.MarkerFaceColor, 'flat'));
% legend entries follow the series' user data
assert(isequal(sort(plotAxes.Legend.String), {'A', 'B'}));
% labels, title, font size and z-limits as set by the function
assert(strcmp(plotAxes.XLabel.String, 'Glycolysis (%)'));
assert(strcmp(plotAxes.YLabel.String, 'ATP synthetase (%)'));
assert(strcmp(plotAxes.ZLabel.String, 'Succinate-CoA ligase (%)'));
assert(strcmp(plotAxes.Title.String, 'ATP production strategies across samples'));
assert(plotAxes.FontSize == fontSize && isequal(plotAxes.ZLim, [0 12]));
% only the png of the standard view is written
writtenFiles = dir(fullfile(outputDir, 'FS_3D*'));
assert(isequal({writtenFiles.name}, {'FS_3D.png'}));
% the colour order is set as a root default (documented defect above)
assert(isequal(get(0, 'DefaultAxesColorOrder'), expectedColorOrder));
close all
rmdir(outputDir, 's');

%% one phenotype, diff_view = 1: the three side views are saved as well

outputDir = tempname;
mkdir(outputDir);
make3Dplot({'s1', 'A'; 's2', 'A'}, fluxes(1:2, :), fontSize, outputDir, 1);
plotAxes = gca;
assert(numel(plotAxes.Children) == 1);
assert(isequal(plotAxes.Children.XData(:), [14; 24]));
assert(isequal(plotAxes.Legend.String, {'A'}));
% the last view set is azimuth 90, elevation 0 (Succ-ATP)
assert(isequal(plotAxes.View, [90 0]));
writtenFiles = dir(fullfile(outputDir, 'FS_3D*'));
assert(isequal(sort({writtenFiles.name}), ...
    sort({'FS_3D.png', 'FS_3D_ATP_GLY.pdf', 'FS_3D_Succ_GLY.pdf', 'FS_3D_SUCC_ATP.pdf'})));
close all
rmdir(outputDir, 's');

%% diff_view empty: the default 0, only the standard view

outputDir = tempname;
mkdir(outputDir);
make3Dplot(PHs, fluxes, fontSize, outputDir, []);
writtenFiles = dir(fullfile(outputDir, 'FS_3D*'));
assert(isequal({writtenFiles.name}, {'FS_3D.png'}));
close all
rmdir(outputDir, 's');

% restore the root defaults and change the directory
if hadColorOrder
    set(0, 'DefaultAxesColorOrder', savedColorOrder);
else
    set(0, 'DefaultAxesColorOrder', 'remove');
end
if hadVisibility
    set(0, 'DefaultFigureVisible', savedVisibility);
else
    set(0, 'DefaultFigureVisible', 'remove');
end
cd(currentDir)
