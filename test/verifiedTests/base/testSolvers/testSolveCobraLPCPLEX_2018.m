% The COBRAToolbox: testSolveCobraLPCPLEX_2018.m
%
% Purpose:
%     - solveCobraLPCPLEX_2018(LPProblem, printLevel, basisReuse, conflictResolve,
%       contFunctName, minNorm, interface) (declared inside the file as solveCobraLPCPLEX)
%       solves an LP, optionally with a Euclidean-norm regularisation, through the TOMLAB
%       CPLEX (default), IBM ILOG simple (cplexlp/cplexqp) or IBM ILOG complex (Cplex class)
%       interface. The function is QUARANTINED (Constitution III-Defects, quarantine in
%       back-fill campaigns): an LPProblem without the optional field csense stops with an
%       error, and the documented solution fields stat and solver are missing; no assertion
%       about the function is made.
%
% Function under test:
%     src/base/solvers/cplex/solveCobraLPCPLEX_2018.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - every solve needs TOMLAB CPLEX or IBM ILOG CPLEX; neither is installed on the
%     reference machine (gurobi is the only commercial solver), so a test would need
%     stand-in cplex/Cplex/cplexlp/cplexqp functions on a temporary path.
%
% Coverage exemptions:
%     every line - solveCobraLPCPLEX_2018 is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: An LPProblem without csense stops with an error
%       SEVERITY: error
%       TRIGGER: LP = struct('A', sparse([1 -1 0; 0 1 -1]), 'b', [0; 0], 'c', [0; 0; 1],
%         'lb', zeros(3, 1), 'ub', 10 * ones(3, 1), 'osense', -1);
%         solveCobraLPCPLEX_2018(LP)
%       OBSERVED: (R2025a, 2026-11-17; no CPLEX needed, the error comes before any solver
%         call) "Colon operands must be real scalars." (MATLAB:colon:operandsNotRealScalar)
%         at line 170: line 165 sets nMet = size(LPProblem.A), the vector [2 3], and
%         1:nMet is then evaluated
%       EXPECTED: INPUTS document .csense as optional; the code (comment "assuming equality
%         constraints") fills one 'E' per row of A and solves
%       LINES: 165, 170
%     - DEFECT: The documented solution fields solver (every interface) and stat (ILOGsimple) are missing
%       SEVERITY: wrong-result
%       TRIGGER: the LP above with LP.csense = ['E'; 'E']: solveCobraLPCPLEX_2018(LP) with
%         TOMLAB CPLEX, and solveCobraLPCPLEX_2018(LP, 0, 0, 0, [], 0, 'ILOGsimple') with
%         IBM ILOG CPLEX
%       OBSERVED: (R2025a, 2026-11-17, with stand-in cplex, Cplex, cplexlp and cplexoptimset
%         functions on a temporary path that solve with gurobi; CPLEX is not installed)
%         tomlab_cplex returns the fields full, dual, rcost, obj, nInfeas, sumInfeas,
%         origStat, time, stat (no solver); ILOGsimple returns obj, full, dual, rcost,
%         nInfeas, sumInfeas, origStat, time (no stat, no solver), obj = 10 in both. The
%         ILOGsimple and tomlab_cplex branches never set solver, and the status block
%         (line 519) runs only for 'tomlab_cplex'
%       EXPECTED: OUTPUT documents .stat (COBRA status 1/2/0/-1) and .solver for every solution
%       LINES: 363-421, 422-464, 519
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSolveCobraLPCPLEX_2018'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so nothing calls it
% and no solver is declared; the call is the standard opening of a COBRA test and the place
% where the requirements are added when the defects are fixed
prepareTest();

% change the directory
cd(currentDir)
