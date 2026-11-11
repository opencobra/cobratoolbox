function [x, fval, exitflag, output, population, scores] = cobraGa(problem)
% Genetic algorithm for bit-string problems, without the Global Optimization
% Toolbox
%
% USAGE:
%
%    [x, fval, exitflag, output, population, scores] = cobraGa(problem)
%
% INPUT:
%    problem:      structure with fields
%
%                    * fitnessfcn - handle of the function to minimize; it takes one individual
%                      (1 x nvars) or, with Vectorized = 'on', all individuals (rows) at once and
%                      returns one value per individual (row or column)
%                    * nvars - number of bits per individual
%                    * options - structure of options with gaoptimset names (case-insensitive;
%                      a plain structure replaces gaoptimset): PopulationType ('bitstring'),
%                      PopulationSize (scalar, or a vector of subpopulation sizes; default 50
%                      for nvars <= 5, else 200), InitialPopulation, CreationFcn, CrossoverFcn,
%                      MutationFcn (a handle or {handle, extra arguments}), CrossoverFraction
%                      (0.8), EliteCount (ceil(0.05*subpopulation size)), Generations
%                      (100*nvars), StallGenLimit (50), StallTimeLimit (Inf), TimeLimit (Inf),
%                      FitnessLimit (-Inf), TolFun (1e-6), Vectorized or Vectorize ('off'),
%                      MigrationDirection ('forward'), MigrationFraction (0.2),
%                      MigrationInterval (20), Display ('final' or 'off')
%
% OUTPUTS:
%    x:            best individual found (1 x nvars double of 0 and 1)
%    fval:         its fitness value
%    exitflag:     1 average relative change of the best value over StallGenLimit generations
%                  <= TolFun, 5 FitnessLimit reached, 0 Generations reached, -4 StallTimeLimit,
%                  -5 TimeLimit
%    output:       structure with `problemtype`, `rngstate` (state of the random number
%                  generator before the run), `generations`, `funccount`, `message` and
%                  `maxconstraint`
%    population:   final population (sum(PopulationSize) x nvars double; subpopulations in order)
%    scores:       column of the fitness values of `population`
%
% EXAMPLE:
%
%    problem = struct('fitnessfcn', @(X) -sum(X, 2), 'nvars', 20, 'options', ...
%        struct('PopulationType', 'bitstring', 'Vectorized', 'on', 'Display', 'off'));
%    [x, fval] = cobraGa(problem)   % x = ones(1, 20), fval = -20
%
% NOTE:
%    Plain-MATLAB replacement for ga with gaoptimset options and PopulationType 'bitstring'
%    (Global Optimization Toolbox), as used by optGene; other population types, other selection
%    or scaling functions, PlotFcns and any other option raise an error naming it; semantics:
%    specs/20261111-152503-toolbox-free-remaining/mathworks-semantics.md, G2 section 4.
%    Each generation and subpopulation (MathWorks, "How the Genetic Algorithm Works"): rank
%    scaling of the scores (expectation proportional to 1/sqrt(rank), summing to the number of
%    parents; the documentation says 1/rank, a MathWorks staff answer the square root, the
%    exponent is UNCONFIRMED), stochastic universal sampling of 2*nCrossover + nMutation parents
%    (Baker 1987), EliteCount best individuals kept with their scores, nCrossover =
%    round(CrossoverFraction*(size - EliteCount)) crossover children and the remaining mutation
%    children. Custom functions are called as CreationFcn(nvars, fitnessfcn, options),
%    CrossoverFcn(parents, options, nvars, fitnessfcn, scores, population, extra...) and
%    MutationFcn(parents, options, nvars, fitnessfcn, state, scores, population, extra...);
%    defaults are random bits (creation), scattered crossover and bit flips with probability
%    0.01. Every MigrationInterval generations the floor(MigrationFraction*min(size)) best
%    individuals of each subpopulation replace the worst of the next one (forward, wrapping).
%    Stopping tests after each generation, in this order: FitnessLimit, Generations, TimeLimit,
%    StallTimeLimit, then |best(g - L) - best(g)|/max(1, |best(g)|)/L <= TolFun with
%    L = StallGenLimit. Random numbers come only from rand, randi and randperm, so a run with
%    a fixed rng seed and no time-based stop is reproducible. Same algorithm class as ga; the
%    iterates differ (maintainer decision 2026-11-11: correctness is reaching the optimum).
%
% .. Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

if ~isstruct(problem) || ~isfield(problem, 'fitnessfcn') || ~isfield(problem, 'nvars')
    error('COBRA:cobraGa:invalidInput', 'cobraGa: problem must be a structure with fields fitnessfcn and nvars.');
end
nvars = problem.nvars;
fitnessFcn = problem.fitnessfcn;
if isfield(problem, 'options') && ~isempty(problem.options)
    userOptions = problem.options;
