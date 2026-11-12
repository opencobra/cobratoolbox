% The COBRAToolbox: testOptForce.m
%
% Purpose:
%     - test OptForce (according to the tutorial)
%     - test the optional inputs, the report and the result files, the runs without a solution and
%       the search with an increasing number of interventions (option loop).
%     - Everything runs in a temporary folder, with a pool whose job files are in that folder too:
%       a default pool would write them to ~/.matlab/local_cluster_jobs. Each run has its own run
%       folder, and files named after the current minute (the reports and the default result
%       file) are found by pattern, so no assertion depends on the name of a minute.
%
% Function under test:
%     src/design/optForce/optForce.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation; AntCore, the model of the OptForce tutorial, with 90 reactions. The
%     bilevel problem has one binary variable per reaction and intervention. MILP solver required.
%
% Coverage exemptions:
%     Line 229: Windows branch of the default of printExcel, OS-specific.
%     Lines 672-686, 688-692, 694-695: Excel output, entered only when ~isunix, OS-specific.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The option loop stops with an error as soon as a set is found
%       SEVERITY: unusable-option
%       TRIGGER: optForce(..., 'loop', 1) on a problem that has a solution
%       OBSERVED: analyzeOptForceSol is called without biomassRxn, so the solution structure takes
%         its place and the call stops with "OptForce: input biomassRxn must be an string"
%       EXPECTED: the sets are returned as without loop: analyzeOptForceSol(model, targetRxn,
%         biomassRxn, solution)
%       LINES: 407-445, 452-535
%     - DEFECT: The option loop solves the same problem in each pass
%       SEVERITY: wrong-result
%       TRIGGER: optForce(..., 'loop', 1, 'k', 3, 'kMin', 1)
%       OBSERVED: the passes count currentK from kMin to k, but the problem and the saved inputs
%         are built with k, so sets smaller than k are not searched for
%       EXPECTED: each pass builds the problem and sizes the results with currentK interventions
%       LINES: 385-386, 395-398, 403
%     - DEFECT: A progress message of the option loop is written to the report file
%       SEVERITY: error
%       TRIGGER: optForce(..., 'loop', 1, 'k', 3, 'printLevel', 1, 'printReport', 0) on a problem
%         without solution
%       OBSERVED: the message "increasing k" of the printLevel branch uses freport, which does not
%         exist without a report: "Unrecognized function or variable 'freport'"; with a report the
%         message goes to the report instead of the console
%       EXPECTED: the message is printed to the console
%       LINES: 548
%     - DEFECT: The documented exclusion type D is not recognised when the inputs are recorded
%       SEVERITY: cosmetic
%       TRIGGER: excludedRxns with typeReg D
%       OBSERVED: the problem excludes the reaction, but excludedLRxns.mat stays empty and the
%         report says "Excluded from D". The recording expects L, which the problem builder
%         rejects with an error
%       EXPECTED: one letter for downregulations throughout, D as documented
%       LINES: 347, 365-366, 876-881
%     - DEFECT: The report becomes a file named like the output folder
%       SEVERITY: cosmetic
%       TRIGGER: a run that creates no output folder: no set found, or printText = 0 on Linux
%       OBSERVED: movefile finds no folder and renames the report to OutputsOptForce, a plain file
%       EXPECTED: the output folder is created first and the report is moved into it
%       LINES: 746
%     - DEFECT: A wrong exclusion type leaves the report open and the folder changed
%       SEVERITY: cosmetic
%       TRIGGER: excludedRxns with a typeReg other than U, D, K or A
%       OBSERVED: the error is raised with the report still open and the run folder as current folder
%       EXPECTED: the report is closed and the starting folder restored
%       LINES: 887
%
% Authors:
%     - Thomas Pfau Oct 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

global CBTDIR

originalDir = pwd;

pathTutorial = which('testOptForce.m');
pathstr = fileparts(pathTutorial);
cd(pathstr)

solverPkgs = prepareTest('requireOneSolverOf', {'ibm_cplex','gurobi'});

% work in a temporary folder, which is removed at the end or when the test fails
sandboxDir = tempname;
mkdir(sandboxDir);
startPath = path;
addpath(pathstr);  % validateOptForceSol is next to this test
cd(sandboxDir);
sandboxDir = pwd;  % the folder name as MATLAB reports it
jobFolder = fullfile(sandboxDir, 'poolJobs');
openFilesAtStart = openedFiles();
leaveSandbox = onCleanup(@() cleanUpSandbox(originalDir, sandboxDir, jobFolder, startPath, openFilesAtStart));

