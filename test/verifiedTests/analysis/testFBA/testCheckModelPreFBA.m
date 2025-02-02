% The COBRAToolbox: testcheckModelPreFBA.m
%
% Purpose:
%     - testcheckModelPreFBA tests the functionality of checkModelPreFBA.m
%     function
%
% Authors:
%     - Ronan Fleming     06/11/2020
%     - Farid Zare:       21/11/2023      Revised the code
%

global CBTDIR

% define the required solvers
requiredSolvers = {'needsLP', 'matlab'};

% check if the specified requirements are fullfilled
solvers = prepareTest('needsLP', true);

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% determine the test path for references
testPath = pwd;

%Load ecoli core model
model = getDistributedModel('ecoli_core_model.mat');

%Find the internal reaction subset of the network
printLevel = -1;
model = findSExRxnInd(model,[],printLevel);

%Make an inconsistent model by adding an isolated metabolite
incModel = getDistributedModel('ecoli_core_model.mat');
incModel = addExchangeRxn(incModel, 'isolatedMet', -10, 0);

%Initialize the test
param.printLevel = 0;

for k = 1:length(solvers.LP)
    solverLPOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if solverLPOK
       fprintf(' -- Running testcheckModelPreFBA.m using the solver interface: %s ... ', solvers.LP{k});
       %Recon3DModel_301, with open external reactions, is flux and 
       %stoichiometrically consistent, so check should be positive
       isConsistent = checkModelPreFBA(model, param);
       assert(isConsistent)

       %The model containing an isolated metabolite is flux and
       %stoichiometrically inconsistent, so output must be zero
       isConsistent = checkModelPreFBA(incModel, param);
       assert(~isConsistent)

       % output a success message
       fprintf('Done.\n');
    end
end

% change the directory
cd(currentDir)
