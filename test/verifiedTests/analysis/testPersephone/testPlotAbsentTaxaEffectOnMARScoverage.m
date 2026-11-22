% The COBRAToolbox: testPlotAbsentTaxaEffectOnMARScoverage.m
%
% Purpose:
%     - plotAbsentTaxaEffectOnMARScoverage plots the mean MARS read coverage obtained when
%       the k most abundant unmapped taxa are added to the mapped ones (k = 0, 1, ...), for
%       all unmapped taxa and for those with a genus+epithet name, and saves the figure as
%       <results_path>effectOfAbsentTaxaOnReadCoverageMARS.png. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): the first point of the
%       genus+epithet curve is wrong (defect below), so no assertion about the function is
%       made.
%
% Function under test:
%     src/analysis/persephone/additionalFunctions/plotAbsentTaxaEffectOnMARScoverage.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use small hand-built tables and an
%     invisible figure in a temporary folder.
%
% Coverage exemptions:
%     every line - plotAbsentTaxaEffectOnMARScoverage is quarantined for the defect below
%     (feature 20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The genus+epithet curve starts at the standard deviation of the base coverage
%       SEVERITY: wrong-result
%       TRIGGER: pre = table({'Alpha one'; 'Beta two'; 'Gamma three'}, [10; 5; 1], [20; 0;
%         2], 'VariableNames', {'Taxon', 's1', 's2'}); absent = table({'Alpha_one';
%         'Beta_two'}, [0.3; 0.1], 'VariableNames', {'Taxon', 'mean'}); rc = table({'pre';
%         'post'}, [100; 50], [100; 70], 'VariableNames', {'Var', 's1', 's2'});
%         plotAbsentTaxaEffectOnMARScoverage(pre, absent, rc, [tmpDir filesep],
%         'numAbsentTaxaToInvestigate', 3), with the default figure CloseRequestFcn set to
%         hide the figure so that the YData of the two plotted lines can be read
%       OBSERVED: 'All absent taxa' YData [0.6 0.75 0.775]; 'Absent taxa with standard
%         nomenclature (genus+epithet)' YData [0.141421 0.75 0.775]: line 79 writes
%         stdCov_readCounts(1) into meanCov_readCounts_onlyNamedTaxa(1), overwriting the mean
%         set on line 78, instead of into stdCov_readCounts_onlyNamedTaxa(1)
%       EXPECTED: both curves start at the base mean coverage 0.6 (mean of 50/100 and 70/100)
%       LINES: 79
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPlotAbsentTaxaEffectOnMARScoverage'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
