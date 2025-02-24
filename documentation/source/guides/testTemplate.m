% The COBRAToolbox: <testNameOfSrcFile>.m
%
% Purpose:
%     - <provide a short description of the purpose of the test
%
% Authors:
%     - <major change>: <your name> <date>
%

global CBTDIR

% define the features required to run the test
requiredToolboxes = { 'bioinformatics_toolbox', 'optimization_toolbox' };

requiredSolvers = { 'dqqMinos', 'matlab' };

% require the specified toolboxes and solvers, along with a UNIX OS
solversPkgs = prepareTest('reqSolvers', requiredSolvers, 'requiredToolboxes', requiredToolboxes, 'needUnix', true);

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% determine the test path for references
testPath = pwd;

% set the tolerance
tol = 1e-8;

% load the model
%Either:
model = getDistributedModel('ecoli_core_model.mat'); %For all models in the test/models folder and subfolders
%or
model = readCbModel('testModel.mat','modelName','NameOfTheModelStruct'); %For all models which are part of this particular test.

%Load reference data
load([testPath filesep 'testData_functionToBeTested.mat']);

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
    wrongInputs = {'FirstArgument',modelForSecondArgument};
    verifyCobraFunctionError('testFile', 'inputs', wrongInputs);
    % output a success message
    fprintf('Done.\n');
end

% change the directory
cd(currentDir)
