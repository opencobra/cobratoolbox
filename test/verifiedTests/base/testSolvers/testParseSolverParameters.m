% The COBRAToolbox: testParseSolverParameters.m
%
% Purpose:
%     - parseSolverParameters(problemType, varargin) returns the COBRA parameters of a
%       problem type (param) and the remaining, solver-specific parameters
%       (solverOnlyParams). The defaults come from getCobraSolverParams with the structure
%       form struct('solver', <selected solver>), whose documented priority is
%       "paramStructure > solver type paramStructure (the global CBT_<type>_PARAMS) >
%       default values set within getCobraSolverParams". The optional inputs are
%       parameter/value pairs, optionally with one parameter structure first or last; a
%       field of that structure wins over a pair with the same name (comment of line 73).
%       The test sets the solver state by hand (CobraSolverState) to known values, derives
%       every expected value from that state, the documented defaults of
%       getCobraSolverParams (lines 90-116 there) and the parameter lists of
%       getCobraSolverParamsOptionsForType, and restores the state at the end.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns; severity audit T009a): param does not hold the additional parameters the
%       OUTPUTS section promises (defect below), so no assertion about the function is made;
%       the checks described above are the plan for the test once the defect is resolved.
%
% Function under test:
%     src/base/solvers/param/parseSolverParameters.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; the solver selection and parameter globals are set to
%     hand-built values through CobraSolverState and restored.
%
% Coverage exemptions:
%     every line - parseSolverParameters is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers, severity audit T009a)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The invalid-parameters error message shows literal \n instead of line breaks
%       SEVERITY: cosmetic
%       TRIGGER: parseSolverParameters('LP', 'feasTol', 1e-3, 'x')
%       OBSERVED: the message reads "Invalid Parameters supplied.\nParameters have to be
%         supplied ..." with the two characters \n (MATLAB R2025a); error is called with
%         a single argument, so escape sequences are not converted
%       EXPECTED: three lines, as the '\n' in the message text intends
%       LINES: 54-56
%     - DEFECT: param does not hold the additional (solver-specific) parameters
%       SEVERITY: wrong-result
%       TRIGGER: [param, solverOnlyParams] = parseSolverParameters('LP', struct('Method', 2))
%       OBSERVED: param has only the COBRA fields of the LP type; Method is only in
%         solverOnlyParams
%       EXPECTED: per OUTPUTS, param is "The COBRA Toolbox specific parameters for this
%         problem type given the provided parameters, plus any additional parameters";
%         every caller in src/ (solveCobraLP, parseCobraVarargin, ...) takes the solver
%         parameters from solverOnlyParams, so the header is the likely error. Severity
%         audit 2026-11-15: param holds only the COBRA fields (lines 91-102) and the
%         additional parameters are only in solverOnlyParams
%       LINES: 91-102
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15; severity audit
%       2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testParseSolverParameters'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
