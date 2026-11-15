% The COBRAToolbox: testConfigCMatrix.m
%
% Purpose:
%     - configCMatrix adds the BarrierRound folder (parent of CMatrix) to the path, runs the
%       parent configuration script config, and adds the CMatrix include folder to the path; it
%       is the first step of compileCMatrix and is run by loadModular('CMatrix'). The function
%       is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): the
%       script config does not exist in the repository, so every call stops with an error
%       (defect below) and no assertion about the function is made.
%
% Function under test:
%     src/analysis/sampling/BarrierRound/CMatrix/configCMatrix.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would check the path entries added and restore
%     the path.
%
% Coverage exemptions:
%     every line - configCMatrix is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Every call stops because the parent script config does not exist
%       SEVERITY: error
%       TRIGGER: configCMatrix() (also loadModular('CMatrix'), after initCobraToolbox)
%       OBSERVED: error MATLAB:UndefinedFunction 'Unrecognized function or variable
%         'config'.' at line 11 (MATLAB R2025a; which config -all finds nothing, and no
%         config.m exists under src/analysis/sampling/BarrierRound); the BarrierRound folder
%         added by line 10 stays at the top of the path and the include folder is never added.
%       EXPECTED: the parent configuration runs (it is expected to set the global EIGEN_PATH
%         that compileCMatrix reads) and the CMatrix include folder is added to the path
%       LINES: 11, 13
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConfigCMatrix'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
