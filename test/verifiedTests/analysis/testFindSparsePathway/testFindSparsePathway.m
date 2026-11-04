% The COBRAToolbox: findSparsePathway.m
%
% Purpose:
%     - testFindSparsePathway tests the findSparsePathway function.
%
% Function under test:
%     src/analysis/sparseFBA/findSparsePathway.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation on Recon3DModel_301 (the original pathway check) and on a toy model
%     with one short and one long route for the defaults, the penalties and the input check.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Original file: Ronan Fleming 03/02/2021
%     - Enhanced:      Farid Zare    03/06/2025
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindSparsePathway'));
cd(fileDir);

% Initialize the test
solverPkgs = prepareTest('requiredSolvers',{'gurobi'});
fprintf('   Testing findSparsePathway function using solver %s ... \n', solverPkgs.LP{1})
solverOK = changeCobraSolver(solverPkgs.LP{1}, 'LP', 0);

% try first with Recon3D
model = getDistributedModel('Recon3DModel_301.mat');
start = 'xol7aone[r]';
stop = 'cholate[c]';
s=' ';
osenseStr = 'max';

% add sink reaction for start
model = addReaction(model,['start_', start],'reactionFormula',[start,s,'-->']);
model = addReaction(model,['stop_', stop],'reactionFormula',['-->',s,stop]);
%printRxnFormula(model,model.rxns(end-1:end));

%% maximise flux through this dummy stop reaction
model = changeObjective(model,['stop_', stop]);
%force flux through this dummy start reaction
model = changeRxnBounds(model,['start_', start],-1000,'b');
model = changeRxnBounds(model,['stop_', stop],1000,'b');
model = changeRxnBounds(model,'sink_cholate[c]',0,'b');
%%
model0=model;

%%
[vSparse, sparseRxnBool1, essentialRxnBool]  = sparseFBA(model, osenseStr);
model.rxns(sparseRxnBool1);
nnz(sparseRxnBool1);
nnz(vSparse);

%%
rxnPenalty = ones(length(model.rxns),1);
param.printLevel = 1;
param.regularizeOuter = 0;
param.theta=0.1;
[solution,sparseRxnBool2] = findSparsePathway(model,rxnPenalty,param);
model.rxns(sparseRxnBool2);
nnz(sparseRxnBool2);
nnz(solution.v);

%check that both approaches give a sparse solution
assert(nnz(sparseRxnBool1)==nnz(sparseRxnBool2));

%% toy model: one unit of flux goes from A to D, by a short route or by a long route

toyRxns = {'in'; 'short'; 'long1'; 'long2'; 'long3'; 'out'};
toyFormulas = {' -> A'; 'A -> D'; 'A -> B'; 'B -> C'; 'C -> D'; 'D -> '};
toyModel = createModel(toyRxns, toyRxns, toyFormulas);
toyModel = changeRxnBounds(toyModel, 'in', 1, 'b');
isShort = ismember(toyModel.rxns, {'in'; 'short'; 'out'});
toyTol = 1e-6;

%% default penalties and parameters: every active reaction is penalised, the short route wins

[toySolution, toyBool] = findSparsePathway(toyModel);
assert(toySolution.stat == 1);
assert(isequal(toyBool, isShort));
assert(norm(toySolution.v - double(isShort)) < toyTol);
assert(norm(toyModel.S * toySolution.v) < toyTol);

%% negative penalties incentivise the long route; the parameters take their default

rxnPenalty = ones(numel(toyModel.rxns), 1);
rxnPenalty(ismember(toyModel.rxns, {'long1'; 'long2'; 'long3'})) = -1;
[toySolution, toyBool] = findSparsePathway(toyModel, rxnPenalty);
assert(toySolution.stat == 1);
assert(isequal(toyBool, ~ismember(toyModel.rxns, 'short')));
assert(norm(toyModel.S * toySolution.v) < toyTol);

%% a penalty vector of the wrong length is refused

assert(verifyCobraFunctionError('findSparsePathway', 'inputs', {toyModel, ones(2, 1)}, ...
                                'testMessage', 'rxnPenalty must be the same as size(problem.A,2)'));

% output a success message
fprintf('Done.\n');

% change the directory
cd(currentDir)
