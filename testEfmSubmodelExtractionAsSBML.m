% The COBRAToolbox: <testNameOfSrcFile>.m
%
% Purpose:
%     - <provide a short description of the purpose of the test
%
% Authors:
%     - <major change>: <your name> <date>
%

global CBTDIR

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% determine the test path for references
testPath = pwd;

% load the model
model = readCbModel('testModel.mat','modelName','model_irr'); %For all models which are part of this particular test.

% Load reference data
load([testPath filesep 'testData_efmSubmodelExtractionAsSBML.mat']);

% This is a function with 3 required inputs, 2 optional inputs and 1 optional output:
% Case 1: Test whether efmSubmodelExtractionAsSBML gives the expected output when using 3 input and 1 output arguments
selectedRxns = testEFMRxns(testSelectedEFM, find(testEFMRxns(testSelectedEFM,:))); 
submodelEFM = efmSubmodelExtractionAsSBML(model, selectedRxns, 'testEFMSubmodel.xml') ;
assert(isequal(submodelEFM, submodelEFM_ref));

% Case 2: Test whether efmSubmodelExtractionAsSBML gives the expected output when using 5 input and 1 output arguments
submodelEFM_woUbMets = efmSubmodelExtractionAsSBML(model, selectedRxns, 'testEFMSubmodel_woUbMets.xml', 1, testUbiquitousMets) ;
assert(isequal(submodelEFM_woUbMets, submodelEFM_woUbMets_ref));

% Case 3: Test whether efmSubmodelExtractionAsSBML gives an error with < 3 input and 1 output arguments
assert(verifyCobraFunctionError('efmSubsystemsExtraction', 'inputs', {model, selectedRxns}, 'outputArgCount', 1));
assert(verifyCobraFunctionError('efmSubsystemsExtraction', 'inputs', {model}, 'outputArgCount', 1));