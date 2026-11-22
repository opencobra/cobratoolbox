% The COBRAToolbox: testSetGurobiParam.m
%
% Purpose:
%     - setGurobiParam translates a COBRA parameter structure into the parameter structure of
%       the Gurobi MATLAB interface: timelimit becomes TimeLimit, multiscale = 1 sets
%       ScaleFlag = 0, lifted = 1 sets Aggregate = 1 and Presolve = 0, method is copied to
%       lpmethod or qpmethod, the algorithm names of lpmethod and qpmethod become the numeric
%       Method, printLevel, feasTol and optTol give OutputFlag, DisplayInterval,
%       FeasibilityTol and OptimalityTol, and every field that is not a Gurobi parameter is
%       removed. The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): a given TimeLimit is overridden by timelimit and the fields documented as
%       optional are required, so no assertion about the function is made.
%
% Function under test:
%     src/base/solvers/gurobi/setGurobiParam.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use hand-built parameter structures.
%
% Coverage exemptions:
%     every line - setGurobiParam is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: timelimit overrides TimeLimit although the help text says it is copied only when TimeLimit is absent
%       SEVERITY: wrong-result
%       TRIGGER: setGurobiParam(struct('timelimit', 10, 'TimeLimit', 20, 'printLevel', 0, 'feasTol', 1e-7, 'optTol', 1e-8))
%       OBSERVED: gurobiParam.TimeLimit = 10 (R2025a, 2026-11-15); line 80 copies timelimit
%         unconditionally
%       EXPECTED: TimeLimit = 20 kept, as the help text says timelimit is copied to TimeLimit if
%         TimeLimit is absent
%       LINES: 79-81
%     - DEFECT: printLevel, feasTol and optTol are required although the fields are documented as optional
%       SEVERITY: error
%       TRIGGER: setGurobiParam(struct())
%       OBSERVED: error Unrecognized field name "printLevel". (MATLAB:nonExistentField); without
%         OutputFlag and DisplayInterval the field printLevel is read, without FeasibilityTol
%         the field feasTol, without OptimalityTol the field optTol
%       EXPECTED: all fields optional (help text: with fields (all optional))
%       LINES: 182, 194, 214, 223
%     - DEFECT: the warning for an unknown lpmethod names param.qpmethod
%       SEVERITY: cosmetic
%       TRIGGER: param.lpmethod = 'FOO'
%       OBSERVED: warning FOO is an unrecognised param.qpmethod for gurobi
%       EXPECTED: the warning names param.lpmethod
%       LINES: 145
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSetGurobiParam'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
