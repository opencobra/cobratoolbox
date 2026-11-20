% The COBRAToolbox: testSolveCobraLPCPLEXcard.m
%
% Purpose:
%     - solveCobraLPCPLEXcard(LPProblem, printLevel, basisReuse, conflictResolve,
%       contFunctName, minNorm, theNorm) solves an LP with IBM ILOG CPLEX (Cplex class,
%       when cplexlp is on the path) or TOMLAB CPLEX, optionally minimising the Euclidean
%       norm ('two') or approximating the cardinality ('zero') of the solution in a second
%       solve. The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): an LPProblem without the optional field csense stops with an error, and
%       the IBM ILOG branch returns or optimises the objective with the wrong sign; no
%       assertion about the function is made.
%
% Function under test:
%     src/base/solvers/cplex/solveCobraLPCPLEXcard.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - every solve needs IBM ILOG CPLEX or TOMLAB CPLEX; neither is installed on the
%     reference machine (gurobi is the only commercial solver), so a test would need
%     stand-in Cplex/cplexlp/cplex functions on a temporary path.
%
% Coverage exemptions:
%     every line - solveCobraLPCPLEXcard is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: An LPProblem without csense stops with an error
%       SEVERITY: error
%       TRIGGER: LP = struct('A', sparse([1 -1 0; 0 1 -1]), 'b', [0; 0], 'c', [0; 0; 1],
%         'lb', zeros(3, 1), 'ub', 10 * ones(3, 1), 'osense', -1);
%         solveCobraLPCPLEXcard(LP)
%       OBSERVED: (R2025a, 2026-11-17; no CPLEX needed, the error comes before any solver
%         call) "Colon operands must be real scalars." (MATLAB:colon:operandsNotRealScalar)
%         at line 160: line 155 sets nMet = size(LPProblem.A), the vector [2 3], and
%         1:nMet is then evaluated
%       EXPECTED: INPUTS document .csense as optional; the code (comment "assuming equality
%         constraints") fills one 'E' per row of A and solves
%       LINES: 155, 160
%     - DEFECT: The IBM ILOG branch returns the objective of a maximisation with the wrong sign
%       SEVERITY: wrong-result
%       TRIGGER: the LP above with LP.csense = ['E'; 'E'], IBM ILOG CPLEX (cplexlp) on the
%         path: solveCobraLPCPLEXcard(LP)
%       OBSERVED: (R2025a, 2026-11-17, with stand-in Cplex and cplexlp functions on a
%         temporary path that solve the Cplex model with gurobi; CPLEX is not installed)
%         solution.obj = -10 with solution.full = [10; 10; 10] and stat 1. Line 331 sets the
%         Cplex objective to -c = LPProblem.c with sense 'maximize' (line 327), so objval is
%         LPProblem.c'*x = 10, and line 362 multiplies it by osense = -1
%       EXPECTED: solution.obj = LPProblem.c'*solution.full = 10, as the TOMLAB branch returns
%         (f_k*osense, line 702)
%       LINES: 331, 362
%     - DEFECT: theNorm 'zero' optimises the original objective in the wrong direction or reports it with the wrong sign
%       SEVERITY: wrong-result
%       TRIGGER: the LP above with LP.csense = ['E'; 'E'] and IBM ILOG CPLEX on the path:
%         solveCobraLPCPLEXcard(LP, 0, 0, 0, [], 1, 'zero') (maximisation); the same with
%         minNorm = -1; and with LP.osense = 1, LP.c = [0; 0; -1] (minimisation)
%       OBSERVED: (R2025a, 2026-11-17, same stand-in) maximisation: solution.obj = 0 for
%         minNorm 1 and -1, the minimum of v3 instead of the maximum 10: line 402 passes
%         c = osense*LPProblem.c with the sense 'maximize' of line 397, so the first solve
%         minimises v3 and line 536 (473) bounds v3 below by 0 instead of 10*beta;
%         minimisation: solution.obj = 10 although LPProblem.c'*solution.full = -10 (line 587
%         negates x'*c)
%       EXPECTED: the first solve optimises LPProblem.c in the sense osense (as the 'two'
%         branch does), the second solve keeps that optimum, and solution.obj is
%         LPProblem.c'*x of the optimum
%       LINES: 394-398, 402, 515, 587
%     - DEFECT: The cardinality solve prints the solution structure and a minimum-Euclidean-norm note
%       SEVERITY: cosmetic
%       TRIGGER: solveCobraLPCPLEXcard(LP, 0, 0, 0, [], 1, 'zero') with IBM ILOG CPLEX on the
%         path (printLevel 0)
%       OBSERVED: (R2025a, 2026-11-17, same stand-in) "solution = struct with fields: obj: 0"
%         is printed (line 433 has no semicolon), followed by "This objective corresponds to
%         a flux with minimum Euclidean norm." (lines 806-809 print it for every nonzero
%         minNorm, also for theNorm 'zero' and printLevel 0)
%       EXPECTED: console output gated by printLevel; no Euclidean-norm note for 'zero'
%       LINES: 433, 806-809
%     - DEFECT: With osense = 1 the IBM ILOG branch optimises in the wrong direction
%       SEVERITY: wrong-result
%       TRIGGER: LP = struct('A', sparse([1 -1 0; 0 1 -1]), 'b', [0; 0], 'c', [0; 0; 1],
%         'lb', zeros(3, 1), 'ub', 10 * ones(3, 1), 'osense', 1, 'csense', ['E'; 'E']);
%         solveCobraLPCPLEXcard(LP) with IBM ILOG CPLEX (cplexlp) on the path (theNorm 'two',
%         the default; also with minNorm ~= 0); the same with LP.c = [0; 0; -1]
%       OBSERVED: (R2025a, 2026-11-17, with stand-in Cplex and cplexlp on a temporary path that
%         solve the Cplex model with gurobi; CPLEX is not installed) solution.full = [10; 10;
%         10], solution.obj = -10, stat 1, where solveCobraLP with gurobi returns the minimum
%         full = [0; 0; 0], obj 0; with LP.c = [0; 0; -1] it returns full = [0; 0; 0], obj 0
%         instead of the minimum -10. Line 182 sets c = osense*LPProblem.c = LPProblem.c and
%         line 331 passes -c with the sense 'minimize' of line 325, so -LPProblem.c is minimised
%         and line 362 reports -LPProblem.c'*x
%       EXPECTED: the minimum of LPProblem.c'*x (obj 0 at x = 0; obj -10 at x = [10; 10; 10]
%         for c = [0; 0; -1]) with solution.obj = LPProblem.c'*solution.full
%       LINES: 324-331, 362
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSolveCobraLPCPLEXcard'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so nothing calls it
% and no solver is declared; the call is the standard opening of a COBRA test and the place
% where the requirements are added when the defects are fixed
prepareTest();

% change the directory
cd(currentDir)
