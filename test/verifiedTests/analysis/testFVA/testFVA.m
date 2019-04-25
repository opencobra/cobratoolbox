% The COBRAToolbox: testFVA.m
%
% Purpose:
%     - testFVA tests the functionality of flux variability analysis
%       basically performs FVA and checks solution against known solution.
%
% Authors:
%     - Original file: Joseph Kang 04/27/09
%     - CI integration: Laurent Heirendt January 2017
%     - Vmin, Vmax test: Marouen Ben Guebila 24/02/17
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFVA'));
cd(fileDir);

% set the tolerance
tol = 1e-4;

% load the model
model = readCbModel('Ec_iJR904.mat');
load('testFVAData.mat');
minFlux = minFlux(:);
maxFlux = maxFlux(:);
loopToyModel = createToyModelForgapFind();

threadsForFVA = 1;
try
    if isempty(gcp('nocreate'))
        parpool(2);
    end
    solverPkgs = prepareTest('needsLP',true,'needsMILP',true,'needsQP',true,'needsMIQP',true, ...
        'useSolversIfAvailable',{'ibm_cplex'; 'gurobi'},...
        'excludeSolvers',{'dqqMinos','quadMinos'},...
        'minimalMatlabSolverVersion',8.0);
    threadsForFVA = [2, 1];
catch ME
    % test FVA without parrallel toolbox.
    % here, we can use dqq and quadMinos, because this is not parallel.
    solverPkgs = prepareTest('needsLP',true,'needsMILP',true,'needsQP',true,'needsMIQP',true, ...
        'useSolversIfAvailable',{'ibm_cplex'; 'gurobi'},'minimalMatlabSolverVersion',8.0);
end

printText = {'single-thread', 'parallel'};

