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

% model and data for loopless FVA
loopToyModel = createToyModelForLooplessFVA();
llfvaOptPercent = 90;
% expected results [min | max]
toyfvaResultsRef = [...
    0, 1; ...
    0, 0.5; ...
    0, 1000; ...
    -99.91, 0.1; ...
    -99.91, 0.1; ...
    -1, -0.9; ...
    -1, 0; ...
    -1, 0; ...
    0.9, 1];
toyllfvaResultsRef = [ ...
    0, 1; ...
    0, 0.5; ...
    0, 1; ...
    0, 0.1; ...
    0, 0.1; ...
    -1, -0.9; ...
    -1, 0; ...
    -1, 0; ...
    0.9, 1];

threadsForFVA = 1;
try
    if isempty(gcp('nocreate'))
        parpool(2);
    end
    solverPkgs = prepareTest('needsLP',true,'needsMILP',true,'needsQP',true,'needsMIQP',true, ...
        'useSolversIfAvailable',{'ibm_cplex','gurobi'},...
        'excludeSolvers',{'dqqMinos','quadMinos','matlab','pdco'},...
        'minimalMatlabSolverVersion',8.0);
    threadsForFVA = [2, 1];
catch ME
    % test FVA without parrallel toolbox.
    % here, we can use dqq and quadMinos, because this is not parallel.
 solverPkgs = prepareTest('needsLP',true,'needsMILP',true,'needsQP',true,'needsMIQP',true, ...
        'useSolversIfAvailable',{'gurobi'; 'ibm_cplex'; 'mosek'},...
        'excludeSolvers',{'dqqMinos','quadMinos', 'matlab','pdco'},...
        'minimalMatlabSolverVersion',8.0);
 end

printText = {'single-thread', 'parallel'};

% test both single-thread and parallel (if available) computation
for k = 1:length(solverPkgs.LP)
    % change the COBRA solver (LP)
    solverLPOK = changeCobraSolver(solverPkgs.LP{k}, 'LP', 0);
    currentSolver = solverPkgs.LP{k};
    doQP = false;
    doMILP = false;
    doMIQP = false;
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
    for threads = threadsForFVA
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
            for i = 1:numel(rxnID)
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
            rxnTest = rxnNames(1);
            inputToTest = {{90, 'max', 'rxnNameList', rxnTest}; ...
                {90, 'osenseStr', 'max', 'rxnNameList', rxnTest, 'allowLoops', 1}; ...
                {'optPercentage', 90, 'rxnNameList', rxnTest}; ...
                {'opt', 90, 'r', rxnTest}};  % test partial matching
            for j = 1:numel(inputToTest)
                [minFluxT, maxFluxT] = fluxVariability(model, inputToTest{j}{:});
                assert(max(abs(minFluxT - minFlux(1))) < tol)
                assert(max(abs(maxFluxT - maxFlux(1))) < tol)
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
                assert(max(abs(minFluxT - minFlux(1))) < tol)
                assert(max(abs(maxFluxT - maxFlux(1))) < tol)
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
            assert(max(abs(minFluxT - minFlux(1))) < tol)
            assert(max(abs(maxFluxT - maxFlux(1))) < tol)
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
            if ~strcmp(currentSolver, 'mosek')
                % Since the solution are dependant on solvers and cpus, the test will check the existence of nargout (weak test) over the 4 first reactions
                rxnNamesForV = {'PGI', 'PFK', 'FBP', 'FBA'};

                % testing default FVA with 2 printLevels
                for j = 0:1
                    fprintf('    Testing flux variability with printLevel %s:\n', num2str(j));
                    [minFluxT, maxFluxT, Vmin, Vmax] = fluxVariability(model, 90, 'max', rxnNamesForV, j, 0, 'threads', threads);
                    assert(~isequal(Vmin, []));
                    assert(~isequal(Vmax, []));
                end
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
                if ~strcmp(currentSolver, 'mosek')
                    [minFluxT, maxFluxT, Vmin, Vmax] = fluxVariability(model, 90, 'max', rxnNamesForV, 1, 1, testMethods{j}, 'threads', threads);
                    assert(~isequal(Vmin, []));
                    assert(~isequal(Vmax, []));
                end

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

            % test for loopless FVA
            if doMILP &&  any(strcmp(currentSolver, {'gurobi', 'ibm_cplex'}))
                % test FVA allowing loops first
                [minF, maxF] = fluxVariability(loopToyModel, 'opt', llfvaOptPercent);
                assert(abs(max(minF - toyfvaResultsRef(:, 1))) < tol)
                assert(abs(max(maxF - toyfvaResultsRef(:, 2))) < tol)

                % verify that if flux distributions are required outputs,
                % method 'minOrigSol` returns error with allowLoops not on
                assert(verifyCobraFunctionError('fluxVariability', 'outputArgCount', 3, ...
                    'input', {loopToyModel, llfvaOptPercent, 'max', [], 0, 0, 'minOrigSol', 'threads', threads}));
                assert(verifyCobraFunctionError('fluxVariability', 'outputArgCount', 4, ...
                    'input', {loopToyModel, llfvaOptPercent, 'max', [], 0, 0, 'minOrigSol', 'threads', threads}));

                solverParams = struct();
                if strcmp(currentSolver, 'gurobi')
                    solverParams = struct('Presolve', 0);
                end
               % check that different methods for loopless FVA give the same results
               if 0
                   %fastSNP not giving the same result as the rest TODO -
                   %why?
                   
