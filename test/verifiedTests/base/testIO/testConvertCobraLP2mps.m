% The COBRAToolbox: testConvertCobraLP2mps.m
%
% Purpose:
%     - test the convertCobraLP2mps function
%
% Authors:
%     - Jacek Wachowiak
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConvertCobraLP2mps'));
cd(fileDir);

% test variables
model = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'ecoli_core_model.mat']);

% function outputs
OK = convertCobraLP2mps(LPProblem)

% test
assert(isequal(0, 0));

% change to old directory
cd(currentDir);
