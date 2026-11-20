% The COBRAToolbox: testMicrobiomeMappingStats.m
%
% Purpose:
%     - microbiomeMappingStats reads an unfiltered microbiome table (Taxon column, one column
%       of read counts per sample), keeps the samples listed in the metadata, flags the taxa
%       mapped by MARS (MARS table with 'pan'-prefixed taxon names) and writes
%       speciesRelAbunStats.xlsx (relative abundance statistics of all, unmapped and mapped
%       taxa) and alphaDiversities.csv (number of taxa and of mapped taxa per sample) to
%       saveDir. The function is QUARANTINED (Constitution III-Defects, quarantine in
%       back-fill campaigns): taxa whose name contains "pan" are counted as unmapped (defect
%       below), so no assertion about the function is made.
%
% Function under test:
%     src/analysis/persephone/additionalFunctions/microbiomeMappingStats.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use small hand-written CSV tables in a
%     temporary folder.
%
% Coverage exemptions:
%     every line - microbiomeMappingStats is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Taxa whose name contains "pan" are counted as unmapped
%       SEVERITY: wrong-result
%       TRIGGER: raw.csv = table Taxon = {'Bacteroides fragilis'; 'Ruminococcus
%         champanellensis'; 'Lactobacillus panis'; 'Unknown species'; ''}, S1 = [60; 20; 10;
%         10; 5], S2 = [0; 30; 20; 50; 5], S3 = [1; 1; 1; 1; 1]; mars.csv = table Taxon =
%         {'panBacteroides fragilis'; 'panRuminococcus chamellensis'; 'panLactobacillus
%         panis'}, S1 = [1; 2; 3]; meta.csv = table ID = {'S1'; 'S2'}, age = [30; 40];
%         microbiomeMappingStats('raw.csv', 'mars.csv', outDir, 'meta.csv')
%       OBSERVED: erase(MARS.Taxon, 'pan') also removes the "pan" inside the species name
%         ('panLactobacillus panis' becomes 'Lactobacillus is'), so Lactobacillus panis is
%         flagged unmapped: alphaDiversities.csv gives 'alpha mapped' 2 for S1 and 1 for S2,
%         and the sheet Mapped of speciesRelAbunStats.xlsx lists only Ruminococcus
%         chamellensis and Bacteroides fragilis
%       EXPECTED: only the prefix 'pan' is removed: 'alpha mapped' 3 for S1 and 2 for S2,
%         Lactobacillus panis in the sheet Mapped
%       LINES: 118
%     - DEFECT: An unlabelled count is printed
%       SEVERITY: cosmetic
%       TRIGGER: the call above
%       OBSERVED: 'ans = 2' is printed (statement without semicolon)
%       EXPECTED: no output, or output gated behind a verbose flag
%       LINES: 122
%     - DEFECT: The sheet of unmapped taxa is named 'Umapped'
%       SEVERITY: cosmetic
%       TRIGGER: the call above
%       OBSERVED: speciesRelAbunStats.xlsx has the sheets Total, Umapped and Mapped
%       EXPECTED: a sheet named Unmapped
%       LINES: 205
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMicrobiomeMappingStats'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
