% The COBRAToolbox: testEditCobraToolboxPath.m
%
% Purpose:
%     - editCobraToolboxPath(basePath, folderPattern, method) adds to or removes from the MATLAB
%       path every folder below basePath whose full path contains folderPattern (defaults:
%       basePath = the thermo folder holding vonBertalanffy, folderPattern = [filesep 'new'],
%       method = 'remove').
%     - Once the defect below is fixed, the test should build a folder tree in a tempname
%       folder (base/new, base/old, base/old/new, base/newer, base/other) and check which
%       folders are added and removed (the pattern is a plain substring, so '/new' also matches
%       '/newer'), the default pattern and method, the error for an unknown method, and the
%       default basePath: with empty inputs and 'add' every folder below the thermo folder whose
%       path contains [filesep 'new'] (listed independently with genpath) is on the path, also
%       when which() returns Windows separators (a stand-in which in a tempname folder). The
%       MATLAB path is saved first and restored at the end.
%       Quarantined: no behaviour of editCobraToolboxPath is asserted until the
%       unusable-option defect below is fixed; this file only opens the test.
%
% Function under test:
%     src/base/paths/editCobraToolboxPath.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built folders.
%
% Coverage exemptions:
%     every line - editCobraToolboxPath is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The default basePath does nothing on Windows
%       SEVERITY: unusable-option
%       TRIGGER: editCobraToolboxPath([], '', 'add') (or any call that omits basePath or passes
%         it empty) on Windows, where which('initVonBertalanffy') returns a path with backslashes;
%         reproduced on Linux with a stand-in which in the current folder that returns the real
%         path with every '/' replaced by '\'
%       OBSERVED: (R2025a, 2026-11-17) "new folders on path after add: 0 of 6; path changed: 0",
%         no error and no message; with the real which the same call adds 6 of 6. Line 21 strips
%         'vonBertalanffy/initVonBertalanffy.m' with a hard-coded '/', so basePath stays the path
%         of the .m file and dir() lists no folder below it
%       EXPECTED: basePath is the thermo folder on every platform (strip ['vonBertalanffy' filesep
%         'initVonBertalanffy.m'] or use fileparts), and the folders below it that contain the
%         pattern are added or removed as documented
%       LINES: 20-21, 31-32
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15; quarantined
%       after independent review, 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testEditCobraToolboxPath'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
