% The COBRAToolbox: <testNameOfSrcFile>.m
%
% Purpose:
%     - test mtFVA option of fluxVariability
%
% Authors:
%     - Axel von Kamp 4/9/19
%

prepareTest('requiredSolvers', {'ibm_cplex'});
changeCobraSolver('ibm_cplex', 'LP');


model = readCbModel('Ec_iJR904.mat');
load('testFVAData.mat');

% set the tolerance
tol = 1e-4;

fprintf('   Testing flux variability analysis using mtFVA\n');

rxnNames = {'PGI', 'PFK', 'FBP', 'FBA', 'TPI', 'GAPD', 'PGK', 'PGM', 'ENO', 'PYK', 'PPS', ...
    'G6PDH2r', 'PGL', 'GND', 'RPI', 'RPE', 'TKT1', 'TKT2', 'TALA'};

% launch the flux variability analysis
fprintf('    Testing flux variability for the following reactions:\n');
disp(rxnNames);

for j = 0:2
    % test with different heuristics levels
    [minFluxS2, maxFluxS2] = fluxVariability(model, 90, 'max', rxnNames, 0, true, 'FBA', struct(), 0, 1, j, 1);
    assert(max(abs(minFlux' - minFluxS2)) < tol)
    assert(max(abs(maxFlux' - maxFluxS2)) < tol)
end

% error if allowLoops is on
assert(verifyCobraFunctionError('fluxVariability', 'outputArgCount', 2, ...
    'input', {model, 90, 'max', rxnNames, 0, false, 'FBA', struct(), 0, 1, 0, 1}, ...
    'testMessage', 'mtFVA only supports the FBA method and neither supports loopless contraints nor Vmin/Vmax'))

% error if a method other than FBA is chosen
assert(verifyCobraFunctionError('fluxVariability', 'outputArgCount', 4, ...
    'input', {model, 90, 'max', rxnNames, 0, true, '0-norm', struct(), 0, 1, 0, 1}, ...
    'testMessage', 'mtFVA only supports the FBA method and neither supports loopless contraints nor Vmin/Vmax'))