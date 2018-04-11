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

% save original solve
global CBT_MILP_SOLVER;
orig_solver = CBT_MILP_SOLVER;

% test solver packages

global SOLVERS

% Do this test for all available MIQP solvers
UseIfAvailable = fieldnames(SOLVERS);  % We will simply use all available solvers that are MIQP solvers.
solverPkgs = prepareTest('needsMILP', true, 'useSolversIfAvailable', UseIfAvailable);

% set the tolerance
tol = 1e-8;

for k = 1:length(solverPkgs.MILP)
    fprintf('   Running solveCobraMILP using %s ... ', solverPkgs.MILP{k});

    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs.MILP{k}, 'MILP', 0);

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
        if strcmp(solverPkgs.MILP{k}, 'cplex_direct') || strcmp(solverPkgs.MILP{k}, 'tomlab_cplex')
            parameters.relMipGapTol = 1e-12;
            parameters.intTol = 1e-12;
            MILPsolution = solveCobraMILP(MILPproblem, parameters);
            % check if MILP can be solved without x0 supplied
            MILPsolution2 = solveCobraMILP(rmfield(MILPproblem, 'x0'), parameters);
        else
            MILPsolution = solveCobraMILP(MILPproblem);
            % check if MILP can be solved without x0 supplied
            MILPsolution2 = solveCobraMILP(rmfield(MILPproblem, 'x0'));
        end

        % check results with expected answer.
        assert(all(abs(MILPsolution.int - [0; 31; 46]) < tol))
        assert(abs(MILPsolution.obj - 554) < tol)
        assert(abs(MILPsolution2.obj - 554) < tol)

        if strcmp(solverPkgs.MILP{k}, 'ibm_cplex')
            % test IBM-Cplex-specific parameters. Solve with the below parameters changed
            cplexParams = struct();
            cplexParams.emphasis.mip = 0;  % MIP emphasis: balance optimality and integer feasibility
            cplexParams.mip.strategy.search = 2;  % MIP search method: dynamic search
            MILPsolution = solveCobraMILP(MILPproblem, cplexParams, 'logFile', 'testIBMcplexMILPparam1.log');
            % check expected answer
            assert(all(abs(MILPsolution.int - [0; 31; 46]) < tol))
            assert(abs(MILPsolution.obj - 554) < tol)

            % solve with the parameters changed to other values
            cplexParams.emphasis.mip = 1;  % MIP emphasis: integer feasibility.
            cplexParams.mip.strategy.search = 1;  % MIP search method: traditional branch-and-cut search
            MILPsolution = solveCobraMILP(MILPproblem, cplexParams, 'logFile', 'testIBMcplexMILPparam2.log');
            % check expected answer
            assert(all(abs(MILPsolution.int - [0; 31; 46]) < tol))
            assert(abs(MILPsolution.obj - 554) < tol)

            % compare the log files to see whether the parameter changes are implemented
            testLog = {''; ''};
            paramsInLog = cell(2, 1);
            % text that should be found during the first test
            paramsInLog{1} = {'balance optimality and feasibility'; 'dynamic search'};
            % text that should be found during the second test
            paramsInLog{2} = {'integer feasibility'; 'branch-and-cut'};
            for jTest = 1:2
                % read the log files
                f = fopen(['testIBMcplexMILPparam' num2str(jTest) '.log'], 'r');
                l = fgets(f);
                while ~isequal(l, -1)
                    testLog{jTest} = [testLog{jTest}, l];
                    l = fgets(f);
                end
                fclose(f);
                % check that the expected parameter values are set, and the unexpected are not set.
                for p = 1:2
                    assert(~isempty(strfind(testLog{jTest}, paramsInLog{jTest}{p})));
                    assert(isempty(strfind(testLog{jTest}, paramsInLog{setdiff(1:2, jTest)}{p})));
                end
                % delete the log files
                delete(['testIBMcplexMILPparam' num2str(jTest) '.log']);
            end
            fprintf('Test ibm_cplex output to command window ...\n')
            % solve without logToFile = 1
            diary test_ibm_cplex_output_to_console1.txt
            sol = solveCobraMILP(MILPproblem);
            diary off
            % read the diary, which should be empty
            f = fopen('test_ibm_cplex_output_to_console1.txt', 'r');
            l = fgets(f);
            assert(isequal(l, -1))
            fclose(f);
            delete('test_ibm_cplex_output_to_console1.txt')

            % solve wit logToFile = 1
            diary test_ibm_cplex_output_to_console2.txt
            sol = solveCobraMILP(MILPproblem, 'logFile', 1);
            diary off
            % read the diary, which should be non-empty
            f = fopen('test_ibm_cplex_output_to_console2.txt', 'r');
            l = fgets(f);
            line = 0;
            while ~isequal(l, -1)
                line = line + 1;
                l = fgets(f);
            end
            fclose(f);
            assert(line > 3)
            delete('test_ibm_cplex_output_to_console2.txt')
            fprintf('Test ibm_cplex output to command window ... Done\n')

        end

        if strcmp(solverPkgs.MILP{k}, 'gurobi')
            % check additional parameters for Gurobi
            % temporarily shut down warning
            warning_stat = warning;
            warning off
            MILPproblem = struct();
            MILPproblem.A = [speye(10, 20), -3 * rand(10, 30)];
            MILPproblem.b = zeros(10, 1);
            MILPproblem.c = ones(50, 1);
            MILPproblem.lb = [-1000 * ones(35, 1); zeros(15, 1)];
            MILPproblem.ub = [1000 * ones(35, 1); ones(15, 1)];
            MILPproblem.vartype = char(['C' * ones(1, 20), 'I' * ones(1, 15), 'B' * ones(1, 15)]);
            MILPproblem.csense = char('E' * ones(1, 10));
            MILPproblem.osense = -1;
            % test TimeLimit as a gurobi-specific parameter
            sol = solveCobraMILP(MILPproblem, struct('TimeLimit', 0));
            assert(strcmp(sol.origStat, 'TIME_LIMIT'))
            % restore previous warning state
            warning(warning_stat)

            % check user-supplied x0
            MILPproblem.A = rand(10, 20);
            MILPproblem.b = 1000 * ones(10, 1);
            MILPproblem.c = zeros(20, 1);
            MILPproblem.lb = zeros(20, 1);
            MILPproblem.ub = ones(20, 1);
            MILPproblem.vartype = char(['C' * ones(1, 10), 'B' * ones(1, 10)]);
            MILPproblem.csense = char('L' * ones(1, 10));

            % no objective function. The supplied should be the returned
            % (if not everything becomes zero after presolve)
            MILPproblem.x0 = zeros(20, 1);
            sol = solveCobraMILP(MILPproblem);
            assert(isequal(sol.full, MILPproblem.x0));

            MILPproblem.x0 = ones(20, 1);
            sol = solveCobraMILP(MILPproblem);
            assert(isequal(sol.full, MILPproblem.x0));

        end
    end

    % output a success message
    fprintf('Done.\n');
