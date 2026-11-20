% The COBRAToolbox: testPrintSolutionGEM.m
%
% Purpose:
%     - printSolutionGEM prints the objective value and the non-zero fluxes of the reactions
%       added by growthExpMatch (MatricesSUX.MatrixPart ~= 1): to the command window when
%       called with two inputs, or appended to logFile (with '.txt' added when missing,
%       created anew at iteration 1) after saving the solution to
%       <logFile>_solution_<itNum>. The function is QUARANTINED (Constitution III-Defects,
%       quarantine in back-fill campaigns): a log file name shorter than four characters
%       stops the function, so no assertion about the function is made.
%
% Function under test:
%     src/reconstruction/growthExpMatch/printSolutionGEM.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would build MatricesSUX and the solution by hand
%     and write the log in a temporary folder.
%
% Coverage exemptions:
%     every line - printSolutionGEM is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A log file name shorter than four characters stops the function
%       SEVERITY: error
%       TRIGGER: MatricesSUX.MatrixPart = [1 2 2], MatricesSUX.rxns = {'r1'; 'r2'; 'r3'},
%         solution.cont = [1; 0; 2.5], solution.obj = 3; printSolutionGEM(MatricesSUX,
%         solution, 'abc', 1) in an empty folder
%       OBSERVED: "Array indices must be positive integers or logical values." at line 27
%         (logFile(end-3:end) of a 3-character name), after abc_solution_1.mat was saved and
%         before anything was printed (R2025a, 2026-11-15); 'GEMLog' and 'GEMLog.txt' work
%       EXPECTED: the log written to abc.txt, as for any other name without '.txt'
%       LINES: 27
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - Help text of printSolutionGEM corrected to match the code (feature 20261120-151023-doc-matches-code), 2026-11-20.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPrintSolutionGEM'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
