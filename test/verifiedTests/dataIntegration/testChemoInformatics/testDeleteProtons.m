% The COBRAToolbox: testDeleteProtons.m
%
% Purpose:
%     - tests the deleteProtons function using the DAS network
%
% Authors:
%     - German Preciat -- August 2017
%

% save the current path
currentDir = pwd;

% initialize the test
cd(fileparts(which('testDeleteProtons')));

% Load reference data
load('refData_deleteProtons.mat')

% Load the dopamine synthesis network
model = readCbModel('subDas.mat');

modelNew = deleteProtons(model);
assert(all(all(modelNew.S == modelNew0.S)), 'Reference S matrix does not match.')
assert(all(all(modelNew.S == modelNew0.S)), 'Reference metabolites do not match.')
assert(all(all(modelNew.S == modelNew0.S)), 'Reference metabolites formulas do not match.')
assert(all(all(modelNew.S == modelNew0.S)), 'Reference metabolites charges do not match.')


% change the directory
cd(currentDir)