% The COBRA Toolbox: testSetConstraintsOnBiomassReaction
%
% Purpose:
%     - test setConstraintsOnBiomassReaction function
%
% Authors:
%     - Loic Marx, November 2018
%
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testsetConstraintsOnBiomassReaction'));
cd(fileDir);

%define inputs
rxnID = findRxnIDs(model,rxns)
rxnID = find(strcmp(model.model.rxns,rxns));

model = load('ecoli_core_model.mat');
dT = 24
tolerance = 20
of = find('ACALD')
%Calcule the reference value

ub =   0.0347;
lb =   0.0231;
model = changeRxnBounds(model,of,lb,'l');
modelBM = changeRxnBounds(model,of,ub,'u');


