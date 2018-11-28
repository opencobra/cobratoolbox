% The COBRAToolbox: testDetermineBinaryMatrix.m
%
% Purpose:
%     - test the function to determine the binary version of the stoichiometric matrix S
%
% Authors:
%     - Laurent Heirendt, November 2018
%

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% load the model
model = createToyModelForLifting(false);




% change the directory
cd(currentDir)
