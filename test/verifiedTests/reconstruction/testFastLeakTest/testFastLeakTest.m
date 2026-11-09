% The COBRAToolbox: testFastLeakTest.m
%
% Purpose:
%     - Test Fast Leak Test on an E.Coli Model
%     - Modify the model to give rise to some leaking metabolites.
%
% Function under test:
%     src/reconstruction/modelGeneration/fastLeakTest.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation: ecoli_core_model and a small hand-built leak.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: an error when every tested reaction leaks
%       SEVERITY: error
%       TRIGGER: a model in which every exchange and demand reaction under test carries a leak
%       OBSERVED: the list of reactions to test becomes empty, and changeObjective stops with
%         'Objective reactions not found in model!'
%       EXPECTED: the list of leaking reactions is returned
%       LINES: 61
%
% Authors:
%     - Thomas Pfau
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFastLeakTest.m'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available
prepareTest('needsLP', true);

% define the solver packages to be used to run this test
solverPkgs = {'gurobi', 'tomlab_cplex', 'glpk'};

model = getDistributedModel('ecoli_core_model.mat');

%First, we have to remove all flux forcing constraints, because they interfere with leak testing.
model.lb(model.lb > 0) = 0;
model.ub(model.ub < 0) = 0;

%Test different solvers

for k = 1:length(solverPkgs)
    % set the solver
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverOK == 1
        fprintf('   Testing empty Leak Test with solver %s ... \n', solverPkgs{k});

        [LeakMets, modelClosed, FluxExV] = fastLeakTest(model, {}, 'true');

        assert(isempty(LeakMets));
    end
end

%We will add 2 reactions which together produce one unit of the second metabolite
modelWithLeaks = addReaction(model,'A1','metaboliteList',{model.mets{1},model.mets{2}},'stoichCoeffList',[-1 2],'printLevel',-1);
modelWithLeaks = addReaction(modelWithLeaks,'A2','metaboliteList',{model.mets{2},model.mets{1}},'stoichCoeffList',[-1 1],'printLevel',-1);

for k = 1:length(solverPkgs)
    % set the solver
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverOK == 1
        fprintf('   Testing non empty Leak Test with solver %s ... \n', solverPkgs{k});

        [LeakMets, modelClosed, FluxExV] = fastLeakTest(modelWithLeaks, {}, 'true');

        assert(any(ismember(['DM_' model.mets{2}],LeakMets))|| any(ismember(['DM_' model.mets{2}],LeakMets)));
    end
end
%Now, we also test for protons (there should only be other protons then, as
%nothing else can be leaked from only protons - normally
modelWithLeaks = addReaction(model,'A1','metaboliteList',{'h[c]','h[x]'},'stoichCoeffList',[-1 2],'printLevel',-1);
modelWithLeaks = addReaction(modelWithLeaks,'A2','metaboliteList',{'h[x]','h[c]'},'stoichCoeffList',[-1 1],'printLevel',-1);

for k = 1:length(solverPkgs)
    % set the solver
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverOK == 1
        fprintf('   Testing proton Leak Test with solver %s ... \n', solverPkgs{k});

        [LeakMets, modelClosed, FluxExV] = fastLeakTest(modelWithLeaks, {}, 'true');

        %Only Protons in the leaks.
        assert(all(~cellfun(@isempty, regexp(LeakMets,'^(DM_)|(EX_)h\[[a-z]\]$'))));
    end
end

%% default demand test, and no demand reactions
modelWithLeaks = addReaction(model,'A1','metaboliteList',{model.mets{1},model.mets{2}},'stoichCoeffList',[-1 2],'printLevel',-1);
modelWithLeaks = addReaction(modelWithLeaks,'A2','metaboliteList',{model.mets{2},model.mets{1}},'stoichCoeffList',[-1 1],'printLevel',-1);
gurobiOK = changeCobraSolver('gurobi', 'LP', 0);

% leaving out the third input means demand reactions are tested
[leaksDefault, closedDefault] = fastLeakTest(modelWithLeaks, {});
[leaksDemand, closedDemand] = fastLeakTest(modelWithLeaks, {}, 'true');
assert(isequal(sort(leaksDefault), sort(leaksDemand)));
assert(numel(closedDefault.rxns) == numel(closedDemand.rxns));
assert(numel(closedDefault.rxns) == numel(modelWithLeaks.rxns) + numel(modelWithLeaks.mets));

% any other value tests the exchange reactions alone: nothing is added to the model
[leaksExchange, closedExchange, fluxExchange] = fastLeakTest(modelWithLeaks, {}, 'false');
assert(numel(closedExchange.rxns) == numel(modelWithLeaks.rxns));
assert(~isempty(leaksExchange) && all(startsWith(leaksExchange, 'EX_')));
assert(numel(fluxExchange) == numel(leaksExchange) && all(fluxExchange > 1e-6));
% every exchange reaction is closed for uptake, and the model is unchanged otherwise
exchangeBool = sum(modelWithLeaks.S ~= 0, 1)' == 1;
assert(all(closedExchange.lb(exchangeBool) == 0));
assert(isequal(closedExchange.lb(~exchangeBool), modelWithLeaks.lb(~exchangeBool)));
% the model without the added reactions does not leak through its exchange reactions
assert(isempty(fastLeakTest(model, {}, 'false')));

%% a forced flux makes the trivial solution infeasible
forcedModel = model;
forcedModel.lb(strcmp(forcedModel.rxns, 'ATPM')) = 1;
assert(verifyCobraFunctionError('fastLeakTest', 'inputs', {forcedModel, {}, 'false'}, ...
    'testMessage', ['Trivial solution is not a solution of the model.\n', ...
    'Check that you are not enforcing flux as Leak testing does not work with forced fluxes.']));

%% a leak without an upper bound makes the problem unbounded
%   L1: a -> 2 b, L2: b -> a, EX_b: b ->
unboundedModel = struct();
unboundedModel.mets = {'a[c]'; 'b[c]'};
unboundedModel.rxns = {'L1'; 'L2'; 'EX_b'};
unboundedModel.S = sparse([-1 1 0; 2 -1 -1]);
unboundedModel.lb = zeros(3, 1);
unboundedModel.ub = inf(3, 1);
unboundedModel.c = zeros(3, 1);
unboundedModel.b = zeros(2, 1);
unboundedModel.csense = ['E'; 'E'];
unboundedModel.osenseStr = 'max';
% (the status of an unbounded problem depends on the solver)
if gurobiOK
    assert(verifyCobraFunctionError('fastLeakTest', 'inputs', {unboundedModel, {}, 'false'}, ...
        'testMessage', ['Problems exist in the model, which lead to the trivial problem being unbounded or otherwise problematic.\n', ...
        'If unbounded, one option could be to reduce the maximal upper/lower bounds to a specified value.']));
end

% change to the original directory
cd(currentDir);
