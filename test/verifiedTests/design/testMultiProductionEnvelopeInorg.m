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
model = getDistributedModel('ecoli_core_model.mat');
model.ub(36) = 0; % anaerobic conditions
model.lb(36) = 0;
deletions = model.genes(20);
biomassRxn = model.rxns(model.c==1); % biomass
geneDelFlag = true;
nPts = 100;
plotAllFlag = true;

% reference data
refData_x=(0:(0.2117/19):0.2117)';
refData_1stcolumn = zeros(20, 1); % EX_ac(e)
refData_1stcolumn(18) = 0.0736;
refData_1stcolumn(19) = 3.9862;
refData_1stcolumn(20) = 8.5036;
refData_2ndcolumn = zeros(20, 1);
refData_6thcolumn = (10:(-1.4964/19):8.5036)';

% function calls
[biomassValues, targetValues] = multiProductionEnvelopeInorg(model);
[biomassValues1, targetValues1] = multiProductionEnvelopeInorg(model, model.rxns(20));
[biomassValues2, targetValues2] = multiProductionEnvelopeInorg(model, deletions, biomassRxn, geneDelFlag, nPts, plotAllFlag);

% tests
% x axis comparison
assert(isequal((abs(refData_x-biomassValues) < 1e-4), ones(20, 1)));
% tests for 1st (rising in the end), 2nd (zeros) and 6th column (decreasing from 10 to 8.5)
assert(isequal((abs(refData_1stcolumn-targetValues(:, 1)) < 1e-4), ones(20, 1)));
assert(isequal(refData_2ndcolumn, targetValues(:, 2)));
assert(isequal((abs(refData_6thcolumn-targetValues(:, 6)) < 1e-4), ones(20, 1)));

pause(3);

close all hidden force

% change to old directory
cd(currentDir);
