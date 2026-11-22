% The COBRAToolbox: testComparePaths.m
%
% Purpose:
%     - comparePaths(NAME, printLevel) splits an environment variable as the system shell sees
%       it (echo $NAME) and as MATLAB sees it (getenv), or, for NAME = 'PYTHON', the module
%       search path of the system python and of MATLAB's Python interface, and returns the
%       entries common to both and the entries found only on one side.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the independent review (T027/T028) showed that for NAME = 'PYTHON' a
%       module search path entry that contains a blank is returned as a difference instead of
%       as common, so this file makes no assertion about the function. The wave version of
%       this test (git history) checked the environment-variable branch with variables it set
%       itself (equal entries, an entry with two blanks, an unset variable, all print levels)
%       and the PYTHON branch against sys.path read independently from both pythons; it is the
%       starting point once the defect is fixed.
%
% Function under test:
%     src/base/paths/comparePaths.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; needs the system program python and MATLAB's Python
%     interface (python3).
%
% Coverage exemptions:
%     every line - comparePaths is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers, independent review T027/T028). Before the
%     quarantine the test reached every executable line.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Python path entries with blanks, commas or quotes are reported as differences
%       SEVERITY: wrong-result
%       TRIGGER: [common, system_not_matlab, matlab_not_system] = comparePaths('PYTHON') when
%         an entry of sys.path contains a blank (also a comma or a quote); for example
%         setenv('PYTHONPATH', fullfile(d, 'a b')) before MATLAB's Python is loaded, so that
%         both the system python and MATLAB's Python have <d>/a b in sys.path
%       OBSERVED: (R2025a, 2026-11-17) <d>/a b is in sys.path of both pythons but is returned
%         in matlab_not_system and not in common, and system_not_matlab holds <d>/ab: line 39
%         deletes every blank of every system entry (meant for the blanks after the commas of
%         the printed list), and lines 32-40 split the printed list at every comma and remove
%         every quote, also inside entries
%       EXPECTED: <d>/a b in common (INPUTS: NAME 'PYTHON' compares the MATLAB and system
%         python paths; OUTPUTS: common holds the entries common to system and MATLAB), as for
%         any path entry; blanks are valid in paths (Program Files, Application Support)
%       LINES: 31-40
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - Converted to the quarantine layout after the independent review (T027/T028), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testComparePaths'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
