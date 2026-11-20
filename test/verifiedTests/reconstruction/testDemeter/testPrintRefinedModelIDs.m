% The COBRAToolbox: testPrintRefinedModelIDs.m
%
% Purpose:
%     - printRefinedModelIDs(draftFolder) lists every file in draftFolder and its
%       subfolders, keeps the SBML and .mat files ("remove any files that are not SBML or
%       mat files") and returns adaptDraftModelID of each name, the identifiers DEMETER gives
%       the refined models. The function is QUARANTINED (Constitution III-Defects,
%       quarantine in back-fill campaigns): the filter does not remove other files; no
%       assertion about the function is made.
%
% Function under test:
%     src/reconstruction/demeter/src/integration/printRefinedModelIDs.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would create empty files in a temporary folder.
%
% Coverage exemptions:
%     every line - printRefinedModelIDs is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: files that are not SBML or .mat files are returned as model identifiers
%       SEVERITY: wrong-result
%       TRIGGER: a folder holding the empty files A_b.sbml and notes.txt, then
%         printRefinedModelIDs(folder); or a folder holding only notes.txt and other.csv
%       OBSERVED: (R2025a, 2026-11-15) {'A_b'; 'notes_txt'} for the first folder and
%         {'other_csv'} for the second. Line 27 applies any() to the whole column returned
%         by contains, so delInd is 1 when no file matches (only the first file is removed)
%         and empty otherwise (no file is removed)
%       EXPECTED: {'A_b'} for the first folder and no identifier for the second: every file
%         whose name contains neither 'sbml' nor 'mat' removed (the comment of line 26)
%       LINES: 27-28
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPrintRefinedModelIDs'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
