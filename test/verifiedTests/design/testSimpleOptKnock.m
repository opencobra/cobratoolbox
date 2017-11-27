% The COBRAToolbox: testSimpleOptKnock.m
%
% Purpose:
%     - test the simpleOptKnock function
%
% Authors:
%     - Jacek Wachowiak
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSimpleOptKnock'));
cd(fileDir);

% test variables
model = getDistributedModel('ecoli_core_model.mat');
targetRxn = model.rxns(20); % 'EX_ac(e)'

% function outputs
[wtRes, delRes] = simpleOptKnock(model, targetRxn);
[wtRes2, delRes2] = simpleOptKnock(model, targetRxn, model.genes(1), 1, 0.5, 1);

% tests
assert(abs(12.1585 - delRes.maxProd(23)) < 1e-4); % 'EX_co2(e)'
assert(abs(14.3123 - delRes.maxProd(12)) < 1e-4);% 'ATPS4r'
assert(abs(12.1584 - delRes.minProd(14)) < 1e-4);% 'CO2t'
assert(abs(8.5036 - delRes.minProd(16)) < 1e-4);% 'CYTBD'
assert(abs(0.8739 - wtRes.growth) < 1e-4);% always the same
%for gene deletions
assert(abs(0.8739 - wtRes2.growth) < 1e-4);% always the same
assert(abs(3e-07 - delRes2.maxProd) < 1e-4);
assert(abs(delRes2.minProd) < 1e-4);

% change to old directory
cd(currentDir);
