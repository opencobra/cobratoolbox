% The COBRAToolbox: testOptimizeCbModel.m
%
% Purpose:
%     - Tests computeMW functionality
%
% Authors:
%     - CI integration: Laurent Heirendt

% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end - (length('initCobraToolbox.m') + 1));

% change to the test folder
cd([CBTDIR '/test/verifiedTests/testElementalBalance'])

% load the model and data
load('testElementalBalanceData.mat');

% run elmental balance with no optional functions
[MW Ematrix] = computeMW(model);

% check that the molecular weights have been calculated properly
assert(isequal(MW, stdMW))

% check that the Ematrix has been computed correctly
assert(isequal(Ematrix, stdEmatrix))

% run computeMW with a specific met list
[MW Ematrix] = computeMW(model, model.mets(25:35), false);

% check that the molecular weights have been calculated properly
assert(isequal(MW, stdMW2))

% check that the Ematrix has been computed correctly
assert(isequal(Ematrix, stdEmatrix2))

% change the directory
cd(CBTDIR)
