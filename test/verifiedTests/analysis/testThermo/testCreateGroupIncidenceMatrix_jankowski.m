% The COBRAToolbox: testCreateGroupIncidenceMatrix_jankowski.m
%
% Purpose:
%     - createGroupIncidenceMatrix_jankowski parses the output file of the group contribution
%       method (one header line, then one line per metabolite of gcmMetList of the form
%       "id;id;group:count|group:count|", "NONE;NONE;" for none) into the m x g group incidence
%       matrix G and stops with an error on a group that is not in the Jankowski group list. A
%       test would compare G with the counts of a hand-written file in a tempname folder.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): its documented positional arguments are ignored (defect below), so this
%       file makes no assertion about the function.
%
% Function under test:
%     src/analysis/thermo/groupContribution/jankowski/createGroupIncidenceMatrix_jankowski.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - hand-built model fields and a text file, no solver.
%
% Coverage exemptions:
%     every line - createGroupIncidenceMatrix_jankowski is quarantined for the defect below
%     (feature 20261113-142115-test-backfill-tiers).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented arguments gcmOutputFile, gcmMetList and jankowskiGroupData are
%       ignored
%       SEVERITY: unusable-option
%       TRIGGER: createGroupIncidenceMatrix_jankowski(model, 'gcm.txt', {'a'; 'b'; 'c'},
%       groupData) with model.mets = {'a'; 'b'; 'c'; 'd'}, groupData.groups = {'G1'; 'G2';
%       'G3'} and gcm.txt a valid output file
%       OBSERVED: "Unrecognized field name "jankowskiGroupData"." at line 26 (MATLAB R2025a);
%       with model.gcmOutputFile, model.gcmMetList and model.jankowskiGroupData set, a call
%       with the arguments 'nonexistent.txt', {} and an empty group list returns the matrix of
%       the model fields: lines 26-28 read the model fields only
%       EXPECTED: the matrix built from the file, metabolite list and groups passed as
%       arguments, as the INPUTS section documents them
%       LINES: 26-28
%     - DEFECT: The function line names createGroupIncidenceMatrix_old, not the file name
%       SEVERITY: cosmetic
%       TRIGGER: any use; the Code Analyzer reports the mismatch for the file
%       OBSERVED: line 1 declares "function G = createGroupIncidenceMatrix_old(...)" in
%         createGroupIncidenceMatrix_jankowski.m; MATLAB calls the function by its file name,
%         so calls work (recorded 2026-11-20 when the USAGE line was corrected to the file
%         name by feature 20261120-151023-doc-matches-code)
%       EXPECTED: the function line names the file, createGroupIncidenceMatrix_jankowski
%       LINES: 1
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.
%     - Help text of createGroupIncidenceMatrix_jankowski corrected to match the code (feature 20261120-151023-doc-matches-code), 2026-11-20.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCreateGroupIncidenceMatrix_jankowski'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file needs no
% solver, MATLAB toolbox or particular operating system; the call is the standard opening of
% a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
