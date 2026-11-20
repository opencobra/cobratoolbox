% The COBRAToolbox: testSparseLP_old.m
%
% Purpose:
%     - SparseLP_old(c, polyhedron, zeps, max_warm_start) solves the LP min c'*x over the
%       polyhedron (Aeq*x = beq, Ain*x <= bin, lb <= x <= ub) with Gurobi called directly, then
%       looks for the sparsest optimal solution: an l1-norm LP and warm-started concave (Theta
%       L0) approximations. The function is QUARANTINED (Constitution III-Defects, quarantine in
%       back-fill campaigns): it returns an infeasible zero vector for some LPs, and it errors
%       for an empty inequality block, for optimal solutions with no positive entry and for
%       initial solutions whose entries are all below zeps; no assertion about the function is
%       made.
%
% Function under test:
%     src/base/solvers/cardOpt/smoothConcave/SparseLP_old.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - hand-built LPs of one to four variables; the function calls the gurobi MATLAB
%     interface directly (not solveCobraLP), so a test would declare
%     prepareTest('requiredSolvers', {'gurobi'}).
%
% Coverage exemptions:
%     every line - SparseLP_old is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The zero vector is returned as the solution although it violates Aeq*x = beq
%       SEVERITY: wrong-result
%       TRIGGER: P = struct('Aeq', eye(2), 'beq', [0; 5], 'Ain', [0 0], 'bin', 0,
%         'lb', [-10; -10], 'ub', [10; 10]); [rt, ec, nw, z] = SparseLP_old([1; 0], P, 1e-8, 5)
%       OBSERVED: (R2025a, Gurobi, 2026-11-17) rt = 0, ec = 0, nw = 0, z = [0; 0]: the
%         zero-optimum shortcut tests max(Aeq*0 - beq) == 0, which holds when beq >= 0 has one
%         zero entry, instead of testing that every residual is zero
%       EXPECTED: z = [0; 5] (the only feasible point, objective 0), result_tab = [1, 1]
%       LINES: 49-50
%     - DEFECT: Empty inequality (or equality) block errors when the LP optimum is zero
%       SEVERITY: error
%       TRIGGER: P = struct('Aeq', [1 -1], 'beq', 0, 'Ain', [], 'bin', [], 'lb', [-10; -10],
%         'ub', [10; 10]); SparseLP_old([1; -1], P, 1e-8, 5) (findMinimalSetOfRxns passes
%         Ain = [], bin = []; Ain = zeros(0, 2), bin = zeros(0, 1) fails as well)
%       OBSERVED: (R2025a, Gurobi, 2026-11-17) "Incorrect dimensions for matrix multiplication"
%         at line 49 for Ain = []; "Operands to the logical AND (&&) and OR (||) operators must
%         be convertible to logical scalar values" at line 49 for the 0-by-2 Ain
%       EXPECTED: the empty block is ignored as in LPSolve, L1Solve and ThetaL0, which test
%         isempty, and z = [0; 0] is returned (zero is feasible and optimal)
%       LINES: 49
%     - DEFECT: Theta L0 iteration errors when the l1 solution has no positive entry
%       SEVERITY: error
%       TRIGGER: P = struct('Aeq', 1, 'beq', -1, 'Ain', 0, 'bin', 0, 'lb', -10, 'ub', 10);
%         SparseLP_old(0, P, 1e-8, 5)
%       OBSERVED: (R2025a, Gurobi, 2026-11-17) "Operands to the logical AND (&&) and OR (||)
%         operators must be convertible to logical scalar values" in ThetaL0 at line 149:
%         min(sol(sol > zero_precision)) is empty
%       EXPECTED: z = -1, result_tab = [1, 1] (the only feasible point); the smoothing
%         function theta1 uses abs(t), so negative entries are allowed
%       LINES: 142, 149
%     - DEFECT: Output z is not assigned when every entry of the LP solution is below zeps
%       SEVERITY: error
%       TRIGGER: P = struct('Aeq', 1, 'beq', 1e-12, 'Ain', 0, 'bin', 0, 'lb', -1, 'ub', 1);
%         [rt, ec, nw, z] = SparseLP_old(1, P, 1e-9, 5)
%       OBSERVED: (R2025a, Gurobi, 2026-11-17) "Output argument "z" (and possibly others) not
%         assigned a value in the execution with "SparseLP_old" function.": the optimum
%         1e-12 is not exactly 0, so the shortcut of line 49 is not taken, and the loop of line
%         71 does not run because init_result = 0
%       EXPECTED: z = 1e-12 (or the LP solution x0) with result_tab = [0, 0]
%       LINES: 71
%     - DEFECT: Diagnostic output is printed unconditionally
%       SEVERITY: cosmetic
%       TRIGGER: any call, e.g. the first trigger above
%       OBSERVED: (R2025a, Gurobi, 2026-11-17) "err_init = 0", "err_l1 = 0" and "Elapsed time
%         is ... seconds." are printed (statements without semicolon and toc)
%       EXPECTED: no console output, or output gated behind a printLevel argument
%       LINES: 43, 61, 87
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSparseLP_old'));
cd(fileDir);

% the function is quarantined: no requirement is declared and nothing calls it. When the
% defects are fixed, the test declares prepareTest('requiredSolvers', {'gurobi'})
prepareTest();

% change the directory
cd(currentDir)
