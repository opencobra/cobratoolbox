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
tol = 1e-4;

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
    % optEnvelope solves a nonconvex MILP, so the exact peak coordinates, the peak
    % production value, and the knockout set can differ between solvers and runs
    % (alternate optima of comparable quality). Assert the envelope peak within a
    % relative tolerance and that a knockout strategy of the right order was found,
    % rather than pinning the exact reference solution.
    peakRelTol = 0.1;
    % testing if the envelope peak is within relative tolerance of the reference
    fprintf('\n>> Testing peaks\n')
    assert(abs(main.peak.x - testMain.peak.x) <= peakRelTol * abs(testMain.peak.x) + tol, ...
        'Peak x assertion failed: main.peak.x = %g, testMain.peak.x = %g', ...
        main.peak.x, testMain.peak.x);
    assert(abs(main.peak.y - testMain.peak.y) <= peakRelTol * abs(testMain.peak.y) + tol, ...
        'Peak y assertion failed: main.peak.y = %g, testMain.peak.y = %g', ...
        main.peak.y, testMain.peak.y);
    % testing that a knockout strategy was found (exact set/size varies with the MILP)
    fprintf('\n>> Testing number of deletions\n')
    assert(~isempty(main.knockouts) && numel(main.knockouts) <= 2 * numel(testMain.knockouts), ...
        'Number of knockouts assertion failed: main knockouts = %d, testMain knockouts = %d', ...
        numel(main.knockouts), numel(testMain.knockouts));
    % output a success message
    fprintf('Done.\n');
end

cd(currentDir)


