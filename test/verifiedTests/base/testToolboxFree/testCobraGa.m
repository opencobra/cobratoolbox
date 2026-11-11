% The COBRAToolbox: testCobraGa.m
%
% Purpose:
%     - cobraGa is the plain-MATLAB replacement for ga with bit-string populations (Global
%       Optimization Toolbox), as used by optGene. Correctness is reaching the known optimum
%       (maintainer decision 2026-11-11: same algorithm class, same optimum, not the same
%       iterates). This test checks OneMax (optimum all ones), a 0/1 knapsack whose optimum is
%       found independently by enumerating all 2^15 subsets, reproducibility with a fixed seed,
%       that the best value never worsens (elitism), migration between subpopulations (exact,
%       deterministic check), the operator signatures of optGene (its creation, crossover and
%       mutation functions, copied below, with four subpopulations), every exit flag, the
%       non-vectorized path and the initial population, the display, the errors for unsupported
%       options, and (only where the toolbox is installed) parity with ga.
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraGa.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCobraGa'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

quietBitstring = struct('PopulationType', 'bitstring', 'Vectorized', 'on', 'Display', 'off');

%% OneMax: the optimum is all ones

rng(0);
problem = struct('fitnessfcn', @(X) -sum(X, 2), 'nvars', 30, 'options', setfield(quietBitstring, 'Generations', 300));
[x, fval, exitflag, output, population, scores] = cobraGa(problem);
assert(isequal(x, ones(1, 30)) && fval == -30 && isa(x, 'double'));
assert(isequal(size(population), [200 30]) && isequal(size(scores), [200 1]) && all(ismember(population(:), [0 1])));
assert(isequal(scores, -sum(population, 2)) && min(scores) == fval);
assert(ismember(exitflag, [0 1]) && output.generations >= 1 && output.funccount > 200);
assert(strcmp(output.problemtype, 'unconstrained') && isempty(output.maxconstraint) && isstruct(output.rngstate));

%% 0/1 knapsack: the optimum found by exhaustive enumeration of all 2^15 subsets

