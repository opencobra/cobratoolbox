% The COBRAToolbox: testSelMatrix.m
%
% Purpose:
%     - testSelMatrix tests the functionality of testSelMatrix()
%
% Authors:
%     - Lemmer El Assal February 2017
%

% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end-(length('initCobraToolbox.m') + 1));

cd([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'testTools']);

% load reference data
load('refData_selMatrix.mat');

selMat1 = selMatrix(selVec1);
selMat2 = selMatrix(selVec2);
assert(isequal(selMat1, ref_selMat1))
assert(isequal(selMat2, ref_selMat2))

%return to original directory
cd(CBTDIR);