%Init paralell pool, if possible, with its job files in the temporary folder
minWorkers = 2;
if isParallelToolboxAvailable() && isempty(getParallelPool())
    myCluster = parcluster('local');
    if myCluster.NumWorkers >= minWorkers
        mkdir(jobFolder);
        myCluster.JobStorageLocation = jobFolder;
        parpool(myCluster, minWorkers);
        % the sandbox is active: the job files of the pool are not in the home folder
        assert(strcmp(myCluster.JobStorageLocation, jobFolder));
    end
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
        % each run has its own folder: reports of the same minute have the same name
        runID = 'TestOptForceM';
        
        %Get Must Sets
        fprintf('Building Must sets...\n')
        constrOpt = struct('rxnList', {{'EX_gluc', 'R75', 'EX_suc'}}, 'values', [-100, 0, 155.5]');
        [mustLSet, pos_mustL] = findMustL(model, minFluxesW, maxFluxesW, 'constrOpt', constrOpt, ...
                                  'runID', [runID 'L'], 'printLevel', 0);
        [mustUSet, pos_mustU] = findMustU(model, minFluxesW, maxFluxesW, 'constrOpt', constrOpt, ...
                                  'runID', [runID 'U'], 'printLevel', 0);

        %constrOpt = struct('rxnList', {{'EX_gluc', 'R75', 'EX_suc'}}, 'values', [-100, 0, 155.5]');
        exchangeRxns = model.rxns(cellfun(@isempty, strfind(model.rxns, 'EX_')) == 0);
        excludedRxns = unique([mustUSet; mustLSet; exchangeRxns]);
        [mustUU, pos_mustUU, mustUU_linear, pos_mustUU_linear] = ...
                findMustUU(model, minFluxesW, maxFluxesW, 'constrOpt', constrOpt, ...
                           'excludedRxns', excludedRxns,'runID', [runID 'UU'], ...
                           'printLevel', 0);

        [mustLL, pos_mustLL, mustLL_linear, pos_mustLL_linear] = ...
                findMustLL(model, minFluxesW, maxFluxesW, 'constrOpt', constrOpt, ...
                           'excludedRxns', excludedRxns,'runID', [runID 'LL'], ...
                           'printLevel', 0);
        [mustUL, pos_mustUL, mustUL_linear, pos_mustUL_linear] = ...
                findMustUL(model, minFluxesW, maxFluxesW, 'constrOpt', constrOpt, ...
                          'excludedRxns', excludedRxns,'runID', [runID 'UL'], ...
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
        assert(size(optForceSets, 1) == nSets);
        assertSetsConsistent(model, 1, optForceSets, posOptForceSets, typeRegOptForceSets, flux_optForceSets);

        % the report lists the inputs and the result, the text file holds the set, the saved
        % inputs hold the target
        outputFolder = fullfile(runID, 'OutputsOptForce');
        reportText = readReport(outputFolder);
        assert(contains(reportText, ['Target reaction:' newline 'EX_suc']));
        assert(contains(reportText, 'optForce found 1 sets'));
        assert(contains(reportText, 'Sets found by optForce were printed in OptForce.txt'));
        resultLines = strsplit(strtrim(fileread(fullfile(outputFolder, 'OptForce.txt'))), newline);
        assert(numel(resultLines) == 2);
        assert(contains(resultLines{2}, optForceSets{1}));
        savedInputs = load(fullfile(runID, 'InputsOptForce', 'targetRxn.mat'));
        assert(isequal(savedInputs.targetRxn, {'EX_suc'}));
        % the run returned to the folder it started in
        assert(strcmp(pwd, sandboxDir));
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
        assert(size(optForceSets, 1) <= nSets);
        assertSetsConsistent(model, 2, optForceSets, posOptForceSets, typeRegOptForceSets, flux_optForceSets);
        % the reaction excluded from the upregulations is not upregulated in any set
        assert(~any(strcmp(optForceSets(:), 'SUCt') & strcmp(typeRegOptForceSets(:), 'upregulation')));
        savedInputs = load(fullfile(runID, 'InputsOptForce', 'excludedURxns.mat'));
        assert(isequal(savedInputs.excludedURxns, {'SUCt'}));
        assert(contains(readReport(fullfile(runID, 'OutputsOptForce')), 'SUCt: Excluded from Upregulations'));
        %clean up
        rmdir(runID,'s');

        optForceInputs = {model, targetRxn, biomassRxn, mustU, mustL, ...
                          minFluxesW, maxFluxesW, minFluxesM, maxFluxesM};

        %% all sets of one intervention are found: the search ends when no further set exists
        % far more sets are allowed than exist, so the result does not depend on the solver's order
        runID = 'TestOptForceAll';
        [allSets, ~, allTypes] = optForce(optForceInputs{:}, 'k', 1, 'nSets', 1000, ...
                                          'constrOpt', constrOpt, 'runID', runID);
        allInterventions = strcat(allSets, ':', allTypes);
        assert(numel(unique(allInterventions)) == numel(allInterventions));
        assert(numel(allInterventions) < 1000);
        % every kind of intervention occurs, so the exclusions below are not void
        upRxn = allSets(strcmp(allTypes, 'upregulation'));
        downRxn = allSets(strcmp(allTypes, 'downregulation'));
        knockoutRxn = allSets(strcmp(allTypes, 'knockout'));
        assert(~isempty(upRxn) && ~isempty(downRxn) && ~isempty(knockoutRxn));

        %% each type of exclusion removes its intervention, and nothing else
        % type A is not documented, the problem builder reads it as all types
        % four different reactions: a reaction can be excluded only once
        chosenDownRxn = setdiff(downRxn, upRxn(1), 'stable');
        chosenKnockoutRxn = setdiff(knockoutRxn, [upRxn(1); chosenDownRxn(1)], 'stable');
        allTypesRxn = chosenKnockoutRxn{2};
        rxnList = {upRxn{1}, chosenDownRxn{1}, chosenKnockoutRxn{1}, allTypesRxn};
        excludedRxns = struct('rxnList', {rxnList}, 'typeReg', 'UDKA');
        runID = 'TestOptForceExcluded';
        [keptSets, ~, keptTypes] = optForce(optForceInputs{:}, 'k', 1, 'nSets', 1000, ...
                                            'constrOpt', constrOpt, 'excludedRxns', excludedRxns, ...
                                            'runID', runID);
        removed = [strcat(upRxn(1), ':upregulation'); strcat(chosenDownRxn(1), ':downregulation'); ...
                   strcat(chosenKnockoutRxn(1), ':knockout'); allInterventions(strcmp(allSets, allTypesRxn))];
        assert(isempty(setxor(strcat(keptSets, ':', keptTypes), setdiff(allInterventions, removed))));
        savedInputs = load(fullfile(runID, 'InputsOptForce', 'excludedKRxns.mat'));
        assert(isequal(savedInputs.excludedKRxns, chosenKnockoutRxn(1)));
        reportText = readReport(fullfile(runID, 'OutputsOptForce'));
        assert(contains(reportText, [chosenKnockoutRxn{1} ': Excluded from Knockouts']));

        %% an unknown type of exclusion is rejected
        % the letter L is recorded as a downregulation before the problem builder rejects it
        for wrongType = 'LZ'
            excludedRxns = struct('rxnList', {downRxn(1)}, 'typeReg', wrongType);
            runID = ['TestOptForceType' wrongType];
            assert(verifyCobraFunctionError('optForce', 'inputs', ...
                   [optForceInputs, {'k', 1, 'constrOpt', constrOpt, 'excludedRxns', excludedRxns, ...
                                     'runID', runID}], ...
                   'testMessage', 'OptForce: incorrect type of regulation assigned'));
            % see the known defects: the report is still open and the run folder is current
            closeFilesOpenedSince(openFilesAtStart);
            cd(sandboxDir);
        end
        savedInputs = load(fullfile('TestOptForceTypeL', 'InputsOptForce', 'excludedLRxns.mat'));
        assert(isequal(savedInputs.excludedLRxns, downRxn(1)));
        savedInputs = load(fullfile('TestOptForceTypeZ', 'InputsOptForce', 'excludedLRxns.mat'));
        assert(isempty(savedInputs.excludedLRxns));

        %% without constrOpt, no reaction is fixed
        runID = 'TestOptForceFree';
        [optForceSets, posOptForceSets, typeRegOptForceSets, flux_optForceSets] = ...
            optForce(optForceInputs{:}, 'k', 1, 'nSets', 3, 'runID', runID);
        assert(size(optForceSets, 1) == 3);
        assertSetsConsistent(model, 1, optForceSets, posOptForceSets, typeRegOptForceSets, flux_optForceSets);
        reportText = readReport(fullfile(runID, 'OutputsOptForce'));
        assert(contains(reportText, ['Constrained reactions:' newline newline 'Excluded reactions:']));

        %% verbose is an alternative name of printLevel, and both together are refused
        runID = 'TestOptForceVerbose';
        consoleText = evalc(['[optForceSets, posOptForceSets, typeRegOptForceSets, flux_optForceSets] = ' ...
                             'optForce(optForceInputs{:}, ''k'', 1, ''constrOpt'', constrOpt, ' ...
                             '''verbose'', 1, ''runID'', runID);']);
        assertSetsConsistent(model, 1, optForceSets, posOptForceSets, typeRegOptForceSets, flux_optForceSets);
        assert(contains(consoleText, 'set n 1 was found'));
        assert(contains(consoleText, 'optForce found 1 sets'));
        assert(contains(consoleText, 'Sets found by optForce were printed in OptForce.txt'));
        assert(verifyCobraFunctionError('optForce', 'inputs', ...
               [optForceInputs, {'verbose', 1, 'printLevel', 1}], ...
               'testMessage', 'Either supply printLevel or verbose optional parameter'));

        %% the name of the result file is built from the time when outputFileName is empty
        runID = 'TestOptForceDefaultName';
        optForceSets = optForce(optForceInputs{:}, 'k', 1, 'constrOpt', constrOpt, ...
                                'outputFileName', '', 'runID', runID);
        resultFiles = dir(fullfile(runID, 'OutputsOptForce', 'optForceSolution-*.txt'));
        assert(numel(resultFiles) == 1);
        resultText = fileread(fullfile(resultFiles(1).folder, resultFiles(1).name));
        assert(contains(resultText, optForceSets{1}));

        %% with all outputs switched off, the run leaves nothing but its empty folder
        runID = 'TestOptForceSilent';
        [optForceSets, posOptForceSets, typeRegOptForceSets, flux_optForceSets] = ...
            optForce(optForceInputs{:}, 'k', 1, 'constrOpt', constrOpt, 'printReport', 0, ...
                     'printText', 0, 'keepInputs', 0, 'runID', runID);
        assertSetsConsistent(model, 1, optForceSets, posOptForceSets, typeRegOptForceSets, flux_optForceSets);
        assert(numel(dir(runID)) == 2);  % only . and ..

        %% a model with coupling constraints gets a warning, the constraints are not used
        % issueConfirmationWarning waits for an answer on a machine named jenkins
        if ~contains(getenv('HOME'), 'jenkins')
            modelWithC = model;
            modelWithC.C = sparse(1, numel(model.rxns));
            modelWithC.d = 0;
            modelWithC.dsense = 'L';
            modelWithC.ctrs = {'unusedConstraint'};
            runID = 'TestOptForceCoupling';
            consoleText = evalc(['[optForceSets, posOptForceSets, typeRegOptForceSets, flux_optForceSets] = ' ...
                                 'optForce(modelWithC, optForceInputs{2:end}, ''k'', 1, ' ...
                                 '''constrOpt'', constrOpt, ''runID'', runID);']);
            assert(contains(consoleText, 'optForce does not handle the additional constraints'));
            assertSetsConsistent(model, 1, optForceSets, posOptForceSets, typeRegOptForceSets, flux_optForceSets);
            assert(validateOptForceSol(origmodel, posOptForceSets, typeRegOptForceSets, 'EX_suc'));
            clear modelWithC
        end

        %% a problem without solution gives empty results
        % the biomass flux is fixed far above its upper bound
        impossible = struct('rxnList', {{'R75'}}, 'values', 1e4);
        runID = 'TestOptForceNoSet';
        consoleText = evalc(['[optForceSets, posOptForceSets, typeRegOptForceSets, flux_optForceSets] = ' ...
                             'optForce(optForceInputs{:}, ''k'', 1, ''constrOpt'', impossible, ' ...
                             '''printLevel'', 1, ''runID'', runID);']);
        assert(isempty(optForceSets) && isempty(posOptForceSets));
        assert(isempty(typeRegOptForceSets) && isempty(flux_optForceSets));
        assert(contains(consoleText, 'optForce did not find any set'));
        assert(contains(consoleText, 'no plain text file was generated'));
        assert(strcmp(pwd, sandboxDir));

        %% with the option loop, each number of interventions from kMin to k is tried in turn
        % see the known defects: only a problem without solution can be run with this option
        runID = 'TestOptForceLoop';
        consoleText = evalc(['[optForceSets, posOptForceSets, typeRegOptForceSets, flux_optForceSets] = ' ...
                             'optForce(optForceInputs{:}, ''k'', 3, ''constrOpt'', impossible, ' ...
                             '''loop'', 1, ''printLevel'', 1, ''runID'', runID);']);
        assert(isempty(optForceSets) && isempty(posOptForceSets));
        assert(isempty(typeRegOptForceSets) && isempty(flux_optForceSets));
        reportText = readReport(runID);
        assert(contains(reportText, 'increasing k to 2'));
        for triedK = 1:3
            noSetMessage = sprintf('optForce did not find any set using k = %d', triedK);
            assert(contains(consoleText, noSetMessage));
            assert(contains(reportText, noSetMessage));
            assert(exist(fullfile(runID, sprintf('InputsOptForce_k%d', triedK)), 'dir') == 7);
        end
        assert(strcmp(pwd, sandboxDir));

        % kMin sets the first number of interventions; without report and inputs nothing is written
        runID = 'TestOptForceLoopSilent';
        [optForceSets, posOptForceSets, typeRegOptForceSets, flux_optForceSets] = ...
            optForce(optForceInputs{:}, 'k', 3, 'kMin', 3, 'constrOpt', impossible, 'loop', 1, ...
                     'printReport', 0, 'keepInputs', 0, 'runID', runID);
        assert(isempty(optForceSets) && isempty(posOptForceSets));
        assert(isempty(typeRegOptForceSets) && isempty(flux_optForceSets));
        assert(numel(dir(runID)) == 2);  % only . and ..
        assert(strcmp(pwd, sandboxDir));
    end
end

% leave and remove the temporary folder
clear leaveSandbox
assert(~exist(sandboxDir, 'dir'));

cd(originalDir);


function assertSetsConsistent(model, nInterventions, sets, positions, types, fluxes)
    % the four outputs of optForce describe the same sets, of the requested size: the positions
    % point to the named reactions, the types are known, and the fluxes respect the bounds of
    % the model (1e-6: the feasibility tolerance of the solvers)
    assert(size(sets, 2) == nInterventions);
    assert(isequal(size(sets), size(positions), size(types), size(fluxes)));
    assert(all(positions(:) > 0));
    assert(isequal(sets(:), model.rxns(positions(:))));
    assert(all(ismember(types(:), {'upregulation', 'downregulation', 'knockout'})));
    tol = 1e-6;
    assert(all(fluxes(:) >= model.lb(positions(:)) - tol));
    assert(all(fluxes(:) <= model.ub(positions(:)) + tol));
end


function reportText = readReport(folder)
    % the text of the only report in a folder; the report is found by pattern because its name
    % holds the minute of the run
    reports = dir(fullfile(folder, 'report-*.txt'));
    assert(numel(reports) == 1);
    reportText = fileread(fullfile(reports(1).folder, reports(1).name));
end


function closeFilesOpenedSince(openFilesAtStart)
    % close the files that were opened after openFilesAtStart was taken
    newFiles = setdiff(openedFiles(), openFilesAtStart);
    for fileID = newFiles(:)'
        fclose(fileID);
    end
end


function cleanUpSandbox(startDir, sandboxDir, jobFolder, startPath, openFilesAtStart)
    % closes a pool whose job files are in the temporary folder, closes the files left open,
    % restores the path of the session and removes the temporary folder, also when the test fails
    cd(startDir);
    path(startPath);
    pool = getParallelPool();
    if ~isempty(pool) && strcmp(pool.Cluster.JobStorageLocation, jobFolder)
        delete(pool);
    end
    closeFilesOpenedSince(openFilesAtStart);
    rmdir(sandboxDir, 's');
end
