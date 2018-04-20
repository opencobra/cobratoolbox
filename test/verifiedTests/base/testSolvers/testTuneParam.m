% The COBRAToolbox: testTuneParam.m
%
% Purpose:
%     - testTuneParam tests the CPLEX parameter tuning tool of IBM CPLEX
%
% Author:
%     - Marouen BEN GUEBILA 04/12/2017


%Define Requirements
prepareTest('requiredSolvers',{'ibm_cplex'}) %Could this also use tomlab cplex??

% load the model
model = getDistributedModel('ecoli_core_model.mat');

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTuneParam'));
cd(fileDir);

% change the solver to IBM CPLEX
solverOK = changeCobraSolver('ibm_cplex');

if solverOK
    %retrieve all IBM Cplex paramters
    cpxControl = CPLEXParamSet('ILOGcomplex');

    %set barrier as solver algorithm and set numerical emphasis to 1
    cpxControl.lpmethod = 4;
    cpxControl.emphasis.numerical = 1;

    %Optimize parameter values
    timeLimit = 5;%seconds
    nRuns = 5;%runs
    printLevel = 0;
    optimParam = tuneParam(model, cpxControl, timeLimit, nRuns, printLevel);

    %test results
    %check if automatic is the optimal solver algorithm for Ecoli and
    %numerical emphasis desactivated
    assert(isequal(optimParam.lpmethod, 0))
    assert(isequal(optimParam.emphasis.numerical, 0))
end

% change the directory
cd(currentDir)