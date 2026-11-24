% The COBRAToolbox: testCheckSolFeas.m
%
% Purpose:
%     - checkSolFeas(LP, sol, maxInfeas, tol) returns the infeasibility of solution vectors for a
%       COBRA model or LP structure (or a CPLEX object) and, for a solution structure, the
%       structure with stat = 1 when it is feasible within tol. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): a solution structure
%       without a .full field is an error, and the documented second output (the solution
%       structure) is never returned; no assertion about the function is made.
%
% Function under test:
%     src/base/solvers/cplex/checkSolFeas.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use hand-built LP structures and solution
%     vectors (the CPLEX object branch needs the IBM ILOG CPLEX class).
%
% Coverage exemptions:
%     every line - checkSolFeas is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A solution structure with .x and no .full field is an error
%       SEVERITY: error
%       TRIGGER: LP.A = sparse([1 1 0; 0 1 -1]); LP.b = [2; 0]; LP.csense = ['E'; 'L'];
%         LP.lb = [0; 0; 0]; LP.ub = [10; 10; 10]; checkSolFeas(LP, struct('x', [1; 1; 1]))
%       OBSERVED: (R2025a, 2026-11-23) error "Unrecognized field name "full"." - the test for
%         .x reads sol.full; with sol.x and an empty sol.full the call returns NaN
%       EXPECTED: 0, the infeasibility of sol.x (the header: ".x - solution vector, read if
%         .full is absent")
%       LINES: 106-107
%     - DEFECT: The solution structure output is never returned and its stat is never set
%       SEVERITY: unusable-option
%       TRIGGER: the same LP; s.full = [1; 1; 1]; [infeas, sol] = checkSolFeas(LP, s)
%       OBSERVED: (R2025a, 2026-11-23) error "Output argument "varargout{2}" (and possibly
%         others) not assigned a value in the execution with "checkSolFeas" function." - sol is
%         overwritten by the vector sol.full, so isstruct(sol) is false and lines 154-160 (and
%         the tol input) are never reached; with one output the call returns 0
%       EXPECTED: infeas = 0 and sol = s with sol.stat = 1 (the header: "sol - solution
%         structure, returned only when the input sol was itself a structure. If infeas <= tol,
%         sol.stat = 1")
%       LINES: 105, 153-160
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCheckSolFeas'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
