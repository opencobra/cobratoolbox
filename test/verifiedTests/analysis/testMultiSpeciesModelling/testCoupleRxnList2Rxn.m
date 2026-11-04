% The COBRAToolbox: testCoupleRxnList2Rxn.m
%
% Purpose:
%     - tests the basic functionality of coupleRxnList2Rxn
%
% Function under test:
%     src/analysis/coupling/coupleRxnList2Rxn.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation on ecoli_core_model; the default arguments are checked on the
%     constraints themselves, without a solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Original file: Almut Heinken - March 2017
%     - CI integration: Laurent Heirendt - March 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%
global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCoupleRxnList2Rxn'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available
prepareTest('needsLP', true);

% test coupling constraints
model = getDistributedModel('ecoli_core_model.mat');

% remove ATPM constraint so no infeasible model is generated
model = changeRxnBounds(model, 'ATPM', 0, 'l');

% couple E. coli reactions (except exchanges and biomass) to biomass
rxnC = 'Biomass_Ecoli_core_w_GAM';
rxnList = model.rxns(find(~strncmp('EX_', model.rxns, 3)));

rxnList(strmatch('Biomass', rxnList), :) = [];

c = 400;
u = 0.01;
[modelCoupled] = coupleRxnList2Rxn(model, rxnList, rxnC, c, u);

% fix the random flux and the random reactions below, so that every run checks the same cases
rng(0);

% test if the coupling constraints work
% expected that the absolute flux through one reaction cannot be higher than (flux through rxnC*c)+u
% constrain flux through rxnC to a random value between 0.01 and 0.1
constrFlux = rand * 0.1;
modelCoupled = changeRxnBounds(modelCoupled, rxnC, constrFlux, 'u');

% set the tolerance
tol = 1e-4;

%test solver packages
solverPkgs = {'tomlab_cplex', 'gurobi', 'glpk'};

for k = 1:length(solverPkgs)

    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverOK == 1
        fprintf('   Testing coupleRxnList2Rxn using %s ... ', solverPkgs{k});
        LPproblem = buildOptProblemFromModel(modelCoupled);
        % optimize a random coupled reaction 100 times
        for i = 1:100
            rxnInd = rxnList{randi(length(rxnList), 1), 1};
            rxnPos = findRxnIDs(model,rxnInd);
            LPproblem.c(:) = 0; 
            LPproblem.c(rxnPos) = 1;
            solution = solveCobraLP(LPproblem);
            assert(abs(solution.obj) <= (constrFlux * c) + u + tol)
        end
    end

    % output a success message
    fprintf('Done.\n');
end

%% default coupling factor and threshold, reaction given in a cell

% PGI is reversible and gets two constraints, PFK is irreversible and gets one
rxnPair = {'PGI'; 'PFK'};
pairCoupled = coupleRxnList2Rxn(model, rxnPair, {rxnC}, [], []);
assert(isequal(pairCoupled.ctrs, {'slack_PGI'; 'slack_PGI_R'; 'slack_PFK'}));
assert(isequal(pairCoupled.dsense(:), ['L'; 'G'; 'L']));

% v_i - 1000 * v_rxnC <= 0.01 and v_PGI + 1000 * v_rxnC >= -0.01 (default c = 1000, u = 0.01)
assert(norm(pairCoupled.d - [0.01; -0.01; 0.01]) < 1e-12);
assert(isequal(full(pairCoupled.C(:, findRxnIDs(model, 'PGI'))), [1; 1; 0]));
assert(isequal(full(pairCoupled.C(:, findRxnIDs(model, 'PFK'))), [0; 0; 1]));
assert(isequal(full(pairCoupled.C(:, findRxnIDs(model, rxnC))), [-1000; 1000; -1000]));
assert(nnz(pairCoupled.C) == 6);

% omitted coupling arguments give the same constraints as empty ones
assert(isequal(coupleRxnList2Rxn(model, rxnPair, rxnC), pairCoupled));

%% an empty reaction list couples every reaction of the model

allCoupled = coupleRxnList2Rxn(model, [], rxnC);
assert(size(allCoupled.C, 1) == numel(model.rxns) + nnz(model.lb < 0));
assert(all(ismember(strcat('slack_', model.rxns), allCoupled.ctrs)));
assert(isequal(allCoupled, coupleRxnList2Rxn(model, {}, rxnC)));

% the upper bound of an active reaction is limited by the flux through rxnC
rowPFK = strcmp(allCoupled.ctrs, 'slack_PFK');
assert(allCoupled.C(rowPFK, findRxnIDs(model, 'PFK')) == 1);
assert(allCoupled.C(rowPFK, findRxnIDs(model, rxnC)) == -1000);

% change the directory
cd(currentDir)
