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
CBTDIR = pth(1:end - (length('initCobraToolbox.m') + 1));

cd([CBTDIR '/test/verifiedTests/testFVA'])

% set the tolerance
tol = 1e-8;

% define the solver packages to be used to run this test
solverPkgs = {'tomlab_cplex', 'glpk'};

% load the model
load('Ec_iJR904.mat', 'model');
load('testFVAData.mat');

for k = 1:length(solverPkgs)
    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs{k});

    if solverOK == 1
        fprintf('   Testing flux variability analysis using %s ... ', solverPkgs{k});

        poolobj = gcp('nocreate'); % If no pool, do not create new one.
        if isempty(poolobj)
            % launch 2 workers
            parpool(2);
        end

        % launch the flux variability analysis
        [minFluxT, maxFluxT] = fluxVariability(model, 90);

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
cd(CBTDIR)
