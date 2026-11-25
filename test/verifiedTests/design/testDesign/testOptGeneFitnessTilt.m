% The COBRAToolbox: testOptGeneFitnessTilt.m
%
% Purpose:
%     - optGeneFitnessTilt(rxn_vector_matrix, model, targetRxn, rxnListInput, isGeneList) is the
%       fitness function optGene uses: for each row of the population it knocks out the selected
%       reactions (or genes, with deleteModelGenes, building rxnGeneMat when it is missing),
%       adds a small weight (0.001) for the transport of the target to the objective
%       (augmentBOF), solves the tilted FBA and returns minus the target flux when the tilted
%       objective is at least 0.1 (0 when the value is above -1e-3). Rows with more knock-outs
%       than the global MaxKnockOuts, infeasible rows and rows with an objective below 0.1 get
%       0; computed values are cached in the global java.util.Hashtable HTABLE, which is
%       replaced by an empty one when it holds more than 50000 entries. Expected values are
%       derived by hand below.
%
% Function under test:
%     src/design/optGeneFitnessTilt.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - one LP per population row on a hand-built nine-reaction model, every available
%     LP solver among gurobi and glpk.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The globals HTABLE and MaxKnockOuts are required but not documented
%       SEVERITY: limitation
%       TRIGGER: clear global HTABLE; optGeneFitnessTilt([0 1 0], model, 'EX_P', {'R1'; 'R2';
%         'R5'}, false) with the model of this test
%       OBSERVED: (R2025a, gurobi, 2026-11-25) MATLAB:structRefFromNonStruct "Dot indexing is
%         not supported for variables of this type." at line 147; the cache works only after
%         the caller sets global HTABLE = java.util.Hashtable (optGene does); the limit MaxKnockOuts (line 47) is read from an
%         undocumented global as well (unset, the comparison with [] is false and no limit
%         applies). The test sets both globals and restores them.
%       EXPECTED: the globals documented in the help text, or an empty cache created when
%         HTABLE is not set
%       LINES: 21, 47, 142-153
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOptGeneFitnessTilt'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
globalsBefore = who('global');
initialSolverState = CobraSolverState.get();

% the function reads the globals HTABLE and MaxKnockOuts; keep their values to restore them
global HTABLE MaxKnockOuts
savedHTABLE = HTABLE;
savedMaxKnockOuts = MaxKnockOuts;

% Network: uptake of A (EX_A, at most 10) and D (EX_D, at most 5); R1: A -> B (gene g1);
% R2: A -> B + P (gene g2); R5: D -> P (gene g5); transport TP: P -> Pe; secretion EX_P: Pe ->;
% growth BIO: B -> (objective); maintenance ATPM: B -> (at least 1). Pe occurs only in TP and
% EX_P, so augmentBOF adds 0.001 * TP to the objective and the tilted optimum makes as much P as
% possible at the largest growth (9 = 10 B - 1 ATPM):
%   no knock-out:  P = 10 (R2) + 5 (R5) = 15, fitness -15
%   R2 out:        P = 5 (R5),                fitness -5
%   R2 and R5 out: P = 0,                     fitness 0 (above -1e-3)
%   R1 and R2 out: no B for ATPM, infeasible, fitness 0
rxnIds = {'EX_A'; 'R1'; 'R2'; 'R5'; 'EX_D'; 'TP'; 'EX_P'; 'BIO'; 'ATPM'};
model = createModel(rxnIds, rxnIds, {'A <=> '; 'A -> B'; 'A -> B + P'; 'D -> P'; 'D <=> '; ...
    'P -> Pe'; 'Pe <=> '; 'B -> '; 'B -> '}, 'lowerBoundList', [-10 0 0 0 -5 0 0 0 1], ...
    'upperBoundList', 1000 * ones(1, 9), 'grRuleList', {''; 'g1'; 'g2'; 'g5'; ''; ''; ''; ''; ''}, ...
    'printLevel', 0);
