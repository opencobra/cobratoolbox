% The COBRAToolbox: testmultiProductionEnvelope.m
%
% Purpose:
%     - test the multiProductionEnvelope function
%
% Authors:
%     - Jacek Wachowiak
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMultiProductionEnvelope'));
cd(fileDir);

% test variables
model = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'mat' filesep 'ecoli_core_model.mat']);
model.lb(36) = 0; % setting the model to anaerobic conditions
model.ub(36) = 0; % setting the model to anaerobic conditions
biomassRxn = model.rxns(13);
target = model.rxns(13); % objective = biomass reaction
deletions = model.rxns(21);
deletions2 = model.genes(21);

%reference data
refData_x=(0:(0.2117/19):0.2117)';
refData_1stcolumn = zeros(20, 1); % EX_ac(e)
refData_1stcolumn(18) = 0.0736;
refData_1stcolumn(19) = 3.9862;
refData_1stcolumn(20) = 8.5036;
refData_2ndcolumn = zeros(20, 1);
refData_6thcolumn = (10:(-1.4964/19):8.5036)';

% function outputs
% each column of targetValues corresponds to one reaction results, while biomassValues is the x axis
% for this test: 1	EX_ac(e), 2	EX_acald(e), 3	EX_akg(e), 4	EX_etoh(e), 5	EX_for(e), after that the results do not correspond to the graph,
% additionally there are always 2 curves, the data corresponds to the lower one
[biomassValues, targetValues] = multiProductionEnvelope(model);
[biomassValues2, targetValues2] = multiProductionEnvelope(model, deletions, biomassRxn);
%gene not reaction removal
[biomassValues3, targetValues3] = multiProductionEnvelope(model, deletions2, biomassRxn, 1, 20, 1);

% tests - not all results are possible to be tested, the suitable were chosen
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
