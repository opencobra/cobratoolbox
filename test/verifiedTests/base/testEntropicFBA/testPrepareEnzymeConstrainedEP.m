% The COBRAToolbox: testPrepareEnzymeConstrainedEP.m
%
% Purpose:
%     - prepareEnzymeConstrainedEP appends the enzyme variables of an enzyme-constrained model
%     (their columns in the mass balance and coupling rows, objective, bounds and entropy weights)
%     to an entropic flux balance problem after checking the dimensions.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/solvers/entropicFBA/prepareEnzymeConstrainedEP.m
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
fileDir = fileparts(which('testPrepareEnzymeConstrainedEP'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a problem with m = 2 metabolites, n = 3 reactions and 1 coupling row (rows: 2 + 3 + 1 = 6)
m = 2; n = 3; nCoupling = 1;
base.A = sparse(6, 3);
base.c = [1; 2; 3];
base.lb = [0; 0; 0];
base.ub = [10; 10; 10];
base.d = [0.5; 0.5; 0.5];

% an enzyme-constrained model with 2 enzyme variables
model.E = sparse([1 0; 0 2]);
model.D = sparse([3 4]);
model.evarlb = [0; 0];
model.evarub = [5; 6];
model.evarc = [7; 8];
% the same problem without coupling rows (5 rows)
noCouplingProblem = base;
noCouplingProblem.A = sparse(5, 3);

%% enzyme columns, objective, bounds and entropy weights are appended

[problem, nEvar] = prepareEnzymeConstrainedEP(base, model, m, n, nCoupling, 0.25);
assert(nEvar == 2);
assert(isequal(size(problem.A), [6 5]));
% metabolite rows 1-2 hold E and the coupling row 6 holds D; the flux rows 3-5 stay empty
assert(isequal(full(problem.A(1:2, 4:5)), [1 0; 0 2]));
assert(isequal(full(problem.A(3:5, 4:5)), zeros(3, 2)));
assert(isequal(full(problem.A(6, 4:5)), [3 4]));
assert(isequal(problem.c, [1; 2; 3; 7; 8]));
assert(isequal(problem.lb, [0; 0; 0; 0; 0]) && isequal(problem.ub, [10; 10; 10; 5; 6]));
assert(isequal(problem.d, [0.5; 0.5; 0.5; 0.25; 0.25]));

%% the entropy weight defaults to zero and can be given per variable

[problem, ~] = prepareEnzymeConstrainedEP(base, model, m, n, nCoupling);
assert(isequal(problem.d(4:5), [0; 0]));
[problem, ~] = prepareEnzymeConstrainedEP(base, model, m, n, nCoupling, []);
assert(isequal(problem.d(4:5), [0; 0]));
[problem, ~] = prepareEnzymeConstrainedEP(base, model, m, n, nCoupling, [0.1 0.2]);
assert(isequal(problem.d(4:5), [0.1; 0.2]));

%% no coupling rows

noCouplingModel = model;
noCouplingModel.D = [];
[problem, ~] = prepareEnzymeConstrainedEP(noCouplingProblem, noCouplingModel, m, n, 0);
assert(isequal(size(problem.A), [5 5]));

%% inconsistent dimensions are errors

% enzyme matrix with the wrong number of rows
bad = model;
bad.E = sparse(3, 2);
verifyCobraFunctionError('prepareEnzymeConstrainedEP', 'inputs', {base, bad, m, n, nCoupling}, ...
    'testMessage', 'model.E has 3 rows');
% coupling matrix with the wrong number of rows
bad = model;
bad.D = sparse(2, 2);
verifyCobraFunctionError('prepareEnzymeConstrainedEP', 'inputs', {base, bad, m, n, nCoupling}, ...
    'testMessage', 'model.D has 2 rows');
% coupling matrix with the wrong number of columns
bad = model;
bad.D = sparse(1, 3);
verifyCobraFunctionError('prepareEnzymeConstrainedEP', 'inputs', {base, bad, m, n, nCoupling}, ...
    'testMessage', 'model.D has 3 columns');
% nonzero coupling matrix without coupling rows
verifyCobraFunctionError('prepareEnzymeConstrainedEP', 'inputs', {noCouplingProblem, model, m, n, 0}, ...
    'testMessage', 'model.D is nonempty but the model has no coupling');
% bounds and objective of the wrong length
bad = model;
bad.evarlb = 0;
verifyCobraFunctionError('prepareEnzymeConstrainedEP', 'inputs', {base, bad, m, n, nCoupling}, ...
    'testMessage', 'evarlb/evarub/evarc must each have length nEvar');
% lower bound above upper bound
bad = model;
bad.evarlb = [6; 0];
verifyCobraFunctionError('prepareEnzymeConstrainedEP', 'inputs', {base, bad, m, n, nCoupling}, ...
    'testMessage', 'some model.evarlb exceed model.evarub');

% change the directory
cd(currentDir)
