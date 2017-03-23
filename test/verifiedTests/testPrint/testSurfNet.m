% The COBRAToolbox: testSurfNet.m
%
% Purpose:
%     - testSurfNet tests the functionality of surfNet
%       and compares it to expected data.
%
% Authors:
%     - Lemmer El Assal March 2017
%

% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end-(length('initCobraToolbox.m') + 1));

cd([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'testPrint']);

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
cd(CBTDIR)
