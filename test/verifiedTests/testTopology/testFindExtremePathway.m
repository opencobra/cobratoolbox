% The COBRAToolbox: testFindExtremePathway.m
%
% Purpose:
%     - testFindExtremePathway tests the functionality of findExtremePathway.
%
% Authors:
%     - Sylvain Arreckx March 2017
%
% Test problem from 
%     "System Modeling in Cellular Biology: From Concepts to Nuts and Bolts", 
%     section "Stoichiometric and Constraint Based Modeling", MIT Press

% define global paths
global path_GUROBI
addpath(genpath(path_GUROBI));

% save the current path
currentDir = pwd;

% initialize the test
initTest(fileparts(which(mfilename)));

model.S = [1, 0, 0, 0,-1,-1,-1, 0, 0, 0
           0, 1, 0, 0, 1, 0, 0,-1,-1, 0
           0, 0, 0, 0, 0, 1, 0, 1, 0,-1
           0, 0, 0, 0, 0, 0, 1, 0, 0,-1
           0, 0, 0,-1, 0, 0, 0, 0, 0, 1
           0, 0,-1, 0, 0, 0, 0, 0, 1, 1];
model.revRxns = [0 1 0 0 0 0 0 1 0 0];

model.stoich = model.S;
model.reversibilities = model.revRxns;

solverOK = changeCobraSolver('gurobi6', 'LP');
obj = [0.5985; 0.4709; 0.6959; 0.6999; 0.6385; 0.0336; 0.0688; 0.3196; 0.5309; 0.6544; 0.4076; 0.8200];

refV = [0.2500; 0; 0.2500; 0; 0.2500; 0; 0; 0; 0.2500; 0];
tol = 1e-14;

v = findExtremePathway(model); 
assert(all(abs(model.S * v) < tol))

% testing findExtremePathway with different arguments
model = rmfield(model, 'revRxns');
try
    v = findExtremePathway(model, obj); 
catch ME
    assert(length(ME.message) > 0)
end

model.ub = [-1,  1, -1, -1, -1, -1, -1,  1, -1, -1];
model.lb = [ 0, -1,  0,  0,  0,  0,  0, -1,  0,  0];

v = findExtremePathway(model, obj); 
assert(all(refV == v))
assert(all(model.S * v == zeros(size(model.S, 1), 1)))

model2.S = [-1,  0,  1;
             1, -1,  0;
             0,  1, -1];

[x, output] = findExtremePool(model2);

assert(all(abs(model2.S * x) < tol))

rmpath(genpath(path_GUROBI));

% delete generated files
delete('*.ine');
delete('*.ext');

% change the directory
cd(currentDir)
