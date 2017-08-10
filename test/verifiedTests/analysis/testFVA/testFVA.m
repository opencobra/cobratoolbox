% The COBRAToolbox: testFVA.m
%
% Purpose:
%     - testFVA tests the functionality of flux variability analysis
%       basically performs FVA and checks solution against known solution.
%
% Authors:
%     - Original file: Joseph Kang 04/27/09
%     - CI integration: Laurent Heirendt January 2017
%     - Vmin, Vmax test: Marouen Ben Guebila 24/02/17
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFVA'));
cd(fileDir);

% set the tolerance
tol = 1e-4;

% define the solver packages to be used to run this test
solverPkgs = {'tomlab_cplex', 'gurobi'};

% load the model
load('Ec_iJR904.mat', 'model');
load('testFVAData.mat');

% create a parallel pool
minWorkers = 2;
myCluster = parcluster(parallel.defaultClusterProfile);

if myCluster.NumWorkers >= minWorkers
    poolobj = gcp('nocreate');  % if no pool, do not create new one.
    if isempty(poolobj)
        parpool(minWorkers);  % launch minWorkers workers
    end

    for k = 1:length(solverPkgs)

        % change the COBRA solver (LP)
        solverLPOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);
        solverQPOK = changeCobraSolver(solverPkgs{k}, 'QP', 0);

        if solverLPOK && solverQPOK
            fprintf('   Testing flux variability analysis using %s ... ', solverPkgs{k});

            rxnNames = {'PGI', 'PFK', 'FBP', 'FBA', 'TPI', 'GAPD', 'PGK', 'PGM', 'ENO', 'PYK', 'PPS', ...
                        'G6PDH2r', 'PGL', 'GND', 'RPI', 'RPE', 'TKT1', 'TKT2', 'TALA'};

            % launch the flux variability analysis
            fprintf('    Testing flux variability for the following reactions:\n');
            disp(rxnNames);
            [minFluxT, maxFluxT] = fluxVariability(model, 90, 'max', rxnNames);

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
                printLabeledData(model.rxns(i), [minFlux(i) maxFlux(i) maxFlux(i) - minFlux(i)], true, 3);
            end

            % Vmin and Vmax test
            % Since the solution are dependant on solvers and cpus, the test will check the existence of nargout (weak test) over the 4 first reactions
            rxnNames = {'PGI', 'PFK', 'FBP', 'FBA'};

            % testing default FVA with 2 printLevels
            for j = 0:1
                fprintf('    Testing flux variability with printLevel %s:\n', num2str(j));
                [minFlux, maxFlux, Vmin, Vmax] = fluxVariability(model, 90, 'max', rxnNames, j, 1);
                assert(~isequal(Vmin, []));
                assert(~isequal(Vmax, []));
            end

            % testing various methods
            testMethods = {'FBA', '0-norm', '1-norm', '2-norm', 'minOrigSol'};

            for j = 1:length(testMethods)
                fprintf('    Testing flux variability with test method %s:\n', testMethods{j});
                [minFlux, maxFlux, Vmin, Vmax] = fluxVariability(model, 90, 'max', rxnNames, 1, 1, testMethods{j});
                assert(~isequal(Vmin, []));
                assert(~isequal(Vmax, []));
            end

            % output a success message
            fprintf('Done.\n');
        end
    end
else
    warning(' > Skipping testFVA as the default parallel pool is not configured for more than 2 workers.');
end

% change the directory
cd(currentDir)
