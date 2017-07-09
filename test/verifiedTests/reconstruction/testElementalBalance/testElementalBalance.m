% The COBRAToolbox: testElementalBalance.m
%
% Purpose:
%     - Tests computeMW functionality
%
% Authors:
%     - CI integration: Laurent Heirendt

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testElementalBalance'));
cd(fileDir);

% load the model and data
load('testElementalBalanceData.mat');

% run elmental balance with no optional functions
[MW, Ematrix] = computeMW(model);

% check that the molecular weights have been calculated properly
assert(isequal(MW, stdMW))

% check that the Ematrix has been computed correctly
assert(isequal(Ematrix, stdEmatrix))

% run computeMW with a specific met list
[MW, Ematrix] = computeMW(model, model.mets(25:35), false);

% check that the molecular weights have been calculated properly
assert(isequal(MW, stdMW2))

% check that the Ematrix has been computed correctly
assert(isequal(Ematrix, stdEmatrix2))

% change the directory
cd(currentDir)
