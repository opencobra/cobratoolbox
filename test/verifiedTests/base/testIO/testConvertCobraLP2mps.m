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
LPProblem = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'ecoli_core_model.mat']);
LPProblem_2 = rmfield(LPProblem, 'csense');
LPProblem_2 = rmfield(LPProblem_2, 'osense');

% function outputs
OK = convertCobraLP2mps(LPProblem);
OK_2 = convertCobraLP2mps(LPProblem_2);

% test
assert(isequal(OK, 1));
assert(isequal(OK_2, 1));

% change to old directory
cd(currentDir);
