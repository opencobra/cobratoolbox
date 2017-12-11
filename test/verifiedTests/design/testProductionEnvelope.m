% The COBRAToolbox: testProductionEnvelope.m
%
% Purpose:
%     - test the productionEnvelope function
%
% Authors:
%     - Jacek Wachowiak
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testProductionEnvelope'));
cd(fileDir);

% test variables
model = readCbModel('ecoli_core_model.mat');
model.lb(36) = 0; % Set anaerobic conditions
biomassRxn = model.rxns{13};
targetRxn = model.rxns{20};
deletions = model.rxns(23);
deletions2 = model.genes(23);

% reference data
refData_biomass = (0:(0.2111/19):0.2111)';
refData_targetValues = zeros(20, 2);
refData_targetValues(14:20, 1) = [0.6599, 1.9014, 3.1430, 4.3845, 5.6260, 6.8675, 8.3187];
refData_targetValues(:,2) = (10:(-1.6813/19):8.3187)';

refData_biomass2 = (0:(0.2117/19):0.2117)';
refData_targetValues2 = zeros(20, 2);
refData_targetValues2(18:20, 1) = [0.6148, 4.5592, 8.5036];
refData_targetValues2(:,2) = (10:(-1.4964/19):8.5036)';

% function outputs
[biomassValues, targetValues, lineHandle] = productionEnvelope(model, deletions, 'k', targetRxn, biomassRxn)
[biomassValues2, targetValues2, lineHandle2] = productionEnvelope(model, deletions2, 'k', targetRxn, biomassRxn, 1)
try
    productionEnvelope(model); % a default call with this model causes an error
catch ME
    assert(length(ME.message) > 0)
end

% tests
assert(isequal((abs(refData_biomass-biomassValues) < 1e-4), true(20, 1)));
assert(isequal((abs(refData_targetValues-targetValues) < 1e-4), true(20, 2)));

assert(isequal((abs(refData_biomass2-biomassValues2) < 1e-4), true(20, 1)));
assert(isequal((abs(refData_targetValues2-targetValues2) < 1e-4), true(20, 2)));

close all hidden force

% change to old directory
cd(currentDir);
