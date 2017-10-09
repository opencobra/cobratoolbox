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
model = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'ecoli_core_model.mat']);
targetRxn = model.rxns(1);

% function outputs
[wtRes, delRes] = simpleOptKnock(model, targetRxn);
[wtRes2, delRes2] = simpleOptKnock(model, targetRxn, model.genes, 1, 0.05, 1);

% tests
assert(isequal(wtRes.minProd, wtRes2.minProd));
assert(isequal(wtRes.maxProd, wtRes2.maxProd));
assert(isequal(wtRes.growth, wtRes2.growth));
assert(isequal(size(delRes.minProd), size(zeros(95,1))));
assert(isequal(size(delRes.maxProd), size(zeros(95,1))));
assert(isequal(size(delRes.growth), size(zeros(95,1))));
assert(isequal(size(delRes2.minProd), size(zeros(137))));
assert(isequal(size(delRes2.maxProd), size(zeros(137))));
assert(isequal(size(delRes2.growth), size(zeros(137))));

% change to old directory
cd(currentDir);
