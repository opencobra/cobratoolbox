% The COBRAToolbox: testDetermineSignMatrix.m
%
% Purpose:
%     - test the function to determine the binary version of the stoichiometric matrix S
%
% Authors:
%     - Laurent Heirendt, November 2018
%

% save the current path and initialize the test
currentDir = fileparts(which(mfilename));

% load the model
model = createToyModelForLifting(false);

% load reference test data
load([currentDir filesep 'refData_determineBinaryMatrix.mat']);

% run the function with full output
[test_Shat, test_Shatabs, test_mconnect, test_nconnect, test_mconnectin, test_mconnectout] = determineBinaryMatrix(model.S);

assert(isequal(test_Shat, Shat))
assert(isequal(test_Shatabs, Shatabs))
assert(isequal(test_mconnect, mconnect))
assert(isequal(test_nconnect, nconnect))
assert(isequal(test_mconnectin, mconnectin))
assert(isequal(test_mconnectout, mconnectout))

% run the function with partial output
[test_Shat, test_Shatabs, test_test_mconnect, test_nconnect] = determineBinaryMatrix(model.S);

assert(isequal(test_Shat, Shat))
assert(isequal(test_Shatabs, Shatabs))
assert(isequal(test_mconnect, mconnect))
assert(isequal(test_nconnect, nconnect))

% run the function with minimal output
[test_Shat, test_Shatabs] = determineBinaryMatrix(model.S);

assert(isequal(test_Shat, Shat))
assert(isequal(test_Shatabs, Shatabs))

% change the directory
cd(currentDir)
