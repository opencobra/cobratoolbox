% The COBRAToolbox: testPlotTestSuiteResults.m
%
% Purpose:
%     - plotTestSuiteResults(testResultsFolder, reconVersion) reads the results of the
%       DEMETER test suite (<feature>_TruePositives/_FalseNegatives_<reconVersion>.txt,
%       growsOnDefinedMedium_<reconVersion>.txt, imbalance and leak lists), draws violin
%       plots, computes the sensitivity of each feature (<reconVersion>_Properties.xls) and
%       the share of strains agreeing with the data (<reconVersion>_PercentagesAgreement.xls),
%       and lists unbalanced reactions and leaking metabolites. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): growth on the defined
%       medium is read as NaN when the file holds only 0 and 1; no assertion about the
%       function is made.
%
% Function under test:
%     src/reconstruction/demeter/suite/tests/plotTestSuiteResults.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would write the result files in a temporary
%     folder whose name ends in _refined.
%
% Coverage exemptions:
%     every line - plotTestSuiteResults is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: growth on the defined medium is lost when the file holds only numbers
%       SEVERITY: wrong-result
%       TRIGGER: in folder d/res_refined, growsOnDefinedMedium_v.txt {'s1', 1; 's2', 0;
%         's3', 1}, Carbon_sources_TruePositives_v.txt {'s1', 'glc'; 's2', ''; 's3', 'lac'}
%         and Carbon_sources_FalseNegatives_v.txt {'s1', ''; 's2', 'fru'; 's3', ''} (written
%         tab-separated as batchTestAllReconstructionFunctions writes them);
%         plotTestSuiteResults('d/res_refined', 'v')
%       OBSERVED: (R2025a, 2026-11-15) v_PercentagesAgreement.xls row growsOnDefinedMedium:
%         StrainsWithData 0, PercentAgreeing missing (0/0 = NaN); readtable(..., 'format',
%         'auto') of line 46 reads the 0/1 column as numbers and str2double of a numeric
%         cell is NaN (lines 68, 268-269); the violin plot of line 95 gets NaN data
%       EXPECTED: StrainsWithData 3 and PercentAgreeing 2/3 (the file holds 2 growing and 1
%         non-growing strain), as for a file that also holds 'NA' (read as text)
%       LINES: 46, 67-68, 268-269, 274
%     - DEFECT: the sensitivity column header loses its blank
%       SEVERITY: cosmetic
%       TRIGGER: the call above
%       OBSERVED: (R2025a, 2026-11-15) v_Properties.xls header 'Sensitivityv': strcat removes
%         the trailing blank of 'Sensitivity '
%       EXPECTED: 'Sensitivity v'
%       LINES: 120
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPlotTestSuiteResults'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
