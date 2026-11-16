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
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the severity audit T009a raised the first defect below (a documented input
%       whose plot is not produced), so this file makes no assertion about the function. The
%       checks described above are those of the wave 09 version of this test (git history),
%       to be restored once the defect is fixed.
%
% Function under test:
%     src/dataIntegration/metabotools/make3Dplot.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built phenotypes and flux matrix.
%
% Coverage exemptions:
%     every line - make3Dplot is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers, severity audit T009a). Before the quarantine the
%     test reached every executable line.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Only the first two phenotypes are plotted
%       SEVERITY: wrong-result
%       TRIGGER: make3Dplot({'s1', 'A'; 's2', 'B'; 's3', 'C'}, rand(3, 7), 10, tempname-folder)
%       OBSERVED: the axes hold two scatter series (A and B); phenotype C is computed into x3,
%         y3, z3 but never plotted and not in the legend (R2025a, 2026-11-15)
%       EXPECTED: one series per phenotype, as the commented-out loop of lines 48-55 intends;
%         the header documents PHs as "Phenotypes = [samples PHENOTYPE]" and says "The
%         phenotypes are defined as colors" with no limit on their number, and the colour
%         order set at line 46 has seven entries, so a third phenotype is a documented input
%         whose plot is not produced (severity audit T009a)
%       LINES: 60-64
%     - DEFECT: The coordinates of every phenotype are printed to the console
%       SEVERITY: cosmetic
%       TRIGGER: any call, e.g. make3Dplot({'s1', 'B'; 's2', 'A'; 's3', 'B'}, [11:17; 21:27;
%         31:37], 10, tempname-folder)
%       OBSERVED: x1 = ..., y1 = ..., z1 = ... are printed for every phenotype (the eval
%         strings have no semicolon; R2025a, 2026-11-15)
%       EXPECTED: no console output
%       LINES: 37-39
%     - DEFECT: The colour order is changed for every later figure of the session
%       SEVERITY: cosmetic
%       TRIGGER: any call, e.g. make3Dplot({'s1', 'B'; 's2', 'A'; 's3', 'B'}, [11:17; 21:27;
%         31:37], 10, tempname-folder)
%       OBSERVED: set(0, 'DefaultAxesColorOrder', ...) stays in force after the call
%         (R2025a, 2026-11-15); a test has to restore the previous root default
%       EXPECTED: the colour order applied to this figure only
%       LINES: 46
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - Converted to the quarantine layout after the severity audit 2026-11-15 (T009a).

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMake3Dplot'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
