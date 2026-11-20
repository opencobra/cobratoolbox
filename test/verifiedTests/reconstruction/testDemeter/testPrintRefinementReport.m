% The COBRAToolbox: testPrintRefinementReport.m
%
% Purpose:
%     - printRefinementReport reads the results of the DEMETER test suite of a refinement
%       project (ATP_from_O2_<reconVersion>.txt and <reconVersion>_PercentagesAgreement.xls in
%       <testResultsFolder>/<reconVersion>_refined, tooHighATP.mat and notGrowing.mat in
%       testResultsFolder), prints a summary, returns it as a table and writes it to
%       Refinement_report_<reconVersion> in the current folder. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): the rows of the
%       agreement table that the DEMETER suite writes are reported under the wrong names, so
%       no assertion about the function is made.
%
% Function under test:
%     src/reconstruction/demeter/suite/reports/printRefinementReport.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would write the result files by hand in a temporary
%     folder.
%
% Coverage exemptions:
%     every line - printRefinementReport is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Aromatic amino acid results are reported as bile acids, bile acids as drugs, drugs are left out
%       SEVERITY: wrong-result
%       TRIGGER: <reconVersion>_PercentagesAgreement.xls written as plotTestSuiteResults writes it
%         (header Feature/StrainsWithData/PercentAgreeing, then the rows Carbon_sources,
%         Fermentation_products, PutrefactionPathways, Secretion_products, Metabolite_uptake,
%         AromaticAminoAcidDegradation, Bile_acid_biosynthesis, Drug_metabolism,
%         growsOnDefinedMedium with the numbers 10, 20, ..., 90 and fractions 0.1, ..., 0.9),
%         ATP_from_O2_proj.txt with three models, then
%         printRefinementReport(testResultsFolder, 'proj')
%       OBSERVED: 'Bile acid pathways were refined for 60 reconstructions.' and the row
%         'Reconstructions with bile acids comparative genomic data' 60 / 0.6 (the
%         AromaticAminoAcidDegradation row), 'Drug pathways were refined for 70
%         reconstructions.' and the row 'Reconstructions with drug comparative genomic data'
%         70 / 0.7 (the Bile_acid_biosynthesis row); the Drug_metabolism row (80) is not
%         reported (R2025a, 2026-11-15)
%       EXPECTED: bile acids 70 / 0.7, drugs 80 / 0.8, and the aromatic amino acid degradation
%         row reported under its own name or not at all
%       LINES: 85-96
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPrintRefinementReport'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
