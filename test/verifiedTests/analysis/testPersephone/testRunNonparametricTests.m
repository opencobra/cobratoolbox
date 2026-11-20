% The COBRAToolbox: testRunNonparametricTests.m
%
% Purpose:
%     - runNonparametricTests stacks a table of fluxes or relative abundances (one ID column
%       and one column per reaction or taxon) to long format, joins it with the metadata on
%       ID and compares the groups of a response variable for every reaction or taxon:
%       Wilcoxon rank sum test with effect size r for two groups, Kruskal-Wallis test with
%       eta squared for more, followed by the Benjamini-Hochberg FDR and a sort by FDR. A
%       two-group comparison is skipped when 30% or more of the values of a group are
%       missing. The function is QUARANTINED (Constitution III-Defects, quarantine in
%       back-fill campaigns): a skipped comparison is reported with p-value 0 and FDR 0
%       (defect below), so no assertion about the function is made.
%
% Function under test:
%     src/analysis/persephone/runNonparametricTests.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use hand-built tables.
%
% Coverage exemptions:
%     every line - runNonparametricTests is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A comparison skipped for missing values gets p-value 0 and FDR 0
%       SEVERITY: wrong-result
%       TRIGGER: data = table({'s1'; 's2'; 's3'; 's4'; 's5'; 's6'}, [1; 2; 3; 4; 5; 6],
%         [NaN; NaN; 3; 4; 5; 6], 'VariableNames', {'ID', 'r1', 'r2'}); metadata =
%         table({'s1'; 's2'; 's3'; 's4'; 's5'; 's6'}, {'a'; 'a'; 'a'; 'b'; 'b'; 'b'},
%         'VariableNames', {'ID', 'Grp'}); runNonparametricTests(data, metadata, 'Flux',
%         'Grp')
%       OBSERVED: r2 (two of the three values of group a missing, test skipped on lines
%         160-162) has statistic NaN, p-value 0 and FDR 0 and is sorted first, ahead of r1
%         (p-value 0.1): the p-value column of the preallocated table keeps its 0.
%       EXPECTED: p-value and FDR NaN for a comparison that is not performed
%       LINES: 160-162, 203-206
%     - DEFECT: The predictor name is accepted in any case but used as given
%       SEVERITY: limitation
%       TRIGGER: runNonparametricTests(data, metadata, 'flux', 'Grp') with the tables above
%       OBSERVED: Unrecognized table variable name 'flux'. Variable names are case
%         sensitive. The switch on line 78 uses lower(predictor) and names the stacked
%         column 'Flux', but line 134 reads dataGroup.(predictor).
%       EXPECTED: the result of the call with 'Flux'
%       LINES: 78, 134
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRunNonparametricTests'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
