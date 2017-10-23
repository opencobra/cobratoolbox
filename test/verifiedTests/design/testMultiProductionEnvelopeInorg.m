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

% function calls

% tests
assert(isequal(0, 0));


% change to old directory
cd(currentDir);
