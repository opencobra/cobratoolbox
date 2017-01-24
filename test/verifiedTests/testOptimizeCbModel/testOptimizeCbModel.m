% The COBRAToolbox: testOptimizeCbModel.m
%
% Purpose:
%     - Tests the optimizeCbModel function
%
% Authors:
%     - CI integration: Laurent Heirendt
%
% Note:
%     - The solver libraries must be included separately

% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end-(length('initCobraToolbox.m') + 1));

% change the COBRA solver (LP)
solverOK = changeCobraSolver('tomlab_cplex');

cd([CBTDIR '/test/verifiedTests/testOptimizeCbModel']);

%load the model
load('iLC915.mat');

osenseStr = 'max';
allowLoops = true;

% Regular FBA
minNorm = 0;
FBAsolution = optimizeCbModel(model, osenseStr, minNorm, allowLoops);
assert(FBAsolution.stat == 1);
assert(norm(model.S * FBAsolution.x - model.b, 2) < 1e-6);

% Minimise the Taxicab Norm
minNorm = 'one';
L1solution = optimizeCbModel(model, osenseStr, minNorm, allowLoops);
assert(L1solution.stat == 1);
assert(norm(model.S * L1solution.x - model.b, 2) < 1e-6);
assert(abs(FBAsolution.f - L1solution.x'*model.c) < .01);

% Minimise the zero norm
minNorm = 'zero';
L0solution = optimizeCbModel(model, osenseStr, minNorm, allowLoops);
assert(L0solution.stat == 1);
assert(norm(model.S * L0solution.x - model.b, 2) < 1e-6);
assert(abs(FBAsolution.f - L0solution.x'*model.c) < .01);

% change the COBRA solver (QP)
solverOK = changeCobraSolver('tomlab_cplex', 'QP');

% Minimise the Euclidean Norm of internal fluxes
minNorm = rand(size(model.S, 2), 1);
L2solution = optimizeCbModel(model, osenseStr, minNorm, allowLoops);
assert(L2solution.stat == 1);
assert(norm(model.S * L2solution.x - model.b, 2) < 1e-6);
assert(abs(FBAsolution.f - L2solution.x'*model.c) < .01);

% change the directory
cd(CBTDIR)
