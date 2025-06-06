% The COBRAToolbox: findSparsePathway.m
%
% Purpose:
%     - testFindSparsePathway tests the findSparsePathway function.
%
% Authors:
%     - Original file: Ronan Fleming 03/02/2021
%     - Enhanced:      Farid Zare    03/06/2025
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

% output a success message
fprintf('Done.\n');

% change the directory
cd(currentDir)
