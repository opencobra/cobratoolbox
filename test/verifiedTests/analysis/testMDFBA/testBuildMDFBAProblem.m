% The COBRAToolbox: testBuildMDFBAProblem.m
%
% Purpose:
%     - buildMDFBAProblem builds the mixed-integer problem of metabolite dilution FBA from a
%       model: the LP of buildOptProblemFromModel extended by the variables k (absolute flux),
%       d (dilution), i_act (metabolite use) and the binary y for every metabolite that is not
%       ignored, with the constraints S*v - d = b, k - v >= 0, k + v >= 0, abs(S)*k - i_act = 0,
%       -i_act - M1*y >= -M1 and d + minProd*y = minProd. The problem is only built; no solver
%       is called.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: the problem sizes asserted below were recorded from the first run on
%       2026-11-03 with ecoli_core_model (no solver). They were not derived independently, so
%       they guard consistency, not independent correctness (Tier 5). Every block of the
%       constraint matrix is also compared with the model, and the default minimal production
%       (max(abs([lb; ub])) / 10000) and big-M constant (10000 * max(abs([lb; ub]))) are
%       computed from the model bounds.
%
% Function under test:
%     src/analysis/mdFBA/buildMDFBAProblem.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model loaded through getDistributedModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testBuildMDFBAProblem'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the model once (95 reactions, 72 metabolites)
model = getDistributedModel('ecoli_core_model.mat');
[nMets, nRxns] = size(model.S);

% the LP of the model that the function extends
basicLP = buildOptProblemFromModel(model);

%% default options: every metabolite gets dilution variables

mdfbaProblem = buildMDFBAProblem(model);

% variables: v (95), k (95), then d, i_act and y (72 each); constraints: the 72 mass balances,
% 2 x 95 absolute-value rows and 3 x 72 metabolite rows (Tier-5 sizes, first run 2026-11-03)
nVars = nRxns + nRxns + 3 * nMets;
nCtrs = nMets + 2 * nRxns + 3 * nMets;
assert(isequal(size(mdfbaProblem.A), [nCtrs, nVars]));
assert(isequal(size(mdfbaProblem.A), [478, 406]));

% every vector has one entry per variable or constraint
assert(all(cellfun(@(f) isequal(size(mdfbaProblem.(f)), [nVars, 1]), {'lb', 'ub', 'c', 'vartype', 'x0'})));
assert(all(cellfun(@(f) isequal(size(mdfbaProblem.(f)), [nCtrs, 1]), {'b', 'csense'})));

% the default minimal production and big-M follow from the model bounds (exact: a division and a
% multiplication of the largest bound, 1000)
minProd = max([abs(model.lb); model.ub]) / 10000;
bigM = 10000 * max([basicLP.ub; abs(basicLP.lb)]);
assert(minProd == 0.1 && bigM == 1e7);

% column and row ranges of the blocks
vCols = 1:nRxns;
kCols = nRxns + (1:nRxns);
dCols = 2 * nRxns + (1:nMets);
iCols = 2 * nRxns + nMets + (1:nMets);
yCols = 2 * nRxns + 2 * nMets + (1:nMets);
balanceRows = 1:nMets;
posRows = nMets + (1:nRxns);
negRows = nMets + nRxns + (1:nRxns);
useRows = nMets + 2 * nRxns + (1:nMets);
bigMRows = nMets + 2 * nRxns + nMets + (1:nMets);
prodRows = nMets + 2 * nRxns + 2 * nMets + (1:nMets);
A = mdfbaProblem.A;
I = speye(nMets);

% the constraint blocks are those of the formulation in the purpose (exact: copies of S, of the
% identity and of the constants)
assert(isequal(A(balanceRows, :), [basicLP.A, sparse(nMets, nRxns), -I, sparse(nMets, 2 * nMets)]));
assert(isequal(A(posRows, :), [speye(nRxns), speye(nRxns), sparse(nRxns, 3 * nMets)]));
assert(isequal(A(negRows, :), [-speye(nRxns), speye(nRxns), sparse(nRxns, 3 * nMets)]));
assert(isequal(A(useRows, :), [sparse(nMets, nRxns), abs(model.S), sparse(nMets, nMets), -I, sparse(nMets, nMets)]));
assert(isequal(A(bigMRows, :), [sparse(nMets, 2 * nRxns + nMets), -I, -bigM * I]));
assert(isequal(A(prodRows, :), [sparse(nMets, 2 * nRxns), I, sparse(nMets, nMets), minProd * I]));

