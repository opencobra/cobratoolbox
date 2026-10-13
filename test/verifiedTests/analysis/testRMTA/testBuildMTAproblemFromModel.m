% The COBRAToolbox: testBuildMTAproblemFromModel.m
%
% Purpose:
%     - buildMTAproblemFromModel builds the mixed-integer quadratic optimisation problem of the
%     metabolic transformation algorithm (stoichiometric constraints, change or no-change
%     constraints with binary variables, and the objective) without solving it.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/rMTA/buildMTAproblemFromModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testBuildMTAproblemFromModel'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons
tol = 1e-12;

% three reactions: r1 should go forward, r2 backward, r3 should stay unchanged
model.S = [1 -1 0; 0 1 -1];
model.mets = {'a'; 'b'};
model.rxns = {'r1'; 'r2'; 'r3'};
model.lb = [0; -5; 0];
model.ub = [10; 5; 10];
rxnFBS = [1; -1; 0];
vRef = [2; -1; 3];

%% size and variables of the problem with default alpha (0.66) and epsilon (0)

problem = buildMTAproblemFromModel(model, rxnFBS, vRef);
% 3 flux variables and 4 binary variables (a change and a no-change variable for each of
% the forward and the backward reaction), 6 constraints
assert(isequal(size(problem.A), [6 7]));
assert(strcmp(problem.vartype, 'CCCBBBB'));
assert(isequal(problem.idx_variables.v, 1:3));
assert(problem.idx_variables.y_plus_F == 4 && problem.idx_variables.y_minus_F == 5);
assert(problem.idx_variables.y_plus_B == 6 && problem.idx_variables.y_minus_B == 7);
assert(problem.osense == 1);
% flux bounds from the model, binary variables between 0 and 1
assert(isequal(problem.lb', [0 -5 0 0 0 0 0]));
assert(isequal(problem.ub', [10 5 10 1 1 1 1]));

%% constraints

problem = buildMTAproblemFromModel(model, rxnFBS, vRef);
assert(strcmp(problem.csense', 'EEGELE'));
assert(isequal(problem.b', [0 0 0 1 0 1]));
A = full(problem.A);
% stoichiometry
assert(isequal(A(1:2, 1:3), model.S) && all(all(A(1:2, 4:7) == 0)));
% change constraint of the forward reaction: v1 - (vRef1 + eps) y+ - lb1 y- >= 0
assert(isequal(A(3, :), [1 0 0 -2 0 0 0]));
% change / no change for the forward reaction: y+ + y- = 1
assert(isequal(A(4, :), [0 0 0 1 1 0 0]));
% backward reaction: v2 - (vRef2 - eps) y+ - ub2 y- <= 0
assert(isequal(A(5, :), [0 1 0 0 0 1 -5]));
% change / no change for the backward reaction
assert(isequal(A(6, :), [0 0 0 0 0 1 1]));

%% objective

problem = buildMTAproblemFromModel(model, rxnFBS, vRef);
% linear part: alpha / 2 on the no-change variables and -2 vRef (1 - alpha) on unchanged reactions
expectedC = [0 0 -2 * 3 * (1 - 0.66) 0 0.33 0 0.33];
assert(norm(problem.c' - expectedC) < tol);
% quadratic part: 2 (1 - alpha) on the unchanged reaction
F = full(problem.F);
assert(abs(F(3, 3) - 0.68) < tol && nnz(F) == 1);

%% alpha and epsilon

problem = buildMTAproblemFromModel(model, rxnFBS, vRef, 0.5, 0.1);
A = full(problem.A);
% the forward change constraint uses vRef1 + epsilon
assert(abs(A(3, 4) - (-2.1)) < tol);
% the backward change constraint uses vRef2 - epsilon
assert(abs(A(5, 6) - 1.1) < tol);
assert(abs(problem.c(5) - 0.25) < tol && abs(problem.c(3) - (-2 * 3 * 0.5)) < tol);

% a single epsilon value is used for every reaction
single = buildMTAproblemFromModel(model, rxnFBS, vRef, 0.5, 0.1);
vector = buildMTAproblemFromModel(model, rxnFBS, vRef, 0.5, 0.1 * ones(3, 1));
assert(isequal(single.A, vector.A));

% change the directory
cd(currentDir)
