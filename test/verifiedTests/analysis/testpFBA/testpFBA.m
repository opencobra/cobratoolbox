% The COBRAToolbox: testpFBA.m
%
% Purpose:
%     - tests the basic functionality of pFBA
%       Tests the basic solution for both minimizing the flux of gene-
%       associated reactions and all rxns, while growing on gluose or lactose
%       minimal media. The map output is tested with the E. coli core map of testMaps.
%
% Function under test:
%     src/analysis/parsimoniousFBA/pFBA.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation on the E. coli core models of testpFBAData.mat.
%
% Coverage exemptions:
%     Line 253: unreachable, the only two calls of the local function pass both arguments.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A call with one output stops with an error
%       SEVERITY: error
%       TRIGGER: GeneClasses = pFBA(model), without skipclass
%       OBSERVED: the essential reactions are only computed for more than one output, but they are
%         always stored in RxnClasses, which stops with "Unrecognized function or variable
%         'pFBAEssentialRxns'"
%       EXPECTED: the gene classes
%       LINES: 213
%
% Authors:
%     - Original file: Nathan Lewis 08/30/10
%     - CI integration: Laurent Heirendt February 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%
% Note:
%     - The solver libraries must be included separately

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testpFBA'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available
prepareTest('needsLP', true);

%tolerance
tol = 1e-8;

% load models and expected results
model_glc = readCbModel('testpFBAData.mat','modelName','model_glc');
model_lac = readCbModel('testpFBAData.mat','modelName','model_lac');

objGenes = load('testpFBAData.mat', 'GeneClasses_glc2', 'GeneClasses_glc1', 'GeneClasses_glc0', 'GeneClasses_lac2', 'GeneClasses_lac1', 'GeneClasses_lac0');
objRxns = load('testpFBAData.mat', 'RxnClasses_glc2', 'RxnClasses_glc1', 'RxnClasses_glc0', 'RxnClasses_lac2', 'RxnClasses_lac1', 'RxnClasses_lac0');
objModel = load('testpFBAData.mat', 'modelIrrev_glc2', 'modelIrrev_glc1', 'modelIrrev_glc0', 'modelIrrev_lac2', 'modelIrrev_lac1', 'modelIrrev_lac0');

% list of solver packages
solverPkgs = {'gurobi'}; % 'tomlab_cplex', 'glpk'

% create a parallel pool
try
    minWorkers = 2;
    myCluster = parcluster(parallel.defaultClusterProfile);

    if myCluster.NumWorkers >= minWorkers
        poolobj = getParallelPool();  % if no pool, do not create new one.
        if isempty(poolobj)
            openParallelPool(minWorkers);  % launch minWorkers workers
        end
    end
catch
    disp('Trying non parallel test')
end

