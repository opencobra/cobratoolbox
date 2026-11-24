% The COBRAToolbox: testDefineLinearConstraints.m
%
% Purpose:
%     - defineLinearConstraints(model, method) builds the constraint set A, b_L, b_U used to
%       fit or bound C13 flux vectors (A = model.N for method 1, model.S for method 2), after
%       iteratively giving an offset bound of 1e-4 to the reactions it marks as carrying flux in
%       their only direction. The function is QUARANTINED (Constitution III-Defects, quarantine
%       in back-fill campaigns): method 2 returns bounds that do not match the rows of A, and
%       the marked reactions depend on the feasible point the LP solver happens to return;
%       no assertion about the function is made. The second defect is reached by every call
%       with the default method 1: C13ConfidenceInterval and fitC13Data (2026-11-23).
%
% Function under test:
%     src/dataIntegration/fluxomics/defineLinearConstraints.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - solves LPs (hand-built S, lb, ub, N).
%
% Coverage exemptions:
%     every line - defineLinearConstraints is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Method 2 returns b_L and b_U that do not match the rows of A
%       SEVERITY: wrong-result
%       TRIGGER: lm.S = sparse([1 -1 0 0; 0 1 -1 -1]); lm.mets = {'A'; 'B'};
%         lm.lb = [1; 0; 0; 0]; lm.ub = [10; 10; 10; 10]; lm.N = null(full(lm.S));
%         [A, b_L, b_U] = defineLinearConstraints(lm, 2)
%       OBSERVED: (R2025a, 2026-11-23, gurobi) size(A) = [2 4], b_L = [1 1e-4], b_U = [10 10]:
%         line 163 tests the m rows of A = S but lines 164-165 index the n reaction bounds with
%         that m-element mask, which keeps the first m reaction bounds; with more metabolites
%         than reactions (S = sparse([1 -1; 1 -1; 1 -1]), lb = [1; 0], ub = [10; 10]) the call
%         stops with "The logical indices contain a true value outside of the array bounds."
%         (MATLAB:badsubscript) at line 164
%       EXPECTED: bounds that belong to A = S as the help text says ("lower bounds on the
%         constraints": one per row of S), or the n reaction bounds that fitC13Data's method-2
%         branch takes as variable bounds; not the bounds of the first m reactions
%       LINES: 157-158, 163-165
%     - DEFECT: The reactions given an offset bound depend on the LP solver's feasible point
%       SEVERITY: wrong-result
%       TRIGGER: lm as above; [A, b_L, b_U] = defineLinearConstraints(lm) (gurobi)
%       OBSERVED: (R2025a, 2026-11-23) b_L = [1 1e-4 0 1e-4]: reaction 4 gets the lower bound
%         1e-4 and reaction 3 does not, although both export B with identical columns and
%         bounds and neither is forced away from zero (v = [1 1 1 0] and [1 1 0 1] are both
%         feasible); in the first iteration nothing is marked, so lines 118-119 set the
%         objective to zero and lines 131-133 mark whatever reactions the returned feasible
%         point uses
%       EXPECTED: the offset only for reactions forced away from zero, as the help text says
%         (here reaction 2: b_L = [1 1e-4 0 0]); in any reading, reactions 3 and 4 treated
%         alike and a result that does not depend on the solver's choice of feasible point
%       LINES: 118-119, 131-133
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDefineLinearConstraints'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined and is not called, so
% none is listed; the call is the standard opening of a COBRA test and the place where a
% requirement would be added once the defects are fixed
prepareTest();

% change the directory
cd(currentDir)
