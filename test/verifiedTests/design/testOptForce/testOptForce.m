% The COBRAToolbox: testAddLopLawConstraints.m
%
% Purpose:
%     - test OptForce (according to the tutorial)
%
% Authors:
%     - Thomas Pfau Oct 2017
%

global CBTDIR

solverPkgs = prepareTest('requireOneSolverOf', {'ibm_cplex','gurobi'});

originalDir = pwd;

pathTutorial = which('testOptForce.m');
pathstr = fileparts(pathTutorial);
cd(pathstr)

%Init paralell pool, if possible
try
    minWorkers = 2;
    myCluster = parcluster(parallel.defaultClusterProfile);
    
    if myCluster.NumWorkers >= minWorkers
        poolobj = gcp('nocreate');  % if no pool, do not create new one.
        if isempty(poolobj)
            parpool(minWorkers);  % launch minWorkers workers
        end
        parPoolCreated = true;
    end
catch
    parPoolCreated = false;
end
    
model = getDistributedModel('AntCore.mat');
model.c(strcmp(model.rxns, 'R75')) = 1;
model = changeRxnBounds(model, 'EX_gluc', -100, 'l'); 
model = changeRxnBounds(model, 'EX_o2', -100, 'l'); 
model = changeRxnBounds(model, 'EX_so4', -100, 'l'); 
model = changeRxnBounds(model, 'EX_nh3', -100, 'l'); 
model = changeRxnBounds(model, 'EX_cit', -100, 'l'); 
model = changeRxnBounds(model, 'EX_glyc', -100, 'l'); 

origmodel = model;


%set up the xlwrite command for xls io. We do this before the loop, as
%changeCobraSolver will correct the globals which are reset on 2014b by a
%javaaddpath.
setupxlwrite();

for k = 1:length(solverPkgs)
    solverLPOK = changeCobraSolver(solverPkgs.LP{k}, 'LP');
    solverMILPOK = changeCobraSolver(solverPkgs.MILP{k}, 'MILP');
    
    if solverLPOK && solverMILPOK
        %get max growth rate
        model = origmodel;
        growthRate = optimizeCbModel(model);         
        %get max succinate production
        model = changeObjective(model, 'EX_suc');
        maxSucc = optimizeCbModel(model);
        %Set a high Biomass production constraint
        constrWT = struct('rxnList', {{'R75'}}, 'rxnValues', 14, 'rxnBoundType', 'b');
        constrMT = struct('rxnList', {{'R75', 'EX_suc'}}, 'rxnValues', [0, 155.55], ...
                  'rxnBoundType', 'bb');
        succExPos = ismember(model.rxns,'EX_suc');
        biomassPos = ismember(model.rxns,'R75');
        [minFluxesW, maxFluxesW, minFluxesM, maxFluxesM, ~, ~] = FVAOptForce(model, ...
                                                                     constrWT, constrMT);
        %Assert, that the constraints are met.
        assert(minFluxesW(biomassPos) == 14);
        assert(maxFluxesW(biomassPos) == 14);
        assert(minFluxesM(succExPos) == 155.55);
        assert(maxFluxesM(succExPos) == 155.55);
        assert(minFluxesM(biomassPos) == 0);
        assert(maxFluxesM(biomassPos) == 0);
        runID = 'TestOptForceM';
        
        %Get Must Sets
        fprintf('Building Must sets...\n')
        constrOpt = struct('rxnList', {{'EX_gluc', 'R75', 'EX_suc'}}, 'values', [-100, 0, 155.5]');
        [mustLSet, pos_mustL] = findMustL(model, minFluxesW, maxFluxesW, 'constrOpt', constrOpt, ...
                                  'runID', runID, 'printLevel', 0);
        [mustUSet, pos_mustU] = findMustU(model, minFluxesW, maxFluxesW, 'constrOpt', constrOpt, ...
                                  'runID', runID, 'printLevel', 0);

        %constrOpt = struct('rxnList', {{'EX_gluc', 'R75', 'EX_suc'}}, 'values', [-100, 0, 155.5]');
        exchangeRxns = model.rxns(cellfun(@isempty, strfind(model.rxns, 'EX_')) == 0);
        excludedRxns = unique([mustUSet; mustLSet; exchangeRxns]);
        [mustUU, pos_mustUU, mustUU_linear, pos_mustUU_linear] = ...
                findMustUU(model, minFluxesW, maxFluxesW, 'constrOpt', constrOpt, ...
                           'excludedRxns', excludedRxns,'runID', runID, ...                           
                           'printLevel', 0);

        [mustLL, pos_mustLL, mustLL_linear, pos_mustLL_linear] = ...
                findMustLL(model, minFluxesW, maxFluxesW, 'constrOpt', constrOpt, ...
                           'excludedRxns', excludedRxns,'runID', runID, ...
                           'printLevel', 0);
        [mustUL, pos_mustUL, mustUL_linear, pos_mustUL_linear] = ...
                findMustUL(model, minFluxesW, maxFluxesW, 'constrOpt', constrOpt, ...
                          'excludedRxns', excludedRxns,'runID', runID, ...
                          'printLevel', 0);
        mustU = unique(union(mustUSet, mustUU));
        mustL = unique(union(mustLSet, mustLL));
        targetRxn = 'EX_suc';
        biomassRxn = 'R75';        
        nSets = 1;
        constrOpt = struct('rxnList', {{'EX_gluc','R75'}}, 'values', [-100, 0]);
        fprintf('Running OptForce with k = 1\n')
        [optForceSets, posOptForceSets, typeRegOptForceSets, flux_optForceSets] = ...
                optForce(model, targetRxn, biomassRxn, mustU, mustL, ...
                         minFluxesW, maxFluxesW, minFluxesM, maxFluxesM, ...
                         'k', 1, 'nSets', nSets, 'constrOpt', constrOpt, ...
                         'runID', runID);
        assert(validateOptForceSol(origmodel,posOptForceSets,typeRegOptForceSets,'EX_suc'));
        %clean up
        rmdir(runID,'s')
        fprintf('Running Optforce with k = 2\n')
        nSets = 20;
        runID = 'TestOptForceM2';
        excludedRxns = struct('rxnList', {{'SUCt'}}, 'typeReg','U');
        [optForceSets, posOptForceSets, typeRegOptForceSets, flux_optForceSets] = ...
            optForce(model, targetRxn, biomassRxn, mustU, mustL, ...
             minFluxesW, maxFluxesW, minFluxesM, maxFluxesM, ...
             'k', 2, 'nSets', nSets, 'constrOpt', constrOpt, ...
             'excludedRxns', excludedRxns, ...
             'runID', runID);
        assert(validateOptForceSol(origmodel,posOptForceSets,typeRegOptForceSets,'EX_suc'));
        %clean up
        rmdir(runID,'s');
    end
end

         
cd(originalDir);         
         
         