model = changeObjective(model, 'BIO');
rxnList = {'R1'; 'R2'; 'R5'};

% tolerance: fluxes are at most 15 and come from LP vertices; 1e-6 is far above the solvers'
% feasibility tolerances and far below the 1e-3 threshold of the function
tol = 1e-6;

for k = 1:length(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if ~solverOK
        continue
    end
    fprintf('   Testing optGeneFitnessTilt using %s ... \n', solvers.LP{k});

    %% reaction knock-outs: every outcome of a population row
    % rows: none, R2, R2+R5 (value above -1e-3 set to 0), R1+R2 (infeasible, no flux vector),
    % R1+R2+R5 (3 > MaxKnockOuts = 2, skipped) and R2 again (taken from the cache)
    HTABLE = java.util.Hashtable;
    MaxKnockOuts = 2;
    population = [0 0 0; 0 1 0; 0 1 1; 1 1 0; 1 1 1; 0 1 0];
    val = optGeneFitnessTilt(population, model, 'EX_P', rxnList, false);
    assert(isequal(size(val), [1, 6]));
    assert(max(abs(val - [-15 -5 0 0 0 -5])) < tol);
    % only rows that reach the end are cached, under the row written without blanks
    assert(abs(HTABLE.get('010') - (-5)) < tol);
    assert(abs(HTABLE.get('000') - (-15)) < tol);
    assert(HTABLE.get('011') == 0);
    assert(isempty(HTABLE.get('110')) && isempty(HTABLE.get('111')));

    %% the cache is used before anything else
    % a value stored under '100' is returned as is, without solving (R1 out would give -15)
    HTABLE.put('100', -7);
    val = optGeneFitnessTilt([1 0 0], model, 'EX_P', rxnList, false);
    assert(abs(val - (-7)) < tol);

    %% growth below 0.1: the row is skipped
    % without the maintenance demand (ATPM lower bound 0) R1 and R2 out leave growth 0, so the
    % tilted objective is 0.001 * 5 = 0.005 < 0.1 and the fitness is 0
    modelNoMaintenance = changeRxnBounds(model, 'ATPM', 0, 'l');
    HTABLE = java.util.Hashtable;
    val = optGeneFitnessTilt([1 1 0], modelNoMaintenance, 'EX_P', rxnList, false);
    assert(val == 0);
    assert(isempty(HTABLE.get('110')));

    %% gene knock-outs on a model without rxnGeneMat
    % rxnGeneMat is built (line 27) and deleteModelGenes switches off the reaction of each gene:
    % g2 out is R2 out (-5), g1 out is R1 out (B and P from R2: 10 + 5, -15)
    modelNoGeneMat = rmfield(model, 'rxnGeneMat');
    HTABLE = java.util.Hashtable;
    val = optGeneFitnessTilt([0 1 0; 1 0 0], modelNoGeneMat, 'EX_P', {'g1'; 'g2'; 'g5'}, true);
    assert(max(abs(val - [-5 -15])) < tol);

    %% a full cache is replaced by an empty one before a new value is stored
    % with 50001 entries the next store starts a new java.util.Hashtable holding only that value
    HTABLE = java.util.Hashtable;
    for iEntry = 1:50001
        HTABLE.put(sprintf('key%d', iEntry), -1);
    end
    val = optGeneFitnessTilt([0 1 0], model, 'EX_P', rxnList, false);
    assert(abs(val - (-5)) < tol);
    assert(HTABLE.size() == 1);
    assert(abs(HTABLE.get('010') - (-5)) < tol);
end

% restore the globals of the function, the solver state, and remove the globals created by
% this test
HTABLE = savedHTABLE;
MaxKnockOuts = savedMaxKnockOuts;
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
for iGlobal = 1:numel(newGlobals)
    clear('global', newGlobals{iGlobal});
end

% change the directory
cd(currentDir)
