% The COBRAToolbox: testRandomKO.m
%
% Purpose:
%     - randomKO(modelRed, selectedRxns, N) draws N distinct reactions of selectedRxns at
%       random (redrawing while a draw repeats a reaction), knocks them out, maximises the
%       objective and returns the exchange reactions with a flux above 1e-6 (products), their
%       rates, the knocked-out reactions and the objective value; when the knock-out strain has
%       no solution it draws a new set (recursive call in the catch block). The test checks the
%       outputs against an independent FBA of the reported knock-out strain and the hand
%       derivation below.
%
% Function under test:
%     src/design/randomKO.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - a few LPs on a hand-built seven-reaction model, every available LP solver among
%     gurobi and glpk.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: N larger than the number of selectable reactions never returns
%       SEVERITY: limitation
%       TRIGGER: randomKO(model, {'R1'; 'R2'}, 3) with the model of this test
%       OBSERVED: (R2025a, gurobi, 2026-11-25) the call had not returned when the session was
%         killed after 100 s: three distinct indices cannot be drawn from two, so the while
%         loop redraws forever
%       EXPECTED: an error saying that N exceeds the number of selectable reactions
%       LINES: 25-36
%     - DEFECT: When every selectable knock-out set is infeasible the function never returns
%       SEVERITY: limitation
%       TRIGGER: randomKO(model, {'R2'; 'R5'}, 2) with the model of this test
%       OBSERVED: (R2025a, gurobi, 2026-11-25) the call had not returned when the session was
%         killed after 150 s: the catch block (no error identifier or message checked) redraws
%         and recurses for every failure, whatever its cause
%       EXPECTED: an error once no feasible knock-out set can be found (or the original error
%         propagated)
%       LINES: 45-61
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRandomKO'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
globalsBefore = who('global');
initialSolverState = CobraSolverState.get();

% Network: uptake of A (EX_A, at most 10) and D (EX_D, at most 5); R1: A -> B; R2: A -> B + P;
% R5: D -> P; growth BIO: B -> (objective); secretion of P, EX_P, at least 1. Growth is
% 10 whenever R1 or R2 is active; with R1 and R2 knocked out growth is 0 (P still comes from
% D); with R2 and R5 knocked out no P is made, so EX_P >= 1 is infeasible.
rxnIds = {'EX_A'; 'R1'; 'R2'; 'R5'; 'EX_D'; 'BIO'; 'EX_P'};
model = createModel(rxnIds, rxnIds, {'A <=> '; 'A -> B'; 'A -> B + P'; 'D -> P'; 'D <=> '; ...
    'B -> '; 'P <=> '}, 'lowerBoundList', [-10 0 0 0 -5 0 1], ...
    'upperBoundList', 1000 * ones(1, 7), 'printLevel', 0);
model = changeObjective(model, 'BIO');
selectedRxns = {'R1'; 'R2'; 'R5'};

% tolerance: fluxes are at most 15 and come from LP vertices; 1e-6 is the threshold the function
% itself uses for products and far above the solvers' feasibility tolerances
tol = 1e-6;

for k = 1:length(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if ~solverOK
        continue
    end
    fprintf('   Testing randomKO using %s ... \n', solvers.LP{k});

    %% two random knock-outs: repeated draws and an infeasible draw are both redrawn
    % with rng(8) the first draw repeats a reaction (lines 30-31) and the next one is {R5, R2},
    % whose strain is infeasible: FBA returns no flux vector, the indexing fails and the catch
    % block draws again (line 60). The returned set must be two distinct reactions of
    % selectedRxns other than {R2, R5}.
    rng(8);
    [products, productRates, KOrxns, BOF] = randomKO(model, selectedRxns, 2);
    assert(numel(KOrxns) == 2 && numel(unique(KOrxns)) == 2);
    assert(all(ismember(KOrxns, selectedRxns)));
    assert(~isempty(setdiff({'R2'; 'R5'}, KOrxns)));
    % BOF is the optimal growth of the reported knock-out strain (independent FBA)
    modelKO = changeRxnBounds(model, KOrxns, 0, 'b');
    solKO = optimizeCbModel(modelKO, 'max');
    assert(solKO.stat == 1);
    assert(abs(BOF - solKO.f) < tol);
    % only EX_P can carry a positive exchange flux (A and D are only taken up, BIO is the
    % objective and excluded); its rate lies between its lower bound 1 and the 15 units of P
    % that R2 and R5 can make
    assert(isequal(products, {'EX_P'}));
    assert(numel(productRates) == 1);
    assert(productRates >= 1 - tol && productRates <= 15 + tol);

    %% one knock-out from a single candidate: R1 out, growth through R2 only
    % growth 10 needs 10 B from R2, which makes 10 P, so EX_P is at least 10 (at most 15 with
    % the 5 units of D)
    rng(1);
    [products, productRates, KOrxns, BOF] = randomKO(model, {'R1'}, 1);
    assert(isequal(KOrxns, {'R1'}));
    assert(abs(BOF - 10) < tol);
    assert(isequal(products, {'EX_P'}));
    assert(productRates >= 10 - tol && productRates <= 15 + tol);
end

% restore the solver state and remove the globals created by this test
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
for iGlobal = 1:numel(newGlobals)
    clear('global', newGlobals{iGlobal});
end

% change the directory
cd(currentDir)
