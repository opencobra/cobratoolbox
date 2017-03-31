% The COBRAToolbox: testSurfNet.m
%
% Purpose:
%     - testSurfNet tests the functionality of surfNet
%       and compares it to expected data.
%
% Authors:
%     - Lemmer El Assal March 2017
%

% save the current path
currentDir = pwd;

% initialize the test
cd(fileparts(which(mfilename)));

load([CBTDIR, filesep, 'test' filesep 'models' filesep 'ecoli_core_model.mat'], 'model');

% remove old generated file
delete('surfNet.txt');

diary('surfNet.txt');
metrxn = '13dpg[c]';
surfNet(model, metrxn);
diary off;

text1 = fileread('surfNet.txt');
text2 = fileread('refData_surfNet.txt');
assert(isequal(text1, text2));

% remove the generated file
delete('surfNet.txt');

% change the directory
cd(currentDir)
