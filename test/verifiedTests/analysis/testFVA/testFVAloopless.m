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

% relax the feasibility tolerance a little bit to have better stability
problemType = {'LP', 'MILP', 'MIQP'};
feasTol = zeros(numel(problemType), 1);
for j = 1:numel(problemType)
    feasTol(j) = getCobraSolverParams(problemType{j}, 'feasTol');
    changeCobraSolverParams(problemType{j}, 'feasTol', 1e-8);
end

% load the model
model = readCbModel('Ec_iJR904.mat');
% randomly picked reactions in or not in loops
rxnInLoops = {'THMDt2r';'GALUi';'ADNt2';'NDPK1';'THMDt2';'SERt4';'ADK1';'GALU';'LCAD';'PPCSCT'};
rxnNotInLoops = {'DADA';'GLYt2r';'EX_2ddglcn(e)';'DMPPS';'EX_xan(e)';'ASPCT';'HKNTDH';'UAG2Ei';'ORNabc';'DHAD1'};
rxnTest = [rxnInLoops; rxnNotInLoops];
optPercent = 99;
% results obtained using the previous version of fluxVariability with allowLoops = 0 (on March 18, 2019)
refData = load('refData_looplessFVA.mat');
[minF, maxF] = deal(refData.minFwoLoops, refData.maxFwoLoops);

threadsForFVA = 1;
try
    if isempty(gcp('nocreate'))
        parpool(2);
    end
    solverPkgs = prepareTest('needsLP',true,'needsMILP',true,'needsQP',true,'needsMIQP',true,...
        'useSolversIfAvailable',{'gurobi'; 'ibm_cplex'},...
        'excludeSolvers',{'dqqMinos','quadMinos'},...
        'minimalMatlabSolverVersion',8.0);
    threadsForFVA = [1, 2];
catch ME
    % test FVA without parrallel toolbox.
    % here, we can use dqq and quadMinos, because this is not parallel.
    solverPkgs = prepareTest('needsLP',true,'needsMILP',true,'needsQP',true,'needsMIQP',true,'useSolversIfAvailable',{'gurobi'; 'ibm_cplex'},'minimalMatlabSolverVersion',8.0);
end

printText = {'single-thread', 'parallel'};
% test both single-thread and parallel computation
for threads = threadsForFVA
    
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
        
        if solverLPOK && doMILP
            fprintf('   Testing %s loopless flux variability analysis using %s ... \n', printText{threads}, solverPkgs.LP{k});
            
            % launch the flux variability analysis
            method = {'original', 'fastSNP', 'LLC-NS', 'LLC-EFM'};
            t = zeros(numel(method), 1);
            for j = 1:numel(method)
                tic;
                [minFluxT, maxFluxT] = fluxVariability(model, optPercent, 'max', rxnTest, 2, method{j}, 'threads', threads);
                t(j) = toc;
                assert(max(abs(minFluxT - minF)) < tol)
                assert(max(abs(maxFluxT - maxF)) < tol)
            end
            fprintf('\n\n');
            for j = 1:numel(method)
                fprintf('%s method takes %.2f sec to finish loopless FVA for %d reactions\n', method{j}, t(j), numel(rxnTest));
            end
            
            if doQP && doMIQP
                % return flux distributions
                
                % test for one reaction in loops and one not in loops
                rxnTestForFluxes = [1; 11];
                
                method = {'original', 'fastSNP', 'LLC-NS', 'LLC-EFM'};
                minNormMethod = {'FBA', '0-norm', '1-norm', '2-norm'};
                
                solverParams = repmat({struct()}, numel(minNormMethod), 1);
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
                            assert(abs(minFluxT(j, j2)  - minF(rxnTestForFluxes(i))) < tol)
                            assert(abs(maxFluxT(j, j2)  - maxF(rxnTestForFluxes(i))) < tol)
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
                    minValue = min(min(normMin(:, :, 1)));
                    assert(all(normMin(:, 2, 1) < 1.03 * minValue))  % a larger deviation allowed for 0-norm minimization
                    % check that solutions with minNormMethod = 1-norm should have small 1-norms
                    minValue = min(normMin(:, :, 2), [], 2);
                    assert(all(normMin(:, 3, 2) <= minValue))
                    assert(all(normMin(:, 3, 2) < (1 + 1e-5) * min(normMin(:, 3, 2))))
                    % check that solutions with minNormMethod = 2-norm should have small 2-norms
                    minValue = min(normMin(:, :, 3), [], 2);
                    assert(all(normMin(:, 4, 3) <= minValue))
                    assert(all(normMin(:, 4, 3) < (1 + 1e-5) * min(normMin(:, 4, 3))))
                    
                    % For flux distributions for maxFlux
                    % check that solutions with minNormMethod = 0-norm should have small 2-norms
                    minValue = min(min(normMax(:, :, 1)));
                    assert(all(normMax(:, 2, 1) < 1.03 * minValue)) % a larger deviation allowed for 0-norm minimization
                    % check that solutions with minNormMethod = 1-norm should have small 1-norms
                    minValue = min(normMax(:, :, 2), [], 2);
                    assert(all(normMax(:, 3, 2) <= minValue))
                    assert(all(normMax(:, 3, 2) < (1 + 1e-5) * min(normMax(:, 3, 2))))
                    % check that solutions with minNormMethod = 0-norm should have small 0-norms
                    minValue = min(normMax(:, :, 3), [], 2);
                    assert(all(all(normMax(:, 4, 3) <= minValue)))
                    assert(all(normMax(:, 4, 3) < (1 + 1e-5) * min(normMax(:, 4, 3))))
                    
                end
            end
        end
    end
end

% restore the feasibility tolerance
for j = 1:numel(problemType)
    changeCobraSolverParams(problemType{j}, 'feasTol', feasTol(j));
end

% change the directory
cd(currentDir)
