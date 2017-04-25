% The COBRAToolbox: testDifferentLPSolvers.m
%
% Purpose:
%     - testDifferentLPSolvers tests the solveCobraLP function and its different methods
%
% Authors:
%     - CI integration: Laurent Heirendt, March 2017
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSolveCobraMILP'));
cd(fileDir);

% define solver packages
solverPkgs={'gurobi', 'pdco', 'glpk', 'mosek', 'ibm_cplex', 'cplex_direct', 'quadMinos', 'dqqMinos', 'tomlab_cplex', 'matlab'}; %

% load the ecoli_core_model
load([CBTDIR, filesep, 'test' filesep 'models' filesep 'ecoli_core_model.mat'], 'model');

% set the tolerance
tol = 1e-6;

% set pdco relative parameters
params.feasTol = 1e-12;
params.pdco_method = 2;
params.pdco_maxiter = 400;
params.pdco_xsize = 1e-1;
params.pdco_zsize = 1e-1;

% run LP with various solvers
[~, all_obj] = runLPvariousSolvers(model, solverPkgs, params);

% test here the output
assert(abs(min(all_obj) - max(all_obj)) < tol)

model.c = [200; 400];
model.A = [1/40, 1/60; 1/50, 1/50];
model.b = [1; 1];
model.lb = [0; 0];
model.ub = [1; 1];
model.osense = -1;
model.csense = ['L'; 'L'];

% set pdco relative parameters
params.feasTol = 1e-12;
params.pdco_method = 1;
params.pdco_maxiter = 400;
params.pdco_xsize = 1e-12;
params.pdco_zsize = 1e-12;

[~, all_obj] = runLPvariousSolvers(model, solverPkgs, params);
assert(abs(min(all_obj) - max(all_obj)) < tol)

% change the directory
cd(currentDir)
