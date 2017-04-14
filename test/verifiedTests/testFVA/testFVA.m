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

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFVA'));
cd(fileDir);

% set the tolerance
tol = 1e-8;

% define the solver packages to be used to run this test
solverPkgs = {'tomlab_cplex', 'glpk'};

% load the model
load('Ec_iJR904.mat', 'model');
load('testFVAData.mat');

% create a parallel pool
poolobj = gcp('nocreate'); % if no pool, do not create new one.
if isempty(poolobj)
    parpool(2); % launch 2 workers
end

for k = 1:length(solverPkgs)

    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverOK == 1
        fprintf('   Testing flux variability analysis using %s ... ', solverPkgs{k});

        % launch the flux variability analysis
        [minFluxT, maxFluxT] = fluxVariability(model, 90, 'max', model.rxns, 1);

        rxnNames = {'PGI', 'PFK', 'FBP', 'FBA', 'TPI', 'GAPD', 'PGK', 'PGM', 'ENO', 'PYK', 'PPS', 'G6PDH2r', 'PGL', 'GND', 'RPI', 'RPE', 'TKT1', 'TKT2', 'TALA'};

        % retrieve the IDs of each reaction
        rxnID = findRxnIDs(model, rxnNames);

        % check if each flux value corresponds to a pre-calculated value
        for i = 1:size(rxnID)
            % test the components of the minFlux and maxFlux vectors
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

        % output a success message
        fprintf('Done.\n');
    end
end

% change the directory
cd(currentDir)
