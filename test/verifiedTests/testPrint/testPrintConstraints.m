% The COBRAToolbox: testPrintConstraints.m
%
% Purpose:
%     - testPrint tests the functionality of printConstraints
%       and compares it to expected data.
%
% Authors:
%     - Lemmer El Assal March 2017
%

% save the current path
currentDir = pwd;

% initialize the test
cd(fileparts(which(mfilename)));

load('ecoli_core_model', 'model');

% remove old generated file
delete('printConstraints.txt');

diary('printConstraints.txt');
minInf = -Inf;
maxInf = +Inf;
printConstraints(model, minInf, maxInf);
diary off
text1 = fileread('refData_printConstraints.txt');
text2 = fileread('printConstraints.txt');
assert(isequal(text1, text2));

% remove the generated file
delete('printConstraints.txt');

% change the directory
cd(currentDir)
