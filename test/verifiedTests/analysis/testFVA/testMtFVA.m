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

[minFluxS2, maxFluxS2] = fluxVariability(model, 90, 'max', rxnNames, 0, true, 'FBA', struct(), 0, 1);
assert(max(abs(minFlux' - minFluxS2)) < tol)
assert(max(abs(maxFlux' - maxFluxS2)) < tol)


% changeCobraSolverParams('LP', 'feasTol', 1e-9);
% changeCobraSolverParams('LP', 'optTol', 1e-9);
% % standard FVA
% [minFluxS, maxFluxS] = fluxVariability(model, 90, 'max', rxnNames, 0, true, 'FBA', struct(), 0, 0);
% % FVA using mtFVA
% [minFluxS2, maxFluxS2] = fluxVariability(model, 90, 'max', rxnNames, 0, true, 'FBA', struct(), 0, 1);
% 
% max(abs(minFluxS - minFluxS2))
% max(abs(maxFluxS - maxFluxS2))
% 
% % standard FVA
% [minFluxT, maxFluxT] = fluxVariability(model, 90, 'max', model.rxns, 0, true, 'FBA', struct(), 0, 0);
% % FVA using mtFVA
% [minFluxT2, maxFluxT2] = fluxVariability(model, 90, 'max', model.rxns, 0, true, 'FBA', struct(), 0, 1);
% 
% max(abs(minFluxT - minFluxT2))
% max(abs(maxFluxT - maxFluxT2))
