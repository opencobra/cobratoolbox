% The COBRAToolbox: testPrintConstraints.m
%
% Purpose:
%     - testPrint tests the functionality of printConstraints
%       and compares it to expected data.
%
% Authors:
%     - Lemmer El Assal March 2017
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPrintConstraints'));
cd(fileDir);

model = getDistributedModel('ecoli_core_model.mat');

% remove old generated file
delete('printConstraints.txt');

diary('printConstraints.txt');
minInf = 0;% [-Inf,-1000,-100,0]try different combination to test the function
maxInf = 1000; % [0,100,1000,+Inf]
printConstraints(model, minInf, maxInf);
diary off
text1 = readMixedData('refData_printConstraints.txt');
text2 = readMixedData('printConstraints.txt');
assert(isequal(text1, text2));

% remove the generated file
delete('printConstraints.txt');

% change the directory
cd(currentDir)
