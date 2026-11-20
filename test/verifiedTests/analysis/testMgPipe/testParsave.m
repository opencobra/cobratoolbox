% The COBRAToolbox: testParsave.m
%
% Purpose:
%     - parsave saves a variable to a MAT-file so that it can be called from a parfor loop. A
%       structure with a 'rxns' field (a model) is saved under the name 'model', as a
%       version 7 MAT-file when it has fewer than 300000 reactions and as a version 7.3
%       (HDF5) MAT-file otherwise; any other (non-structure) value is saved under the name
%       'data'. The test checks the variable name, the round-trip of the saved value and the
%       MAT-file version written in the file header (the text 'MATLAB 5.0 MAT-file' or
%       'MATLAB 7.3 MAT-file' at the start of the file, documented by MathWorks).
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns; severity audit T009a): a structure without a rxns field, a documented data
%       variable, is silently not saved (defect below), so no assertion about the function is
%       made; the checks described above are the plan for the test once the defect is
%       resolved.
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/parsave.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built structures and arrays saved in a temporary
%     folder.
%
% Coverage exemptions:
%     every line - parsave is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers, severity audit T009a)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A structure without a rxns field is silently not saved
%       SEVERITY: wrong-result
%       TRIGGER: parsave(fullfile(tempname, 'x.mat'), struct('a', 1))
%       OBSERVED: no file is written and no warning or error is raised (the isfield test on
%         line 15 has no else branch)
%       EXPECTED: per the header ('Saves a data variable (e.g., model)'), the structure is
%         saved; the callers in the toolbox pass only models or cell arrays. Severity audit
%         2026-11-15: INPUTS document data as "name of variable"; a struct without a rxns
%         field is a documented data variable and is silently not saved (no else branch at
%         line 15)
%       LINES: 15
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15; severity audit
%       2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testParsave'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