% test both single-thread and parallel (if available) computation
for threads = threadsForFVA
    
    for k = 1:length(solverPkgs.LP)
        % change the COBRA solver (LP)
        solverLPOK = changeCobraSolver(solverPkgs.LP{k}, 'LP', 0);
        currentSolver = solverPkgs.LP{k};
        doQP = false;
        doMILP = false;
        if ismember(currentSolver,solverPkgs.QP)
            solverQPOK = changeCobraSolver(solverPkgs.LP{k}, 'QP', 0);
            doQP = true & solverQPOK;
        end
        if ismember(currentSolver,solverPkgs.MILP)
            solverMILPOK = changeCobraSolver(solverPkgs.LP{k}, 'MILP', 0);
            doMILP = true & solverMILPOK;
        end
        if ismember(currentSolver,solverPkgs.MIQP)
            solverMIQPOK = changeCobraSolver(solverPkgs.LP{k}, 'MIQP', 0);
            doMIQP = true & solverQPOK;
        end
        
        if solverLPOK
            fprintf('   Testing %s flux variability analysis using %s ... \n', printText{threads}, solverPkgs.LP{k});
            
            rxnNames = {'PGI', 'PFK', 'FBP', 'FBA', 'TPI', 'GAPD', 'PGK', 'PGM', 'ENO', 'PYK', 'PPS', ...
                'G6PDH2r', 'PGL', 'GND', 'RPI', 'RPE', 'TKT1', 'TKT2', 'TALA'};
            
            % launch the flux variability analysis
            fprintf('    Testing flux variability for the following reactions:\n');
            disp(rxnNames);
            [minFluxT, maxFluxT] = fluxVariability(model, 90, 'max', rxnNames, 'threads', threads);
            
            % retrieve the IDs of each reaction
            rxnID = findRxnIDs(model, rxnNames);
            
            % check if each flux value corresponds to a pre-calculated value
            for i = 1:size(rxnID)
                % test the components of the minFlux and maxFlux vectors
                assert(minFlux(i) - tol <= minFluxT(i))
                assert(minFluxT(i) <= minFlux(i) + tol)
                assert(maxFlux(i) - tol <= maxFluxT(i))
                assert(maxFluxT(i) <= maxFlux(i) + tol)
                
                maxMinusMin = maxFlux(i) - minFlux(i);
                maxTMinusMinT = maxFluxT(i) - minFluxT(i);
                assert(maxMinusMin - tol <= maxTMinusMinT)
                assert(maxTMinusMinT <= maxMinusMin + tol)
            end
            
            % test FVA for a single reaction inputted as string
            [minFluxT, maxFluxT] = fluxVariability(model, 90, 'max', rxnNames{1}, 'threads', threads);
            assert(abs(minFluxT - minFlux(1)) < tol)
            assert(abs(maxFluxT - maxFlux(1)) < tol)
            
            % test with or without heuristics
            for h = 1:3
                [minFluxT, maxFluxT] = fluxVariability(model, 90, 'max', rxnNames(1:5), 'heuristics', h, 'threads', threads);
                assert(max(abs(minFluxT - minFlux(1:5))) < tol)
                assert(max(abs(maxFluxT - maxFlux(1:5))) < tol)
            end
            
            % test parameter-value inputs
            rxnTest = rxnNames(1:5);
            inputToTest = {{90, 'max', 'rxnNameList', rxnTest}; ...
                {90, 'osenseStr', 'max', 'rxnNameList', rxnTest, 'allowLoops', 1}; ...
                {'optPercentage', 90, 'rxnNameList', rxnTest}; ...
                {'opt', 90, 'r', rxnTest}};  % test partial matching
            for j = 1:numel(inputToTest)
                [minFluxT, maxFluxT] = fluxVariability(model, inputToTest{j}{:});
                assert(max(abs(minFluxT - minFlux(1:5))) < tol)
                assert(max(abs(maxFluxT - maxFlux(1:5))) < tol)
            end
            
            % test ambiguous partial matching
            assert(verifyCobraFunctionError('fluxVariability', 'outputArgCount', 2, ...
                'input', {model, 'o', 90, 'rxnNameList', rxnTest}, ...
                'testMessage', '''o'' matches multiple parameter names: ''optPercentage'', ''osenseStr''. To avoid ambiguity, specify the complete name of the parameter.'))
            
            % test cobra parameters (saveInput gives easily detectable readouts)
            inputToTest = {{90, struct('saveInput', 'testFVAparamValue'), 'rxnNameList', rxnTest}; ...
                {90, 'rxnNameList', rxnTest, struct('saveInput', 'testFVAparamValue')}; ...
                {'optPercentage', 90, struct('saveInput', 'testFVAparamValue'), 'rxnNameList', rxnTest}};
            if exist('testFVAparamValue.mat', 'file')
                delete('testFVAparamValue.mat')
            end
            for j = 1:numel(inputToTest)
                [minFluxT, maxFluxT] = fluxVariability(model, inputToTest{j}{:});
                assert(max(abs(minFluxT - minFlux(1:5))) < tol)
                assert(max(abs(maxFluxT - maxFlux(1:5))) < tol)
                assert(logical(exist('testFVAparamValue.mat', 'file')))
                delete('testFVAparamValue.mat')
            end
            
            % test cobra + solver-specific parameters
            solverParams = {};
            if strcmp(currentSolver, 'gurobi')
                % 0 time allowed, infeasible
                solverParams = struct('saveInput', 'testFVAparamValue');
                solverParams.TimeLimit = 0;
                solverParams.BarIterLimit = 0;
                solverParams.IterationLimit = 0;
            elseif strcmp(currentSolver, 'ibm_cplex')
                % no iteration allowed, infeasible
                solverParams = struct('saveInput', 'testFVAparamValue');
                solverParams.simplex.limits.iterations = 0;
                solverParams.lpmethod = 1;
                solverParams.timelimit = 0;
                solverParams.barrier.limits.iteration = 0;
            end
            if ~isempty(solverParams)
                assert(verifyCobraFunctionError('fluxVariability', 'outputArgCount', 2, ...
                    'input', {model, 90,  solverParams, 'rxnNameList', rxnTest}, ...
                    'testMessage', 'The FVA could not be run because the model is infeasible or unbounded'))
                assert(logical(exist('testFVAparamValue.mat', 'file')))
                delete('testFVAparamValue.mat')
            end
            
            % all inputs in one single structure
            inputStruct = struct('opt', 90, 'saveInput', 'testFVAparamValue');
            inputStruct.rxn = rxnTest;
            [minFluxT, maxFluxT] = fluxVariability(model, inputStruct);
            assert(max(abs(minFluxT - minFlux(1:5))) < tol)
            assert(max(abs(maxFluxT - maxFlux(1:5))) < tol)
            assert(logical(exist('testFVAparamValue.mat', 'file')))
            delete('testFVAparamValue.mat')
            
            if strcmp(currentSolver, 'gurobi')
                inputStruct.TimeLimit = 0;
                inputStruct.BarIterLimit = 0;
                inputStruct.IterationLimit = 0;
            elseif strcmp(currentSolver, 'ibm_cplex')
                inputStruct.lpmethod = 1;
                inputStruct.simplex.limits.iterations = 0;
                inputStruct.timelimit = 0;
                inputStruct.barrier.limits.iteration = 0;
            end
            if strcmp(currentSolver, 'gurobi') || strcmp(currentSolver, 'ibm_cplex')
                assert(verifyCobraFunctionError('fluxVariability', 'outputArgCount', 2, ...
                    'input', {model, inputStruct}, ...
                    'testMessage', 'The FVA could not be run because the model is infeasible or unbounded'))
                assert(logical(exist('testFVAparamValue.mat', 'file')))
                delete('testFVAparamValue.mat')
            end
            
            % Vmin and Vmax test
            % Since the solution are dependant on solvers and cpus, the test will check the existence of nargout (weak test) over the 4 first reactions
            rxnNamesForV = {'PGI', 'PFK', 'FBP', 'FBA'};
            
            % testing default FVA with 2 printLevels
            for j = 0:1
                fprintf('    Testing flux variability with printLevel %s:\n', num2str(j));
                [minFluxT, maxFluxT, Vmin, Vmax] = fluxVariability(model, 90, 'max', rxnNamesForV, j, 1, 'threads', threads);
                assert(~isequal(Vmin, []));
                assert(~isequal(Vmax, []));
            end
            
            % testing various methods
            % only 2-norm needs QP, all others need LP only
            if doQP
                testMethods = {'FBA', '0-norm', '1-norm', '2-norm', 'minOrigSol'};
            else
                testMethods = {'FBA', '0-norm', '1-norm', 'minOrigSol'};
            end
            
            for j = 1:length(testMethods)
                fprintf('    Testing flux variability with test method %s:\n', testMethods{j});
                [minFluxT, maxFluxT, Vmin, Vmax] = fluxVariability(model, 90, 'max', rxnNamesForV, 1, 1, testMethods{j}, 'threads', threads);
                assert(~isequal(Vmin, []));
                assert(~isequal(Vmax, []));
                
                % this only works on cplex! all other solvers fail this
                % test.... However, we should test it on the CI for
                % functionality checks.
                
                if any(strcmp(currentSolver, {'gurobi', 'ibm_cplex'}))
                    constraintModel = addCOBRAConstraints(model, {'PFK'}, 1);
                    if strcmp(solverPkgs.QP{k},'ibm_cplex')
                        [minFluxT, maxFluxT, Vmin, Vmax] = fluxVariability(constraintModel, 90, 'max', rxnNamesForV, 1, 1, testMethods{j}, 'threads', threads);
                    else
                        % using automatic determination of LP method for solving QP seems to return wrong dual values...
                        % Fixing it to either primal simplex or barrier appears to work...
                        [minFluxT, maxFluxT, Vmin, Vmax] = fluxVariability(constraintModel, 90, 'max', rxnNamesForV, 1, 1, testMethods{j}, 'threads', threads, struct('Method', 0));
                    end
                    assert(maxFluxT(ismember(rxnNamesForV,'PFK')) - 1 <= tol);
                    assert(~isequal(Vmin, []));
                    assert(~isequal(Vmax, []));
                end
            end
            
            if doMILP
                % output a success message
                [minF, maxF] = fluxVariability(loopToyModel, 1, 'max', {'R1', 'R4'}, 0, 0);
                assert(abs(maxF(2)) < tol); %While R4 can carry a flux of 1000, it can't do so without a loop
                assert(abs(maxF(1) - 500) < tol); % Due to downstream reactions which have to carry "double" flux, this reaction can at most carry a flux of 500)
                assert(abs(minF(1) - 5) < tol); %We require at least a flux of 10 through the objective (1% of 1000). This requires a flux of 5 through R1.
                assert(abs(minF(2)) < tol); %We require at least a flux of 10 through the objective (1% of 1000). This requires a flux of 5 through R1.
                assert(verifyCobraFunctionError('fluxVariability', 'outputArgCount', 4, ...
                    'input', {loopToyModel, 1, 'max', {'R1', 'R4'}, 0, 0, 'minOrigSol', 'threads', threads}));
                
                %The below is an odd assertion, but since the minimal solution for reaction 1 is the minimal solution of the system,
                %it has to be the same as the maximal solution for the second tested
                %Reaction.
                % The assertion below works for minimizing 1-norm or 2-norm.
                % But simply 'FBA' does not necessarily guarantee minimal
                % solution because 'FBA' method does not do anything to
                % minimize the flux distribution
                % For 0-norm, it is also not necessarily minimal because the number of active
                % reaction being minimal does not imply the flux values are
                % Checked with the underlying MILPproblem in fluxVariability,
                % non-minimal solutions were also optimal to the MILPproblem
                % using 'FBA' or '0-norm'
                solverParams = struct();
                if strcmp(currentSolver, 'gurobi')
                    solverParams = struct('Presolve', 0);
                end
                [minF1, maxF1, minSols1, maxSols1] = fluxVariability(loopToyModel, 1, 'max', {'R1','R4'}, 0, 0, '1-norm', solverParams, 'threads', threads);
                fprintf('\n1-norm minimized flux distributions for minimizing R1, R4 and maximizing R1, R4:\n');
                disp([minSols1, maxSols1]);
                assert(max(abs(minF1 - [5; 0])) < tol)
                assert(max(abs(maxF1 - [500; 0])) < tol)
                
                % the corresponding norm-minimized solutions
                % min R1, max and min R4
                sol1 = [5; 5; 10; 0; 0; 0; 0; 0; 0; -5; 10];
                % max R1
                sol2 = [5; 5; 10; 0; 0; 0; 0; 0; 0; -5; 10] * 100;
                
                assert(sum(abs(minSols1(:, 1) - sol1)) < tol)
                assert(sum(abs(minSols1(:, 2) - sol1)) < tol)
                assert(sum(abs(maxSols1(:, 1) - sol2)) < tol)
                assert(sum(abs(maxSols1(:, 2) - sol1)) < tol)
                
                if doMIQP
                    [minF2, maxF2, minSols2, maxSols2] = fluxVariability(loopToyModel, 1, 'max', {'R1','R4'}, 0, 0, '2-norm', solverParams, 'threads', threads);
                    fprintf('\n2-norm minimized flux distributions for minimizing R1, R4 and maximizing R1, R4:\n');
                    disp([minSols2, maxSols2]);
                    assert(max(abs(minF2 - [5; 0])) < tol)
                    assert(max(abs(maxF2 - [500; 0])) < tol)
                    
                    % MIQP seems not to perfectly satisfy the optimality tolerance (1e-9).
                    % Check the % deviation of the 2-norm from the optimal solution
                    assert((norm(minSols2(:, 1), 2) ^ 2 / norm(sol1, 2) ^ 2) - 1 < tol)
                    assert((norm(minSols2(:, 2), 2) ^ 2 / norm(sol1, 2) ^ 2) - 1 < tol)
                    assert((norm(maxSols2(:, 1), 2) ^ 2 / norm(sol2, 2) ^ 2) - 1 < tol)
                    assert((norm(maxSols2(:, 2), 2) ^ 2 / norm(sol1, 2) ^ 2) - 1 < tol)
                end
            end
            fprintf('Done.\n');
        end
    end

end

            
% change the directory
cd(currentDir)