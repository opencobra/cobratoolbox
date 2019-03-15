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
loopToyModel = createToyModelForgapFind();

runOrder = 1:2;
try
    poolobj = gcp('nocreate');
    if ~isempty(poolobj)
        % if parallel pool is already on, run the test for parallel computation first
        runOrder = [2 1];
    end
end
% test both single-thread and parallel computation
for jRun = runOrder
    cont = true;
    if jRun == 1
        % test FVA without parrallel toolbox.
        pttoolboxPath = which('parpool');
        % here, we can use dqq and quadMinos, because this is not parallel.
        solverPkgs = prepareTest('needsLP',true,'needsMILP',true,'needsQP',true,'needsMIQP',true,'useSolversIfAvailable',{'gurobi'; 'ibm_cplex'},'minimalMatlabSolverVersion',8.0);
        if ~isempty(pttoolboxPath)
            %We also have to shut down the parallel pool, as otherwise problems
            %occur with the pool.
            poolobj = gcp('nocreate');
            delete(poolobj);
            %Now, lets remove the parallel processing stuff from the path. and
            %reintroduce it in the end.
            cpath = fileparts(pttoolboxPath);
            rmpath(cpath);
        end
        printText = 'single-thread';
    elseif jRun == 2
        % define the solver packages to be used to run this test, can't use
        % dqq/Minos for the parallel part.
        solverPkgs = prepareTest('needsLP',true,'needsMILP',true,'needsQP',true,'needsMIQP',true,...
            'useSolversIfAvailable',{'ibm_cplex'},...
            'excludeSolvers',{'dqqMinos','quadMinos'},...
            'minimalMatlabSolverVersion',8.0);
        % create a parallel pool
        try
            minWorkers = 2;
            myCluster = parcluster(parallel.defaultClusterProfile);
            %No parallel pool
            if myCluster.NumWorkers >= minWorkers
                poolobj = gcp('nocreate');  % if no pool, do not create new one.
                if isempty(poolobj)
                    parpool(minWorkers);  % launch minWorkers workers
                end
            end
        catch
            %No Parallel pool. Thats fine
            cont = false;
        end
        printText = 'parallel';
    end
    
    if cont
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
                fprintf('   Testing %s flux variability analysis using %s ... ', printText, solverPkgs.LP{k});
                
                rxnNames = {'PGI', 'PFK', 'FBP', 'FBA', 'TPI', 'GAPD', 'PGK', 'PGM', 'ENO', 'PYK', 'PPS', ...
                    'G6PDH2r', 'PGL', 'GND', 'RPI', 'RPE', 'TKT1', 'TKT2', 'TALA'};
                
                % launch the flux variability analysis
                fprintf('    Testing flux variability for the following reactions:\n');
                disp(rxnNames);
                [minFluxT, maxFluxT] = fluxVariability(model, 90, 'max', rxnNames);
                
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
                if ~doQP || ~doMILP
                    % Do the rest only for those solvers, which do have QP and MILP
                    % support.
                    continue
                end
                % Vmin and Vmax test
                % Since the solution are dependant on solvers and cpus, the test will check the existence of nargout (weak test) over the 4 first reactions
                rxnNames = {'PGI', 'PFK', 'FBP', 'FBA'};
                
                % testing default FVA with 2 printLevels
                for j = 0:1
                    fprintf('    Testing flux variability with printLevel %s:\n', num2str(j));
                    [minFluxT, maxFluxT, Vmin, Vmax] = fluxVariability(model, 90, 'max', rxnNames, j, 1);
                    assert(~isequal(Vmin, []));
                    assert(~isequal(Vmax, []));
                end
                
                % testing various methods
                testMethods = {'FBA', '0-norm', '1-norm', '2-norm', 'minOrigSol'};
                
                for j = 1:length(testMethods)
                    fprintf('    Testing flux variability with test method %s:\n', testMethods{j});
                    [minFluxT, maxFluxT, Vmin, Vmax] = fluxVariability(model, 90, 'max', rxnNames, 1, 1, testMethods{j});
                    assert(~isequal(Vmin, []));
                    assert(~isequal(Vmax, []));
                    % this only works on cplex! all other solvers fail this
                    % test.... However, we should test it on the CI for
                    % functionality checks.
                    if strcmp(solverPkgs.QP{k},'ibm_cplex')
                        constraintModel = addCOBRAConstraints(model,{'PFK'},1);
                        [minFluxT, maxFluxT, Vmin, Vmax] = fluxVariability(constraintModel, 90, 'max', rxnNames, 1, 1, testMethods{j});
                        assert(maxFluxT(ismember(rxnNames,'PFK')) - 1 <= tol);
                        assert(~isequal(Vmin, []));
                        assert(~isequal(Vmax, []));
                    end
                end
                
                % output a success message
                [minF,maxF] = fluxVariability(loopToyModel,1,'max',{'R1','R4'},0,0);
                assert(abs(maxF(2))< tol); %While R4 can carry a flux of 1000, it can't do so without a loop
                assert(abs(maxF(1) -500) < tol); % Due to downstream reactions which have to carry "double" flux, this reaction can at most carry a flux of 500)
                assert(abs(minF(1)-5) < tol); %We require at least a flux of 10 through the objective (1% of 1000). This requires a flux of 5 through R1.
                assert(abs(minF(2)) < tol); %We require at least a flux of 10 through the objective (1% of 1000). This requires a flux of 5 through R1.
                assert(verifyCobraFunctionError('fluxVariability','outputArgCount',4,'input',{loopToyModel,1,'max',{'R1','R4'},0,0, 'minOrigSol'}));
                
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
                [minF1, maxF1, minSols1, maxSols1] = fluxVariability(loopToyModel, 1, 'max', {'R1','R4'}, 0, 0, '1-norm', solverParams);
                [minF2, maxF2, minSols2, maxSols2] = fluxVariability(loopToyModel, 1, 'max', {'R1','R4'}, 0, 0, '2-norm', solverParams);
                fprintf('\n1-norm minimized flux distributions for minimizing R1, R4 and maximizing R1, R4:\n');
                disp([minSols1, maxSols1]);
                fprintf('\n2-norm minimized flux distributions for minimizing R1, R4 and maximizing R1, R4:\n');
                disp([minSols2, maxSols2]);
                
                assert(max(abs(minF1 - [5; 0])) < tol)
                assert(max(abs(minF2 - [5; 0])) < tol)
                assert(max(abs(maxF1 - [500; 0])) < tol)
                assert(max(abs(maxF2 - [500; 0])) < tol)
                
                % the corresponding norm-minimized solutions
                % min R1, max and min R4
                sol1 = [5; 5; 10; 0; 0; 0; 0; 0; 0; -5; 10];
                % max R1
                sol2 = [5; 5; 10; 0; 0; 0; 0; 0; 0; -5; 10] * 100;
                
                assert(sum(abs(minSols1(:, 1) - sol1)) < tol)
                assert(sum(abs(minSols1(:, 2) - sol1)) < tol)
                assert(sum(abs(maxSols1(:, 1) - sol2)) < tol)
                assert(sum(abs(maxSols1(:, 2) - sol1)) < tol)
                
                % gurobi QP seems not to perfectly satisfy the optimality
                % tolerance (1e-9). The 2-norm-minimized solutions returned might 
                % have up to 5e-8 larger then the true 2-norm-minimized solution 
                assert(norm(minSols2(:, 1) - sol1, 2) ^ 2 < tol)
                assert(norm(minSols2(:, 2) - sol1, 2) ^ 2 < tol)
                assert(norm(maxSols2(:, 1) - sol2, 2) ^ 2 < tol)
                assert(norm(maxSols2(:, 2) - sol1, 2) ^ 2 < tol)
                fprintf('Done.\n');
            end
        end
    end
    
    if jRun == 1 && ~isempty(pttoolboxPath)
        % Readd the path.
        addpath(cpath);
    end
end

% change the directory
cd(currentDir)