else
    userOptions = struct();
end
if nvars <= 5
    defaultSize = 50;
else
    defaultSize = 200;
end
settings = struct('PopulationType', 'doubleVector', 'PopulationSize', defaultSize, 'InitialPopulation', [], ...
    'CreationFcn', [], 'CrossoverFcn', [], 'MutationFcn', [], 'CrossoverFraction', 0.8, 'EliteCount', [], ...
    'Generations', 100 * nvars, 'StallGenLimit', 50, 'StallTimeLimit', Inf, 'TimeLimit', Inf, ...
    'FitnessLimit', -Inf, 'TolFun', 1e-6, 'Vectorized', 'off', 'MigrationDirection', 'forward', ...
    'MigrationFraction', 0.2, 'MigrationInterval', 20, 'Display', 'final');
settingNames = fieldnames(settings);
givenNames = fieldnames(userOptions);
for k = 1:numel(givenNames)
    name = givenNames{k};
    if strcmpi(name, 'Vectorize')
        name = 'Vectorized';
    end
    match = settingNames(strcmpi(settingNames, name));
    if isempty(match)
        error('COBRA:cobraGa:unsupportedOption', 'cobraGa: unsupported option ''%s''.', givenNames{k});
    end
    settings.(match{1}) = userOptions.(givenNames{k});
end
if ~strcmpi(settings.PopulationType, 'bitstring')
    error('COBRA:cobraGa:unsupportedOption', ...
        'cobraGa: unsupported option ''PopulationType'' value ''%s'' (only ''bitstring'' is supported).', char(settings.PopulationType));
end
if ~strcmpi(settings.MigrationDirection, 'forward')
    error('COBRA:cobraGa:unsupportedOption', 'cobraGa: unsupported option ''MigrationDirection'' value ''%s''.', char(settings.MigrationDirection));
end
isVectorized = strcmpi(settings.Vectorized, 'on');
isQuiet = strcmpi(settings.Display, 'off');

% the options structure handed to custom functions has the names they read
functionOptions = settings;
subpopulationSizes = settings.PopulationSize(:)';
total = sum(subpopulationSizes);
lastRow = cumsum(subpopulationSizes);
firstRow = lastRow - subpopulationSizes + 1;

output = struct('problemtype', 'unconstrained', 'rngstate', rng, 'generations', 0, 'funccount', 0, ...
    'message', '', 'maxconstraint', []);
startTime = tic;

% initial population
if isempty(settings.CreationFcn)
    population = zeros(total, nvars);
    nProvided = size(settings.InitialPopulation, 1);
    population(1:nProvided, :) = settings.InitialPopulation;
    population(nProvided + 1:end, :) = rand(total - nProvided, nvars) < 0.5;
else
    population = double(settings.CreationFcn(nvars, fitnessFcn, functionOptions));
end
[scores, output.funccount] = evaluate(fitnessFcn, population, isVectorized, output.funccount);
bestHistory = min(scores);
lastImprovement = tic;

generation = 0;
exitflag = [];
while isempty(exitflag)
    generation = generation + 1;
    state = struct('Generation', generation, 'Population', population, 'Score', scores, ...
        'Best', bestHistory, 'StartTime', startTime);
    newPopulation = zeros(total, nvars);
    newScores = NaN(total, 1);
    for s = 1:numel(subpopulationSizes)
        rows = firstRow(s):lastRow(s);
        [newPopulation(rows, :), newScores(rows)] = breed(population(rows, :), scores(rows), settings, ...
            functionOptions, nvars, fitnessFcn, state);
    end
    % evaluate all new children of all subpopulations together (elite individuals keep their scores)
    isNew = isnan(newScores);
    [newScores(isNew), output.funccount] = evaluate(fitnessFcn, newPopulation(isNew, :), isVectorized, output.funccount);
    population = newPopulation;
    scores = newScores;

    % forward migration with wrapping: copies of the best replace the worst of the next subpopulation
    if numel(subpopulationSizes) > 1 && mod(generation, settings.MigrationInterval) == 0
        nMigrants = floor(settings.MigrationFraction * min(subpopulationSizes));
        if nMigrants > 0
            migrants = cell(numel(subpopulationSizes), 1);
            for s = 1:numel(subpopulationSizes)
                rows = firstRow(s):lastRow(s);
                [~, order] = sort(scores(rows));
                migrants{s} = rows(order(1:nMigrants));
            end
            sourcePopulation = population;
            sourceScores = scores;
            for s = 1:numel(subpopulationSizes)
                target = mod(s, numel(subpopulationSizes)) + 1;
                rows = firstRow(target):lastRow(target);
                [~, order] = sort(scores(rows), 'descend');
                worst = rows(order(1:nMigrants));
                population(worst, :) = sourcePopulation(migrants{s}, :);
                scores(worst) = sourceScores(migrants{s});
            end
        end
    end

    best = min(scores);
    if best < bestHistory(end)
        lastImprovement = tic;
    end
    bestHistory(end + 1) = best; %#ok<AGROW>

    stallWindow = settings.StallGenLimit;
    if best <= settings.FitnessLimit
        exitflag = 5;
        output.message = 'Optimization terminated: minimum fitness limit reached.';
    elseif generation >= settings.Generations
        exitflag = 0;
        output.message = 'Optimization terminated: maximum number of generations exceeded.';
    elseif toc(startTime) > settings.TimeLimit
        exitflag = -5;
        output.message = 'Optimization terminated: time limit exceeded.';
    elseif toc(lastImprovement) > settings.StallTimeLimit
        exitflag = -4;
        output.message = 'Optimization terminated: stall time limit exceeded.';
    elseif generation >= stallWindow && ...
            abs(bestHistory(end - stallWindow) - best) / max(1, abs(best)) / stallWindow <= settings.TolFun
        exitflag = 1;
        output.message = 'Optimization terminated: average change in the fitness value less than TolFun.';
    end
