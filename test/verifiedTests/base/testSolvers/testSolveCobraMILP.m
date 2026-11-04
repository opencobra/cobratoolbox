% The COBRAToolbox: testSolveCobraMILP.m
%
% Purpose:
%     - testSolveCobraMILP tests the SolveCobraMILP function and its different methods
%     - Solver names that the interface refuses or writes to a file (mps, an unknown name) are
%       selected with validationLevel -1: no solver is imitated, the branch does not call one.
%       All other branches run with the real gurobi and glpk.
%
% Function under test:
%     src/base/solvers/solveCobraMILP.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - toy MILPs, gurobi and glpk.
%
% Coverage exemptions:
%     Line 134: unreachable, ~find(regexp(...)) is empty or false, so the condition is never true.
%     Lines 198-236: cplex_direct branch, solver not available.
%     Lines 245-292: gurobi_mex branch, solver not available.
%     Lines 297-318: ibm_cplex branch, solver not available.
%     Lines 351-352: defective input skipped, see the defect on an empty csense below.
%     Lines 398-463: tomlab_cplex branch, solver not available.
%     Line 504: unreachable, the nested function redirect has no caller.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: gurobi does not accept an empty csense
%       SEVERITY: error
%       TRIGGER: MILPproblem.csense empty, with the solver gurobi
%       OBSERVED: the default senses go to the local csense, while the problem passed to gurobi
%         keeps the empty field, so gurobi stops with Incorrect size(model.sense)
%       EXPECTED: equalities, as with glpk
%       LINES: 351-352, 375
%     - DEFECT: The legacy mps interface returns no output
%       SEVERITY: error
%       TRIGGER: solution = solveCobraMILP(problem) with the solver mps
%       OBSERVED: the function returns before solution is assigned, so the call stops with
%         Output argument solution not assigned, after the file was written
%       EXPECTED: an empty solution, as in solveCobraLP
%       LINES: 469
%
% Author:
%     - Original file: Joseph Kang 11/16/09
%     - CI integration: Laurent Heirendt, March 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
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

% the random problems must be reproducible
rng(0);

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
if SOLVERS.ibm_cplex.working && changeCobraSolver('ibm_cplex', 'MILP', 0)
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

