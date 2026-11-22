% The COBRAToolbox: testGenerateStackedBarPlot_PhylumMARScoverage.m
%
% Purpose:
%     - generateStackedBarPlot_PhylumMARScoverage reads two tables (Taxon, mean) of phylum
%       mean relative abundances before and after MARS mapping, merges the phyla below 1%
%       into 'Others', draws one stacked bar per table with a colour-blind-friendly palette
%       and a legend, and saves PhylumAbundanceMappingCoverage_stackedBarPlot.png in saveDir.
%       The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): it errors for more than seven bar segments (defect below), so no
%       assertion about the function is made.
%
% Function under test:
%     src/analysis/persephone/generateStackedBarPlot_PhylumMARScoverage.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use hand-written CSV tables, an invisible
%     figure and a temporary folder.
%
% Coverage exemptions:
%     every line - generateStackedBarPlot_PhylumMARScoverage is quarantined for the defect
%     below (feature 20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Errors for more than seven phyla
%       SEVERITY: error
%       TRIGGER: pre.csv and post.csv written from table({'p1'; 'p2'; 'p3'; 'p4'; 'p5'; 'p6';
%         'p7'; 'p8'}, [0.3; 0.2; 0.15; 0.1; 0.1; 0.05; 0.05; 0.05], 'VariableNames',
%         {'Taxon', 'mean'}); generateStackedBarPlot_PhylumMARScoverage('pre.csv',
%         'post.csv', tempdirPath)
%       OBSERVED: MATLAB:UndefinedFunction, Unrecognized function or variable 'base_colors'.
%         (line 121; MATLAB R2025a): with 8 phyla and 'Others' num_taxa is 9 > 7, and the
%         interpolation branch uses base_colors and num_colors, which are never defined
%       EXPECTED: a palette of num_taxa colours interpolated from the seven base colours
%         and the figure saved, as the comment of the branch says
%       LINES: 118-123
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGenerateStackedBarPlot_PhylumMARScoverage'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
