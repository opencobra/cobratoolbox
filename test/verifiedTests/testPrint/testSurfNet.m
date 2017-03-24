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
initTest(fileparts(which(mfilename)));


load('ecoli_core_model', 'model');

delete('surfNet.txt');
diary('surfNet.txt');
metrxn = '13dpg[c]';
surfNet(model, metrxn);
diary off;
text1 = fileread('surfNet.txt');
text2 = fileread('surfNet_ref.txt');
assert(isequal(text1,text2));

% change the directory
cd(currentDir)
