% The COBRAToolbox: testFVA.m
%
% Purpose:
%     - testFVA tests the functionality of flux variability analysis
%       basically performs FVA and checks solution against known solution.
%
% Authors:
%     - Original file: Joseph Kang 04/27/09
%     - CI integration: Laurent Heirendt January 2017
%
% Note:
%     - The solver libraries must be included separately

% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end-(length('initCobraToolbox.m') + 1));

cd([CBTDIR '/test/verifiedTests/testFVA'])

% set the tolerance
tol = 1e-8;

% set the solver
changeCobraSolver('tomlab_cplex')

% load the model
load('Ec_iJR904.mat', 'model');
load('testFVAData.mat');

fprintf('\n>> Flux variability analysis\n\n');

% launch the flux variability analysis
[minFluxT, maxFluxT] = fluxVariability(model, 90);

rxnNames = {'PGI', 'PFK', 'FBP', 'FBA', 'TPI', 'GAPD', 'PGK', 'PGM', 'ENO', 'PYK', 'PPS', 'G6PDH2r', 'PGL', 'GND', 'RPI', 'RPE', 'TKT1', 'TKT2', 'TALA'};

% retrieve the IDs of each reaction
rxnID = findRxnIDs(model, rxnNames);

% check if each flux value corresponds to a pre-calculated value
for i =1:size(rxnID)
    assert(minFlux(i) - tol <= minFluxT(i))
    assert(minFluxT(i) <= minFlux(i) + tol)

    assert(maxFlux(i) - tol <= maxFluxT(i))
    assert(maxFluxT(i) <= maxFlux(i) + tol)

    maxMinusMin = maxFlux(i) - minFlux(i);
    maxTMinusMinT = maxFluxT(i) - minFluxT(i);
    assert(maxMinusMin - tol <= maxTMinusMinT)
    assert(maxTMinusMinT <= maxMinusMin + tol)

    % print the labels
    printLabeledData(model.rxns(i), [minFlux(i) maxFlux(i) maxFlux(i)-minFlux(i)], true, 3);
end

% change the directory
cd(CBTDIR)
