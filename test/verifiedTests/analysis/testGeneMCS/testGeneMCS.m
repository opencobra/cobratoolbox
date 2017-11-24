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

% Load Ecoli core
load([CBTDIR filesep 'test' filesep 'models' filesep 'mat' filesep 'ecoli_core_model.mat'], 'model');
% make all boundaries +1000, 0 or -1000
model.ub(:) = +1000;
model.lb(logical(model.rev)) = -1000;
model.lb(~logical(model.rev)) = 0;
  
% expected solution
true_gmcs = cell(16,1);
true_gmcs{1} = {'b2415' 'b4025'}';
true_gmcs{2} = {'b2415' 'b3919'}';
true_gmcs{3} = {'b2415' 'b2779'}';
true_gmcs{4} = {'b2416' 'b2779'}';
true_gmcs{5} = {'b1779' 'b2416'}';
true_gmcs{6} = {'b2987' 'b3493'}';
true_gmcs{7} = {'b2416' 'b3919'}';
true_gmcs{8} = {'b1779' 'b2415'}';
true_gmcs{9} = {'b2779' 'b2926'}';
true_gmcs{10} = {'b2416' 'b4025'}';
true_gmcs{11} = {'b2415' 'b2926'}';
true_gmcs{12} = {'b3236' 'b3956'}';
true_gmcs{13} = {'b2914' 'b4090'}';
true_gmcs{14} = {'b2465' 'b2935'}';
true_gmcs{15} = {'b1779' 'b2779'}';
true_gmcs{16} = {'b2416' 'b2926'}';


for k = 1:length(solverPkgs)
    fprintf(' -- Running <testFile> using the solver interface: %s ... ', solverPkgs{k});

    solverLPOK = changeCobraSolver(solverPkgs{k}, 'MILP', 0);

    if solverLPOK
        % Eliminate G-matrix if it exist
        if exist('G_ecoli_core_test.mat', 'file')
            delete G_ecoli_core_test.mat
        end
        
        % Calculate GMCS
        [gmcs, gmcs_time] = calculateGeneMCS('ecoli_core_test', model, 20);
               
        % Eliminante Nan -> no more gMCS
        gmcs = gmcs(cellfun('isclass', gmcs,'cell'));
        gmcs = gmcs(cellfun(@length, gmcs)<=2);
        
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

    % output a success message
    fprintf('Done.\n');
end

% change the directory
cd(currentDir)
