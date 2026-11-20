% The COBRAToolbox: testValidateDietPath.m
%
% Purpose:
%     - validateDietPath takes a COBRA Toolbox diet name (EUAverageDiet, HighFiberDiet, ...)
%       or the path of a diet file; for a name it writes the diet to <resPath>/diet.txt and
%       returns that path, for a .txt file it returns the input path. The function is
%       QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): every diet
%       file path stops with an error (defect below), so no assertion about the function is
%       made.
%
% Function under test:
%     src/analysis/persephone/additionalFunctions/validateDietPath.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use a temporary folder.
%
% Coverage exemptions:
%     every line - validateDietPath is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A diet file path stops with an error
%       SEVERITY: error
%       TRIGGER: a file myDiet.txt holding the line 'EX_a<TAB>1' in tmpDir;
%         validateDietPath(fullfile(tmpDir, 'myDiet.txt'), tmpDir)
%       OBSERVED: error "Unrecognized function or variable 'diet'." (validateDietPath:50);
%         the file branch and the final else use the undefined lower-case variable diet
%         instead of Diet
%       EXPECTED: the input path is returned (documented: '.txt' files are skipped)
%       LINES: 50-53, 65
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testValidateDietPath'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
