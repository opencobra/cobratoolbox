% The COBRAToolbox: testListBiGGMOdels.m
%
% Purpose:
%     - test the listBiGGModels function
%
% Authors:
%     - Jacek Wachowiak

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testListBiGGMOdels'));
cd(fileDir);

% test variables
refData_str = fileread('refData_listBiGGModels.txt');
refData_str = refData_str(1:end-1);
% function outputs
[str] = listBiGGModels();

% test
assert(isequal(refData_str, str));

% change to old directory
cd(currentDir);
