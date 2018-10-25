% The COBRAToolbox: testScaleSMatrix.m
%
% Purpose:
%     - test the functionality of scaleSmatrix
%
% Authors:
%     - Loic Marx
%

% save the current path
currentDir = pwd;

% initialize the test
cd(fileparts(which(mfilename)));

% load the model
model = getDistributedModel('ecoli_core_model.mat'); %For all models in the test/models folder and subfolders

% load reference data
load('refData_scaledS.mat');

% run the function to scale de S matrix
sS = scaleSMatrix(model.S);

% compare the scaled matrix against the reference data
assert(isequal(sS, scaledS))

% change the directory
cd(currentDir)
