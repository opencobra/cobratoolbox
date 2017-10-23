% The COBRAToolbox: testMultiProductionEnvelopeInorg.m
%
% Purpose:
%     - test the multiProductionEnvelopeInorg function
%
% Authors:
%     - Jacek Wachowiak
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMultiProductionEnvelopeInorg'));
cd(fileDir);

% test variables
model = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'ecoli_core_model.mat']);
deletions = model.genes(20);
biomassRxn = model.rxns(model.c==1);
geneDelFlag = true;
nPts = 100;
plotAllFlag = true;
refData_biomassValues = [0; 0.0460; 0.0920; 0.1380; 0.1840; 0.2300; 0.2760; 0.3220; 0.3680; 0.4140; 0.4600; 0.5060; 0.5520; 0.5979; 0.6439; 0.6899; 0.7359; 0.7819; 0.8279; 0.8739];

% function calls
[biomassValues, targetValues] = multiProductionEnvelopeInorg(model);
[biomassValues1, targetValues1] = multiProductionEnvelopeInorg(model, model.rxns(20));
[biomassValues2, targetValues2] = multiProductionEnvelopeInorg(model, deletions, biomassRxn, geneDelFlag, nPts, plotAllFlag);

% tests
assert(isequal((refData_biomassValues - biomassValues) < (ones(20, 1) * 1e-4), ones(20, 1)));
assert(isempty(targetValues));
% change to old directory
cd(currentDir);