% right-hand side and senses of each block
assert(isequal(mdfbaProblem.b, [basicLP.b; zeros(2 * nRxns + nMets, 1); -bigM * ones(nMets, 1); minProd * ones(nMets, 1)]));
assert(isequal(mdfbaProblem.csense, [basicLP.csense; repmat('G', 2 * nRxns, 1); repmat('E', nMets, 1); ...
    repmat('G', nMets, 1); repmat('E', nMets, 1)]));

% bounds: the flux bounds of the model, k and i_act from 0 to inf, d from 0 to minProd, y from
% 0 to 1; only the y variables are binary; the objective is the model objective on v
assert(isequal(mdfbaProblem.lb, [model.lb; zeros(nRxns + 3 * nMets, 1)]));
assert(isequal(mdfbaProblem.ub(vCols), model.ub));
assert(all(isinf(mdfbaProblem.ub([kCols, iCols]))));
assert(all(mdfbaProblem.ub(dCols) == minProd) && all(mdfbaProblem.ub(yCols) == 1));
assert(isequal(mdfbaProblem.vartype, [repmat('C', nRxns + nRxns + 2 * nMets, 1); repmat('B', nMets, 1)]));
assert(isequal(mdfbaProblem.c, [model.c; zeros(nRxns + 3 * nMets, 1)]));

% the model maximises (osense -1) and the starting point is zero
assert(mdfbaProblem.osense == -1);
assert(isequal(mdfbaProblem.x0, zeros(nVars, 1)));

%% ignored metabolites and a given minimal production

ignoredMets = {'h2o[c]'; 'h[c]'};
givenMinProd = 0.01;
mdfbaProblem = buildMDFBAProblem(model, 'ignoredMets', ignoredMets, 'minProd', givenMinProd);

% the ignored metabolites get no d, i_act or y variable: 70 metabolites remain (Tier-5 sizes,
% first run 2026-11-03)
relMets = ~ismember(model.mets, ignoredMets);
nRelMets = nnz(relMets);
nVars = 2 * nRxns + 3 * nRelMets;
nCtrs = nMets + 2 * nRxns + 3 * nRelMets;
assert(nRelMets == 70);
assert(isequal(size(mdfbaProblem.A), [nCtrs, nVars]));
assert(isequal(size(mdfbaProblem.A), [472, 400]));
assert(numel(mdfbaProblem.b) == nCtrs && numel(mdfbaProblem.lb) == nVars && numel(mdfbaProblem.vartype) == nVars);

% the mass balance of an ignored metabolite has no dilution term; the other balances have -d
dCols = 2 * nRxns + (1:nRelMets);
identityMets = speye(nMets);
assert(isequal(mdfbaProblem.A(1:nMets, dCols), -identityMets(:, relMets)));
assert(nnz(mdfbaProblem.A(~relMets, dCols)) == 0);

% the use rows only hold the rows of abs(S) of the remaining metabolites
useRows = nMets + 2 * nRxns + (1:nRelMets);
assert(isequal(mdfbaProblem.A(useRows, nRxns + (1:nRxns)), abs(model.S(relMets, :))));

% the given minimal production is the upper bound of d, the coefficient of y and the right-hand
% side of the production rows (exact copies of the given value)
prodRows = nMets + 2 * nRxns + 2 * nRelMets + (1:nRelMets);
yCols = 2 * nRxns + 2 * nRelMets + (1:nRelMets);
assert(all(mdfbaProblem.ub(dCols) == givenMinProd));
assert(all(mdfbaProblem.b(prodRows) == givenMinProd));
assert(isequal(mdfbaProblem.A(prodRows, yCols), givenMinProd * speye(nRelMets)));

%% metabolites that are not in the model are rejected

assert(verifyCobraFunctionError('buildMDFBAProblem', 'inputs', {model, 'ignoredMets', {'notAMetabolite[c]'}}));

% change the directory
cd(currentDir)
