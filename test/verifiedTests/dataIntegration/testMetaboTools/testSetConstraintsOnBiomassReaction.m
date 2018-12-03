% The COBRA Toolbox: testSetConstraintsOnBiomassReaction
%
% Purpose:
%     - test setConstraintsOnBiomassReaction function
%
% Authors:
%     - Loic Marx, November 2018

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which(mfilename));
cd(fileDir);

% define inputs
model = getDistributedModel('ecoli_core_model.mat');
dT = 24;
tolerance = 20;
id = findRxnIDs(model, checkObjective(model));
of = model.rxns(id);

% calcule the reference data
ub = 0.0347;
lb = 0.0231;
tol = 1e-4;
model_refData = setConstraintsOnBiomassReaction(model, of, dT, tolerance);

% test if the upperbound and the lowerbound are the same as the references values
assert(norm(model_refData.ub(id) - ub) < tol);
assert(norm(model_refData.lb(id) - lb) < tol);

% change back to the current directory
cd(currentDir);