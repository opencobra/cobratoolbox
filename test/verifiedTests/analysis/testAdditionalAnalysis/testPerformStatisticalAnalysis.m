% The COBRAToolbox: testPerformStatisticalAnalysis.m
%
% Purpose:
%     - performStatisticalAnalysis compares features (rows of sampleData, for example fluxes)
%       between the groups of a stratification column of sampleInformation: Wilcoxon rank
%       sum test for two groups, Kruskal-Wallis test or one-way ANOVA for more, corrected
%       for multiple testing (Benjamini-Hochberg, or Storey with mafdr), with group averages,
%       standard deviations and descriptions from the VMH database. Samples whose values are
%       all zero are meant to be removed first. The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): an all-zero sample is not removed
%       for numeric data and changes the statistics (defect below), so no assertion about
%       the function is made.
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/performStatisticalAnalysis.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use hand-built cell arrays and a small VMH
%     database written to a temporary folder.
%
% Coverage exemptions:
%     every line - performStatisticalAnalysis is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Samples whose values are all zero are not removed
%       SEVERITY: wrong-result
%       TRIGGER: sampleData = {'', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7'; 'EX_ac[fe]', 1, 2,
%         3, 10, 11, 12, 0; 'ATPM', 5, 6, 7, 1, 2, 3, 0}; sampleInformation = {'ID', 'Group';
%         'S1', 'A'; 'S2', 'A'; 'S3', 'A'; 'S4', 'B'; 'S5', 'B'; 'S6', 'B'; 'S7', 'A'};
%         performStatisticalAnalysis(sampleData, sampleInformation, 'BHFDR', true)
%       OBSERVED: the all-zero sample S7 stays in significantFeatures and in the tests:
%         p-values before correction 0.0518 and 0.3768, Average_A 1.5 and 4.5 (without S7:
%         0.0809, 0.0809, 2 and 6). Line 75 applies str2double to numeric cells, which gives
%         NaN, so the all-zero condition never holds (MATLAB R2025a).
%       EXPECTED: S7 removed (code comment "delete columns that are all zeros") and the
%         statistics of S1 to S6
%       LINES: 75-77
%     - DEFECT: Fecal exchange features never get a metabolite description
%       SEVERITY: wrong-result
%       TRIGGER: the call above; the metabolite ac (Acetate) is in the VMH database
%       OBSERVED: the Description of EX_ac[fe] is 'NA'. The condition on line 230 includes
%         the header 'Feature' of Statistics(:,1), which never contains '[fe]', so the
%         prefix and suffix are never stripped.
%       EXPECTED: 'Acetate'. Severity audit 2026-11-15: the code comment "add
%         reaction/metabolite annotations if possible" and the EX_/[fe] stripping (lines
%         231-232) show the Description column is meant to be filled; the test on line 230
%         includes the header row so it is always false and every [fe] feature gets NA in the
%         returned Statistics table - a wrong value in a result, not in a message
%       LINES: 230-232
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPerformStatisticalAnalysis'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
