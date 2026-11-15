% The COBRAToolbox: testGetUnannotatedReactionsFromPubSeedSpreadsheets.m
%
% Purpose:
%     - getUnannotatedReactionsFromPubSeedSpreadsheets reads the PubSEED comparative-genomics
%       spreadsheets of a folder and returns, for each organism of the information file, the
%       VMH reactions (InReactions.txt) of the genes with an empty annotation, without
%       duplicates, without reactions gap-filled in gapfilledGenomeAnnotation.txt and without
%       reactions missing from ReactionTranslationTable.txt. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): when no reaction is
%       unannotated, it stops with an index error instead of returning an empty list, so no
%       assertion about the function is made.
%
% Function under test:
%     src/reconstruction/demeter/src/integration/getUnannotatedReactionsFromPubSeedSpreadsheets.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would write the information file, the input
%     tables and the spreadsheets by hand in a temporary folder.
%
% Coverage exemptions:
%     every line - getUnannotatedReactionsFromPubSeedSpreadsheets is quarantined for the
%     defect below (feature 20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Spreadsheets with no unannotated reaction stop with an index error
%       SEVERITY: error
%       TRIGGER: in a temporary folder d (also the current folder): info2.txt with the
%         tab-separated lines 'MicrobeID PubSeedID' and 'orgA Org A (1.1)'; InReactions.txt
%         'PubSEED Abreviation VMH Abbreviation' and 'GeneX RXN1'; ReactionTranslationTable.txt
%         'TranslatedReaction VMHreaction' and 'rxn1 RXN1'; gapfilledGenomeAnnotation.txt
%         'orgB RXN9 gap_filled'; d/ss/a.tsv 'Organism GeneX' and 'Org A (1.1) 123' (every
%         gene annotated); getUnannotatedReactionsFromPubSeedSpreadsheets(fullfile(d,
%         'info2.txt'), d, fullfile(d, 'ss'))
%       OBSERVED: "Index in position 2 exceeds array bounds." at line 84:
%         unannotatedRxns is the 0 x 0 cell {} and unannotatedRxns(:, 1) fails (R2025a,
%         2026-11-15)
%       EXPECTED: an empty list of unannotated reactions returned
%       LINES: 84
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetUnannotatedReactionsFromPubSeedSpreadsheets'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
