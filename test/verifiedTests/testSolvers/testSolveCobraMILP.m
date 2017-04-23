% The COBRAToolbox: testSolveCobraMILP.m
%
% Purpose:
%     - testSolveCobraMILP tests the SolveCobraMILP function and its different methods
%
% Author:
%     - Original file: Joseph Kang 11/16/09
%     - CI integration: Laurent Heirendt, March 2017
%
% Note:
%       test is performed on objective as solution can vary between machines, solver version etc..

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSolveCobraMILP'));
cd(fileDir);

% test solver packages
solverPkgs = {'cplex_direct', 'ibm_cplex', 'tomlab_cplex', 'gurobi6', 'glpk'};

% set the tolerance
tol = 1e-8;

for k = 1:length(solverPkgs)
    fprintf('   Running solveCobraLPCPLEX using %s ... ', solverPkgs{k});

    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs{k}, 'MILP', 0);

    if solverOK
        % MILP Solver test: chemeng.ed.ac.uk/~jwp/MSO/section5/milp.html

        % set up MILP problem.
        MILPproblem.c = [20; 6; 8];
        MILPproblem.A = [0.8, 0.2, 0.3;
                         0.4, 0.3, 0;
                         0.2, 0, 0.1];
        MILPproblem.b = [20; 10; 5];
        MILPproblem.lb = [0; 0; 0];
        MILPproblem.ub = [1000; 1000; 1000];
        MILPproblem.osense = -1;
        MILPproblem.csense = ['L'; 'L'; 'L'];
        MILPproblem.vartype = ['I'; 'I'; 'I'];
        MILPproblem.x0 = [0, 0, 0];
        pass = 1;

        % solve MILP problem setting the relative MIP gap tolerance and integrality tolerance to 1e-12 using parameters structure.
        if strcmp(solverPkgs{k}, 'cplex_direct') || strcmp(solverPkgs{k}, 'tomlab_cplex')
            parameters.relMipGapTol = 1e-12;
            parameters.intTol = 1e-12;
            MILPsolution = solveCobraMILP(MILPproblem, parameters);
        else
            MILPsolution = solveCobraMILP(MILPproblem);
        end

        % check results with expected answer.
        assert(all(abs(MILPsolution.int - [0; 31; 46]) < tol))
        assert(abs(MILPsolution.obj - 554) < tol)
    end

    % output a success message
    fprintf('Done.\n');
end

% remove the generated file
fullFileNamePath = [fileparts(which(mfilename)), filesep, 'MILPProblem.mat'];
if exist(fullFileNamePath, 'file') == 2
    delete(fullFileNamePath);
end

% change the directory
cd(currentDir)
