function results = benchmarkGurobiSimple(modelPath, varargin)
% Simple Gurobi LP benchmark using COBRA's solveCobraLP function
%
% USAGE:
%    results = benchmarkGurobiSimple('path/to/mWBM_S85_male_lifted.mat');
%
% INPUT:
%    modelPath:  Path to .mat file containing model
%
% OPTIONAL:
%    threads:    Thread counts to test (default: [1 2 4 8 16 20])
%    iterations: Repetitions per config (default: 1)
%    out:        JSON output file path (default: none)

p = inputParser;
addParameter(p, 'threads', [1 2 4 8 16 20], @isvector);
addParameter(p, 'iterations', 1, @isscalar);
addParameter(p, 'out', '', @ischar);
parse(p, varargin{:});

threads = p.Results.threads;
iterations = p.Results.iterations;
outFile = p.Results.out;

% Load model
fprintf('Loading %s...\n', modelPath);
tic;
loaded = load(modelPath);
loadTime = toc;

% Extract model struct - handle both direct and wrapped models
if isfield(loaded, 'model')
    model = loaded.model;
else
    % Unpack all fields from loaded struct
    modelFields = fieldnames(loaded);
    model = struct();
    for i = 1:length(modelFields)
        model.(modelFields{i}) = loaded.(modelFields{i});
    end
end

fprintf('  loaded model with %d reactions\n', length(model.c));

% Build LP problem from model
fprintf('Building LP...\n');
tic;
lpProblem = buildOptProblemFromModel(model);
buildTime = toc;
fprintf('  LP: %d vars, %d constraints\n', length(lpProblem.c), size(lpProblem.A, 1));

% Initialize results
resultIdx = 1;
allResults = struct('threads', {}, 'solve_time', {}, 'objective', {}, 'status', {});

% =========================================================================
% TEST 1: Varying thread count
% =========================================================================
fprintf('\n%s\n', repmat('=', 1, 80));
fprintf('TEST 1: Varying thread count\n');
fprintf('%s\n\n', repmat('=', 1, 80));

for t = threads
    fprintf('Threads=%d, iterations=%d\n', t, iterations);
    times = [];

    for iter = 1:iterations
        % Create solver params
        params = getCobraSolverParams('LP');
        params.gurobi.Threads = t;
        params.gurobi.OutputFlag = 0;
        params.gurobi.ScaleFlag = 2;

        % Solve
        tic;
        solution = solveCobraLP(lpProblem, params);
        solveTime = toc;

        times = [times; solveTime];
        fprintf('  [%d] solve=%.2fs  status=%d  obj=%.6e\n', ...
            iter, solveTime, solution.stat, solution.obj);

        % Store result
        allResults(resultIdx).threads = t;
        allResults(resultIdx).presolve = NaN;
        allResults(resultIdx).method = NaN;
        allResults(resultIdx).solve_time = solveTime;
        allResults(resultIdx).objective = solution.obj;
        allResults(resultIdx).status = solution.stat;
        resultIdx = resultIdx + 1;
    end

    avgTime = mean(times);
    stdTime = std(times);
    fprintf('  → avg=%.2fs ± %.4fs\n\n', avgTime, stdTime);
end

% =========================================================================
% TEST 2: Presolve on/off
% =========================================================================
fprintf('%s\n', repmat('=', 1, 80));
fprintf('TEST 2: Presolve on/off (threads=%d)\n', threads(end));
fprintf('%s\n\n', repmat('=', 1, 80));

