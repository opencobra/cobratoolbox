% The COBRAToolbox: testBuildCplexProblemFromCOBRAStruct.m
%
% Purpose:
%     - buildCplexProblemFromCOBRAStruct(Problem) builds a Cplex object from a COBRA LP, QP or
%       MILP structure: the left and right hand sides from b and csense (or b_L and b_U), bounds,
%       quadratic part (with a regularised diagonal), objective sense folded into the linear
%       objective, variable types and starting point. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): a Problem without the
%       documented optional csense stops with an error, and the documented b_L and b_U are never
%       read; no assertion about the function is made.
%
% Function under test:
%     src/base/solvers/cplex/buildCplexProblemFromCOBRAStruct.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - hand-built COBRA problems; the Cplex class of IBM ILOG CPLEX (not installed on the
%     reference machine; the defects were reproduced with a stand-in function Cplex that returns
%     a structure with fields Model and Start).
%
% Coverage exemptions:
%     every line - buildCplexProblemFromCOBRAStruct is quarantined for the defects below
%     (feature 20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A Problem without the documented optional csense stops with an error
%       SEVERITY: error
%       TRIGGER: Problem = struct('A', sparse([1 1; 1 -1]), 'b', [2; 0], 'lb', [0; 0], 'ub',
%         [10; 10], 'c', [1; 1], 'osense', -1); buildCplexProblemFromCOBRAStruct(Problem), with a
%         Cplex class (or a stand-in Cplex function) on the path
%       OBSERVED: (R2025a, stand-in Cplex, 2026-11-23) "Unrecognized field name "csense"." at
%         line 42, which reads Problem.csense before checking that the field exists
%       EXPECTED: the help text lists csense as optional with the default assumption that all
%         constraints are equalities, so lhs = rhs = b = [2; 0]
%       LINES: 42
%     - DEFECT: The documented b_L and b_U are never used
%       SEVERITY: wrong-result
%       TRIGGER: the Problem above with csense = '', b_L = [1; -inf] and b_U = [3; 0]
%       OBSERVED: (R2025a, stand-in Cplex, 2026-11-23) Model.lhs = [2; 0] and Model.rhs = [2; 0],
%         taken from b: line 53 tests isfield(Problem.csense, 'b_L'), which is false for any
%         char csense, instead of isfield(Problem, 'b_L')
%       EXPECTED: the help text says b_L and b_U are used if csense does not resolve the sides,
%         so Model.lhs = [1; -inf] and Model.rhs = [3; 0]
%       LINES: 53-56
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testBuildCplexProblemFromCOBRAStruct'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined and not called, so no
% solver is needed; the call is the standard opening of a COBRA test and the place where the
% requirements are added when the defects are fixed
prepareTest();

% change the directory
cd(currentDir)
