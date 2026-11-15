% The COBRAToolbox: testGetCurationStatus.m
%
% Purpose:
%     - getCurationStatus reads the information file of a DEMETER reconstruction resource and
%       the five experimental data tables of inputDataFolder (carbon sources, fermentation
%       products, growth requirements, secretion products, metabolite uptake) and returns,
%       for each organism and table, 2 if the organism has experimental data, 1 if it has
%       references only and 0 otherwise; it also writes curationStatus.txt. The function is
%       QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): data
%       entries 1 and -1 (the growth requirements table uses both) cancel out, so an
%       organism with experimental data is reported as 1, and no assertion about the
%       function is made.
%
% Function under test:
%     src/reconstruction/demeter/src/integration/getCurationStatus.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would write the information file and the five
%     tables by hand in a temporary folder.
%
% Coverage exemptions:
%     every line - getCurationStatus is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Data entries 1 and -1 cancel out and the organism is reported without experimental data
%       SEVERITY: wrong-result
%       TRIGGER: in a temporary folder d, info.txt with the lines MicrobeID, orgA, orgB, and
%         CarbonSourcesTable.txt, FermentationTable.txt, GrowthRequirementsTable.txt,
%         secretionProductTable.txt and uptakeTable.txt each with the tab-separated lines
%         'MicrobeID X1 X2 Ref1', 'orgA 1 -1 PMID:1', 'orgB 1 0 PMID:2';
%         getCurationStatus(fullfile(d, 'info.txt'), d, false)
%       OBSERVED: orgA gets 1 in every column and orgB gets 2: line 70 tests
%         abs(sum(data)) > 0, and 1 + (-1) = 0 (R2025a, 2026-11-15). In the distributed
%         GrowthRequirementsTable.txt (values 1, 0, -1) no strain has a zero sum (0 of 4750
%         strains with data), so the shipped resource is not affected
%       EXPECTED: 2 for orgA as for orgB (the documented "2 indicates that the reconstruction
%         was refined against available experimental data"): any non-zero entry, for example
%         any(cell2mat(...) ~= 0)
%       LINES: 70
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetCurationStatus'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
