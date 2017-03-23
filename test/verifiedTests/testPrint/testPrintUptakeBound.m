% The COBRAToolbox: testPrintUptakeBound.m
%
% Purpose:
%     - testPrint tests the functionality of printUptakeBound
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
cd(CBTDIR)
