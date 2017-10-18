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

        if strcmp(solverPkgs{k}, 'ibm_cplex')
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
        end
        
        % check additional parameters for Gurobi 
        if strcmp(solverPkgs{k}, 'gurobi6')
            sol = solveCobraMILP(MILPproblem, struct('TimeLimit',0));
            assert(strcmp(sol.origStat, 'TIME_LIMIT'))
            
            diary testGurobiMipStart.txt
            sol = solveCobraMILP(MILPproblem, 'printLevel', 1);
            diary off
            text = '';
            f = fopen('testGurobiMipStart.txt', 'r');
            l = fgets(f);
            while ~isequal(l, -1)
                text = [text, l];
                l = fgets(f);
            end
            fclose(f);
            assert(~isempty(strfind(text, 'Loaded MIP start')))
            delete('testGurobiMipStart.txt')
        end
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
