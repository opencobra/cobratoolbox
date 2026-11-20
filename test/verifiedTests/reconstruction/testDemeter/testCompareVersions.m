% The COBRAToolbox: testCompareVersions.m
%
% Purpose:
%     - compareVersions loads one reconstruction (microbeID.mat) from the folder of a previous
%       and of a new version, writes a LaTeX report of their differences (properties,
%       reaction, metabolite and gene content, constraints, mass and charge balance, leak test,
%       ATP production, growth, carbon sources, fermentation products, nutrients, vitamins and
%       bile acids) to reportFolder, runs pdflatex on it and returns the report name, a summary
%       table and the reactions, metabolites and genes found in only one version. The function
%       is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): every call
%       with valid inputs stops at the first test function it calls, which does not exist, so
%       no assertion about the function is made.
%
% Function under test:
%     src/reconstruction/demeter/suite/reports/compareVersions.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no solver reached; a test would save two small hand-built models in a
%     temporary folder (the missing test functions would need a solver and pdflatex).
%
% Coverage exemptions:
%     every line - compareVersions is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Every comparison stops at a test function that does not exist in the toolbox
%       SEVERITY: error
%       TRIGGER: folders prev/ and new/ (passed with a trailing filesep) each holding mic1.mat
%         with model = createModel({'EX_a', 'biomass_x'}, {'Ex a', 'biomass'},
%         {'a[e] <=>', 'a[e] ->'}) and model.genes = {'g1'} (lb of EX_a -5 in the new one), an
%         existing report folder rep; compareVersions(prev, new, rep, 'mic1', [])
%       OBSERVED: "Undefined function 'Test_MassChargeBalance' for input arguments of type
%         'struct'." at line 278, after the report was written up to the section 'Mass and
%         charge balance'; the report file stays open (fopen of line 46, fclose only at line
%         878). None of Test_MassChargeBalance, Test_LeakingMetabolites, Test_ATP, Test_Growth,
%         Test_CarbonSources, Test_FermentationProducts, Test_NutrientRequirements,
%         Test_BvitaminBiosynthesis, Test_VitaminSecretion or Test_BileAcidBiosynthesis exists
%         anywhere in the repository (R2025a, 2026-11-15)
%       EXPECTED: the complete report, the summary table and the lists of the documented
%         outputs
%       LINES: 278, 280, 383-384, 412-413, 436-437, 463-464, 521-522, 580, 582, 699-700, 760-761, 819-820
%     - DEFECT: Metabolite content is reported as identical whenever the reactions are identical
%       SEVERITY: wrong-result
%       TRIGGER: the two models of the entry above with the metabolite a[e] of the new model
%         renamed b[e] (same reactions)
%       OBSERVED: line 166 compares modelNew.rxns with modelPrevious.rxns, so the report says
%         'Metabolites are identical in both models.' and outputSummary(2, 3) is 'Unchanged'
%         although the metabolites differ (read from the code; the report text up to line 278
%         confirms the message, R2025a, 2026-11-15)
%       EXPECTED: metabolites compared (modelNew.mets with modelPrevious.mets), 'Changed' and
%         the lists of metabolites only in one version
%       LINES: 166-168
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCompareVersions'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
