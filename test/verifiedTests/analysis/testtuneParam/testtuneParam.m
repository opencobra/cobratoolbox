% The COBRAToolbox: testtuneParam.m
%
% Purpose:
%     - testtuneParam tests the CPLEX parameter tuning tool of
%       IBM CPLEX
%
% Author:
%     - Marouen BEN GUEBILA 04/12/2017

global CBTDIR
global ILOG_CPLEX_PATH

addpath(genpath(ILOG_CPLEX_PATH));

%Load the model
model = getDistributedModel('ecoli_core_model.mat');

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testtuneParam'));
cd(fileDir);    

%findMIIS (works with IBM CPLEX)
solverOK = changeCobraSolver('ibm_cplex');

if solverOK
    cpxControl = CPLEXParamSet('ILOGcomplex');
    cpxControl.lpmethod=4;%set barrier as solver algorithm
    optimParam = tuneParam(model,cpxControl,5,5,0);

    %test results
    %check if automatic is the optimal solver algorithm for Ecoli
    assert(isequal(optimParam.lpmethod,0))
end

% change the directory
cd(currentDir)