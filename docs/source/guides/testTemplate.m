% The COBRAToolbox: <testNameOfSrcFile>.m
%
% Purpose:
%     - <provide a short description of the purpose of the test
%
% Authors:
%     - <major change>: <your name> <date>
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
cd(fileparts(which(mfilename)));

% set the tolerance
tol = 1e-8;

% define the solver packages to be used to run this test
solverPkgs = {'tomlab_cplex', 'glpk', 'gurobi6'};

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
catch
    parTest = false;
    disp('Some info whether the test is not run if no parallel toolbox is present')
end
if parTest 
% if paralell toolbox has to be present (if not, this can be left out).
%}

for k = 1:length(solverPkgs)
    fprintf(' -- Running <testFile> using the solver interface: %s ... ', solverPkgs{k});

    solverLPOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverLPOK
        % <your test goes here>
    end
    verifyCobraFunctionError(@() testFile(wrongInput));
    % output a success message
    fprintf('Done.\n');
end

% change the directory
cd(currentDir)
