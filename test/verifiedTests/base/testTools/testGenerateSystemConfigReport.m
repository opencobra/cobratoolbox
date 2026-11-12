% The COBRAToolbox: testGenerateSystemConfigReport.m
%
% Purpose:
%     - tests the generateSystemConfigReport functionality
%
% Function under test:
%     src/base/generateSystemConfigReport.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver.
%
% Coverage exemptions:
%     Line 36: unreachable. The function has just moved to the toolbox root, where
%     initCobraToolbox.m lives, so which('initCobraToolbox') is never empty.
%     Lines 56-57: unreachable. system() reports a missing git through its status and text, it
%     does not throw, and strtrim of that text cannot fail.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A short answer from curl stops the report at the summary
%       SEVERITY: error
%       TRIGGER: a curl command whose output of --version has fewer than three words
%       OBSERVED: the warning at line 66 leaves result_curlVersion undefined, so line 95 stops the
%         function with an undefined-variable error, with the diary still on and the current
%         folder left at the toolbox root
%       EXPECTED: the report finishes and shows that the curl version is not known
%       LINES: 65-66
%
% Authors:
%     - Original file: COBRA Toolbox
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

global CBTDIR
global TOMLAB_PATH

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGenerateSystemConfigReport'));
cd(fileDir);

reportFile = [CBTDIR filesep 'COBRAconfigReport.log'];

% a report left by an earlier run is replaced, not appended to
fid = fopen(reportFile, 'w');
fprintf(fid, 'stale report\n');
fclose(fid);

generateSystemConfigReport();

% the report is complete, and the function returned to the folder it was called from
reportText = fileread(reportFile);
assert(~contains(reportText, 'stale report'));
assert(contains(reportText, 'SYSTEM CONFIGURATION REPORT'));
assert(contains(reportText, 'Architecture'));
assert(contains(reportText, 'CBT_LP_SOLVER'));
assert(contains(reportText, 'System PATH'));
assert(contains(reportText, 'MATLAB path'));
assert(strcmp(pwd, fileDir));

%% a global that cannot be printed gets a warning and the report goes on
savedTomlabPath = TOMLAB_PATH;
TOMLAB_PATH = {'not a text'};
lastwarn('');
try
    generateSystemConfigReport();
catch ME
    TOMLAB_PATH = savedTomlabPath;
    rethrow(ME);
end
TOMLAB_PATH = savedTomlabPath;
assert(contains(lastwarn, 'TOMLAB_PATH could not be retrieved'));
assert(contains(fileread(reportFile), 'END OF CONFIGURATION REPORT'));

delete(reportFile);

% change the directory
cd(currentDir)