rng(20261111);
weights = randi([1 20], 1, 15);
values = randi([1 30], 1, 15);
capacity = floor(sum(weights) / 2);
allSubsets = dec2bin(0:2 ^ 15 - 1, 15) - '0';
feasible = allSubsets * weights' <= capacity;
optimum = max(allSubsets(feasible, :) * values');
knapsack = @(X) -(X * values') + 1000 * max(X * weights' - capacity, 0);
% a genetic algorithm is a heuristic: with the default mutation rate (0.01, as MathWorks) about
% nine runs in ten reach the optimum; with a mutation rate of 1/nvars (a custom mutation
% function, as optGene uses) and 100 individuals, 20 of 20 seeds reached it when this test was
% written, so the optimum is required for three seeds
knapsackOptions = struct('PopulationType', 'bitstring', 'Vectorized', 'on', 'Display', 'off', 'PopulationSize', 100, ...
    'Generations', 500, 'StallGenLimit', 100, 'MutationFcn', {{@bitFlipMutation, 1 / 15}});
for seed = 1:3
    rng(seed);
    [x, fval] = cobraGa(struct('fitnessfcn', knapsack, 'nvars', 15, 'options', knapsackOptions));
    assert(fval == -optimum && x * weights' <= capacity && x * values' == optimum);
end

%% reproducibility with a fixed seed (generation-based stop) and elitism (best never worsens)

problem = struct('fitnessfcn', knapsack, 'nvars', 15, 'options', ...
    setfield(setfield(quietBitstring, 'PopulationSize', 40), 'Generations', 30));
rng(5);
[x1, fval1, ~, output1, population1, scores1] = cobraGa(problem);
rng(5);
[x2, fval2, ~, output2, population2, scores2] = cobraGa(problem);
assert(isequal(x1, x2) && fval1 == fval2 && isequal(population1, population2) && isequal(scores1, scores2));
assert(output1.generations == output2.generations && isequal(output1.rngstate, output2.rngstate));
% the run with fewer generations is a prefix of the same run: its best value is never better
bestByGenerations = zeros(1, 4);
for k = 1:4
    rng(5);
    [~, bestByGenerations(k)] = cobraGa(setfield(problem, 'options', setfield(problem.options, 'Generations', 5 * k)));
end
assert(all(diff(bestByGenerations) <= 0));

%% migration between subpopulations (deterministic: all individuals are elite, no children)

% two subpopulations of four; every generation the best two of each replace the worst two of
% the next one (forward, wrapping); fitness = -(number of ones)
initial = [1 1 1 0; 1 0 0 0; 0 0 0 0; 1 1 0 0; ...   % subpopulation 1: scores -3 -1 0 -2
    0 0 0 1; 1 1 1 1; 0 1 0 0; 0 0 1 1];             % subpopulation 2: scores -1 -4 -1 -2
migrationOptions = struct('PopulationType', 'bitstring', 'Vectorized', 'on', 'Display', 'off', ...
    'PopulationSize', [4 4], 'InitialPopulation', initial, 'EliteCount', 4, 'Generations', 1, ...
    'MigrationInterval', 1, 'MigrationFraction', 0.5);
[~, fval, ~, ~, population, scores] = cobraGa(struct('fitnessfcn', @(X) -sum(X, 2), 'nvars', 4, 'options', migrationOptions));
% after breeding each subpopulation is sorted by score; then subpopulation 2 receives the best
% two of subpopulation 1 ([1 1 1 0], [1 1 0 0]) in place of its worst two, and subpopulation 1
% receives the best two of subpopulation 2 ([1 1 1 1], one of the -2 rows: [0 0 1 1])
assert(isequal(sortrows(population(1:4, :)), sortrows([1 1 1 0; 1 1 0 0; 1 1 1 1; 0 0 1 1])));
assert(isequal(sortrows(population(5:8, :)), sortrows([1 1 1 1; 0 0 1 1; 1 1 1 0; 1 1 0 0])));
assert(isequal(scores, -sum(population, 2)) && fval == -4);

%% optGene's operators: custom creation, crossover with an extra rate, mutation {handle, rate}

global MaxKnockOuts
MaxKnockOuts = 3;
rng(2);
optGeneOptions = struct('PopulationType', 'bitstring', 'CreationFcn', @lowmutationcreation, ...
    'MutationFcn', {{@mutationUniformEqual, 1 / 20}}, 'PopulationSize', [20 20 20 20], ...
    'InitialPopulation', [], 'CrossoverFraction', 0.8, ...
    'CrossoverFcn', @(a, b, c, d, e, f) crossoverCustom(a, b, c, d, e, f, 0.2 / 20), ...
    'StallGenLimit', 1000, 'Generations', 60, 'TolFun', 1e-10, 'Vectorize', 'on', ...
    'MigrationFraction', 0.1, 'MigrationInterval', 5, 'StallTimeLimit', 3600, 'TimeLimit', 7200, 'Display', 'off');
% the fitness gives 0 to individuals with more than MaxKnockOuts ones, as optGene's fitness does
% (its creation function can produce such rows; crossover and mutation never do)
cappedOneMax = @(X) -sum(X, 2) .* (sum(X, 2) <= MaxKnockOuts);
[x, fval, exitflag, ~, population] = cobraGa(struct('fitnessfcn', cappedOneMax, 'nvars', 20, 'options', optGeneOptions));
% the optimum is -3; after the first generation every row is a capped child or an elite row
assert(fval == -3 && sum(x) == 3 && all(sum(population, 2) <= 3) && exitflag == 0 && size(population, 1) == 80);
clear global MaxKnockOuts

%% exit flags

oneMax = struct('fitnessfcn', @(X) -sum(X, 2), 'nvars', 30, 'options', quietBitstring);
rng(3);
[~, ~, exitflag, output] = cobraGa(setfield(oneMax, 'options', setfield(quietBitstring, 'Generations', 3)));
assert(exitflag == 0 && output.generations == 3 && contains(output.message, 'generations'));
[~, fval, exitflag] = cobraGa(setfield(oneMax, 'options', setfield(quietBitstring, 'FitnessLimit', -10)));
assert(exitflag == 5 && fval <= -10);
constant = struct('fitnessfcn', @(X) zeros(size(X, 1), 1), 'nvars', 8, 'options', setfield(quietBitstring, 'StallGenLimit', 5));
[~, ~, exitflag, output] = cobraGa(constant);
assert(exitflag == 1 && output.generations == 5);
[~, ~, exitflag] = cobraGa(setfield(oneMax, 'options', setfield(quietBitstring, 'TimeLimit', 0)));
assert(exitflag == -5);
[~, ~, exitflag] = cobraGa(setfield(constant, 'options', setfield(quietBitstring, 'StallTimeLimit', 0)));
assert(exitflag == -4);

%% non-vectorized fitness, initial population, default population size for few variables

rng(4);
initialRows = [1 1 0; 0 1 1];
problem = struct('fitnessfcn', @(x) -sum(x), 'nvars', 3, 'options', ...
    struct('PopulationType', 'bitstring', 'InitialPopulation', initialRows, 'Generations', 1, 'Display', 'off'));
[~, ~, ~, output, population] = cobraGa(problem);
% 50 individuals for nvars <= 5; the evaluation count covers the initial population and the
% non-elite children of the first generation (50 - ceil(0.05*50) = 47)
assert(size(population, 1) == 50 && output.funccount == 50 + 47);

%% display: the stop message is printed unless Display is 'off'

printedMessage = evalc('cobraGa(setfield(oneMax, ''options'', rmfield(setfield(quietBitstring, ''Generations'', 1), ''Display'')));');
assert(contains(printedMessage, 'maximum number of generations'));

%% errors: unsupported options and invalid problems

assert(verifyCobraFunctionError('cobraGa', 'inputs', {setfield(oneMax, 'options', struct('PopulationType', 'doubleVector'))}, ...
    'testMessage', 'cobraGa: unsupported option ''PopulationType'' value ''doubleVector'' (only ''bitstring'' is supported).'));
assert(verifyCobraFunctionError('cobraGa', 'inputs', {setfield(oneMax, 'options', setfield(quietBitstring, 'PlotFcns', {}))}, ...
    'testMessage', 'cobraGa: unsupported option ''PlotFcns''.'));
assert(verifyCobraFunctionError('cobraGa', 'inputs', {setfield(oneMax, 'options', setfield(quietBitstring, 'MigrationDirection', 'both'))}, ...
    'testMessage', 'cobraGa: unsupported option ''MigrationDirection'' value ''both''.'));
assert(verifyCobraFunctionError('cobraGa', 'inputs', {struct('nvars', 3)}, ...
    'testMessage', 'cobraGa: problem must be a structure with fields fitnessfcn and nvars.'));
% without options the default population type (doubleVector) is not supported
assert(verifyCobraFunctionError('cobraGa', 'inputs', {struct('fitnessfcn', @(x) 0, 'nvars', 3)}, ...
    'testMessage', 'cobraGa: unsupported option ''PopulationType'' value ''doubleVector'' (only ''bitstring'' is supported).'));

%% parity with ga (only where the Global Optimization Toolbox is installed)

if exist('ga', 'file') == 2 && license('test', 'GADS_Toolbox')
    rng(1);
    toolboxOptions = gaoptimset('PopulationType', 'bitstring', 'Vectorized', 'on', 'Display', 'off', ...
        'PopulationSize', 100, 'Generations', 500, 'StallGenLimit', 100, 'MutationFcn', {@bitFlipMutation, 1 / 15});
    [~, fvalToolbox] = ga(struct('fitnessfcn', knapsack, 'nvars', 15, 'options', toolboxOptions, 'solver', 'ga'));
    % the same optimum (found by enumeration above), not the same iterates
    assert(fvalToolbox == -optimum);
    fprintf('parity with ga: passed\n');
else
    fprintf('skipped: Global Optimization Toolbox not installed\n');
end

% change the directory
cd(currentDir)

function children = bitFlipMutation(parents, options, nvars, fitnessFcn, state, scores, population, rate)
% Bit-flip mutation with probability rate per bit (custom MutationFcn with an extra argument)
children = population(parents, :);
flips = rand(size(children)) < rate;
children(flips) = 1 - children(flips);
end

% ---- copies of the local operators of src/design/optGene.m (as of 2026-11-11) ----

function [Population] = lowmutationcreation(GenomeLength, FitnessFcn, options)
% optGene creation function: provided rows, then on average one bit set per row
totalPopulation = sum(options.PopulationSize);
initPopProvided = size(options.InitialPopulation, 1);
individualsToCreate = totalPopulation - initPopProvided;
Population = true(totalPopulation, GenomeLength);
if initPopProvided > 0
    Population(1:initPopProvided, :) = options.InitialPopulation;
end
Population(initPopProvided + 1:end, :) = logical(1 / GenomeLength > rand(individualsToCreate, GenomeLength));
end

function mutationChildren = mutationUniformEqual(parents, options, GenomeLength, FitnessFcn, state, thisScore, thisPopulation, mutationRate)
% optGene mutation function: bit flips, at most MaxKnockOuts ones, tends to fewer ones
global MaxKnockOuts
mutationChildren = zeros(length(parents), GenomeLength);
for i = 1:length(parents)
    child = thisPopulation(parents(i), :);
    kos = sum(child);
    mutationPoints = find(rand(1, length(child)) < mutationRate);
    child(mutationPoints) = ~child(mutationPoints);
    while sum(child(:)) > MaxKnockOuts
        ind2 = find(child);
        child(ind2(randi(length(ind2), 1))) = 0;
    end
    if rand > .5 && kos > 1
        while sum(child(:)) >= kos
            ind2 = find(child);
            child(ind2(randi(length(ind2), 1))) = 0;
        end
    end
    mutationChildren(i, :) = child;
end
end

function xoverKids = crossoverCustom(parents, options, GenomeLength, FitnessFcn, unused, thisPopulation, mutationRate)
% optGene crossover function: uniform crossover of parent pairs, then mutation
global MaxKnockOuts
nKids = length(parents) / 2;
xoverKids = zeros(nKids, GenomeLength);
index = 1;
for i = 1:nKids
    r1 = parents(index);
    r2 = parents(index + 1);
    index = index + 2;
    for j = 1:GenomeLength
        if rand > 0.5
            xoverKids(i, j) = thisPopulation(r1, j);
        else
            xoverKids(i, j) = thisPopulation(r2, j);
        end
    end
    while sum(xoverKids(i, :)) > MaxKnockOuts
        ind2 = find(xoverKids(i, :));
        xoverKids(i, ind2(randi(length(ind2), 1))) = 0;
    end
end
xoverKids = mutationUniformEqual(1:size(xoverKids, 1), [], GenomeLength, [], [], [], xoverKids, mutationRate);
end
