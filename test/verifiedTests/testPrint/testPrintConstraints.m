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
initTest(fileparts(which(mfilename)));


load('ecoli_core_model', 'model');

delete('printConstraints.txt');
diary('printConstraints.txt');
minInf = -Inf;
maxInf = +Inf;
printConstraints(model, minInf, maxInf);
diary off
text1 = fileread('printConstraints_ref.txt');
text2 = fileread('printConstraints.txt');
assert(isequal(text1,text2));

% change the directory
cd(currentDir)
