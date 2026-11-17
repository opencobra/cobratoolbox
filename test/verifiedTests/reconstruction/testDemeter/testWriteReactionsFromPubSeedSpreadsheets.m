% The COBRAToolbox: testWriteReactionsFromPubSeedSpreadsheets.m
%
% Purpose:
%     - writeReactionsFromPubSeedSpreadsheets reads the PubSEED comparative-genomics
%       spreadsheets of a folder and writes inputDataFolder/genomeAnnotation.txt: for each
%       organism of the information file and each annotated gene function, the VMH reactions
%       of that function (InReactions.txt) with their gene rule, plus gap-filled exchange
%       reactions for the extracellular metabolites of each reaction.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the independent review (T027/T028) showed that the documented default of
%       inputDataFolder is not implemented, so the documented way to request it fails; this
%       file makes no assertion about the function. The wave version of this test (git
%       history) wrote the information file, InReactions.txt, a small VMH database and two
%       spreadsheets by hand in a temporary folder and checked the written rows (gene rules,
%       ' or ' joining, gap-filled entries, exchanges, de-duplication, numeric and text
%       versions, no spreadsheet); it is the starting point once the defect is fixed.
%
% Function under test:
%     src/reconstruction/demeter/src/integration/writeReactionsFromPubSeedSpreadsheets.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-written text files in a temporary folder.
%
% Coverage exemptions:
%     every line - writeReactionsFromPubSeedSpreadsheets is quarantined for the defect below
%     (feature 20261113-142115-test-backfill-tiers, independent review T027/T028). Before the
%     quarantine the test reached every executable line.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented default of inputDataFolder is not implemented
%       SEVERITY: unusable-option
%       TRIGGER: writeReactionsFromPubSeedSpreadsheets(infoFilePath, [], spreadsheetFolder)
%         (or '' for inputDataFolder) run from a folder that holds the information file,
%         InReactions.txt and the VMH database; inputDataFolder cannot be omitted because
%         spreadsheetFolder follows it, so an empty value is the only way to ask for the
%         default
%       OBSERVED: (R2025a, 2026-11-17, Linux) "Unable to open file '/genomeAnnotation.txt'
%         for writing" at line 129: [[] filesep 'genomeAnnotation'] is a path in the root of
%         the file system; there is no nargin or isempty handling; ./InputData is not written
%       EXPECTED: the file written to the folder InputData of the current folder, as the
%         header documents ("inputDataFolder: Folder to save propagated data to (default:
%         folder in current path called "InputData")", lines 11-12)
%       LINES: 129
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - Quarantined after the independent review (T027/T028), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testWriteReactionsFromPubSeedSpreadsheets'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
