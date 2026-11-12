% The COBRAToolbox: testGpSampler.m
%
% Purpose:
%     - tests the gpSampler function using the E. coli Core Model, and a toy problem for the
%       input checks, the default arguments and the restart from an earlier result
%
% Function under test:
%     src/analysis/sampling/ACHR/gpSampler.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - sampling on ecoli_core_model and on a toy problem; the random seed is fixed.
%
% Coverage exemptions:
%     Lines 221-364: dead code, the local function warmup is never called, because the only call of it is commented out in favour of createHRWarmup.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A bias distribution stops with an error
%       SEVERITY: unusable-option
%       TRIGGER: gpSampler(model, 10, bias, 1) with bias.method = 'uniform', bias.index = 1 and
%         bias.param = [0.1 0.2]
%       OBSERVED: createHRWarmup loops over 1:size(bias.index), and a vector in a colon expression
%         stops with "Colon operands must be real scalars" (MATLAB R2025a)
%       EXPECTED: warmup points and samples that follow the bias distribution
%       LINES: 176
%     - DEFECT: The distributed sampler does not exist
%       SEVERITY: unusable-option
%       TRIGGER: gpSampler(model, 10, [], 1, [], -1), a negative number of threads
%       OBSERVED: the help describes threads < 0 as the use of the distributed toolbox, but the
%         function ACHRSamplerDistributedGeneral is not in the toolbox, so the call stops with an
%         undefined function error
%       EXPECTED: sampling with the distributed toolbox
%       LINES: 205
%     - DEFECT: A problem given by A without S stops with an error
%       SEVERITY: error
%       TRIGGER: gpSampler(struct('A', [1 1 -1], 'b', 0, 'lb', [0; 0; 0], 'ub', [1; 1; 2], 'csense', 'E'), 10)
%       OBSERVED: the warmup calls buildOptProblemFromModel, which reads .S and stops with
%         "Unrecognized field name S"
%       EXPECTED: sampling of the space, since the help describes .A as the matrix of the problem
%         and .S only as the replacement of an absent .A
%       LINES: 186
%
% Authors:
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
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

%% toy problem: x1 + x2 - x3 = 0 within bounds, sampled with the first LP solver

changeCobraSolver(solvers.LP{1}, 'LP', 0);
rng(0);
tol = 1e-6;
toyProblem = struct('S', [1, 1, -1], 'b', 0, 'csense', 'E', 'lb', [0; 0; 0], 'ub', [1; 1; 2]);
nToyPoints = 10;

%% incomplete input: each check returns early with the default outputs 0 and 1

% the default arguments are set before these checks, so they need no sampling of 10 minutes
[noResult, noFraction] = gpSampler(struct('b', 0));
assert(isequal(noResult, 0) && noFraction == 1);
assert(isequal(gpSampler(rmfield(toyProblem, 'lb'), nToyPoints), 0));
assert(isequal(gpSampler(rmfield(toyProblem, 'ub'), nToyPoints), 0));

% a bias without a method
assert(isequal(gpSampler(toyProblem, nToyPoints, struct('index', 1), 1), 0));

% an unknown constraint type
badSense = toyProblem;
badSense.csense = 'X';
assert(isequal(gpSampler(badSense, nToyPoints, [], 1), 0));

% constraints without a solution: the offset does not satisfy the right hand side
inconsistent = toyProblem;
inconsistent.S = [1, 1, 0; 1, 1, 0];
inconsistent.b = [1; 2];
inconsistent.csense = ['E'; 'E'];
warningState = warning('off', 'MATLAB:rankDeficientMatrix');
assert(isequal(gpSampler(inconsistent, nToyPoints, [], 1), 0));
warning(warningState);

%% b and csense are optional, and maxSteps limits the sampling instead of maxTime

[toySample, mixedFrac] = gpSampler(rmfield(toyProblem, {'b', 'csense'}), nToyPoints, [], [], 100);
assert(isequal(toySample.b, 0) && toySample.csense == 'E');
assert(isequal(size(toySample.points), [3, nToyPoints]));
assert(toySample.steps == 100);
assert(mixedFrac > 0);
assert(max(abs(toySample.S * toySample.points)) < tol);
assert(all(toySample.points(:) >= -tol) && all(all(toySample.points <= toyProblem.ub + tol)));

%% a nonzero right hand side is moved to an offset: the samples satisfy the original constraints

offsetProblem = toyProblem;
offsetProblem.b = 1;
offsetProblem.ub = [2; 2; 2];
offsetSample = gpSampler(offsetProblem, nToyPoints, [], [], 100);
assert(max(abs(offsetProblem.S * offsetSample.points - 1)) < tol);
assert(all(offsetSample.points(:) >= -tol) && all(all(offsetSample.points <= offsetProblem.ub + tol)));

%% maxSteps of 0: only warmup points are made, and the mixed fraction stays 1

[warmupOnly, mixedFrac] = gpSampler(toyProblem, nToyPoints, [], 1, 0);
assert(mixedFrac == 1);
assert(isfield(warmupOnly, 'warmupPts') && ~isfield(warmupOnly, 'points'));
assert(warmupOnly.steps == 0);

%% a result is continued: the warmup points are kept and the steps add up

continued = gpSampler(toySample, nToyPoints, [], [], 100);
assert(isequal(continued.warmupPts, toySample.warmupPts));
assert(continued.steps == 200);
assert(max(abs(continued.S * continued.points)) < tol);

%% warmup points without the preprocessing data are made again

noInternal = rmfield(warmupOnly, 'internal');
noInternal.warmupPts(:) = 0;
restarted = gpSampler(noInternal, nToyPoints, [], 1, 0);
assert(isfield(restarted, 'internal'));
assert(any(restarted.warmupPts(:)));

%% without warmup points the earlier points and bias of the structure are removed

noWarmup = rmfield(toySample, 'warmupPts');
noWarmup.bias = struct('method', 'uniform');
restarted = gpSampler(noWarmup, nToyPoints, [], 1, 0);
assert(isfield(restarted, 'warmupPts'));
assert(~isfield(restarted, 'points') && ~isfield(restarted, 'bias'));
assert(restarted.steps == 0);

% remove the files written by the sampler and set the seed to its default value
for samplerFile = {'sampleStructTmp.mat', 'ACHRParallelError.txt'}
    if isfile(samplerFile{1})
        delete(samplerFile{1});
    end
end
rng('default');

% change the directory
cd(currentDir)
