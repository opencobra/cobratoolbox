% The COBRAToolbox: testPrintConstraints.m
%
% Purpose:
%     - testPrint tests the functionality of printConstraints
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
cd(CBTDIR)
