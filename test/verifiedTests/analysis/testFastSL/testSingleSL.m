% The COBRAToolbox: testSingleSL.m
%
% Purpose:
%     - singleSL (Fast-SL) returns the single lethal reactions of a model: it computes a
%       minimal L1-norm optimal flux distribution, knocks out each reaction that carries flux
%       there (except those of eliList, by default the ATP maintenance reaction atpm) and
%       reports those whose knock-out gives a growth below cutoff * wild type growth or an
%       infeasible model. The test checks the result for every combination of the optional
%       inputs and that the progress bar it opens is closed again.
%     - Expected values are derived by hand on a six-reaction toy model: EX_A (-> A, ub 10),
%       R1 (A -> B), R2 (A -> C, ub 5), R3 (C -> B), BIO (B ->, objective) and ATPM (A ->,
%       lb 1). The wild type growth is 9 and the minimal-norm solution uses EX_A, R1, BIO and
%       ATPM (the detour R2-R3 costs twice the flux). Knocking out EX_A makes the forced ATPM
%       flux infeasible (NaN growth), knocking out BIO gives growth 0, knocking out R1 leaves
%       growth 5 through R2-R3 (lethal only for a cutoff above 5/9), and knocking out ATPM
%       raises the growth to 10.
%
% Function under test:
%     src/analysis/deletion/Syntheticlethals/Fast-SL/singleSL.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LP (minimal-norm FBA and FBA) on a six-reaction toy model, every available LP
%     solver among gurobi and glpk.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSingleSL'));
cd(fileDir);

% the solver set-up may create global variables; those created here are removed at the end
globalsBefore = who('global');

% require an LP solver; skip gracefully if none is available
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
initialSolverState = CobraSolverState.get();

% figures open before the test: singleSL opens a waitbar and must close it again
figuresBefore = findall(0, 'type', 'figure');

% the toy model (see Purpose)
rxnIds = {'EX_A'; 'R1'; 'R2'; 'R3'; 'BIO'; 'ATPM'};
model = createModel(rxnIds, rxnIds, {' -> A'; 'A -> B'; 'A -> C'; 'C -> B'; 'B -> '; 'A -> '}, ...
    'lowerBoundList', [0 0 0 0 0 1], 'upperBoundList', [10 1000 5 1000 1000 1000], 'printLevel', 0);
model = changeObjective(model, 'BIO');

for k = 1:numel(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if ~solverOK
        continue
    end
    fprintf('   Testing singleSL using %s ... \n', solvers.LP{k});

    %% defaults: cutoff 0.01, ATPM ignored
    % EX_A (infeasible knock-out, NaN growth) and BIO (growth 0) are lethal; R1 is not (growth
    % 5 > 0.01 * 9); ATPM is not analysed. The order follows the reaction order of the model.
    lethal = singleSL(model);
    assert(isequal(lethal, {'EX_A'; 'BIO'}));
    % the bounds of the input model are not changed (the knock-outs are made on a copy)
    assert(isequal(model.lb, [0; 0; 0; 0; 0; 1]) && isequal(model.ub, [10; 1000; 5; 1000; 1000; 1000]));

    %% cutoff: a reduction to 5/9 of the wild type growth is lethal for cutoff 0.6
    % an empty cutoff is the default 0.01
    assert(isequal(singleSL(model, 0.6), {'EX_A'; 'R1'; 'BIO'}));
    assert(isequal(singleSL(model, []), {'EX_A'; 'BIO'}));

    %% eliList: the listed reactions are not analysed (ATPM is then analysed: not lethal)
    assert(isequal(singleSL(model, [], {'EX_A'}), {'BIO'}));
    % an empty eliList falls back to the atpm reaction
    assert(isequal(singleSL(model, 0.01, {}), {'EX_A'; 'BIO'}));

    %% atpm: names the reaction that the default eliList ignores
    % with atpm 'BIO', BIO is ignored and EX_A is the only lethal reaction; an empty atpm is
    % 'ATPM'; an atpm that is not in the model leaves the eliList empty, so every reaction
    % with flux is analysed (ATPM is not lethal)
    assert(isequal(singleSL(model, [], [], 'BIO'), {'EX_A'}));
    assert(isequal(singleSL(model, 0.01, {'EX_A'}, []), {'BIO'}));
    assert(isequal(singleSL(model, 0.01, [], 'NONE'), {'EX_A'; 'BIO'}));
end

%% the waitbar is closed: no figure is left behind
assert(isempty(setdiff(findall(0, 'type', 'figure'), figuresBefore)));

% restore the solver state, remove the globals created by the solver set-up, restore the
% directory
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
for i = 1:numel(newGlobals)
    clear('global', newGlobals{i});
end
cd(currentDir)
