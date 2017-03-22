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

% define global paths
global TOMLAB_PATH
global ILOG_CPLEX_PATH
global GUROBI_PATH
global CBT_MILP_SOLVER

% save the current path
currentDir = pwd;

% initialize the test
initTest(fileparts(which(mfilename)));

% test solver packages
solverPkgs = {'cplex_direct', 'ibm_cplex', 'tomlab_cplex', 'gurobi6', 'glpk'};

% set the tolerance
tol = 1e-8;

for k = 1:length(solverPkgs)

    % add the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        addpath(genpath(TOMLAB_PATH));
    elseif strcmp(solverPkgs{k}, 'cplex_direct') || strcmp(solverPkgs{k}, 'ibm_cplex')
        addpath(genpath(ILOG_CPLEX_PATH));
    elseif strcmp(solverPkgs{k}, 'gurobi6')
        addpath(genpath(GUROBI_PATH));
    end

    if (~verLessThan('matlab', '8.4') && strcmp(solverPkgs{k}, 'cplex_direct')) || (~verLessThan('matlab', '9') && strcmp(solverPkgs{k}, 'ibm_cplex'))
        fprintf(['\n IBM ILOG CPLEX - ', solverPkgs{k}, ' - is incompatible with this version of MATLAB, please downgrade or change solver\n'])
    else
        fprintf('   Running solveCobraLPCPLEX using %s ... ', solverPkgs{k});

        % change the COBRA solver (LP)
        solverOK = changeCobraSolver(solverPkgs{k});

        % set the global solver name
        CBT_MILP_SOLVER = solverPkgs{k};

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

    % remove the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        rmpath(genpath(TOMLAB_PATH));
    elseif strcmp(solverPkgs{k}, 'cplex_direct') || strcmp(solverPkgs{k}, 'ibm_cplex')
        rmpath(genpath(ILOG_CPLEX_PATH));
    elseif strcmp(solverPkgs{k}, 'gurobi6')
        rmpath(genpath(GUROBI_PATH));
    end
end

% remove the generated file
fullFileNamePath = [fileparts(which(mfilename)), filesep, 'MILPProblem.mat'];
if exist(fullFileNamePath, 'file') == 2
    system(['rm ', fullFileNamePath]);
end

% change the directory
cd(currentDir)