%% Interface branches: solver state, inputs, the status of each available solver
coverageState = CobraSolverState.get();
coverageDir = tempname;
mkdir(coverageDir);
coverageError = [];
try
    coverageSolvers = prepareTest('needsMILP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
    isAvailable = @(solverName) any(strcmp(coverageSolvers.MILP, solverName));

    % the problem of the first section, with the optimum 554
    coverageMILP = struct('c', [20; 6; 8], 'A', [0.8, 0.2, 0.3; 0.4, 0.3, 0; 0.2, 0, 0.1], ...
        'b', [20; 10; 5], 'lb', [0; 0; 0], 'ub', [1000; 1000; 1000], 'osense', -1, ...
        'csense', ['L'; 'L'; 'L'], 'vartype', ['I'; 'I'; 'I']);

    %% an explicit solver state selects the solver of one call only
    if isAvailable('gurobi') && isAvailable('glpk')
        changeCobraSolver('gurobi', 'MILP', 0);
        explicitState = CobraSolverState.get();
        explicitState.solver.MILP = 'glpk';
        solution = solveCobraMILP(coverageMILP, 'cobraSolverState', explicitState);
        assert(strcmp(solution.solver, 'glpk') && abs(solution.obj - 554) < tol);
        assert(strcmp(CobraSolverState.getSolver('MILP'), 'gurobi'));
    end

    changeCobraSolver(coverageSolvers.MILP{1}, 'MILP', 0);

    %% the input is saved on request
    savedFile = fullfile(coverageDir, 'savedMILP.mat');
    solveCobraMILP(coverageMILP, 'saveInput', savedFile);
    savedInput = load(savedFile);
    assert(isequal(savedInput.MILPproblem.A, coverageMILP.A));

    %% a variable type that is not C, I or B is taken as continuous
    wrongType = coverageMILP;
    wrongType.vartype = ['X'; 'I'; 'I'];
    printedText = evalc('solution = solveCobraMILP(wrongType);');
    assert(contains(printedText, 'vartype not C or B or I:  Assuming C'));
    assert(solution.stat == 1 && solution.obj >= 554 - 1e-6 && numel(solution.int) == 2);

    %% the indices of the integer solution are handed over to the solution
    withIndices = coverageMILP;
    withIndices.intSolInd = [1; 2; 3];
    solution = solveCobraMILP(withIndices);
    assert(isequal(solution.intInd, [1; 2; 3]));

    %% solver names that the interface refuses without calling a solver
    refusedSolvers = {'', 'There is no solver for MILP problems available'; ...
                      'nonsense', 'Unknown solver: nonsense'};
    for i = 1:size(refusedSolvers, 1)
        changeCobraSolver(refusedSolvers{i, 1}, 'MILP', 0, -1);
        assertErrorContains(@() solveCobraMILP(coverageMILP), refusedSolvers{i, 2});
    end

    %% the legacy mps interface writes the problem to a file
    changeCobraSolver('mps', 'MILP', 0, -1);
    cd(coverageDir);
    solveCobraMILP(coverageMILP);
    assert(exist(fullfile(coverageDir, 'MILP.mps'), 'file') == 2);
    cd(fileDir);

    %% glpk: an empty csense means equalities
    noSense = struct('c', [1; 1; 0], 'A', [1, 1, 0], 'b', 2, 'lb', [0; 0; 0], 'ub', [5; 5; 5], ...
        'osense', 1, 'csense', '', 'vartype', ['I'; 'I'; 'C']);
    if isAvailable('glpk')
        changeCobraSolver('glpk', 'MILP', 0);
        solution = solveCobraMILP(noSense);
        assert(solution.stat == 1 && abs(solution.obj - 2) < 1e-6);
    end

    %% gurobi
    if isAvailable('gurobi')
        changeCobraSolver('gurobi', 'MILP', 0);

        % printing, a log file and an integrality tolerance above the lower limit of gurobi
        logFile = fullfile(coverageDir, 'gurobiMILP.log');
        solution = solveCobraMILP(coverageMILP, 'printLevel', 1, 'logFile', logFile, 'intTol', 1e-6);
        assert(solution.stat == 1 && abs(solution.obj - 554) < 1e-6);
        assert(exist(logFile, 'file') == 2);

        % minimisation: the costs are positive and x >= 0
        minimisation = coverageMILP;
        minimisation.osense = 1;
        solution = solveCobraMILP(minimisation);
        assert(solution.stat == 1 && abs(solution.obj) < 1e-6);

        % a time limit reached with an incumbent: the start point 0 fits this knapsack problem
        % with 200 binary variables and 60 rows, whose optimum takes far longer than the limit
        nVariables = 200;
        nRows = 60;
        hardA = randi([1, 50], nRows, nVariables);
        hardMILP = struct('c', randi([1, 100], nVariables, 1), 'A', sparse(hardA), ...
            'b', floor(sum(hardA, 2) / 2), 'lb', zeros(nVariables, 1), 'ub', ones(nVariables, 1), ...
            'osense', -1, 'csense', repmat('L', nRows, 1), 'vartype', repmat('B', nVariables, 1), ...
            'x0', zeros(nVariables, 1));
        solution = solveCobraMILP(hardMILP, struct('TimeLimit', 1, 'Threads', 1));
        assert(strcmp(solution.origStat, 'TIME_LIMIT') && solution.stat == 3);
        assert(contains(lastwarn, 'Time limit reached'));
        assert(numel(solution.full) == nVariables && all(hardMILP.A * solution.full <= hardMILP.b + 1e-6));
    end
catch coverageError
end
cd(fileDir);
CobraSolverState.restore(coverageState);
rmdir(coverageDir, 's');
if ~isempty(coverageError)
    rethrow(coverageError);
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

function assertErrorContains(functionHandle, expectedText)
    % The call has to stop with an error whose message contains expectedText.
    threw = false;
    try
        functionHandle();
    catch ME
        threw = true;
        assert(contains(ME.message, expectedText), 'unexpected error: %s', ME.message);
    end
    assert(threw, 'no error was thrown');
end

