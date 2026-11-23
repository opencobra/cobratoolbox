% The COBRAToolbox: testOptimizeCardinality.m
%
% Purpose:
%     - optimizeCardinality(problem, param) minimises the zero norm of the variables x, maximises
%       that of y and minimises the one norm of z subject to linear constraints, by DC programming
%       on a capped-l1 approximation (a sequence of LPs whose approximation parameter theta
%       grows). The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): an LP solution with status 3 (solution exists, not proven optimal), which the
%       sub-problem accepts, ends the iterations with status -1; no assertion about the function
%       is made.
%
% Function under test:
%     src/base/solvers/cardOpt/sparseLP/optimizeCardinality.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - hand-built LPs and an LP solver (QP solver for the warm start 'l2').
%
% Coverage exemptions:
%     every line - optimizeCardinality is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: An LP status 3 ends the iterations with status -1 instead of proceeding
%       SEVERITY: wrong-result
%       TRIGGER: any problem for which solveCobraLP returns stat 3 for a sub-problem (for example
%         ibm_cplex codes 5, 6, 10-12, 21, 22); reproduced with a stand-in solveCobraLP that
%         returns stat 3: problem = struct('p', 2, 'q', 0, 'r', 0, 'A', [1 1], 'b', 1, 'csense',
%         'E', 'lb', [0; 0], 'ub', [2; 2], 'c', [0; 0]); rng(1); optimizeCardinality(problem)
%       OBSERVED: (R2025a, stand-in solveCobraLP, 2026-11-23) the sub-problem prints
%         "optimizeCardinality: LPsolution.stat == 3, proceeding but check inputs for numerical
%         instability" and keeps the solution, but line 906 reads "case 1 || 3", which is
%         "case true" and matches stat 1 only, so stat 3 falls to "otherwise": solution.stat = -1
%         and solution.x is the previous iterate (with gurobi, which never returns stat 3 for an
%         LP, the same problem returns stat 1)
%       EXPECTED: stat 3 is treated as stat 1, as the sub-problem (line 1159) and the final
%         assignment (line 1059, solution.stat == 1 || solution.stat == 3) intend: "case {1, 3}"
%       LINES: 906, 1037-1047
%     - DEFECT: The random warm start is not protected against infinite bounds
%       SEVERITY: cosmetic
%       TRIGGER: problem = struct('p', 2, 'q', 0, 'r', 0, 'A', [1 1], 'b', 1, 'csense', 'E',
%         'lb', [-inf; -inf], 'ub', [2; 2], 'c', [0; 0]); rng(1); optimizeCardinality(problem,
%         struct('printLevel', 1))
%       OBSERVED: (R2025a, gurobi, 2026-11-23) the starting point is -Inf where lb is -Inf: line
%         741 starts from lb2, not from the clipped minlb2 that lines 736-739 compute "to protect
%         against inf or -inf in bounds"; the first iteration prints ||dx|| = Inf and del_obj =
%         NaN; the result (stat 1, obj 1) is not affected
%       EXPECTED: a finite random starting point between minlb2 and maxub2
%       LINES: 741
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOptimizeCardinality'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined and not called, so no
% solver is needed; the call is the standard opening of a COBRA test and the place where the
% requirements (an LP and a QP solver) are added when the defect is fixed
prepareTest();

% change the directory
cd(currentDir)
