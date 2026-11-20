% The COBRAToolbox: testSetCplexParametersForProblem.m
%
% Purpose:
%     - setCplexParametersForProblem(cplexProblem, problemTypeParams, solverParams,
%       problemType) resets a Cplex object to its defaults and sets display, logging,
%       tolerance, MIP, algorithm, scaling, time-limit, numerical-emphasis, Markowitz and
%       advanced-start parameters from the COBRA problem-type parameters and the
%       solver-specific parameters, and returns the log destination. The function is
%       QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): for
%       problemType 'MIQP' the documented text values of problemTypeParams.method are
%       overwritten before the function returns; no assertion about the function is made.
%
% Function under test:
%     src/base/solvers/cplex/setCplexParametersForProblem.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use a hand-built structure (fields
%     setDefault, Param, DisplayFunc) in place of the Cplex object, as testSetCplexParam.m
%     does.
%
% Coverage exemptions:
%     every line - setCplexParametersForProblem is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: text values of problemTypeParams.method have no effect for MIQP
%       SEVERITY: unusable-option
%       TRIGGER: cp.setDefault = []; cp.Param = struct(); cp.DisplayFunc = @disp;
%         ptp = struct('printLevel', 0, 'logFile', 0, 'feasTol', 1e-6, 'optTol', 1e-6,
%         'relMipGapTol', 1e-4, 'intTol', 1e-5, 'absMipGapTol', 0, 'timeLimit', 100,
%         'method', 'PRIMAL'); out = setCplexParametersForProblem(cp, ptp, struct(), 'MIQP')
%       OBSERVED: (R2025a, 2026-11-15) out.Param.lpmethod.Cur = 4 (barrier) for 'PRIMAL'
%         (and for every other text value). Lines 248-260 set lpmethod from the text value,
%         then line 302 (else branch of the 'LP' test on line 268) sets lpmethod to 4 for
%         every problem type other than 'LP'
%       EXPECTED: INPUTS document .method as "LP/QP algorithm selector used when problemType
%         is MIQP (numeric legacy code, or 'AUTOMATIC'/'PRIMAL'/...)", so 'PRIMAL' selects
%         algorithm 1; the numeric values do take effect (method 0 gives qpmethod 1)
%       LINES: 248-260, 302
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSetCplexParametersForProblem'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
