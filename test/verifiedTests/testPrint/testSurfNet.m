% The COBRAToolbox: testSurfNet.m
%
% Purpose:
%     - testSurfNet tests the functionality of surfNet
%       and compares it to expected data.
%
% Authors:
%     - Lemmer El Assal March 2017
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSurfNet'));
cd(fileDir);

load([CBTDIR, filesep, 'test' filesep 'models' filesep 'ecoli_core_model.mat'], 'model');

% remove old generated file
delete('surfNet.txt');

diary('surfNet.txt');
metrxn = '13dpg[c]';
surfNet(model, metrxn);
diary off;

text1 = importdata('surfNet.txt');
text2 = importdata('refData_surfNet.txt');
assert(isequal(text1, text2));

% remove the generated file
delete('surfNet.txt');

% change the directory
cd(currentDir)
