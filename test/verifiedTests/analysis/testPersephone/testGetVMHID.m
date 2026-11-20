% The COBRAToolbox: testGetVMHID.m
%
% Purpose:
%     - getVMHID looks up VMH metabolite IDs for metabolite names (case-insensitive exact
%       match in the database of loadVMHDatabase) and, when suggest is 1, lists for every
%       name that is not found the database names that contain it, shortest first. The
%       function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the suggestions are put in the wrong columns once a name has been
%       found (defect below), so no assertion about the function is made.
%
% Function under test:
%     src/analysis/persephone/additionalFunctions/getVMHID.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use a hand-written metabolite database in
%     a temporary folder (as testLoadVMHDatabase does).
%
% Coverage exemptions:
%     every line - getVMHID is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Suggestions are misaligned after a found name
%       SEVERITY: wrong-result
%       TRIGGER: [metIDs, suggestedMets] = getVMHID({'ATP', 'lactate'}, 1) with the VMH
%         database (ATP is found, lactate is not)
%       OBSERVED: suggestedMets is a 23x2 cell array (MATLAB R2025a) whose first column is
%         {'lactate'; []; []; ...} and whose second column is {[]; 'D-lactate';
%         'L-lactate'; 'Indolelactate'; ...}: the column of the found name is deleted
%         (line 63), so the suggestions of the i-th name are written into column i of the
%         shrunken array, next to their name instead of below it. getVMHID({'lactate'}, 1)
%         gives the correct 23x1 column.
%       EXPECTED: one column per name not found, the name in row 1 and its suggestions
%         below it: {'lactate'; 'D-lactate'; 'L-lactate'; 'Indolelactate'; ...}
%       LINES: 60-64, 79-80
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetVMHID'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
