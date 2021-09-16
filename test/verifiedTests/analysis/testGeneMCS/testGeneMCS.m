% The COBRAToolbox: testGeneMCS.m
%
% Purpose:
%     - Check the function of geneMCS using different solvers
%
% Authors:
%     - Luis V. Valcarcel 2017-11-17
%

global CBTDIR
requiredSolvers = {'ibm_cplex'};
prepareTest('requiredSolvers',requiredSolvers);

% save the current path
currentDir = pwd;

% initialize the test
testDir = fileparts(which('testGeneMCS'));
cd(testDir);

% define the solver packages to be used to run this test
solverPkgs = {'ibm_cplex', 'glpk', 'gurobi'};

% Load Toy Example
fileName = [CBTDIR filesep 'tutorials' filesep 'analysis' filesep 'gMCS' filesep 'gMCStoyExample.mat'];
if 0
    %TODO gMCStoyExample.mat needs to be made compatible with 
%     testGeneMCS.m:
%     Error using readCbModel (line 232)
%     There were no valid models in the mat file.
%     Please load the model manually via ' load /home/rfleming/work/sbgCloud/code/fork-cobratoolbox/tutorials/analysis/gMCS/gMCStoyExample.mat' and check it with verifyModel() to validate it.
%     Try using convertOldStyleModel() before verifyModel() to bring the model structure up to date.
%     Error in testGeneMCS (line 25)
%     model = readCbModel([CBTDIR filesep 'tutorials' filesep 'analysis' filesep 'gMCS' filesep 'gMCStoyExample.mat']);
    model = readCbModel(fileName);
else
    load(fileName)
end
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

        % Check errors when missing argument
        assert(verifyCobraFunctionError('calculateGeneMCS', 'inputs', {model, 20, 5}));
        assert(verifyCobraFunctionError('calculateGeneMCS', 'inputs', {'toy_example_gMCS', [], 20,5}));
        assert(verifyCobraFunctionError('calculateGeneMCS', 'inputs', {'toy_example_gMCS', model, [],5}));
        assert(verifyCobraFunctionError('calculateGeneMCS', 'inputs', {'toy_example_gMCS', model, 20}));

        % Calculate GMCS
        [gmcs, gmcs_time] = calculateGeneMCS('toy_example_gMCS', model, 20,5);

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
        %Now, test with a gene_set
        options = struct();
%         options.gene_set = model.genes([1 2 4 5 6]);
        [gmcs, gmcs_time] = calculateGeneMCS('toy_example_gMCS', model, 20, 5, 'gene_set', model.genes([1 2 4 5 6]));
            % Check the gMCS
        [IsCutSet, IsMinimal, geneNotMinimal] = checkGeneMCS(model, gmcs);
        assert(all(IsMinimal));
        assert(all(IsCutSet));
        %Assert that all correct solutions are there
        assert(all(cellfun(@(x) any(cellfun(@(y) isempty(setxor(x,y)),gmcs)), {{'g5'},{'g1','g4'}})))
        %and, that there are no surplus solutions
        assert(all(cellfun(@(x) any(cellfun(@(y) isempty(setxor(x,y)),{{'g5'},{'g1','g4'}})), gmcs)))
        %Finally test this for gMCS containing a specific knockout.
        options.KO = 'g5';
        [gmcs, gmcs_time] = calculateGeneMCS('toy_example_gMCS', model, 20, 5, options);
        assert(isequal(gmcs,{{'g5'}}));
        % Check the gMCS
        [IsCutSet, IsMinimal, geneNotMinimal] = checkGeneMCS(model, gmcs);
        assert(IsMinimal);
        assert(IsCutSet);
        %assert using one worker
        options = struct();
        options.numWorkers = 1;
        assert(~verifyCobraFunctionError('calculateGeneMCS', 'inputs', {'toy_example_gMCS', model, 20, 5, options}));
    else
        warning('The test testGeneMCS cannot run using the solver interface: %s. The solver interface is not installed or not configured properly.\n', solverPkgs{k});
    end

    % Eliminate generated files
    if exist([testDir filesep 'G_toy_example_gMCS.mat'], 'file')
        delete G_toy_example_gMCS.mat
    end
    if exist([testDir filesep 'CobraMILPSolver.log'], 'file')
        delete CobraMILPSolver.log
    end
    if exist([testDir filesep 'MILPProblem.mat'], 'file')
        delete MILPProblem.mat
    end
    if exist([testDir filesep 'tmp.mat'], 'file')
        delete tmp.mat
    end

    % output a success message
    fprintf('Done.\n');
end

% change the directory
cd(currentDir)
