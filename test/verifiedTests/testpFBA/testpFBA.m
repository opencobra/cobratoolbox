% The COBRAToolbox: testpFBA.m
%
% Purpose:
%     - tests the basic functionality of pFBA
%       Tests the basic solution for both minimizing the flux of gene-
%       associated reactions and all rxns, while growing on gluose or lactose
%       minimal media. Does not test the functionality of the map function.
%
% Authors:
%     - Original file: Nathan Lewis 08/30/10
%     - CI integration: Laurent Heirendt February 2017
%
% Note:
%     - The solver libraries must be included separately

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testpFBA'));
cd(fileDir);

%tolerance
tol = 1e-8;

% load models and expected results
load('testpFBAData.mat', 'model_glc', 'model_lac');
objGenes = load('testpFBAData.mat', 'GeneClasses_glc1', 'GeneClasses_glc0', 'GeneClasses_lac1', 'GeneClasses_lac0');
objRxns = load('testpFBAData.mat', 'RxnClasses_glc1', 'RxnClasses_glc0', 'RxnClasses_lac1', 'RxnClasses_lac0');
objModel = load('testpFBAData.mat', 'modelIrrev_glc1', 'modelIrrev_glc0', 'modelIrrev_lac1', 'modelIrrev_lac0');

% list of solver packages
solverPkgs = {'tomlab_cplex', 'gurobi6', 'glpk'};

% create a parallel pool
poolobj = gcp('nocreate'); % if no pool, do not create new one.
if isempty(poolobj)
    parpool(2); % launch 2 workers
end

for k = 1:length(solverPkgs)
    fprintf(' -- Running testfindBlockedReaction using the solver interface: %s ... ', solverPkgs{k});

    solverLPOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverLPOK

        % run pFBA
        fprintf('\n*** Test basic pFBA calculations ***\n\n');
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

        % output a success message
        fprintf('Done.\n');
    end
end

% change back to the root directory
cd(currentDir)