for k = 1:length(solverPkgs)

    fprintf(' -- Running testfindBlockedReaction using the solver interface: %s ... \n', solverPkgs{k});

    solverLPOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverLPOK

        % run pFBA
        fprintf('\n*** Test basic pFBA calculations ***\n\n');
        fprintf('\n** Optimal solution - minimize flux not associated with gene: glucose\n');
        [t_objGenes.GeneClasses_glc1 t_objRxns.RxnClasses_glc1 t_objModel.modelIrrev_glc1] = pFBA(model_glc, 'geneoption', 2);

        fprintf('\n** Optimal solution - minimize flux not associated with gene: lactate\n');
        [t_objGenes.GeneClasses_lac1 t_objRxns.RxnClasses_lac1 t_objModel.modelIrrev_lac1] = pFBA(model_lac, 'geneoption', 2);

        fprintf('\n** Optimal solution - minimize gene-associated flux: glucose\n');
        [t_objGenes.GeneClasses_glc1 t_objRxns.RxnClasses_glc1 t_objModel.modelIrrev_glc1] = pFBA(model_glc, 'geneoption', 1);

        fprintf('\n** Optimal solution - minimize gene-associated flux: lactate\n');
        [t_objGenes.GeneClasses_lac1 t_objRxns.RxnClasses_lac1 t_objModel.modelIrrev_lac1] = pFBA(model_lac, 'geneoption', 1);

        fprintf('\n** Optimal solution - minimize all flux: glucose **\n');
        [t_objGenes.GeneClasses_glc0 t_objRxns.RxnClasses_glc0 t_objModel.modelIrrev_glc0] = pFBA(model_glc, 'geneoption', 0);

        fprintf('\n** Optimal solution - minimize all flux: lactate **\n');
        [t_objGenes.GeneClasses_lac0 t_objRxns.RxnClasses_lac0 t_objModel.modelIrrev_lac0] = pFBA(model_lac, 'geneoption', 0);

        t_objGenesf = fieldnames(t_objGenes);
        t_objRxnsf = fieldnames(t_objRxns);
        t_objModelf = fieldnames(t_objModel);

        % testing if gene lists are consistent with expected lists
        t_fg = zeros(40, 1);
        cnt = 0;
        for i = 1:length(t_objGenesf)
            tmp_lists = fieldnames(t_objGenes.(t_objGenesf{i}));
            for j = 1:length(tmp_lists)
                t1 = find(~ismember(t_objGenes.(t_objGenesf{i}).(tmp_lists{j}), objGenes.(t_objGenesf{i}).(tmp_lists{j})));
                t2 = find(~ismember(objGenes.(t_objGenesf{i}).(tmp_lists{j}), t_objGenes.(t_objGenesf{i}).(tmp_lists{j})));
                cnt = cnt + 1;
                if isempty(t1)
                    t_fg(cnt) = 1;
                end
                cnt = cnt + 1;
                if isempty(t2)
                    t_fg(cnt) = 1;
                end
            end
        end

        assert(min(t_fg) == 1)

        % testing if rxn lists are consistent with expected lists
        t_fr = zeros(40, 1);
        cnt = 0;
        for i = 1:length(t_objRxnsf)
            tmp_lists = fieldnames(t_objRxns.(t_objRxnsf{i}));
            for j = 1:length(tmp_lists)
                t1 = find(~ismember(t_objRxns.(t_objRxnsf{i}).(tmp_lists{j}), objRxns.(t_objRxnsf{i}).(tmp_lists{j})));
                t2 = find(~ismember(objRxns.(t_objRxnsf{i}).(tmp_lists{j}), t_objRxns.(t_objRxnsf{i}).(tmp_lists{j})));
                cnt = cnt + 1;
                if isempty(t1)
                    t_fr(cnt) = 1;
                end
                cnt = cnt + 1;
                if isempty(t2)
                    t_fr(cnt) = 1;
                end
            end
        end

        assert(min(t_fr) == 1)

        % testing if flux minima are consistent with expected values
        t_fm = zeros(8, 1);
        cnt = 0;
        for i = 1:length(t_objModelf)
            t1 = t_objModel.(t_objModelf{i}).lb(findRxnIDs(t_objModel.(t_objModelf{i}), 'netFlux')) - objModel.(t_objModelf{i}).lb(findRxnIDs(objModel.(t_objModelf{i}), 'netFlux'));
            t2 = t_objModel.(t_objModelf{i}).ub(findRxnIDs(t_objModel.(t_objModelf{i}), 'netFlux')) - objModel.(t_objModelf{i}).ub(findRxnIDs(objModel.(t_objModelf{i}), 'netFlux'));
            cnt = cnt + 1;
            if t1 < tol
                t_fm(cnt) = 1;
            end
            cnt = cnt + 1;
            if t2 < tol
                t_fm(cnt) = 1;
            end
        end

        assert(min(t_fm) == 1)

        x = min([t_fm; t_fg; t_fr]);

        %% default parameters and a model without rxnGeneMat

        % the default is to minimise the gene-associated flux; rxnGeneMat is rebuilt from the rules
        netFluxID = @(m) findRxnIDs(m, 'netFlux');
        modelNoMat = rmfield(model_glc, 'rxnGeneMat');
        [geneClasses, rxnClasses, modelIrrev, minimizedFlux] = pFBA(modelNoMat);
        classNames = fieldnames(t_objGenes.GeneClasses_glc1);
        for i = 1:numel(classNames)
            assert(isempty(setxor(geneClasses.(classNames{i}), t_objGenes.GeneClasses_glc1.(classNames{i}))));
        end
        assert(isempty(setxor(rxnClasses.pFBAOpt_Rxns, t_objRxns.RxnClasses_glc1.pFBAOpt_Rxns)));
        assert(abs(minimizedFlux.f - t_objModel.modelIrrev_glc1.lb(netFluxID(t_objModel.modelIrrev_glc1))) < 1e-6);
        assert(abs(modelIrrev.ub(netFluxID(modelIrrev)) - minimizedFlux.f) < tol);

        %% a tolerance given by name: the classes of the default tolerance on this model

        [geneClasses, rxnClasses] = pFBA(model_glc, 'geneoption', 0, 'tol', 1e-7);
        assert(isempty(setxor(geneClasses.pFBAEssential, t_objGenes.GeneClasses_glc0.pFBAEssential)));
        assert(isempty(setxor(rxnClasses.Essential_Rxns, t_objRxns.RxnClasses_glc0.Essential_Rxns)));

        %% skipclass: only the minimised flux and the irreversible model are returned

        [geneClasses, rxnClasses, modelIrrev, minimizedFlux] = pFBA(model_glc, 'skipclass', 1, 'geneoption', 0);
        assert(isempty(geneClasses) && isempty(rxnClasses));
        assert(minimizedFlux.stat == 1);

        % the same minimum as with the classification, fixed on the netFlux reaction
        assert(abs(minimizedFlux.f - t_objModel.modelIrrev_glc0.lb(netFluxID(t_objModel.modelIrrev_glc0))) < 1e-6);
        assert(modelIrrev.lb(netFluxID(modelIrrev)) == minimizedFlux.f);
        assert(modelIrrev.ub(netFluxID(modelIrrev)) == minimizedFlux.f);

        %% an odd number of parameters is refused

        assert(verifyCobraFunctionError('pFBA', 'inputs', {model_glc, 'geneoption'}, ...
                                        'testMessage', 'Invalid number of parameters/values'));

        %% a map is written with the reaction classes

        % the map output type is set to svg when it is not set, in the file given by name; an
        % unknown parameter name is passed on to the map options
        global CB_MAP_OUTPUT
        savedMapOutput = CB_MAP_OUTPUT;
        CB_MAP_OUTPUT = [];
        map = readCbMap(which('ecoli_core_map.txt'));
        mapFile = [tempname '.svg'];
        [geneClasses, rxnClasses] = pFBA(model_glc, 'geneoption', 0, 'map', map, 'mapoutname', mapFile, 'lineWidth', 3);
        assert(strcmp(CB_MAP_OUTPUT, 'svg'));
        CB_MAP_OUTPUT = savedMapOutput;
        assert(isfile(mapFile));
        svgText = fileread(mapFile);
        delete(mapFile);
        assert(contains(svgText, '<svg'));

        % the classes do not depend on the map
        assert(isempty(setxor(geneClasses.pFBAoptima, t_objGenes.GeneClasses_glc0.pFBAoptima)));

        % output a success message
        fprintf('Done.\n');
    end
end


% change back to the root directory
cd(currentDir)
