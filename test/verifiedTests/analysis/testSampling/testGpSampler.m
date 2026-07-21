% The COBRAToolbox: testGpSampler.m
%
% Purpose:
%     - tests the gpSampler function using the E. coli Core Model
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGpSampler'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available
solvers = prepareTest('needsLP', true);

% load the model
model = getDistributedModel('ecoli_core_model.mat');

% define the number of sample points
samplePoints = [5, 190];

% define the solver packages to be used to run this test
solverPkgs = {'gurobi', 'tomlab_cplex', 'glpk'};

% Feature 002: gpSampler assertions are solver-independent, so in fast mode
% validate on a single representative (default) LP solver instead of looping
% over every installed solver. Full mode keeps the complete cross-solver loop.
if getCobraTestMode('isFast')
    solverPkgs = solvers.LP;
end

for k = 1:length(solverPkgs)

    % set the solver
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverOK == 1
        fprintf('   Testing readSBML using %s ... \n', solverPkgs{k});

        for i = 1:length(samplePoints)
            % call sampler
            [sampleStructOut, mixedFrac] = gpSampler(model, samplePoints(i), [], 2);

            % check
            [errorsA, errorsLUB, stuckPoints] = verifyPoints(sampleStructOut);

            assert(all(~any(errorsA)));
            assert(~any(errorsLUB));
            assert(~any(stuckPoints));
        end

        % print a line for success of loop i
        fprintf(' Done.\n');
    end
end

% change the directory
cd(currentDir)
