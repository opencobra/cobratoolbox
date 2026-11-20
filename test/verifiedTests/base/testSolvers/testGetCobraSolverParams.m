% The COBRAToolbox: testGetCobraSolverParams.m
%
% Purpose:
%     - getCobraSolverParams(problemType, paramNames, paramStructure) returns the values of
%       the solver parameters named in paramNames, taken with the documented priority
%       "paramStructure > solver type paramStructure (the global CBT_<type>_PARAMS) > default
%       values set within this script", and, when paramStructure is given, a final structure
%       output. The function is QUARANTINED (Constitution III-Defects, quarantine in
%       back-fill campaigns): the global parameters are ignored when no paramStructure is
%       given, and used when paramStructure is 'default' (the two defects below, mirror
%       images of each other), so no assertion about the function is made.
%
% Function under test:
%     src/base/solvers/param/getCobraSolverParams.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would set the global solver parameters by hand
%     (CobraSolverState) and restore them.
%
% Coverage exemptions:
%     every line - getCobraSolverParams is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The global solver parameters are ignored when no paramStructure is given
%       SEVERITY: wrong-result
%       TRIGGER: changeCobraSolverParams('LP', 'feasTol', 1e-9); getCobraSolverParams('LP', 'feasTol')
%       OBSERVED: 1e-06 (the default of the script; overRideDefaults is 0 without a third input,
%         so CBT_LP_PARAMS is never read)
%       EXPECTED: 1e-09, the global value (header: "gets ... from paramStructure, the global
%         cobra parameters variable or default values ... with the following priority
%         paramStructure > solver type paramStructure > default paramStructure")
%       LINES: 64-68, 169-176
%     - DEFECT: paramStructure 'default' returns the global values instead of the defaults
%       SEVERITY: wrong-result
%       TRIGGER: changeCobraSolverParams('LP', 'feasTol', 1e-9); getCobraSolverParams('LP', 'feasTol', 'default')
%       OBSERVED: 1e-09 (the global value; overRideDefaults is set to 1 for 'default')
%       EXPECTED: 1e-06 (OPTIONAL INPUTS: "paramStructure can be set to 'default' to use the
%         default values set within this script"; the comment of line 56 reads "overide
%         defaults unless hack is asking for defaults")
%       LINES: 60-62
%     - DEFECT: The structure output keeps the fields named in paramNames
%       SEVERITY: wrong-result
%       TRIGGER: [v, s] = getCobraSolverParams('LP', 'feasTol', struct('feasTol', 1e-3, 'other', 5))
%       OBSERVED: s has the fields feasTol (1e-3) and other (5)
%       EXPECTED: per OUTPUTS, "paramStructureOut, with fields removed corresponding to
%         paramNames" (only other); no caller in src/ uses this output, so the header is the
%         likely error. Severity audit 2026-11-15: the struct returned keeps and sets exactly
%         those fields (lines 166, 181), the opposite of the documented result
%       LINES: 166, 181, 186
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetCobraSolverParams'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
