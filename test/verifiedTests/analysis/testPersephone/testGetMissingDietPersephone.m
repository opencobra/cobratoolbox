% The COBRAToolbox: testGetMissingDietPersephone.m
%
% Purpose:
%     - getMissingDietPersephone finds the closed diet exchange reactions (Diet_EX_*, lower
%       bound 0) that an infeasible microbiome or host-microbiome model needs: it opens them
%       all (lb -10, ub 0) and, if the model is then feasible, closes random batches of them
%       (50, 10, 5, then 1 at a time), keeping those whose closure makes the model
%       infeasible. Known missing components are opened first and returned together with the
%       new ones. A host-microbiome model (one with Excretion_EX_microbiota_LI_biomass[fe])
%       has its microbiota excretion and its Whole* reactions fixed to 1 and is solved with
%       optimizeWBModel; other models with optimizeCbModel.
%     - Expected values are derived by hand on toy models. Microbiome model: R (a[d] + c[d]
%       -> bio[c]) and BIO (bio[c] -> , lb 1, objective) need a[d] and c[d]; Diet_EX_c[d] is
%       open (lb -10), Diet_EX_a[d] is closed, and 60 closed diet exchanges of metabolites
%       b1[d] ... b60[d], each consumed by a sink P1 ... P60 that is part of the objective,
%       are not needed. The only missing component is therefore Diet_EX_a[d], whatever the
%       random batches (a[d] always carries flux in a feasible solution, so it is never
%       discarded; each b is discarded when closed alone). The 60 unneeded exchanges make
%       the random batches sometimes miss Diet_EX_a[d], so both outcomes (feasible and
%       infeasible) of each batch stage occur (seeds fixed). Host-microbiome model: the
%       microbiota (a[d] -> microbiota_LI_biomass[fe]) and the host (c[d] -> wb[c], Whole
%       body reaction wb[c] -> ) both have bounds 0 in the input, so the model is feasible
%       only because of the forced bounds; with them both Diet_EX_a[d] and Diet_EX_c[d] are
%       missing.
%
% Function under test:
%     src/analysis/persephone/getMissingDietPersephone.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LP on toy models: optimizeCbModel with every available LP solver among
%     gurobi and glpk; optimizeWBModel (host-microbiome model) with the solvers validated
%     for the PSCM toolbox (gurobi, ibm_cplex).
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Progress values are printed without being asked for
%       SEVERITY: cosmetic
%       TRIGGER: any call that reaches the search, e.g. getMissingDietPersephone(model) on the
%         microbiome toy model of this test
%       OBSERVED: (R2025a, gurobi, 2026-11-25) the console shows "Elapsed time is ...
%         seconds." (lines 81 and 87; line 81 measures from whatever tic the caller made
%         last), "ans = 2" for each batch (length(dietlb) without semicolon), "ans = ..."
%         objective values and the growing list potentialMissing
%       EXPECTED: no console output, or output gated behind a print level (constitution
%         VII-G); the help mentions none
%       LINES: 81, 87, 107, 121, 165, 178, 188, 208, 221, 231, 247, 261, 271
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetMissingDietPersephone'));
cd(fileDir);

% the solver set-up may create global variables; those created here are removed at the end
globalsBefore = who('global');

% require an LP solver validated for the PSCM toolbox (optimizeWBModel); glpk is also used
% for the microbiome model, which is solved with optimizeCbModel
validatedSolvers = {'gurobi', 'ibm_cplex'};
solvers = prepareTest('needsLP', true, 'requireOneSolverOf', validatedSolvers, ...
    'useSolversIfAvailable', [validatedSolvers, {'glpk'}]);
initialSolverState = CobraSolverState.get();

% the batches are random: fix the seed, restore the generator at the end
rngBefore = rng;

