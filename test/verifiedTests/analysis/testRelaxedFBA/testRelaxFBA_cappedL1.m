% The COBRAToolbox: testRelaxFBA_cappedL1.m
%
% Purpose:
%     - relaxFBA_cappedL1(model, param) finds a minimal set of relaxations of the steady-state
%       constraints and flux bounds that makes an FBA problem feasible, approximating the
%       zero-norm by a capped-L1 norm solved by DCA (a sequence of LPs). A test would check the
%       relaxations (S*v + r = b, lb - p <= v <= ub + q) on small infeasible models with an LP
%       solver. The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the documented option minLB is overwritten by its default, and omitting
%       the documented option toBeUnblockedReactions stops with an error (defects below), so
%       this file makes no assertion about the function.
%
% Function under test:
%     src/analysis/relaxedFBA/relaxFBA_cappedL1.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - a test would solve LPs on hand-built models with an LP solver.
%
% Coverage exemptions:
%     every line - relaxFBA_cappedL1 is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented option minLB is ignored and replaced by its default
%       SEVERITY: unusable-option
%       TRIGGER: relaxFBA_cappedL1(model, param) with param.minLB set and no param.maxLB, e.g.
%         model.S = sparse([1 -1]), b = 0, c = [0; 0], lb = [-5; 1], ub = [10; 10],
%         csense = 'E', param = struct('minLB', -1, 'printLevel', 2, 'nbMaxIteration', 1,
%         'toBeUnblockedReactions', zeros(2, 1)), gurobi
%       OBSERVED: (R2025a, 2026-11-23) the parameter display of line 151 shows minLB: -10: line 73
%         tests isfield(param, 'maxLB') (an option that is not documented or used) instead of
%         'minLB', so line 74 always overwrites minLB with min(-max(ub), min(lb)) = -10
%       EXPECTED: minLB: -1 - a given minLB is kept and bounds the relaxed lower bounds (line 431)
%       LINES: 73-74
%     - DEFECT: Omitting the documented option toBeUnblockedReactions stops with an error
%       SEVERITY: error
%       TRIGGER: relaxFBA_cappedL1(model, struct('printLevel', 0, 'nbMaxIteration', 2)) with the
%         model above (no toBeUnblockedReactions field), gurobi
%       OBSERVED: (R2025a, 2026-11-23) 'Unrecognized field name "toBeUnblockedReactions".' at
%         line 326 (relaxFBA_cappedL1_solveSubProblem): every other option gets a default in
%         lines 70-141, this one none
%       EXPECTED: a default of zeros(n, 1) (no reaction to unblock), as relaxedFBA uses
%       LINES: 326
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRelaxFBA_cappedL1'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file needs no
% solver, MATLAB toolbox or particular operating system; the call is the standard opening of
% a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