end

% test ibm_cplex output to command window
solverOK = changeCobraSolver('ibm_cplex', 'MILP', 0);
if solverOK
    fprintf('Test ibm_cplex output to command window ...\n')
    % solve without logToFile = 1
    diary test_ibm_cplex_output_to_console1.txt
    sol = solveCobraMILP(MILPproblem);
    diary off
    % read the diary, which should be empty
    f = fopen('test_ibm_cplex_output_to_console1.txt', 'r');
    l = fgets(f);
    assert(isequal(l, -1))
    fclose(f);
    delete('test_ibm_cplex_output_to_console1.txt')

    % solve wit logToFile = 1
    diary test_ibm_cplex_output_to_console2.txt
    sol = solveCobraMILP(MILPproblem, 'logFile', 1);
    diary off
    % read the diary, which should be non-empty
    f = fopen('test_ibm_cplex_output_to_console2.txt', 'r');
    l = fgets(f);
    line = 0;
    while ~isequal(l, -1)
        line = line + 1;
        l = fgets(f);
    end
    fclose(f);
    assert(line > 3)
    delete('test_ibm_cplex_output_to_console2.txt')
    fprintf('Test ibm_cplex output to command window ... Done\n')
end

% remove the generated file
fullFileNamePath = [fileparts(which(mfilename)), filesep, 'MILPProblem.mat'];
if exist(fullFileNamePath, 'file') == 2
    delete(fullFileNamePath);
end

% change back to the original solver
if ~isempty(orig_solver)
    changeCobraSolver(orig_solver, 'MILP', 0);
end

% change the directory
cd(currentDir)
