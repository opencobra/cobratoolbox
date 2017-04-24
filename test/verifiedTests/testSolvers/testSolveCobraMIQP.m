% The COBRAToolbox: testSolveCobraMIQP.m
%
% Purpose:
%     - testSolveCobraMIQP tests the SolveCobraMIQP function and its different methods
%
% Author:
%     - CI integration: Laurent Heirendt, April 2017
%
% Note:
%       test is performed on objective as solution can vary between machines, solver version etc..

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSolveCobraMIQP'));
cd(fileDir);

% set the tolerance
tol = 1e-4;

% test solver packages
solverPkgs = {'gurobi'};

% MIQP Solver test: http://tomopt.com/docs/quickguide/quickguide006.php

% set up MIQP problem.
MIQPproblem.c    = [-6 0]';
MIQPproblem.F    = [4 -2;-2 4];
MIQPproblem.A    = [1 1];
MIQPproblem.b  = 1.9;
MIQPproblem.lb  = [0 0]';
MIQPproblem.ub  = [Inf Inf]';
MIQPproblem.osense = 1;
MIQPproblem.csense = 'L';
MIQPproblem.vartype = ['I'; 'C'];

for k = 1:length(solverPkgs)

    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs{k}, 'MIQP', 0);

    if solverOK

        fprintf('   Running testSolveCobraQP using %s ... ', solverPkgs{k});

        MIQPsolution = solveCobraMIQP(MIQPproblem, 'printLevel', 0);

        % Check MIQP results with expected answer.
        assert(abs(MIQPsolution.obj + 4.5) < tol & all(abs(MIQPsolution.full - [1;0.5]) < tol));

        % output a success message
        fprintf('Done.\n');
    end
end

% change the directory
cd(currentDir)
