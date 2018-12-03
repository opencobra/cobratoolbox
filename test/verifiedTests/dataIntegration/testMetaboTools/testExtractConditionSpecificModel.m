% The COBRA Toolbox: testexportSetToGAMS
%
% Purpose:
%     - test exportSetToGAMS function
%
% Authors:
%     - Loic Marx, December 2018

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which(mfilename));
cd(fileDir);

% define inputs
model = getDistributedModel('ecoli_core_model.mat');
theshold = 10e-6

model_RefData =  extractConditionSpecificModel(model,theshold)
rxnID = findRxnIDs(model_RefData,model.rxns)

% change back to the current directory
cd(currentDir);