%% toy models (see Purpose)
nUnneeded = 60;
unneededIds = strcat('Diet_EX_b', strtrim(cellstr(num2str((1:nUnneeded)'))), '[d]');
unneededMets = strcat('b', strtrim(cellstr(num2str((1:nUnneeded)'))), '[d]');
sinkIds = strcat('P', strtrim(cellstr(num2str((1:nUnneeded)'))));
rxnIds = [{'Diet_EX_a[d]'; 'Diet_EX_c[d]'}; unneededIds; sinkIds; {'R'; 'BIO'}];
formulas = [{'a[d] <=> '; 'c[d] <=> '}; strcat(unneededMets, ' <=> '); strcat(unneededMets, ' -> '); ...
    {'a[d] + c[d] -> bio[c]'; 'bio[c] -> '}];
lowerBounds = [0; -10; zeros(2 * nUnneeded, 1); 0; 1];
microbiome = createModel(rxnIds, rxnIds, formulas, 'lowerBoundList', lowerBounds, ...
    'upperBoundList', 1000 * ones(numel(rxnIds), 1), 'printLevel', 0);
% the objective includes the sinks P1 ... P60, so an open b exchange carries flux in every
% optimal solution: it is discarded only when it is itself closed in a feasible batch
microbiome = changeObjective(microbiome, [{'BIO'}; sinkIds]);

hostIds = {'Diet_EX_a[d]'; 'Diet_EX_c[d]'; 'Micro'; 'Excretion_EX_microbiota_LI_biomass[fe]'; ...
    'Whole_body_objective_rxn'; 'Host'};
host = createModel(hostIds, hostIds, {'a[d] <=> '; 'c[d] <=> '; 'a[d] -> microbiota_LI_biomass[fe]'; ...
    'microbiota_LI_biomass[fe] -> '; 'wb[c] -> '; 'c[d] -> wb[c]'}, ...
    'lowerBoundList', zeros(6, 1), 'upperBoundList', [1000; 1000; 1000; 0; 0; 1000], 'printLevel', 0);
host = changeObjective(host, 'Whole_body_objective_rxn');

for k = 1:numel(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if ~solverOK
        continue
    end
    fprintf('   Testing getMissingDietPersephone using %s ... \n', solvers.LP{k});

    %% microbiome model, no known components (one input): the closed component it needs
    rng(3);
    missing = getMissingDietPersephone(microbiome);
    assert(isequal(missing, {'Diet_EX_a[d]'}));

    %% known components are opened first and returned with the new ones (sorted, unique)
    % Diet_EX_b1[d] is not needed, but a component given as known is kept in the output
    rng(5);
    missing = getMissingDietPersephone(microbiome, {'Diet_EX_b1[d]'});
    assert(isequal(missing, {'Diet_EX_a[d]'; 'Diet_EX_b1[d]'}));

    %% testInitialFeasibility 0: the first feasibility test is skipped, same result
    rng(7);
    missing = getMissingDietPersephone(microbiome, '', 0);
    assert(isequal(missing, {'Diet_EX_a[d]'}));

    %% a model that is already feasible returns the known list unchanged
    feasibleModel = changeRxnBounds(microbiome, 'Diet_EX_a[d]', -10, 'l');
    assert(isequal(getMissingDietPersephone(feasibleModel, {'Diet_EX_b2[d]'}), {'Diet_EX_b2[d]'}));
    assert(isempty(getMissingDietPersephone(feasibleModel)));

    %% a model that stays infeasible with all diet components open returns the known list
    % R is blocked, so no diet makes BIO >= 1 possible: nothing is searched
    blockedModel = changeRxnBounds(microbiome, 'R', 0, 'u');
    assert(isempty(getMissingDietPersephone(blockedModel)));
    assert(isequal(getMissingDietPersephone(blockedModel, {'Diet_EX_b3[d]'}), {'Diet_EX_b3[d]'}));

    %% host-microbiome model (optimizeWBModel, validated solvers only)
    % the microbiota excretion and the Whole body reaction are fixed to 1 by the function,
    % so both diet components are missing
    if any(strcmp(solvers.LP{k}, validatedSolvers))
        rng(11);
        missing = getMissingDietPersephone(host);
        assert(isequal(missing, {'Diet_EX_a[d]'; 'Diet_EX_c[d]'}));
    end
end

% restore the random generator and the solver state, remove the globals created by the
% solver set-up, restore the directory
rng(rngBefore);
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
for i = 1:numel(newGlobals)
    clear('global', newGlobals{i});
end
cd(currentDir)
