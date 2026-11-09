% The COBRAToolbox: testcheckModelPreFBA.m
%
% Purpose:
%     - testcheckModelPreFBA tests the functionality of checkModelPreFBA.m
%     function
%
% Function under test:
%     src/reconstruction/modelGeneration/checkModelPreFBA.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation: ecoli_core_model, an LP solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Ronan Fleming     06/11/2020
%     - Farid Zare:       21/11/2023      Revised the code
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
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

%% diagnostics at printLevel 2
% (the first solver is enough: these sections test the printed report and the input handling)
changeCobraSolver(solvers.LP{1}, 'LP', 0);
param.printLevel = 2;
reportText = evalc('isConsistent = checkModelPreFBA(model, param);');
assert(isConsistent);
assert(contains(reportText, 'totals.') && contains(reportText, 'heuristically exchange.'));
assert(contains(reportText, '(Check 1: minimum cardinality of conservation relaxation vector.)'));
assert(contains(reportText, '(Check 2: leak/siphon tests.)'));
assert(contains(reportText, '(Check 3: maximim cardinality conservation vector.)'));
assert(contains(reportText, '(Check 4: maximim cardinality constrained right nullspace.)'));
assert(contains(reportText, 'Open external reactions is stoichiometrically and flux consistent.'));

%% a model given by file name, and the default model and parameters
% the default model file is a large one: a copy of the small model under that name, in a temporary
% folder that is searched first, stands in for it
tempFolder = tempname;
mkdir(tempFolder);
cd(tempFolder);
save('smallCopy.mat', 'model');
assert(checkModelPreFBA('smallCopy.mat', struct('printLevel', 0)));
save('Recon3DModel_301.mat', 'model');
assert(checkModelPreFBA());
% the parameters can be left out, and printLevel defaults to 0
assert(checkModelPreFBA('smallCopy.mat'));
assert(checkModelPreFBA(model, struct()));
assert(~checkModelPreFBA(incModel));
cd(testPath);
rmdir(tempFolder, 's');

% change the directory
cd(currentDir)
