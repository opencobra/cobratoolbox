% The COBRAToolbox: testModelMultipleObjectives.m
%
% Purpose:
%     - modelMultipleObjectives solves one flux balance problem per requested objective
%       (zero-, one- and two-norm minimisation, unweighted or weighted by gene expression or by
%       the number of bonds broken and formed, and entropic thermodynamic variants) and
%       returns one solution per objective; objectives whose data are missing are dropped, and
%       an objective whose solve fails returns stat '' and the error message. The test uses a
%       toy network with three parallel reactions A -> B between an uptake and a forced
%       secretion, so that every weighted objective picks a split of the flux derived by
%       hand from the weights the function computes (expressionRxns0norm, expressionRxns1norm,
%       the bond weights with the mean for a missing value). It also checks the dropped
%       objectives, the plots of the weights for printLevel > 0 (figure layouts of lines
%       71-81) and the error path of every objective with a model that cannot be solved.
%
% Function under test:
%     src/dataIntegration/modelMultipleObjectives.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LP, cardinality and QP solves on a five-reaction toy model; every available LP
%     solver among gurobi and glpk, with gurobi for the QP problems.
%
% Coverage exemptions:
%     Lines 285-289: unreachable, the condition of line 284 ends with '&& 0'.
%     Lines 316, 350, 368, 386, 405: the entropic objectives (unWeightedTCBMflux,
%     unWeightedTCBMfluxConc, unWeightedTCBMfluxConcNorm, weightedTCBM, weightedTCBMt) call
%     entropicFluxBalanceAnalysis with tcbmParam.solver = 'mosek'; MOSEK is not installed, so
%     the call throws and the line is not counted. The error path of these objectives is
%     covered (failing model of the last section); their solutions are not asserted.
%     Lines 323-337: the objective 'weightedTCBMflux' is skipped (limitation below).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A model without expressionRxns stops with an error unless all three weight fields are given
%       SEVERITY: limitation
%       TRIGGER: model = createModel({'R1'; 'R2'; 'R3'}, {'r1'; 'r2'; 'r3'}, {' -> A'; 'A -> B';
%         'B -> '}); model.lb = [0; 0; 0]; model.ub = [10; 10; 10]; model.c = [0; 0; 1];
%         model.SConsistentRxnBool = [false; true; false]; modelMultipleObjectives(model,
%         struct('objectives', {{'unWeighted1norm'}}))
%       OBSERVED: (R2025a, 2026-11-25) "Unrecognized field name "expressionRxns"." at line 213,
%         although lines 203-204 handle a model without expressionRxns; line 204 removes the
%         objectives containing 'GE0', a text that no objective name contains
%       EXPECTED: the documented model lists expressionRxns among its fields, so the input is
%         not documented; the code's check suggests it was meant to be optional
%       LINES: 204, 213, 219
%     - DEFECT: A model with bondsE but without bondsBF stops with an error
%       SEVERITY: limitation
%       TRIGGER: the model of the first entry with model.expressionRxns = [1; 2; NaN] and
%         model.bondsE = [1; 2; 3], no bondsBF; modelMultipleObjectives(model,
%         struct('objectives', {{'unWeighted1norm'}}))
%       OBSERVED: (R2025a, 2026-11-25) "Unrecognized field name "bondsBF"." at line 191, which
%         compares the length of bondsBF (not bondsE) with the reactions; line 196 also uses
%         the NaN entries of bondsBF; the bond-enthalpy weights are not used by any objective
%       EXPECTED: the documented model lists both fields; the check of line 191 was evidently
%         meant for bondsE
%       LINES: 191, 196
%     - DEFECT: The objective weightedTCBMflux stores its solution under unWeightedTCBMflux
%       SEVERITY: limitation
%       TRIGGER: modelMultipleObjectives(model, struct('objectives', {{'weightedTCBMflux'}}))
%         for any model
%       OBSERVED: (code reading, R2025a, 2026-11-25) lines 333-336 assign
%         solutions.unWeightedTCBMflux, so the output field weightedTCBMflux listed in the help
%         is never set and a requested unWeightedTCBMflux is overwritten; the objective is not
%         among the supported objectives of the help, its weights are a TODO (line 325), and
%         it needs MOSEK
%       EXPECTED: the solution in solutions.weightedTCBMflux, as the output list documents
%       LINES: 333, 335-336
%     - DEFECT: After the first failed objective, every later objective prints the error report again
%       SEVERITY: cosmetic
%       TRIGGER: any objective list in which an objective fails, for example the model of the
%         last section with several objectives
%       OBSERVED: (R2025a, 2026-11-25) hasErrored (line 297) is never reset, so line 510
%         prints the report of the last error after every following objective, also after
%         objectives that were solved
%       EXPECTED: one report per failed objective
%       LINES: 297, 509-510
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testModelMultipleObjectives'));
cd(fileDir);

