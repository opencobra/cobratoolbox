% The COBRAToolbox: testRunMars.m
%
% Purpose:
%     - runMars reads a reads table (with the taxonomy in a Taxon column or in a separate
%       taxonomy table), cleans and renames the taxon names (renamingMars.json), maps the
%       taxa of every level (kingdom to species) onto AGORA2, APOLLO or a user database,
%       computes coverage, evenness and Firmicutes/Bacteroidetes metrics, and writes the
%       metrics, mapped, unmapped, processed and mapped_forModelling results. The function is
%       QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): it writes
%       the original-data summary into the processed and mapped sheets (defect below), so no
%       assertion about the function is made.
%
% Function under test:
%     src/analysis/persephone/runMars.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use a hand-written reads table, a small
%     user database and a temporary output folder.
%
% Coverage exemptions:
%     every line - runMars is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The processed and mapped summary sheets hold the original data
%       SEVERITY: wrong-result
%       TRIGGER: reads.xlsx written from table({'k__Bacteria;p__Bacillota;c__Bacilli;
%         o__Lactobacillales;f__Lactobacillaceae;g__Lactobacillus;s__acidophilus';
%         'k__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;
%         g__Bacteroides;s__fragilis'; 'k__Bacteria;p__Bacteroidota;c__Bacteroidia;
%         o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__'}, [100; 60; 40], [50; 30;
%         20], 'VariableNames', {'Taxon', 'S1', 'S2'}) (taxon strings without line breaks)
%         and db.csv with the columns Kingdom to Species of Lactobacillus acidophilus and
%         Bacteroides fragilis; runMars('reads.xlsx', 'reconstructionDb', 'user_db',
%         'userDbPath', 'db.csv', 'outputPathMars', outFolder)
%       OBSERVED: the sheets processedData and mappedData of
%         metrics/Species/taxonSummary.xlsx are identical to originalData (MATLAB R2025a):
%         they list the row 'NaN' (the reads without a species, mean 30) that
%         processed/processed_Species.csv does not contain. Lines 474-475 (and 479-480 for
%         brayCurtisDissimilarity.xlsx) write taxonSummary.originalData (brayCurtis.originalData)
%         to all three sheets.
%       EXPECTED: the processed and mapped summaries (taxonSummary.processed and
%         taxonSummary.mapped, brayCurtis.processed and brayCurtis.mapped) in the sheets of
%         the same names
%       LINES: 474-475, 479-480
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRunMars'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
