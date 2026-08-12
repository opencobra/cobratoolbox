function results = benchmarkGurobiThreads(modelPath, varargin)
% Benchmark Gurobi solver with different thread counts and parameters
% to isolate performance bottleneck vs Python implementation.
%
% USAGE:
%    results = benchmarkGurobiThreads('path/to/mWBM_S85_male_lifted.mat');
%    results = benchmarkGurobiThreads(..., 'threads', [1 2 4 8 16 20]);
%    results = benchmarkGurobiThreads(..., 'iterations', 3, 'out', 'results.json');
%
% INPUT:
%    modelPath:  Path to mWBM .mat file
%
% OPTIONAL:
%    threads:    Thread counts to test (default: [1 2 4 8 16 20])
%    iterations: Number of iterations per config (default: 1)
%    out:        JSON output file path (default: none)
%    verbose:    Print solver output (default: false)
%
% OUTPUT:
%    results:    Struct array with timing results for each config

p = inputParser;
addParameter(p, 'threads', [1 2 4 8 16 20], @isvector);
addParameter(p, 'iterations', 1, @isscalar);
addParameter(p, 'out', '', @ischar);
addParameter(p, 'verbose', false, @islogical);
parse(p, varargin{:});

threads = p.Results.threads;
iterations = p.Results.iterations;
outFile = p.Results.out;
verbose = p.Results.verbose;

% Load model
fprintf('Loading %s...\n', modelPath);
tic;
load(modelPath);
loadTime = toc;

% Build LP problem (same as COBRA's buildOptProblemFromModel)
fprintf('Building LP problem...\n');
tic;
% Construct the stacked constraint matrix [S; C]
A_mat = [S; C];
b_vec = [b; d];
csense_vec = [csense; dsense];

% Combined variable bounds - handle both naming conventions
if exist('evarlb', 'var')
    lb_all = [lb; evarlb];
    ub_all = [ub; evarub];
    c_all = [c; evarc];
else
    lb_all = lb;
    ub_all = ub;
    c_all = c;
end

% Determine osense
osense_val = -1;  % default maximize
if exist('osenseStr', 'var') && strcmp(osenseStr, 'min')
    osense_val = 1;
elseif exist('osense', 'var') && osense == 1
    osense_val = 1;
end

fprintf('  Problem: %d vars, %d constraints, osense=%d\n', length(c_all), length(b), osense);
buildTime = toc;

% Prepare Gurobi parameter structure
baseParams.OutputFlag = 0;
baseParams.ScaleFlag = 2;

% Store results
resultIdx = 1;
configResults = struct('threads', {}, 'solve_time', {}, 'status', {}, 'objective', {});

% =========================================================================
% TEST 1: Varying thread count
% =========================================================================
fprintf('\n%s\n', repmat('=', 1, 80));
fprintf('TEST 1: Varying thread count (default Presolve, ScaleFlag=2)\n');
fprintf('%s\n\n', repmat('=', 1, 80));

for t = threads
    fprintf('Threads=%d, iterations=%d\n', t, iterations);
    times = [];

    for iter = 1:iterations
        % Build Gurobi problem
        gurobiModel = buildGurobiProblemFromModel(struct('S', S, 'C', C, 'b', b, ...
            'c', c_all, 'lb', lb_all, 'ub', ub_all, 'csense', csense, 'osense', osense));

        % Set solver parameters
        params = baseParams;
        params.Threads = t;
        params.Method = -1;  % Auto

        % Measure solve time
        tic;
        result = gurobi(gurobiModel, params);
        solveTime = toc;
        times = [times; solveTime];

        stat = mapSolverStatus('gurobi', 'LP', result.status);
        obj = result.objval;
        fprintf('  [%d] solve=%.2fs  status=%s  obj=%.6e\n', iter, solveTime, result.status, obj);

        % Store result
        configResults(resultIdx).threads = t;
        configResults(resultIdx).presolve = [];
        configResults(resultIdx).method = -1;
        configResults(resultIdx).solve_time = solveTime;
        configResults(resultIdx).status = stat;
        configResults(resultIdx).objective = obj;
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
        % Build Gurobi problem
        gurobiModel = buildGurobiProblemFromModel(struct('S', S, 'C', C, 'b', b, ...
            'c', c_all, 'lb', lb_all, 'ub', ub_all, 'csense', csense, 'osense', osense));

        % Set solver parameters
        params = baseParams;
        params.Threads = threads(end);
        params.Presolve = presolveVal;
        params.Method = -1;

        % Measure solve time
        tic;
        result = gurobi(gurobiModel, params);
        solveTime = toc;
        times = [times; solveTime];

        stat = mapSolverStatus('gurobi', 'LP', result.status);
        fprintf('  [%d] solve=%.2fs  status=%s\n', iter, solveTime, result.status);

        % Store result
        configResults(resultIdx).threads = threads(end);
        configResults(resultIdx).presolve = presolveVal;
        configResults(resultIdx).method = -1;
        configResults(resultIdx).solve_time = solveTime;
        configResults(resultIdx).status = stat;
        configResults(resultIdx).objective = result.objval;
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
        % Build Gurobi problem
        gurobiModel = buildGurobiProblemFromModel(struct('S', S, 'C', C, 'b', b, ...
            'c', c_all, 'lb', lb_all, 'ub', ub_all, 'csense', csense, 'osense', osense));

        % Set solver parameters
        params = baseParams;
        params.Threads = threads(end);
        params.Presolve = 1;
        params.Method = method;

        % Measure solve time
        tic;
        result = gurobi(gurobiModel, params);
        solveTime = toc;
        times = [times; solveTime];

        stat = mapSolverStatus('gurobi', 'LP', result.status);
        fprintf('  [%d] solve=%.2fs  status=%s\n', iter, solveTime, result.status);

        % Store result
        configResults(resultIdx).threads = threads(end);
        configResults(resultIdx).presolve = 1;
        configResults(resultIdx).method = method;
        configResults(resultIdx).solve_time = solveTime;
        configResults(resultIdx).status = stat;
        configResults(resultIdx).objective = result.objval;
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
[minTime, minIdx] = min([configResults.solve_time]);
[maxTime, maxIdx] = max([configResults.solve_time]);

fastest = configResults(minIdx);
slowest = configResults(maxIdx);

fprintf('Fastest:  threads=%d  presolve=%s  method=%d  time=%.2fs\n', ...
    fastest.threads, mat2str(fastest.presolve), fastest.method, fastest.solve_time);
fprintf('Slowest:  threads=%d  presolve=%s  method=%d  time=%.2fs\n', ...
    slowest.threads, mat2str(slowest.presolve), slowest.method, slowest.solve_time);
fprintf('Speedup:  %.1fx\n\n', slowest.solve_time / fastest.solve_time);

% Save to JSON if requested
if ~isempty(outFile)
    results = struct();
    results.model = modelPath;
    results.load_time = loadTime;
    results.build_time = buildTime;
    results.problem.rows = size(A, 1);
    results.problem.cols = size(A, 2);
    results.configs = configResults;

    jsonStr = jsonencode(results);
    fid = fopen(outFile, 'w');
    fprintf(fid, '%s', jsonStr);
    fclose(fid);
    fprintf('Saved results to %s\n', outFile);
end

results = configResults;
end