end
output.generations = generation;
[fval, bestIndex] = min(scores);
x = population(bestIndex, :);
if ~isQuiet
    fprintf('cobraGa: %s\n', output.message);
end
end

function [children, childScores] = breed(population, scores, settings, functionOptions, nvars, fitnessFcn, state)
% One generation of one subpopulation: elite individuals, crossover and mutation children
subpopulationSize = size(population, 1);
if isempty(settings.EliteCount)
    nElite = ceil(0.05 * subpopulationSize);
else
    nElite = min(settings.EliteCount, subpopulationSize);
end
nCrossover = round(settings.CrossoverFraction * (subpopulationSize - nElite));
nMutation = subpopulationSize - nElite - nCrossover;
nParents = 2 * nCrossover + nMutation;

[~, order] = sort(scores);
% rank scaling: expectation proportional to 1/sqrt(rank), summing to the number of parents
expectation = zeros(subpopulationSize, 1);
expectation(order) = 1 ./ sqrt(1:subpopulationSize);
expectation = nParents * expectation / sum(expectation);
% stochastic universal sampling: nParents equally spaced pointers from one random start
wheel = cumsum(expectation);
wheel(end) = nParents; % exact end of the wheel, so that every pointer (< nParents) is inside
pointers = rand + (0:nParents - 1)';
parents = zeros(1, nParents);
for k = 1:nParents
    parents(k) = find(wheel >= pointers(k), 1);
end
parents = parents(randperm(nParents));

elite = population(order(1:nElite), :);
crossoverParents = parents(1:2 * nCrossover);
mutationParents = parents(2 * nCrossover + 1:end);
if isempty(settings.CrossoverFcn)
    crossoverChildren = zeros(nCrossover, nvars);
    for k = 1:nCrossover
        mask = rand(1, nvars) > 0.5;
        first = population(crossoverParents(2 * k - 1), :);
        second = population(crossoverParents(2 * k), :);
        crossoverChildren(k, :) = first .* mask + second .* ~mask;
    end
else
    [crossoverFcn, extra] = splitFunction(settings.CrossoverFcn);
    crossoverChildren = crossoverFcn(crossoverParents, functionOptions, nvars, fitnessFcn, scores, population, extra{:});
end
if isempty(settings.MutationFcn)
    mutationChildren = population(mutationParents, :);
    flips = rand(nMutation, nvars) < 0.01;
    mutationChildren(flips) = 1 - mutationChildren(flips);
else
    [mutationFcn, extra] = splitFunction(settings.MutationFcn);
    mutationChildren = mutationFcn(mutationParents, functionOptions, nvars, fitnessFcn, state, scores, population, extra{:});
end
children = double([elite; crossoverChildren; mutationChildren]);
childScores = [scores(order(1:nElite)); NaN(nCrossover + nMutation, 1)];
end

function [handle, extra] = splitFunction(specification)
% A function handle, or a cell {handle, extra arguments...}
if iscell(specification)
    handle = specification{1};
    extra = specification(2:end);
else
    handle = specification;
    extra = {};
end
end

function [values, funccount] = evaluate(fitnessFcn, individuals, isVectorized, funccount)
% Fitness values of the rows of individuals, as a column
if isempty(individuals)
    values = zeros(0, 1);
    return
end
if isVectorized
    values = fitnessFcn(individuals);
    values = double(values(:));
else
    values = zeros(size(individuals, 1), 1);
    for k = 1:size(individuals, 1)
        values(k) = fitnessFcn(individuals(k, :));
    end
end
funccount = funccount + size(individuals, 1);
end
