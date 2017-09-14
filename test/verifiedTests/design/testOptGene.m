% The COBRAToolbox: testOptGene.m
%
% Purpose:
%     - test the optGene function
%
% Authors:
%     - Jacek Wachowiak
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOptGene'));
cd(fileDir);

% test variables
model = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'ecoli_core_model.mat']);
targetRxn = char(model.rxns(2));
substrateRxn = '';
generxnList = model.rxns(1);

% function outputs
% requires Global Optimization Toolbox
[x, population, scores, optGeneSol] = optGene(model, targetRxn, substrateRxn, generxnList)

% test
assert(isequal(0, 0));

% change to old directory
cd(currentDir);
