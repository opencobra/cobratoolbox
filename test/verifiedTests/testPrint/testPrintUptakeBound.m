% The COBRAToolbox: testPrintUptakeBound.m
%
% Purpose:
%     - testPrint tests the functionality of printUptakeBound
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

delete('printUptakeBound.txt');
diary('printUptakeBound.txt');
ref_upInd = [23; 28; 31; 32; 35; 36; 37];
upInd = printUptakeBound(model);
diary off;
assert(isequal(ref_upInd, upInd));
text1 = fileread('printUptakeBound.txt');
text2 = fileread('printUptakeBound_ref.txt');
assert(isequal(text1,text2));


% change the directory
cd(currentDir)
