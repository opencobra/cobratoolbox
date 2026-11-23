% The COBRAToolbox: testConsistentPotentials.m
%
% Purpose:
%     - consistentPotentials finds the minimum-norm metabolite potentials y (sum(y) = 1) that
%       agree with the directions of the internal reactions: S(:, j)' * y <= 0 for a forward-
%       only reaction, >= 0 for a reverse-only one; reversible and external reactions (and
%       reactions named ATPM or Biomass_Ecoli_core_w/GAM) are not constrained. The test checks
%       a hand-built 3-metabolite model whose QP optimum y = (6, 3, 5) / 14 for (A, B, C) is
%       derived by hand (KKT conditions below), both with the internal reactions found by
%       findSExRxnInd and with a given SIntRxnBool in which ATPM and the biomass reaction are
%       marked internal (their constraints would make that point infeasible, so the
%       unchanged optimum shows they are removed), and the optional printLevel.
%
% Function under test:
%     src/analysis/thermo/thermoFBA/consistentPotentials.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - one QP per call on a hand-built model, every available QP solver among gurobi.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConsistentPotentials'));
cd(fileDir);

% the function solves a QP: require a QP solver and use gurobi where available
globalsBefore = who('global');
solvers = prepareTest('needsQP', true, 'useSolversIfAvailable', {'gurobi'});
initialSolverState = CobraSolverState.get();

% a hand-built model:
%   EX_A   A <=>          exchange (external)
%   EX_C   C <=>          exchange (external)
%   R1     A -> 2 B       forward only:  -(2 yB - yA) >= 0, i.e. yA >= 2 yB
%   R2     B -> C         reverse only:  -(yC - yB) <= 0,  i.e. yC >= yB
%   R3     A <=> C        reversible: not constrained
% QP: min 0.5 * ||y||^2 s.t. yA >= 2 yB, yC >= yB, yA + yB + yC = 1.
% By hand: the uniform point (1/3 each) violates yA >= 2 yB, so that constraint is active
% (yA = 2 yB); minimising 5 yB^2 + yC^2 with 3 yB + yC = 1 gives yB = 3/14, yC = 5/14,
% yA = 6/14, and yC >= yB holds. KKT: multiplier of yA >= 2 yB is 1/7 >= 0, so this is the
% unique optimum of the strictly convex QP.
rxnIds = {'EX_A'; 'EX_C'; 'R1'; 'R2'; 'R3'};
rxnFormulas = {'A[c] <=>'; 'C[c] <=>'; 'A[c] -> 2 B[c]'; 'B[c] -> C[c]'; 'A[c] <=> C[c]'};
model = createModel(rxnIds, rxnIds, rxnFormulas, ...
    'lowerBoundList', [-10; -10; 0; -10; -10], 'upperBoundList', [10; 10; 10; 0; 10], ...
    'printLevel', 0);
[~, metOrder] = ismember({'A[c]'; 'B[c]'; 'C[c]'}, model.mets);
expectedPotentials = [6; 3; 5] / 14;

% the same model with ATPM (C -> A, forward: would need yC >= yA) and the E. coli core biomass
% reaction (B -> A, forward: would need yB >= yA); both are violated at the optimum above.
% SIntRxnBool is given and marks them internal, so only lines 32-33 can remove them.
modelNamed = addReaction(model, 'ATPM', 'reactionFormula', 'C[c] -> A[c]', ...
    'lowerBound', 0, 'upperBound', 10, 'printLevel', 0);
modelNamed = addReaction(modelNamed, 'Biomass_Ecoli_core_w/GAM', 'reactionFormula', ...
    'B[c] -> A[c]', 'lowerBound', 0, 'upperBound', 10, 'printLevel', 0);
modelNamed.SIntRxnBool = ~strncmp(modelNamed.rxns, 'EX_', 3);

% the optimum is computed to the QP solvers' default tolerances (1e-9 or so); 1e-6 is well
% above them and far below the differences between the potentials (1/14)
tol = 1e-6;

for k = 1:numel(solvers.QP)
    solverName = solvers.QP{k};
    solverOK = changeCobraSolver(solverName, 'QP', 0);
    assert(solverOK == 1);
    fprintf('   Testing consistentPotentials using %s ... \n', solverName);

    %% internal reactions found by findSExRxnInd (line 30), printLevel omitted (line 36)
    potentials = consistentPotentials(model);
    assert(numel(potentials) == numel(model.mets));
    assert(all(abs(potentials(metOrder) - expectedPotentials) < tol));
    % the potentials agree with the reaction directions and are normalised
    assert(abs(sum(potentials) - 1) < tol);
    assert(model.S(:, 3)' * potentials <= tol);   % forward-only R1
    assert(model.S(:, 4)' * potentials >= -tol);  % reverse-only R2

    %% SIntRxnBool given, ATPM and the biomass reaction removed by name, printLevel given
    potentials = consistentPotentials(modelNamed, 0);
    [~, metOrderNamed] = ismember({'A[c]'; 'B[c]'; 'C[c]'}, modelNamed.mets);
    assert(all(abs(potentials(metOrderNamed) - expectedPotentials) < tol));
end

% restore the solver state and remove the globals created by this test
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
if ~isempty(newGlobals)
    clear('global', newGlobals{:});
end

% change the directory
cd(currentDir)
