% The COBRAToolbox: <testNameOfSrcFile>.m
%
% Purpose:
%     - <provide a short description of the purpose of the test
%
% Authors:
%     - <major change>: <your name> <date>
%

% save the current path
currentDir = pwd;

% initialize the test
cd(fileparts(which(mfilename)));

% set the tolerance
tol = 1e-8;

% define the solver packages to be used to run this test
solverPkgs = {'tomlab_cplex', 'glpk', 'gurobi6'};

% load the model
load('modelFile.mat', 'model');
load('testData_functionToBeTested.mat');

%{
% This is only necessary for tests that test a function that runs in parallel.

% create a parallel pool
poolobj = gcp('nocreate'); % if no pool, do not create new one.
if isempty(poolobj)
    parpool(2); % launch 2 workers
end
%}

for k = 1:length(solverPkgs)
    fprintf(' -- Running <testFile> using the solver interface: %s ... ', solverPkgs{k});

    solverLPOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverLPOK
        % <your test goes here>
    end

    % output a success message
    fprintf('Done.\n');
end

% change the directory
cd(currentDir)
