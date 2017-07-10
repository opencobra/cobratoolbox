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

load([CBTDIR, filesep, 'test' filesep 'models' filesep 'ecoli_core_model.mat'], 'model');

% remove old generated file
delete('printConstraints.txt');

diary('printConstraints.txt');
minInf = -Inf;
maxInf = +Inf;
printConstraints(model, minInf, maxInf);
diary off
text1 = readMixedData('refData_printConstraints.txt');
text2 = readMixedData('printConstraints.txt');
assert(isequal(text1, text2));

% remove the generated file
delete('printConstraints.txt');

% change the directory
cd(currentDir)