for presolveVal = [1, 0]
    presolveLabel = 'ON';
    if presolveVal == 0
        presolveLabel = 'OFF';
    end
    fprintf('Presolve=%s (threads=%d), iterations=%d\n', presolveLabel, threads(end), iterations);
    times = [];

    for iter = 1:iterations
        % Create solver params
        params = getCobraSolverParams('LP');
        params.gurobi.Threads = threads(end);
        params.gurobi.Presolve = presolveVal;
        params.gurobi.OutputFlag = 0;
        params.gurobi.ScaleFlag = 2;

        % Solve
        tic;
        solution = solveCobraLP(lpProblem, params);
        solveTime = toc;

        times = [times; solveTime];
        fprintf('  [%d] solve=%.2fs  status=%d\n', iter, solveTime, solution.stat);

        % Store result
        allResults(resultIdx).threads = threads(end);
        allResults(resultIdx).presolve = presolveVal;
        allResults(resultIdx).method = NaN;
        allResults(resultIdx).solve_time = solveTime;
        allResults(resultIdx).objective = solution.obj;
        allResults(resultIdx).status = solution.stat;
        resultIdx = resultIdx + 1;
    end

    avgTime = mean(times);
    fprintf('  → avg=%.2fs\n\n', avgTime);
end

% =========================================================================
% TEST 3: Solver method
% =========================================================================
fprintf('%s\n', repmat('=', 1, 80));
fprintf('TEST 3: Solver method (threads=%d, presolve=1)\n', threads(end));
fprintf('%s\n\n', repmat('=', 1, 80));

methodNames = {'-1 (auto)', '0 (primal)', '1 (dual)', '2 (barrier)', '3 (concurrent)'};
methodVals = [-1, 0, 1, 2, 3];

for methodIdx = 1:length(methodVals)
    method = methodVals(methodIdx);
    methodName = methodNames{methodIdx};
    fprintf('Method=%s, iterations=%d\n', methodName, iterations);
    times = [];

    for iter = 1:iterations
        % Create solver params
        params = getCobraSolverParams('LP');
        params.gurobi.Threads = threads(end);
        params.gurobi.Presolve = 1;
        params.gurobi.Method = method;
        params.gurobi.OutputFlag = 0;
        params.gurobi.ScaleFlag = 2;

        % Solve
        tic;
        solution = solveCobraLP(lpProblem, params);
        solveTime = toc;

        times = [times; solveTime];
        fprintf('  [%d] solve=%.2fs  status=%d\n', iter, solveTime, solution.stat);

        % Store result
        allResults(resultIdx).threads = threads(end);
        allResults(resultIdx).presolve = 1;
        allResults(resultIdx).method = method;
        allResults(resultIdx).solve_time = solveTime;
        allResults(resultIdx).objective = solution.obj;
        allResults(resultIdx).status = solution.stat;
        resultIdx = resultIdx + 1;
    end

    avgTime = mean(times);
    fprintf('  → avg=%.2fs\n\n', avgTime);
end

% =========================================================================
% SUMMARY
% =========================================================================
fprintf('%s\n', repmat('=', 1, 80));
fprintf('SUMMARY\n');
fprintf('%s\n\n', repmat('=', 1, 80));

% Find fastest and slowest
[minTime, minIdx] = min([allResults.solve_time]);
[maxTime, maxIdx] = max([allResults.solve_time]);

fastest = allResults(minIdx);
slowest = allResults(maxIdx);

fprintf('Fastest:  threads=%d  time=%.2fs\n', fastest.threads, fastest.solve_time);
fprintf('Slowest:  threads=%d  time=%.2fs\n', slowest.threads, slowest.solve_time);
fprintf('Speedup:  %.1fx\n\n', slowest.solve_time / fastest.solve_time);

% Save to JSON if requested
if ~isempty(outFile)
    results = struct();
    results.model = modelPath;
    results.load_time = loadTime;
    results.build_time = buildTime;
    results.problem.rows = size(lpProblem.A, 1);
    results.problem.cols = length(lpProblem.c);

    % Convert results to cell array for JSON encoding
    configCell = {};
    for i = 1:length(allResults)
        configCell{i} = struct(...
            'threads', allResults(i).threads, ...
            'presolve', allResults(i).presolve, ...
            'method', allResults(i).method, ...
            'solve_time', allResults(i).solve_time, ...
            'objective', allResults(i).objective, ...
            'status', allResults(i).status);
    end
    results.configs = configCell;

    jsonStr = jsonencode(results);
    fid = fopen(outFile, 'w');
    fprintf(fid, '%s', jsonStr);
    fclose(fid);
    fprintf('Saved results to %s\n', outFile);
end

results = allResults;
end
