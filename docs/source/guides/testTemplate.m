% The COBRAToolbox: <testNameOfSrcFile>.m
%
% Purpose:
%     - <provide a short description of the purpose of the test
%
% Authors:
%     - <major change>: <your name> <date>
%

global CBTDIR

%Define the features required to run the test

%These are the names of the toolboxes as used in
%license('test','featurename')
requiredToolboxes = {'bioinformatics_toolbox','optimization_toolbox'};
%requiredSolvers lists all solvers that need to be present for the test to
%run. Make sure this is only used if there is an explicit requirement for a
%specific solver. Otherwise indicate the type of required solver. (see
%below)
requiredSolvers = {'dqqMinos','matlab'};

%Now, check if the specified requirements are fullFilled. 
%You can also require solvers for a specific type of problem by
%e.g. using COBRARequisitesFullfilled('needLP', true)  to declare that a LP solver is required for the test. 
%For other problem types (NLP,MILP,MIQP,QP) replace LP by the respective problem type.
%You can further specify that the test only runs on windows/mac/linux/unix
%by specifying 'needsWindows',true
%For more details and examples please have a look at this guide:
%https://github.com/opencobra/cobratoolbox/blob/master/docs/source/guides/testGuide.md

%Require the bioinformatics and optimization toolbox (specified above),
%along with dqqMinos and matlab as solvers (also specified above)
%solvers will contain a cell arrays of solver names.
solversPkgs = COBRARequisitesFullfilled('reqSolvers',requiredSolvers,'requiredToolboxes',requiredToolboxes);




% save the current path
currentDir = pwd;

% initialize the test
cd(fileparts(which(mfilename)));

% set the tolerance
tol = 1e-8;

% load the model
%Either:
model = getDistributedModel('ecoli_core_model.mat'); %For all models in the test/models folder and subfolders
%or
model = readCbModel('testModel.mat','modelName','NameOfTheModelStruct'); %For all models which are part of this particular test.

%Load reference data
load('testData_functionToBeTested.mat');

%{
% This is only necessary for tests that test a function that runs in parallel.
% create a parallel pool
% This is in try/catch as otherwise the test will error if no parallel
% toolbox is installed.
try
    parTest = true;
    poolobj = gcp('nocreate'); % if no pool, do not create new one.
    if isempty(poolobj)
        parpool(2); % launch 2 workers
    end
catch ME
    parTest = false;
    fprintf('No Parallel Toolbox found. TRying test without Parallel toolbox.\n')
end
if parTest 
% if parallel toolbox has to be present (if not, this can be left out).
%}

for k = 1:length(solverPkgs.LP)
    fprintf(' -- Running <testFile> using the solver interface: %s ... ', solverPkgs.LP{k});

    solverLPOK = changeCobraSolver(solverPkgs.LP{k}, 'LP', 0);

    if solverLPOK
        % <your test goes here>
    end
    verifyCobraFunctionError(@() testFile(wrongInput));
    % output a success message
    fprintf('Done.\n');
end

% change the directory
cd(currentDir)
