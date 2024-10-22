% The COBRAToolbox: testOptEnvelope.m
%
% Purpose:
%     - tests the basic functionality of optEnvelope
%       Returns 1 if all tests were completed succesfully, 0 if not
%
% Authors:
%     - Original file: Kristaps Berzins 30/09/2024
%

% save the current path and initialize the test
currentDir = pwd;

% determine the test path for references
fileDir = fileparts(which('testOptEnvelope'));
cd(fileDir);

% set the tolerance
tol = 1e-6;

% define the solver packages to be used to run this test
requiredSolvers = { 'gurobi' };
solversPkgs = prepareTest('requiredSolvers', requiredSolvers);

% load the model
load('testOptEnvelopeData.mat');
model = readCbModel('testOptEnvelopeData.mat', 'modelName', 'model');

solverOK = changeCobraSolver('gurobi', 'all', 0);

if solverOK == 1
    fprintf('   Testing functions of optEnvelope ... ');
    
    % check if envelope matches
    fprintf('\n>> Running optEnvelope\n');
    [main] = optEnvelope(model, 'EX_ac_e');
    
    % testing if optimal point is within range
    fprintf('\n>> Testing peaks\n')
    assert(abs(main.peak.x - testMain.peak.x) < tol);
    assert(abs(main.peak.y - testMain.peak.y) < tol);
    
    % testing if num of deletions matches
    fprintf('\n>> Testing number of deletions\n')
    assert(abs(numel(main.knockouts) - numel(testMain.knockouts)) < tol);
    
    % output a success message
    fprintf('Done.\n');
end

cd(currentDir)
