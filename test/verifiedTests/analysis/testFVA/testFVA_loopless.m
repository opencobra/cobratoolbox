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
load('refData_looplessFVA.mat');
% model = createToyModelForgapFind();
% optPercent = 1;
% rxnNameList = model.rxns;

runOrder = 1:2;
try
    poolobj = gcp('nocreate');
    if ~isempty(poolobj)
        % if parallel pool is already on, run the test for parallel computation first
        runOrder = [2 1];
    end
end
% test both single-thread and parallel computation
for jRun = 2%runOrder
    cont = true;
    if jRun == 1
        % test FVA without parrallel toolbox.
        pttoolboxPath = which('parpool');
        % here, we can use dqq and quadMinos, because this is not parallel.
        solverPkgs = prepareTest('needsLP',true,'needsMILP',true,'needsQP',true,'needsMIQP',true,'useSolversIfAvailable',{'ibm_cplex'},'minimalMatlabSolverVersion',8.0);
        if ~isempty(pttoolboxPath)
            %We also have to shut down the parallel pool, as otherwise problems
            %occur with the pool.
            poolobj = gcp('nocreate');
            delete(poolobj);
            
            %%%% this is pretty dangerous if errors occur and the script
            %%%% does not run through
%             %Now, lets remove the parallel processing stuff from the path. and
%             %reintroduce it in the end.
%             cpath = fileparts(pttoolboxPath);
%             rmpath(cpath);
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
            % change the COBRA solver (LP)
            solverLPOK = changeCobraSolver(solverPkgs.LP{k}, 'LP', 0);
            
            if solverLPOK && doMILP
                fprintf('   Testing %s loopless flux variability analysis using %s ... ', printText, solverPkgs.LP{k});
                
                % launch the flux variability analysis
                
                for str = {'original', 'fastSNP', 'LLC-NS', 'LLC-EFM'}
                    tic;
                    [minFluxT, maxFluxT] = fluxVariability(model, optPercent, 'max', rxnNameList, 0, str{:});
                    t = toc;
                    fprintf('%s method takes %.2f sec to finish\n', str{:}, t);
                    assert(max(abs(minFluxT - minF)) < tol)
                    assert(max(abs(maxFluxT - maxF)) < tol)
                end
                
                
            end
        end
    end
    
%     if jRun == 1 && ~isempty(pttoolboxPath)
%         % Readd the path.
%         addpath(cpath);
%     end
end

% change the directory
cd(currentDir)
