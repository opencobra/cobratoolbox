% The COBRAToolbox: testFVAloopless.m
%
% Purpose:
%     - testFVAloopess tests the functionality of loopless flux variability analysis
%
% Authors:
%     - Template from testFVA.m
%     - Joshua Chan 03/15/2019

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFVAloopless'));
cd(fileDir);

% set the tolerance
tol = 1e-4;

% load the model
model = getDistributedModel('ecoli_core_model.mat');

% two reactions in loops and two not in loops
rxnInLoops = {'FRD7'; 'SUCDi'};
rxnNotInLoops = {'ATPM'; 'FUM'};
rxnTest = [rxnInLoops; rxnNotInLoops];
optPercent = 90;

% results obtained using the previous version of fluxVariability (on May 17, 2019)
fvaResultsRef = [0, 1000; ...
    0, 1000; ...
    8.39, 25.55109; ...
    -0.51292, 8.04594];

llfvaResultsRef = [0, 0.51292; ...
    0, 8.04594; ...
    8.39, 25.55109;...
    -0.51292, 8.04594];

threadsForFVA = 1;
try
    if isempty(gcp('nocreate'))
        parpool(2);
    end
    solverPkgs = prepareTest('needsLP',true,'needsMILP',true,'needsQP',true,'needsMIQP',true,...
        'useSolversIfAvailable',{'gurobi'; 'ibm_cplex'},...
        'excludeSolvers',{'dqqMinos','quadMinos'},...
        'minimalMatlabSolverVersion',8.0);
    threadsForFVA = [2, 1];
catch ME
    % test FVA without parrallel toolbox.
    % here, we can use dqq and quadMinos, because this is not parallel.
    solverPkgs = prepareTest('needsLP',true,'needsMILP',true,'needsQP',true,'needsMIQP',true,...
        'useSolversIfAvailable',{'gurobi'; 'ibm_cplex'},'minimalMatlabSolverVersion',8.0);
end

printText = {'single-thread', 'parallel'};
% test both single-thread and parallel computation

%%
for k = 1:length(solverPkgs.LP)
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
        doMIQP = true & solverMIQPOK;
    end
    % change the COBRA solver (LP)
    solverLPOK = changeCobraSolver(solverPkgs.LP{k}, 'LP', 0);
    
    for threads = threadsForFVA
        if solverLPOK && doMILP
            fprintf('   Testing %s loopless flux variability analysis using %s ... \n', printText{threads}, solverPkgs.LP{k});
            
            % check the usual FVA first
            [minFluxT, maxFluxT] = fluxVariability(model, optPercent, 'max', rxnTest, 2, 1, 'threads', threads);
            assert(max(abs(minFluxT - fvaResultsRef(:, 1))) < tol)
            assert(max(abs(maxFluxT - fvaResultsRef(:, 2))) < tol)
            
            % check that different methods for loopless FVA give the same results
            method = {'original', 'fastSNP', 'LLC-NS', 'LLC-EFM'};
            t = zeros(numel(method), 1);
            for j = 1:numel(method)
                tic;
                [minFluxT, maxFluxT] = fluxVariability(model, optPercent, 'max', rxnTest, 2, method{j}, 'threads', threads);
                t(j) = toc;
                assert(max(abs(minFluxT - llfvaResultsRef(:, 1))) < tol)
                assert(max(abs(maxFluxT - llfvaResultsRef(:, 2))) < tol)
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
                
                for i = 1:numel(rxnTestForFluxes)
                    [minFluxT, maxFluxT] = deal(zeros(numel(method), numel(minNormMethod)));
                    [Vmin, Vmax] = deal(zeros(numel(model.rxns), numel(method), numel(minNormMethod)));
                    
                    for j = 1:numel(method)
                        for j2 = 1:numel(minNormMethod)
                            tic;
                            [minFluxT(j, j2), maxFluxT(j, j2), Vmin(:, j, j2), Vmax(:, j, j2)] = ...
                                fluxVariability(model, optPercent, 'max', rxnTest(rxnTestForFluxes(i)), 2, method{j}, minNormMethod{j2}, solverParams{j2}, 'threads', threads);
                            t(j, j2) = toc;
                            assert(abs(minFluxT(j, j2)  - llfvaResultsRef(rxnTestForFluxes(i), 1)) < tol)
                            assert(abs(maxFluxT(j, j2)  - llfvaResultsRef(rxnTestForFluxes(i), 2)) < tol)
                        end
                    end
                    % calculate the norms from the solutions
                    
                    [normMin, normMax] = deal(zeros(numel(method), numel(minNormMethod), 3));
                    for j = 1:numel(method)
                        for j2 = 1:numel(minNormMethod)
                            % 0-norm
                            normMin(j, j2, 1) = sum(abs(Vmin(:, j, j2)) > 1e-8);
                            % 1-norm
                            normMin(j, j2, 2) = sum(abs(Vmin(:, j, j2)));
                            % 2-norm
                            normMin(j, j2, 3) = Vmin(:, j, j2)' * Vmin(:, j, j2);
                            
                            % 0-norm
                            normMax(j, j2, 1) = sum(abs(Vmax(:, j, j2)) > 1e-8);
                            % 1-norm
                            normMax(j, j2, 2) = sum(abs(Vmax(:, j, j2)));
                            % 2-norm
                            normMax(j, j2, 3) = Vmax(:, j, j2)' * Vmax(:, j, j2);
                        end
                    end
                    
                    % For flux distributions for minFlux
                    % check that solutions with minNormMethod = 0-norm should have small 0-norms
                    minValue = min(normMin(:, :, 1), [], 2);
                    % a larger deviation allowed for 0-norm minimization using different methods,
                    % since the approximation algorithm used by sparseFBA
                    % for 0-norm might find a 0-norm slightly higher than
                    % solving the original MILP
                    assert(all(normMin(:, 2, 1) <= min(minValue) + 5))
                    % check that solutions with minNormMethod = 1-norm should have small 1-norms
                    minValue = min(normMin(:, :, 2), [], 2);
                    assert(all(normMin(:, 3, 2) <= (1 + tol) * min(minValue)))
                    % check that solutions with minNormMethod = 2-norm should have small 2-norms
                    minValue = min(normMin(:, :, 3), [], 2);
                    assert(all(normMin(:, 4, 3) <= (1 + tol) * min(minValue)))
                    
                    % For flux distributions for maxFlux
                    % check that solutions with minNormMethod = 0-norm should have small 0-norms
                    minValue = min(normMax(:, :, 1), [], 2);
                    % a larger deviation allowed for 0-norm minimization
                    assert(all(normMax(:, 2, 1) <= min(minValue) + 5))
                    % check that solutions with minNormMethod = 1-norm should have small 1-norms
                    minValue = min(normMax(:, :, 2), [], 2);
                    assert(all(normMax(:, 3, 2) <= (1 + tol) * min(minValue)))
                    % check that solutions with minNormMethod = 2-norm should have small 2-norms
                    minValue = min(normMax(:, :, 3), [], 2);
                    assert(all(normMax(:, 4, 3) <= (1 + tol) * min(minValue)))
                    
                end
            end
        end
    end
end

% change the directory
cd(currentDir)
