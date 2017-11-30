% The COBRAToolbox: testGeneMCS.m
%
% Purpose:
%     - Check the function of geneMCS using different solvers
%
% Authors:
%     - Luis V. Valcarcel 2017-11-17
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
cd(fileparts(which('testGeneMCS')));

% define the solver packages to be used to run this test
solverPkgs = {'ibm_cplex','gurobi'}; 

% Load Toy Example
model = readCbModel([CBTDIR filesep 'tutorials' filesep 'analysis' filesep 'gMCS' filesep 'gMCStoyExample.mat']);
  
% expected solution
true_gmcs = cell(3,1);
true_gmcs{1} = {'g5'}';
true_gmcs{2} = {'g1' 'g4'}';
true_gmcs{3} = {'g2' 'g3' 'g4'}';

for k = 1:length(solverPkgs)
    fprintf(' -- Running testGeneMCS using the solver interface: %s ... ', solverPkgs{k});

    solverLPOK = changeCobraSolver(solverPkgs{k}, 'MILP', 0);

    if solverLPOK
        % Eliminate G-matrix if it exist
        if exist([currentDir filesep 'G_toy_example_gMCS.mat'], 'file')
            delete G_toy_example_gMCS.mat
        end
        
        % Calculate GMCS
        [gmcs, gmcs_time] = calculateGeneMCS('toy_example_gMCS', model, 20);
               
        % Eliminante Nan -> no more gMCS
        gmcs = gmcs(cellfun('isclass', gmcs,'cell'));
        
        % Check if the solution obtained is the same as the expected
        % solution
        gmcsIsTrue = zeros(size(true_gmcs));
        for i = 1:numel(gmcs)
            for j=1:numel(true_gmcs)
                aux1 = gmcs{i};
                aux2 = true_gmcs{j};
                if isequal(aux1,aux2)
                    gmcsIsTrue(j) = gmcsIsTrue(j)+1;
                    break
                end
            end
        end
        assert(sum(~logical(gmcsIsTrue))==0);
    else
        warning('The test testGeneMCS cannot run using the solver interface: %s. The solver interface is not installed or not configured properly.\n', solverPkgs{k});
    end
    
    % Eliminate generated files
    if exist([currentDir filesep 'G_toy_example_gMCS.mat'], 'file')
        delete G_toy_example_gMCS.mat
    end
    if exist([currentDir filesep 'CobraMILPSolver.log'], 'file')
        delete CobraMILPSolver.log
    end
    if exist([currentDir filesep 'MILPProblem.mat'], 'file')
        delete MILPProblem.mat
    end

    % output a success message
    fprintf('Done.\n');
end

% change the directory
cd(currentDir)