% require LP and QP solvers; skip gracefully if none is available
solvers = prepareTest('needsLP', true, 'needsQP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});

% the solver selection is saved and restored; globals created by the solver interfaces
% (entropicFluxBalanceAnalysis reads the EP, NLP and CLP parameters) are removed at the end
globalsBefore = who('global');
initialSolverState = CobraSolverState.get();

% figures of the weights are drawn invisibly and closed at the end
previousFigureVisible = get(0, 'DefaultFigureVisible');
set(0, 'DefaultFigureVisible', 'off');
figuresBefore = findall(0, 'Type', 'figure');

% tolerances: LP solutions are exact to the solver's feasibility tolerance; the QP splits
% are derived without the 1e-6 regularisation the function adds, so they agree to ~1e-5
tolLP = 1e-6;
tolQP = 1e-5;

% toy network: EX_A takes up A, three parallel reactions R2, R4, R5 convert A to B, EX_B
% secretes B and is forced to carry 1 (lb = 1); the objective min EX_B is therefore 1 and the
% norm objectives choose how the unit flux is split between R2, R4 and R5
validModel = createModel({'EX_A'; 'R2'; 'R4'; 'R5'; 'EX_B'}, {'EX_A'; 'R2'; 'R4'; 'R5'; 'EX_B'}, ...
    {' -> A'; 'A -> B'; 'A -> B'; 'A -> B'; 'B -> '});
validModel.lb = [0; 0; 0; 0; 1];
validModel.ub = [10; 10; 10; 10; 10];
validModel.c = [0; 0; 0; 0; 1];
validModel.SConsistentRxnBool = [false; true; true; true; false];
% expression: R2 10, R4 0.1, R5 and the exchanges unknown. The function derives
%   0-norm weights -log(e)/log(10) = [0; -1; 1; 0; 0] (unknown -> 0),
%   1-norm weights -(log(e) - log(10)) = [.; 0; log(100); .; .], unknown -> mean = log(10),
%   exchanges -> 0: [0; 0; log(100); log(10); 0]; the 2-norm weights are the 1-norm weights
validModel.expressionRxns = [NaN; 10; 0.1; NaN; NaN];
% bonds broken and formed: R2 1, R4 3, R5 unknown -> mean 2, exchanges -> 0
validModel.bondsBF = [NaN; 1; 3; NaN; NaN];
validModel.bondsE = [NaN; 1; 2; 3; NaN];
validModel.DfGt0 = [0; 0];
% g0 and g1 are removed before solving
validModel.g0 = [0; 5; 0; 0; 0];
validModel.g1 = [0; 5; 0; 0; 0];

isR2 = strcmp(validModel.rxns, 'R2');
isR4 = strcmp(validModel.rxns, 'R4');
isR5 = strcmp(validModel.rxns, 'R5');
parallel = isR2 | isR4 | isR5;

% checks shared by every solved objective: optimal, steady state, bounds, EX_B = 1
checkSolution = @(solution, tol) solution.stat == 1 ...
    && norm(validModel.S * solution.v, inf) < tol ...
    && all(solution.v >= validModel.lb - tol) && all(solution.v <= validModel.ub + tol) ...
    && abs(solution.v(5) - 1) < tol && abs(sum(solution.v(parallel)) - 1) < tol;

allObjectives = {'unWeighted0norm'; 'Weighted0normGE'; 'Weighted0normBBF'; ...
    'unWeighted1norm'; 'Weighted1normGE'; 'Weighted1normBBF'; ...
    'unWeighted2norm'; 'Weighted2normGE'; 'Weighted2normBBF'};

qpSolverOK = changeCobraSolver(solvers.QP{1}, 'QP', 0);

for k = 1:length(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if solverOK && qpSolverOK
        fprintf('   Testing modelMultipleObjectives using %s ... \n', solvers.LP{k});

        %% every norm objective on the toy network
        solutions = modelMultipleObjectives(validModel, struct('objectives', {allObjectives}));
        assert(isequal(sort(fieldnames(solutions)), sort(allObjectives)));
        for i = 1:numel(allObjectives)
            assert(checkSolution(solutions.(allObjectives{i}), tolQP));
        end

        % zero norm: one parallel reaction suffices, so three reactions carry flux
        assert(nnz(abs(solutions.unWeighted0norm.v) > tolLP) == 3);
        % weighted zero norm by expression: weight +1 on R4 (avoid), -1 on R2 (use)
        assert(abs(solutions.Weighted0normGE.v(isR4)) < tolLP);
        % weighted zero norm by bonds: R2 has the smallest weight (1 < 2 < 3)
        assert(abs(solutions.Weighted0normBBF.v(isR2) - 1) < tolLP);

        % one norm: every split costs 3
        assert(abs(norm(solutions.unWeighted1norm.v, 1) - 3) < tolLP);
        % weighted one norm: R2 has weight 0 (expression) and 1 (bonds), the smallest
        assert(abs(solutions.Weighted1normGE.v(isR2) - 1) < tolLP);
        assert(abs(solutions.Weighted1normBBF.v(isR2) - 1) < tolLP);

        % two norm: equal weights split the flux equally
        assert(max(abs(solutions.unWeighted2norm.v(parallel) - 1/3)) < tolQP);
        % weighted two norm: v proportional to 1 / weight; expression weights 1e-6 (R2) and
        % >= log(10) (R4, R5) send almost all flux through R2 (1 - 7e-7 by hand). The
        % objective changes by only ~1e-6 over this range, so the QP solver's optimality
        % tolerance sets the accuracy (gurobi returned 0.99997 on 2026-11-25): tolerance 1e-3
        assert(abs(solutions.Weighted2normGE.v(isR2) - 1) < 1e-3);
        % bond weights 1, 3, 2 (+1e-6) give 6/11, 2/11, 3/11; this also proves that the
        % missing bond count of R5 is replaced by the mean 2
        assert(abs(solutions.Weighted2normBBF.v(isR2) - 6/11) < tolQP);
        assert(abs(solutions.Weighted2normBBF.v(isR4) - 2/11) < tolQP);
        assert(abs(solutions.Weighted2normBBF.v(isR5) - 3/11) < tolQP);

        %% infeasible model: the weighted two-norm solution is marked INFEASIBLE
        % EX_B must carry 20 but EX_A is capped at 10
        infeasibleModel = validModel;
        infeasibleModel.lb(5) = 20;
        solutions = modelMultipleObjectives(infeasibleModel, ...
            struct('objectives', {{'Weighted2normGE'}}));
        % no solution is optimal (the status code for infeasibility differs between solvers)
        assert(solutions.Weighted2normGE.stat ~= 1);
        % the message is set only for the solver status text 'INFEASIBLE' (gurobi)
        if isequal(solutions.Weighted2normGE.origStat, 'INFEASIBLE')
            assert(isequal(solutions.Weighted2normGE.message, 'INFEASIBLE'));
        end
    end
end

%% default parameters (gurobi QP and the first LP solver)
% the seven default objectives are solved; unWeightedTCBMflux needs MOSEK, so only its
% presence is checked
changeCobraSolver(solvers.LP{1}, 'LP', 0);
solutions = modelMultipleObjectives(validModel);
defaultObjectives = {'unWeighted0norm'; 'Weighted0normGE'; 'unWeighted1norm'; ...
    'Weighted1normGE'; 'unWeighted2norm'; 'Weighted2normGE'};
assert(isequal(sort(fieldnames(solutions)), sort([defaultObjectives; {'unWeightedTCBMflux'}])));
for i = 1:numel(defaultObjectives)
    assert(checkSolution(solutions.(defaultObjectives{i}), tolQP));
end

%% printLevel 1: weights plotted, 8 weight sets (layout 2 x 2)
% bonds broken and formed (1), bond enthalpy (1), expression (3) and the three computed
% expression weights (3) give 8 = 2 * 2 * 2 sub-plot slots for the three histograms
solutions = modelMultipleObjectives(validModel, ...
    struct('printLevel', 1, 'objectives', {{'unWeighted1norm'}}));
assert(checkSolution(solutions.unWeighted1norm, tolLP));
figuresNow = setdiff(findall(0, 'Type', 'figure'), figuresBefore);
assert(numel(figuresNow) == 1);
assert(numel(findall(figuresNow, 'Type', 'axes')) == 3);

%% printLevel 1 with modelType 'upt': nothing is plotted
figuresPrevious = findall(0, 'Type', 'figure');
solutions = modelMultipleObjectives(validModel, ...
    struct('printLevel', 1, 'modelType', 'upt', 'objectives', {{'unWeighted1norm'}}));
assert(checkSolution(solutions.unWeighted1norm, tolLP));
assert(isempty(setdiff(findall(0, 'Type', 'figure'), figuresPrevious)));

%% no bond data: BBF objectives are dropped; 5 weight sets (prime) become 6 (layout 2 x 3)
% expression (3) and two computed weights (expressionRxns0norm is given) give 5
noBondsModel = rmfield(validModel, {'bondsBF', 'bondsE', 'DfGt0'});
noBondsModel.expressionRxns0norm = [0; -1; 1; 0; 0];
figuresPrevious = findall(0, 'Type', 'figure');
solutions = modelMultipleObjectives(noBondsModel, ...
    struct('printLevel', 1, 'objectives', {{'Weighted1normBBF'; 'Weighted0normGE'}}));
assert(isequal(fieldnames(solutions), {'Weighted0normGE'}));
assert(checkSolution(solutions.Weighted0normGE, tolLP));
assert(abs(solutions.Weighted0normGE.v(isR4)) < tolLP);
newFigure = setdiff(findall(0, 'Type', 'figure'), figuresPrevious);
assert(numel(findall(newFigure, 'Type', 'axes')) == 3);

%% all weights given: 3 weight sets (prime, layout 1 x 3)
% the given 1-norm weights are used as they are: R5 cheapest
givenWeightsModel = noBondsModel;
givenWeightsModel.expressionRxns1norm = [0; 2; 3; 1; 0];
givenWeightsModel.expressionRxns2norm = [0; 2; 3; 1; 0];
figuresPrevious = findall(0, 'Type', 'figure');
solutions = modelMultipleObjectives(givenWeightsModel, ...
    struct('printLevel', 1, 'objectives', {{'Weighted1normGE'}}));
assert(checkSolution(solutions.Weighted1normGE, tolLP));
assert(abs(solutions.Weighted1normGE.v(isR5) - 1) < tolLP);
newFigure = setdiff(findall(0, 'Type', 'figure'), figuresPrevious);
assert(numel(findall(newFigure, 'Type', 'axes')) == 3);

%% no expression data but all weights given: 0 weight sets, an empty figure
noExpressionModel = rmfield(givenWeightsModel, 'expressionRxns');
figuresPrevious = findall(0, 'Type', 'figure');
solutions = modelMultipleObjectives(noExpressionModel, ...
    struct('printLevel', 1, 'objectives', {{'Weighted1normGE'}}));
assert(abs(solutions.Weighted1normGE.v(isR5) - 1) < tolLP);
newFigure = setdiff(findall(0, 'Type', 'figure'), figuresPrevious);
assert(numel(newFigure) == 1);
assert(isempty(findall(newFigure, 'Type', 'axes')));

%% a model that cannot be solved: every objective returns stat '' and the error message
% without S every solve (optimizeCbModel, entropicFluxBalanceAnalysis) fails; the error is
% caught by design (weightedTCBMflux is skipped, see the limitation above)
failingModel = rmfield(validModel, 'S');
failingModel.DfG0 = [0; 0];
failingObjectives = [allObjectives; {'unWeightedTCBMflux'; 'unWeightedTCBMfluxConc'; ...
    'unWeightedTCBMfluxConcNorm'; 'weightedTCBM'; 'weightedTCBMt'}];
solutions = modelMultipleObjectives(failingModel, struct('objectives', {failingObjectives}));
assert(isequal(sort(fieldnames(solutions)), sort(failingObjectives)));
for i = 1:numel(failingObjectives)
    assert(isequal(solutions.(failingObjectives{i}).stat, ''));
    assert(ischar(solutions.(failingObjectives{i}).message));
    assert(~isempty(solutions.(failingObjectives{i}).message));
end

% close the figures, restore the figure default and the solver selection
close(setdiff(findall(0, 'Type', 'figure'), figuresBefore));
set(0, 'DefaultFigureVisible', previousFigureVisible);
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
if ~isempty(newGlobals)
    clear('global', newGlobals{:});
end

% change the directory
cd(currentDir)