%                    Reduce complexity by nullspace preprocessing and implementing localized loopless constraints (LLCs)
%                    Unable to find EFMs. Use connections from nullspace to implement LLCs
%                    Reactions in internal nullspace can be divided into 1 connected components.
%                    No	      Name	      Min	      Max
%                    2	        R2	    0.000	    0.500
%                    1	        R1	    0.000	    1.000
%                    4	        R4	    0.000	    0.100
%                    3	        R3	    0.000	    1.000
%                    9	      Ex_E	    0.900	    1.000
%                    8	      Ex_C	   -1.000	    0.000
%                    6	      Ex_A	   -1.000	   -0.900
%                    5	        R5	    0.000	    0.100
%                    7	      Ex_B	   -1.000	    0.000
%                    Reduce complexity by nullspace preprocessing (Fast-SNP)
%                    Not enough input parameters supported
%                    No	      Name	      Min	      Max
%                    1	        R1	    0.000	    1.000
%                    4	        R4	  -99.910	    0.100
%                    3	        R3	    0.000	 1000.000
%                    7	      Ex_B	   -1.000	    0.000
%                    2	        R2	    0.000	    0.500
%                    6	      Ex_A	   -1.000	   -0.900
%                    5	        R5	  -99.910	    0.100
%                    9	      Ex_E	    0.900	    1.000
%                    8	      Ex_C	   -1.000	    0.000
   
                    method = {'original', 'LLC-NS', 'LLC-EFM','fastSNP'};
               else
                    method = {'original', 'LLC-NS', 'LLC-EFM'};
               end
               t = zeros(numel(method), 1);
               minFluxT=zeros(size(loopToyModel.S,2),numel(method));
               maxFluxT=zeros(size(loopToyModel.S,2),numel(method));
               for j = 1:numel(method)
                   tic;
                   %    [minFlux, maxFlux] = fluxVariability(model, optPercentage, osenseStr, rxnNameList, printLevel, allowLoops)
                   [minFluxT(:,j), maxFluxT(:,j)] = fluxVariability(loopToyModel, llfvaOptPercent, 'max', [], 2, method{j}, 'threads', threads);
                   t(j) = toc;
                   assert(max(abs(minFluxT(:,j) - toyllfvaResultsRef(:, 1))) < tol)
                   assert(max(abs(maxFluxT(:,j) - toyllfvaResultsRef(:, 2))) < tol)
               end
               fprintf('\n\n');
               for j = 1:numel(method)
                   fprintf('%s method takes %.2f sec to finish loopless FVA for %d reactions\n', method{j}, t(j), numel(rxnTest));
               end

               if doQP && doMIQP
                   % return flux distributions

                   % test for one reaction in loops and one not in loops
                   rxnTestForFluxes = [1; 3];

                   method = {'original', 'fastSNP', 'LLC-NS', 'LLC-EFM'};
                   minNormMethod = {'FBA', '0-norm', '1-norm', '2-norm'};

                   solverParams = repmat({struct('intTol', 1e-9, 'feasTol', 1e-8)}, numel(minNormMethod), 1);
                   % minimizing 0-norm with presolve on may be inaccurate
                   switch currentSolver
                       case 'gurobi'
                           solverParams{2}.Presolve = 0;
                       case 'ibm_cplex'
                           solverParams{2}.presolvenode = 0;
                   end

                   rxnTest = 'Ex_E';
                   rxnTestId = findRxnIDs(loopToyModel, rxnTest);
                   [minFluxT, maxFluxT] = deal(zeros(numel(method), numel(minNormMethod)));
                   [Vmin, Vmax] = deal(zeros(numel(loopToyModel.rxns), numel(method), numel(minNormMethod)));

                   for j = 1:numel(method)
                       for j2 = 1:numel(minNormMethod)
                            tic;
                            [minFluxT(j, j2), maxFluxT(j, j2), Vmin(:, j, j2), Vmax(:, j, j2)] = ...
                                fluxVariability(loopToyModel, llfvaOptPercent, 'max', rxnTest, 2, method{j}, minNormMethod{j2}, solverParams{j2}, 'threads', threads);
                            t(j, j2) = toc;
                            assert(abs(minFluxT(j, j2)  - toyllfvaResultsRef(rxnTestId, 1)) < tol)
                            assert(abs(maxFluxT(j, j2)  - toyllfvaResultsRef(rxnTestId, 2)) < tol)
                            if j2 == 2 && j <= 2
                                % min 0-norm. Use R3 instead of R4 + R5
                                % But only necessarily true for original and fastSNP method because LLC determines that
                                % solving LPs is enough, which will invoke sparseFBA to approximate min-L0 solutions,
                                % which may not be the exact minimum solution
                                assert(abs(Vmin(3, j, j2) - 0.9) < tol)
                                assert(abs(Vmin(4, j, j2)) < tol)
                                assert(abs(Vmin(5, j, j2)) < tol)
                                assert(abs(Vmax(3, j, j2) - 1) < tol)
                                assert(abs(Vmax(4, j, j2)) < tol)
                                assert(abs(Vmax(5, j, j2)) < tol)
                            elseif j2 == 3
                                % min 1-norm
                                assert(abs(Vmin(3, j, j2)) < tol)
                                assert(abs(Vmin(4, j, j2) - 0.09) < tol)
                                assert(abs(Vmin(5, j, j2) - 0.09) < tol)
                                assert(abs(Vmax(3, j, j2)) < tol)
                                assert(abs(Vmax(4, j, j2) - 0.1) < tol)
                                assert(abs(Vmax(5, j, j2) - 0.1) < tol)
                            elseif j2 == 4
                                % min 2-norm will make all rxns active
                                assert(all(abs(Vmin(:, j, j2)) > tol))
                                assert(all(abs(Vmax(:, j, j2)) > tol))
                            end
                       end
                   end
               end
            end
            fprintf('Done.\n');
        end
    end

end


% change the directory
cd(currentDir)
